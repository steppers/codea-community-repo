
local function TextDropdown(x, y, w, h, default, options, cb)
    local dd = Oil.Dropdown(x, y, w, h, default)
    :add_style(UI.THEME.dropdown)
    
    local handler = function(node, event)
        if event.type == "tap" and node:covers(event.pos) then
            local val = node:get_style("text")
            dd:add_style("text", val)
            dd:transition(false)
            cb(val)
            return true
        end
        return false
    end
        
    for i,item in ipairs(options) do
        if i > 1 then
            dd:add_child(
                -- 1 pixel line
                Oil.Rect(0.5, 0, 100, 1.0001)
                :set_style_sheet(UI.THEME.divider)
            )
        end
        dd:add_child(
            -- Label
            Oil.Label(0, 0, 1.0, 20, item)
            :add_handler(handler)
            :set_style_sheet(UI.THEME.dropdown)
        )
    end
    
    return dd
end

local function LabelledSwitch(x, y, label, callback, default)
    return Oil.Switch(x, y, callback, default)
        :add_child(
            Oil.Label(60, 0.5, 100, 32, label, LEFT)
            :set_style_sheet(UI.THEME.news_internal)
        )
end

function SettingsWindow()
    local root = Oil.Rect(0, 0, 1.0, 1.0)
    :set_priority(20)
    :set_style_sheet(UI.THEME.background)
    :add_handler(function(node, event)
        return true
    end)
    
    local list = Oil.List(0.5, -50, 1.0)
    :add_children(
        Oil.Label(10, 0, -10, 20, "Theme:", LEFT)
        :set_style_sheet(UI.THEME.news_internal),
        TextDropdown(10, 0, -10, 30, readLocalData("theme") or "light", {"light", "dark"}, function(v)
            saveLocalData("theme", v)
        end),
    
        LabelledSwitch(10, 0, "Enable Review", function(v)
            UI.ENABLE_REVIEW = v
            UI.REVIEW_BUTTON.enabled = v
            saveLocalData("review_enabled", v)
        end, readLocalData("review_enabled") or false),
    
        LabelledSwitch(10, 0, "Clear Cache & Restart", function(v)
            DB.fs:format()
            viewer.restart()
        end, false)
    )
    
    root:add_children(
        -- Close button
        Oil.EmojiButton(10, -10, 30, 30, "❌", function()
            root:kill()
        end)
        :set_style_sheet(UI.THEME.button)
        :add_style("fontSize", 14)
        :add_style("textFill", color(255)),
    
        Oil.Label(0.5, -0.0001, 1.0, 50, "Settings")
        :set_style_sheet(UI.THEME.button)
        :add_style("fontSize", 20)
        :add_style("font", "HelveticaNeue-Bold"),
    
        -- 1 pixel line
        Oil.Rect(5, -50, -5, 1.0001)
        :set_style_sheet(UI.THEME.divider),
    
        -- The content
        list
    )
end
