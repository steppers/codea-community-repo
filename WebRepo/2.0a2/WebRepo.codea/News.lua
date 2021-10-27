local scroll_node

local icon_style = {
    strokeWidth = 0,
    radius = 16,
    fill=color(255)
}

local function LabelledSwitch(x, y, label, callback, default)
    return Oil.Switch(x, y, callback, default)
        :add_child(
            Oil.Label(60, 0.5, 100, 32, label, LEFT)
            :set_style_sheet(UI.THEME.news_internal_alt)
        )
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
        
        if wsmall > 300 then
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
        :set_style_sheet(UI.THEME.news)
        :add_style("tex", asset .. "Icon.png")
        :add_children(
            -- Coming Soon!
            Oil.Label(15, -15, -1, 60, "WebRepo 2.0\nComing Soon!", LEFT)
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
            Oil.Icon(10, 10, 60, 60, asset.documents .. "WebRepo 2.0.codea/Icon@2x.png")
            :add_style(icon_style),
    
            -- Name label
            Oil.Label(80, 35, 200, 30, "WebRepo 2.0", LEFT)
            :set_style_sheet(UI.THEME.news_internal),
    
            -- Author label
            Oil.Label(80, 12, 200, 30, "Codea Community Repository", LEFT)
            :set_style_sheet(UI.THEME.news_internal_alt)
            :add_style("fontSize", 16),
    
            -- Install button
            Oil.TextButton(-10, 20, 150, 40, "PRE-REGISTER")
            :set_style_sheet(UI.THEME.button)
        )
    )
    
    scroll_node:add_child(
        Oil.Rect()
        :set_style_sheet(UI.THEME.news_internal)
        :add_style("radius", 16)
        :add_children(
            Oil.VerticalStack(10, 20, -10, -20)
            :add_style("align", TOP)
            :add_style("spacing", 20)
            :add_children(
                Oil.Label(25, 0, -1, 30, "New Features", LEFT)
                :set_style_sheet(UI.THEME.news_internal)
                :add_style("fontSize", 32),
    
                LabelledSwitch(5, 0, "In-App Submissions & Approval?", nil, true),
                LabelledSwitch(5, 0, "Light & Dark Themes?", nil, true),
                LabelledSwitch(5, 0, "Slick new UI?", nil, true),
                LabelledSwitch(5, 0, "Annoying Github login?", nil, false),
                LabelledSwitch(5, 0, "Best Community Projects?", nil, true)
            )
        )
    )
    
    bare_news_node:add_child(scroll_node)
    
end

local function newsAddNewProject(info)
    
    -- Missing icon
    local icon = Oil.Icon(10, 10, 60, 60, asset.builtin.Blocks.Missing)
    :add_style(icon_style)
    
    -- Retrieve the app icon
    DB.getAppBanner(info.app, function(img)
        if not img then return end
        icon:set_style("tex", img)
    end)
    
    local root = Oil.Rect()
        :set_style_sheet(UI.THEME.news)
        :add_handler(Oil.ButtonHandler(function()
            AppWindow(info.app)
        end))
        :add_children(
            -- New Project:
            Oil.Label(15, -15, -1, 60, "New Project:\n" .. info.app.name, LEFT)
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
            Oil.Label(80, 35, 200, 30, info.app.name, LEFT)
            :set_style_sheet(UI.THEME.news_internal),
    
            -- Desc. label
            Oil.Label(80, 12, 200, 30, info.app.info.short_description, LEFT)
            :set_style_sheet(UI.THEME.news_internal_alt)
            :add_style("fontSize", 16),
    
            -- Install button
            Oil.TextButton(-10, 20, 100, 40, "INSTALL")
            :set_style_sheet(UI.THEME.button)
        )
    
    DB.getAppBanner(info.app, function(img)
        if not img then return end
        root:set_style("tex", img)
    end)
    
    scroll_node:add_child(root)
end

function newsAddNewUpdate(info)
    
end

function newsAddNewComingSoon(info)
    
end

function newsAddRecentReleases(info)
    
end

function newsAddRecentUpdates(info)
    
end

local item2func = {
    new_project = newsAddNewProject,
    new_update = newsAddNewUpdate,
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
