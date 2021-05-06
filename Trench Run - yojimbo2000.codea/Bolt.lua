Bolt = class(Mesh)

function Bolt:init(t)
    Mesh.init(self, t)
    self.radius = 0.2
    self.speed = t.speed
    self.lifespan = ElapsedTime + 2
end

function Bolt:update()
    self.pos = self.pos + self.speed * self.forward 
    if ElapsedTime > self.lifespan or self.pos.x < -trenchRadius+self.radius or self.pos.x > trenchRadius-self.radius or self.pos.y < self.radius  or self.pos.z < player.pos.z - 40 then --or self.pos.y > trenchSize+self.radius
     self.kill = true 
    end
    
end

function Bolt:hit()
    self.kill = true
end

function Bolt:draw()
    pushMatrix()
    translate(self.pos:unpack())

     rotate(self.angle.y, 0,1,0)   
    rotate(self.angle.x, 1,0,0)
    rotate(self.angle.z)  

    blendMode(ADDITIVE)
    self.mesh:draw()
    blendMode(NORMAL)
    popMatrix()
end