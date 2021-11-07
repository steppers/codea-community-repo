ColorCard = class()

function ColorCard:init(pos)
    
    self.pos = pos
    local sizeConstant = math.abs(WIDTH - HEIGHT)
    self.size = {x= sizeConstant * 0.5, y= sizeConstant * 0.8}
    
    local luc = {}
    for v in string.gmatch(readLocalData("last_used_color", "210(36, 84)"), "[^(,)]+") do
        table.insert(luc, tonumber(v))
    end
    
    local initial_hsb = vec3(table.unpack(luc))
    local initial_rgb = ColorConverter:hsb2rgb(initial_hsb)
    
    self.size.min = math.min(self.size.x, self.size.y)
    self.colChooser = colorChooser(self.pos, self.size.min-36, "WHEEL")
    self.colChooser.color.current = initial_rgb
    self.colChooser.angle.previous, self.colChooser.saturation_and_brightness.current.x, self.colChooser.saturation_and_brightness.current.y = initial_hsb:unpack()
    
    local hsbLabels = {
        "Hue",
        "Saturation",
        "Brightness"
    }
    
    self.colorPanel = MultiSlider("HSB Sliders", hsbLabels, self.pos, vec2(self.size.min-36, self.size.min/(35/26)))
    
    self.colorPanel.hsbsliders.label.gap = 18
    self.colorPanel.hsbsliders.color.box = color(75)
    self.colorPanel.hsbsliders.color.label = color(225)
    for name, slider in pairs(self.colorPanel.hsbsliders) do
        if self.colorPanel.hsbsliders.index[name] ~= nil then
            slider.color.rail = color(55)
            slider.color.bar = color(125)
            slider.color.label = color(225)
            slider.value.format = "%.0f"
            if self.colorPanel.hsbsliders.index[name] > 1 then
                slider.value.unit = "%"
                slider.value.max = 100.0
            else
                slider.value.unit = "º"
                slider.value.max = 360.0
            end
        end
    end
    self.colorPanel.hsbsliders.hue.value.current, self.colorPanel.hsbsliders.saturation.value.current, self.colorPanel.hsbsliders.brightness.value.current = initial_hsb:unpack()
    
    local rgbLabels = {
        "Red",
        "Green",
        "Blue"
    }
    
    self.colorPanel = MultiSlider("RGB Sliders", rgbLabels, self.pos, vec2(self.size.min-36, self.size.min/(35/26)))
    
    self.colorPanel.rgbsliders.label.gap = 18
    self.colorPanel.rgbsliders.color.box = color(75)
    self.colorPanel.rgbsliders.color.label = color(225)
    for name, slider in pairs(self.colorPanel.rgbsliders) do
        if self.colorPanel.rgbsliders.index[name] ~= nil then
            slider.color.rail = color(55)
            slider.color.bar = color(125)
            slider.color.label = color(225)
            slider.value.format = "%.0f"
            slider.value.max = 255
        end
    end
    self.colorPanel.rgbsliders.red.value.current, self.colorPanel.rgbsliders.green.value.current, self.colorPanel.rgbsliders.blue.value.current = initial_rgb:unpack()
    
    self.heights = {
        63,
        81+self.colChooser.size/0.5,
        99+self.colChooser.size/0.5+self.colorPanel.hsbsliders.size.y,
        self.size.y
    }
    
    local initial_state = readLocalData("initial_state", 4)
    
    self.size.y = self.heights[initial_state]
    
    self.card = {
        handle={
            held=false,
            moved=false,
            color={
                table={55, 255},
                current=nil,
            },
            position_and_size=vec4(0,0,0,0)
        },
        state={
            current=initial_state,
            previous=initial_state,
            next=initial_state
        },
        transition=Timer(0.125),
        fader=0.0
    }
    
    self.card.state.previous = readLocalData("previous_state", initial_state)
    self.card.handle.color.current = self.card.handle.color.table[Math:clamp(initial_state, 1, 2)]
    
end

function ColorCard:draw()
    
    pushMatrix()
    pushStyle()
    
    if not self.card.transition:complete() then
        self.card.fader = self.card.transition.count/self.card.transition.interval
    end
    
    if not self.card.handle.held then
        local fader = self.card.fader * (self.card.fader - 2) * -0.25
        self.size.y = Math:mix(
            self.size.y,
            Math:multiMix(self.heights, self.card.state.current/table.maxn(self.heights)),
            fader
        )
        self.card.handle.color.current = Math:mix(
            self.card.handle.color.current,
            Math:multiMix(self.card.handle.color.table, self.card.state.current/2),
            fader/0.5
        )
    end
    
    self.size.y = Math:clamp(self.size.y, self.heights[1], HEIGHT-45)
    
    Shapes:roundedRect(self.pos.x, self.pos.y, self.size.x, self.size.y, 36)
    
    Clip:on(self.pos, self.size)
    
    self.card.handle.position_and_size = vec4(self.pos.x+self.size.x/2-18, self.pos.y+self.size.y-9, self.pos.x+self.size.x/2+18, self.pos.y+self.size.y-9)
    
    strokeWidth(5)
    stroke(self.card.handle.color.current)
    line(self.card.handle.position_and_size:unpack())
    noStroke()
    
    font("ArialRoundedMTBold")
    fontSize(self.size.x * 0.15)
    local title = "Colors"
    local tW, tH = textSize(title)
    
    fill(225)
    textMode(CENTER)
    text(title, self.pos.x+ (tW * 0.65), self.pos.y+self.size.y-(tW * 0.45))
    
    fill(self.colChooser.color.current:unpack())
  
    local rrW, rrH = tW * 0.6, tH * 0.85
    Shapes:roundedRect(
    self.pos.x+self.size.x-(rrW * 1.25), 
    self.pos.y+self.size.y-(rrH * 1.95), 
    rrW, rrH, rrH * 0.5)
    
    self.colChooser.pos = self.pos+vec2(0.5, 0.5) * self.size.min+vec2(0, self.size.y-self.size.min-45)
    self.colChooser:draw()
    
    if -- if Color Chooser is active --
    self.colChooser.picker.hue.held
    or self.colChooser.picker.saturation_and_brightness.held
    then
        
        self.colorPanel.hsbsliders.hue.value.current = self.colChooser.angle.current
        self.colorPanel.hsbsliders.saturation.value.current = self.colChooser.saturation_and_brightness.current.x
        self.colorPanel.hsbsliders.brightness.value.current = self.colChooser.saturation_and_brightness.current.y
        fHSB = ColorConverter:hsb2rgb(vec3(self.colChooser.angle.current, self.colChooser.saturation_and_brightness.current:unpack()))
        self.colorPanel.rgbsliders.red.value.current = fHSB.x
        self.colorPanel.rgbsliders.green.value.current = fHSB.y
        self.colorPanel.rgbsliders.blue.value.current = fHSB.z
        
    elseif -- if HSB sliders are active --
    self.colorPanel.hsbsliders.hue.held
    or self.colorPanel.hsbsliders.saturation.held
    or self.colorPanel.hsbsliders.brightness.held
    then
        
        self.colChooser.angle.previous = self.colorPanel.hsbsliders.hue.value.current
        self.colChooser.saturation_and_brightness.current = vec2(self.colorPanel.hsbsliders.saturation.value.current, self.colorPanel.hsbsliders.brightness.value.current)
        fHSB = ColorConverter:hsb2rgb(vec3(self.colorPanel.hsbsliders.hue.value.current, self.colorPanel.hsbsliders.saturation.value.current, self.colorPanel.hsbsliders.brightness.value.current))
        self.colorPanel.rgbsliders.red.value.current = fHSB.x
        self.colorPanel.rgbsliders.green.value.current = fHSB.y
        self.colorPanel.rgbsliders.blue.value.current = fHSB.z
        
    elseif -- if RGB sliders are active --
    self.colorPanel.rgbsliders.red.held
    or self.colorPanel.rgbsliders.green.held
    or self.colorPanel.rgbsliders.blue.held
    then
        
        local fRGB = ColorConverter:rgb2hsb(vec3(self.colorPanel.rgbsliders.red.value.current, self.colorPanel.rgbsliders.green.value.current, self.colorPanel.rgbsliders.blue.value.current))
        if (self.colorPanel.rgbsliders.red.value.current+self.colorPanel.rgbsliders.green.value.current+self.colorPanel.rgbsliders.blue.value.current)/3 >= 255 then
            fRGB.x = self.colChooser.angle.previous
        end
        self.colChooser.angle.previous = fRGB.x
        self.colChooser.saturation_and_brightness.current = vec2(fRGB.y, fRGB.z)
        self.colorPanel.hsbsliders.hue.value.current = fRGB.x
        self.colorPanel.hsbsliders.saturation.value.current = fRGB.y
        self.colorPanel.hsbsliders.brightness.value.current = fRGB.z
        
    end
    
    --- HSB Sliders ---
    
    self.colorPanel.hsbsliders.pos = self.pos+vec2(18, self.size.y-self.colChooser.size/0.5-self.colorPanel.hsbsliders.size.y-81)
    self.colorPanel:draw("hsbsliders")
    
    for name, i in pairs(self.colorPanel.hsbsliders.index) do
        for j = 0, 360 do
            if i == self.colorPanel.hsbsliders.index["hue"]then
                fill(ColorConverter:hsb2rgb(vec3(j, 100.0, 100.0)):unpack())
            elseif i == self.colorPanel.hsbsliders.index["saturation"] then
                fill(ColorConverter:hsb2rgb(vec3(self.colorPanel.hsbsliders.hue.value.current, j/3.6, self.colorPanel.hsbsliders.brightness.value.current)):unpack())
            else
                fill(ColorConverter:hsb2rgb(vec3(self.colorPanel.hsbsliders.hue.value.current, self.colorPanel.hsbsliders.saturation.value.current, j/3.6)):unpack())
            end
            ellipse(
                self.colorPanel.hsbsliders[name].pos.x+2.25+(self.colorPanel.hsbsliders[name].size.x-4.5) * j/360,
                self.colorPanel.hsbsliders[name].pos.y-9,
                4.5
            )
        end
    end
    
    --- RGB Sliders ---
    
    self.colorPanel.rgbsliders.pos = self.pos+vec2(18, self.size.y-self.colChooser.size/0.5-self.colorPanel.rgbsliders.size.y/0.5-99)
    self.colorPanel:draw("rgbsliders")
    
    for name, i in pairs(self.colorPanel.rgbsliders.index) do
        for j = 0, 255 do
            if i == self.colorPanel.rgbsliders.index["red"]then
                fill(j, self.colorPanel.rgbsliders.green.value.current, self.colorPanel.rgbsliders.blue.value.current)
            elseif i == self.colorPanel.rgbsliders.index["green"] then
                fill(self.colorPanel.rgbsliders.red.value.current, j, self.colorPanel.rgbsliders.blue.value.current)
            else
                fill(self.colorPanel.rgbsliders.red.value.current, self.colorPanel.rgbsliders.green.value.current, j)
            end
            ellipse(
                self.colorPanel.rgbsliders[name].pos.x+2.25+(self.colorPanel.rgbsliders[name].size.x-4.5) * j/255,
                self.colorPanel.rgbsliders[name].pos.y-9,
                4.5
            )
        end
    end
    
    Clip:off()
    
    popStyle()
    popMatrix()
    
end

function ColorCard:touched(touch)
    
    if touch.state ~= ENDED then
        
        if touch.state == BEGAN
        and touch.x > self.card.handle.position_and_size.x-126 and touch.x < self.card.handle.position_and_size.z+126
        and touch.y > self.card.handle.position_and_size.y-18 and touch.y < self.card.handle.position_and_size.w+18
        and self.card.state.current ~= 1 then
            self.card.handle.held = true
        end
        
    else
        
        if touch.x > self.pos.x and touch.x < self.pos.x+self.size.x
        and touch.y > self.pos.y and touch.y < self.pos.y+self.size.y
        and self.card.state.current == 1 then
            self.card.state.current = self.card.state.previous
        end
        
        self.card.handle.held = false
        
        self.card.transition:start()
        
    end
    
    if self.card.handle.held then
        
        self.size.y = touch.y-self.pos.y+9
        
        if self.size.y < self.heights[self.card.state.next]-45 then
            self.card.state.next = self.card.state.next - 1
        elseif self.size.y > self.heights[self.card.state.next]+45 then
            self.card.state.next = self.card.state.next + 1
        elseif self.card.state.next == 1 then
            self.card.state.previous = self.card.state.current
        end
        
        self.card.state.next = Math:clamp(self.card.state.next, 1, table.maxn(self.heights))
        
        self.card.handle.moved = true
        
    elseif self.card.handle.moved then
        
        self.card.state.current = self.card.state.next
        
        self.card.handle.moved = false
        
    else
    
    self.colChooser:touched(touch)
    self.colorPanel:touched(touch, "hsbsliders")
    self.colorPanel:touched(touch, "rgbsliders")
        
    end
    
    saveLocalData("previous_state", self.card.state.previous)
    saveLocalData("initial_state", self.card.state.current)
    saveLocalData("last_used_color", self.colChooser.angle.current..tostring(self.colChooser.saturation_and_brightness.current))
    
end
