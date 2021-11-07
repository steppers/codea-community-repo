SingleSlider = class()

function SingleSlider:init(name, pos, size, value)
    
    self.label = {
        name=name,
    }
    self.color = {
        label=color(255),
        rail=color(55),
        bar=color(125)
    }
    self.pos = pos
    self.size = size
    self.value = {
        current=0.125,
        min=0.0,
        max=1.0,
        unit="",
        format="%.1f"
    }
    self.radius = 9
    
end

function SingleSlider:draw()
    
    pushMatrix()
    pushStyle()
    
    fontSize(self.size.y/1.5)
    
    self.label.size = vec2(textSize(self.label.name))
    
    self.value.string = string.format(self.value.format, self.value.current)..self.value.unit
    self.value.size = vec2(textSize(self.value.string))
    
    --self.size.x = math.max(self.size.x, self.label.size.x+self.label.size.y+self.value.size.x)

    fill(self.color.rail)
    Shapes:roundedRect(self.pos.x, self.pos.y, self.size.x, self.size.y, self.radius)
    
    fill(self.color.bar)
    Clip:on(self.pos-vec2(1, 1), vec2(self.size.x * (self.value.current-self.value.min)/(self.value.max-self.value.min), self.size.y)+vec2(2, 2))
    Shapes:roundedRect(self.pos.x, self.pos.y, self.size.x, self.size.y, self.radius)
    Clip:off()
    
    fill(self.color.label)
    textMode(CENTER)
    textAlign(LEFT)
    text(self.label.name, self.pos.x+self.label.size.x/2+self.label.size.y/3, self.pos.y+self.size.y/2)
    textAlign(RIGHT)
    text(self.value.string, self.pos.x+self.size.x-self.value.size.x/2-self.value.size.y/3, self.pos.y+self.size.y/2)
    
    popStyle()
    popMatrix()
    
end

function SingleSlider:touched(touch)
    
    if touch.state == BEGAN and
    touch.pos.x >= self.pos.x and touch.pos.x <=  self.pos.x+self.size.x and
    touch.pos.y >= self.pos.y and touch.pos.y <= self.pos.y+self.size.y then
        self.held = true
    elseif touch.state == ENDED then
        self.held = false
    end
    
    if self.held then
        self.value.current = self.value.min+(touch.pos.x-self.pos.x)/self.size.x * (self.value.max-self.value.min)
    end
    
    self.value.current = Math:clamp(self.value.current, self.value.min, self.value.max)
    
end