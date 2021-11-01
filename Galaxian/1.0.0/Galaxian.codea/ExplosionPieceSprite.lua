-----------------
--  Galaxian   --
-----------------

-- Keith Davis --
--  (c) 2021   --
--  ZuniSoft   --

ExplosionPieceSprite = class()

function ExplosionPieceSprite:init(x, y, w, h, f)
    -- you can accept and set parameters here
    self.x = x
    self.y = y
    self.locRect = Rectangle(x, y, w, h)
    self.faces = f
    self.currFace = 1
    self.alive = true
    self.type = 0
    self.classType = "ExplosionPieceSprite"
    self.MAX_SPEED = 10.0 * Global.SCALE
    self.s = (math.random(0) * (self.MAX_SPEED - 2.0)) + 2
    self.deg = (math.random(0) * 360.0)
    self.rad = self.deg * 3.14 / 180.0
    self.dy = math.cos(self.rad) * self.s
    self.dx = math.sin(self.rad) * self.s
    self.cnt = 0
end

function ExplosionPieceSprite:getCurrFace()
    if self.currFace < 1 or self.currFace > #self.faces then
        return self.faces[1]
    end
    return self.faces[self.currFace]
end

function ExplosionPieceSprite:update()
    if (self.cnt%3 == 0) then
        self.currFace = self.currFace + 1
        if self.currFace >= #self.faces then
            self.alive = false
        end
    end
    self.locRect.x = self.locRect.x + self.dx
    self.locRect.y = self.locRect.x + self.dy
    if (self.locRect.x + self.locRect.w> Global.SCREEN_WIDTH or
        self.locRect.x < 0 or self.locRect.y + self.locRect.h > Global.SCREEN_HEIGHT or self.locRect.y < 0) then
        self.alive = false
    end
    self.cnt = self.cnt + 1
end

function ExplosionPieceSprite:getCollisionRect()
    return self.locRect
end
   
function ExplosionPieceSprite:died()
end