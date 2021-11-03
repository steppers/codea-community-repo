--# Bullet
Bullet = class()

function Bullet:init(owner, x, y, weapon)
    self.owner = owner
    self.origin = vec2(x, y)
    self.pos = vec2(x, y)
    
    -- handles weapon spray
    if weapon == Weapons.flak then
        self.dir = vec2(self.owner.dir.x + (-1+math.random()*2)/5, self.owner.dir.y + (-1+math.random()*2)/5)
    elseif weapon == Weapons.blastgun then
        self.dir = vec2(self.owner.dir.x + (-1+math.random()*2)/10, self.owner.dir.y + (-1+math.random()*2)/10)
    else
        self.dir = vec2(self.owner.dir.x, self.owner.dir.y)
    end
    
    self.weapon = weapon
    self.speed = weapon.speed
    self.dmg = weapon.dmg
    self.range = weapon.range
    self.distance = 0
    self.gone = false
    self.impact = false
    self.timer = 0
    
    if weapon == Weapons.rocketlauncher then
        table.insert(scene.animations, Animation("smoke", self.pos))
    end
end

function Bullet:hit(vol)
    if self.weapon == Weapons.flak then
        sound("Game Sounds One:Pillar Hit", vol/10)
    elseif self.weapon == Weapons.rocketlauncher then
        sound("A Hero's Quest:FireBall Blast 2",  vol)
    else
        sound("Game Sounds One:Pillar Hit", vol)
    end
    
end

function Bullet:update()
    self.timer = self.timer + DeltaTime
    local vol = math.min(50/self.pos:dist(self.owner.pos), .8) --math.min(50/self.distance, .8)
    local bounce = self.weapon == Weapons.blastgun or self.weapon == Weapons.flak
    self.lastpos = self.pos
    
    local x, y = math.floor(self.pos.x/world.size) + 1, math.floor(self.pos.y/world.size) + 1
    local npx = self.pos.x + self.dir.x * self.speed * 60*DeltaTime
    local npy = self.pos.y + self.dir.y * self.speed * 60*DeltaTime
    local nx, ny = math.floor(npx/world.size) + 1, math.floor(npy/world.size) + 1
    local hit = false
    
    -- handles weather a bullet hits or bounces off ball.
    if world.map[nx][y].solid then
        if bounce then
            self.dir.x = -self.dir.x
        else
            hit = true
            self.gone = true
        end
        self.impact = true
        self:hit(vol)
    end
    if world.map[x][ny].solid then
        if bounce then
            self.dir.y = -self.dir.y
        else
            hit = true
            self.gone = true
        end
        self.impact = true
        self:hit(vol)
    end
    
    self.pos = self.pos + self.dir * self.speed * 60*DeltaTime
    
    if self.weapon == Weapons.rocketlauncher then
        if self.timer > .1 then
            self.timer = 0
            table.insert(scene.animations, Animation("smoke", self.pos, false, .1, 1, .7))
        end
    end
    
    if self.impact and self.weapon == Weapons.rocketlauncher then
        local dist = self.pos:dist(self.owner.pos)
        if dist < 150 then
            self:dealDmg(self.owner, (self.dmg - dist)/2)
        end
        local dist = self.pos:dist(self.owner.target.pos)
        if dist < 150 then
            self:dealDmg(self.owner.target, (self.dmg - dist)/2)
        end
        table.insert(scene.animations, Animation("smoke", self.pos, false, .1, 3.3, .7))        
        table.insert(scene.animations, Animation("explosion", self.pos, false, .1, 2, .7))
        table.insert(scene.animations, Animation("explosion", self.pos, false, .1, 2, .7))
        return
    end
    
    -- update distance travelled by bullet
    self.distance = self.distance + self.pos:dist(self.lastpos)
    
    if self.distance > self.range then
        self.gone = true
        return
    end
    
    -- if it can bleed, we can kill it
    if not self.owner.target.invincible and self.pos:dist(self.owner.target.pos) < 40 then
        if self.weapon == Weapons.rocketlauncher then
            local dist = self.pos:dist(self.owner.pos)
            if dist < 150 then
                self:dealDmg(self.owner, (self.dmg - dist)/4)
            end
            table.insert(scene.animations, Animation("smoke", self.pos, false, .1, 3.3, .7))        
            table.insert(scene.animations, Animation("explosion", self.pos, false, .1, 2, .7))
            table.insert(scene.animations, Animation("explosion", self.pos, false, .1, 2, .7))
        end
        self:dealDmg(self.owner.target, self.dmg, true)
        self.impact = true
        self.gone = true
        self:hit(vol)        
        return
    end
end

function Bullet:dealDmg(target, dmg, face)
    -- calculate possible shield absorb
    local realDmg = 0
    if target.shield == 0 then
        realDmg = dmg
    else
        target.shield = target.shield - dmg
        if target.shield > 0 then
            realDmg = dmg/2
        else
            realDmg = dmg + target.shield/2
            target.shield = 0
        end
    end
    
    target.life = target.life - realDmg
    target.showHit = true
    
    target.isSnared = true
    target.snareTimer = .5
    target:updateSpeed()
    if target.life > 0 then
        sound("A Hero's Quest:Hurt 1")
    end
    
    target.knockedBack = true
    target.knockBackPow = target.knockBackPow + dmg/5
    if face then
        target.knockBackDir = target.side * (self.pos - target.pos):normalize() 
    else
        target.knockBackDir = -target.side * (self.pos - target.pos):normalize() 
    end
    table.insert(scene.animations, Animation("blood", target.pos, false, .1, 2, .7))
    if target.life <= 0 then
        		target.score.deaths = target.score.deaths + 1
        		if target ~= self.owner then
            			self.owner.score.kills = self.owner.score.kills + 1
        		else
            			self.owner.score.kills = self.owner.score.kills - 1
        		end
        table.insert(scene.animations, Animation("blood", target.pos, false, .1, 3, .7))
        table.insert(scene.animations, Animation("blood", target.pos, false, .1, 3, .7))
        table.insert(scene.animations, Animation("blood", target.pos, false, .1, 3, .7))
    end	
end

function Bullet:draw(vec)
    local pos = self.pos - vec
    pushMatrix()
    translate(pos.x, pos.y)
    
    if self.impact then
        if self.weapon == Weapons.blastgun then
            tint(255, 255, 255, 255)
            sprite("Project:blast2", 0, 0, 128, 128)
        else
            tint(255, 240, 0, 255)
            sprite("Project:bullet", 0, 0, 128, 128)
        end
    else
        tint(255, 255, 255, 255)
        if self.weapon == Weapons.blastgun then
            sprite("Project:blast", 0, 0, 64, 64)
        elseif self.weapon == Weapons.rocketlauncher then
            sprite("Project:bullet", 0, 0, 96, 96)
        else
            sprite("Project:bullet", 0, 0, 64, 64)
        end
    end
    popMatrix()
end