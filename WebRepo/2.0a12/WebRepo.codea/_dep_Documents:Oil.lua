-- Contents:
--    Main.lua
--    OIL.lua
--    OILInput.lua
--    Prefabs.lua
--    StyleSheets.lua
--    Node.lua
--    RectRenderer.lua
--    Blur.lua

------------------------------
-- Main.lua
------------------------------
do
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
    --FPSOverlay.setup(60)
    
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

end
------------------------------
-- OIL.lua
------------------------------
do
Oil = {}

-- New global values
TOP = "top"
BOTTOM = "bottom"

-- Axis types
AXIS_NONE = 0
AXIS_X =  1
AXIS_Y =  2
AXIS_XY = 3

function Oil.setup()
    -- Create framebuffer
    Oil.fb = image(WIDTH, HEIGHT)
    
    -- Init root node
    Oil.root = Oil.Node(0, 0, WIDTH, HEIGHT)
    Oil.root.style_default = Oil.style_default
    Oil.root:set_debug_name("root")
end

function Oil.beginDraw()
    setContext(Oil.fb)
end

function Oil.endDraw()
    -- Update touches
    update_touches()
    
    -- Update nodes
    Oil.root:update()
    Oil.root:post_update()
    
    -- Draw nodes
    setContext(Oil.fb)
    Oil.root:draw()
    setContext()
    
    -- Blit to screen
    ortho(0, WIDTH, 0, HEIGHT)
    spriteMode(CORNER)
    sprite(Oil.fb, 0, 0)
end

function Oil.sizeChanged(w, h)
    if Oil.root == nil then
        return
    end
    
    -- Regenerate framebuffer
    Oil.fb = image(w, h)
    
    -- Resize root node
    Oil.root.w = w
    Oil.root.h = h 
end



-- Clip management
local clip_stack = {}
function Oil.clip(x, y, w, h)
    
    if #clip_stack > 0 then
        local old = clip_stack[#clip_stack]
        local r = x + w
        local t = y + h
        x = math.max(old.x, x)
        y = math.max(old.y, y)
        w = math.max(math.min(old.x + old.z, r) - x, 0)
        h = math.max(math.min(old.y + old.w, t) - y, 0)
    end
    
    clip(x, y, w, h)
    table.insert(clip_stack, vec4(x, y, w, h))
end

function Oil.clipPop()
    table.remove(clip_stack)
    
    -- Re-apply clip
    local len = #clip_stack
    if len > 0 then
        local c = clip_stack[len]
        clip(c.x, c.y, c.z, c.w)
    else
        clip()
    end
end

end
------------------------------
-- OILInput.lua
------------------------------
do
-- Handles all input related stuff in OIL

local touches = {}

local press_duration = 0.4

local StateDown = 0
local StatePress = 1
local StateDrag = 2

local current_time = 0
        
-- Dispatchers
local last_handler = nil
local function dispatch_event(event)
    local handled = false
    
    -- Give the previous handler priority
    if last_handler and last_handler.enabled then
        handled, last_handler = last_handler:handle_event(event)
    end
    
    -- If nothing has handled it so far then pass it to root
    if not handled and Oil.root then
        _, last_handler = Oil.root:handle_event(event)
    end
end


-- Our handlers
function Oil.hover(gesture)
    dispatch_event{
        type = "hover",
        pos = gesture.location
    }
end

-- Convert a scroll gesture into a drag gesture
function Oil.scroll(gesture)
    local pos = gesture.location - gesture.translation
    if gesture.state == BEGAN then
        -- Send raw event
        dispatch_event{
            type = "drag",
            pos = pos,
            delta = gesture.delta,
            state = BEGAN
        }
    elseif gesture.state == CHANGED then
        dispatch_event{
            type = "drag",
            pos = pos,
            delta = gesture.delta,
            state = CHANGED
        } 
    else
        dispatch_event{
            type = "drag",
            pos = pos,
            state = ENDED
        }
    end
end

function Oil.keyboard(key)
    dispatch_event{
        type = "key",
        key = key
    }
end

function Oil.touch(touch)
    -- Get current tracked touch
    local current = touches[touch.id]
    
    -- New touch?
    if touch.state == BEGAN then
        touches[touch.id] = {
            pos = touch.pos,
            time = touch.timestamp,
            state = StateDown
        }
        
        -- Send raw event
        dispatch_event{
            type = "touchdown",
            pos = touch.pos
        }
        
        -- Set the start time
        if current_time == 0 then
            current_time = touch.timestamp
        end
        
    elseif touch.state == CHANGED then
        if current.state ~= StateDrag and current.pos:distSqr(touch.pos) > 25 then
            current.state = StateDrag
            
            dispatch_event{
                type = "drag",
                pos = touch.pos,
                delta = touch.delta,
                state = BEGAN
            }
        end
        
        if current.state == StateDrag then
            dispatch_event{
                type = "drag",
                pos = touch.pos,
                delta = touch.delta,
                state = CHANGED
            }
        end
    else
        dispatch_event{
            type = "touchup",
            pos = touch.pos
        }
        
        -- Dispatch tap/click event?
        if current.state == StateDown and touch.timestamp - current.time < press_duration then
            dispatch_event{
                type = "tap",
                pos = touch.pos,
                is_click = (touch.type == POINTER)
            }
        elseif current.state == StateDrag then
            dispatch_event{
                type = "drag",
                pos = touch.pos,
                state = ENDED
            }
        end
        
        -- Stop tracking this touch
        touches[touch.id] = nil
    end
end

-- Called once per frame to detect long presses
-- without requiring the user to lift their finger
function update_touches()
    if current_time ~= 0 then
        current_time = current_time + DeltaTime
        for _,touch in pairs(touches) do
            if touch.state == StateDown and (current_time - touch.time > press_duration) then
                touch.state = StatePress
                
                dispatch_event{
                    type = "press",
                    pos = touch.pos
                }
            end
        end
    end
end

end
------------------------------
-- Prefabs.lua
------------------------------
do
-- Custom renderers
function Oil.TextRenderer(node, w, h)
    -- Apply styling
    node:apply_style("textFill", fill)
    node:apply_style("font")
    node:apply_style("fontSize")
    node:apply_style("textAlign")
    
    local ww = node:get_style("textWrapWidth")
    if ww <= 1.0 then
        ww = w * ww
    end
    textWrapWidth(ww // 1)
        
    textMode(CORNER)
    local str = node:get_style("text") or ""
    local tw, th = textSize(str)
    
    -- Save the text width & height
    node.state.tw = tw
    node.state.th = th
        
    local align = node:get_style("textAlign")
    if align == CENTER then
        text(str, (w-tw)/2, (h-th)/2)
    elseif align == RIGHT then
        text(str, w-tw, (h-th)/2)
    else
        text(str, 0, (h-th)/2)
    end
end

function Oil.TextRendererResize(node, w, h)
    -- Apply styling
    node:apply_style("textFill", fill)
    node:apply_style("font")
    node:apply_style("fontSize")
    node:apply_style("textAlign")
    
    local ww = node:get_style("textWrapWidth")
    if ww <= 1.0 then
        ww = w * ww
    end
    textWrapWidth(ww // 1)
    
    textMode(CORNER)
    local str = node:get_style("text") or ""
    local tw, th = textSize(str)
    
    -- Resize height
    node.h = th
        
    local align = node:get_style("textAlign")
    if align == CENTER then
        text(str, (w-tw)/2, (h-th)/2)
    elseif align == RIGHT then
        text(str, w-tw, (h-th)/2)
    else
        text(str, 0, (h-th)/2)
    end
end





-- Handlers
function Oil.ButtonHandler(callback, long_press_callback)
    return function(node, event)
        if event.pos == nil then
            return false
        end
        
        if node:covers(event.pos) then
            node.style.fill = node:get_style("fillButtonHover")
            
            if event.type == "touchdown" then
                node.style.fill = node:get_style("fillButtonPressed")
                return true
            elseif event.type == "touchup" then
                node.style.fill = node:get_style("fillButtonNormal")
                return true
            elseif event.type == "tap" then
                node.style.fill = node:get_style("fillButtonNormal")
                if event.is_click then -- mouse clicks leave the cursor
                    node.style.fill = node:get_style("fillButtonHover")
                end
                if callback then callback(node) end
                return true
            elseif event.type == "press" then
                if long_press_callback then long_press_callback(node) end
                return true
            end
        else
            node.style.fill = node:get_style("fillButtonNormal")
        end
    end
end
    
-- Blocks all incoming events that are inside the node
function Oil.TouchBlocker(node, event)
    if node:covers(event.pos) then
        return true
    end
end
        




-- Node constructors
function Oil.Label(x, y, w, h, label, align)
    return Oil.Node(x, y, w, h)
        :add_renderer(Oil.TextRenderer)
        :set_style_sheet(Oil.style_Label)
        :set_style({
            text = label,
            textAlign = align
        })
end

function Oil.LabelResize(x, y, w, h, label, align)
    return Oil.Node(x, y, w, h)
        :add_renderer(Oil.TextRendererResize)
        :set_style_sheet(Oil.style_Label)
        :set_style({
            text = label,
            textAlign = align
        })
end

function Oil.Rect(x, y, w, h, col, radius, blur)
    return Oil.Node(x, y, w, h)
        :add_renderer(Oil.RectRenderer)
        :set_style_sheet(Oil.style_Rect)
        :set_style({
            fill = col,
            radius = radius,
            blur = blur
        })
end

function Oil.Icon(x, y, w, h, texture)
    return Oil.Rect(x, y, w, h)
        :set_style_sheet(Oil.style_Icon)
        :set_style("tex", texture)
end

function Oil.TextButton(x, y, w, h, label, cb, press_cb)
    return Oil.Rect(x, y, w, h)
        :add_handler(Oil.ButtonHandler(cb, press_cb))
        :add_renderer(Oil.TextRenderer)
        :set_style_sheet(Oil.style_TextButton)
        :set_style("text", label)
        :add_updater(function(node)
            if node:get_style("autoResize") then
                if node.state.tw then
                    node.w = node.state.tw + 20
                end
            end
        end)
end

function Oil.EmojiButton(x, y, w, h, emoji, cb, press_cb)
    return Oil.Rect(x, y, w, h)
        :add_handler(Oil.ButtonHandler(cb, press_cb))
        :add_renderer(Oil.TextRenderer)
        :set_style_sheet(Oil.style_EmojiButton)
        :set_style("text", emoji)
end

function Oil.IconButton(x, y, w, h, texture, cb, press_cb)
    return Oil.Icon(x, y, w, h, texture)
        :add_handler(Oil.ButtonHandler(cb, press_cb))
        :set_style_sheet(Oil.style_IconButton)
end

-- Spreads children along it's width
function Oil.HorizontalStack(x, y, w, h)
    return Oil.Node(x, y, w, h)
        :set_style_sheet(Oil.style_HorizontalStack)
        :add_updater(function(node)
            local num_children = #node.children
            local spacing = node:get_style("spacing")
            
            local children_total_width = 0
            for _,child in ipairs(node.children) do
                children_total_width = children_total_width + child.frame.w
            end
            children_total_width = children_total_width + ((spacing or 0) * (num_children-1))
        
            -- Reposition ourself to maintain alignment
            local x = 0
            local align = node:get_style("align")
            if align == RIGHT then
                x = (node.frame.w - children_total_width)
            elseif align == CENTER then
                x = (node.frame.w - children_total_width)/2
            end
        
            -- Reposition children
            for _,child in ipairs(node.children) do
                child.frame.x = x
                x = x + child.frame.w + spacing 
            end
        end)
end

-- Spreads children along it's height.
-- Children must use pixel heights.
function Oil.VerticalStack(x, y, w, h)
    return Oil.Node(x, y, w, h)
        :set_style_sheet(Oil.style_VerticalStack)
        :add_updater(function(node)
            local num_children = #node.children
            local spacing = node:get_style("spacing")
            
            local children_total_height = 0
            for _,child in ipairs(node.children) do
                children_total_height = children_total_height + child.frame.h
            end
            children_total_height = children_total_height + ((spacing or 0) * (num_children-1))
        
            -- Reposition ourself to maintain alignment
            local y = children_total_height
            local align = node:get_style("align")
            if align == TOP then
                y = node.frame.h
            elseif align == CENTER then
                y = (node.frame.h + children_total_height)/2
            end
        
            -- Reposition children
            for _,child in ipairs(node.children) do
                y = y - child.frame.h
                child.frame.y = y
                y = y - spacing
            end
        end)
end

-- Scroll
function Oil.Scroll(x, y, w, h)
    local node = Oil.Node(x, y, w, h)
        :set_style_sheet(Oil.style_Scroll)
        :add_handler(function(node, event)
            if event.type == "drag" then
                if event.state == BEGAN and node:covers(event.pos) then
                    node.scroll_velocity = event.delta / DeltaTime
                    node.scrolling = true
                    return true, node
                elseif event.state == CHANGED and node.scrolling then
                    node.scroll_velocity = event.delta / DeltaTime
                    return true, node
                elseif event.state == ENDED and node.scrolling then
                    node.scrolling = false
                    return true, nil
                end
            elseif node.scrolling then
                return true, node
            end
            return false, nil
        end)
        :add_updater(function(node)
            -- Scroll smoothing
            if node.scrolling then
                node.scroll = node.scroll + node.scroll_velocity*DeltaTime
            elseif node.scroll_velocity then
                node.scroll_velocity = node.scroll_velocity * (1-DeltaTime) * 0.93
                node.scroll = node.scroll + node.scroll_velocity*DeltaTime
            end
            
            -- Detect bounds of children
            local minx, maxx, miny, maxy = math.maxinteger,math.mininteger,math.maxinteger,math.mininteger
            for _,child in ipairs(node.children) do
                minx = math.min(minx, child.frame.x)
                miny = math.min(miny, child.frame.y)
                maxx = math.max(maxx, child.frame.x + child.frame.w)
                maxy = math.max(maxy, child.frame.y + child.frame.h)
            end
     
            -- Default scroll axis is Y
            local axis = node:get_style("scrollAxis")
            
            -- The desired scroll value
            local target = vec2(node.scroll:unpack())
            
            -- Calculate Y Axis scroll
            if (axis & AXIS_Y) == 0 then
                node.scroll.y = 0
                target.y = 0
            else
                maxy = maxy + node:get_style("bufferTop")
                miny = miny - node:get_style("bufferBottom")
                local min_scroll = (node.frame.h - maxy)
                local max_scroll = -miny
                if (maxy-miny) < node.frame.h then
                    target.y = min_scroll
                elseif node.scroll.y < min_scroll then
                    target.y = min_scroll
                elseif node.scroll.y > max_scroll then
                    target.y = max_scroll
                end
            end

            -- Calculate X Axis scroll
            if (axis & AXIS_X) == 0 then
                node.scroll.x = 0
                target.x = 0
            else
                maxx = maxx + node:get_style("bufferLeft")
                minx = minx - node:get_style("bufferRight")
                local min_scroll = (node.frame.w - maxx)
                local max_scroll = -minx
                if (maxx-minx) < node.frame.w then
                    target.x = -min_scroll
                elseif node.scroll.x < min_scroll then
                    target.x = min_scroll
                elseif node.scroll.x > max_scroll then
                    target.x = max_scroll
                end
            end
            
            -- On the first update, we should set the scroll
            -- value directly so scrolling lists aren't animating
            -- when we run the project.
            if node.initial_scroll_done then
                node.scroll = node.scroll + (target - node.scroll)*DeltaTime*10
            else
                node.initial_scroll_done = true
                node.scroll = target
            end
        end)
    
    -- Override draw_children to implement clipping
    function node:draw_children()
        local axis = node:get_style("clipAxis")
        if axis == 0 then
            -- No clip
            Oil.Node.draw_children(self)
            return
        elseif axis == AXIS_X then
            Oil.clip(self.frame.x_raw, 0, self.frame.w, HEIGHT)
        elseif axis == AXIS_Y then
            Oil.clip(0, self.frame.y_raw, WIDTH, self.frame.h)
        elseif axis == AXIS_XY then
            Oil.clip(self.frame.x_raw, self.frame.y_raw, self.frame.w, self.frame.h)
        end
        
        -- Do draw
        Oil.Node.draw_children(self)
        Oil.clipPop()
    end
    
    -- Block events that don't fall within the scroll node
    function node:handle_event(event)
        
        -- Disable
        if not self.enabled then
            return false
        end
        
        -- Pass to children first
        local handled, handler
        
        -- Only pass to children if we're not scrolling & the pos is
        -- within the node.
        if not node.scrolling and ((event.pos == nil) or node:covers(event.pos)) then
            handled, handler = self:children_handle_event(event)
            if handled then return handled, handler end
        end
        
        -- Pass to handler functions
        handled, handler = self:internal_handle_event(event)
        
        -- Return result
        return handled, handler
    end
    
    return node
end

function Oil.Switch(x, y, callback, default)
    local node = Oil.Rect(x, y, 54, 32)
        :set_style_sheet(Oil.style_Switch)
        :add_handler(function(node, event)
            if event.type == "tap" and node:covers(event.pos) then
                node.state.value = not node.state.value
                node.state.changed = true
                if callback then callback(node.state.value) end
                return true
            end
        end)
    
    local handle = Oil.Rect(2, 2, 28, 28)
        :set_style_sheet(Oil.style_SwitchHandle)
    node:add_child(handle)
    
    node:add_updater(function(node)
            if node.state.changed then
                if node.state.tween1 then
                    tween.stop(node.state.tween1)
                    tween.stop(node.state.tween2)
                end
            
                node.state.tween1 = tween(0.15, handle, { x = (node.state.value and 24) or 2 })
            
                local col = (node.state.value and node:get_style("fillOn")) or node:get_style("fillOff")
                node.state.tween2 = tween(0.15, node.style.fill, { r=col.r, g=col.g, b=col.b, a=col.a })
            
                node.state.changed = false
            end
        end)
    
    -- Default values
    node.state.value = default or false
    local col = (node.state.value and node:get_style("fillOn")) or node:get_style("fillOff")
    node.style.fill = color(col.r, col.g, col.b, col.a)
    handle.x = (node.state.value and 24) or 2
    
    return node
end

function Oil.Slider(x, y, w, h, min, max, callback, default)
    local node = Oil.Node(x, y, w, h)
    
    local bar_active = Oil.Rect(0, 0.5, 0, 4)
        :set_style_sheet(Oil.style_Slider)
        :add_updater(function(node)
            node:add_style("fill", node:get_style("fillActive"))
        end)
    
    local handle = Oil.Rect(0, 0.5, 28, 28)
        :set_style_sheet(Oil.style_SliderHandle)
        :add_handler(function(handle, event)
            if event.type == "drag" and (handle:covers(event.pos) or handle.state.dragging == true) then
                if event.state ~= ENDED then
                    local diff = math.min(math.max(0.0, (event.pos.x - node.frame.x_raw)), node.frame.w)
                    local f = diff / node.frame.w
                    handle.state.dragging = true
                    if handle.x ~= f then
                        handle.x = f
                        bar_active.x = f/2
                        bar_active.w = f
                        if callback then callback(min + (max-min)*f) end
                    end
                    return true
                else
                    handle.state.dragging = false
                    return true
                end
            end
        end)
    
    local bar = Oil.Rect(0.5, 0.5, 1.0, 4)
        :set_style_sheet(Oil.style_Slider)
        :add_handler(function(bar, event)
            if event.type == "tap" and node:covers(event.pos) then
                local f = (event.pos.x - bar.frame.x_raw) / bar.frame.w
                if handle.x ~= f then
                    tween(0.15, handle, {x = f})
                    tween(0.15, bar_active, {x = f/2, w = f})
                    if callback then callback(min + (max-min)*f) end
                end
                return true
            end
        end)
    
    node:add_child(bar)
    node:add_child(bar_active)
    node:add_child(handle)
    
    -- Setup initial state
    if default then
        default = (default - min) / (max - min)
        handle.x = default
        bar_active.x = default/2
        bar_active.w = default
    end
    
    return node
end

function Oil.List(x, y, w)
    local node = Oil.VerticalStack(x, y, w, 10)
        :set_style_sheet(Oil.style_List)
        :add_updater(function(node)
            local num_children = #node.children
            local spacing = node:get_style("spacing")
            
            local children_total_height = 0
            for _,child in ipairs(node.children) do
                children_total_height = children_total_height + child.frame.h
            end
            children_total_height = children_total_height + ((spacing or 0) * num_children)
        
            node.frame.y = node.frame.y - children_total_height
            node.frame.h = children_total_height
        end)
    
    return node
end

function Oil.Dropdown(x, y, w, h, label, max_size)
    local ddroot = Oil.Node(x, y, w, h)
    :set_style("text", label)
    
    -- Initialise state
    ddroot.state.open = false
    ddroot.state.tween = nil
    ddroot.state.size = 0
    
    local frame = Oil.Rect(0, 0, 1.0, 1.0)
    local header = Oil.Label(8, -0.0001, -8, h)
    local scroll = Oil.Scroll(0, -h, 1.0, 0)
    local list = Oil.List(0, -0.0001, 1.0, 0)
    local icon = Oil.Label(0, -0.0001, 0, h, "🔽", LEFT)
    
    function ddroot:transition(open)
        -- Cancel the previous animation
        if ddroot.state.tween then
            tween.stop(ddroot.state.tween)
        end
        
        ddroot.state.open = open
        if open then
            -- Set the icon
            icon:set_style("text", "🔼")
            
            -- Force the frame to the same size
            frame.x = frame.frame.x
            frame.w = frame.frame.w
            
            -- Move the frame to the Oil root
            Oil.root:add_child(frame)
            ddroot.state.tween = tween(0.2, ddroot.state, {
                size = math.min(max_size or 300, list.frame.h) -- TODO: use list size in here
            })
        else
            -- Set the icon
            icon:set_style("text", "🔽")
            
            ddroot.state.tween = tween(0.2, ddroot.state, {
                size = 0
            }, nil, function()
                -- Add the frame back to the dropdown root
                Oil.Node.add_child(ddroot, frame)
                frame.x = 0
                frame.y = 0
                frame.w = 1.0
                frame.h = 1.0
                scroll.h = 0
            end)
        end
    end
    
    frame
    :set_priority(1000) -- Over everything (hopefully)
    :set_style_sheet(Oil.style_Dropdown)
    :add_pre_updater(function(node)
        -- While the dropdown is open it needs to be repositioned
        -- to the dropdown root node.
        if frame.parent == Oil.root then
            frame.x = ddroot.frame.x_raw
            frame.y = ddroot.frame.y_raw - ddroot.state.size
            
            -- Prevent the dropdown from going off the bottom
            -- of the screen.
            if frame.y < 0 then
                frame.y = 0
                ddroot.state.size = ddroot.frame.y_raw
            end
            
            -- Resize frame and scroll
            frame.h = ddroot.state.size + h
            scroll.h = ddroot.state.size
        end
    end)
    :add_handler(function(node, event)
        -- Close the dropdown if we do anything outside of
        -- the dropdown.
        if frame.parent == Oil.root then
            if event.pos ~= nil and node:covers(event.pos) then
                return true
            elseif event.type ~= "hover" then
                ddroot:transition(false)
            end
        end
        return false
    end)
    :set_style(ddroot.style)
    
    -- The header controls the state of the dropdown
    header
    :set_style(ddroot.style)
    :set_style_sheet(Oil.style_Dropdown)
    :add_handler(function(node, event)
        if event.type == "tap" and ddroot:covers(event.pos) then
            -- Toggle the state
            ddroot:transition(not ddroot.state.open)
            return true, nil
        end
    end)
    :add_child(icon)
    
    -- Enable scroll clipping
    scroll
    :add_style("clipAxis", AXIS_Y)
    
    scroll:add_child(list)
    frame:add_child(header)
    frame:add_child(scroll)
    ddroot:add_child(frame)
    
    function ddroot:add_child(child)
        list:add_child(child)
        return self
    end
    
    function ddroot:add_children(...)
        list:add_children(...)
        return self
    end
    
    return ddroot
end

function Oil.TextEntry(x, y, w, h, default_text, callback)
    local node = Oil.Rect(x, y, w, h)
    local scroll = Oil.Scroll(0, 0, 1.0, 1.0)
    local textbox = Oil.Node(0, -0.0001, 1.0, 100)
    
    node:add_style("text", default_text or "")
    node:set_style_sheet(Oil.style_TextEntry)
    scroll:set_style_sheet(Oil.style_TextEntry)
    
    -- Stores character position info
    local char_info = {}
    node.state.char_info_requires_update = true
    local cursor_index = 1
    
    -- Keeps the cursor within frame
    local function goto_cursor(font_size)
        
        -- Do nothing if empty string
        if #char_info == 0 then
            return
        end
        
        local info = char_info[cursor_index]
        
        -- Convert the cursor coord into text entry coords
        local y = info[2] - (textbox.h - scroll.frame.h) + scroll.scroll.y
        
        -- Snap the scroll y value if required to move the cursor into view
        if y < 0 then
            scroll.scroll.y = scroll.scroll.y - y
        elseif y > (scroll.frame.h - font_size) then
            scroll.scroll.y = scroll.scroll.y - (y-(scroll.frame.h - font_size))
        end
    end
    
    -- Apply inset values
    scroll:add_pre_updater(function(_)
        local inset = node:get_style("textEntryInset") or 5
        scroll.x = inset
        scroll.y = inset
        scroll.w = ((inset > 0) and -inset) or 1.0
        scroll.h = scroll.w
    end)
    
    -- Calculate character positions
    textbox:add_pre_updater(function(_)
        if node.state.char_info_requires_update then
            node.state.char_info_requires_update = false
            
            -- Set text parameters
            local font_size = node:get_style("fontSize")
            node:apply_style("font", font)
            fontSize(font_size)
            
            -- Clear old char info
            char_info = {}
            
            -- Add terminator so we can place the cursor
            -- at the end of the final line.
            local str = node:get_style("text") .. "\0"
            
            -- Position chars
            local x, y, cw = 0, -font_size
            for c in str:gmatch(".") do
                cw, _ = textSize(c)
                
                -- Wrap or newline?
                if x + cw > scroll.frame.w then
                    x = 0
                    y = y - font_size
                end
                
                -- Add the char info
                table.insert(char_info, {x, y, cw/2})
                
                -- Account for newlines
                if c == "\n" then
                    x = 0
                    y = y - font_size
                else
                    x = x + cw
                end
            end
            
            -- Resize the text box and adjust char positions
            textbox.h = -y
            for i,v in ipairs(char_info) do
                v[2] = v[2] - y
            end
            
            goto_cursor(font_size)
        end
    end)
    
    -- Rendering goes here
    textbox:add_renderer(function(_, w, h)
        local str = node:get_style("text")
        node:apply_style("textFill", fill)
        node:apply_style("font", font)
        local font_size = node:get_style("fontSize")
        fontSize(font_size)
        
        -- Use corner mode
        textMode(CORNER)
        
        -- Draw the text one character at a time
        for i,info in ipairs(char_info) do
            local c = str:sub(i,i)
            text(c, info[1], info[2])
        end
        
        -- Draw the cursor
        local blink = node:get_style("cursorBlink")
        if node.state.focus and (not blink or (blink and (ElapsedTime % 1.5) <= 0.75)) then
            node:apply_style("textFill", stroke)
            node:apply_style("cursorWidth", strokeWidth)
            lineCapMode(ROUND)
            local info = char_info[cursor_index]
            line(info[1], info[2], info[1], info[2] + font_size)
        end
    end)
    
    -- Moves the cursor index to the nearest suitable
    -- position
    local function move_cursor(pos)
        -- Get position in char_info coord-space
        pos = pos - vec2(scroll.frame.x_raw, scroll.frame.y_raw) - scroll.scroll
        pos = pos + vec2(textbox.frame.w - scroll.frame.w, textbox.frame.h - scroll.frame.h)
        
        -- Are we above the top row?
        if pos.y >= textbox.h then
            cursor_index = 1
            return
        end
        
        -- Are we below the bottom row?
        if pos.y < 0 then
            cursor_index = #char_info
            return
        end
        
        local font_size = node:get_style("fontSize")
        
        -- Find nearest char
        local last_half_width = 0
        local found_row = false
        for i,info in ipairs(char_info) do
            -- Are we on the correct row?
            if pos.y < (info[2] + font_size) and pos.y >= info[2] then
                -- Correct character?
                if pos.x < info[1] + info[3] and pos.x >= info[1] - last_half_width then
                    cursor_index = i
                    return
                end
                last_half_width = info[3]
                found_row = true
                
            -- If we fail to find a char on the same row,
            -- go to the end of that row.
            elseif found_row then
                cursor_index = (i-1)
                return
            end
        end
        
        -- Move to last char as we didn't find it in our iteration
        cursor_index = #char_info
    end
    
    node:add_handler(function(_, event)
        if event.type == "tap" and node:covers(event.pos) then
            showKeyboard()
            node.state.focus = true
            move_cursor(event.pos)
            node:set_style("stroke", node:get_style("strokeFocus"))
            
            -- If the software keyboard is shown then we want to move the
            -- text box above it.
            -- DISABLED for now as isKeyboardShowing() doesn't accomodate this.
            if isKeyboardShowing() and node.frame.y_raw < HEIGHT/2 then
                --Oil.root.scroll.y = (HEIGHT/2) - node.frame.y_raw
            end
            return true, node
        end
        
        if event.type ~= "hover" and event.pos and not node:covers(event.pos) then
            hideKeyboard()
            node.state.focus = false
            Oil.root.scroll.y = 0
            node:set_style("stroke", node:get_style("strokeNoFocus"))
            return false
        end
        
        if node.state.focus and event.type == "key" then
            local str = node:get_style("text")
            
            if event.key == BACKSPACE then
                if cursor_index == 1 then
                    return true, node
                end
                
                -- Delete the char
                node:set_style("text", str:sub(0,cursor_index-2) .. str:sub(cursor_index, -1))
                
                -- Move cursor backwards
                cursor_index = cursor_index - 1
            else
                -- Insert the char
                node:set_style("text", str:sub(0,cursor_index-1) .. event.key .. str:sub(cursor_index, -1))
                
                -- Move cursor along
                cursor_index = cursor_index + 1
            end
            
            -- Trigger the callback when we make an edit
            if callback then callback(node:get_style("text")) end
            
            -- Update the char info
            node.state.char_info_requires_update = true
            return true, node
        end
    end)
    
    scroll:add_child(textbox)
    node:add_child(scroll)
    
    return node
end

function Oil.Alert(msg, cb, style_sheet, style_sheet_button)
    local root = Oil.Rect(0, 0, 1.0, 1.0)
    :set_priority(100) -- over everything
    :add_style("fill", color(0, 128)) --darken the background
    
    root:add_child(
        Oil.Rect(0.5, 0.5, 370, 300)
        :set_style_sheet(style_sheet or Oil.style_Alert)
        :add_handler(function(node, event)
            return true
        end)
        :add_children(
            Oil.Label(5, 50, 360, 245, msg)
            :add_style("textWrapWidth", 360)
            :set_style_sheet(style_sheet or Oil.style_Alert),
    
            Oil.TextButton(5, 5, 177.5, 40, "NO", function() cb(false) root:kill() end)
            :set_style_sheet(style_sheet_button or Oil.style_TextButton),
    
            Oil.TextButton(-5, 5, 177.5, 40, "YES", function() cb(true) root:kill() end)
            :set_style_sheet(style_sheet_button or Oil.style_TextButton)
        )
    )
end

end
------------------------------
-- StyleSheets.lua
------------------------------
do
Oil.style_default = {
    -- General settings
    fill = color(128),
    stroke = color(255),
    strokeWidth = 0,
    spacing = 10,
    align = CENTER,
    
    -- Rectangle settings
    radius = 0,
    shadow = false,
    shadowWidth = 10,
    shadowIntensity = 1.0,
    
    -- Text settings
    font = "Helvetica",
    fontSize = 17,
    textAlign = CENTER,
    textFill = color(0),
    text = "<undefined>",
    textWrapWidth = 0,
    autoResize = false,
    
    -- Blur settings
    blur = false,
    blur_once = false,
    blur_amount = 1.0,
    blur_kernel_size = 16,
    blur_downscale = 0.5,
    
    -- Button presets
    fillButtonNormal = color(255),
    fillButtonHover = color(255),
    fillButtonPressed = color(255),
    
    -- Scroll settings
    clipAxis = AXIS_NONE,
    scrollAxis = AXIS_Y,
    bufferTop = 0,
    bufferBottom = 0,
    bufferLeft = 0,
    bufferRight = 0,
    
    -- Text Entry settings
    cursorWidth = 2,
    cursorBlink = true,
    textEntryInset = 5,
    strokeFocus = color(0, 137, 255),
    strokeNoFocus = color(255)
}

Oil.style_Label = {    
    -- Text
    text = "<undefined>",
    textAlign = CENTER,
    textFill = color(255),
    font = "Helvetica",
    fontSize = 17
}

Oil.style_Rect = {
    -- General
    fill = color(200),
    stroke = color(255),
    strokeWidth = 0,
    
    -- Rect
    radius = 0,
    
    -- Blur
    blur = false,
    blur_amount = 1.0,
    blur_kernel_size = 16,
    blur_downscale = 0.5
}

Oil.style_Icon = {
    -- General
    fill = color(255),
    stroke = color(255),
    strokeWidth = 0,
    
    -- Rect
    radius = 0,
    
    -- Blur
    blur = false,
    blur_amount = 1.0,
    blur_kernel_size = 16,
    blur_downscale = 0.5,
}

Oil.style_TextButton = {
    -- General settings
    fill = color(50, 150, 220),
    stroke = color(255),
    strokeWidth = 2,
    
    -- Rectangle settings
    radius = 15,
    
    -- Text settings
    font = "Helvetica",
    fontSize = 17,
    textAlign = CENTER,
    textFill = color(255),
    
    -- Button presets
    fillButtonNormal = color(50, 150, 220),
    fillButtonHover = color(144, 184, 213),
    fillButtonPressed = color(82, 119, 221),
}

Oil.style_EmojiButton = {
    -- General settings
    fill = color(50, 150, 220),
    stroke = color(255),
    strokeWidth = 2,
    
    -- Rectangle settings
    radius = 12,
    
    -- Text settings
    font = "Helvetica",
    fontSize = 32,
    textAlign = CENTER,
    textFill = color(255),
    
    -- Button presets
    fillButtonNormal = color(50, 150, 220),
    fillButtonHover = color(144, 184, 213),
    fillButtonPressed = color(82, 119, 221),
}

Oil.style_IconButton = {
    -- General settings
    fill = color(255),
    strokeWidth = 2,
    
    -- Rectangle settings
    radius = 12,
    
    -- Button presets
    fillButtonNormal = color(255),
    fillButtonHover = color(220),
    fillButtonPressed = color(180),
}

Oil.style_HorizontalStack = {
    spacing = 10,
    align = CENTER
}

Oil.style_VerticalStack = {
    spacing = 10,
    align = CENTER
}

Oil.style_Scroll = {
    clipAxis = AXIS_NONE,
    scrollAxis = AXIS_Y,
    bufferTop = 0,
    bufferBottom = 0,
    bufferLeft = 0,
    bufferRight = 0
}

Oil.style_Switch = {
    fill = color(128),
    fillOn = color(19, 207, 82),
    fillOff = color(128),
    radius = 16
}

Oil.style_SwitchHandle = {
    fill = color(230),
    radius = 14
}

Oil.style_Slider = {
    fill = color(196),
    fillActive = color(0, 118, 255),
    strokeWidth = 0,
    radius = 2
}

Oil.style_SliderHandle = {
    fill = color(230),
    strokeWidth = 1,
    radius = 14,
    shadow = true,
    shadowWidth = 10,
    shadowIntensity = 0.5
}

Oil.style_List = {
    spacing = 10,
    align = TOP
}

Oil.style_Dropdown = {
    -- General settings
    fill = color(50, 150, 220),
    stroke = color(255),
    strokeWidth = 2,
    
    -- Rectangle settings
    radius = 12,
    
    -- Text settings
    font = "Helvetica",
    fontSize = 17,
    textAlign = CENTER,
    textFill = color(255),
    
    -- Button presets
    fillButtonNormal = color(50, 150, 220),
    fillButtonHover = color(144, 184, 213),
    fillButtonPressed = color(82, 119, 221),
}

Oil.style_TextEntry = {
    -- General settings
    fill = color(210),
    stroke = color(105, 133, 156),
    strokeWidth = 3,
    
    -- Rectangle settings
    radius = 8,
    
    -- Text settings
    font = "Helvetica",
    fontSize = 20,
    textFill = color(32),
    
    -- Scroll settings
    clipAxis = AXIS_Y,
    
    -- Text Entry settings
    cursorWidth = 2,
    cursorBlink = true,
    textEntryInset = 7,
    strokeFocus = color(0, 137, 255),
    strokeNoFocus = color(105, 133, 156)
}

Oil.style_Alert = {
    -- General
    fill = color(200),
    stroke = color(255),
    strokeWidth = 0,
    
    -- Rect
    radius = 15,
    
    -- Blur
    blur = false,
    blur_amount = 1.0,
    blur_kernel_size = 16,
    blur_downscale = 0.5
}

end
------------------------------
-- Node.lua
------------------------------
do
Oil.Node = class()

local root_frame = {
    x = 0, y = 0, w = WIDTH, h = HEIGHT,
    x_raw = 0, y_raw = 0
}

-- Calculates a pixel pos + size
local function parsePosSize(pos, size, parent_size)
    if size >= 0 then
        if size <= 1.0 then -- Proportional size
            size = parent_size * size
        end
        
        if pos < 0 then -- far edge offset
            pos = (parent_size + pos) - size
        elseif pos < 1 and pos > 0 then -- Proportional pos
            pos = (parent_size * pos) - size/2
        end
    else -- negative size (far edge offset)
        if pos < 0 then -- far edge offset
            pos = parent_size + pos
        elseif pos <= 1.0 then -- Proportional pos
            pos = parent_size * pos
        end
        
        -- Normalise to 0 - parent_size
        size = parent_size + size
        
        -- Get final size
        size = math.max(size - pos, 0)
    end
    return pos, size
end

function Oil.Node:init(x, y, w, h, priority)
    -- General values
    self.x = x or 0.5
    self.y = y or 0.5
    self.w = w or 1.0
    self.h = h or 1.0
    self.scroll = vec2(0,0)
    
    -- Default priority
    self.priority = priority or 0
    
    -- Enabled and displayed by default
    self.enabled = true
    self.hidden = false
    
    -- Empty state table
    self.state = {}
    
    -- Default style sheet
    self.style_sheet = Oil.style_default
    self.style = {}
    
    -- Empty frame until first update
    self.frame = {}
    
    -- Empty component lists
    self.pre_updaters = {}
    self.updaters = {}
    self.renderers = {}
    self.handlers = {}
    
    -- Empty children list
    self.children = {}
    
    -- When priorities are the same, children are
    -- sorted based on child indices instead so
    -- children added first are updated and drawn
    -- first
    self.next_child_index = 0
    self.child_index = 0
    
    -- Child of root by default (root uses nil)
    if Oil.root then
        Oil.root:add_child(self)
    end
    
    -- Calculate an initial frame
    self:calculate_frame()
    self:calculate_frame_raw()
end

-- Called once per frame (when enabled)
--
-- Pre Update runs from leaf nodes up to the root.
-- Use pre-update to adjust node frame sizes & positions
-- based on children only.
--
-- Do not base changes on parent values
function Oil.Node:update()
    
    -- Abort if disabled
    if not self.enabled then
        return
    end
    
    -- Run pre-updaters.
    -- We do this in reverse order so additional updaters
    -- added to prefabs are run first.
    for i = #self.pre_updaters, 1, -1 do
        self.pre_updaters[i](self)
    end
    
    -- Calculate render frame
    self:calculate_frame()
    
    -- Re-sort the children
    self:sort_children()
    
    -- Pre-Update children
    for _,child in ipairs(self.children) do
        child:update()
    end
    
    -- Run updaters.
    -- We do this in reverse order so additional updaters
    -- added to prefabs are run first.
    for i = #self.updaters, 1, -1 do
        self.updaters[i](self)
    end
end
    
-- Called once per frame (when enabled)
--
-- Update runs from the root node down to leaf nodes
-- Use pre-update to adjust node frame sizes
function Oil.Node:post_update()
    
    -- Abort if disabled
    if not self.enabled then
        return
    end
    
    -- Calculate raw frame position
    self:calculate_frame_raw()
    
    -- Update children
    for _,child in ipairs(self.children) do
        child:post_update()
    end
end

-- Called once per frame (when enabled & visible)
function Oil.Node:draw()
    
    -- Abort if disabled or hidden
    if self.hidden or not self.enabled then
        return
    end
    
    -- Translate
    pushMatrix()
    translate(self.frame.x, self.frame.y)
    
    -- Draw own renderers
    for _,renderer in ipairs(self.renderers) do
        renderer(self, self.frame.w, self.frame.h)
    end
    
    -- Translate children for scrolling
    translate(self.scroll.x, self.scroll.y)
    
    -- Draw children
    self:draw_children()
    
    -- Revert translate
    popMatrix()
end

-- Draws the node children
-- (can be overridden for custom clipping)
function Oil.Node:draw_children()
    for _,child in ipairs(self.children) do
        child:draw()
    end
end

-- Handle an event
function Oil.Node:handle_event(event)
    
    -- Ignore event if disabled
    if not self.enabled then
        return false
    end
    
    -- Pass to children first
    local handled, handler = self:children_handle_event(event)
    if handled then return handled, handler end
    
    -- Pass to handler functions
    handled, handler = self:internal_handle_event(event)
    
    -- Return result
    return handled, handler
end

function Oil.Node:internal_handle_event(event)
    for _,handler in ipairs(self.handlers) do
        handled, handler = handler(self, event)
        if handled then
            return handled, handler
        end
    end
end

function Oil.Node:children_handle_event(event)
    for i = #self.children, 1, -1 do
        local child = self.children[i]
        local handled, handler = child:handle_event(event)
        if handled then
            return handled, handler
        end
    end
end

function Oil.Node:calculate_frame()
    
    -- Root node uses the precalculated root frame
    if self.parent == nil then
        self.frame = root_frame
        self.frame.w = WIDTH
        self.frame.h = HEIGHT
        return
    end
    
    local parent = self.parent.frame
    
    -- Calculate our current frame
    self.frame.x, self.frame.w = parsePosSize(self.x, self.w, parent.w)
    self.frame.y, self.frame.h = parsePosSize(self.y, self.h, parent.h)
end

function Oil.Node:calculate_frame_raw()
    
    -- Root node uses the precalculated root frame
    if self.parent == nil then
        self.frame.x_raw = 0
        self.frame.y_raw = 0
        return
    end
    
    local parent = self.parent.frame
    
    -- Raw pos (absolute screen pos)
    self.frame.x_raw = self.frame.x + parent.x_raw + self.parent.scroll.x
    self.frame.y_raw = self.frame.y + parent.y_raw + self.parent.scroll.y
end

function Oil.Node:covers(pos)
    return  pos.x >= self.frame.x_raw and
            pos.x <= self.frame.x_raw + self.frame.w and
            pos.y >= self.frame.y_raw and
            pos.y <= self.frame.y_raw + self.frame.h
end

function Oil.Node:set_style(style_or_key, value)
    if value ~= nil then
        self.style[style_or_key] = value
    elseif style_or_key ~= nil then
        self.style = style_or_key
    else
        self.style = {}
    end
    return self
end

function Oil.Node:add_style(style_or_key, value)
    if value ~= nil then 
        self.style[style_or_key] = value
    else
        for k,v in pairs(style_or_key) do
            self.style[k] = v
        end
    end
    return self
end

function Oil.Node:set_style_sheet(style_sheet)
    self.style_sheet = style_sheet
    return self
end

function Oil.Node:get_style(key)
    local style = self.style[key]
    if style ~= nil then
        return style
    end
    
    style = self.style_sheet[key]
    if style ~= nil then
        return style
    end
    
    return Oil.style_default[key]
end

-- Retrieves the style value for key and passes
-- it to the provided function or a global function
-- of the same name.
function Oil.Node:apply_style(key, func)
    local v = self:get_style(key)
    assert(v ~= nil, "No style value for key: " .. key)
    
    if func then
        -- Call the func we're given
        func(v)
    else
        -- Call global function by the same name
        _G[key](v)
    end
end

function Oil.Node:set_priority(p)
    self.priority = p
    
    -- Resort
    self.parent:sort_children()
    return self
end

function Oil.Node:add_child(child, sort)
    -- Remove from previous parent
    if child.parent then
        child.parent:remove_child(child)
    end
    
    -- Add child
    table.insert(self.children, child)
    child.parent = self
    
    -- Set child index
    child.child_index = self.next_child_index
    self.next_child_index = self.next_child_index + 1
    
    if sort == nil or sort then
        self:sort_children()
    end
    return self
end

function Oil.Node:add_children(...)
    for _,child in ipairs({...}) do
        self:add_child(child, false)
    end
    self:sort_children()
    return self
end

-- Registers the function 'updater' as an update function
-- that will be called every frame (when the node is enabled)
-- Pre-Updaters are called before calculating the frame.
function Oil.Node:add_pre_updater(updater)
    table.insert(self.pre_updaters, updater)
    return self
end

-- Registers the function 'updater' as an update function
-- that will be called every frame (when the node is enabled)
function Oil.Node:add_updater(updater)
    table.insert(self.updaters, updater)
    return self
end

-- Registers the function 'renderer' as a render function
-- that will be called every frame (when the node is enabled & displayed on-screen)
function Oil.Node:add_renderer(renderer)
    table.insert(self.renderers, renderer)
    return self
end

-- Registers the function 'handler' as an event handler
-- for this node
function Oil.Node:add_handler(handler)
    table.insert(self.handlers, handler)
    return self
end

-- Removes a child from this node
function Oil.Node:remove_child(child)
    for i,v in ipairs(self.children) do
        if v == child then
            table.remove(self.children, i)
            child.parent = nil -- No parent now
            return
        end
    end
end

-- Removes a pre-updater from this node
function Oil.Node:remove_pre_updater(updater)
    for i,v in ipairs(self.pre_updaters) do
        if v == updater then
            table.remove(self.pre_updaters, i)
            return
        end
    end
end

-- Removes an updater from this node
function Oil.Node:remove_updater(updater)
    for i,v in ipairs(self.updaters) do
        if v == updater then
            table.remove(self.updaters, i)
            return
        end
    end
end

-- Removes an renderer from this node
function Oil.Node:remove_renderer(renderer)
    for i,v in ipairs(self.renderers) do
        if v == renderer then
            table.remove(self.renderers, i)
            return
        end
    end
end

-- Removes a handler from this node
function Oil.Node:remove_handler(handler)
    for i,v in ipairs(self.handlers) do
        if v == handler then
            table.remove(self.handlers, i)
            return
        end
    end
end

-- Sorts the children according to priority
function Oil.Node:sort_children()
    table.sort(self.children, function(a,b)
        if a.priority == b.priority then
            return a.child_index < b.child_index
        end
        return a.priority < b.priority
    end)
end

-- Removes the node from its parent.
-- Use this to delete nodes
function Oil.Node:kill()
    self.parent:remove_child(self)
end

-- Sets the debug name
function Oil.Node:set_debug_name(name)
    self.debug_name = name
    return self
end

-- Gets a debug name if it's available
function Oil.Node:get_debug_name()
    return self.debug_name or "unnamed"
end

end
------------------------------
-- RectRenderer.lua
------------------------------
do
-- Rect renderer utilising Signed Distance Fields
-- in order to avoid the need for multiple meshes

local blank_image = image(1,1)
blank_image:set(1,1,color(255))

local shader_src = {
    vert = [[
        uniform mat4 modelViewProjection;

        attribute vec2 position;
        attribute vec2 texCoord;
        
        varying highp vec2 vUV;
        
        void main()
        {
            vUV = texCoord;
            gl_Position = modelViewProjection * vec4(position.xy, 0.0, 1.0);
        }
    ]],
    frag = [[
        precision highp float;
    
        uniform lowp sampler2D texture;
        uniform vec2 rectSize;
        uniform vec4 fill;
        uniform vec4 stroke;
        uniform float radius;
        uniform float strokeWidth;
        uniform bool shadow;
        uniform float shadowWidth;
        uniform float shadowIntensity;
        
        varying highp vec2 vUV;
    
        float RectSDF(vec2 p, vec2 b, float r)
        {
            vec2 d = abs(p) - b + vec2(r);
            return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - r;
        }
        
        void main() 
        {
            vec2 pos = rectSize * vUV;
    
            if (shadow)
            {
                float fDist = RectSDF(pos-rectSize/2.0, rectSize/2.0, radius + shadowWidth);
                gl_FragColor = vec4(vec3(0.0), smoothstep(0.0, 1.0, (-fDist/(shadowWidth*2.0))) * shadowIntensity);
            }
            else
            {
                float fDist = RectSDF(pos-rectSize/2.0, rectSize/2.0, radius);
                
                // Not great from an optimisation standpoint I know, but
                // it looks great.
                if (fDist > -0.5)
                {
                    vec4 from = (strokeWidth > 0.0) ? stroke : texture2D(texture, vUV) * fill;
                    gl_FragColor = mix(from, vec4(from.rgb, 0.0), smoothstep(0.0, 1.0, abs(fDist+0.5)));
                }
                else
                {
                    float fBlendAmount = (strokeWidth > 0.0) ? smoothstep(0.0, 1.0, abs(fDist) - strokeWidth/2.0) : 1.0;
                    gl_FragColor = mix(stroke, texture2D(texture, vUV) * fill, fBlendAmount);
                }
            }
        }
    ]],
}

local coords = {
    vec2(0, 0),
    vec2(1, 0),
    vec2(1, 1),
    vec2(0, 0),
    vec2(1, 1),
    vec2(0, 1),
}
local rmesh = mesh()
rmesh.vertices = coords
rmesh.texCoords = coords
rmesh.shader = shader(shader_src.vert, shader_src.frag)

function Oil.RectRenderer(node, w, h)
    -- Do blur effect
    if node:get_style("blur") then
        if node:get_style("blur_once") and node.state.blur_tex then
            -- Don't update the blur. It's only done once
        else
            node.state.blur_tex = node.state.blur_tex or Oil.BlurTexture(node:get_style("blur_amount"), node:get_style("blur_kernel_size"), node:get_style("blur_downscale"))
            node.state.blur_tex:update(Oil.fb, node.frame)
            node.style.tex = node.state.blur_tex:get()
        end
    elseif node.state.blur_tex then
        -- Ensure the blur textures can be freed
        node.style.tex = nil
        node.state.blur_tex = nil
    end
    
    -- Setup uniforms
    rmesh.shader.texture = node:get_style("tex") or blank_image
    rmesh.shader.fill = node:get_style("fill")
    rmesh.shader.stroke = node:get_style("stroke")
    rmesh.shader.strokeWidth = node:get_style("strokeWidth")
    rmesh.shader.radius = node:get_style("radius")
    
    -- Draw shadow
    if node:get_style("shadow") then
        local shadowWidth = node:get_style("shadowWidth")
        rmesh.shader.rectSize = vec2(w + shadowWidth*2, h + shadowWidth*2)
        rmesh.shader.shadow = true
        rmesh.shader.shadowWidth = shadowWidth
        rmesh.shader.shadowIntensity = node:get_style("shadowIntensity")
        pushMatrix()
        translate(-shadowWidth, -shadowWidth)
        scale(w+shadowWidth*2, h+shadowWidth*2)
        rmesh:draw()
        popMatrix()
    end
    
    -- Draw Rect
    rmesh.shader.rectSize = vec2(w, h)
    rmesh.shader.shadow = false
    pushMatrix()
    scale(w, h)
    rmesh:draw()
    popMatrix()
end

end
------------------------------
-- Blur.lua
------------------------------
do
-- Blur

Oil.BlurTexture = class()

local blur_shader_src = {
    vert = [[
        uniform mat4 modelViewProjection;

        attribute vec2 position;
        attribute vec2 texCoord;
    
        uniform vec4 uv_offset_scale;
    
        varying highp vec2 vUV;
        
        void main()
        {
            vUV = (texCoord * uv_offset_scale.zw) + uv_offset_scale.xy;
            gl_Position = modelViewProjection * vec4(position, 0.0, 1.0);
        }
    ]],
    frag = [[
        precision highp float;

        uniform lowp sampler2D texture;
        uniform vec2 scale;
    
        uniform vec3 kernel[%d];
    
        varying highp vec2 vUV;

        vec4 blur(sampler2D image, vec2 uv) {
            vec4 color = vec4(0.0);
            for (int i = 0; i < %d; ++i) {
                color += texture2D(image, uv + (kernel[i].xy * scale)) * kernel[i].z;
            }
            return color;
        }
        
        void main()
        {
            gl_FragColor = blur(texture, vUV);
        }
    ]],
}

local shaders = {}
local function get_shader(kernel_size)
    if shaders[kernel_size] then -- Get from cache
        return shaders[kernel_size]
    end
    
    -- TODO: Support removal from the cache
    local frag_src = string.format(blur_shader_src.frag, kernel_size, kernel_size)
    shaders[kernel_size] = shader(blur_shader_src.vert, frag_src)
    return shaders[kernel_size]
end

local function gauss(x, sd)
    local a = 1 / (math.sqrt(math.pi * 2) * sd)
    local b = math.exp(-((x*x)/(2*(sd*sd))))
    return a * b
end

local function gauss_dist(size)
    -- Standard deviation
    local sd = size / 3.0
    
    -- Generate our distribution
    local dist = {}
    local acc = 0
    for x = -size, size do
        local g = gauss(x, sd)
        acc = acc + g
        table.insert(dist, g)
    end
    
    -- Normalise
    for i = 1, (1+size*2) do
        dist[i] = dist[i] / acc
    end
    
    return dist
end

local function gauss_kernel(dir, step, size)
    local dist_size = (size // 2)
    local dist = gauss_dist(dist_size)
    
    local kernel = {}
    local step = dir * step
    local c = -step*dist_size
    for i = 1, size do
        local v = vec3(c.x, c.y, dist[i])
        table.insert(kernel, v)
        c = c + step
    end
    
    return kernel
end

function Oil.BlurTexture:init(blur_factor, kernel_size, downscale)
    self.blur_kernel_horz = gauss_kernel(vec2(1.0, 0.0), 0.001 * (blur_factor or 1.0), kernel_size or 16)
    self.blur_kernel_vert = gauss_kernel(vec2(0.0, 1.0), 0.001 * (blur_factor or 1.0), kernel_size or 16)
    self.shader = get_shader(kernel_size or 16)
    self.downscale = downscale or 0.5
    self.textures = {}
    self.mesh = {}
    
    self.tex_w = 0
    self.tex_h = 0
end

function Oil.BlurTexture:update(src_tex, src_frame)
    local src_w, src_h = src_tex.width, src_tex.height
    local texw, texh = (src_frame.w * self.downscale), (src_frame.h * self.downscale)
    
    -- Generate new blur textures
    if self.tex_w ~= src_frame.w or self.tex_h ~= src_frame.h or self.src_tex ~= src_tex then
        self.textures[1] = image(texw, texh)
        self.textures[2] = image(texw, texh)
        
        local coords = {
            vec2(0, 0),
            vec2(1, 0),
            vec2(1, 1),
            vec2(0, 0),
            vec2(1, 1),
            vec2(0, 1)
        }
        
        -- Horizontal pass
        self.mesh = mesh()
        self.mesh.shader = self.shader
        self.mesh.vertices = coords
        self.mesh.texCoords = coords
            
        -- Save size for quick reference
        self.tex_w = src_frame.w
        self.tex_h = src_frame.h
        
        -- Save texture source
        self.src_tex = src_tex
    end
    
    pushStyle()
    pushMatrix()
    resetMatrix()
    
    -- Scale the mesh
    scale(texw, texh)
    
    -- Textures need to be interpolated
    smooth()
    
    -- Horz pass
    setContext(self.textures[1])
    self.shader.scale = vec2(src_h/src_w, 1.0)
    self.shader.uv_offset_scale = vec4(src_frame.x_raw/src_w, src_frame.y_raw/src_h, src_frame.w/src_w, src_frame.h/src_h)
    self.shader.texture = src_tex
    self.shader.kernel = self.blur_kernel_horz
    self.mesh:draw()
    
    -- Vert pass
    setContext(self.textures[2])
    self.shader.scale = vec2(1.0, src_h/src_frame.h)
    self.shader.uv_offset_scale = vec4(0,0,1,1)
    self.shader.texture = self.textures[1]
    self.shader.kernel = self.blur_kernel_vert
    self.mesh:draw()
    
    -- Restore framebuffer
    setContext(Oil.fb)
    popMatrix()
    popStyle()
end
    
function Oil.BlurTexture:get()
    return self.textures[2] or nil
end

end
