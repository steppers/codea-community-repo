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
    local header = Oil.Label(0, -0.0001, 1.0, h)
    local scroll = Oil.Scroll(0, -h, 1.0, 0)
    local list = Oil.List(0, -0.0001, 1.0, 0)
    local icon = Oil.Label(8, 0.5, 0, 0, "🔽", LEFT)
    
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
