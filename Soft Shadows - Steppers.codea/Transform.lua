Transform = class()

function Transform:init()
    self.pos = vec3(0, 0, 0)
    self.rot = vec3(0, 0, 0)
    self.scl = vec3(1, 1, 1)
end

function Transform:setMatrix()
    resetMatrix()
    
    translate(self.pos.x, self.pos.y, self.pos.z)
    rotate(self.rot.y, 0, 1, 0)
    rotate(self.rot.z, 0, 0, 1)
    rotate(self.rot.x, 1, 0, 0)
    scale(self.scl.x, self.scl.y, self.scl.z)
end
