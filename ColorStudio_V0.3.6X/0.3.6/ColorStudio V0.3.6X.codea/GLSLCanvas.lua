GLSLCanvas = class()

function GLSLCanvas:init()
    
    cameraSource(readLocalData("last_used_camera", CAMERA_BACK))
    
    self.canvas = mesh()
    
    local lsv = {}
    for v in string.gmatch(readLocalData("last_setting_value", "0.125, 0.0"), "[^,]+") do
        table.insert(lsv, tonumber(v))
    end
    
    self.panel = MultiSlider("SETTINGS", {"THRESHOLD", "SMOOTH"}, vec2(18, 27), vec2(297, 144))
    
    self.panel.settings.radius = 36
    self.panel.settings.color.box = color(75)
    self.panel.settings.color.label = color(225)
    for name, slider in pairs(self.panel.settings) do
        if self.panel.settings.index[name] ~= nil then
            slider.color.rail = color(55)
            slider.color.bar = color(125)
            slider.color.label = color(225)
            slider.value.unit = ""
            slider.value.format = "%.2f"
        end
    end
    self.panel.settings.threshold.value.current, self.panel.settings.smooth.value.current = table.unpack(lsv)
    
    local lpc = {}
    for v in string.gmatch(readLocalData("last_picked_color", "(255, 255, 255)"), "[^(,)]+") do
        table.insert(lpc, tonumber(v))
    end
    
    self.color = {
        replacer=vec3(0, 0, 0),
        picked=vec3(table.unpack(lpc)),
        picker=Picker(0, 100)
    }
    
end

function GLSLCanvas:draw(resolution)
    
    local camWidth, camHeight = spriteSize(CAMERA)
    
    local graphic = shader(vertex(), fragment())
    graphic.reso = resolution
    graphic.camSize = vec2(camWidth, camHeight)
    graphic.touch = CurrentTouch.pos
    graphic.time = ElapsedTime
    graphic.T = self.panel.settings.threshold.value.current
    graphic.S = self.panel.settings.smooth.value.current
    
    local camRatio = math.max(camWidth, camHeight)/math.min(camWidth, camHeight)
    local screenRatio = math.max(WIDTH, HEIGHT)/math.min(WIDTH, HEIGHT)
    
    local offset = vec4(0.0, 0.0, 0.0, 0.0)
    if screenRatio == camRatio then
        offset = vec4(1.0, 1.0, 1.0, 1.0)
    elseif camWidth > camHeight then
        offset = vec4(screenRatio, 1.0, camWidth*0.125, 0.0)
    else
        offset = vec4(1.0, screenRatio, 0.0, camHeight*0.125)
    end
    
    local ctp = vec2(CurrentTouch.x/(WIDTH*offset.x)*camWidth, CurrentTouch.y/(HEIGHT*offset.y)*camHeight) 
    if self.color.picker.held then
        self.color.picked = vec3(image(CAMERA):get(math.floor(ctp.x+0.5)+offset.z, math.floor(ctp.y+0.5)+offset.w))
        saveLocalData("last_picked_color", tostring(self.color.picked))
    end
    graphic.ctr = vec3(self.color.picked:unpack())/255.0
    graphic.rcl = vec3(self.color.replacer.x, self.color.replacer.y, self.color.replacer.z)/255.0
    
    self.canvas.shader = graphic
    
    self.canvas.texCoords = {
        vec2(0, 0),
        vec2(0, 1),
        vec2(1, 1),
        vec2(1, 1),
        vec2(1, 0),
        vec2(0, 0)
    }
    
    self.canvas.vertices = self.canvas.texCoords
    
    for i, v in ipairs(self.canvas.vertices) do
        self.canvas:vertex(i, v.x * resolution.x, v.y * resolution.y)
    end
    
    self.canvas.texture = CAMERA
    
    self.canvas:setColors(255, 255, 255, 255)
    
    self.canvas:draw()
    
    pushStyle()
    noStroke()
    fill(55)
    Shapes:roundedRect(18, 189, 126, 63, self.panel.settings.radius)
    strokeWidth(2)
    stroke(255)
    fill(self.color.picked:unpack())
    ellipse(49.5, 220.5, 45)
    fill(255)
    fontSize(15)
    textMode(CORNER)
    textAlign(LEFT)
    local r, g, b = self.color.picked:unpack()
    local v = "R: "..math.floor(r).."\nG: "..math.floor(g).."\nB: "..math.floor(b)
    text(v, 81, 193.5)
    
    if self.color.picker.held or not self.color.picker.animation:complete() then
        self.color.picker:draw(CurrentTouch.pos, color(r, g, b))
    end
    
    popStyle()
    
    self.panel:draw("settings")
    
end

function GLSLCanvas:touched(touch)
    
    local oss = vec2(
        self.panel.settings.pos:unpack()
    )
    
    oss = vec4(
        oss.x,
        oss.y,
        oss.x+self.panel.settings.size.x,
        oss.y+self.panel.settings.size.y
    )
    
    self.color.picker:touched(touch, Collision.point:circle(touch.pos, vec2(49.5, 220.5), 45))
    
    self.panel:touched(touch, "settings")
    
    saveLocalData("last_setting_value", self.panel.settings.threshold.value.current..","..self.panel.settings.smooth.value.current)
    
    if touch.state == BEGAN and touch.tapCount == 2
    and (touch.x < colCard.pos.x or touch.x > colCard.pos.x + colCard.size.x
    or touch.y < colCard.pos.y or touch.y > colCard.pos.y + colCard.size.y)
    and (touch.x <= oss.x or touch.x >= oss.z
    or touch.y <= oss.y or touch.y >= oss.w)
    then
        if cameraSource() == CAMERA_BACK then
            cameraSource(CAMERA_FRONT)
        else
            cameraSource(CAMERA_BACK)
        end
        saveLocalData("last_used_camera", cameraSource())
    end
    
end