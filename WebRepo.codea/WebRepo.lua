--------------------------------------------------------------------------------
-- Requires
--------------------------------------------------------------------------------
local mime = require("mime")





--------------------------------------------------------------------------------
-- Local constants
--------------------------------------------------------------------------------
local GITHUB_USER = "steppers"
local GITHUB_REPO = "codea-community-repo"
local GITHUB_BRANCH = "dev"
local GITHUB_API_URL = "https://api.github.com/repos/" .. GITHUB_USER .. "/" .. GITHUB_REPO .. "/contents/"
local GITHUB_BLOB_URL = "https://api.github.com/repos/" .. GITHUB_USER .. "/" .. GITHUB_REPO .. "/git/blobs/"
local GITHUB_RAW_URL = "https://github.com/" .. GITHUB_USER .. "/" .. GITHUB_REPO .. "/blob/" .. GITHUB_BRANCH .. "/"

local http_params = nil
local http_params_hash = nil

function generateHTTPParams(token)
    http_params = {
        ["method"] = "GET",
        ["headers"] = {
            ["Authorization"] = "token " .. token,
            ["Accept"] = "application/vnd.github.v3+json"
        }
    }
    
    http_params_hash = {
        ["method"] = "HEAD",
        ["headers"] = {
            ["Authorization"] = "token " .. token,
            ["Accept"] = "application/vnd.github.v3+json"
        }
    }
end





--------------------------------------------------------------------------------
-- Local Variables
--------------------------------------------------------------------------------
local project_list = {}





--------------------------------------------------------------------------------
-- Private implementation
--------------------------------------------------------------------------------

-- Callback is called passing the hash of the object or nil if the request failed
-- for any reason
local function getObjSHA(path, cb)
    
    -- Replace spaces in path with '%20'
    path = string.gsub(path, " ", "%%20")
    
    local function on_success(data, status, headers)
        if status == 200 then
            local sha = string.gsub(headers.Etag, "\"", "")
            sha = string.gsub(sha, "W/", "", 1)
            cb(sha)
        else
            cb(nil)
        end
    end
    
    local function on_fail(err)
        print("getObjSHA(" .. path .. ") -> " .. err)
        cb(nil)
    end
    
    http.request(GITHUB_API_URL .. path .. "?ref=" .. GITHUB_BRANCH, on_success, on_fail, http_params_hash)
end

-- Callback is called with table containing repo directory entries, or nil if
-- the http request failed for any reason
local function getDirJson(path, cb)
    local function on_success(data, status, headers)
        if status == 200 then
            cb(json.decode(data))
        else
            cb(nil)
        end
    end
    
    local function on_fail(error)
        cb(nil)
    end
    
    -- Replace spaces in path with '%20'
    path = string.gsub(path, " ", "%%20")
    
    http.request(GITHUB_API_URL .. path .. "?ref=" .. GITHUB_BRANCH, on_success, on_fail, http_params)
end

-- Downloads data associated with the specified SHA.
-- Returned string data is base64 encoded
local function getBlob(sha, cb)
    local function on_success(data, status, headers)
        if status == 200 then
            data = json.decode(data)
            cb(data.content)
        else
            cb(nil)
        end
    end
    
    local function on_fail(error)
        cb(nil)
    end
    
    http.request(GITHUB_BLOB_URL .. sha, on_success, on_fail, http_params)
end

-- Downloads the raw unencoded file at 'path'
local function getRaw(path, cb)
    
    -- Replace spaces in path with '%20'
    path = string.gsub(path, " ", "%%20")
    
    local function on_success(data, status, headers)
        if status == 200 then
            cb(data)
        else
            cb(nil)
        end
    end
    
    local function on_fail(error)
        cb(nil)
    end
    
    http.request(GITHUB_RAW_URL .. path .. "?raw=true", on_success, on_fail, http_params)
end

-- Downloads a file, regardless of the hash and does not cache the response
--
-- The callback will be called passing the file data (as a base64 encoded string)
-- if the download succeeds or nil if the request fails for any reason.
local function getFile(path, cb, hash)
    -- Retrieve the file's sha first so we can access its blob
    getObjSHA(path, function(sha)
        if sha then
            -- If we didn't pass a hash, always download.
            -- Otherwise, only download if the hash differs
            if hash == nil or sha ~= hash then
                getBlob(sha, cb)
            end
        else
            cb(nil)
        end
    end)
end

-- Downloads and caches a project recursively
local function getProjectBundle(name, cb, sha)
    
    local path = project_list[name].path
    
    local downloads = 1
    local function updateProgress()
        downloads = downloads - 1
        if downloads == 0 then
            saveLocalData("sha:" .. path, sha)
            cb(true)
        end
    end
    
    -- Check if we actually need to download or update this folder
    if readLocalData("sha:" .. path) == sha then
        return
    end
    
    -- Retrieve directory info
    getDirJson(path, function(info)
        
        -- Nil check
        if info == nil then
            cb(false)
            return
        end
        
        if not hasProject(name) then
            createProject(name)
        end
        
        for _,entry in pairs(info) do
            if entry.type == "file" then
                -- Check hash
                if entry.sha ~= readLocalData("sha:" .. entry.path) then
                    -- Track download of file
                    downloads = downloads + 1
                    -- Download blob
                    getBlob(entry.sha, function(data)
                        if data then
                            local asset_path = asset .. "/../" .. entry.path
                            data = mime.unb64(data)
                            
                            -- Update API usages
                            if string.sub(entry.path, -4, -1) == ".lua" then
                                data = updateAPI(data)
                            end
                            
                            -- Write directly to the file
                            local file = io.open(asset_path.path, "w")
                            file:write(data)
                            file:close()
                            
                            -- Save the hash
                            saveLocalData("sha:" .. entry.path, entry.sha)
                            
                            updateProgress()
                        else
                            cb(false)
                        end
                    end)
                end
            end
        end
        
        -- Only allow the callback to be triggered once we've made all requests
        updateProgress()
    end)
end

-- Downloads and caches a project recursively
local function getProjectZip(name, cb, sha)
    
    local path = name .. ".zip"
    local project_path = name .. ".codea"
    
    -- Check if we actually need to download or update this project
    if readLocalData("sha:" .. path) == sha then
        cb(true)
        return
    end
    
    -- Download the project's zip file
    getRaw(path, function(data)
        if data == nil then
            cb(false)
            return
        end
        
        local files = zzlib.listzip(data)
        
        if not hasProject(name) then
            createProject(name)
        end
        
        for _,filepath in pairs(files) do
            -- The first part of the filepath must be the same as the project path
            local is_proj_file = string.find(filepath, project_path, 1, true) == 1
            if string.sub(filepath, -1, -1) ~= "/" and is_proj_file then
                local file_data = zzlib.unzip(data, filepath)
                
                -- Update API usages
                if string.sub(filepath, -4, -1) == ".lua" then
                    file_data = updateAPI(file_data)
                end
                
                -- Write directly to the file
                local asset_path = asset .. "/../" .. filepath
                
                if file_data ~= nil then
                    local file = io.open(asset_path.path, "w")
                    file:write(file_data)
                    file:close()
                end
            end
        end
        
        saveLocalData("sha:" .. path, sha)
        cb(true)
    end, nil)
end





--------------------------------------------------------------------------------
-- Public API
--------------------------------------------------------------------------------

-- Initialises the WebRepo library with previously cached data
function initWebRepo(token)
    
    -- Make sure our request parameters are up to date
    generateHTTPParams(token)
    
    -- Download status.lua from the repo and run it
    getFile("status.lua", function(data)
        if data then
            local fn = load(mime.unb64(data))
            if fn then fn() else
                print("status.lua failed to load correctly!")
            end
        else
            print("Codea Web Repository is currently unavailable")
        end
    end)
    
    -- Load the project list from disk
    local pl = readLocalData("project_list")
    if pl then project_list = json.decode(pl) end
    
    -- Check Projects are still installed
    for _,proj in pairs(project_list) do
        if not hasProject(proj.name) then
            proj.installed = false
            proj.upToDate = false
            
            -- Clear hashes
            local hash_root = "sha:" .. proj.path
            local d = listLocalData()
            for _,key in pairs(d) do
                if string.find(key, hash_root, 1, true) then
                    saveLocalData(key, nil)
                end
            end
            saveLocalData(hash_root, nil)
        end
    end
end

-- Grabs the latest list of projects from the repository
-- If we are unable to connect, then this does nothing.
--
-- Callback is called if/when the update completes
function updateWebRepo(cb)
    -- Directories in the root contain projects
    getDirJson("", function(j)
        
        -- Check that we received a response
        if j == nil then
            cb() -- We tried...
            return
        end
        
        -- Mark all projects as unavailable unless they've been installed
        -- This ensures projects that are no longer on the server are not
        -- provided
        for k,proj in pairs(project_list) do
            if not proj.installed then
                project_list[k] = nil
            end
        end
        
        -- Iterate over the dir entries
        for _,v in pairs(j) do
            
            -- zip files contain projects
            if v.type == "file" and string.find(v.name, ".zip") ~= nil then
                
                -- Strip bundle suffix
                v.name = string.gsub(v.name, ".zip", "", 1)
                
                -- Add this project to the list
                local hash = readLocalData("sha:" .. v.path)
                project_list[v.name] = {
                    ["name"] = v.name,
                    ["path"] = v.path,
                    ["sha"] = v.sha,
                    ["installed"] = (hash ~= nil),
                    ["upToDate"] = (hash == v.sha),
                    ["iszip"] = true
                }
            elseif v.type == "dir" and string.find(v.name, ".codea") ~= nil then
                
                -- Strip bundle suffix
                v.name = string.gsub(v.name, ".codea", "", 1)
                
                -- Add this project to the list
                local hash = readLocalData("sha:" .. v.path)
                project_list[v.name] = {
                    ["name"] = v.name,
                    ["path"] = v.path,
                    ["sha"] = v.sha,
                    ["installed"] = (hash ~= nil),
                    ["upToDate"] = (hash == v.sha),
                    ["iszip"] = false
                }
            end
        end
        
        -- Save the project list to disk
        saveLocalData("project_list", json.encode(project_list))
        
        -- Inform the caller that we've updated the project list
        if cb then cb() end
    end)
end

-- Downloads the specified project, or updates it if required
--
-- cb = function(success)
function downloadProject(projectName, cb)
    
    -- Nil check if the caller doesn't care
    cb = cb or function(s) end
    
    -- Is the project already fully downloaded?
    if project_list[projectName].upToDate then
        cb(true)
        return
    end
    
    -- Let the user know what's going on
    if project_list[projectName].installed then
        print("Updating " .. projectName)
    else
        print("Downloading " .. projectName)
    end
    
    -- Download the project's directory
    local downloadFunc = getProjectBundle
    if project_list[projectName].iszip then
        downloadFunc = getProjectZip
    end
    
    downloadFunc(projectName, function(success)
        if success then
            project_list[projectName].installed = true
            cb(true)
            -- Succeed if the project was already installed
        elseif project_list[projectName].installed then
            cb(true)
        else
            print("There was a problem downloading the project. Please check your internet connection.")
            cb(false)
        end
    end, project_list[projectName].sha)
end

-- Launches the specified project (if downloaded)
function launchProject(projectName)
    if projectIsInstalled(projectName) then
        
        -- Path to the project's bundle
        local project_path = "/../" .. projectName .. ".codea/"
        
        -- Parse project Info.plist
        local plist = readText(asset .. project_path .. "Info.plist")
        if plist == nil then
            print("Unable to open Info.plist in " .. projectName)
            return
        end
        plist = parsePList(plist)
        
        -- Parse project Data.plist
        local data_plist = readText(asset .. project_path .. "Data.plist")
        if data_plist ~= nil then
            data_plist = parsePList(data_plist)
        end
        
        -- Override Codea storage APIs
        saveProjectData = function(key, value) end -- Do nothing
        readProjectData = function(key, default)
            return data_plist[key] or default
        end
        -- TODO: implement the rest
        
        -- Nil out user defined callbacks
        setup = nil
        draw = function() background(0, 0, 0) end
        --- TODO: other callbacks
        
        -- Clear parameters & log
        output.clear()
        -- output.clear()
        parameter.clear()
        
        -- Load lua files in the project specified order
        for _,tab in ipairs(plist["Buffer Order"]) do
            local code = readText(asset .. project_path .. tab .. ".lua")
            if code == nil then
                print("Unable to load " .. tab .. ".lua in " .. projectName)
                return
            end
            
            -- Fixup asset paths so they direct to the correct project
            --
            -- NOTE: Assets used in these projects must use assets from the bundle.
            --       Assets read from elsewhere should not be assumed to exist!
            
            -- Replace 'asset.documents' with random nonsense so we avoid replacing it by accident
            code = string.gsub(code, "asset.documents", "3g287truhdn7kubn43")
            
            -- 'asset .. "/explosion"' -> 'asset .. "/../demo.codea/" .. "/explosion"'
            code = string.gsub(code, "asset *%.%.", "asset .. \"" .. project_path .. "\" .. ")
            -- 'asset.explosion' -> 'asset .. "/../demo.codea/explosion"'
            code = string.gsub(code, "asset%.([^,)]+)", "asset .. \"" .. project_path .. "%1\"")
            
            -- Reinstate 'asset.documents'
            code = string.gsub(code, "3g287truhdn7kubn43", "asset.documents")
            
            -- Load the file
            local fn, err = load(code)
            if fn == nil then
                print(err)
                return
            end
            
            fn()
        end
        
        -- Run the loaded project's setup() function
        setup()
    end
end

-- Returns true if the specified project has an update available
-- in the repo
function projectCanBeUpdated(projectName)
    return not project_list[projectName].upToDate
end

-- Returns true if the specified project is currently downloaded
function projectIsInstalled(projectName)
    return project_list[projectName].installed
end

-- Returns table containing metadata for the specified project
function projectInfo(projectName)
    return project_list[projectName]
end

-- Returns an array of projects (installed or not)
function getProjects()
    return project_list
end
