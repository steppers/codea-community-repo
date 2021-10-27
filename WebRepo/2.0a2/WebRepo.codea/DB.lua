DB = {}

local INCLUDE_SUB_MANIFEST = true

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
function DB.retrieveFile(path, callback, force)
    
    function PrepareURL(url)
        -- Escape special characters
        url = string.gsub(url, "%%", "%%25")
        url = string.gsub(url, " ", "%%20")
        url = string.gsub(url, "!", "%%21")
        url = string.gsub(url, "#", "%%23")
        url = string.gsub(url, "%$", "%%24")
        url = string.gsub(url, "@", "%%40")
        return url
    end
    
    -- If we're not forcing it then use the cached file
    if not force then
        local data = DB.fs:readFile(path)
        if data then
            callback(data)
            return
        end
        -- print("Cache Miss: ", path)
    end
        
    local function success(data, status)
        if status == 200 then
            -- Update cache
            DB.fs:writeFile(path, data)
            callback(DB.fs:readFile(path))
        else
            -- Check cache
            callback(DB.fs:readFile(path))
        end
    end
        
    local function fail(err)
        -- TODO: Check for offline message
        -- Check cache
        callback(DB.fs:readFile(path))
    end
    
    http.request("https://raw.githubusercontent.com/steppers/codea-community-repo/main/" .. PrepareURL(path), success, fail)
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

function DB.downloadApp(app, callback)
    DB.retrieveFile(string.format("%s/%s/manifest.txt", app.name, app.version), function(data)
        if not data then
            callback(false, "Failed to get manifest")
        end
        
        local success = true
        local err = "All is well"
        ac = AsyncCoordinator(function()
            DB.fs:flush()
            callback(success, err)
        end)
        
        local base_path = string.format("%s/%s/", app.name, app.version)
        for path in data:gmatch("(.-)\n") do
            ac:inc()
            DB.retrieveFile(base_path .. path, function(data)
                if not data and success then
                    success = false
                    err = "Failed to get app file: " .. path
                end
                ac:dec()
            end)
        end
        
        ac:done()
    end, true) -- force
end

-- Scans the VFS for the contents of a specific app version
function DB.isAppDownloaded(name, version)
    local manifest = DB.fs:readFile(string.format("%s/%s/manifest.txt", name, version))
    if manifest then
        local base_path = string.format("%s/%s/", name, version)
        for path in manifest:gmatch("(.-)\n") do
            if not DB.fs:fileExists(base_path .. path) then
                return false
            end
        end
    else
        return false
    end
    
    return true
end

-- Scans the VFS for the contents of a specific app version
function DB.isAppInstalled(name, version)
    -- Get the version value
    local file = io.open((asset.documents .. name .. ".codea/.webrepo_version").path, "r")
    if file == nil then
        return false
    end
    
    local ver = file:read("*a")
    file:close()
    
    print(ver, version)
    
    -- Does the version match?
    return ver == version
end

function DB.installApp(name, version)
    print(string.format("Installing %s-%s", name, version))
    
    -- Create project (if it doesn't already exist)
    if not hasProject(name) then
        createProject(name)
    else
        -- TODO: Erase previous project content
    end
    
    local manifest = DB.fs:readFile(string.format("%s/%s/manifest.txt", name, version))
    if manifest then
        local base_path = string.format("%s/%s/", name, version)
        for path in manifest:gmatch("(.-)\n") do
            local data = DB.fs:readFile(base_path .. path)
            if not data then
                error("Missing file! " .. base_path .. path)
            end
              
            -- Copy file from vfs to project
            local file = io.open((asset.documents .. path).path, "wb")
            file:write(data)
            file:close()
        end
    else
         error("Manifest not present: " .. name .. "-" .. version)
    end
    
    -- Save the version value
    local file = io.open((asset.documents .. name .. ".codea/.webrepo_version").path, "w")
    file:write(version)
    file:close()
    
    print(string.format("Installed %s-%s", name, version))
end

function DB.getAppIcon(app, callback)
    DB.retrieveFile(string.format("%s/%s/%s", app.name, app.version, app.info.icon), function(data)
        if data then
            data = image(data)
        end
        callback(data)
    end)
end

function DB.getAppBanner(app, callback)
    DB.retrieveFile(string.format("%s/%s/%s", app.name, app.version, app.info.icon or "banner.png"), function(data)
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
            callback(data:match("https://cdn-.-bayfiles%.com/[^\"]*"))
        end
    end, function(err)
        callback(false)
    end)
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
        http.request(url, function(data)
            if not data then
                callback(false)
            else
                local file = io.open(asset_file.path, "wb")
                file:write(data)
                file:close()
                callback(true)
            end
        end, function(err)
            callback(false)
        end)
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
            -- TODO: Incorporate the metadata file here somewhere so we can review that in app
            -- too.
        
            -- Create project (deleting old version)
            if not hasProject(queue_entry.name) then
                createProject(queue_entry.name)
            end
        
            -- Open the zip and read files to install
            zip = Zip(asset.documents.webrepocache_vfs .. "review.zip")
            local files = zip:listFiles()
            for _,path in ipairs(files) do
                local file_data = zip:readFile(path)
                local file = io.open((asset.documents .. path).path, "wb")
                file:write(file_data)
                file:close()
            end
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
        key = review_key,
        ["type"] = "approve"
    }

    ac:job(function(cb)
        Oil.Alert(
            string.format("Are you sure you want to approve this app?\n\n'%s-%s'", queue_entry.name, queue_entry.version),
            function(result)
                if result then
                    cb()
                end
            end,
            UI.THEME.alert, UI.THEME.button)
    end)
    -- Get the direct URLs before sending the approval request
    :then_do(function(cb)
        GetDirectURL(queue_entry.zip_url, cb)
    end):job(function(cb)
        GetDirectURL(queue_entry.metadata_url, cb)
    end):then_do(function(cb, zip_url, metadata_url)
    
        if not zip_url or not metadata_url then
            callback("Failed to get URLs")
            return
        end
    
        payload.zip_url = zip_url
        payload.metadata_url = metadata_url
    
        http.request("https://bxdt1ckife.execute-api.eu-west-2.amazonaws.com/submit", function(response, code)
            if code == 200 then
                callback("Approve sent")
            else
                callback("Approve failed")
            end
        end, function(err)
            print(err)
            callback("Approve failed")
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
        key = review_key,
        ["type"] = "reject"
    }

    Oil.Alert(
        string.format("Are you sure you want to reject this app?\n\n'%s-%s'", queue_entry.name, queue_entry.version),
        function(result)
            if result then
                http.request("https://bxdt1ckife.execute-api.eu-west-2.amazonaws.com/submit", function(response, code)
                    if code == 200 then
                        callback("Reject Sent")
                    else
                        callback("Reject Failed")
                    end
                end, function(err)
                    print(err)
                    callback("Reject Failed")
                end, {
                    method = "POST",
                    headers = {
                        ["Content-Type"] = "application/json"
                    },
                    data = json.encode(payload, json_state)
                })
            end
        end,
        UI.THEME.alert, UI.THEME.button)
end
