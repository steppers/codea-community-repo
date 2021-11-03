-- Custom Types --
------------------------------------------------------
    
Vertex = class()
    
function Vertex:init(x, y, z)
    self.x = x
    self.y = y
    self.z = z
    self.pt = vec2(0,0)
    self.col = color(Red, Green, Blue, 255)
    self.done = false
end
    
------------------------------------------------------
Face = class()
    
function Face:init(x, y, z)
    self.x = x
    self.y = y
    self.z = z
    self.dist = 0
end
    