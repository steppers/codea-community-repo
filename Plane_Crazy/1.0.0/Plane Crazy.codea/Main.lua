Altimeter = class()

function Altimeter:init(x, y, r)
    -- you can accept and set parameters here
    self.x = x
    self.y = y
    self.r = r
    self.val = 0
end

function Altimeter:draw()
    local x, y, r, one, ten, hundred, thousand
    x = self.x
    y = self.y
    r = self.r
    if self.val > 9999 then self.val = 9999 end
    font("ArialMT")
    pushMatrix()
    pushStyle()
    translate(x, y)
    fill(61, 61, 61, 255)
    stroke(84, 84, 84, 255)
    rect(-r/2-5, -r/2-5, r+10, r+10)
    fill(175, 129, 77, 255)
    ellipse(-r/2+5, -r/2+5, 10)
    ellipse(-r/2+5, r/2-5, 10)
    ellipse(r/2-5, -r/2+5, 10)
    ellipse(r/2-5, r/2-5, 10)
    strokeWidth(3)
    fill(176, 176, 176, 255)
    stroke(219, 191, 149, 255)
    ellipse(0, 0, r)
    stroke(141, 139, 139, 255)
    ellipse(0,0,r-10)
    strokeWidth(1)
    w = r / 170
    scale(w)
    fill(76, 76, 76, 255)
    rect(- 65, - 25, 130, 50)
    fontSize(48)
    fill(255, 255, 255, 255)
    rect(30,-20,30,40)
    fill(0, 0, 0, 255)
    text("0", 44, 0)
    rect(-1,-20,30,40)
    rect(-32,-20,30,40)
    rect(-63,-20,30,40)
    fill(255, 255, 255, 255)
    thousand = math.floor(self.val / 1000)
    hundred = math.floor((self.val - thousand * 1000) / 100)
    ten = math.floor((self.val - thousand * 1000 - hundred * 100) / 10)
    one = math.fmod(self.val, 10)
    -- tens
    clip(self.x - 63, self.y - 20 * w, self.x - 33, 40 * w)
    text(ten, 12, -one * 4 )
    s = ten + 1
    s = string.sub(s, string.len(s), string.len(s))
    text(s, 12, -one * 4 + 40)
    -- hundreds
    clip(self.x - 32, self.y - 20 * w, self.x + 1, 40 * w)
    text(hundred, -18, -ten * 4 )
    s = hundred + 1
    s = string.sub(s, string.len(s), string.len(s))
    text(s, -18, -ten * 4 + 40)
    -- thousand
    clip(self.x - 63, self.y - 20 * w, self.x + 1, 40 * w)
    text(thousand, -50, -hundred * 4 )
    s = thousand + 1
    s = string.sub(s, string.len(s), string.len(s))
    text(s, -50, -hundred * 4 + 40)
    noClip()
    fontSize(12)
    fill(0, 0, 0, 255)
    text("Altitude", 0, 40)
    text("Feet", 0, -40)
    popStyle()
    popMatrix()
end

Compass = class()

function Compass:init(x, y)
    self.x = x
    self.y = y
    self.w = WIDTH * 0.22
end

function Compass:draw()
    pushMatrix()
    pushStyle()
    translate(self.x, self.y)
    fill(61, 61, 61, 255)
    stroke(84, 84, 84, 255)
    rect(0, 0, self.w, 40)
    ellipse(0, 20, 20)
    ellipse(self.w, 20, 20)
    strokeWidth(3)
    fill(192, 192, 192, 255)
    stroke(219, 191, 149, 255)
    rect(5, 20, self.w - 10, 18)
    fill(80, 80, 80, 255)
    ellipse(-2, 20, 8)
    ellipse(self.w + 2, 20, 8)
    font("CourierNewPS-BoldMT")
    fontSize(22)
    fill(104, 31, 31, 255)
    textMode(CENTER)
    textAlign(CENTER)
    text(math.floor(heading), self.w / 2, 27)
    font("Verdana")
    fontSize(14)
    fill(232, 218, 218, 255)
    text("Direction", self.w / 2, 10)
    popStyle()
    popMatrix()
end

Frame = class()

-- Frame 
-- ver. 1.0
-- a simple rectangle for holding controls.
-- ====================

function Frame:init(left, bottom, right, top)
    self.left = left
    self.right = right
    self.bottom = bottom
    self.top = top
end

function Frame:inset(dx, dy)
    self.left = self.left + dx
    self.right = self.right - dx
    self.bottom = self.bottom + dy
    self.top = self.top - dy
end

function Frame:offset(dx, dy)
    self.left = self.left + dx
    self.right = self.right + dx
    self.bottom = self.bottom + dy
    self.top = self.top + dy
end

function Frame:draw()
    pushStyle()
    rectMode(CORNERS)
    rect(self.left, self.bottom, self.right, self.top)
    popStyle()
end

function Frame:roundRect(r)
    pushStyle()
    insetPos = vec2(self.left + r,self.bottom + r)
    insetSize = vec2(self:width() - 2 * r,self:height() - 2 * r)
    
    rectMode(CORNER)
    rect(insetPos.x, insetPos.y, insetSize.x, insetSize.y)
    
    if r > 0 then
        smooth()
        lineCapMode(ROUND)
        strokeWidth(r * 2)
        
        line(insetPos.x, insetPos.y, 
        insetPos.x + insetSize.x, insetPos.y)
        line(insetPos.x, insetPos.y,
        insetPos.x, insetPos.y + insetSize.y)
        line(insetPos.x, insetPos.y + insetSize.y,
        insetPos.x + insetSize.x, insetPos.y + insetSize.y)
        line(insetPos.x + insetSize.x, insetPos.y,
        insetPos.x + insetSize.x, insetPos.y + insetSize.y)            
    end
    popStyle()
end

function Frame:gloss(baseclr)
    local i, t, r, g, b, y
    pushStyle()
    if baseclr == nil then baseclr = color(194, 194, 194, 255) end
    fill(baseclr)
    rectMode(CORNERS)
    rect(self.left, self.bottom, self.right, self.top)
    r = baseclr.r
    g = baseclr.g
    b = baseclr.b
    for i = 1 , self:height() / 2 do
        r = r - 1
        g = g - 1
        b = b - 1
        stroke(r, g, b, 255)
        y = (self.bottom + self.top) / 2
        line(self.left, y + i, self.right, y + i)
        line(self.left, y - i, self.right, y - i)
    end
    popStyle()
end

function Frame:shade(base, step)
    pushStyle()
    strokeWidth(1)
    for y = self.bottom, self.top do
        i = self.top - y
        stroke(base - i * step, base - i * step, base - i * step, 255)
        line(self.left, y, self.right, y)
    end
    popStyle()
end

function Frame:touched(touch)
    if touch.x >= self.left and touch.x <= self.right then
        if touch.y >= self.bottom and touch.y <= self.top then
            return true
        end
    end
    return false
end

function Frame:ptIn(x, y)
    if x >= self.left and x <= self.right then
        if y >= self.bottom and y <= self.top then
            return true
        end
    end
    return false
end

function Frame:width()
    return self.right - self.left
end

function Frame:height()
    return self.top - self.bottom
end

function Frame:midX()
    return (self.left + self.right) / 2
end

function Frame:midY()
    return (self.bottom + self.top) / 2
end

FlightTimer = class()

function FlightTimer:init(x, y, title)
    self.x = x
    self.y = y
    self.w = WIDTH * 0.22
    self.title = title
    self.val = 0
end

function FlightTimer:draw(alt)
    pushMatrix()
    pushStyle()
    if alt > 0 then self.val = self.val + 0.03 end
    translate(self.x, self.y)
    
    fill(61, 61, 61, 255)
    stroke(84, 84, 84, 255)
    rect(0, 0, self.w, 40)
    ellipse(0, 20, 20)
    ellipse(self.w, 20, 20)
    strokeWidth(3)
    fill(192, 192, 192, 255)
    stroke(219, 191, 149, 255)
    rect(5, 20, self.w-10, 18)
    fill(80, 80, 80, 255)
    ellipse(-2, 20, 8)
    ellipse(self.w+2, 20, 8)
    font("CourierNewPS-BoldMT")
    fontSize(22)
    fill(104, 31, 31, 255)
    textMode(CENTER)
    textAlign(CENTER)
    text(math.floor(self.val), self.w/2, 27)
    font("Verdana")
    fontSize(14)
    fill(232, 218, 218, 255)
    text(self.title, self.w/2, 10)
    
    popStyle()
    popMatrix()
end


Horizon = class()

function Horizon:init(x, y, r)
    self.x = x
    self.y = y
    self.r = r
    self.roll=0
    self.pitch=0
end

function Horizon:draw()
    local x, y, r
    x = self.x
    y = self.y
    r = self.r
    pushMatrix()
    pushStyle()
    translate(x, y)
    fill(61, 61, 61, 255)
    stroke(84, 84, 84, 255)
    rect(-r/2-5, -r/2-5, r+10, r+10)
    noStroke()
    fill(19, 19, 19, 255)
    ellipse(-r/2+5, -r/2+5, 10)
    ellipse(-r/2+5, r/2-5, 10)
    ellipse(r/2-5, -r/2+5, 10)
    ellipse(r/2-5, r/2-5, 10)
    strokeWidth(3)
    fill(176, 176, 176, 255)
    stroke(219, 191, 149, 255)
    ellipse(0, 0, r)
    stroke(141, 139, 139, 255)
    ellipse(0,0,r-10)
    strokeWidth(3)
    stroke(98, 98, 98, 255)
    for i=0,6 do
        line(r/2-20,0,r/2-35,0)
        rotate(30)
    end
    rotate(-210)
    font("ArialMT")
    textAlign(CENTER)
    fill(0, 0, 0, 255)
    fontSize(12)
    text("Horizon", 0, 25)
    self.roll = Gravity.x * 90
    self.pitch = Gravity.y 
    rotate(self.roll)
    strokeWidth(10)
    stroke(0, 206, 255, 255)
    x = r / 2 * ( 1 - math.abs(self.pitch / 2.4)) - 5
    y = r / 2 * (self.pitch * 0.8)
    line(0,y+2,-x,y+2)
    line(0,y+2,x,y+2)
    stroke(157, 124, 86, 255)
    line(0,y-3,-x,y-3)
    line(0,y-3,x,y-3)
    stroke(175, 148, 63, 255)
    fill(127, 127, 127, 255)
    rotate(-self.roll)
    stroke(230, 230, 230, 113)
    line(0,0,-r/4,-r/4)
    line(0,0,r/4,-r/4)
    line(0,0,0,-r/4)
    stroke(255, 102, 0, 255)
    line(-r/4,0, -20,0)
    line(r/4,0, 20,0)
    popStyle()
    popMatrix()
end

-- Main
--
-- Plane Crazy 0.2 --

supportedOrientations(PORTRAIT)
displayMode(FULLSCREEN)

function setup()
    local i
    -- targets
    target = {}
    for i = 1, 3 do newTarget(i) end
    -- instrument panel
    w = (WIDTH - 80) / 4
    panelTop = w + 130
    throttle = Throttle(w * 3 + 100, 60, WIDTH - 30, panelTop - 10)
    horizon = Horizon(w * 3 - w/2 + 50, panelTop - w/ 2 - 10, w)
    altimeter = Altimeter(w * 2 - w/2 + 30, panelTop - w/ 2 - 10, w)
    speedo = Speedometer(w - w/2 + 10, panelTop - w/ 2 - 10, w)
    compass = Compass( 10, 60)
    flightTimer = FlightTimer(w + 30, 60, "Flight Time")
    bestFlightTimer = FlightTimer(w * 2 + 50, 60, "Best Flight Time")
    map = Map(WIDTH-200, HEIGHT-200, 190, 190)
    logFrame = Frame(WIDTH - 145, panelTop + 10, 
    WIDTH - 10, panelTop + 65)
    -- meshes used for ground
    trees = mesh()
    trees2 = mesh()
    ground = mesh()
    mud = mesh()
    bushes = mesh()
    rocks = mesh()
    createMapElements()
    
    -- state of game variables
    status = 1
    showLog = false
    stall = false
    oldTouch = nil
    accelMode = false
    
    -- button for log book check box
    accelFrame = Frame(WIDTH / 2 + 10, HEIGHT - 433, 
    WIDTH / 2 + 35, HEIGHT - 395)
    
    mapFrame = Frame(0, panelTop, WIDTH, HEIGHT)
    
    -- read high score
    i = readLocalData("PlaneCrazyBest")
    if i ~= nil then
        bestFlightTimer.val = i
    end
    
    -- Start new game
    newGame()
end

function drawPlane()
    local x, y
    pushMatrix()
    translate(WIDTH/2, HEIGHT/2-100)
    rotate(180 + spinTimer)
    x=70
    if altimeter.val < 10 then y = 70 else
        y=70-math.abs(50*horizon.pitch)
    end
    if crashed then
        sprite("Tyrian Remastered:Explosion Huge", 0, 0, 120, 120)
        timer = 0
        if flightTimer.val > bestFlightTimer.val then
            bestFlightTimer.val = flightTimer.val
            saveLocalData("PlaneCrazyBest", bestFlightTimer.val)
        end
    else
        tint(56, 56, 56, 37)
        sprite("Tyrian Remastered:Enemy Ship B", 0, 
        altimeter.val/2, 70,y)
        noTint()
        if horizon.roll < -20 then
            sprite("Tyrian Remastered:Enemy Ship B R1", 0, 0, 70,y)
        elseif horizon.roll > 20 then
            sprite("Tyrian Remastered:Enemy Ship B L1", 0, 0, 70,y)
        else
            sprite("Tyrian Remastered:Enemy Ship B", 0, 0, 70,y)
        end
    end
    popMatrix()
end

function drawMap()
    -- draw the map features
    pushStyle()
    pushMatrix()
    rotate(heading)
    translate(east + WIDTH / 2, north + HEIGHT / 2)
    s = 1 - (altimeter.val / 5000)
    -- scaling disabled. .
    --scale(s)
    line(-10000, 0, 10000, 0)
    line(0, -10000, 0, 10000)
    ground:draw()
    mud:draw()
    rocks:draw()
    bushes:draw()
    trees:draw()
    trees2:draw()
    runway:draw()
    -- runway details
    stroke(213, 193, 129, 255)
    strokeWidth(5)
    for i=1,10 do
        line(0, i * 100 - 400, 0, i * 100 - 350)
    end
    stroke(0, 138, 255, 255)
    line(-80, 800, 80, 800)
    font("Futura-CondensedExtraBold")
    fill(151, 151, 151, 135)
    fontSize(96)
    text("0 0", 0, -200)
    -- targets
    noFill()
    strokeWidth(20)
    stroke(255, 240, 0, 255)
    for i=1,#target do
        if target[i].z == 500 then
            stroke(255, 36, 0, 104)
        elseif target[i].z == 1000 then
            stroke(253, 224, 3, 255)
        else
            stroke(0, 255, 253, 255)
        end
        ellipse(target[i].x, target[i].y, target[i].z)
        line(target[i].x - target[i].z / 3.2, 
        target[i].y - target[i].z / 3.2, 
        target[i].x + target[i].z / 3.2, 
        target[i].y + target[i].z / 3.2)
        line(target[i].x - target[i].z / 3.2, 
        target[i].y + target[i].z / 3.2, 
        target[i].x + target[i].z / 3.2, 
        target[i].y - target[i].z / 3.2)
    end
    popMatrix()
    -- intro screen if in intro mode
    if status == 1 then
        font("MarkerFelt-Wide")
        fontSize(222 * WIDTH / 768)
        fill(0, 0, 0, 123)
        text("Plane", WIDTH / 2, HEIGHT - 100)
        text("Crazy", WIDTH / 2, HEIGHT - 300)
        fill(255, 252, 0, 255)
        text("Plane", WIDTH / 2 - 10, HEIGHT - 90)
        text("Crazy", WIDTH / 2 - 10, HEIGHT - 290)
        fontSize(72 * WIDTH / 768)
        text("Touch here to begin", WIDTH /2, HEIGHT - 450)
    end
    popStyle()
end

function drawInstruments()
    line(0, panelTop, WIDTH, panelTop)
    fill(89, 89, 89, 255)
    rect(0,0,WIDTH,panelTop)
    -- instruments
    horizon:draw()
    throttle:draw()
    altimeter:draw()
    speedo:draw()
    compass:draw()
    flightTimer:draw(altimeter.val)
    bestFlightTimer:draw(0)
end

function drawLogBook()
    -- pilot log book
    pushStyle()
    fill(0, 0, 0, 86)
    logFrame:draw()
    stroke(255, 230, 0, 255)
    strokeWidth(1)
    rect(logFrame.right - 75, logFrame.bottom + 5, 10, 10)
    fill(255, 230, 0, 255)
    fontSize(14)
    if accelMode then
        text("Accel. Mode", throttle.frame:midX(), 
        throttle.frame.bottom + 5)
    end
    fontSize(12)
    text("Pilot Log", logFrame.left + 100, logFrame.bottom + 10)
    font("HoeflerText-BlackItalic")
    fill(216, 216, 216, 142)
    noStroke()
    ellipse(logFrame.left + 30, logFrame.bottom + 28, 44)
    fill(0, 0, 0, 112)
    fontSize(44)
    text("i", logFrame.left + 30, logFrame.bottom + 22)
    popStyle()
end

function draw()
    noSmooth()
    background(31, 89, 36, 255)
    
    drawMap()
    drawPlane()
    drawInstruments()
    if status > 1 and not crashed then calcPosition() end
    if status > 1 then map:draw(east, north, target) end
    drawLogBook()
    
    if showLog then
        showInstructions()
    end
    
    -- touch handle
    if not accelMode then
        throttle:touched(CurrentTouch)
    else
        throttle.val = throttle.val + UserAcceleration.y * 2
        if throttle.val > 100 then throttle.val = 100 
        elseif throttle.val < 0 then throttle.val = 0 end
    end
    
    -- check targets
    for i = 1, #target do
        if math.abs(north + target[i].y + 300) < target[i].z / 1.5
        and math.abs(east + target[i].x) < target[i].z / 1.5 then
            if target[i].z == 500 then
                timer = timer + 50
            elseif target[i].z == 1000 then
                timer = timer + 40
            else
                timer = timer + 25
            end
            sound(SOUND_POWERUP, 26628)
            newTarget(i)
        end
    end
    
    if mapFrame:touched(CurrentTouch)  then
        if status == 1 and oldTouch ~= CurrentTouch.x then 
            status = 2
            throttle.val = 0
            newGame()
            
        elseif showLog and oldTouch ~= CurrentTouch.x 
        and CurrentTouch.state == BEGAN then
            if accelFrame:touched(CurrentTouch) then 
                accelMode = not accelMode
            else
                showLog = false
            end
        end
        
    end
    
    if logFrame:touched(CurrentTouch) then
        if oldTouch ~= CurrentTouch.x then
            showLog = true
        end
    end
    
    oldTouch = CurrentTouch.x
end

-- minimap for Plane Crazy

Map = class()

function Map:init(x, y, w, h)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
end

function Map:convert(east, north)
    x = (self.w + self.x) - (east+20000) * self.w/40000
    y = (self.y + self.h) -(north+20000) * self.h/40000
    return x, y
end

function Map:draw(east, north, target)
    local x, y, i
    pushStyle()
    fill(195, 195, 195, 155)
    strokeWidth(2)
    stroke(94, 94, 94, 131)
    rect(self.x, self.y, self.w, self.h)
    stroke(235, 6, 6, 255)
    x, y = self:convert(east, north)
    
    if x < self.x then x= self.x end
    if x > self.x + self.w then x= self.x + self.w end
    if y < self.y then y= self.y end
    if y > self.y + self.h then y= self.y + self.h end
    line(x-2,y,x+2,y)
    line(x,y-2,x,y+2)
    stroke(127, 127, 127, 255)
    x, y = self:convert(0, 0)
    fill(126, 126, 126, 255)
    rect(x, y, 1, 10)
    
    fill(61, 61, 61, 255)
    fontSize(18)
    text("Map", self.x + 25, self.y + 15)
    noFill()
    for i=1,#target do
        if target[i].z == 500 then
            stroke(255, 36, 0, 104)
        elseif target[i].z == 1000 then
            stroke(253, 224, 3, 255)
        else
            stroke(50, 83, 239, 255)
        end
        x, y = self:convert(-target[i].x, -target[i].y)
        ellipse(x, y, target[i].z / 100)
    end
    popStyle()
end

-- Misc 

function newGame()
    spinTimer = 0
    soundTimer = 0
    timer = 200
    crashed = false
    east = 0
    north = 250
    heading = 0
    roll = 0
    pitch = 0
    speed = 0
    gas = 50
    altimeter.val = 0
    flightTimer.val = 0
end

function createMapElements()
    local i
    trees.texture ="Planet Cute:Tree Short"
    trees2.texture ="Planet Cute:Tree Ugly"
    trees:setColors(255,255,255,255)
    mud.texture = "Small World:Dirt Patch"
    bushes.texture = "Small World:Bush"
    rocks.texture = "Tyrian Remastered:Rock 3"
    
    for i = 1, 2000 do
        bushes:addRect(math.random(20000) - 10000,
        math.random(9800) - 10000, 32, 27)
    end
    for i = 1, 500 do
        mud:addRect(math.random(20000) - 10000,
        math.random(4000) - 10000, 130, 100)
    end
    
    for i = 1, 1000 do
        trees:addRect(math.random(10000) - 10200,
        math.random(5800), 100, 171)
        trees:addRect(math.random(10000) + 200,
        math.random(5800), 100, 171)
    end
    for i = 1, 1500 do
        trees2:addRect(math.random(20000) - 10000,
        math.random(4000) + 5600 , 100, 171)
    end
    
    i =0
    
    for x = 1, 100 do
        for y = 1, 100 do
            ground:addRect(x*500 - 25000,y*500-25000,500,500)
            i = i + 1
            if y < 48 and y > 40 then
                ground:setRectColor(i, 88+math.random(64), 
                154+math.random(64),  33)
            elseif y <= 40 then
                ground:setRectColor(i, 144+math.random(64), 
                144+math.random(64),  33)
            elseif y == 70 then 
                ground:setRectColor(i, 155+math.random(64), 
                154+math.random(55),  122)
            elseif y > 70 then
                ground:setRectColor(i, 22, 22,  155+math.random(55))
            elseif x < 20 and y < 30 then
                ground:setRectColor(i, 100, 100 + math.random(40), 
                30, 255)
            elseif x > 50 and y < 15 then
                ground:setRectColor(i, 22, 22,  155+math.random(55))
            else
                ground:setRectColor(i, 22, 166+math.random(55),22)
            end
        end
    end
    
    for x = 1, 100 do
        y = 50 + math.random(2) - 1
        ground:setRectColor(5000 + i, 22, 22, 151+math.random(55))
    end
    
    runway = mesh()
    runway:addRect(0,0,200,2000)
    runway:setRectColor(1, 122, 122, 122)
end

function newTarget(i)
    local z
    z = math.floor(math.random(3) + 1) * 500
    target[i] = vec3( math.random(20000) - 10000, 
    math.random(20000) - 10000, z)
end

function calcPosition()
    -- direction
    if speedo.val > 10 then
        heading = heading + horizon.roll / 100
        if heading < 0 then heading = heading + 360 end
        if heading > 360 then heading = heading - 360 end
    end
    -- position
    north = north - math.cos(math.rad(heading)) * speedo.val/20
    if north > 25000 then north = -25000 
    elseif north < -25000 then north = 25000 end
    east = east - math.sin(math.rad(heading)) * speedo.val/20
    if east > 25000 then east = -25000 
    elseif east < -25000 then east = 25000 end
    -- altitude
    altimeter.val = altimeter.val - 0.1
    altimeter.val = altimeter.val - math.abs(horizon.roll) / 50
    altimeter.val = altimeter.val + (horizon.pitch * -speedo.val / 60)
    if speedo.val + horizon.pitch * 100 < 60 then
        stall= true
        if altimeter.val > 0 then
            altimeter.val = altimeter.val - 1
            spinTimer = spinTimer + 10
            sound(SOUND_JUMP, 40113)
        end
    else
        stall = false
        spinTimer = 0
    end
    if altimeter.val <= 0 then
        -- on ground
        -- check for landing / crash
        altimeter.val = 0
        if east < -200 or east > 200 or north > 2300 
        or north < -1300 then
            --big crash
            crashed = true
            timer = 0
            speedo.val = 0
            sound(SOUND_EXPLODE, 18933)
            status = 1
        else
            -- on runway
            if horizon.pitch < 0 then 
                speedo.val = speedo.val - 1 
                fontSize(22)
                text("Brakes Applied. Tilt forward to release.", 
                WIDTH / 2, 320)
            end
        end
    else
        -- in air
        speedo.val = speedo.val + horizon.pitch * 2
    end
    -- speed
    if timer > 0 then
        speedo.val = speedo.val + throttle.val / 100 
    else
        fontSize(22)
        text("Out of gas.", WIDTH / 2, 320)
    end
    
    if speedo.val < 0 then speedo.val=0 end
    if speedo.val > 222 then speedo.val = 220 end
    -- fuel
    timer = timer - throttle.val * 0.001
    if timer < 0 then timer = 0 end
    -- sound
    if timer > 0 and soundTimer + 0.1 < ElapsedTime then
        if throttle.val > 30 then
            sound(DATA, 
            "ZgNAFAA6Pz05PDxCIsyOvCq8qT4jd5g+JAA7fz9EREFCOz5F")
        elseif throttle.val > 0 then
            sound(DATA, 
            "ZgNAFw06Ozs5Pj5FmteWPa+b2j419Z8+JAA4f0FER0VCOz1I")
        end
        soundTimer = ElapsedTime
    end
    -- timer
    pushStyle()
    fill(165, 207, 223, 99)
    fontSize(96)
    textAlign(LEFT)
    textMode(CORNER)
    text(math.floor(timer), 20, 300)
    fill(223, 138, 138, 185)
    textMode(CENTER)
    textAlign(CENTER)
    font("MarkerFelt-Wide")
    if stall and altimeter.val > 10 then
        text("Stall Warning", WIDTH / 2, HEIGHT / 2)
    end
    popStyle()
end



-- Misc2
function showInstructions()
    local i
    pushStyle()
    fill(46, 45, 25, 255)
    rect(10, 315, WIDTH - 20, HEIGHT - 330)
    fill(219, 219, 219, 255)
    rect(20, 320, WIDTH - 40, HEIGHT - 340)
    stroke(67, 67, 67, 255)
    line(WIDTH / 2, 330, WIDTH / 2, HEIGHT - 50)
    textAlign(LEFT)
    textMode(CORNER)
    fontSize(24)
    fill(0, 0, 0, 255)
    font("HelveticaNeue-Bold")
    text("Log Book", 30, HEIGHT - 50)
    fill(23, 50, 167, 255)
    font("Noteworthy-Light")
    strokeWidth(1)
    for i = 1, 14 do
        line(40, HEIGHT - i * 43 - 50, 
        WIDTH / 2 - 10, HEIGHT - i * 43 - 50)
        line(WIDTH / 2 + 10, HEIGHT - i * 43 - 50, 
        WIDTH - 40, HEIGHT - i * 43 - 50)
    end
    fontSize(24 * WIDTH / 768)
    textWrapWidth(330 * WIDTH / 768)
    text("1. Tilt device left and right to change direction.", 
    40, HEIGHT - 142)
    text("2. Tilt device forward to dive and back to climb.", 
    40, HEIGHT - 227)
    text("3. Hold device flat for level flight.", 
    40, HEIGHT - 273)
    text("4. Tilt forward to release brakes on runway.", 
    40, HEIGHT - 355)
    text("5. If you try to climb too quickly you will"..
    " lose speed and stall.", 40, HEIGHT - 442)
    text("6. To recover from a stall tilt forward "..
    " and gain speed.", 40, HEIGHT - 528)
    text("7. It takes more power to hold altitude during "..
    " steeply banked turns.", 40, HEIGHT - 652)
    text("8. When the timer runs down, you're out of fuel. "..
    " ", WIDTH / 2 + 10, HEIGHT - 142)
    text("9. Fly to targets to get extra fuel. "..
    " ", WIDTH / 2 + 10, HEIGHT - 186)
    text("10. Smaller targets give more fuel. "..
    " ", WIDTH / 2 + 10, HEIGHT - 229)
    text("11. Ease off on the throttle to save fuel. "..
    " ", WIDTH / 2 + 10, HEIGHT - 315)
    text("12. Good luck!"..
    " ", WIDTH / 2 + 10, HEIGHT - 357)
    text("     Turn on control of throttle by acceleration. "..
    " Warning! Requires a lot of space and willingness"..
    " to look like an idiot.", WIDTH / 2 + 10, HEIGHT - 560)
    text("(c) 2012 by Mark Sumner"..
    " ", WIDTH / 2 + 60, HEIGHT - 659)
    stroke(0, 0, 0, 255)
    strokeWidth(2)
    fill(219, 219, 219, 255)
    accelFrame:draw()
    strokeWidth(5)
    stroke(31, 179, 22, 255)
    if accelMode then
        line(accelFrame.left, accelFrame:midY(), 
        accelFrame:midX(), accelFrame.bottom)
        line(accelFrame.right, accelFrame.top,
        accelFrame:midX(), accelFrame.bottom)
    end
    popStyle()
end




Speedometer = class()

function Speedometer:init(x, y, r)
    self.x = x
    self.y = y
    self.r = r
    self.val = 0
end

function Speedometer:draw()
    local x, y, r, s
    x = self.x
    y = self.y
    r = self.r
    if self.val > 270 then self.val = 270 end
    font("ArialMT")
    pushMatrix()
    pushStyle()
    translate(x, y)
    fill(61, 61, 61, 255)
    stroke(84, 84, 84, 255)
    rect(-r/2-5, -r/2-5, r+10, r+10)
    fill(19, 19, 19, 255)
    ellipse(-r/2+5, -r/2+5, 10)
    ellipse(-r/2+5, r/2-5, 10)
    ellipse(r/2-5, -r/2+5, 10)
    ellipse(r/2-5, r/2-5, 10)
    strokeWidth(3)
    fill(176, 176, 176, 255)
    stroke(219, 191, 149, 255)
    ellipse(0, 0, r)
    stroke(141, 139, 139, 255)
    ellipse(0,0,r-10)
    
    stroke(0, 0, 0, 255)
    noFill()
    strokeWidth(19)
    ellipse(0,0,r-50)
    stroke(248, 248, 248, 255)
    strokeWidth(13)
    ellipse(0,0,r-55)
    noStroke()
    fill(176, 176, 176, 255)
    if r > 160 then
        rect(-r/2+20,0,40,40)
        rect(-40,r/2-60,40,40)
        rect(-50,15,40,40)
    end
    stroke(0, 0, 0, 255)
    strokeWidth(1)
    rotate(180)
    fontSize(9)
    fill(0, 0, 0, 255)
    for i=0,27 do
        line(r/2-37,0,r/2-30,0)
        rotate(10)
        if i/2 == math.floor(i/2) then
            s = 260 - i * 10
            text(s, r/2-15, 0)
        end
    end
    rotate(-10)
    -- set needle
    rotate(-self.val)
    stroke(255, 0, 0, 255)
    strokeWidth(5)
    line(0,0,r/3,0)
    stroke(82, 82, 82, 255)
    strokeWidth(3)
    fill(90, 90, 90, 255)
    stroke(219, 191, 149, 255)
    ellipse(0, 0, 25)
    stroke(141, 139, 139, 255)
    ellipse(0,0,20)
    fill(0, 0, 0, 255)
    font("ArialMT")
    fontSize(12)
    popMatrix()
    text("Speed", self.x, self.y - 20)
    popStyle()
    
end

Throttle = class()

function Throttle:init(l, b, r, t)
    -- you can accept and set parameters here
    self.x = x
    self.frame = Frame(l, b, r, t)
    self.val = 0
end

function Throttle:draw()
    local dy, vy
    noStroke()
    self.frame:gloss( color(155, 155, 155, 255))
    pushMatrix()
    pushStyle()
    translate(self.frame.left, self.frame.bottom)
    
    -- base
    strokeWidth(3)
    stroke(127, 127, 127, 255)
    fill(92, 92, 92, 255)
    rect(0, self.frame:height() - 40, self.frame:width(), 40)
    stroke(167, 40, 23, 255)
    line(20, 20, self.frame:width() - 20, 20)
    stroke(35, 35, 35, 255)
    line(20, self.frame:height() / 2 , 
    50, self.frame:height() / 2)
    line(20, self.frame:height() / 2 + 20, 
    50, self.frame:height() /2 + 20)
    line(20, self.frame:height() / 2 - 20, 
    50, self.frame:height() /2 - 20)
    -- axis
    vy = 100 / (self.frame:height() - 40)
    dy = self.val / vy + 40
    noStroke()
    fill(51, 51, 51, 255)
    rect(self.frame:width()/2 - 15, self.frame:height()-40- dy, 5, dy)
    fill(127, 127, 127, 255)
    rect(self.frame:width()/2 - 10, self.frame:height()-40- dy, 10, dy)
    fill(165, 165, 165, 255)
    rect(self.frame:width()/2 - 0, self.frame:height()-40- dy, 15, dy)
    fill(78, 31, 31, 255)
    strokeWidth(1)
    
    rect(self.frame:width()/2-35, self.frame:height()-40- dy + 15,
    70, 20)
    fill(43, 43, 43, 255)
    rect(self.frame:width()/2-25, self.frame:height()-40- dy + 5,
    50, 10)
    rect(self.frame:width()/2-25, self.frame:height()-40- dy + 35,
    50, 10)
    -- knob
    
    fontSize(14)
    fill(0, 0, 0, 255)
    text("Throttle", self.frame:width()/2, self.frame:height() - 20)
    line(2, self.frame:height()-vy * 50 , 20,
    self.frame:height()-vy * 50)
    popStyle()
    popMatrix()
end

function Throttle:touched(t)
    local dy, vy
    if self.frame:touched(t) then
        dy = self.frame.top - 80 - t.y
        vy = 100 / (self.frame:height() - 40)
        self.val = dy * vy
    end
    if self.val < 0 then self.val = 0 end
end