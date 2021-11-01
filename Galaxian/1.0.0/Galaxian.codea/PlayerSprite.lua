-----------------
--  Galaxian   --
-----------------

-- Keith Davis --
--  (c) 2021   --
--  ZuniSoft   --

PlayerSprite = class()

function PlayerSprite:init(x, y, w, h, f)
    -- you can accept and set parameters here
    self.x = x
    self.y = y
    self.locRect = Rectangle(x, y, w, h)
    self.faces = f
    self.currFace = 1
    self.alive = true
    self.type = Global.PLAYER_TYPE
    self.classType = "PlayerSprite"
    self.MOVEMENT_SPEED = 2.0 * Global.SCALE
    Global.playerAlive = true
end

function PlayerSprite:getCurrFace()
    if self.currFace < 1 or self.currFace > #self.faces then
        return self.faces[1]
    end
    return self.faces[self.currFace]
end

function PlayerSprite:getCollisionRect()
    return self.locRect
end

function PlayerSprite:update()
    if Global.direction == Global.MOVELEFT then
        self.locRect.x = self.locRect.x - self.MOVEMENT_SPEED
        if self.locRect.x < 0 then
            self.locRect.x = 0
        end
        self.x = self.locRect.x
        Global.playerx = self.x + Global.PLAYER_X_TWEEK
    elseif Global.direction == Global.MOVERIGHT then
        self.locRect.x = self.locRect.x + self.MOVEMENT_SPEED
        if self.locRect.x > Global.SCREEN_WIDTH - self.locRect.w then
            self.locRect.x = Global.SCREEN_WIDTH - self.locRect.w
        end
        self.x = self.locRect.x
        Global.playerx = self.x + Global.PLAYER_X_TWEEK
    end
end

function PlayerSprite:died()
    Global.playerAlive = false
end
