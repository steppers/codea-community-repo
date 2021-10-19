-- Custom renderers
function Oil.TextRenderer(node, w, h)
    -- Apply styling
    node:apply_style("textFill", fill)
    node:apply_style("font")
    node:apply_style("fontSize")
        
    textMode(CORNER)
    local str = node:get_style("text") or ""
    local tw, th = textSize(str)
        
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
                if callback then callback() end
                return true
            elseif event.type == "press" then
                if long_press_callback then long_press_callback() end
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
                if callback then callback(node, node.state.value) end
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
            elseif event.type == "touchup" and handle.state.dragging == true then
                handle.state.dragging = false
                return true
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
    
    local frame = Oil.Rect(0, 0, w, h)
    local header = Oil.Label(0, -0.0001, w, h)
    local scroll = Oil.Scroll(0, -h, 1.0, 0)
    local list = Oil.List(0, -0.0001, 1.0, 0)
    local icon = Oil.Label(8, 0.5, 0, 0, "🔽", LEFT)
    
    local function transition(open)
        -- Cancel the previous animation
        if ddroot.state.tween then
            tween.stop(ddroot.state.tween)
        end
        
        ddroot.state.open = open
        if open then
            -- Set the icon
            icon:set_style("text", "🔼")
            
            -- Move the frame to the Oil root
            Oil.root:add_child(frame)
            ddroot.state.tween = tween(0.2, ddroot.state, {
                size = math.min(300, list.frame.h) -- TODO: use list size in here
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
                frame.h = h
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
                transition(false)
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
            transition(not ddroot.state.open)
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
