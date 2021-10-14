-- Oil - Alpha 2

viewer.mode = FULLSCREEN_NO_BUTTONS

function setup()
    Oil.setup()
    
    -- Scrolling news pane
    local news = Oil.Scroll(0, 120, 1.0, -55)
    :set_style{radius = 30} -- inherited by the children
    :add_updater(function(node)
        -- This updater arranges the children in a similar fashion
        -- to the iOS App Store's 'Today' tab.
        local wunit = ((node.frame.w - 90) / 5)
        local wsmall = wunit * 2
        local wlarge = wunit * 3
        for i,child in ipairs(node.children) do
            local i = i-1
            local isLeft = ((i%2) == 0)
            local isLarge = ((i%4)%3 == 0)
            
            child.x = (isLeft and 30) or -30
            child.y = math.min(-0.0001,  -(i//2) * 430)
            child.w = (isLarge and wlarge) or wsmall
            child.h = 400 -- constant
        end
    end)
    
    news:add_child(
        Oil.Rect()
        :set_texture(asset.builtin.Environments.Sunny_Front)
        :add_children(
            -- Coming Soon!
            Oil.Label(30, -30, -1, 60, "WebRepo 2.0\nComing Soon!", LEFT)
            :set_style{
                fontSize = 36,
                fillText = color(255)
            },
    
            -- Bottom bar background
            Oil.Rect(0, 0, 1.0, 80)
            :set_style{
                fill = color(220)
            },
            Oil.Rect(0, 40, 1.0, 40)
            :set_style{
                fill = color(220),
                radius = 0 -- No rounding
            },
    
            -- Icon
            Oil.Icon(30, 10, 60, 60, asset.documents .. "OIL - Alpha 2.codea/Icon@2x.png")
            :set_style{ radius = 0 },
    
            -- Name label
            Oil.Label(110, 38, 200, 30, "WebRepo 2.0", LEFT)
            :set_style{
                fontSize = 28
            },
    
            -- Author label
            Oil.Label(110, 10, 200, 30, "Steppers", LEFT)
            :set_style{
                fontSize = 20,
                fillText = color(85)
            },
    
            -- Install button
            Oil.TextButton(-30, 15, 130, 50, "Pre-Register")
        )
    )
    
    news:add_child(
        Oil.Rect()
        :set_style{
            fill = color(25, 127, 226),
            fillText = color(255),
            fontSize = 24,
            textAlign = LEFT
        }
        :add_children(
            Oil.VerticalSpreader(0, 0, 1.0, 1.0)
            :set_style{
                spacing = 20
            }
            :add_children(
                Oil.Label(25, -15, -1, 30, "New Releases")
                :set_style{
                    fontSize = 32
                },
    
                Oil.IconButton(25, 0, 60, 60, asset.builtin.Blocks.Dirt_Grass):set_style{fill=color(255)}
                :add_child(Oil.Label(80, 0.5, 200, 1.0, "Foggy"))
                :add_child(Oil.TextButton(280, 0.5, 120, 0.8, "Install")),
    
                Oil.IconButton(25, 0, 60, 60, asset.builtin.Blocks.Dirt_Snow):set_style{fill=color(255)}
                :add_child(Oil.Label(80, 0.5, 200, 1.0, "SODA"))
                :add_child(Oil.TextButton(280, 0.5, 120, 0.8, "Install")),
    
                Oil.IconButton(25, 0, 60, 60, asset.builtin.Blocks.Dirt_Sand):set_style{fill=color(255)}
                :add_child(Oil.Label(80, 0.5, 200, 1.0, "WebRepo 1.3"))
                :add_child(Oil.TextButton(280, 0.5, 120, 0.8, "Install")),
    
                Oil.IconButton(25, 0, 60, 60, asset.builtin.Blocks.Redstone_Emerald):set_style{fill=color(255)}
                :add_child(Oil.Label(80, 0.5, 200, 1.0, "OIL"))
                :add_child(Oil.TextButton(280, 0.5, 120, 0.8, "Install"))
            )
        )
    )
    
    news:add_children(
        Oil.Rect(30, -430, 430, 400):set_style{fill = color(53, 174, 113)},
        Oil.Rect(490, -430, -30, 400):set_style{fill = color(210, 73, 217)}
    )
    
    -- Bottom bar
    Oil.Rect(0, 0, 1.0, 90, color(160), nil, true)
    :set_priority(100)
    :add_handler(Oil.TouchBlocker())
    :add_children(
        Oil.HorizontalSpreader()
        :add_children(
            Oil.IconButton(0, -5, 50, 50, asset.builtin.Blocks.Dirt_Grass),
            Oil.IconButton(0, -5, 50, 50, asset.builtin.Blocks.Brick_Red),
            Oil.TextButton(0, -5, 200, 50, "We're all in a spreader"),
            Oil.IconButton(0, -5, 50, 50, asset.builtin.Blocks.Grass_Top),
            Oil.IconButton(0, -5, 50, 50, asset.builtin.Blocks.Ice)
        )
    )
    
    -- Top buttons
    Oil.Node(0, -0.0001, 1.0, 55)
    :add_children(
        -- Top right button group
        Oil.HorizontalSpreader(-10, 0, 1.0, 1.0)
        :set_style({align=RIGHT})
        :add_children(
            Oil.TextButton(0, -10, 100, 35, "Review"),
            Oil.TextButton(0, -10, 100, 35, "Submit"),
            Oil.TextButton(0, -10, 100, 35, "Settings")
        ),
    
        -- Top left button group
        Oil.HorizontalSpreader(10, 0, 1.0, 1.0)
        :set_style({align=LEFT})
        :add_children(
            Oil.TextButton(0, -10, 35, 35, "❌", function()
                viewer.close() 
            end):set_style({
                fillText = color(255),
                fontSize = 24
            })
        )
    )
end

function draw()
    Oil.beginDraw()
    background(64)
    Oil.endDraw()
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
