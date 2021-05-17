-- Copyright 2015 Théo Arrouye

Button = class()

function Button:init(img, x, y, callback, xsize, ysize)
    self.img = img
    self.x = x
    self.y = y
    if ysize ~= nil then
        self.size = vec2(xsize, ysize)
    else
        self.size = vec2(xsize, 0)
        self.size.y = (xsize / self.pressedImg.width) * self.pressedImg.height
    end
    self.drawSize = self.size
    self.callback = callback
    self.pressed = false
    self.tint = color(127)
end

function Button:draw()
    pushStyle()
    --noSmooth()
    if self.pressed then
        tint(self.tint)
    end
    sprite(self.img, self.x, self.y, self.drawSize.x, self.drawSize.y)
    popStyle()
end

function Button:touched(touch)
    if touch.x > self.x - self.size.x/2 and touch.x < self.x + self.size.x/2 and
    touch.y > self.y - self.size.y/2 and touch.y < self.y + self.size.y/2 then
        if touch.state == BEGAN or touch.state == MOVING then
            self.pressed = true
        elseif touch.state == ENDED then
            self.pressed = false
            self.callback()
        end
    else
        self.pressed = false
    end
end



textButton = class()

function textButton:init(txt, x, y, callback, fs, fn, col, left)
    self.txt = txt or ""
    self.x = x or 0
    self.y = y or 0
    self.callback = callback
    self.pressed = false
    self.fontSize = fs or fontSize()
    self.fontName = fn or "Futura-CondensedExtraBold"
    self.tint = color(65)
    self.fill = col or color(255, 151, 0, 255)

    if left then
        fontSize(self.fontSize)
        font(self.fontName)
        self.x = x + textSize(self.txt) / 2
    end
end

function textButton:draw()
    pushStyle()
    if self.pressed then
        fill(self.tint)
    elseif self.fill ~= nil then
        fill(self.fill)
    end
    fontSize(self.fontSize)
    font(self.fontName)
    self.w, self.h = textSize(self.txt)
    text(self.txt, self.x, self.y)
    popStyle()
end

function textButton:touched(touch)
    if touch.x > self.x - self.w/2 and touch.x < self.x + self.w/2 and
    touch.y > self.y - self.h/2 and touch.y < self.y + self.h/2 then
        if touch.state == BEGAN or touch.state == MOVING then
            self.pressed = true
        elseif touch.state == ENDED then
            self.pressed = false
            self.callback()
        end
    else
        self.pressed = false
    end
end
