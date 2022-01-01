
function AppList(allow_search)
    local root = Oil.Scroll(0, 0, 1.0, -(50 + layout.safeArea.top))
    :add_style("bufferBottom", 120)
    :add_style("padding", 10)
    :add_pre_updater(function(node)
        -- Skip unless needed
        if not node.needs_reposition and node.last_width == WIDTH then
            return
        end
        
        -- Save current state
        node.needs_reposition = false
        node.last_width = WIDTH
        
        -- Do the repositioning
        local padding = node:get_style("padding")
        if allow_search then
            if WIDTH < 800 then
                local cw = WIDTH - (padding * 2)
                for i = 2,#node.children do
                    local child = node.children[i]
                    child.w = cw
                    child.x = padding
                    child.y = -(child.h + padding) * (i-1)
                end
            else
                local cw = (WIDTH - (padding * 3)) // 2
                for i = 2,#node.children do
                    local child = node.children[i]
                    child.w = cw
                    child.x = padding + ((i-2) % 2)*(cw + padding)
                    child.y = -(child.h + padding) * (i // 2)
                end
            end
        else
            if WIDTH < 800 then
                local cw = WIDTH - (padding * 2)
                for i,child in ipairs(node.children) do
                    child.w = cw
                    child.x = padding
                    child.y = -(child.h + padding) * i
                end
            else
                local cw = (WIDTH - (padding * 3)) // 2
                for i,child in ipairs(node.children) do
                    child.w = cw
                    child.x = padding + ((i-1) % 2)*(cw + padding)
                    child.y = -(child.h + padding) * ((i+1) // 2)
                end
            end
        end
    end)
    
    -- Setup the search bar
    if allow_search then
        
        -- Search function
        --
        -- This sets priorities of the children based on their
        -- fuzzy scores
        local function search(str)
            if str == "" then
                for _,child in pairs(root.children) do
                    local app = child.state.app
                    if app then
                        child.priority = 33166368000 - (app.info.timestamp or 1) -- Sort by timestamp
                        child.enabled = true
                    end
                end
                root:sort_children()
                root.needs_reposition = true
                return
            end
            
            for _,child in pairs(root.children) do
                local app = child.state.app
                if app then
                    local score = 0
                    if fzy.has_match(str, app.info.name) then
                        score = fzy.score(str, app.info.name)
                    elseif fzy.has_match(str, app.authors_str) then
                        score = fzy.score(str, app.authors_str)
                    elseif fzy.has_match(str, app.info.short_description) then
                        score = fzy.score(str, app.info.short_description)
                    end
                        
                    child.priority = ((score ~= 0 and -math.min(score, math.maxinteger-1)) or math.maxinteger)
                    child.enabled = (score ~= 0) 
                end
            end
            root:sort_children()
            root.needs_reposition = true
        end
        
        root:add_child(
            -- Search box
            Oil.TextEntry(0.5, -50, 320, 35, "Search", function(str)
                search(str)
            end)
            :set_style_sheet(UI.THEME.text_entry)
            :set_priority(math.mininteger)
        )
    end
    
    function root:add_app(app)
        local root = Oil.Node(0, 0, 300, 80)
        root:set_priority(33166368000 - (app.info.timestamp or 1)) -- Sort by timestamp
        
        -- App icon (missing by default)
        local icon = Oil.Icon(10, 10, 60, 60, asset.builtin.Blocks.Missing)
        :add_style("radius", 16)
    
        -- Retrieve the app icon
        DB.getAppIcon(app, function(img)
            if not img then return end
            icon:set_style("tex", img)
        end)
        
        -- Name label
        local name = Oil.Label(80, -0.001, 1.0, 40, app.info.name, LEFT)
            :set_style_sheet(UI.THEME.news_internal)
        
        -- Desc. label
        local desc = Oil.Label(80, 0.5, 1.0, 40, app.info.short_description, LEFT)
            :set_style_sheet(UI.THEME.news_internal_alt)
            :add_style("fontSize", 16)
        
        -- Author label
        local authors = Oil.Label(80, 0, 1.0, 40, app.authors_str, LEFT)
            :set_style_sheet(UI.THEME.news_internal_alt)
            :add_style("fontSize", 16)
        
        local function update_button_text(bttn)            
            if DB.isAppInstalled(app.name, app.version) then
                bttn:add_style("text", "INSTALLED")
            else
                bttn:add_style("text", "GET")
            end
        end
        
        -- Action button
        local button = Oil.TextButton(-0.0001, 0.5, 135, 30, "GET", function(bttn)
            if bttn:get_style("text") == "GET" then
                if not DB.isAppDownloaded(app.name, app.version) then
                    bttn:set_style("text", "...")
                    DB.downloadApp(app, function(success, err)
                        if success then
                            DB.installApp(app.name, app.version)
                            update_button_text(bttn)
                        else
                            print(err)
                            bttn:set_style("text", "GET")
                        end
                    end)
                elseif not DB.isAppInstalled(app.name, app.version) then
                    DB.installApp(app.name, app.version)
                    update_button_text(bttn)
                end
            end
        end)
        :set_style_sheet(UI.THEME.button)
        update_button_text(button)
        
        -- 1 pixel line
        local divider = Oil.Rect(80, 0, -0.001, -79.5)
        :set_style_sheet(UI.THEME.divider)
        
        root:add_children(
            icon,
            name,
            desc,
            authors,
            button,
            divider
        )
        root.state.app = app
        
        self:add_child(root)
        
        
        root:add_handler(Oil.ButtonHandler(function()
            -- Open the app window
            AppWindow(app)
        end))
        
        -- Trigger an update
        self.needs_reposition = true
    end
    
    return root
end
