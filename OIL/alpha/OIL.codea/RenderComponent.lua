OIL.RenderComponent = class()

-- Constructor
--
-- If a function(w, h) is passed, the function
-- will be used during the rendering phase
function OIL.RenderComponent:init(func, style)
    self.func = func
    self.style = style or {}
end

function OIL.RenderComponent:bind(owner, default_style)
    self.owner = owner
    self.default_style = default_style or OIL.Style.default
end

function OIL.RenderComponent:unbind()
    if self.style == self.owner.style then
        self.style = nil
    end
    self.owner = nil
end

-- Override for implementations if a function was
-- not provided to the constructor
function OIL.RenderComponent:draw(w, h)
    if self.func then self:func(w, h) end
end

-- Searches for a style value by key in order:
-- 1) The component style sheet is searched
-- 2) The parent element style sheet is searched
-- 3) Grandparent's style sheets are searched.
-- 4) The component default style sheet is searched.
-- 5) The global default style sheet is searched.
-- 6) Polls a global function if it exists (e.g. fill())
-- 7) Return nil
function OIL.RenderComponent:get_style(k, this_element_only)
    
    -- Search component style
    local style = self.style
    local v = style and style[k]
    if v ~= nil then return v end
    
    -- Search parents' style
    local parent = self.owner
    while parent ~= nil do
        style = parent.style
        v = style and style[k]
        if v ~= nil then return v end
        
        -- Early out if we only care about our own style
        if this_element_only then
            return nil
        end
        
        -- Next parent
        parent = parent.parent
    end
    
    -- Search component default style sheet
    style = self.default_style
    v = style and style[k]
    if v ~= nil then return v end
    
    -- Search global default style sheet
    style = OIL.Style.default
    v = style and style[k]
    if v ~= nil then return v end
    
    -- Poll global function
    if type(_G[k]) == "function" then
        return _G[k]()
    end
    
    return nil
end

function OIL.RenderComponent:apply_style(k)
    _G[k](self:get_style(k))
end
