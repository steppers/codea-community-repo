socket = require("socket")
ltn12 = require("ltn12")

Submission = {}

socket.http.TIMEOUT = 5

local json_state = {
    indent = true,
    keyorder = {
        "name",
        "short_description",
        "description",
        "authors",
        "version",
        "update_notes",
        "category",
        "platform",
        "zip_url",
        "metadata_url",
        "hidden",
        "forum_link"
    }
}

-- Callback format: function(direct_url)
local function upload(filename, filehandle, callback, string_data)
    
    local len = 0
    
    if filehandle then
        len = filehandle:seek("end")
        filehandle:seek("set")
    end
    
    if string_data then
        len = string.len(string_data)
    end
    
    print("Uploading " .. len .. " bytes...")
    
    local boundary = '--WRUploadsy879iuhjkn89iuwbkyjs'
    local header_b = 'Content-Disposition: form-data; name="file"; filename="' .. filename .. '"\r\nContent-Type: text/plain\r\n'
    
    local s1 = '--' .. boundary .. '\r\n' ..header_b ..'\r\n'
    local s2 = (filehandle and ltn12.source.file(filehandle)) or ltn12.source.string(string_data)
    local s3 = '\r\n--' .. boundary ..'--\r\n'
    local source_len = s1:len() + len + s3:len()
    local source = ltn12.source.cat(
        ltn12.source.string(s1),
        s2,
        ltn12.source.string(s3))
    
    local response_body = {}
    local _, code, _, err = socket.http.request {
        url = "https://api.bayfiles.com/upload",
        method = "POST",
        headers = {
            ["Content-Length"] = source_len,
            ["Content-Type"] = 'multipart/form-data; boundary=' .. boundary    
        },
        source = source,
        sink = ltn12.sink.table(response_body),
    }
    
    if code == 200 then
        local response = json.decode(table.concat(response_body))
        callback(response.data.file.url.short)
    else
        print(code, table.concat(response_body))
        callback(nil)
    end
end

function Submission.submitProject(project_name, metadata, progress_cb, error_cb, complete_cb)
    
    if not hasProject("tmp") then
        createProject("tmp")
    end
    
    if asset.documents[project_name .. ".codea"] == nil then
        error_cb("Unable to find project for upload! " .. project_name)
        complete_cb()
        return
    end
    
    -- Strip webrepo version file
    local version_string = readText(asset.documents .. project_name .. ".codea/.webrepo_version")
    saveText(asset.documents .. project_name .. ".codea/.webrepo_version", nil)
        
    progress_cb("Preparing...")
    tween(0.5, {}, {}, nil, function() -- Delay so the zipping message appears
        
        -- Pack dependencies into the project to load automatically
        -- and remove them from Info.plist
        Packager.IncludeDependencies(project_name, true)
        
        -- Split large files
        --splitProject(asset.documents[project_name .. ".codea"])
        
        local archive = Zip(asset.documents .. "tmp.codea/project.zip", true)
        archive:addFolder(asset.documents[project_name .. ".codea"])
        archive:close()
        
        -- Add size to metadata
        metadata.size = archive.uncompressed_size
        
        -- Restore webrepo version 
        saveText(asset.documents .. project_name .. ".codea/.webrepo_version", version_string)
        
        -- Unsplit large files
        --unsplitProject(asset.documents[project_name .. ".codea"])
        
        local file = io.open((asset.documents .. "tmp.codea/project.zip").path, "rb")
        
        -- Upload zip
        progress_cb("Uploading project")
        tween(0.1, {}, {}, nil, function() -- Delay so the message appears
            upload(project_name .. ".zip", file, function(zip_url)
                if zip_url == nil then
                    error_cb("Failed to upload project zip")
                    complete_cb()
                    return
                end
                
                -- Remove key during the upload
                local key = metadata.key
                metadata.key = nil
                
                -- Remove old urls
                metadata.zip_url = nil
                metadata.metadata_url = nil
                
                -- Upload the metadata too
                progress_cb("Uploading metadata")
                tween(0.1, {}, {}, nil, function() -- Delay so the message appears
                    upload(project_name .. "_meta.json", nil, function(metadata_url)
                        if metadata_url == nil then
                            error_cb("Failed to upload metadata file")
                            complete_cb()
                            return
                        end
                        
                        -- Add urls to metadata
                        metadata.zip_url = zip_url
                        metadata.metadata_url = metadata_url
                        
                        -- Restore the key (if any)
                        metadata.key = key
                        
                        -- Send the metadata to the backend for processing (AWS Lambda & Github workflow are available on Github)
                        --
                        -- As we do not automatically download submitted projects, they can technically expire after a preiod of
                        -- time as is Bayfiles' policy.
                        progress_cb("Submitting")
                        http.request("https://" .. _BACKEND_IP_ .. ":8081/submit", function(response, code)
                            if code == 200 then
                                progress_cb("Done!")
                                complete_cb()
                            else
                                error_cb("Code '" .. tostring(code) .. "' when sending review request")
                                complete_cb()
                            end
                        end, function(err)
                            error_cb("'" .. err .. "' when sending review request")
                            complete_cb()
                        end, {
                            method = "POST",
                            headers = {
                                ["Content-Type"] = "application/json"
                            },
                            data = json.encode(metadata, json_state)
                        })
                    end, json.encode(metadata, json_state))
                end)
            end)
            
            deleteProject("tmp")
        end)
    end)
end
