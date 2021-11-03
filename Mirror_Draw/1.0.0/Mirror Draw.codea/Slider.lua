-- Copyright 2017 Théo Arrouye

Slider = class()

function Slider:init(variable, min, max, x, y, callback, len)
    self.variable, self.label = variable, variable
    self.unitsLabel = ""
    self.x, self.y = x, y
    local init = _G[variable] or min
    print(init)
    print(variable)
    init = math.max(math.min(init, max), min)
    self.min, self.max = min, max
    self.prevValue, self.curValue = init, init
    self.callback = callback
    self.length = len or 250
    self.sliderX = self:convertValueToCoordinate(self.curValue)
    self.textFill = color(255, 151, 0, 255)
    self.baseFill = color(111, 31, 31, 255) --color(127)
    self.filledFill = color(0, 83, 255, 255)
    self.circleFill = color(208, 208, 208, 255)
    self.fS, self.fN = 30, "Futura-CondensedExtraBold"
    self.sW, self.cS = 25, 40
    self:updateValue()
end

function Slider:setLabel(label)
    self.label = label .. ":"
end

function Slider:setUnitsLabel(lbl)
    self.unitsLabel = lbl
end

function Slider:draw()
    pushStyle()
    fontSize(self.fS) font(self.fN)
    strokeWidth(self.sW) stroke(self.baseFill)
    line(self.x - self.length/2, self.y, self.x + self.length/2, self.y)
    strokeWidth(self.sW) stroke(self.filledFill)
    line(self.x - self.length/2, self.y, self.sliderX, self.y)
    stroke(self.filledFill)
    if self.touching then fill(self.filledFill) else fill(self.circleFill) end
    strokeWidth(4)
    ellipse(self.sliderX, self.y, self.cS)
    fill(self.textFill)
    local vn = self:getDispVal() .. self.unitsLabel
    local w,h = textSize(vn)
    text(vn, self.x + self.length/2 + 10 - w/2, self.y + 20 + h/2)
    local w,h = textSize(self.label)
    text(self.label, self.x - self.length/2 - 10 + w/2, self.y + 20 + h/2)
    popStyle()

    if self.touching then
        self:moveSlider()
    else
        if self.curValue ~= _G[self.variable] then
            self.curValue = _G[self.variable]
            self.sliderX = self:convertValueToCoordinate(self.curValue)
        end
    end
end

function Slider:touched(touch)
    if touch.x > self.sliderX - self.cS*1.25 and touch.x < self.sliderX + self.cS*1.25
    and touch.y > self.y - self.cS*1.25 and touch.y < self.y + self.cS*1.25 
    and touch.state == BEGAN then
        self.touching = true
    end
    
    if touch.state == ENDED then
        if self.jumpToTouch then
            if touch.x > self.x - self.length/2 and touch.x < self.x + self.length/2
            and touch.y > self.y - self.cS*1.25 and touch.y < self.y + self.cS*1.25 then
                self:moveSlider()
            end
        end
        self.touching = false
        self.sliderX = self:convertValueToCoordinate(self.curValue)
    end
    
    return (self.touching or touch.state == ENDED)
end

function Slider:convertValueToCoordinate(v)
    return ((v - self.min) / (self.max - self.min)) * self.length + self.x - self.length / 2
end
  
function Slider:convertCoordinateToValue(x)
    local n = 2 * (((x - (self.x - self.length / 2)) / self.length)
        * (self.max - self.min) + self.min)
    return (math.floor(n + 0.5)) / 2
end

function Slider:getDispVal()
    return self.curValue
end

function Slider:moveSlider()
    self.sliderX = math.max(math.min(CurrentTouch.x, self.x + self.length/2), self.x - self.length/2)
    --self.curValue = self.min - 1 + math.floor((((self.sliderX - (self.x - self.length/2)) / self.length) * (self.max - 1) + 1) + 0.49)
    self.curValue = self:convertCoordinateToValue(self.sliderX)
    if self.curValue ~= self.prevValue then
        self:updateValue()
        self.prevValue = self.curValue
        if self.callback ~= nil then
            self.callback()
        end
    end
end

function Slider:updateValue()
    _G[self.variable] = self.curValue
end
