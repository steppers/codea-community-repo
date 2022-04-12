-- Contents:
--    Main.lua
--    Touches.lua

------------------------------
-- Main.lua
------------------------------
do
-----------------------------------------
-- Touches
-- Written by John Millard
-----------------------------------------
-- Description:
-- A simple library for handling touches.
--
-- Use touches.addHandler(handler, priority, multiTouch) to register a handler.
-- Handlers will be notified (by calling handler:touched(touch)) in order of priority (low to high)
-- Any that return true will capture the touch and recieve subsequent touch events.
-- The multi-touch option allows a single handler to capture more than one touch.
-- Use touched.removeHandler(handler) to remove existing handlers.
-----------------------------------------

-- Use this function to perform your initial setup
function setup()
    print("Hello Touches!")

    scene = craft.scene()
    scene.camera.z = -10
    scene.ambientColor = color(42, 42, 42, 255)
    scene.sun.active = false

    ground = scene:entity()
    ground.y = -2
    ground.model = craft.model.cube(vec3(10,0.1,10))
    ground.material = craft.material(asset.builtin.Materials.Standard)

    -- Example class that uses touches library
    Bulb = class()

    function Bulb:init(entity, x, y, z, c)
        self.entity = entity
        self.entity.position = vec3(x, y, z)
        self.color = c
        self.light = self.entity:add(craft.light, POINT)
        self.light.color = c
        self.light.intensity = 0.2
        self.light.distance = 3
        self.entity:add(craft.rigidbody, STATIC)
        self.entity:add(craft.shape.sphere, 0.5)
        self.entity.model = craft.model.icosphere(0.5, 3, false)
        self.entity.material = craft.material(asset.builtin.Materials.Basic)
        self.entity.material.diffuse = c * 0.2

        -- Add to list of touch handlers
        touches.addHandler(self)
    end

    -- The touches function is automatically called on handlers
    function Bulb:touched(touch)
        if touch.state == BEGAN then

            -- Returning true will capture this touch and prevent other handlers from getting it
            local origin, dir =
                scene.camera:get(craft.camera):screenToRay(vec2(touch.x, touch.y))

            -- Do a raycast to check if touch is hitting the bulb
            hit = scene.physics:raycast(origin, dir, 10)

            if hit and hit.entity == self.entity then
                -- Turn up light intensity
                self.light.intensity = 3
                self.entity.material.diffuse = self.color
                print("Touch Began (Captured - "..touch.id..")")
                return true
            end
        elseif touch.state == ENDED then
            -- Turn down intensity when touch ends
            self.light.intensity = 0.2
            self.entity.material.diffuse = self.color * 0.2
            print("Touch Ended (Captured - "..touch.id..")")
        end
    end

    scene:entity():add(Bulb,
        -1.5, 0, 0,
        color(182, 198, 71, 255))

    scene:entity():add(Bulb,
        0, 0, 0,
        color(199, 72, 132, 255))

    scene:entity():add(Bulb,
        1.5, 0, 0,
        color(72, 98, 198, 255))
end

function update(dt)
    scene:update(dt)
end

function draw()
    update(DeltaTime)
    scene:draw()
end

end
------------------------------
-- Touches.lua
------------------------------
do
-----------------------------------------
-- Touches
-- Written by John Millard
-----------------------------------------
-- Description:
-- A touch management class that simplifies handling multiple touch reciever.
-----------------------------------------

local TouchHandler = class()

function TouchHandler:init(target, priority, multiTouch)
    assert(target ~= nil)

    self.target = target
    self.priority = priority or 0
    self.multiTouch = multiTouch or false
    self.captured = {}
    self.count = 0
end

function TouchHandler:scroll(gesture)
    if gesture.state == BEGAN then
        if self.target.scroll and self.target:scroll(gesture) then
            self.capturedScroll = true
            self.count = self.count + 1
            return true
        end
    elseif gesture.state == MOVING then 
        if self.target.scroll and self.capturedScroll then
            self.target:scroll(gesture)
            return true
        end
    elseif gesture.state == ENDED then
        if self.target.scroll and self.capturedScroll then
            self.target:scroll(gesture)
            self.capturedScroll = nil
            self.count = self.count - 1
            return true
        end        
    end
end

function TouchHandler:hover(gesture)
    if self.target.hover then self.target:hover(gesture) end
end

function TouchHandler:touched(touch)
    if touch.state == BEGAN then
        if self.multiTouch or self.count == 0 then
            if self.target:touched(touch) then
                self.captured[touch.id] = true
                self.count = self.count + 1
                return true
            end
        end
    elseif touch.state == MOVING then
        if self.captured[touch.id] then
            self.target:touched(touch)
            return true
        end
    elseif touch.state == ENDED or touch.state == CANCELLED then
        if self.captured[touch.id] then
            self.target:touched(touch)
            self.captured[touch.id] = nil
            self.count = self.count - 1
            return true
        end
    end    

    return false
end

touches = {}
touches.handlers = {}
touches.shared = {}

function touches.share(target, touch, priority)
    local fakeTouch = 
    {
        x = touch.x,
        y = touch.y,
        id = touch.id,
        state = BEGAN,
        tapCount = touch.tapCount,
        deltaX = touch.deltaX,
        deltaY = touch.deltaY       
    }
    
    for k,v in pairs(touches.handlers) do
        if v.target ~= target and v.priority == priority then
            v:touched(fakeTouch) 
        end
    end
end

function touches.addHandler(target, priority, multiTouch)
    table.insert(touches.handlers, TouchHandler(target, priority, multiTouch))

    table.sort(touches.handlers, function(a,b)
        return a.priority < b.priority
    end)
end

function touches.removeHandler(target)
    local i = nil

    for k,v in pairs(touches.handlers) do
        if v.target == target then
            i = k
        end
    end

    table.remove(touches.handlers, i)
end

function touches.touched(touch)
    local captured = false
    for k,v in pairs(touches.handlers) do
        if v:touched(touch) then captured = true end
        if touch.state == BEGAN and captured then
            return true
        end
    end

    return captured
end

function touches.scroll(gesture)
    local captured = false
    for k,v in pairs(touches.handlers) do
        if v.scroll and v:scroll(gesture) then captured = true end
        if gesture.state == BEGAN and captured then
            return true
        end
    end

    return captured    
end

function touches.hover(gesture)
    local captured = false
    for k,v in pairs(touches.handlers) do
        if v.hover then v:hover(gesture) end
    end

    return captured        
end

function touched(touch) touches.touched(touch) end
function scroll(gesture) touches.scroll(gesture) end
function hover(gesture) touches.hover(gesture) end

end
