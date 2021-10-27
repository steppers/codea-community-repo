-- Oil - Alpha 2

viewer.mode = FULLSCREEN_NO_BUTTONS

local news_entry_style = {
    radius = 30,
    shadow = true,
    shadowWidth = 14,
    shadowIntensity = 0.6
}

local icon_style = {
    strokeWidth = 2,
    radius = 12,
    fill=color(255)
}

local function LabelledSwitch(x, y, label, callback, default)
    return Oil.Switch(x, y, callback, default)
        :add_child(Oil.Label(60, 0.5, 100, 32, label, LEFT))
end

function setup()
    Oil.setup()
    FPSOverlay.setup(60)
    
    Oil.Scroll(0.5, 0.5, 1.0, 1.0)
    :add_style("bufferBottom", 400) -- So we can get the text entry above the software keyboard
    :add_child(
        Oil.List(0.5, 1.0, 1.0)
        :add_children(
            Oil.Label(0.5, 0, 200, 50, "I'm a scrolling list!"),
            Oil.Rect(0.5, 0, 200, 30),
            Oil.Icon(0.5, 0, 50, 50, asset.builtin.Blocks.Dirt_Grass),
            Oil.TextButton(0.5, 0, 300, 30, "TextButton", function()
                print("Text Button tapped!")
                Oil.Alert("I'm an alert", function(result)
            
                end)
            end, function()
                print("Text Button long-pressed!")
            end),
            Oil.EmojiButton(0.5, 0, 50, 50, "🎮"),
            Oil.IconButton(0.5, 0, 50, 50, asset.builtin.Blocks.Dirt_Grass),
            Oil.Dropdown(10, 0, -10, 40, "Dropdown")
                :add_children(
                    Oil.Label(0.5, 0, 200, 50, "I can also scroll!"),
                    Oil.IconButton(0.5, 0, 50, 50, asset.builtin.Blocks.Dirt_Grass),
                    Oil.Icon(0.5, 0, 50, 50, asset.builtin.Blocks.Dirt_Snow),
                    Oil.Icon(0.5, 0, 50, 50, asset.builtin.Blocks.Dirt_Sand),
                    Oil.TextButton(0.5, 0, 180, 30, "Another button"),
                    Oil.TextButton(0.5, 0, 180, 30, "And another! :)"),
                    Oil.Icon(0.5, 0, 50, 50, asset.builtin.Blocks.Glass_Frame),
                    Oil.Label(0.5, 0, 200, 60, "This button below\ncloses the app!"),
                    Oil.EmojiButton(0.5, 0, 50, 50, "❌", function()
                        viewer.close()
                    end)
                ),
            Oil.Rect(0.5, 0, 400, 1.1), -- Divider
            Oil.Label(0.5, 0, 400, 10, "Text entry:", LEFT),
            Oil.TextEntry(0.5, 0.5, 400, 100, "I'm a scrolling text entry box!"),
            Oil.Scroll(0.5, 0, 400, 200)
                :set_style("clipAxis", AXIS_Y)
                :add_renderer(Oil.RectRenderer)
                :add_children(
                    Oil.List(0.5, -0.0001, 100)
                    :add_children(
                        Oil.Label(0.5, 0, 200, 50, "I'm also scrollable!"),
                        Oil.IconButton(0.5, 0, 50, 50, asset.builtin.Blocks.Dirt_Grass),
                        Oil.Icon(0.5, 0, 50, 50, asset.builtin.Blocks.Dirt_Snow),
                        Oil.Icon(0.5, 0, 50, 50, asset.builtin.Blocks.Dirt_Sand),
                        Oil.Icon(0.5, 0, 50, 50, asset.builtin.Blocks.Brick_Red),
                        Oil.Icon(0.5, 0, 50, 50, asset.builtin.Blocks.Cactus_Side),
                        Oil.Icon(0.5, 0, 50, 50, asset.builtin.Blocks.Cotton_Red)
                    )
                ),
            Oil.Switch(0.5, 0, function(val)
                print("Switch value changed: " .. tostring(val))
            end),
            Oil.Slider(0.5, 0, 400, 40, 4, 9, function(val)
                print("Slider value changed: " .. val)
            end, 8)
        )
    )
    
    --[[
    -- Scrolling news pane
    local news = Oil.Scroll(0, 0, 1.0, -55)
    :add_style("bufferBottom", 120)
    :add_updater(function(node)
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
                child.y = math.min(-0.0001,  -(i//2) * 430)
                child.w = (isLarge and wlarge) or wsmall
                child.h = 400 -- constant
            end
        else
            for i,child in ipairs(node.children) do
                child.x = 30
                child.y = math.min(-0.0001,  -(i-1) * 430)
                child.w = node.frame.w - 60
                child.h = 400 -- constant
            end
        end
    end)
    
    news:add_child(
        Oil.Rect()
        :add_style(news_entry_style) 
        :add_style("tex", asset.builtin.Environments.Sunny_Front)
        :add_children(
            -- Coming Soon!
            Oil.Label(30, -30, -1, 60, "WebRepo 2.0\nComing Soon!", LEFT)
            :add_style{
                fontSize = 36,
                fillText = color(255)
            },
    
            -- Bottom bar background
            Oil.Rect(0, 0, 1.0, 80)
            :add_style{
                fill = color(220),
                radius = 30
            },
            Oil.Rect(0, 40, 1.0, 40)
            :add_style{
                fill = color(220),
                radius = 0 -- No rounding
            },
    
            -- Icon
            Oil.Icon(30, 10, 60, 60, asset.documents .. "OIL - Alpha 2.codea/Icon@2x.png")
            :add_style("radius", 0),
    
            -- Name label
            Oil.Label(110, 38, 200, 30, "WebRepo 2.0", LEFT)
            :add_style("fontSize", 28)
            :add_style("textFill", color(32)),
    
            -- Author label
            Oil.Label(110, 10, 200, 30, "Steppers", LEFT)
            :add_style("fontSize", 20)
            :add_style("textFill", color(85)),
    
            -- Install button
            Oil.TextButton(-30, 15, 130, 50, "Pre-Register")
        )
    )
    
    news:add_child(
        Oil.Rect()
        :add_style(news_entry_style)
        :add_style("fill", color(25, 127, 226))
        :add_children(
            Oil.VerticalStack(0, 0, 1.0, 1.0)
            :add_style("spacing", 20)
            :add_children(
                Oil.Label(25, -15, -1, 30, "New Releases", LEFT)
                :add_style({fontSize=32, fillText=color(255)}),
    
                Oil.IconButton(25, 0, 60, 60, asset.documents .. "Foggy - West ft UberGoober.codea/Icon.png")
                :add_style(icon_style)
                :add_child(Oil.Label(80, 0.5, 200, 1.0, "Foggy", LEFT):add_style("fontSize", 28))
                :add_child(Oil.TextButton(280, 0.5, 120, 0.8, "Install")),
    
                Oil.IconButton(25, 0, 60, 60, asset.builtin.Blocks.Dirt_Snow)
                :add_style(icon_style)
                :add_child(Oil.Label(80, 0.5, 200, 1.0, "SODA", LEFT):add_style("fontSize", 28))
                :add_child(Oil.TextButton(280, 0.5, 120, 0.8, "Install")),
    
                Oil.IconButton(25, 0, 60, 60, asset.builtin.Blocks.Dirt_Sand)
                :add_style(icon_style)
                :add_child(Oil.Label(80, 0.5, 200, 1.0, "WebRepo 1.3", LEFT):add_style("fontSize", 28))
                :add_child(Oil.TextButton(280, 0.5, 120, 0.8, "Install")),
    
                Oil.IconButton(25, 0, 60, 60, asset.builtin.Blocks.Redstone_Emerald)
                :add_style(icon_style)
                :add_child(Oil.Label(80, 0.5, 200, 1.0, "OIL", LEFT):add_style("fontSize", 28))
                :add_child(Oil.TextButton(280, 0.5, 120, 0.8, "Install"))
            )
        )
    )
    
    news:add_child(
        Oil.Rect()
        :add_style(news_entry_style)
        :add_style("fill", color(223, 45, 63))
        :add_children(
            Oil.VerticalStack(10, 20, -10, -20)
            :add_style("align", TOP)
            :add_style("spacing", 20)
            :add_children(
                Oil.Label(25, 0, -1, 30, "New Features", LEFT)
                :add_style({fontSize=32, fillText=color(255)}),
    
                LabelledSwitch(5, 0, "In-App Submissions & Approval?", nil, true),
                LabelledSwitch(5, 0, "Light & Dark Themes?", nil, true),
                LabelledSwitch(5, 0, "Slick new UI?", nil, true),
                LabelledSwitch(5, 0, "Annoying Github login?", nil, false),
                LabelledSwitch(5, 0, "Best Community Projects?", nil, true)
            )
        )
    )
    
    news:add_children(
        Oil.Rect(490, -430, -30, 400):add_style(news_entry_style):add_style("fill", color(210, 73, 217))
        :add_child(Oil.Label(0.5, 0.5, 1.0, 1.0, string.rep("xXx", 20)))
    )
    
    -- Bottom bar
    Oil.Rect(0, 0, 1.0, 90, color(160), nil, true)
    :set_priority(100)
    :add_handler(Oil.TouchBlocker)
    :add_children(
        Oil.HorizontalStack()
        :add_children(
            Oil.EmojiButton(0, -5, 50, 50, "📅"),
            Oil.EmojiButton(0, -5, 50, 50, "🎮"),
            Oil.EmojiButton(0, -5, 50, 50, "🛠"),
            Oil.EmojiButton(0, -5, 50, 50, "📚"),
            Oil.EmojiButton(0, -5, 50, 50, "🎨"),
            Oil.EmojiButton(0, -5, 50, 50, "🔍")
        )
    )
    
    -- Top buttons
    Oil.Node(0, -0.0001, 1.0, 55)
    :add_children(
        -- Top right button group
        Oil.HorizontalStack(-10, 0, 1.0, 1.0)
        :add_style("align", RIGHT)
        :add_children(
            Oil.TextButton(0, -10, 100, 35, "Review"),
            Oil.TextButton(0, -10, 100, 35, "Submit"),
            Oil.TextButton(0, -10, 100, 35, "Settings")
        ),
    
        -- Top left button group
        Oil.HorizontalStack(10, 0, 1.0, 1.0)
        :add_style("align", LEFT)
        :add_children(
            Oil.EmojiButton(0, -10, 35, 35, "❌", function()
                viewer.close() 
            end)
            :set_style("fontSize", 24)
        )
    )
    ]]
end

function draw()
    Oil.beginDraw()
    background(64)
    Oil.endDraw()
    
    --FPSOverlay.draw()
end

function sizeChanged(w, h)
    Oil.sizeChanged(w, h)
end

function hover(g)
    Oil.hover(g)
end

function scroll(g)
    Oil.scroll(g)
end

function touched(t)
    Oil.touch(t)
end

function keyboard(k)
    Oil.keyboard(k)
end
