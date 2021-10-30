
function AppList()
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
    end)
    
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
        local name = Oil.Label(80, 30, 1.0, 40, app.info.name, LEFT)
            :set_style_sheet(UI.THEME.news_internal)
        
        -- Desc. label
        local desc = Oil.Label(80, 8, 1.0, 40, app.info.short_description, LEFT)
            :set_style_sheet(UI.THEME.news_internal_alt)
            :add_style("fontSize", 16)
        
        local function update_button_text(bttn)            
            if DB.isAppInstalled(app.name, app.version) then
                bttn:add_style("text", "INSTALLED")
            elseif not DB.isAppDownloaded(app.name, app.version) then
                bttn:add_style("text", "DOWNLOAD")
            else
                bttn:add_style("text", "INSTALL")
            end
        end
        
        -- Action button
        local button = Oil.TextButton(-0.0001, 0.5, 135, 30, "INSTALL", function(bttn)
            if bttn:get_style("text") == "DOWNLOAD" then
                bttn:set_style("text", "...")
                DB.downloadApp(app, function(success, err)
                    if success then
                        DB.installApp(app.name, app.version)
                        update_button_text(bttn)
                    else
                        print(err)
                        bttn:set_style("text", "DOWNLOAD")
                    end
                end)
            elseif bttn:get_style("text") == "INSTALL" then
                DB.installApp(app.name, app.version)
                update_button_text(bttn)
            end
        end)
        :set_style_sheet(UI.THEME.button)
        update_button_text(button)
        
        -- 1 pixel line
        local divider = Oil.Rect(80, 1, -0.001, 1.0001)
        :set_style_sheet(UI.THEME.divider)
        
        root:add_children(
            icon,
            name,
            desc,
            button,
            divider
        )
        
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
