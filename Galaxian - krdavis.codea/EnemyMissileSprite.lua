-----------------
--  Galaxian   --
-----------------

-- Keith Davis --
--  (c) 2021   --
--  ZuniSoft   --

EnemyMissileSprite = class()

function EnemyMissileSprite:init(x, y, w, h, f)
    -- you can accept and set parameters here
    self.x = x
    self.y = y
    self.locRect = Rectangle(x, y, w, h)
    self.faces = f
    self.currFace = 1
    self.alive = true
    self.type = Global.EMISSILE_TYPE
    self.classType = "EmemyMissileSprite"
    self.MOVEMENT_SPEED = (5.0 * Global.SCALE)
end

function EnemyMissileSprite:getCurrFace()
    if self.currFace < 1 or self.currFace > #self.faces then
        return self.faces[1]
    end
    return self.faces[self.currFace]
end

function EnemyMissileSprite:update()    
    self.locRect.y = self.locRect.y - self.MOVEMENT_SPEED
    self.y = self.locRect.y
    if self.locRect.y < 0 then
        self.alive = false
    end
end


function EnemyMissileSprite:getCollisionRect()
    return self.locRect
end

function EnemyMissileSprite:died()
end
