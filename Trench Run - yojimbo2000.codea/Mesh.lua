Mesh = class() 

function Mesh:init(t) 
    self.pos = t.pos
    self.mesh = t.mesh
    print("mesh",self.mesh)
    --self.instances = t.instances
    self.scenery = t.scenery
    self.matrix = t.matrix or matrix()
    self.forward = t.forward or vec3(0,0,1)
    self.up = t.up or vec3(0,1,0)
    self.size = t.size or 1
    self.angle = t.angle or vec3(0,0,0)
    self:light{light = vec4(40,100,-70,0)} --directional light direction (x,y,z,0)
    self.flash = 1
    self.mask = t.mask
    meshes[#meshes+1] = self
end

function Mesh:draw()
    if ((self.pos + self.size * cam.forward) - cam.pos):normalize():dot(cam.forward) < 0.85 then return end --dont draw mesh if outside field of view not self.scenery and 
    pushMatrix()
    translate(self.pos:unpack())
    
   --y, x, z
    rotate(self.angle.z)
    rotate(self.angle.x, 1,0,0)
    rotate(self.angle.y, 0,1,0)
    
    local mm = modelMatrix()
    self.forward = getZForward(mm)
    self.up = getYUp(mm)
    self.mesh.shader.modelMatrix=mm
    self.matrix = mm
    self.mesh.shader.eye=cam.pos
    self.mesh.shader.flash = self.flash
    scale(self.size)
    self.mesh:draw() --self.instances

    popMatrix()
end

function Mesh:collisions()
    
end

function Mesh:flashing(speed, bright)
    if self.tween then tween.reset(self.tween) end
    if not speed then --switch off flashing
        self.tween = nil
    else
        self.flash = bright
        self.tween = tween(speed, self, {flash = 1}) --sineInOut
        
    end
end

function Mesh:light(t)
    local m=self.mesh
    
    m.shader.light=t.light:normalize()
    m.shader.ambient=t.ambient or 0.3
    m.shader.lightColor=t.lightColor or color(255, 245, 235, 255)
end
