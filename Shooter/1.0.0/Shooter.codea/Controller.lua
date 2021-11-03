--# Controller
Controller = class()

function Controller:init(owner, moveStick)
    self.isMoveStick = moveStick
    self.owner = owner
    self.active = false
    self.moving = false
    self.pos = vec2()
    self.origin = vec2()
    self.dist = 0
    self.lastDir = vec2(1, 0)
end

function Controller:draw()
    if self.active then
        
        local vec = (self.pos - self.origin)
        
        local dir = vec2(0,0)
        if vec ~= dir then
            dir = vec:normalize()
        else
            dir = self.lastDir
        end
        
        if self.isMoveStick then
            local val = self.owner.speed * self.dist/50 * 60*DeltaTime
            self.owner:move(dir, val)
            
            if self.owner.shootStick.moving == false then
                self.owner.dir =  dir
            end
        else
            if self.moving then
                self.owner.dir = dir                
            end
        end
        
        self.lastDir = dir
        
        sprite("Project:stick", self.pos.x, self.pos.y)
        sprite("Project:stick_bg", self.origin.x, self.origin.y)
    end
end

function Controller:touched(touch)
    self.active = true
    if touch.state == BEGAN then
        if not self.isMoveStick then
            if self.owner.weapon == Weapons.railgun then
                self.owner.aiming = true
            else
                self.owner:fire(true)
            end
        end
        self.origin.x = touch.x
        self.origin.y = touch.y
    end
    
    self.pos.x = touch.x
    self.pos.y = touch.y
    
    self.dist = self.pos:dist(self.origin)
    
    if self.dist > 10 then 
        self.moving = true
    end
    
    if self.isMoveStick then
        if self.dist > 15 then
            self.dist = self.dist - 15
            self.owner:setStatus("moving")
        else
            self.dist = 0
            self.owner:setStatus("idle")
        end
    end
    
    if touch.state == ENDED then
        self.active = false
        self.moving = false
        if self.isMoveStick then
            self.owner:setStatus("idle")
        else
            if self.owner.weapon == Weapons.railgun then
                self.owner.aiming = false
                self.owner:fire(true)
            end
            self.owner.firing = false
        end
    end
    
    if self.dist > 50 then self.dist = 50 end
end