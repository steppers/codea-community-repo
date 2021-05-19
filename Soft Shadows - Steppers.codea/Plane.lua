Plane = class()

function Plane:init(width, height, col)
    self.mesh = mesh()
    self.mesh:addRect(0, 0, width, height)
    self.mesh:setColors(col or color(255))
    
    self.trans = Transform()
    self.trans.rot.x = 90
end

function Plane:draw(shader_to_use)
    self.trans:setMatrix()
    shader_to_use.model = modelMatrix()
    self.mesh.shader = shader_to_use
    self.mesh:draw()
end
