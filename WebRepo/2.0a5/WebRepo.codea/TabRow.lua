
local button_style_sheet = {
    radius = 6,
    fill = color(0, 0),
    fillButtonNormal = color(0, 0),
    fillButtonHover = color(96, 168, 230),
    fillButtonPressed = color(0, 126, 255)
}

-- Current tab
local current_tab = "Today"

local function button(icon, label, callback)
    local node = Oil.Node(0, -5, 60, 75)
        :add_renderer(Oil.RectRenderer)
        :set_style_sheet(button_style_sheet)
        :add_updater(function(node)
            -- Ensure we remain 'pressed' if this is the selected tab
            if current_tab == label then
                node:set_style("fill", node:get_style("fillButtonPressed"))
            end
        end)
        :add_handler(Oil.ButtonHandler(function(bttn)
            callback(bttn, label)
        end))
        :add_children(
            Oil.Label(0, -5, 1.0, 40, icon):set_style("fontSize", 40),
            Oil.Label(0, -50, 1.0, 20, label)
        )
    
    return node
end

function CreateTabRow(news_node, games_node, apps_node, libs_node, --[[assets_node,]] search_node)
    
    -- Track the nodes we're controlling
    local nodes = {}
    nodes["Today"] = news_node
    nodes["Games"] = games_node
    nodes["Apps"] = apps_node
    nodes["Libs"] = libs_node
    --nodes["Assets"] = assets_node
    nodes["Search"] = search_node
    
    local function callback(bttn, id)
        -- Hide all nodes first
        for _,v in pairs(nodes) do
            v.enabled = false
        end
        nodes[id].enabled = true
        current_tab = id
        
        -- Disable all button backgrounds for now
        -- (the button updaters will correct this)
        for _,bttn in pairs(bttn.parent.children) do
            bttn:set_style("fill", bttn:get_style("fillButtonNormal"))
        end
    end
    
    Oil.Rect(0, 0, 1.0, 80 + layout.safeArea.bottom)
    :set_style_sheet(UI.THEME.tab_bar)
    :add_child(
        Oil.HorizontalStack(0, 0, 1.0, 80 + layout.safeArea.bottom)
        :add_renderer(Oil.RectRenderer)
        :add_style("fill", color(255))
        :add_style("blur", true)
        :add_style("blur_amount", 2.0)
        :add_style("blur_kernel_size", 32)
        :add_children(
            button("📅", "Today", callback),
            button("🎮", "Games", callback),
            button("🛠", "Apps", callback),
            button("📚", "Libs", callback),
            --button("🎨", "Assets", callback),
            button("🔍", "Search", callback)
        )
    )
    
    -- Disable all but News
    for _,v in pairs(nodes) do
        v.enabled = false
    end
    nodes["Today"].enabled = true
end
