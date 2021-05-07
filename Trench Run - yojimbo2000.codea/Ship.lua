Ship = class(Mesh)

function Ship:init(t)
    self.fireInterval = 0
    self.speed = t.speed
    self.shielded = 0
    Mesh.init(self,t)
end

function Ship:collisions()
    local mask = 3-self.mask 
    for i = 1,#meshes do
        local v = meshes[i]
        if v.mask == mask and v.pos:dist(self.pos)<v.radius+self.radius then
            sound("Game Sounds One:Zapper "..math.random(2))
            self:hit()
            v:hit()
        end
    end
end

function Ship:hit()
    
    if ElapsedTime > self.shielded then
        self:flashing(0.2,8)
        self.shield = self.shield - 0.05
        if self.shield <= 0 then
            Explosion{pos = vec3(self.pos:unpack())}
            self:destroy()
            self.kill = true
        end
        self.shielded =ElapsedTime + 0.25
    end
end

function Ship:update()
    self:control()
    self.pos = self.pos + self.speed * self.forward 
    self.pos.x = clamp(self.pos.x, -trenchRadius+self.radius * 1.5, trenchRadius-self.radius * 1.5)
end
