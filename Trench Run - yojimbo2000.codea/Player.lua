Player = class(Ship)

function Player:init(t)
    t.mesh = model.XWing
    t.mask = friendly
    t.speed = 1
    self.radius = 0.7
    Ship.init(self,t)
    self.cannonPos = {vec3(1.4111, 0.5537, 0.9973), vec3(-1.4111, 0.5537, 0.9973 ), vec3(1.4111, -0.5537, 0.9973), vec3(-1.4111, -0.5537, 0.9973 )} --0.9973
    
    self.shield = 1
    self.fireSide = 1
end

function Player:control()
    --steering
    local tilt = math.deg(Gravity.x-deviceOri.x)
    self.angle.y = tilt * -0.6
    self.angle.z = tilt * 1.3
    self.angle.x = math.deg(Gravity.y-deviceOri.y)
    
    --firing
    if self.touching and ElapsedTime>self.fireInterval then
        print("model.playerBolt", model.playerBolt)
        self.fireInterval = ElapsedTime + 0.1
        Bolt{pos = self.pos + vecRotMat(self.matrix, self.cannonPos[self.fireSide]) + self.forward, angle = vec3(self.angle:unpack()), forward = self.forward, mesh = model.playerBolt, mask = friendly, speed = 3}
       -- self.fireSide = 3 - self.fireSide --alternate which side we fire on
        self.fireSide = (self.fireSide %4)+1
    end
    
    self.pos.y = clamp(self.pos.y, self.radius * 1.2, trenchSize +self.radius)

end

function Player:destroy()
    GameOver.init()
end

function Player:touched(t)
    if t.state == ENDED then 
        self.touching = false
    else
        self.touching = true
    end

end
