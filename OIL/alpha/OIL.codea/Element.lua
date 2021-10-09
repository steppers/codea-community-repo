OIL.Element = class()

function OIL.Element:init(t)
    -- Defaults
    self.children = {}
    self.render_components = {}
    self.x = 0
    self.y = 0
    self.w = 1.0
    self.h = 1.0
    self.frame = {}
    self.priority = 0 -- default priority
    self.hidden = false
    self.enabled = true
    self.on_event = nil
    self.scroll_x = 0
    self.scroll_y = 0
    self.scroll_buffer_top = 0
    self.scroll_buffer_bottom = 0
    
    -- Add overrides
    if t then
        for k,v in pairs(t) do
            self[k] = v
        end
    end
    
    -- If we have a parent, register ourself with it
    if self.parent then
        self.parent:add_child(self)
    elseif OIL.root then -- or register with the root
        OIL.root:add_child(self)
    end
    
    -- Setup a destructor
    local mt = getmetatable(self)
    mt.__gc = function(self)
        if self.destructor then self:destructor() end
    end
    setmetatable(self, mt)
    
    -- Initialise default frame
    self:update_frame()
    
    -- Internal values
    self.next_child_index = 0
end

function OIL.Element:add_child(child)
    if child.parent then
        child.parent:remove_child(child)
    end
    
    -- Set and inc. parent index
    child.parent_index = self.next_child_index
    self.next_child_index = self.next_child_index + 1
    
    child.parent = self
    table.insert(self.children, child)
    self:sort_children() -- re-sort
    return self
end

function OIL.Element:remove_child(child)
    -- Remove child
    for i,v in ipairs(self.children) do
        if v == child then
            table.remove(self.children, i)
            child.parent = nil
            break
        end
    end
end

function OIL.Element:kill()
    -- Remove ourself from the element chain
    self.parent:remove_child(self)
end

function OIL.Element:sort_children()
    table.sort(self.children, function(a, b)
        if a.priority == b.priority then
            return a.parent_index < b.parent_index
        end
        return a.priority < b.priority
    end)
end

function OIL.Element:add_render_component(component, default_style)
    component:bind(self, default_style)
    table.insert(self.render_components, component)
    return self
end

function OIL.Element:remove_render_component(component)
    -- Remove render_component
    for i,v in ipairs(self.render_components) do
        if v == component then
            table.remove(self.render_components, i)
            break
        end
    end
    component.owner = nil
end

-- Stolen from SODA
local function parseCoordSize(loc, size, edge)
    local pos, len
    if size>1 then
        len = size --standard length coord
    elseif size>0 then
        len = math.ceil(edge * size) --proportional length
    end --nb defer if size is negative
    if len then
        local half = len * 0.5
        if loc%1==0 and loc>=0 then
            pos = loc + half --standard coord
        elseif loc<0 then
            pos = edge - half + loc --negative coord
        else
            pos = math.ceil(edge * loc) --proportional coord
        end
    else --negative size
        if loc%1==0 and loc>=0 then 
            len = edge - loc + size --loc and size describing the two edges
            pos = loc + len * 0.5
        elseif loc>0 then  --proportional loc coord
            local x2 = edge + size
            local x1 = math.ceil(edge * loc)
            len = x2 - x1
            pos = x1 + len * 0.5
          --  pos = edge * loc 
            
            --len = (x2 - pos) * 2
        else --both negative
            local x2 = edge + size
            local x1 = edge + loc
            len = x2 - x1
            pos = x1 + len * 0.5
        end
    end
    return pos, len
end

function OIL.Element:update_frame()
    -- Use the set x, y, w, h values & the parent frame
    -- to calculate the render frame for this element
    
    -- If we have no parent, then we're the root so use a fullscreen frame
    if self.parent == nil then
        self.frame = {
            x = WIDTH/2, y = HEIGHT/2,
            w = WIDTH, h = HEIGHT,
            l = 0, r = WIDTH, b = 0, t = HEIGHT,
            l_scrolled = 0, r_scrolled = WIDTH, b_scrolled = 0, t_scrolled = HEIGHT
        }
        return
    end
    
    local parent = self.parent.frame
    
    self.frame.x, self.frame.w = parseCoordSize(self.x, self.w, parent.w)
    self.frame.y, self.frame.h = parseCoordSize(self.y, self.h, parent.h)
    
    -- Parent offset
    self.frame.x = self.frame.x + parent.l
    self.frame.y = self.frame.y + parent.b
    
    -- Pre Scroll frame
    self.frame.l_unscrolled = self.frame.x - self.frame.w * 0.5
    self.frame.r_unscrolled = self.frame.l_unscrolled + self.frame.w
    self.frame.l = self.frame.l_unscrolled + self.parent.scroll_x
    self.frame.r = self.frame.l + self.frame.w
    
    self.frame.b_unscrolled = self.frame.y - self.frame.h * 0.5
    self.frame.t_unscrolled = self.frame.b_unscrolled + self.frame.h
    self.frame.b = self.frame.b_unscrolled + self.parent.scroll_y - self.parent.scroll_buffer_top
    self.frame.t = self.frame.b + self.frame.h
end

function OIL.Element:draw(hidden)
    -- Element enabled?
    if not self.enabled then
        return
    end
    
    -- Call our update function
    if self.update then
        self:update()
        
        -- If parent is nil then we've been removed
        -- from the element chain and should return.
        if self.parent == nil then return end
    end
    
    -- Call our private update function
    if self._update then
        self:_update()
        
        -- If parent is nil then we've been removed
        -- from the element chain and should return.
        if self.parent == nil then return end
    end
    
    -- Update the render frame
    self:update_frame()
    
    -- Save model matrix
    pushMatrix()
    
    -- Translate for new frame
    translate(self.frame.l, self.frame.b)
    
    -- Element hidden?
    if not self.hidden then
        -- Draw render components in order
        for _,comp in ipairs(self.render_components) do
            comp:draw(self.frame.w, self.frame.h)
        end
    end
    
    -- Restore model matrix
    popMatrix()
    
    -- Draw children
    self:draw_children(hidden)
end

-- Allows for child draw overrides (E.g. scrolling containers)
function OIL.Element:draw_children(hidden)
    for _,child in ipairs(self.children) do
        child:draw(self.hidden or hidden)
    end
end

-- Returns true if the event has been handled
function OIL.Element:handle_event(event)
    
    -- Pass to children first (in reverse order)
    for i = #self.children, 1, -1 do
        local child = self.children[i]
        if child:handle_event(event) then
            return child
        end
    end
    
    -- Call our event handler
    if self.on_event and self:on_event(event) then
        return self
    end
    
    -- Not handled
    return nil
end

function OIL.Element:pos_is_inside(pos)
    return  self.frame.l <= pos.x and
            self.frame.r >= pos.x and
            self.frame.b <= pos.y and
            self.frame.t >= pos.y
end
