-- Custom renderers
Oil.TextRenderer = class(Oil.Renderer)
function Oil.TextRenderer:init(style)
    Oil.Renderer.init(self, function(node, w, h)
        -- Apply styling
        Oil.styleApply("fillText", fill)
        Oil.styleApply("font")
        Oil.styleApply("fontSize")
        
        textMode(CORNER)
        local str = Oil.styleGet("text") or ""
        local tw, th = textSize(str)
        
        local align = Oil.styleGet("textAlign")
        if align == CENTER then
            text(str, (w-tw)/2, (h-th)/2)
        elseif align == RIGHT then
            text(str, w-tw, (h-th)/2)
        else
            text(str, 0, (h-th)/2)
        end
    end, style)
end





-- Handlers
function Oil.ButtonHandler(callback, long_press_callback)
    return function(node, event)
        if node:covers(event.pos) then
            node.style.fill = Oil.styleGet("fillButtonHover")
            
            if event.type == "touchdown" then
                node.style.fill = Oil.styleGet("fillButtonPressed")
                return true
            elseif event.type == "touchup" then
                node.style.fill = Oil.styleGet("fillButtonNormal")
                return true
            elseif event.type == "tap" then
                node.style.fill = Oil.styleGet("fillButtonNormal")
                if event.is_click then -- mouse clicks leave the cursor
                    node.style.fill = Oil.styleGet("fillButtonHover")
                end
                if callback then callback() end
                return true
            elseif event.type == "press" then
                if long_press_callback then long_press_callback() end
                return true
            end
        else
            node.style.fill = Oil.styleGet("fillButtonNormal")
        end
    end
end

function Oil.ScrollHandler()
    return function(node, event)
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
end

-- Blocks all incoming events that are inside the node
function Oil.TouchBlocker()
    return function(node, event)
        if node:covers(event.pos) then
            return true
        end
    end
end
        




-- Node constructors
function Oil.Label(x, y, w, h, label, align)
    local node = Oil.Node(x, y, w, h)
    :add_renderer(Oil.TextRenderer({
        text=label,
        textAlign=align
    }))
    
    function node:set_label(label)
        self.renderers[1].style.text = label
        return self
    end
    
    return node
end

function Oil.Rect(x, y, w, h, col, radius, blur)
    local node = Oil.Node(x, y, w, h)
        :add_renderer(Oil.RectRenderer(),{
            fill = col,
            radius = radius,
            blur = blur
        })
    
    function node:set_texture(texture)
        self.renderers[1].style.tex = texture
        return self
    end
    
    return node
end

function Oil.Icon(x, y, w, h, texture)
    return Oil.Rect(x, y, w, h):set_texture(texture)
end

function Oil.TextButton(x, y, w, h, label, cb, press_cb)
    local node = Oil.Rect(x, y, w, h)
        :add_handler(Oil.ButtonHandler(cb, press_cb))
        :add_renderer(Oil.TextRenderer({text=label}))
        :set_default_style(Oil.style_text_button) -- default style
    
    function node:set_label(label)
        self.renderers[2].style.text = label
        return self
    end
    
    return node
end

function Oil.IconButton(x, y, w, h, texture, cb, press_cb)
    local node = Oil.Icon(x, y, w, h, texture)
        :add_handler(Oil.ButtonHandler(cb, press_cb))
        :set_default_style(Oil.style_icon_button) -- default style
    
    return node
end

-- Spreads children along it's width
function Oil.HorizontalSpreader(x, y, w, h)
    local node = Oil.Node(x, y, w, h)
    :add_updater(function(node)
        -- Have the children update first
        node:update_children_minimal()
        
        local num_children = #node.children
        local spacing = Oil.styleGet("spacing")
        
        local children_total_width = 0
        for _,child in ipairs(node.children) do
            children_total_width = children_total_width + child.frame.w
        end
        children_total_width = children_total_width + ((spacing or 0) * (num_children-1))
        
        local x = 0
        local align = Oil.styleGet("align")
        if align == RIGHT then
            x = node.frame.w - children_total_width
        elseif align == CENTER then
            x = (node.frame.w - children_total_width) / 2
        end
        
        for _,child in ipairs(node.children) do
            child.x = x//1
            x = x + child.frame.w + (spacing or 0)
        end
    end)
    
    return node
end

-- Spreads children along it's height
function Oil.VerticalSpreader(x, y, w, h)
    local node = Oil.Node(x, y, w, h)
    :add_updater(function(node)
        -- Have the children update first
        node:update_children_minimal()
        
        local num_children = #node.children
        local spacing = Oil.styleGet("spacing")
        
        local children_total_height = 0
        for _,child in ipairs(node.children) do
            children_total_height = children_total_height + child.frame.h
        end
        children_total_height = children_total_height + ((spacing or 0) * (num_children-1))
        
        local y = children_total_height
        local align = Oil.styleGet("align")
        if align == TOP then
            y = node.frame.h
        elseif align == CENTER then
            y = (node.frame.h + children_total_height) / 2
        end
        
        for _,child in ipairs(node.children) do
            y = y - child.frame.h
            child.y = y // 1
            y = y - spacing
        end
    end)
    
    return node
end

-- Scroll
function Oil.Scroll(x, y, w, h)
    local node = Oil.Node(x, y, w, h)
    :add_updater(function(node)
        -- Scroll smoothing
        if node.scrolling then
            node.scroll = node.scroll + node.scroll_velocity*DeltaTime
        elseif node.scroll_velocity then
            node.scroll_velocity = node.scroll_velocity * 0.93
            node.scroll = node.scroll + node.scroll_velocity*DeltaTime
        end
        
        -- Update the child frames
        node:update_children_minimal()
        
        -- Detect bounds of children
        local minx, maxx, miny, maxy = math.maxinteger,math.mininteger,math.maxinteger,math.mininteger
        for _,child in ipairs(node.children) do
            minx = math.min(minx, child.frame.x)
            miny = math.min(miny, child.frame.y)
            maxx = math.max(maxx, child.frame.x + child.frame.w)
            maxy = math.max(maxy, child.frame.y + child.frame.h)
        end
        
        -- Default scroll axis is Y
        local axis = (Oil.styleGet("scrollAxis") or AXIS_Y)
        
        -- The desired scroll value
        local target = vec2(node.scroll:unpack())
        
        -- Calculate Y Axis scroll
        if (axis & AXIS_Y) == 0 then
            node.scroll.y = 0
            target.y = 0
        else
            local bufB = (Oil.styleGet("bufferBottom") or 0)
            local h = (maxy-miny) + (node.frame.h-maxy) + bufB
            if h < node.frame.h then
                target.y = 0
            elseif node.scroll.y < 0 then
                target.y = 0
            elseif node.scroll.y > (h - node.frame.h) then
                target.y = (h - node.frame.h)
            end
        end
        
        -- Calculate X Axis scroll
        if (axis & AXIS_X) == 0 then
            node.scroll.x = 0
            target.x = 0
        else
            local bufR = (Oil.styleGet("bufferRight") or 0)
            local w = (maxx-minx) + (node.frame.w-maxx) + bufR
            if w < node.frame.w then
                target.x = 0
            elseif node.scroll.x < 0 then
                target.x = 0
            elseif node.scroll.x > (w - node.frame.w) then
                target.x = (w - node.frame.w)
            end
        end
        
        node.scroll = node.scroll + (target - node.scroll)*DeltaTime*10
    end)
    :add_handler(Oil.ScrollHandler())
    
    -- Override draw_children to implement clipping
    function node:draw_children()
        local axis = (Oil.styleGet("clipAxis") or AXIS_NONE)
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
    
    return node
end
