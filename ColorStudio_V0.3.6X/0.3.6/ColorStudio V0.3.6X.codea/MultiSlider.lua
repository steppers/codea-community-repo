MultiSlider = class()

function MultiSlider:init(name, sliders, pos, size)
    
    local variable = string.lower(string.gsub(name, "%s", ""))
    
    self = MultiSlider
    
    self[variable] = {}
    self[variable].index = {}
    for i, name in ipairs(sliders) do
        self[variable][string.lower(name)] = SingleSlider(name)
        self[variable].index[string.lower(name)] = i
        self[variable].numberOfSlider = i
    end
    
    self[variable].pos = pos
    self[variable].size = size
    self[variable].radius = 18
    self[variable].label = {
        name=name,
        gap = 9
    }
    self[variable].color = {}
    
end

function MultiSlider:draw(variable)
    
    pushMatrix()
    pushStyle()
    
    fill(self[variable].color.box)
    Shapes:roundedRect(self[variable].pos.x, self[variable].pos.y, self[variable].size.x, self[variable].size.y, self[variable].radius)
    
    local spacing = Spacer:vertical(self[variable].pos+vec2(9, 0), self[variable].size-vec2(18, 0), self[variable].label.gap, self[variable].numberOfSlider+1)
    
    for name, slider in pairs(self[variable]) do
        if self[variable].index[name] ~= nil then
            local i = self[variable].numberOfSlider+1-self[variable].index[name]
            slider.pos = vec2(spacing[i].x, spacing[i].y)
            slider.size = vec2(spacing[i].z, spacing[i].w)
            slider.radius = self[variable].radius/2
            slider:draw()
        end
    end
    
    fill(self[variable].color.label)
    fontSize(spacing[self[variable].numberOfSlider+1].w/1.25)
    textMode(CENTER)
    self[variable].label.size = vec2(textSize(self[variable].label.name))
    text(
        self[variable].label.name,
        spacing[self[variable].numberOfSlider+1].x+self[variable].label.size.x/2,
        spacing[self[variable].numberOfSlider+1].y+self[variable].label.size.y/2
    )
    
    popStyle()
    popMatrix()
    
end

function MultiSlider:touched(touch, variable)
    
    for name, slider in pairs(self[variable]) do
        if self[variable].index[name] ~= nil then
            slider:touched(touch)
        end
    end
    
end