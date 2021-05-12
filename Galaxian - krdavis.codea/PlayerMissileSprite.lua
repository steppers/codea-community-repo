-----------------
--  Galaxian   --
-----------------

-- Keith Davis --
--  (c) 2021   --
--  ZuniSoft   --

PlayerMissileSprite = class()

function PlayerMissileSprite:init(x, y, w, h, f)
    -- you can accept and set parameters here
    self.x = x
    self.y = y
    self.locRect = Rectangle(x, y, w, h)
    self.faces = f
    self.currFace = 1
    self.alive = true
    self.type = 0
    self.classType = "PlayerMissileSprite"
    self.MOVEMENT_SPEED = 10 * Global.SCALE
    self.missileFired = false
end

function PlayerMissileSprite:getCurrFace()
    if self.currFace < 1 or self.currFace > #self.faces then
        return self.faces[1]
    end
    return self.faces[self.currFace]
end

function PlayerMissileSprite:update()
    if Global.fire == true and self.missileFired == false then
        self.missileFired = true
        self.type = Global.PMISSILE_TYPE
        Global.playerFired = true
    end
    
    if self.missileFired then
        self.locRect.y = self.locRect.y + self.MOVEMENT_SPEED
        self.y = self.locRect.y
        if self.locRect.y > Global.SCREEN_HEIGHT then
            self.alive = false
        end
    else
        self.locRect.x = Global.playerx
        self.x = self.locRect.x
        self.y = self.locRect.y
    end
    if Global.playerAlive == false then
        self.alive = false
    end
end

function PlayerMissileSprite:getCollisionRect()
    return self.locRect
end


function PlayerMissileSprite:died()
    if Global.playerAlive then
        Global.loadAnotherMissile = true
    else
        Global.loadAnotherMissile = false
    end
end
