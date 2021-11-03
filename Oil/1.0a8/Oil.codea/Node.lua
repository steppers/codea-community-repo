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
