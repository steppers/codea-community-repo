-- Contents:
--    Main.lua
--    OrbitViewer.lua
--    FirstPersonViewer.lua

------------------------------
-- Main.lua
------------------------------
do
-- Cameras

-- Use this function to perform your initial setup
function setup()
    print("Hello Cameras!")

    scene = craft.scene()
    local m = craft.model("CastleKit:knightBlue")
    model = scene:entity()
    model:add(craft.renderer, m)
    
    scene.camera:add(OrbitViewer, vec3(0,5,0), 5, 10, 20)
    
  --  scene.camera:add(FirstPersonViewer)
end

function update(dt)
    scene:update(dt)
end

-- This function gets called once every frame
function draw()
    update(DeltaTime)
    scene:draw()
end
end
------------------------------
-- OrbitViewer.lua
------------------------------
do
-----------------------------------------
-- OrbitViewer
-- Written by John Millard
-----------------------------------------
-- Description:
-- A basic viewer that orbits a target via rotating, panning and zooming.
-- A particular point in space is used as the target. 
-- Single touch rotates while pinching is used for zooming in and out.
-- Two finger drag is used for panning.
-- Attach to a camera's entity for basic first person controls:
-- i.e. scene.camera:add(OrbitViewer)
-----------------------------------------

OrbitViewer = class()

function OrbitViewer:init(entity, target, zoom, minZoom, maxZoom)
    self.entity = entity
    self.camera = entity:get(craft.camera)

    -- The camera's current target
    self.target = target or vec3(0,0,0)
    self.origin = self.target

    self.zoom = zoom or 5
    self.minZoom = minZoom or 1
    self.maxZoom = maxZoom or 20

    self.touches = {}
    self.prev = {}

    -- Camera rotation
    self.rx = 0
    self.ry = 0

    -- Angular momentum
    self.mx = 0
    self.my = 0

    self.sensitivity = 0.25

    if touches then touches.addHandler(self, 0, true) end
end

-- Project a 2D point z units from the camera
function OrbitViewer:project(p,z)
    local origin, dir = self.camera:screenToRay(p)   
    return origin + dir * z
end

-- Calculate overscroll curve for zooming
local function scrollDamping(x,s)
    return s * math.log(x + s) - s * math.log(s)
end

function OrbitViewer:update()
    if #self.touches == 0 and not self.capturedScroll then
        -- Apply momentum from previous swipe
        self.rx = self.rx + self.mx * DeltaTime
        self.ry = self.ry + self.my * DeltaTime
        self.mx = self.mx * 0.9
        self.my = self.my * 0.9 
        
        -- If zooming past min or max interpolate back to limits
        if self.zoom > self.maxZoom then
            local overshoot = self.zoom - self.maxZoom
            overshoot = overshoot * 0.9
            self.zoom = self.maxZoom + overshoot
        elseif self.zoom < self.minZoom then
            local overshoot = self.minZoom - self.zoom
            overshoot = overshoot * 0.9
            self.zoom = self.minZoom - overshoot
        end
        
    elseif #self.touches == 2 then
        self.entity.position = self.prev.target - self.entity.forward * self.zoom
        
        local mid = self:pinchMid()  
        local dist = self:pinchDist()
        
        local p1 = self:project(self.prev.mid, self.zoom)  
        local p2 = self:project(mid,self.zoom)
        
        self.target = self.prev.target + (p1-p2)  
        self.zoom = self:clampZoom(self.prev.zoom * (self.prev.dist / dist))
    end  
    
    -- Clamp vertical rotation between -90 and 90 degrees (no upside down view)
    self.rx = math.min(math.max(self.rx, -90), 90)

    -- Calculate the camera's position and rotation
    local rotation = quat.eulerAngles(self.rx,  self.ry, 0)
    self.entity.rotation = rotation
    local t = vec3(self.target.x, self.target.y, self.target.z)
    self.entity.position = t + self.entity.forward * -self.zoom
end

-- Calculate the distance between the current two touches
function OrbitViewer:pinchDist()
    local p1 = vec2(self.touches[1].x, self.touches[1].y)
    local p2 = vec2(self.touches[2].x, self.touches[2].y)
    return p1:dist(p2)
end

-- Calculate the mid point between the current two touches
function OrbitViewer:pinchMid()
    local p1 = vec2(self.touches[1].x, self.touches[1].y)
    local p2 = vec2(self.touches[2].x, self.touches[2].y)
    return (p1 + p2) * 0.5
end

function OrbitViewer:clampZoom(zoom)
    if zoom > self.maxZoom then
        local overshoot = zoom - self.maxZoom
        overshoot = scrollDamping(overshoot, 10.0)
        zoom = self.maxZoom + overshoot
    elseif zoom < self.minZoom then
        local overshoot = self.minZoom - zoom
        overshoot = scrollDamping(overshoot, 10.0)
        zoom = self.minZoom - overshoot
    end
    return zoom
end

function OrbitViewer:rotate(x, y)
    self.rx = self.rx - y * self.sensitivity
    self.ry = self.ry - x * self.sensitivity            
end

function OrbitViewer:pan(p1, p2)
    local p1 = self:project(p1, self.zoom)  
    local p2 = self:project(p2, self.zoom)
        
    self.target = self.target + (p1-p2)  
end

function OrbitViewer:scroll(gesture)
    local panMode = gesture.shift
    local zoomMode = gesture.alt
    
    if gesture.state == BEGAN then
        if #self.touches > 0 then return false end

        self.capturedScroll = true
        self.prev.zoom = self.zoom
        self.prev.mid = gesture.location

        return true
    elseif gesture.state == MOVING then
        if panMode then
            self:pan(gesture.location - gesture.delta, gesture.location)            
        elseif zoomMode then
            self.zoom = self:clampZoom(self.prev.zoom + (gesture.location - self.prev.mid).y * self.sensitivity)
        else
            self:rotate(gesture.delta.x, gesture.delta.y)
        end
        self.prevGestureDelta = gesture.delta
    elseif gesture.state == ENDED or gesture.state == CANCELLED then
        self.capturedScroll = false

        if not panMode and not zoomMode then
            local delta = self.prevGestureDelta
            self.mx = -delta.y / DeltaTime * self.sensitivity
            self.my = -delta.x / DeltaTime * self.sensitivity        
        end
    end
end

function OrbitViewer:touched(touch)
    if touch.tapCount == 2 then
        self.target = self.origin
    end
    
    if self.capturedScroll then return false end
    
    -- Allow a maximum of 2 touches
    if touch.state == BEGAN and #self.touches < 2 then
        table.insert(self.touches, touch)
        if #self.touches == 2 then
            self.prev.target = vec3(self.target:unpack())
            self.prev.mid = self:pinchMid()
            self.prev.dist = self:pinchDist()
            self.prev.zoom = self.zoom
            self.mx = 0
            self.my = 0
        end        
        return true
    -- Cache updated touches
    elseif touch.state == MOVING then
        for i = 1,#self.touches do
            if self.touches[i].id == touch.id then
                self.touches[i] = touch
            end
        end
    -- Remove old touches
    elseif touch.state == ENDED or touch.state == CANCELLED then
        for i = #self.touches,1,-1 do
            if self.touches[i].id == touch.id then
                table.remove(self.touches, i)
                break
            end
        end
        
        if #self.touches == 1 then
            self.mx = 0
            self.my = 0
        end
    end
    
    -- When all touches are finished apply momentum if moving fast enough
    if #self.touches == 0 then
        self.mx = -touch.deltaY / DeltaTime * self.sensitivity
        self.my = -touch.deltaX / DeltaTime * self.sensitivity
        if math.abs(self.mx) < 70 then 
            self.mx = 0
        end
        if math.abs(self.my) < 70 then 
            self.my = 0
        end
    -- When only one touch is active simply rotate the camera
    elseif #self.touches == 1 then
        self:rotate(touch.deltaX, touch.deltaY)
    end
    
    return false
end
end
------------------------------
-- FirstPersonViewer.lua
------------------------------
do
-----------------------------------------
-- FirstPersonViewer
-- Written by John Millard
-----------------------------------------
-- Description:
-- A basic viewer for first person cameras.
-- Attach to a camera's entity for basic first person controls:
-- i.e. scene.camera:add(FirstPersonViewer)
-----------------------------------------

FirstPersonViewer = class()

local IDLE = 1
local ROTATE = 2

function FirstPersonViewer:init(camera, tapHandler)
    self.camera = camera
    self.rx = 0
    self.ry = 0
    self.state = IDLE
    self.enabled = true
    self.tapHandler = tapHandler
    self.sensitivity = 0.25
    if touches then touches.addHandler(self, 0, false) end
end

function FirstPersonViewer:isActive()
    return self.state ~= IDLE
end

function FirstPersonViewer:update()
    if self.enabled then  
        -- clamp vertical rotation between -90 and 90 degrees (no upside down view)
        self.rx = math.min(math.max(self.rx, -90), 90)
        local rotation = quat.eulerAngles(self.rx,  self.ry, 0)
        self.camera.rotation = rotation
    end
end

function FirstPersonViewer:scroll(gesture)
    if gesture.state == BEGAN then 
        return true
    elseif gesture.state == MOVING then
        self.rx = self.rx - gesture.delta.y * self.sensitivity
        self.ry = self.ry - gesture.delta.x * self.sensitivity    
    end
end

function FirstPersonViewer:touched(touch)
    if self.state == IDLE then
        if touch.state == BEGAN then
            self.start = vec2(touch.x, touch.y)
        elseif touch.state == MOVING then
            local length = (vec2(touch.x, touch.y) - self.start):len()
            if length >= 5 then
                self.state = ROTATE
            end        
        end       
    elseif self.state == ROTATE then
        if touch.state == MOVING then
            self.rx = self.rx - touch.deltaY * self.sensitivity
            self.ry = self.ry - touch.deltaX * self.sensitivity
        elseif touch.state == ENDED then
            self.state = IDLE
        end           
    end
    
    return true
end

end
