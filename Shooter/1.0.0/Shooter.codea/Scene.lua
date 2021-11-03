--# Scene
Scene = class()

function Scene:init()
    self.multi = true
    self.players = {}
    self.bullets = {}
    self.animations = {}
    self.bulletIndex = nil
    self.animIndex = nil
    self.p1 = Player(self, 5*80, 22*80, 1)
    self.p2 = Player(self, 10*80, 7*80, -1)
    self.p1.target = self.p2
    self.p2.target = self.p1
    
    table.insert(self.players, self.p1)
    table.insert(self.players, self.p2)
    
    self.p1img = image(WIDTH/2, HEIGHT)
    self.p2img = image(WIDTH/2, HEIGHT)
end

function Scene:reset()
    self:init()
end

function Scene:update()
    -- update timers (respawns, etc...)
    world:update()
    self.p1:update()
    self.p2:update()
    
    -- process bullet collisions etc...
    self.bulletIndex = nil
    for index, bullet in ipairs(self.bullets) do
        if bullet.gone then
            self.bulletIndex = index
        else
            bullet:update()
        end
    end
    
    self.animIndex = nil
    for index, animation in ipairs(self.animations) do
        if animation.done then
            self.animIndex = index
        else
            animation:update()
        end
    end
    
    
end

function Scene:showStats(player)
    fill(0, 0, 0, 150)
    local offset = 0
    if player.side == -1 then
        offset = WIDTH/2
    end
    rect(offset, 0, WIDTH/2, HEIGHT)
    pushMatrix()
    fill(255, 0, 0, 255)
    translate(offset + WIDTH/4, HEIGHT/2)
    rotate(-90*player.side)
    fontSize(30)
    	if not player.spawned then
        		text("You died !", 0, 200)
    	end
    	
    text("Flag caps: " .. player.score.caps, 0, 100)
    text("Kills: " .. player.score.kills, 0, 0)
    text("Deaths: " .. player.score.deaths, 0, -100)
    	
    	if not player.spawned then
        		text("Respawning in " .. math.floor(player.spawnTimer*10)/10 .. "s", 0, -200)
    	end
    popMatrix()
end


function Scene:draw()
    -- if multi we use clip() to splitscreen
    if self.multi then
        clip(0, 0, WIDTH/2, HEIGHT)
    end
    world:draw(self.p1)
    if self.p1.spawned then
        self.p1:draw()
    else
        self:showStats(self.p1)
    end
    tint(255)
    
    if self.multi then
        clip(WIDTH/2, 0, WIDTH/2, HEIGHT)
        world:draw(self.p2)
        if self.p2.spawned then
            self.p2:draw()
        else
            self:showStats(self.p2)
        end
        tint(255)
        
        clip()
        
        --  vignette overlay and separation
        rotate(-90)
        sprite("Project:0001",  - HEIGHT/2, WIDTH/4, HEIGHT, WIDTH/2)
        rotate(180)
        sprite("Project:0001",   HEIGHT/2, -WIDTH/2 - WIDTH/4 , HEIGHT, WIDTH/2)
        rotate(-90)
        strokeWidth(2)
        stroke(0, 0, 0, 255)
        line(WIDTH/2, 1, WIDTH/2, HEIGHT)
    else
        sprite("Project:0001",  WIDTH/2, HEIGHT/2, WIDTH, HEIGHT)
    end
end

-- handle player controls
function Scene:touched(touch)
    if touch.x < WIDTH/2 then
        if self.p1.spawned then
            if touch.y < HEIGHT/2 then
                self.p1.shootStick:touched(touch)
            else
                self.p1.moveStick:touched(touch)
            end
        end
    else
        if self.p2.spawned then
            if touch.y < HEIGHT/2 then
                self.p2.moveStick:touched(touch)
            else
                self.p2.shootStick:touched(touch)
            end
        end
    end
    
    
end