-----------------
--  Galaxian   --
-----------------

-- Keith Davis --
--  (c) 2021   --
--  ZuniSoft   --

Button = class()

function Button:init(x, y, image,...)
    -- you can accept and set parameters here
    self.x = x
    self.y = y
    self.w = 32
    self.h = 32
    self.image = image
    local arg = {...}
    self.imageWidth = arg[1]
    self.imageHeight = arg[2]
    self.txt = arg[3]
    self.fnt = arg[4]
    self.fntSize = arg[5]
end

function Button:draw()
    if self.imageWidth then
        sprite(self.image, self.x, self.y, self.imageWidth, self.imageHeight)
        self.w = self.imageWidth
        self.h = self.imageHeight
    else
        sprite(self.image, self.x, self.y, self.w, self.h)
    end
    if self.txt ~= nil then
        pushStyle()
        fill(0, 0, 0, 255)
        font(self.fnt)
        fontSize(self.fntSize)
        text(self.txt, self.x, self.y)
        popStyle()
    end
end

function Button:touched(touch)
    if touch.state == BEGAN or touch.state == ENDED then
        if touch.x > self.x - self.w and touch.x < self.x + self.w and
        touch.y > self.y - self.h and touch.y < self.y + self.h then
            return true
        end
    end
    return false
end
