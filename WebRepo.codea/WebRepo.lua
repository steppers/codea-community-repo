WebRepo = class()

local webrepo = nil

function WebRepo:init(api, delegate)
    self.api = api
    self.delegate = delegate
    self.metadata = {}
    self.icons = {}
    self.connection_failure = false
    
    webrepo = self
    
    -- Check status
    self.api:getFile("status.lua", function(data)
        self.connection_failure = (data == nil)
        if data then
            load(data)()
        else
            print("Failed to connect to the repository. Please check your internet connection")
        end
    end)
    
    -- Load our cached app metadata
    local mdjson = readText(asset.documents .. "webrepocache.json")
    if mdjson then
        self.metadata = json.decode(mdjson)
        
        -- Inform our delegate so all the cached projects can be listed
        for _,v in pairs(self.metadata) do
            
            -- Check the project is still installed
            local editor_name = string.gsub(v.path, ".codea", "")
            if v.installed and not v.bundle and not hasProject(editor_name) then
                v.installed = false
                v.sha = nil
            end
            
            -- Special check for projects in bundle's collection
            -- we consider the bundle deleted if the collection
            -- doesn't exist or there are no projects in it.
            if v.installed and v.bundle then
                for _,folder in pairs(v.bundle_folders) do
                    root_folder, subfolder = string.match(folder, "(.-)/(.*)")
                    
                    if root_folder then
                        -- Project in collection
                        if asset.documents[root_folder] == nil or #asset.documents[root_folder][subfolder .. ".codea"].all == 0 then
                            v.installed = false
                            v.sha = nil
                            break
                        end
                    else
                        -- Asset pack
                        folder = string.gsub(folder, " ", "_")
                        if asset.documents[folder] == nil then
                            v.installed = false
                            v.sha = nil
                            break
                        end
                    end
                end
            end
            
            -- Clear values that should be reset at launch
            v.downloading = false
            v.icon_downloading = false
            v.icon_index = nil
            v.filtered = false
            v.executable = v.executable or (not v.library and not v.bundle)
            
            -- Check if we should autoupdate
            if v.update_available and v.path == "WebRepo.codea" and GITHUB_BRANCH == "main" then
                self:downloadProject(v)
            end
            
            self.delegate.onMetadataAdded(v)
        end
    end
    
    self:updateListings()
end

function WebRepo:updateListings()
    self.api:getContent("/", function(content)
        if not content then
            self.connection_failure = true
            return
        end
        
        local shouldReloadMetadata = readLocalData("shouldRefreshMetadata")
        
        for _,v in pairs(content) do
            
            local is_folder = (v.type == "dir")
            
            -- We only care about folders (.codea bundles are actually folders)
            if is_folder then
                
                -- Check if we already have metadata for this project
                local current_metadata = self.metadata[v.name]
                
                if current_metadata then
                    -- Flag the project as being on the server
                    current_metadata.on_server = true
                    
                    if v.name ~= "WebRepo.codea" then
                        -- Mark the project as requiring a metadata refresh
                        current_metadata.refresh = current_metadata.refresh or shouldReloadMetadata
                    end
                end
                
                -- Only download metadata if we don't have any yet or the
                -- sha hash has changed
                if current_metadata == nil or current_metadata.sha ~= v.sha or current_metadata.refresh then
                    
                    local is_update = (current_metadata == nil or current_metadata.sha ~= v.sha or current_metadata.update_available)
                    
                    -- Download the Info.plist
                    self.api:getFile(v.path .. "/Info.plist", function(data)
                        if not data then
                            -- If we're unable to get the plist file, this probably isn't
                            -- a project or multi-project bundle
                            return
                        end
                        
                        data = parsePList(data)            
                        
                        -- Update the metadata
                        local metadata = self.metadata[v.name] or {}
                        metadata.name = data.Name or "Unnamed"
                        metadata.path = v.path
                        metadata.sha = v.sha
                        metadata.update_available = is_update
                        metadata.desc = data.Description or "No description available"
                        metadata.long_desc = data.LongDescription or metadata.desc
                        metadata.author = data.Author or "Unknown"
                        metadata.version = data.Version or "1.0"
                        metadata.hidden = data.Hidden or false
                        metadata.library = data.Library or false
                        metadata.bundle = data.Bundle or false
                        metadata.bundleexecproject = data.BundleExecutableProject or nil
                        metadata.executable = data.Executable or (not metadata.library and not metadata.bundle)
                        metadata.platform = data.Platform or nil
                        metadata.icon_index = nil
                        metadata.icon_path = data.Icon or nil
                        metadata.icon_downloading = false
                        metadata.link = data.Link
                        metadata.filtered = false
                        metadata.on_server = true
                        metadata.refresh = false
                        metadata.bundle_folders = {}
                        
                        -- Adjust icon name if we haven't explicitly specified in the plist
                        if metadata.icon_path and string.sub(metadata.icon_path, -4, -1) ~= ".png" and string.sub(metadata.icon_path, -4, -1) ~= ".jpg" then
                            if ContentScaleFactor == 2 then
                                metadata.icon_path = metadata.icon_path .. "@2x.png"
                            else
                                metadata.icon_path = metadata.icon_path .. ".png"
                            end
                        end
                        
                        -- Extra name info
                        if metadata.bundle then
                            metadata.name = metadata.name .. " (Bundle)"
                            
                            if metadata.platform == "iphone" then
                                metadata.name = metadata.name .. "(iPhone)"
                            elseif metadata.platform == "ipad" then
                                metadata.name = metadata.name .. "(iPad)"
                            end
                        else                        
                            if metadata.platform == "iphone" then
                                metadata.name = metadata.name .. " (iPhone)"
                            elseif metadata.platform == "ipad" then
                                metadata.name = metadata.name .. " (iPad)"
                            end
                        end
                            
                        -- Inform our delegate that the metadata has been added
                        -- if the metadata already exists we've just updated it above
                        -- so the project browser will update automatically
                        if self.metadata[v.name] == nil then
                            
                            -- The metadata is new so we haven't installed this yet
                            metadata.installed = false
                            
                            -- Store the metadata
                            self.metadata[v.name] = metadata
                            self.delegate.onMetadataAdded(metadata)
                        end
                        
                        -- If this project has an update, do it automatically
                        if v.name == "WebRepo.codea" and GITHUB_BRANCH == "main" then
                            self:downloadProject(metadata)
                        end
                        
                        -- Flush the new metadata to disk
                        self:flushMetadata()
                    end)
                end
            end
        end
        
        -- Remove projects that are no longer on the server
        for k,v in pairs(self.metadata) do
            if not v.on_server then
                self.metadata[v] = nil
                self.delegate.onMetadataRemoved(v)
            else
                v.on_server = nil
            end
        end
        
        -- Flush the new metadata to disk
        self:flushMetadata()
        
        -- We've now marked all the metadata to be refreshed
        saveLocalData("shouldRefreshMetadata", false)
    end)
end

function WebRepo:flushMetadata()
    saveText(asset.documents .. "webrepocache.json", json.encode(self.metadata))
end

local downloads_in_progress = 0
local download_queue = {} -- Stores a separate queue for each project download in progress
--[[
{
    [1] = { sha, asset_path }
    [2] = { sha, asset_path }
    [3] = { sha, asset_path }

    num_files = 3,      -- Number of files currently queued
    total_files = 3,    -- Total number of files in this project
    valid = true,       -- True when we can start downloading
    project_meta = metadata
}
]]--

-- Called to begin processing the download queue 
function WebRepo:doDownloads()
    
    -- Number of downloads that can be running in parallel 
    local PARALLEL_DOWNLOADS = 8
    
    local current_queue = download_queue[1]
    
    if current_queue and current_queue.valid then
        
        -- The number of downloads that should be started
        local downloads_to_start = PARALLEL_DOWNLOADS - downloads_in_progress
        for i = 1, downloads_to_start do
            
            -- Grab the next download in the queue
            local next_download = table.remove(current_queue, 1)
            
            -- If there are no more downloads in this queue, stop
            if not next_download then
                break
            end
            
            -- Start the download
            self:downloadBlob(next_download, current_queue)
            
            -- Increment the number of downloads in progress
            downloads_in_progress = downloads_in_progress + 1
        end 
    end
end

function WebRepo:downloadBlob(entry, queue)
    
    -- Get the blob
    self.api:getBlob(entry.sha, function(data)
        
        -- Check if the download has been aborted
        if not queue.project_meta.downloading then
            return -- Don't write the data
        end
        
        if data then

            -- Write directly to the file
            local file = io.open(entry.asset_path.path, "w")
            file:write(data)
            file:close()
            
            -- Log that we've completed a file download
            queue.num_files = queue.num_files - 1
            
            -- Calculate a rough progress value        
            queue.project_meta.download_progress = (queue.total_files - queue.num_files) / queue.total_files
            
            -- Check if we've completed the full project download
            if queue.num_files == 0 then
                
                queue.project_meta.downloading = false
                queue.project_meta.installed = true
                queue.project_meta.update_available = false
                queue.project_meta.download_progress = nil
                self:flushMetadata()
                
                -- Inform the delegate
                self.delegate.onProjectDownloaded(queue.project_meta)
                
                -- Remove the queue
                table.remove(download_queue, 1)
            end
            
            -- Trigger the next download now so we don't have to wait
            -- for another frame
            downloads_in_progress = downloads_in_progress - 1
            self:doDownloads()
        else
            
            -- If we fail then abort the current download
            self:abortProjectDownload()
        end
    end)
end

function WebRepo:newProjectDownload(project_meta)
    local queue = {
        num_files = 0,
        total_files = 0,
        valid = false,
        project_meta = project_meta
    }
    table.insert(download_queue, queue)
end

function WebRepo:queueFileDownload(sha, asset_path)
    local queue = download_queue[#download_queue]
    queue.num_files = queue.num_files + 1
    table.insert(queue, { sha = sha, asset_path = asset_path })
end

function WebRepo:startProjectDownload()
    local queue = download_queue[#download_queue]
    queue.total_files = queue.num_files
    queue.valid = true
    
    -- Trigger the download processing
    self:doDownloads()
end

function WebRepo:abortProjectDownload(webrepo)
    print("Aborting download of " .. queue.project_meta.path)
    local queue = download_queue[1]
    queue.project_meta.downloading = false
    queue.project_meta.installed = false
    queue.project_meta.update_available = true
    queue.project_meta.download_progress = nil
    self:flushMetadata()
    
    downloads_in_progress = 0
    table.remove(download_queue, 1)
end

function WebRepo:downloadProject(project_meta)
    
    if not project_meta.update_available then
        return
    end
    
    if project_meta.bundle then
        project_meta.bundle_folders = {}
    end
    
    self:newProjectDownload(project_meta)
    
    local editor_name = string.gsub(project_meta.path, ".codea", "")
    
    -- We should only actually start the download when we have no more
    -- folder content requests waiting for a response
    local contentRequestsWaiting = 0
    local function startDownload()
        contentRequestsWaiting = contentRequestsWaiting - 1
        if contentRequestsWaiting == 0 then
            project_meta.downloading = true
            self:startProjectDownload()
        end
    end
    
    local function downloadProject(entry)
        
        local editor_name = string.gsub(entry.path, ".codea", "")
        table.insert(project_meta.bundle_folders, editor_name)
        
        -- Get the list of project content
        contentRequestsWaiting = contentRequestsWaiting + 1
        self.api:getContent(entry.path, function(content)
            if content == nil then
                print("Failed to get project content. Please check your internet connection.")
                self.connection_failure = true
                self:abortProjectDownload(self)
                return    
            end
            
            -- Create the project if it doesn't exist already
            local editor_name = project_meta.path .. ":" .. string.gsub(entry.name, ".codea", "")
            pcall(deleteProject, editor_name)
            createProject(editor_name)
            
            for _,e in pairs(content) do
                if e.type == "file" then
                    self:queueFileDownload(e.sha, asset.documents .. project_meta.path .. "/" .. entry.name .. "/" .. e.name)
                end
            end
            
            -- Trigger the download if we're not waiting on any content requests
            startDownload()
        end)
    end
    
    local function downloadAssetBundle(entry)
        
        local editor_name = string.gsub(entry.name, ".assets", "")
        table.insert(project_meta.bundle_folders, editor_name)
        
        -- Get the content of the asset bundle
        contentRequestsWaiting = contentRequestsWaiting + 1
        self.api:getContent(entry.path, function(content)
            if content == nil then
                print("Failed to get asset bundle content. Please check your internet connection.")
                self.connection_failure = true
                self:abortProjectDownload(self)
                return    
            end
            
            -- Doesn't appear to actually create the project but
            -- it does create the correct .assets folder!
            createProject(entry.name .. ":empty")
            
            for _,e in pairs(content) do
                if e.type == "file" then
                    self:queueFileDownload(e.sha, asset.documents .. entry.name .. "/" .. e.name)
                end
            end
            
            -- Trigger the download if we're not waiting on any content requests
            startDownload()
        end)
    end    
    project_meta.downloading = true
    
    -- Get the contents of the project
    contentRequestsWaiting = contentRequestsWaiting + 1
    self.api:getContent(project_meta.path, function(content)
        if content == nil then
            print("Failed to get project content. Please check your internet connection.")
            self.connection_failure = true
            project_meta.downloading = false
            return    
        end
        
        -- Create the project if the first request succeeds and this isn't
        -- a multi-project bundle
        if not hasProject(editor_name) and not project_meta.bundle then
            createProject(editor_name)
        end
        
        if project_meta.bundle then
            for _,e in pairs(content) do
                if e.type == "dir" then
                    if string.match(e.name, ".asset") then
                        downloadAssetBundle(e)
                    elseif string.match(e.name, ".codea") then
                        downloadProject(e) 
                    end
                end
            end 
        else
            for _,e in pairs(content) do
                if e.type == "file" then
                    self:queueFileDownload(e.sha, asset.documents .. e.path)
                end
            end
        end
        
        -- Trigger the download if we're not waiting on any content requests
        startDownload()
    end)
end

function WebRepo:deleteProject(project_meta)
    
    -- Update metadata
    project_meta.installed = false
    project_meta.update_available = true
    
    -- delete it
    local editor_name = string.gsub(project_meta.path, ".codea", "")
    deleteProject(editor_name)
    
    -- Flush the metadata
    self:flushMetadata()
end

function WebRepo:launchProject(project_meta)
    
    if project_meta.installed and project_meta.executable then
        
        -- The editor name for the project being launched
        local editor_name = string.gsub(project_meta.path, ".codea", "")
        
        -- Path to the project's bundle
        local project_path = project_meta.path .. "/"
        
        -- If it's a multi-project bundle then we need to launch the specified project
        if project_meta.bundle then
            project_path = project_path .. project_meta.bundleexecproject .. ".codea/"
            editor_name = project_meta.path .. ":" .. project_meta.bundleexecproject
        end
        
        -- Parse project Info.plist
        local plist = readText(asset.documents .. project_path .. "Info.plist")
        if plist == nil then
            if project_meta.bundle then
                error("Unable to open Info.plist in " .. project_meta.path .. ":" .. project_meta.bundleexecproject)
            else
                error("Unable to open Info.plist in " .. project_meta.name)
            end
            return
        end
        plist = parsePList(plist)
        
        -- Clear parameters & log
        output.clear()
        parameter.clear()
        
        -- Any project we run should know it's launched using WebRepo
        _WEB_REPO_LAUNCH_ = true
            
        -- Override Codea API
        overrideAPI(project_path)
        
        -- All loaded projects so we don't recurse infinitely for some circular dependencies.
        local loaded_projects = { editor_name }
        
        -- Recursively loads a project and it's dependencies
        local function loadDependency(project, parent)
            
            -- Only load a dependency once
            for _,p in pairs(loaded_projects) do
                if p == project then return end
            end
            
            -- Consider this project loaded
            table.insert(loaded_projects, project)
            
            -- Get the tabs of the dependency
            local tabs = listProjectTabs(project)
            if tabs == nil or #tabs == 0 then
                pcall(error, "Unable to load dependency " .. project .. " for " .. parent)
                return
            end
            
            -- Load the dependency's plist
            local project_path = string.gsub(project, ":", "/") .. ".codea/"
            local plist = readText(asset.documents .. project_path .. "Info.plist")
            if plist == nil then
                error("Unable to open Info.plist in " .. project_path)
                return
            end
            plist = parsePList(plist)
            
            -- Load each sub dependency recursively
            if plist["Dependencies"] then
                for _,dep in ipairs(plist["Dependencies"]) do
                    loadDependency(dep, project)
                end
            end
                
            -- Load each tab from the dependency project
            for _,tab in pairs(tabs) do
                if tab ~= "Main" then -- Ignore 'Main' tabs 
                    local code = readProjectTab(project .. ":" .. tab)
                    
                    -- Load the file
                    local fn, err = load(code)
                    if fn == nil then
                        error("Error in dependency (" .. project .. "): " .. err)
                        return
                    end
                    
                    fn()
                end
            end
        end
        
        -- Load dependencies in the project specified order
        if plist["Dependencies"] then
            for _,dep in ipairs(plist["Dependencies"]) do
                loadDependency(dep, editor_name)
            end
        end
            
        -- Load lua files in the project specified order
        for _,tab in ipairs(plist["Buffer Order"]) do
            local code = readText(asset.documents .. project_path .. tab .. ".lua")
            if code == nil then
                error("Unable to load " .. tab .. ".lua in " .. project_meta.name)
                return
            end
            
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

function WebRepo:initProjectIcon(project_meta)
    -- Early out
    if project_meta.icon_index or project_meta.icon_path == nil or project_meta.icon_downloading then
        return
    end
    
    -- If it's installed grab the icon from the installed project
    -- unless it's a bundle, in which case we don't download it at install
    if project_meta.installed and not project_meta.bundle then
        table.insert(self.icons, {
            icon = readImage(asset .. "/../" .. project_meta.path .. "/" ..project_meta.icon_path),
            meta = project_meta
        })
        project_meta.icon_index = #self.icons
        return 
    end
    
    -- Check for known connection issues
    if self.connection_failure then return end
    
    -- Set flag
    project_meta.icon_downloading = true
    
    -- Get the icon file
    self.api:getFile(project_meta.path .. "/" .. project_meta.icon_path, function(data)
        if not data then
            print("Failed to get Icon for " .. project_meta.path)
            self.connection_failure = true
            project_meta.icon_downloading = false
            return
        end
        
        table.insert(self.icons, {
            icon = data,
            meta = project_meta
        })
        project_meta.icon_index = #self.icons
        project_meta.icon_downloading = false
    end)
end

function WebRepo:freeProjectIcon(project_meta)
    -- Check we have an icon to free
    if project_meta.icon_index == nil then
        return
    end
    
    -- Remove the last icon
    local last = table.remove(self.icons)
    
    -- Update the element we just removed
    last.meta.icon_index = project_meta.icon_index
    
    -- Are we done?
    if last.meta ~= project_meta then
        
        -- Move the last element into the removal index
        self.icons[project_meta.icon_index] = last
    end
    
    -- Nil the index
    project_meta.icon_index = nil
end

function WebRepo:getProjectIcon(project_meta)
    if project_meta.icon_index then
        return self.icons[project_meta.icon_index].icon
    else
        return asset.builtin.Blocks.Missing
    end
end
    
-- e.g getProjectMetadata("WebRepo.codea")
function WebRepo:getProjectMetadata(project_path)
    return self.metadata[project_path]
end

function WebRepoDelegate(t)
    local t = t or {}
    
    -- Setup default callbacks
    t.onMetadataUpdated =       t.onMetadataUpdated or function() end
    t.onProjectDownloaded =     t.onProjectDownloaded or function() end
    t.onProjectUpdated =        t.onProjectUpdated or function() end
    
    return t
end