WebRepo = class()

function WebRepo:init(api, delegate)
    self.api = api
    self.delegate = delegate
    self.metadata = {}
    self.icons = {}
    self.connection_failure = false
    
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
            if v.installed and not hasProject(editor_name) then
                v.installed = false
                v.sha = nil
            end
            
            -- Clear values that should be reset at launch
            v.downloading = false
            v.icon_downloading = false
            v.icon_index = nil
            v.filtered = false
            v.executable = v.executable or not v.library
            
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
            
            -- We only care about .codea project bundles
            if string.find(v.name, ".codea") and v.type == "dir" then
                
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
                            self.connection_failure = true
                            print("Failed to get Info.plist for " .. v.path)
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
                        metadata.author = data.Author or "Unknown"
                        metadata.version = data.Version or "1.0"
                        metadata.hidden = data.Hidden or false
                        metadata.library = data.Library or false
                        metadata.executable = data.Executable or not metadata.library
                        metadata.platform = data.Platform or nil
                        metadata.icon_index = nil
                        metadata.icon_path = data.Icon or nil
                        metadata.icon_downloading = false
                        metadata.filtered = false
                        metadata.on_server = true
                        metadata.refresh = false
                        
                        -- Adjust icon name if we haven't explicitly specified in the plist
                        if metadata.icon_path and string.sub(metadata.icon_path, -4, -1) ~= ".png" then
                            if ContentScaleFactor == 2 then
                                metadata.icon_path = metadata.icon_path .. "@2x.png"
                            else
                                metadata.icon_path = metadata.icon_path .. ".png"
                            end
                        end
                        
                        if metadata.platform == "iphone" then
                            metadata.name = metadata.name .. " (iPhone)"
                        elseif metadata.platform == "ipad" then
                            metadata.name = metadata.name .. " (iPad)"
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

function WebRepo:downloadProject(project_meta)
    
    if not project_meta.update_available then
        return
    end
    
    local editor_name = string.gsub(project_meta.path, ".codea", "")
    
    local downloads = 0
    local function downloadComplete()
        downloads = downloads - 1
        -- TODO: Add rough progress
        if downloads == 0 then
            project_meta.downloading = false
            project_meta.installed = true
            project_meta.update_available = false
            self:flushMetadata()
            
            -- Inform the delegate
            self.delegate.onProjectDownloaded(project_meta)
        end
    end
    
    project_meta.downloading = true
    
    -- Get the contents of the project
    self.api:getContent(project_meta.path, function(content)
        if content == nil then
            print("Failed to get project content. Please check your internet connection.")
            self.connection_failure = true
            project_meta.downloading = false
            return    
        end
        
        -- Create the project if the first request succeeds
        if not hasProject(editor_name) then
            createProject(editor_name)
        end
        
        for _,e in pairs(content) do
            
            -- Download all files at top level
            if e.type == "file" then
                downloads = downloads + 1
                
                -- Get the blob
                self.api:getBlob(e.sha, function(data)
                    if data then
                        local asset_path = asset.documents .. e.path
                        
                        -- Write directly to the file
                        local file = io.open(asset_path.path, "w")
                        file:write(data)
                        file:close()
                        
                        downloadComplete()
                    else
                        self.connection_failure = true
                        project_meta.downloading = false
                    end
                end)
            end
        end
    end)
end

function WebRepo:deleteProject(project_meta)
    
end

function WebRepo:launchProject(project_meta)
    if project_meta.installed then
        
        -- Path to the project's bundle
        local project_path = project_meta.path .. "/"
        
        -- Parse project Info.plist
        local plist = readText(asset.documents .. project_path .. "Info.plist")
        if plist == nil then
            error("Unable to open Info.plist in " .. project_meta.name)
            return
        end
        plist = parsePList(plist)
        
        -- Override Codea API
        overrideAPI(project_path)
        
        -- Clear parameters & log
        output.clear()
        parameter.clear()
        
        -- Any project we run should know it's launched using WebRepo
        _WEB_REPO_LAUNCH_ = true
        
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
    if project_meta.installed then
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