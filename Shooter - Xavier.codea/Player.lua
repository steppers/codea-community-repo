--# Player
Player = class()

function Player:init(scene, x, y, side)
    self.scene = scene
    self.side = side
    	self.score = {}
    	self.score.caps = 0
    	self.score.kills = 0
    	self.score.deaths = 0
    	
    if side == 1 then
        self.flag = "Project:p1_1_7"
        self.spawn = "Project:p1_3_7"
    else
        self.flag = "Project:p1_2_7"
        self.spawn = "Project:p1_4_7"
    end
    self.hasFlag = false
    self.flagStolen = false
    
    self.target = nil
    
    self.pos = vec2(x, y)
    self.mpos = vec2()
    self.dir = vec2(1, 0)
    self.moveStick = Controller(self, true)
    self.shootStick = Controller(self)
    
    self.status = "idle"
    self.model = Model(self)
    
    self.arrow = mesh()
    self.arrowId = self.arrow:addRect(0, 0, 150, 150)
    self.arrow.texture = "Project:arrow"
    self.arrowTimer = 0
    
    self:respawn()
    
    self.shield = 0
    self.spawned = true
    self.invincible = false
end

function Player:move(vec, val)
    local npx = self.pos.x + vec.x * val
    local npy = self.pos.y + vec.y * val
    local nx, ny = math.floor(npx/world.size) + 1, math.floor(npy/world.size) + 1
    if ny > 0 and ny <= world.maxH and not world.map[self.mpos.x][ny].solid then
        self.pos.y = npy
    end
    if nx > 0 and nx <= world.maxW and not world.map[nx][self.mpos.y].solid then
        self.pos.x = npx
    end
end

-- equips a weapon
function Player:setWeapon(weapon)
    self.weapon = weapon
    if self.weapon ~= Weapons.railgun then
        self.aiming = false
    end
    self.ammo = self.weapon.ammo
    self:updateSpeed()
end

-- respawn player to spawn point
function Player:respawn()
    if self.hasFlag then
        self:dropFlag()
    end
    
    if self.side == 1 then
        self.pos = vec2(world.p1spawn.x*world.size-world.size/2, world.p1spawn.y*world.size-world.size/2)
    else
        self.pos = vec2(world.p2spawn.x*world.size-world.size/2, world.p2spawn.y*world.size-world.size/2)
    end
    self.aiming = false
    
    self.leftPortal = true
    self.invincible = true
    self.invinTimer = 2   
    self.spawned = false
    self.timer = 0
    self.shield = 0
    self.status = "idle"
    self.aiming = false
    self.firing = false
    self.ready = true
    self.showFlash = false
    self.showHit = false
    self.needReload = false
    self.spawnTimer = 8
    self.knockedBack = false
    self.knockBackDir = vec2()
    self.knockBackPow = 0
    
    self.hasSpeedboost = false
    self.speedboostTimer = 0
    
    self.isSnared = false
    self.snareTimer = 0    
    
    repeat
        -- self.pos = vec2(math.random(world.maxW*world.size-1), math.random(world.maxH*world.size-1))
        local x, y = math.floor(self.pos.x/world.size) + 1, math.floor(self.pos.y/world.size) + 1
    until true --world.map[x][y].solid ~= true
    
    self:setWeapon(Weapons.gun)
    self.life = 100
end

function Player:updateSpeed()
    local weight = self.weapon.weight
    if self.hasSpeedboost then
        weight = weight - 3
    end
    if self.hasFlag then
        weight = weight + 1
    end
    if self.isSnared then
        weight = weight + 2
    end
    
    self.speed = 5.5 - weight
end

-- handles flag capture
function Player:capFlag()
    if not self.flagStolen then
        sound("A Hero's Quest:Level Up")
        sound("Game Sounds One:Crowd Cheer")
        
        local block
        for x=1, world.maxW do
            for y=1, world.maxH do
                block = world.map[x][y]
                if block.pickup == "Project:p1_1_7" then block.pickup = nil end
                if block.pickup == "Project:p1_2_7" then block.pickup = nil end
            end
        end
        
        if self.side == 1 then
            world.map[world.p1flag.x][world.p1flag.y].pickup = self.flag
            world.map[world.p2flag.x][world.p2flag.y].pickup = self.target.flag
        else
            world.map[world.p1flag.x][world.p1flag.y].pickup = self.target.flag
            world.map[world.p2flag.x][world.p2flag.y].pickup = self.flag
        end
        self.target.hasFlag = false
        self.hasFlag = false
        self.flagStolen = false
        self.target.flagStolen = false
        		self.score.caps = self.score.caps + 1
    end
end

-- handles flag stealing
function Player:stealFlag(tile)
    self.hasFlag = true
    sound("A Hero's Quest:Pick Up")
    tile.pickup = nil
    self.target.flagStolen = true
end

-- handles flag save
function Player:returnFlag(tile)
    tile.pickup = nil
    sound("Game Sounds One:Crowd Cheer")
    if self.side == 1 then
        world.map[world.p1flag.x][world.p1flag.y].pickup = self.flag
    else
        world.map[world.p2flag.x][world.p2flag.y].pickup = self.flag
    end
    self.flagStolen = false
end

-- handles flag drop
function Player:dropFlag()
    self.hasFlag = false
    world.map[self.mpos.x][self.mpos.y].pickup = self.target.flag
    --    sound("A Hero's Quest:Pick Up")
end

-- handles picking up item
function Player:pickup(tile)
    
    -- flag
    if self.hasFlag then
        if tile.pickup == self.spawn then
            self:capFlag()
        end
    elseif tile.pickup == self.target.flag then
        self:stealFlag(tile)
    end
    
    if tile.pickup == self.flag and self.flagStolen then
        self:returnFlag(tile)
    end
    -- speedboost
    if tile.pickup == "Project:p1_1_6" then
        sound("A Hero's Quest:FireBall Woosh")
        self.hasSpeedboost = true
        self.boostTimer = 2
        self:resetPickup(tile)
    end
    -- shield
    if tile.pickup == "Project:p1_2_6" then
        sound("A Hero's Quest:Steal")
        self.shield = self.shield + 50
        if self.shield > 100 then self.shield = 100 end
        self:resetPickup(tile)
    end
    -- life
    if tile.pickup == "Project:p1_1_8" then
        sound("A Hero's Quest:Eat 1")
        self.life = 100
        self:resetPickup(tile)
    end
    -- flak
    if tile.pickup == "Project:p1_2_8" then
        sound("Game Sounds One:Reload 2")
        self:setWeapon(Weapons.flak)
        self:resetPickup(tile)
    end
    -- minigun
    if tile.pickup == "Project:p1_3_8" then
        sound("Game Sounds One:Reload 2")
        self:setWeapon(Weapons.minigun)
        self:resetPickup(tile)
    end
    -- blastgun
    if tile.pickup == "Project:p1_4_8" then
        sound("Game Sounds One:Reload 2")
        self:setWeapon(Weapons.blastgun)
        self:resetPickup(tile)
    end
    -- railgun
    if tile.pickup == "Project:p1_5_8" then
        sound("Game Sounds One:Reload 2")
        self:setWeapon(Weapons.railgun)
        self:resetPickup(tile)
    end
    -- rocketlauncher
    if tile.pickup == "Project:p1_6_8" then
        sound("Game Sounds One:Reload 2")
        self:setWeapon(Weapons.rocketlauncher)
        self:resetPickup(tile)
    end
    
end

-- once an item is picked up, starts its respawn timer (handled by World class)
function Player:resetPickup(tile)
    world:addRespawnTimer(tile.pickup, self.mpos)
    tile.pickup = nil
end

-- handles entering a portal
function Player:portalTo(tile)
    if self.leftPortal then
        table.insert(scene.animations, Animation("electrik", self.pos))
        table.insert(scene.animations, Animation("electrik", self.pos))
        self.pos.x = tile.portal.dx * world.size - world.size/2
        self.pos.y = tile.portal.dy * world.size - world.size/2
        self.mpos = vec2(tile.portal.dx, tile.portal.dy)
        self.leftPortal = false
        sound("A Hero's Quest:Attack Cast 1")
        table.insert(scene.animations, Animation("electrik", self.pos, false, .1, 2))
        table.insert(scene.animations, Animation("electrik", self.pos, false, .1, 2))
    end
end

-- updates player timers and player map coordinates
function Player:update()
    if self.knockedBack then
        self.knockBackPow = self.knockBackPow - self.knockBackPow/5
        self:move(self.knockBackDir, self.knockBackPow)
        if self.knockBackPow < 1 then
            self.knockedBack = false
            self.knockBackPow = 0
        end
    end
    
    if not self.spawned then
        self.spawnTimer = self.spawnTimer - DeltaTime
        if self.spawnTimer < 0 then
            self.spawned = true
        end
    end
    
    if self.isSnared then
        self.snareTimer = self.snareTimer - DeltaTime
        if self.snareTimer < 0 then
            self.isSnared = false
            self:updateSpeed()
        end
    end
    
    if self.hasSpeedboost  then
        self.boostTimer = self.boostTimer - DeltaTime
        if self.boostTimer < 0 then
            self.hasSpeedboost = false
            self:updateSpeed()
        end
    end
    
    self.mpos = vec2(math.floor(self.pos.x/world.size) + 1, math.floor(self.pos.y/world.size) + 1)
    local pos = world.map[self.mpos.x][self.mpos.y]
    if pos.pickup then
        self:pickup(pos)
        self:updateSpeed()
    end
    if pos.portal then
        self:portalTo(pos)
    else
        self.leftPortal = true
    end
    
    if self.ammo < 1 then
        self:setWeapon(Weapons.gun)
    end
    
    
    self.model:update()
    if self.life <= 0 then
        sound("A Hero's Quest:Hurt 5")
        self:respawn()
    end
    
    
    if self.spawned and self.invincible then
        self.invinTimer = self.invinTimer - DeltaTime
        if self.invinTimer < 0 then
            self.invinTimer = 3
            self.invincible = false
        end
    end
    
    
    self.timer = self.timer + DeltaTime
    self.arrowTimer = self.arrowTimer + DeltaTime/2
    if self.arrowTimer > 1 then
        self.arrowTimer = 0
    end
    
    if self.weapon == Weapons.flak then
        if self.needReload and self.timer > self.weapon.rate/3 then
            sound("Game Sounds One:Reload 1")
            self.needReload = false
        end
    end
    if self.timer > self.weapon.rate then
        self.timer = 0
        self.ready = true
        if self.firing then
            self:fire()
        end
        
    end
end


function Player:draw()
    -- positions the player and opponent if multi
    local offset = 0
    if self.side == -1 then
        offset = WIDTH/2
    end
    local p1offset
    local v = self.target.pos - self.pos
    if scene.multi then
        p1offset = vec2(offset + WIDTH/4, HEIGHT/2)
    else
        p1offset = vec2(offset + WIDTH/2, HEIGHT/2)
    end
    local p2offset = v + p1offset
    local pos = self.pos - p1offset
    
    -- draws all bullets
    for _, bullet in ipairs(scene.bullets) do
        bullet:draw(pos)
    end
    
    -- draws the red beam for railgun
    if self.aiming then
        local offset = vec2(0, -9):rotate(math.atan(self.dir.y, self.dir.x))
        
        stroke(255, 0, 0, 49)
        strokeWidth(10)
        local A = p1offset + offset + self.dir * 45
        local B = p1offset + offset + self.dir * self.weapon.range
        line(A.x, A.y, B.x, B.y)
    end
    if self.target.aiming then
        stroke(255, 0, 0, 49)
        strokeWidth(10)
        local A = p2offset + self.target.dir * 45
        local B = p2offset  + self.target.dir * self.target.weapon.range
        line(A.x, A.y, B.x, B.y)
    end
    
    strokeWidth(2)
    stroke(0, 0, 0, 255)
    
    pushMatrix()
    translate(p1offset.x, p1offset.y)
    
    -- shows opponent position indicator
    if self.target.spawned then
        local ang = math.atan2(v.y, v.x)
        self.arrow:setRect(self.arrowId, 0, 0, self.arrowTimer*250, self.arrowTimer*250, ang)
        self.arrow:setRectColor(self.arrowId, 255, 255, 255, 255-self.arrowTimer*255)
        self.arrow:draw()
    end
    
    -- display ammo and player
    fill(255)
    rotate(-90*self.side)
    text(self.ammo, 0, 50)
    rotate(90*self.side)
    self:render()
    popMatrix()
    
    if self.target.spawned then
        pushMatrix()
        translate(p2offset.x, p2offset.y)
        self.target:render()
        popMatrix()
    end
    --[[
    if self.showHit and self.shield > 0 then
        pushMatrix()
        translate(p1offset.x, p1offset.y)
        tint(255, 255, 255, 131)
        sprite("Project:shield", 0, 0, world.size)
        popMatrix()
    end
]]--

for _, animation in ipairs(scene.animations) do
animation:draw(pos)
end

self.showFlash = false
self.showHit = false
end

function Player:render()
-- draws light flash or player shadow
if self.showFlash then
if self.weapon == Weapons.blastgun then
    sprite("Project:blast2", 0, 0, 250, 250)
else
    sprite("Project:bullet", 0, 0, 250, 250)
end
else
sprite("Project:Shadow", 0, 0, 80, 96)
end

-- draws the player
if self.invincible then
rotate(math.atan(self.dir.y, self.dir.x)*180/math.pi)
if self.showFlash then
    if self.weapon == Weapons.blastgun then
        tint(255, 0, 201, 250)
    else
        tint(255, 255, 255, 250)
    end
    sprite("Project:muzzle", 73, -9)
end
if math.floor(self.invinTimer*5)%2==0 then
    self.model:draw()
end
else
-- display lifebar
local life = self.life*2.55
fill(255 - life, life, 0, 255)
rect(-self.side * 32, -self.life/4, 10, self.life/2)

-- display shield
local shield = self.shield*2.55
fill(0, 127, 255, 255)
rect(-self.side * 48, -self.shield/4, 10, self.shield/2)

rotate(math.atan(self.dir.y, self.dir.x)*180/math.pi)
if self.showFlash then
    if self.weapon == Weapons.blastgun then
        tint(255, 0, 201, 250)
    else
        tint(255, 255, 255, 250)
    end
    sprite("Project:muzzle", 73, -9)
end
self.model:draw()
end
end

function Player:drawGUI()
if self.spawned then
self.moveStick:draw()
self.shootStick:draw()
end
end

-- sets status ("moving", "idle", etc...)
function Player:setStatus(status)
if self.status ~= status then
self.status = status
self.model.currentFrame = 1
end
end

-- handles pressing the fire button
function Player:fire(first)
-- first shot
if first then
self.firing = true
if self.ready then
    self.showFlash = true
    self.timer = 0
end
end

-- weapon ready to fire
if self.ready then
self.ammo = self.ammo - 1
self.showFlash = true

-- adds a bullet
local offset = vec2(0, -9):rotate(math.atan(self.dir.y, self.dir.x))
local spawn = self.pos + offset + self.dir * 45

if self.weapon == Weapons.blastgun or self.weapon == Weapons.flak then
    local x, y = math.floor(spawn.x/world.size) + 1, math.floor(spawn.y/world.size) + 1
    if world.map[x][y].solid then
        spawn = self.pos + offset - self.dir * 5
    end
    
end

table.insert(self.scene.bullets, Bullet(self, spawn.x, spawn.y, self.weapon))

-- or 10 for the flak
if self.weapon == Weapons.flak then
    for i=1, 9 do
        table.insert(self.scene.bullets, Bullet(self, spawn.x, spawn.y, self.weapon))
    end
    self.needReload = true
    for i=1, 4 do
        sound("Game Sounds One:Pistol")
    end
elseif self.weapon == Weapons.railgun then
    for i=1, 10 do
        sound("Game Sounds One:Blaster")
    end
elseif self.weapon == Weapons.blastgun then
    sound("Game Sounds One:Blaster")
elseif self.weapon == Weapons.rocketlauncher then
    sound("A Hero's Quest:FireBall Blast 1", .5)
else
    sound("Game Sounds One:Pistol")
end
end
self.ready = false
end