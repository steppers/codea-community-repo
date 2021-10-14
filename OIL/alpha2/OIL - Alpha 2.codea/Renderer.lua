-- Basic storage class representing a renderer component

Oil.Renderer = class()

function Oil.Renderer:init(func, style)
    self.func = func
    self.style = style or {}
end
