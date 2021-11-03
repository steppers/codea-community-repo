local scroll_node

local icon_style = {
    strokeWidth = 0,
    radius = 16,
    fill=color(255)
}

local function age_string(timestamp)
    local time_ago = os.time() - timestamp
    if time_ago < 60 then
        return string.format("%d sec%s ago", time_ago, (time_ago == 1 and "") or "s")
    elseif time_ago < 3600 then
        time_ago = time_ago // 60
        return string.format("%d min%s ago", time_ago, (time_ago == 1 and "") or "s")
    elseif time_ago < 86400 then
        time_ago = time_ago // 3600
        return string.format("%d hour%s ago", time_ago, (time_ago == 1 and "") or "s")
    elseif time_ago < 31536000 then
        time_ago = time_ago // 86400
        return string.format("%d day%s ago", time_ago, (time_ago == 1 and "") or "s")
    else
        time_ago = time_ago // 31536000
        return string.format("%d year%s ago", time_ago, (time_ago == 1 and "") or "s")
    end
end

-- Accepts a bare node and configures it as the news screen
function initNewsNode(bare_news_node)
    
    -- Scrolling news pane
    scroll_node = Oil.Scroll(0, 0, 1.0, -(50 + layout.safeArea.top))
    :add_style("bufferBottom", 120)
    :add_pre_updater(function(node)
        -- This updater arranges the children in a similar fashion
        -- to the iOS App Store's 'Today' tab.
        local wunit = ((node.frame.w - 90) / 5)
        local wsmall = wunit * 2
        local wlarge = wunit * 3
        
        if wsmall > 400 then
            for i,child in ipairs(node.children) do
                local i = i-1
                local isLeft = ((i%2) == 0)
                local isLarge = ((i%4)%3 == 0)
                
                child.x = (isLeft and 30) or -30
                child.y = math.min(-0.0001,  -(i//2) * 350)
                child.w = (isLarge and wlarge) or wsmall
                child.h = 320 -- constant
            end
        else
            for i,child in ipairs(node.children) do
                child.x = 8
                child.y = math.min(-0.0001,  -(i-1) * 336)
                child.w = node.frame.w - 16
                child.h = 320 -- constant
            end
        end
    end)
    
    scroll_node:add_child(
        Oil.Rect()
        :set_priority(33166368000) -- 1st Jan 3021 00:00:00
        :set_style_sheet(UI.THEME.news_internal)
        :add_style("radius", 16)
        :add_children(
            Oil.Label(0, 0, 1.0, 1.0, "The end of time...")
            :set_style_sheet(UI.THEME.news_internal_alt)
        )
    )
    
    bare_news_node:add_child(scroll_node)
    
end

local function newsProject(info)
    
    -- Limit the number of news items
    if #scroll_node.children >= 32 then
        return
    end
    
    local title = "New Project "
    if info.type == "new_update" then
        title = "Updated "
    end
    
    -- Missing icon
    local icon = Oil.Icon(10, 10, 60, 60, asset.builtin.Blocks.Missing)
    :add_style(icon_style)
    
    -- Retrieve the app icon
    DB.getAppBanner(info.app, function(img)
        if not img then return end
        icon:set_style("tex", img)
    end)
    
    local function update_button_text(bttn)
        if DB.isAppInstalled(info.app.name, info.app.version) then
            bttn:add_style("text", "INSTALLED")
        elseif not DB.isAppDownloaded(info.app.name, info.app.version) then
            bttn:add_style("text", "GET")
        else
            bttn:add_style("text", "INSTALL")
        end
    end
    
    -- Action button
    local button = Oil.TextButton(-10, 25, 135, 30, "INSTALL", function(bttn)
        if bttn:get_style("text") == "GET" then
            bttn:set_style("text", "...")
            DB.downloadApp(info.app, function(success, err)
                if success then
                    DB.installApp(info.app.name, info.app.version)
                    update_button_text(bttn)
                else
                    print(err)
                    bttn:set_style("text", "GET")
                end
            end)
        elseif bttn:get_style("text") == "INSTALL" then
            DB.installApp(info.app.name, info.app.version)
            update_button_text(bttn)
        end
    end)
    :set_style_sheet(UI.THEME.button)
    update_button_text(button)
    
    local root = Oil.Rect()
        :set_priority(33166368000 - (info.app.info.timestamp or 1)) -- Sort by timestamp
        :set_style_sheet(UI.THEME.news)
        :add_handler(Oil.ButtonHandler(function()
            AppWindow(info.app)
        end))
        :add_children(
            -- New Project:
            Oil.Label(15, -10, -1, 35, title .. age_string(info.app.info.timestamp), LEFT)
            :add_style{
                fontSize = 32,
                fillText = color(255)
            },
    
            -- Bottom bar background
            Oil.Rect(0, 0, 1.0, 80)
                :set_style_sheet(UI.THEME.news_internal)
                :add_style("radius", 16),
            Oil.Rect(0, 40, 1.0, 40)
                :set_style_sheet(UI.THEME.news_internal)
                :add_style("radius", 0),
    
            -- Icon
            icon,
    
            -- Name label
            Oil.Label(80, 35, 200, 30, info.app.info.name, LEFT)
            :set_style_sheet(UI.THEME.news_internal),
    
            -- Desc. label
            Oil.Label(80, 12, 200, 30, info.app.info.short_description, LEFT)
            :set_style_sheet(UI.THEME.news_internal_alt)
            :add_style("fontSize", 16),
    
            -- Install button
            button
        )
    
    DB.getAppBanner(info.app, function(img)
        if not img then return end
        root:set_style("tex", img)
    end)
    
    scroll_node:add_child(root)
end

function newsAddNewComingSoon(info)
    
end

function newsAddRecentReleases(info)
    
end

function newsAddRecentUpdates(info)
    
end

local item2func = {
    new_project = newsProject,
    new_update = newsProject,
    coming_soon = newsAddComingSoon,
    recent_releases = newsAddRecentReleases,
    recent_updates = newsAddRecentUpdates
}

function newsAddItem(info)
    local func = item2func[info.type]
    if func then
        func(info)
    else
        error("Unknown news item type: " .. info.type)
    end
end
