-----------------
--  Galaxian   --
-----------------

-- Keith Davis --
--  (c) 2021   --
--  ZuniSoft   --

Score300Sprite = class()

function Score300Sprite:init(x, y, w, h, f)
    -- you can accept and set parameters here
    self.x = x
    self.y = y
    self.locRect = Rectangle(x, y, w, h)
    self.faces = f
    self.currFace = 1
    self.alive = true
    self.type = 0
    self.classType = "Score300Sprite"
    self.cnt = 0
end

function Score300Sprite:getCurrFace()
    if self.currFace < 1 or self.currFace > #self.faces then
        return self.faces[1]
    end
    return self.faces[self.currFace]
end

function Score300Sprite:update()
    tween.delay(2, function()
        if self.cnt%3 == 0 then
            self.currFace = self.currFace + 1
            if self.currFace >= #self.faces then
                self.alive = false
            end
        end
    end)
    self.cnt = self.cnt + 1 
end

function Score300Sprite:getCollisionRect()
    return self.locRect
end

function Score300Sprite:died()
end
