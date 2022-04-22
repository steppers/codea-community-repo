_BACKEND_IP_ = "132.145.59.91"
_BACKEND_PORT_ = "443"

DB = {}

local INCLUDE_SUB_MANIFEST = true

local function PrepareURL(url)
    -- Escape special characters
    url = string.gsub(url, "%%", "%%25")
    url = string.gsub(url, " ", "%%20")
    url = string.gsub(url, "!", "%%21")
    url = string.gsub(url, "#", "%%23")
    url = string.gsub(url, "%$", "%%24")
    url = string.gsub(url, "@", "%%40")
    return url
end

-- We track the local WebRepo state using a VFS folder.
--
-- Project metadata and downloads are cached until we
-- clear the cache.
--
-- If a project download already exists in the cache
-- then we restore it from the cache rather than download
-- the entire project again. With versioning this should
-- be stable as a new submission must use a new version.

function DB.setup()
    -- Init VFS
    DB.fs = VFS("webrepocache")
    DB.apps = {}
end

-- Downloads a file and uses the cache if it fails
function DB.retrieveFile(path, callback, force, read, progress_cb)
    
    -- Pass the file content to the callback by default
    if read == nil then
        read = true
    end
    
    -- If we're not forcing it then use the cached file
    if not force then
        local data = DB.fs:readFile(path)
        if data then
            callback(read and data)
            return
        end
        -- print("Cache Miss: ", path)
    end
    
    -- Get the headers only first
    http.request("https://" .. _BACKEND_IP_ .. ":" .. _BACKEND_PORT_ .. "/" .. PrepareURL(path), function(res, code, headers)
        
        -- Don't download images in chunks
        if headers["Content-Type"] == "image/png" then
            http.request("https://" .. _BACKEND_IP_ .. ":" .. _BACKEND_PORT_ .. "/" .. PrepareURL(path), function(res)
                DB.fs:writeFile(path, res)
                callback((read and DB.fs:readFile(path)) or true)
            end)
            return
        end
        
        -- Download files in chunks to avoid memory issues
        local size = math.tointeger(headers['Content-Length'])
        local totalSize = size
        local pos = 0
        local file = DB.fs:open(path .. ".download", "wb")
        local CHUNK_SIZE = 1 * 1024 * 1024 -- 1MB at a time
        
        local function nextChunk()
            local chunkSize = math.min(size, CHUNK_SIZE)
            size = size - chunkSize
            http.request("https://" .. _BACKEND_IP_ .. ":" .. _BACKEND_PORT_ .. "/" .. PrepareURL(path), function(res)
                file:write(res)
                pos = pos + chunkSize
                if progress_cb then progress_cb(pos/totalSize) end
                if size > 0 then
                    nextChunk()
                else
                    file:close()
                    DB.fs:mv(path .. ".download", path)
                    callback((read and DB.fs:readFile(path)) or true)
                end
            end, function(err)
                DB.fs:rm(path .. ".download")
                file:close()
                objc.warning(path .. " => " .. err)
            end, { headers = { Range = string.format("bytes=%d-%d", pos, pos + chunkSize - 1)}})
        end
        
        nextChunk()
        
    end, function(err)
        objc.warning(path .. " => " .. err)
    end, { method = "HEAD" })
end

-- Download queue thread
local dlQueue = {}
local dlMap = {}
ST.Thread(function()
    local dlCount = 0
    
    while true do
        
        -- Get next download
        while dlCount < 8 and #dlQueue > 0 do
            
            -- Get the queued path
            local path = table.remove(dlQueue)
            
            -- Copy the current map
            local map = dlMap[path]
            dlMap[path] = nil
            
            -- Determine if we need to force a download?
            local force = false
            local read = false
            for _, dl in ipairs(map) do
                force = force or dl.force
                read = read or dl.read
            end
            
            -- Do the file download
            ST.runMain(function()
                --print("Downloading ", path)
                dlCount = dlCount + 1
                DB.retrieveFile(path, function(data)
                    dlCount = dlCount - 1
                    
                    -- Call all interested callbacks
                    for _, dl in ipairs(map) do
                        if dl.callback then dl.callback(dl.read and data) end
                    end
                end, force, read, function(v)
                    -- Call all interested callbacks
                    for _, dl in ipairs(map) do
                        if dl.progress_cb then dl.progress_cb(v) end
                    end
                end)
            end)
        end
            
        ST.yield()
    end
end)

function DB.retrieveFileQueued(path, callback, force, read, progress_cb)
    
    -- Pass the file content to the callback by default
    if read == nil then
        read = true
    end
    
    -- If we're not forcing it then use the cached file
    if not force then
        local data = DB.fs:readFile(path)
        if data then
            callback(read and data)
            return
        end
    end
    
    if dlMap[path] == nil then
        dlMap[path] = {}
        -- Add to the download queue
        table.insert(dlQueue, path)
    end
    
    -- Add it to the entries array
    table.insert(dlMap[path], {
        callback = callback,
        force = force,
        read = read,
        progress_cb = progress_cb
    })
    
    if progress_cb then
        progress_cb(0)
    end
end

function DB.loadStore(callback)
    
    DB.retrieveFile("manifest.json", function(data)
        if data then
            data = json.decode(data)
            
            local store = {}
            
            -- Only trigger the callback when all of the metadata downloads are complete
            ac = AsyncCoordinator(function()
                callback(store)
            end)
            
            -- Retrieve app info for all listed apps
            for name, versions in pairs(data) do
                store[name] = {}
                
                for i,version in ipairs(versions) do
                    ac:inc() -- inc coordinator
                    
                    -- Get the app info
                    DB.retrieveFile(string.format("%s/%s/metadata.json", name, version), function(data)
                        if data then
                            local app = {
                                name = name,
                                version = version,
                                info = json.decode(data)
                            }
                            
                            -- Setup authors string
                            app.authors_str = ""
                            for i,author in ipairs(app.info.authors) do
                                if i == 1 then
                                    app.authors_str = author
                                elseif i == 2 then
                                    app.authors_str = app.authors_str .. " ft. " .. author
                                else
                                    app.authors_str = app.authors_str .. ", " .. author
                                end
                            end
                            
                            -- Add to DB apps
                            DB.apps[name] = DB.apps[name] or {}
                            DB.apps[name][version] = app
                            DB.apps[name][i] = app -- Indexed versions
                            
                            -- Add the app to the store
                            store[name][i] = app
                        else
                            store[name][i] = false -- Not available
                        end

                        ac:dec() -- dec coordinator
                    end)
                end
            end
            
            ac:done() -- We've done the initialisation
        else
            callback(nil)
        end
    end, true) -- force update
end

-- Get an App object from a name & version
-- If the app version is not available, returns nil
function DB.getApp(name, version)
    if DB.apps[name] then
        return DB.apps[name][version]
    end
end

-- Gets the latest version of an app or nil if the 
-- app does not exist
function DB.getLatestApp(name)
    -- Replace spaces with underscores
    name = name:gsub(" ", "_")
    
    -- Find the app
    if DB.apps[name] then
        local versions = DB.apps[name]
        return (versions and DB.apps[name][#versions]) or nil
    end
end

function DB.downloadApp(app, callback, progress_cb)
    DB.retrieveFile(string.format("%s/%s/project.zip", app.name, app.version), function(data)
        if not data then
            callback(false, "Failed to get project zip")
            return
        end
        
        callback(true, "All is well")
    end, true, -- force
    false, progress_cb)
end

-- Scans the VFS for the contents of a specific app version
function DB.isAppDownloaded(name, version)
    local zip = DB.fs:readFile(string.format("%s/%s/project.zip", name, version))
    return zip ~= nil
end

-- Scans the VFS for the contents of a specific app version
function DB.isAppInstalled(name, version)
    if name  == "WebRepo" then
        name = (asset.name):match("(.*)%.codea")
    end
    
    local project_name = DB.getApp(name, version).info.name
    
    -- Get the version value
    local file = io.open((asset.documents .. project_name .. ".codea/.webrepo_version").path, "r")
    if file == nil then
        return false
    end
    
    local ver = file:read("*a")
    file:close()
    
    -- Does the version match?
    return ver == version
end

-- IMPORTANT: Always call on an ST.Thread
function DB.installApp(name, version)
    print(string.format("Installing %s-%s", name, version))
    
    -- Allow the 'INSTALLING' message to display & resize
    ST.yield()
    ST.yield()
    ST.yield()
    
    local project_name = DB.getApp(name, version).info.name
    
    if project_name == "WebRepo" then
        project_name = (asset.name):match("(.*)%.codea")
    end
    
    -- Create project (if it doesn't already exist)
    if not hasProject(project_name) then
        createProject(project_name)
    else
        -- TODO: Erase previous project content
    end
    
    -- Open the zip and read files to install
    zip = Zip(DB.fs.vfs_root .. DB.fs:getFile(string.format("%s/%s/project.zip", name, version)).file)
    local files = zip:listFiles()
    for _,path in ipairs(files) do
        local file_data = zip:readFile(path)
        if path:find("/.-/") then -- 2 slashes (subfolder)
            local sf = asset.documents.path .. "/" .. path:gsub("/[^/]-$", "")
                
            local fm = objc.cls.NSFileManager.defaultManager
            if not fm:fileExistsAtPath_isDirectory_(sf, true) then
                fm:createDirectoryAtPath_withIntermediateDirectories_attributes_error_(sf, true, nil, nil)
            end
        end
        local file = io.open((asset.documents .. path).path, "wb")
        file:write(file_data)
        file:close()
    end
    
    -- Save the version value
    local file = io.open((asset.documents .. project_name .. ".codea/.webrepo_version").path, "w")
    file:write(version)
    file:close()
    
    -- Unsplit split files
    unsplitProject(asset.documents[project_name .. ".codea"])
    
    print(string.format("Installed %s-%s", project_name, version))
end

local k_default_icons = {
    ["Game"] = asset.IconDefaultGame,
    ["App"] = asset.IconDefaultApp,
    ["Library"] = asset.IconDefaultLib
}

function DB.getAppIcon(app, callback)
    callback(k_default_icons[app.info.category])
    DB.retrieveFileQueued(string.format("%s/Icon.png", app.name), function(data)
        if data then
            data = image(data)
            callback(data) 
        else
            DB.retrieveFileQueued(string.format("%s/Icon@2x.png", app.name), function(data)
                if data then
                    data = image(data)
                end
                callback(data)
            end)
        end
    end)
end

function DB.getAppBanner(app, callback)
    callback(k_default_icons[app.info.category])
    DB.retrieveFileQueued(string.format("%s/Icon.png", app.name), function(data)
        if data == nil then
            DB.getAppIcon(app, callback)
        else
            if data then
                data = image(data)
            end
            callback(data)
        end
    end)
end

function DB.deleteApp(name, version)
    
end

function DB.clearCache(keep_latest)
    
end

function DB.getReviewQueue(callback)
    DB.retrieveFile("review_queue.json", function(data)
        callback((data and json.decode(data)) or nil)
    end, true) -- force
end

-- Converts from bayfiles user url to download url
local function GetDirectURL(indirect_url, callback)
    http.request(indirect_url, function(data)
        if not data then
            callback(false)
        else
            -- We should keep an eye on this in case the bayfiles CDN urls change
            local url = data:match("https://cdn-.-bayfiles%.com/[^\"]*")
            if not url then
                error("Unable to detect direct URL!")
            end
            url = PrepareURL(url)
            callback(url)
        end
    end, function(err)
        callback(false)
    end)
end

function DB.getReviewCandidateMetadata(queue_entry, callback)    
    local ac = Async()
    
    local ended = false
    local function fail(cond)
        if not cond and not ended then
            ended = true
        end
        return not cond
    end

    local function DownloadFile(url, callback)
        http.request(url, function(data)
            if not data then
                callback(nil)
            else
                callback(data)
            end
        end, function(err)
            print(url, err)
            callback(nil)
        end)
    end

    -- Get the direct URL
    ac:job(function(cb)
        GetDirectURL(queue_entry.metadata_url, cb)
    end)

    -- Once we have the direct URL we can download
    -- the metadata file
    ac:then_do(function(cb, metadata_url)
        if fail(metadata_url) then return end
        DownloadFile(metadata_url, cb)
    
    end):then_do(function(cb, metadata)
        if fail(metadata ~= nil) then return end
    
        -- Pass the metadata to the callback so the reviewer can check it.
        callback(metadata)
    end)
    
    -- Run the Async tasks
    ac:go()
end

function DB.installReviewCandidate(queue_entry, oil_status, callback)    
    local ac = Async()
    
    oil_status:add_style("text", "Downloading...")
    
    local ended = false
    local function fail(cond)
        if not cond and not ended then
            oil_status:add_style("text", "*** Failed ***")
            tween(3, {}, {}, tween.easing.linear, function()
                oil_status:add_style("text", "Install")
            end)
            ended = true
        end
        
        return not cond
    end

    local function DownloadFile(url, asset_file, callback)
    
        -- Get the headers only first
        http.request(url, function(res, code, headers)
            
            -- Download files in chunks to avoid memory issues
            local size = math.tointeger(headers['Content-Length'])
            local totalSize = size
            local pos = 0
            local file = io.open(asset_file.path, "wb")
            local CHUNK_SIZE = 1 * 1024 * 1024 -- 1MB at a time
            
            local function nextChunk()
                local chunkSize = math.min(size, CHUNK_SIZE)
                size = size - chunkSize
                http.request(url, function(res)
                    file:write(res)
                    if size > 0 then
                        pos = pos + chunkSize
                        print(string.format("url: %d%%", math.ceil((pos*100)/totalSize)))
                        nextChunk()
                    else
                        print("url: 100%")
                        file:close()
                        callback(true)
                    end
                end, function(err)
                    file:close()
                    objc.warning(url .. " => " .. err)
                    callback(false)
                end, { headers = { Range = string.format("bytes=%d-%d", pos, pos + chunkSize - 1)}})
            end
            
            nextChunk()
            
        end, function(err)
            objc.warning(url .. " => " .. err)
            callback(false)
        end, { method = "HEAD" })
    end

    -- Get the direct URLs in parallel
    ac:job(function(cb)
        GetDirectURL(queue_entry.zip_url, cb)
    end):job(function(cb)
        GetDirectURL(queue_entry.metadata_url, cb)
    end)

    -- Once we have the direct URLs we can download the
    -- files and install the project
    ac:then_do(function(cb, zip_url, metadata_url)
        if fail(zip_url) then return end
        DownloadFile(zip_url, asset.documents.webrepocache_vfs .. "review.zip", cb)
    
    end):job(function(cb, zip_url, metadata_url)
        if fail(metadata_url) then return end
        DownloadFile(metadata_url, asset.documents.webrepocache_vfs .. "review_meta.json", cb)
    
    end):then_do(function(cb, has_zip, has_meta)
        if fail(has_zip and has_meta) then return end
    
        oil_status:add_style("text", "Installing...")
        tween(0.1, {}, {}, tween.easing.linear, function()
            -- Pass the metadata to the callback so the reviewer can check it.
            if callback then callback(readText(asset.documents.webrepocache_vfs .. "review_meta.json")) end
        
            -- Create project (deleting old version)
            if not hasProject(queue_entry.name) then
                createProject(queue_entry.name)
            end
        
            -- Open the zip and read files to install
            zip = Zip(asset.documents.webrepocache_vfs .. "review.zip")
            local files = zip:listFiles()
            for _,path in ipairs(files) do
                local file_data = zip:readFile(path)
                if path:find("/.-/") then -- 2 slashes (subfolder)
                    local sf = asset.documents.path .. "/" .. path:gsub("/[^/]-$", "")
                
                    local fm = objc.cls.NSFileManager.defaultManager
                    if not fm:fileExistsAtPath_isDirectory_(sf, true) then
                        fm:createDirectoryAtPath_withIntermediateDirectories_attributes_error_(sf, true, nil, nil)
                    end
                end
                local file = io.open((asset.documents .. path).path, "wb")
                file:write(file_data)
                file:close()
        end
        
        -- Unsplit split files
        unsplitProject(asset.documents[queue_entry.name .. ".codea"])
        
        oil_status:add_style("text", "Done")
            tween(3, {}, {}, tween.easing.linear, function()
                oil_status:add_style("text", "INSTALL")
            end)
        end)
    end)
    
    -- Run the Async tasks
    ac:go()
end

function DB.approveReviewCandidate(queue_entry, review_key, callback)
    local ac = Async()

    if not review_key or review_key == "" then
        callback("Review key required!")
        return
    end

    local payload = {
        name = queue_entry.name,
        version = queue_entry.version,
        key = review_key
    }

    ac:job(function(cb)
        Oil.Alert(
            string.format("Are you sure you want to approve this app?\n\n'%s-%s'", queue_entry.name, queue_entry.version),
            function(result)
                if result then
                    cb()
                end
            end,
            UI.THEME.alert, UI.THEME.button_fixed)
    end)
    :then_do(function(cb)
    
        payload.zip_url = queue_entry.zip_url
        payload.metadata_url = queue_entry.metadata_url
    
        http.request("https://" .. _BACKEND_IP_ .. ":" .. _BACKEND_PORT_ .. "/approve", function(response, code)
            if code == 200 then
                callback("Approval sent")
            else
                callback("Approval failed")
            end
        end, function(err)
            print(err)
            callback("Approval failed")
        end, {
            method = "POST",
            headers = {
                ["Content-Type"] = "application/json"
            },
            data = json.encode(payload, json_state)
        })
    end)

    ac:go() -- Kick of the async stuff
end

function DB.rejectReviewCandidate(queue_entry, review_key, callback)
    if not review_key or review_key == "" then
        callback("Review key required!")
        return
    end

    local payload = {
        name = queue_entry.name,
        version = queue_entry.version,
        key = review_key
    }

    Oil.Alert(
        string.format("Are you sure you want to reject this app?\n\n'%s-%s'", queue_entry.name, queue_entry.version),
        function(result)
            if result then
                http.request("https://" .. _BACKEND_IP_ .. ":" .. _BACKEND_PORT_ .. "/reject", function(response, code)
                    if code == 200 then
                        callback("Rejection Sent")
                    else
                        callback("Rejection Failed")
                    end
                end, function(err)
                    print(err)
                    callback("Rejection Failed")
                end, {
                    method = "POST",
                    headers = {
                        ["Content-Type"] = "application/json"
                    },
                    data = json.encode(payload, json_state)
                })
            end
        end,
        UI.THEME.alert, UI.THEME.button_fixed)
end
