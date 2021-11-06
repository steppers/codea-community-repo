
function AppWindow(app)
    local root = Oil.Rect(0, 0, 1.0, 1.0)
    :set_style_sheet(UI.THEME.app_window)
    :set_priority(20)
    :add_handler(function(node, event)
        if event.type == "tap" then
            node:kill()
        end
        return true
    end)
    
    local scroll = Oil.Scroll(0, 0, 1.0, 1.0)
    :add_style("radius", 15)
    :add_style("bufferBottom", 50)
    
    -- App icon (missing by default)
    local icon = Oil.Icon(10, -266, 96, 96, asset.builtin.Blocks.Missing)
    :add_style("radius", 16)
    
    -- App banner (missing by default)
    local banner = Oil.Icon(0, -0.0001, 1.0, 256, asset.builtin.Blocks.Missing)
    :add_style("texAspectFill", true)
    
    -- Retrieve the app icon
    DB.getAppIcon(app, function(img)
        if not img then return end
        icon:set_style("tex", img)
    end)
    
    -- Retrieve the app banner
    DB.getAppBanner(app, function(img)
        if not img then return end
        banner:set_style("tex", img)
    end)
    
    -- Name label
    local name = Oil.Label(116, -260, 1.0, 40, app.info.name, LEFT)
        :set_style_sheet(UI.THEME.news_internal)
        :add_style("fontSize", 24)
        
    -- Desc. label
    local desc = Oil.Label(116, -292, 1.0, 40, app.info.short_description, LEFT)
        :set_style_sheet(UI.THEME.news_internal_alt)
        :add_style("fontSize", 16)
    
    local project_size = app.info.size or "N/A"
    if app.info.size then
        if project_size < 1024 then
            project_size = string.format("%dB", project_size)
        elseif project_size < 1024 * 1024 then
            project_size = string.format("%.1fKB", project_size / 1024)
        elseif project_size < 1024 * 1024 * 1024 then
            project_size = string.format("%.1fMB", project_size / (1024*1024))
        end
    end
    
    local extras = Oil.HorizontalStack(10, -382, -10, 80)
    :add_children(
        Oil.Node(0, 0, 100, 80)
        :add_children(
            Oil.Label(0, -1, 1.0, 10, "DEVELOPER")
            :set_style_sheet(UI.THEME.news_internal_alt)
            :add_style("fontSize", 14),
            Oil.Label(0, 0, 1.0, 70, app.authors_str)
            :set_style_sheet(UI.THEME.news_internal_alt)
            :add_style("fontSize", 14)
            :add_style("textWrapWidth", 100)
        ),
    
        Oil.Node(0, 0, 100, 80)
        :add_children(
            Oil.Label(0, -1, 1.0, 10, "PLATFORMS")
            :set_style_sheet(UI.THEME.news_internal_alt)
            :add_style("fontSize", 14),
            Oil.Label(0, 0, 1.0, 70, app.info.platform or "iPad & iPhone")
            :set_style_sheet(UI.THEME.news_internal_alt)
            :add_style("fontSize", 14)
            :add_style("textWrapWidth", 100)
        ),
    
        Oil.Node(0, 0, 100, 80)
        :add_children(
            Oil.Label(0, -1, 1.0, 10, "SIZE")
            :set_style_sheet(UI.THEME.news_internal_alt)
            :add_style("fontSize", 14),
            Oil.Label(0, 0, 1.0, 70, project_size)
            :set_style_sheet(UI.THEME.news_internal_alt)
            :add_style("fontSize", 14)
            :add_style("textWrapWidth", 100)
        )
    )
    
    -- What's New label
    local whats_new_heading = Oil.Label(10, -472, -10, 20, "What's New", LEFT)
        :set_style_sheet(UI.THEME.news_internal)
        :add_style("fontSize", 24)
    
    -- Update Notes
    local whats_new_list = Oil.List(10, -502, -10)
    local whats_new = Oil.Scroll(10, -502, -10, 106)
    :add_style("clipAxis", AXIS_Y)
    :add_child(whats_new_list)
    
    -- Long Desc. Label
    local long_desc = Oil.LabelResize(10, -617, -10, 100, app.info.description, LEFT)
    :set_style_sheet(UI.THEME.news_internal)
        :add_style({
            fontSize = 16,
            textWrapWidth = 0.85 -- no idea why this is a limit before the text vanishes
        })
    
    -- Version dropdown
    local version_dd = Oil.Dropdown(-10, -332, 145, 30, app.version)
    :add_style(UI.THEME.dropdown)
    :add_style("textAlign", RIGHT)
    
    local function update_button_text(bttn)
        if DB.isAppInstalled(app.name, version_dd:get_style("text")) then
            bttn:add_style("text", "INSTALLED")
        elseif not DB.isAppDownloaded(app.name, version_dd:get_style("text")) then
            bttn:add_style("text", "GET")
        else
            bttn:add_style("text", "INSTALL")
        end
    end
    
    -- Action button
    local button = Oil.TextButton(116, -332, 150, 30, "GET", function(bttn)
        local app = DB.apps[app.name][version_dd:get_style("text")]
        
        if bttn:get_style("text") == "GET" then
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
        else
            DB.installApp(app.name, app.version)
            update_button_text(bttn)
        end
    end)
    :set_style_sheet(UI.THEME.button)
    
    -- Setup button
    update_button_text(button)
    
    local dd_handler = function(node, event)
        if event.type == "tap" and node:covers(event.pos) then
            version_dd:add_style("text", node:get_style("text"))
            version_dd:transition(false)
            update_button_text(button)
            return true
        end
        return false
    end
    
    -- Add versions to dropdown & generate 'What's new string'
    for i = #DB.apps[app.name], 1, -1 do
        local app = DB.apps[app.name][i]
        whats_new_list:add_child(
            Oil.LabelResize(10, -0.0001, -10, 10, app.version .. ":\n" .. app.info.update_notes, LEFT)
            :set_style_sheet(UI.THEME.news_internal)
            :add_style({
                fontSize = 16,
            })
        )
        version_dd:add_child(
            Oil.Label(0, 0, 1.0, 20, app.version)
            :add_handler(dd_handler)
            :set_style_sheet(UI.THEME.dropdown)
        )
    end
        
    scroll:add_children(
        banner,
        icon,
        name,
        desc,
        button,
        version_dd,
    
        Oil.Rect(10, -371, -10, 1.0001)
        :set_style_sheet(UI.THEME.divider),
    
        extras,
        --screenshots,
    
        Oil.Rect(10, -461, -10, 1.0001)
        :set_style_sheet(UI.THEME.divider),
    
        -- Update notes
        whats_new_heading,
        whats_new,
    
        Oil.Rect(10, -611, -10, 1.0001)
        :set_style_sheet(UI.THEME.divider),
    
        -- Description
        long_desc
    )
    
    if app.info.forum_link then
        -- Share button
        scroll:add_child(
            Oil.EmojiButton(-10, -266, 30, 30, "🌐", function()
                openURL(app.info.forum_link, true)
            end)
            :set_style_sheet(UI.THEME.button)
            :add_style("textFill", color(255))
        )
    end
    
    root:add_child(scroll)
    root:add_child(
        Oil.EmojiButton(10, -10, 30, 30, "❌", function()
            root:kill()
        end)
        :set_style_sheet(UI.THEME.button)
        :add_style("fontSize", 14)
        :add_style("textFill", color(255))
    )
end
