Enemy = class(Ship)
local trenchDirection = vec3(0,0,1)
function Enemy:init(t)
    t.mesh = model.TieFighter
    t.size = 2
    t.mask = hostile
    self.inception = ElapsedTime
    self.radius = 0.7
    self.parentWave = t.parentWave
    self.movement = t.movement
    self.shield = 0.1
    Ship.init(self, t)
end

function Enemy:control()
    local diff = player.pos-self.pos
    self:movement(diff)
    --firing
    if ElapsedTime>self.fireInterval then
        
        if diff.z > 30 and self.forward:dot(trenchDirection)<0 then
            self.kill = true
            self.parentWave:shipDown()
            return
        end
       -- local len = diff:len()
        if diff:normalize():dot(self.forward)>0.99 then --len<50 and
        
        self.fireInterval = ElapsedTime + 0.3
        Bolt{pos = self.pos + self.forward, angle = vec3(self.angle:unpack()), forward = self.forward, mesh = model.enemyBolt, mask = hostile, speed = 2}
     
        end
    end
    self.pos.y = clamp(self.pos.y, self.radius * 1.2, trenchSize * 2 +self.radius)

end

function Enemy:destroy()
    score = score + 150
    self.parentWave:shipDown()
end

function Enemy:corkscrew()
    -- self.angle.y = self.angle.y +  math.sin(ElapsedTime) * 0.06
    local time = (ElapsedTime-self.inception)*2
    self.angle.y = 180 +  math.sin(time) * 10
    self.angle.z = (time * 30) % 360
end

function Enemy:dive(diff)
    local time = (ElapsedTime-self.inception)*2
    self.angle.y = math.sin(time) * 10
    if not self.diveTween and diff.z > -50 and diff.z < -30 then
        self.diveTween = tween(1.5 + math.random(), self.angle, {x = 180}, tween.easing.cubicInOut)
    end
end

function Enemy:diveFast(diff)
    local time = (ElapsedTime-self.inception)*2
    self.angle.y = math.sin(time) * 10
    if not self.diveTween and diff.z > -60 and diff.z < -40 then
        self.diveTween = tween(1.1 + math.random(), self.angle, {x = 180}, tween.easing.cubicInOut) --0.5, 180
        tween(0.5, self, {speed = 0.3}, tween.easing.cubicInOut)
    end
end