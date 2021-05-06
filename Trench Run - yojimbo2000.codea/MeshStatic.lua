MeshStatic = class(Mesh) 

function MeshStatic:init(t) 
    self.pos = t.pos
    self.mesh = t.mesh
    
    self.instances = t.instances
    self.scenery = t.scenery
    self.matrix = t.matrix or matrix()
    print(self.matrix)
    
    self.mesh.shader.flash = 1
    self.size = t.size or 1
    self.angle = t.angle or vec3(0,0,0)
    self:light{light = vec4(40,100,-70,0)} --directional light direction (x,y,z,0), or point light position (x,y,z,1)
    self.flash = 1
    self.mask = t.mask
    meshes[#meshes+1] = self
end

function MeshStatic:draw()
 --   if not self.scenery and ((self.pos + self.size * cam.forward) - cam.pos):normalize():dot(cam.forward) < 0.85 then return end --dont draw mesh if outside field of view
    pushMatrix()
    modelMatrix(self.matrix)
  
    self.mesh.shader.eye=cam.pos
    self.mesh.shader.modelMatrix = self.matrix
    self.mesh:draw()
    popMatrix()
end


