Wave = class()

formations = {
    {pos = vec3(0,3,150), angle = vec3(0,180,0), speed = -0.5, offset = vec3(0,1,0), movement = Enemy.corkscrew
    }, --flying backwards, player overtakes

    {pos = vec3(6, 12,150), angle = vec3(0,180,0), speed = -0.3, offset = vec3(-1,-1,0), movement = Enemy.corkscrew
    }, --flying backwards, player overtakes

    {pos = vec3(-6,16,150), angle = vec3(0,0,0), speed = 0.5, offset = vec3(1,0,0), movement = Enemy.dive
    }, --do a half loop when player draws near

    {pos = vec3(-6,19,12), angle = vec3(0,0,0), speed = 1.1, offset = vec3(1,0,0), movement = Enemy.diveFast
    }, --do a half loop when player draws near
}
function Wave:init()
    self.type = formations[math.random(#formations)] --[2] --
    self.number = 4 + math.random(4)
    self.remaining = self.number
    self.interval = 0.3 + math.random() * 0.5
    self.timer = ElapsedTime + 0.5 + math.random()
end

function Wave:update()
    if ElapsedTime > self.timer and self.number > 0 then
        self.timer = ElapsedTime + self.interval
        Enemy{pos = self.type.pos + self.number * self.type.offset, angle = vec3(self.type.angle:unpack()), speed = self.type.speed, parentWave = self, movement = self.type.movement}
        self.number = self.number - 1
    end
end

function Wave:shipDown()
    self.remaining = self.remaining - 1
    if self.remaining <= 0 then
        self:init()
    end
end
