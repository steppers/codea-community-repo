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

function Oil.ScrollHandler(node, event)
    if node:covers(event.pos) or node.scrolling then
        if event.type == "touchup" then
            node.scrolling = false
        elseif event.type == "drag" then
            node.scrolling = true
            node.scroll_velocity = event.delta / DeltaTime
        end
            
        return true
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
function Oil.HorizontalSpreader(x, y, w, h)
    return Oil.Node(x, y, w, h)
        :set_style_sheet(Oil.style_HorizontalSpreader)
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
function Oil.VerticalSpreader(x, y, w, h)
    return Oil.Node(x, y, w, h)
        :set_style_sheet(Oil.style_VerticalSpreader)
        :add_updater(function(node)
            local num_children = #node.children
            local spacing = node:get_style("spacing")
            
            local children_total_height = 0
            for _,child in ipairs(node.children) do
                children_total_height = children_total_height + child.h
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
        :add_handler(Oil.ScrollHandler)
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
            local axis = (node:get_style("scrollAxis") or AXIS_Y)
            
            -- The desired scroll value
            local target = vec2(node.scroll:unpack())
            
            -- Calculate Y Axis scroll
            if (axis & AXIS_Y) == 0 then
                node.scroll.y = 0
                target.y = 0
            else
                maxy = maxy + (node:get_style("bufferTop") or 0)
                miny = miny + (node:get_style("bufferBottom") or 0)
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
                maxx = maxx + (node:get_style("bufferLeft") or 0)
                minx = minx + (node:get_style("bufferRight") or 0)
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
            
            node.scroll = node.scroll + (target - node.scroll)*DeltaTime*10
        end)
    
    -- Override draw_children to implement clipping
    function node:draw_children()
        local axis = (node:get_style("clipAxis") or AXIS_NONE)
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
        if node.scrolling or (event.pos == nil) or node:covers(event.pos) then
            Oil.Node.handle_event(self, event)
        end
    end
    
    return node
end
