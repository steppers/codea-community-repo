socket = require("socket")
ltn12 = require("ltn12")

Submission = {}

socket.http.TIMEOUT = 15

-- Callback format: function(direct_url)
local function upload(filename, filehandle, callback)
    
    local len = filehandle:seek("end")
    filehandle:seek("set")
    
    print("Uploading " .. len .. " bytes...")
    
    local boundary = '--FileIOUploadsy879iuhjkn89iuwbkyjs'
    local header_b = 'Content-Disposition: form-data; name="file"; filename="' .. filename .. '"\r\nContent-Type: text/plain\r\n'
    
    local s1 = '--' .. boundary .. '\r\n' ..header_b ..'\r\n'
    local s2 = filehandle
    local s3 = '\r\n--' .. boundary ..'--\r\n'
    local source_len = s1:len() + len + s3:len()
    local source = ltn12.source.cat(
        ltn12.source.string(s1),
        ltn12.source.file(s2),
        ltn12.source.string(s3))
    
    local response_body = {}
    local _, code, _, err = socket.http.request {
        url = "https://file.io/",
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
        callback(response.link)
    else
        print(code, table.concat(response_body))
        callback(nil)
    end
end

function Submission.submitProject(project_name, metadata, callback)
    
    if not hasProject("tmp") then
        createProject("tmp")
    end
    
    if asset.documents[project_name .. ".codea"] == nil then
        print("Unable to find project for upload! " .. project_name)
        callback(false)
        return
    end
    
    print("Submitting " .. project_name .. "...")
    
    print("Zipping...")
    local archive = ZipArchive(asset.documents.tmp.path .. "/project.zip", true)
    archive:addFolder(asset.documents[project_name .. ".codea"])
    archive:close()

    local file = io.open(asset.documents.tmp.path .. "/project.zip", "rb")
    
    -- Upload zip
    upload(project_name .. ".zip", file, function(link)
        if link == nil then
            print("Failed to upload project zip")
            callback(false)
            return
        end
        
        metadata.zip_url = link -- Add zip url to metadata
        
        local json_state = {
            indent = true,
            keyorder = {
                "name",
                "short_description",
                "description",
                "authors",
                "version",
                "update_notes",
                "categories",
                "library",
                "zip_url",
                "hidden",
                "review"
            }
        }
        
        -- Send the metadata to the backend for processing (AWS Lambda & Github workflow are available on Github)
        --
        -- PLEASE ONLY USE TO SEND CODEA PROJECTS...
        -- Admittedly, anyone can trigger this lambda any way they like so anything could technically be uploaded
        -- but we'll deal with that issue if it ever comes to it. 
        --
        -- To the Codea community if you want free file storage for your junk there are plenty of alternatives to
        -- ruining this for everyone else. If this does backfire, submissions will likely be trickier in the future
        -- when I disable this method... You've been warned.
        http.request("https://bxdt1ckife.execute-api.eu-west-2.amazonaws.com/submit", function(response, code)
            callback(code == 200)
        end, function(err)
            error(err)
        end, {
            method = "POST",
            headers = {
                ["Content-Type"] = "application/json"
            },
            data = json.encode(metadata, json_state)
        })
    end)
    
    deleteProject("tmp")
end
