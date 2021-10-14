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
        
        if pos%1 == 0 and pos >= 0 then
            -- Standard coord
        elseif pos < 0 then -- far edge offset
            pos = (parent_size + pos) - size
        else -- Proportional pos
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
    self.x = x or 0.0
    self.y = y or 0.0
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
    
    -- Empty style table by default
    self.style = {}
    self.style_default = nil -- No default override
    
    -- Empty frame until first update
    self.frame = {}
    
    -- Empty component lists
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
end

-- Called once per frame (when enabled)
function Oil.Node:update()
    
    -- Abort if disabled
    if not self.enabled then
        return
    end
    
    -- Calculate render frame
    self:calculate_frame()
    
    -- Re-sort the children
    self:sort_children()
    
    -- Apply style
    Oil.stylePush(self.style_default, self.style)
    
    -- Update own updaters.
    -- We do this in reverse order so additional updaters
    -- added to prefabs are run first.
    for i = #self.updaters, 1, -1 do
        self.updaters[i](self)
    end
    
    -- Update children
    for _,child in ipairs(self.children) do
        child:update()
    end
    
    -- Pop style
    Oil.stylePop(2)
end

-- Updates the current node and it's children without
-- calling updaters. Only the frames are calculated
-- using the Nodes' current states.
function Oil.Node:update_minimal()
    -- Calculate render frame
    self:calculate_frame()
    
    -- Re-sort the children
    self:sort_children()
    
    -- Update children
    for _,child in ipairs(self.children) do
        child:update_minimal()
    end
end

-- Same as update_minimal above but avoids
-- recalculating our own frame again.
-- This should only be called from within
-- an updater.
function Oil.Node:update_children_minimal()
    -- Update children's frames
    for _,child in ipairs(self.children) do
        child:update_minimal()
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
    
    -- Apply style
    Oil.stylePush(self.style_default, self.style)
    
    -- Draw own renderers
    for _,renderer in ipairs(self.renderers) do
        Oil.stylePush(renderer.style) -- Push renderer style
        renderer.func(self, self.frame.w, self.frame.h)
        Oil.stylePop() -- Pop renderer style
    end
    
    -- Translate children for scrolling
    translate(self.scroll.x, self.scroll.y)
    
    -- Draw children
    self:draw_children()
    
    -- Pop style
    Oil.stylePop(2)
    
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
    
    -- Apply style
    Oil.stylePush(self.style_default, self.style)
    
    -- Pass to children first
    for i = #self.children, 1, -1 do
        local child = self.children[i]
        local handler = child:handle_event(event)
        if handler then
            Oil.stylePop() -- Pop renderer style
            return handler
        end
    end
    
    -- Pass to handlers
    for _,handler in ipairs(self.handlers) do
        if handler(self, event) then
            Oil.stylePop() -- Pop renderer style
            return self
        end
    end
    
    -- Pop renderer style
    Oil.stylePop(2)
    
    -- Not handled
    return nil
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

function Oil.Node:set_style(style)
    self.style = style
    return self
end

function Oil.Node:set_default_style(style)
    self.style_default = style
    return self
end

function Oil.Node:set_priority(p)
    self.priority = p
    
    -- Resort
    self.parent:sort_children()
    return self
end

function Oil.Node:add_child(child)
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
    
    return self
end

function Oil.Node:add_children(...)
    for _,child in ipairs({...}) do
        self:add_child(child)
    end
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
function Oil.Node:add_renderer(renderer, style)
    if type(renderer) == "function" then
        table.insert(self.renderers, Oil.Renderer(renderer, style))
    else
        renderer.style = style or renderer.style
        table.insert(self.renderers, renderer) 
    end
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
            v.parent = nil -- No parent now
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
