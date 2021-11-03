-- Originally written by u/UberGoober 
-- (https://codea.io/talk/discussion/6855)

-- Modified by Théo Arrouye

SwipeColorPicker = class()

function SwipeColorPicker:init(x, y, size)
    self.hsv = vec4(0.7, 0.7, 0.7, 0.8)
    self.color = self:updateRGB()
    self.size = size
    self.position = vec2(x,y)
    self.strokeSize = 3
    self.active = false
    self.sizePickerMode = false
    self.noSizePick = true
end

function SwipeColorPicker:swipeHorizontal(amount)
    amount = amount / WIDTH
    self:hsvShift(amount, 0)
end

function SwipeColorPicker:hsvShift(h,v)
    self.hsv.x = self.hsv.x + h
    if self.hsv.y < 1 then
        self.hsv.y = self.hsv.y - v 
        if self.hsv.y < 0 then
            self.hsv.y = 0
        end
        if self.hsv.y > 1 then
            self.hsv.z = self.hsv.z - math.fmod(self.hsv.y, 1)
            self.hsv.y = 1
        end
    else 
        self.hsv.z = self.hsv.z + v
        if self.hsv.z > 1 then
            self.hsv.y = self.hsv.y -  math.fmod(self.hsv.z, 1)
            self.hsv.z = 1
        end
    end
    self:updateRGB()
end

function SwipeColorPicker:swipeVertical(amount)
    amount = amount / HEIGHT * 3
    self:hsvShift(0, amount)
end

function SwipeColorPicker:draw()
    -- Codea does not automatically call this method
    -- background(self.color)
    pushStyle()
    ellipseMode(CENTER)
    
    noStroke()
    -- the bezels
    fill(255, 255, 255, 255)
    if self.active then
        fill(197, 167, 167, 255)
    end
    if self.sizePickerMode then
        fill(255 - self.color.r, 255 - self.color.g, 255 - self.color.b)
    end
    ellipse(self.position.x, self.position.y, self.size * 1.1)
    
    -- the color
    fill(self.color)
    ellipse(self.position.x, self.position.y, self.size)
    if self.sizePickerMode and not self.noSizePick then
        stroke(self.color)
        strokeWidth(self.strokeSize) 
        line(self.position.x - WIDTH / 20,self.position.y + self.strokeSize / 2 + self.size - (self.size / 3),
        self.position.x + WIDTH / 20,self.position.y + self.strokeSize / 2 + self.size - (self.size / 3))
        strokeWidth(0)
    end
    popStyle()    
end

function SwipeColorPicker:touched(touch)
    local insideCircle
    if touch.state == BEGAN then
        local radius = self.size * 0.5
        local closeEnoughX = math.abs(touch.x-self.position.x) < radius
        local closeEnoughY = math.abs(touch.y-self.position.y) < radius
        if closeEnoughX and closeEnoughY then
            self.active = true
        end
    end
    if self.active then
        if touch.tapCount == 2 and self.sizePickerMode == false then
            self.sizePickerMode = true
        end
        if self.sizePickerMode then
            self.strokeSize = self.strokeSize + touch.deltaY
            if self.strokeSize < 0.5 then
                self.strokeSize =  0.5
            end
        else
            if math.abs(touch.deltaX) > math.abs(touch.deltaY) then
                self:swipeHorizontal(touch.deltaX)
            else
                self:swipeVertical(touch.deltaY)
            end
        end
        if touch.state == ENDED then
            self.active = false
            self.sizePickerMode = false
        end
    end
    
    return self.active or touch.state == ENDED
end

function SwipeColorPicker:updateRGB()
    self.color = color(self:hsvToRGB(self.hsv.x, self.hsv.y,self.hsv.z))
    return self.color
end

function SwipeColorPicker:hsvToRGB(h, s, v)
    --thanks to SkyTheCoder on the Codea forums
    local r, g, b

    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)

    local switch = i % 6

    if switch == 0 then
        r = v
        g = t
        b = p
    elseif switch == 1 then
        r = q
        g = v
        b = p
    elseif switch == 2 then
        r = p
        g = v
        b = t
    elseif switch == 3 then
        r = p
        g = q
        b = v
    elseif switch == 4 then
        r = t
        g = p
        b = v
    elseif switch == 5 then
        r = v
        g = p
        b = q
    end

    return math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)
end
