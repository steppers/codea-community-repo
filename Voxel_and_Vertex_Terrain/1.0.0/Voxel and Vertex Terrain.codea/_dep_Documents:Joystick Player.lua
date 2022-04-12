-- Contents:
--    Main.lua
--    standardCameraRigs.lua
--    joystickWalkerRig.lua
--    Joystick.lua
--    rigidCapsuleRig.lua
--    Legacy.lua

------------------------------
-- Main.lua
------------------------------
do
-- Joystick Player

viewer.mode = OVERLAY

function setup()    
    --setup the scene
    scene = craft.scene()   
    makeGround()
    
    --make a player body controlled by joysticks
    --it contains a separate camera entity put inside the body 
    playerBody = joystickWalkerRig(scene:entity(), scene, asset.builtin.Blocky_Characters.Soldier)
    playerBody.position = vec3(46.5, 40, 46.5)
    playerBody.rig.isThirdPersonView = true
    
    --a control to switch between first and third person views
    parameter.boolean("thirdPersonView", true, function(value) 
        playerBody.rig.isThirdPersonView = value
    end)
end

function makeGround()
    -- Setup voxel terrain
    allBlocks = blocks()    
    scene.voxels:resize(vec3(5,1,5))      
    scene.voxels.coordinates = vec3(0,0,0)    
    -- Create ground out of grass
    scene.voxels:fill("Planks")
    scene.voxels:box(0,10,0,16*5,10,16*5)
    scene.voxels:fill("Dirt")
    scene.voxels:box(0,0,0,16*5,9,16*5)
    --something to bump into, for testing jumps
    scene.voxels:fill("Red Brick")
    scene.voxels:box(20,11,30, 50,11,60)
    scene.voxels:fill("empty")
    scene.voxels:fillStyle(REPLACE)
    scene.voxels:box(21,11,31, 49,11,59)
end

function update(dt)
    scene:update(dt)
    playerBody.update()
end

function draw()
    --update and draw scene and player
    update(DeltaTime)
    scene:draw()
    playerBody.draw()    
    --change boolean to see live updates of simulated dpads
    if true then
        pushStyle()
        local report = generateTwoStickDpadReport(playerBody.rig.joystickView) or ""
        fontSize(20)
        local w, h = textSize(report)
        fill(255, 200, 0)
        textMode(CORNER)
        text(report, WIDTH - (w * 1.15), HEIGHT - (h * 1.05) )
        popStyle()
    end
end

--functions to check the dpad-simulating outputs
function generateTwoStickDpadReport(player)
    local rig = player.rig
    if #rig.joysticks > 0 then
        local dpads = rig.dpadStates()
        local diags = rig.dpadStates(true)
        return
        "DPAD OUTPUTS:"
        .."\n\nLEFT stick:\n"
        ..dpadTableReport(dpads.leftStick)
        .."\nif diagonals allowed:\n"
        ..dpadTableReport(diags.leftStick)
        .."\n\nRIGHT stick:\n"
        ..dpadTableReport(dpads.rightStick)
        .."\nif diagonals allowed:\n"
        ..dpadTableReport(diags.rightStick)
    end
end

function generateOneDpadStickReport(stick)
    local dpad = stick:activatedDpadDirections()
    local diags = stick:activatedDpadDirections(true)
    return
    "\n--------------"..stick.type
    .."\n--angle: "..stick:angle()
    .."\n--deltas: "..stick.delta.x..", "..stick.delta.y
    .."\n--no diagonals:\n"
    ..dpadTableReport(dpad)
    .."\n--diagonals:\n"
    ..dpadTableReport(diags)
end

function dpadTableReport(dpadTable)
    return 
    "\tleft: "..tostring(dpadTable.left)
    .."\n\tright: "..tostring(dpadTable.right)
    .."\n\tup: "..tostring(dpadTable.up)
    .."\n\tdown: "..tostring(dpadTable.down)
end

end
------------------------------
-- standardCameraRigs.lua
------------------------------
do
--create an entity that houses a camera and provides get/set functions for 
--the camera properties; this entity attempts to act like a camera,
--viewer, and entity all in one
function makeCameraViewerEntityThing(scene)
    local cameraEntity = scene:entity()
    if not cameraEntity.rig then cameraEntity.rig = {} end
    local rig = cameraEntity.rig
    cameraEntity:add(craft.camera, 45, 0.1, 1000, false)
    cameraEntity.camera = cameraEntity:get(craft.camera)
    cameraEntity.fieldOfView = function(floatOrNil)
        if floatOrNil then
            cameraEntity.camera.fieldOfView = floatOrNil
        else
            return cameraEntity.camera.fieldOfView
        end 
    end
    cameraEntity.ortho = function(boolOrNil)
        if boolOrNil ~= nil then
            cameraEntity.camera.ortho = boolOrNil
        else
            return cameraEntity.camera.ortho
        end 
    end
    cameraEntity.nearPlane = function(floatOrNil)
        if floatOrNil then
            cameraEntity.camera.nearPlane = floatOrNil
        else
            return cameraEntity.camera.nearPlane
        end 
    end
    cameraEntity.farPlane = function(floatOrNil)
        if floatOrNil then
            cameraEntity.camera.farPlane = floatOrNil
        else
            return cameraEntity.camera.farPlane
        end 
    end
    cameraEntity.clearDepthEnabled = function(boolOrNil)
        if boolOrNil ~= nil then
            cameraEntity.camera.clearDepthEnabled = boolOrNil
        else
            return cameraEntity.camera.clearDepthEnabled
        end 
    end
    cameraEntity.clearColorEnabled = function(boolOrNil)
        if boolOrNil ~= nil then
            cameraEntity.camera.clearColorEnabled = boolOrNil
        else
            return cameraEntity.camera.clearColorEnabled
        end 
    end
    cameraEntity.clearColor = function(colorOrNil)
        if colorOrNil then
            cameraEntity.camera.clearColor = colorOrNil
        else
            return cameraEntity.camera.clearColor
        end 
    end
    rig.rx = 0
    rig.ry = 0
    rig.sensitivity = 0.25
    function rig.camRxRy(rx, ry)
        if (not rx) and (not ry) then
            return rig.rx, rig.ry
        end
        rig.rx, rig.ry = rx, ry
        cameraEntity.eulerAngles = vec3(rig.rx,  rig.ry, 0)
    end
    return cameraEntity
end

--clear any of the functions set by the following rigs
--(this also acts a schematic of the functions available 
--when designing your own rigs)
function clearRig(camEntity)
    if touches then     touches.removeHandler(camEntity)
    end
    camEntity.update = nil
    camEntity.touched = nil
    camEntity.scroll = nil
    camEntity.hover = nil
    camEntity.rig = nil
end

--applying a rig to a cameraViewerEntityThing is similar
--to using one of the built-in Craft viewers, except the
--properties and functions that the viewers use are here
--set directly on the entity, so that the entity itself
--is the viewer, instead of the entity being a property 
---of the viewer object

--a rig that copies the functionality of the built-in
--FirstPersonViewer
function firstPersonRig(camEntity)
    if touches then 
        touches.removeHandler(camEntity) 
        touches.addHandler(camEntity, 0, false)
    end
    if not camEntity.rig then camEntity.rig = {} end
    local rig = camEntity.rig
    rig.IDLE = 1
    rig.ROTATE = 2
    rig.state = rig.IDLE
    rig.start = vec2(0,0)
    rig.enabled = true
    rig.isActive = function()
        return rig.state ~= rig.IDLE
    end
    camEntity.update = function()
        if rig.enabled and rig.state == rig.ROTATE then  
            -- clamp vertical rotation between -90 and 90 degrees (no upside down view)
            rig.rx = math.min(math.max(rig.rx, -90), 90)
            rig.camRxRy(rig.rx, rig.ry)
        end
    end
    camEntity.touched = function(not_self, touch)
        if rig.state == rig.IDLE then
            if touch.state == BEGAN then
                rig.start = vec2(touch.x, touch.y)
            elseif touch.state == MOVING then
                local length = (vec2(touch.x, touch.y) - rig.start):len()
                if length >= 5 then
                    rig.state = rig.ROTATE
                end        
            end       
        elseif rig.state == rig.ROTATE then
            if touch.state == MOVING then
                rig.rx = rig.rx - touch.deltaY * rig.sensitivity
                rig.ry = rig.ry - touch.deltaX * rig.sensitivity
            elseif touch.state == ENDED then
                rig.state = rig.IDLE
            end           
        end
        return true
    end    
end

--a rig that copies the functionality of the built-in
--OrbitViewer
function orbitViewerRig(camEntity)
    if touches then 
        touches.removeHandler(camEntity) 
        touches.addHandler(camEntity, 0, true)
    end
    if not camEntity.rig then camEntity.rig = {} end
    local rig = camEntity.rig
    rig.target = target or vec3(0,0,0)
    rig.origin = rig.target    
    rig.zoom = 5
    rig.minZoom = 1
    rig.maxZoom = 20    
    rig.touches = {}
    rig.prev = {}    
    -- Angular momentum
    rig.mx = 0
    rig.my = 0
    -- Project a 2D point z units from the camera
    function rig.project(p, z)
        local origin, dir = camEntity.camera:screenToRay(p)   
        return origin + dir * z
    end
    -- Calculate overscroll curve for zooming
    function rig.scrollDamping(x,s)
        return s * math.log(x + s) - s * math.log(s)
    end
    -- Calculate the distance between the current two touches
    function rig.pinchDist()
        local p1 = vec2(rig.touches[1].x, rig.touches[1].y)
        local p2 = vec2(rig.touches[2].x, rig.touches[2].y)
        return p1:dist(p2)
    end
    
    -- Calculate the mid point between the current two touches
    function rig.pinchMid()
        local p1 = vec2(rig.touches[1].x, rig.touches[1].y)
        local p2 = vec2(rig.touches[2].x, rig.touches[2].y)
        return (p1 + p2) * 0.5
    end
    
    function rig.clampZoom(zoom)
        if zoom > rig.maxZoom then
            local overshoot = zoom - rig.maxZoom
            overshoot = rig.scrollDamping(overshoot, 10.0)
            zoom = rig.maxZoom + overshoot
        elseif zoom < rig.minZoom then
            local overshoot = rig.minZoom - zoom
            overshoot = rig.scrollDamping(overshoot, 10.0)
            zoom = rig.minZoom - overshoot
        end
        return zoom
    end
    
    function rig.rotate(x, y)
        rig.rx = rig.rx - y * rig.sensitivity
        rig.ry = rig.ry - x * rig.sensitivity   
        rig.camRxRy(rig.rx, rig.ry)
    end
    
    function rig.pan(p1, p2)
        local p1 = rig.project(p1, rig.zoom)  
        local p2 = rig.project(p2, rig.zoom)
        
        rig.target = rig.target + (p1-p2)  
    end
    
    function rig.scroll(not_self, gesture)
        local panMode = gesture.shift
        local zoomMode = gesture.alt
        
        if gesture.state == BEGAN then
            if #rig.touches > 0 then return false end
            
            rig.capturedScroll = true
            rig.prev.zoom = rig.zoom
            rig.prev.mid = gesture.location
            
            return true
        elseif gesture.state == MOVING then
            if panMode then
                rig.pan(gesture.location - gesture.delta, gesture.location)            
            elseif zoomMode then
                rig.zoom = rig.clampZoom(rig.prev.zoom + (gesture.location - rig.prev.mid).y * rig.sensitivity)
            else
                rig.rotate(gesture.delta.x, gesture.delta.y)
            end
            rig.prevGestureDelta = gesture.delta
        elseif gesture.state == ENDED or gesture.state == CANCELLED then
            rig.capturedScroll = false
            
            if not panMode and not zoomMode then
                local delta = rig.prevGestureDelta
                rig.mx = -delta.y / DeltaTime * rig.sensitivity
                rig.my = -delta.x / DeltaTime * rig.sensitivity        
            end
        end
    end
    
    function camEntity.update()
        if #rig.touches == 0 and not rig.capturedScroll then
            -- Apply momentum from previous swipe
            rig.rx = rig.rx + rig.mx * DeltaTime
            rig.ry = rig.ry + rig.my * DeltaTime
            rig.mx = rig.mx * 0.9
            rig.my = rig.my * 0.9 
            
            -- If zooming past min or max interpolate back to limits
            if rig.zoom > rig.maxZoom then
                local overshoot = rig.zoom - rig.maxZoom
                overshoot = overshoot * 0.9
                rig.zoom = rig.maxZoom + overshoot
            elseif rig.zoom < rig.minZoom then
                local overshoot = rig.minZoom - rig.zoom
                overshoot = overshoot * 0.9
                rig.zoom = rig.minZoom - overshoot
            end
            
        elseif #rig.touches == 2 then
            camEntity.position = rig.prev.target - camEntity.forward * rig.zoom
            
            local mid = rig.pinchMid()  
            local dist = rig.pinchDist()
            
            local p1 = rig.project(rig.prev.mid, rig.zoom)  
            local p2 = rig.project(mid, rig.zoom)
            
            rig.target = rig.prev.target + (p1-p2)  
            rig.zoom = rig.clampZoom(rig.prev.zoom * (rig.prev.dist / dist))
        end  
        
        -- Clamp vertical rotation between -90 and 90 degrees (no upside down view)
        rig.rx = math.min(math.max(rig.rx, -90), 90)
        
        -- Calculate the camera's position and rotation
        --[[
        local rotation = quat.eulerAngles(self.rx,  self.ry, 0)
        self.entity.rotation = rotation
        ]]
        rig.camRxRy(rig.rx, rig.ry)
        local t = vec3(rig.target.x, rig.target.y, rig.target.z)
        --self.entity.position = t + self.entity.forward * -self.zoom
        --not sure how above translates to this paradigm...
        camEntity.position = t + camEntity.forward * -rig.zoom
    end
    
    function camEntity.touched(not_self, touch)
        if touch.tapCount == 2 then
            rig.target = rig.origin
        end
        
        if rig.capturedScroll then return false end
        
        -- Allow a maximum of 2 touches
        if touch.state == BEGAN and #rig.touches < 2 then
            table.insert(rig.touches, touch)
            if #rig.touches == 2 then
                rig.prev.target = vec3(rig.target:unpack())
                rig.prev.mid = rig.pinchMid()
                rig.prev.dist = rig.pinchDist()
                rig.prev.zoom = rig.zoom
                rig.mx = 0
                rig.my = 0
            end        
            return true
            -- Cache updated touches
        elseif touch.state == MOVING then
            for i = 1,#rig.touches do
                if rig.touches[i].id == touch.id then
                    rig.touches[i] = touch
                end
            end
            -- Remove old touches
        elseif touch.state == ENDED or touch.state == CANCELLED then
            for i = #rig.touches,1,-1 do
                if rig.touches[i].id == touch.id then
                    table.remove(rig.touches, i)
                    break
                end
            end
            
            if #rig.touches == 1 then
                rig.mx = 0
                rig.my = 0
            end
        end
        
        -- When all touches are finished apply momentum if moving fast enough
        if #rig.touches == 0 then
            rig.mx = -touch.deltaY / DeltaTime * rig.sensitivity
            rig.my = -touch.deltaX / DeltaTime * rig.sensitivity
            if math.abs(rig.mx) < 70 then 
                rig.mx = 0
            end
            if math.abs(rig.my) < 70 then 
                rig.my = 0
            end
            -- When only one touch is active simply rotate the camera
        elseif #rig.touches == 1 then
            rig.rotate(touch.deltaX, touch.deltaY)
        end
        
        return false
    end
end

end
------------------------------
-- joystickWalkerRig.lua
------------------------------
do
-- a rig that combines the joystick rig with the rigid capsule rig
--and makes the left joystck control the capsule motion
function joystickWalkerRig(entity, scene, blockCharacterAsset)
    --give the entity a rigidbody capsule rig
    --which DOES NOT INCLUDE a camera
    entity = rigidCapsuleRig(entity, scene)
    rig = entity.rig
    rig.contollerYInputAllowed = false
    rig.rb.linearDamping = 0.97
    
    --make a new entity to house the visible model
    --this can't be the model of the entity itself, because it
    --has to be able to scale separately from the rigid capsule
    rig.entityWithModel = scene:entity()
    if blockCharacterAsset then
        rig.entityWithModel.model = craft.model(blockCharacterAsset)
    end
    rig.entityWithModel.position = vec3(0, -0.998, 0)
    rig.entityWithModel.scale = vec3(0.12485, 0.12485, 0.12485)
    rig.entityWithModel.parent = entity
    scene.physics.gravity = vec3(0,-60.8,0) --was -14.8
    
    --make another new separate camEntity, give it a joystick camera rig,
    --and make it a child of the body, so it moves with the body
    --THIS IS THE ACTUAL CAMERA
    rig.joystickView = makeCameraViewerEntityThing(scene)
    rig.joystickView = doubleJoystickRig(rig.joystickView)
    rig.headPosition = vec3(0, 0.95, 0)
    rig.joystickView.parent = entity
    rig.isThirdPersonView = false
    
    --a function to align the camera and body if in third-person view
    function orientCamera()
        if rig.isThirdPersonView then
            local jView = rig.joystickView
            local pointToOffsetFrom = vec3(0, 1.5, -0.25) --includes offset for back of head
            local distanceMultiplier = 7
            local newPosition = pointToOffsetFrom - jView.forward * distanceMultiplier
            --at higher angles move camera closer to body
            while newPosition.y < -0.9 do
                distanceMultiplier = distanceMultiplier * 0.999
                newPosition = pointToOffsetFrom - jView.forward * distanceMultiplier
            end
            jView.position = newPosition
        end
    end
    
    --a function for the left joystick to control the rigidBody
    function moveCapsule(stick)
        local delta = stick.delta          
        local forward = rig.joystickView.forward * delta.y
        local right = rig.joystickView.right * -delta.x   
        local finalDir = forward + right   
        if not rig.contollerYInputAllowed then       
            finalDir.y = 0
        end
        if finalDir:len() > 0 then
            finalDir = finalDir:normalize()
        end    
        finalDir.x = math.min(finalDir.x or 2)
        finalDir.z = math.min(finalDir.z or 2)
        rig.move(finalDir)
        --hopefully this eliminates model jittering
        orientCamera()
    end
    
    --assign the new joystick functions
    --(the joystickView is a separate entity with its own rig)
    rig.joystickView.rig.setOutputReciever(moveCapsule, orientCamera)
    
    --merge the draw and update functions of the entity and the 
    --joystick entity. 'Draw' is easy because the entity doesn't have its own 
    --draw function, but the entity does have its own update function, so 
    --that has to be combined with the camera update function
    entity.draw = rig.joystickView.draw
    entity.touched = rig.joystickView.touched
    local ceUpdate, jvUpdate = entity.update, rig.joystickView.update
    entity.update = function()
        ceUpdate()
        jvUpdate()
        --angle the body to keep back of head facing camera
        rig.entityWithModel.eulerAngles = vec3(0,  rig.joystickView.rig.ry, 0)
        if rig.isThirdPersonView and rig.joystickView.z == 0 then
            orientCamera()
            rig.entityWithModel.active = true
        elseif (not rig.isThirdPersonView) and rig.joystickView.z ~= 0 then 
            rig.joystickView.position = rig.headPosition
            rig.entityWithModel.active = false
        end
    end
    
    --send back the entity
    --the structure created is:
      --the main entity, with a rig table:
        --a rigidbody (rig.rb) attached to the main entity
        --a separate entity with the visible model (rig.entityWithModel)
        --a separate entity with the joystick camera (rig.joystickView)
    --both the visible model and the joystickView are children of the 
    --main entity
    return entity
end

--a rig that creates two joysticks and a camera
--and sets the right joystick to control the camera
function doubleJoystickRig(camEntity)
    if touches then 
        touches.removeHandler(camEntity) 
        touches.addHandler(camEntity, 0, true)
    end
    if not camEntity.rig then camEntity.rig = {} end
    local rig = camEntity.rig
    rig.IDLE = 1
    rig.ROTATING = 2
    rig.touch = {}
    rig.touch.NONE = 1
    rig.touch.BEGAN = 2
    rig.touch.DRAGGING = 3
    rig.touch.LONG_PRESS = 4
    rig.state = rig.IDLE
    rig.start = vec2(0,0)
    rig.enabled = true
    rig.longPressDuration = longPressDuration or 1.0
    rig.dragThreshold = dragThreshold or 5
    rig.touchState = rig.touch.NONE
    rig.outputReceivers = {}
    rig.joysticks = {}   
    rig.isActive = function()
        return rig.state ~= rig.IDLE
    end
    
    function rig.defaultRightOutputReciever()
        local function setCameraRxRyFrom(stick)
            rig.rx = rig.rx - stick.delta.y * rig.sensitivity * 0.018
            rig.ry = rig.ry - stick.delta.x * rig.sensitivity * 0.018
        end
        return setCameraRxRyFrom
    end
    
    function rig.setOutputReciever(functionForLeftStick, functionForRightStick)
        local outputTable = {left = functionForLeftStick, right = functionForRightStick}
        table.insert(rig.outputReceivers, outputTable)
    end
    
    rig.setOutputReciever(nil, rig.defaultRightOutputReciever())
    
    function rig.dpadStates(diagonalsAllowed)
        local rightStick = {left = false, right = false, up = false, down = false}
        local leftStick = {left = false, right = false, up = false, down = false}
        if rig.joysticks then
            for _, stick in ipairs(rig.joysticks) do
                if stick.type == "rightStick" then
                    rightStick = stick:activatedDpadDirections(diagonalsAllowed)
                end
                if stick.type == "leftStick" then
                    leftStick = stick:activatedDpadDirections(diagonalsAllowed)
                end
            end
        end
        return {rightStick = rightStick, leftStick = leftStick}
    end
    
    function camEntity.update()
        --from first person viewer
        if rig.enabled and #rig.joysticks > 0 then  
            -- clamp vertical rotation between -90 and 90 degrees (no upside down view)
            rig.rx = math.min(math.max(rig.rx, -90), 90)
            rig.camRxRy(rig.rx, rig.ry)
        end
        for _, stick in ipairs(rig.joysticks) do
            for _, outputFunctions in ipairs(rig.outputReceivers) do
                if outputFunctions.left and stick.type == "leftStick" then
                    outputFunctions.left(stick)
                elseif outputFunctions.right and stick.type == "rightStick" then
                    outputFunctions.right(stick)
                end 
            end
        end
    end
    
    function camEntity.touched(not_self, touch)
        if touch.state==BEGAN then
            if #rig.joysticks < 2 then
                if touch.x<WIDTH/2 then 
                    if #rig.joysticks == 0 or (rig.joysticks[1] and rig.joysticks[1].type ~= "leftStick") then 
                        table.insert(rig.joysticks, Joystick(touch.x,touch.y,touch.id,"leftStick")) 
                    end
                elseif #rig.joysticks == 0 or (rig.joysticks[1] and rig.joysticks[1].type ~= "rightStick") then
                    table.insert(rig.joysticks,Joystick(touch.x,touch.y,touch.id,"rightStick")) 
                end
            end
        elseif touch.state == ENDED or touch.state == CANCELLED then
            for i=#rig.joysticks, 1, -1 do
                if rig.joysticks[i].touchID == touch.id then
                    table.remove(rig.joysticks, i)
                end
            end
        else 
            for i, stick in ipairs(rig.joysticks) do
                if stick.touchID == touch.id then
                    stick:touched(touch)
                end 
            end
        end    
        
        return true
    end    
    
    function camEntity.draw()
        for a,j in pairs(rig.joysticks) do
            j:draw()
        end
    end
    
    return camEntity
end

end
------------------------------
-- Joystick.lua
------------------------------
do
-- A class that draws a simulated joystick and tracks the angle and 
--length of the current touch from the  touch that it spawned woth.
--it also can represent the joystick position as a directional-pad state.
Joystick = class()

function Joystick:init(x,y,id,ty, strokeColor1, strokeColor2)
    self.ox=x
    self.oy=y
    self.cx=x
    self.cy=y
    self.dx=0
    self.dy=0
    self.type=ty
    self.c=20
    self.touchID = id
    self.touchX = x
    self.touchY = y
    self.delta = vec2(0,0)
    self.smallRadius = 80
    self.largeRadius = 150
    self.stroke1 = strokeColor1 or color(255, 103)
    self.stroke2 = strokeColor2 or color(255, 163)
end

function Joystick:draw()
    local bigCircleFill = color(self.stroke1.r, self.stroke1.g, self.stroke1.b, 8)
    local smallCircleFill = color(self.stroke1.r, self.stroke1.g, self.stroke1.b, 16)
    pushStyle()
    stroke(self.stroke1)
    strokeWidth(2)
    fill(bigCircleFill)
    ellipse(self.ox,self.oy, self.largeRadius)
    stroke(self.stroke2)
    fill(smallCircleFill)
    ellipse(self.touchX,self.touchY, self.smallRadius)
    popStyle()
end

function Joystick:angle()
    return math.atan2(self.delta.y, self.delta.x) * 180 / math.pi
end

--returns table with booleans for the state of left, right, up, and down buttons
function Joystick:activatedDpadDirections(diagonalsAllowed)
    --note: angle 0 points right, 90 points up, -90 points down --127 is left *and* up on no diags
    local padState = {left = false, right = false, up = false, down = false}
    local angle = self:angle()
    --ignore stick position if it's basically centered
    if math.abs(self.delta.x) < self.largeRadius * 0.2
    and math.abs(self.delta.y) < self.largeRadius * 0.2
    then return padState end
    --set ranges to convert angles to dpad presses
    local downRange = {under = -45, over = -125}
    local upRange = {under = 125, over = 45}
    local rightRange = {under = upRange.over, over = downRange.under}
    local leftRange = {under = downRange.over, over = upRange.under}
    --if diagonals are allowed, expand all ranges a bit so there's overlap
    if diagonalsAllowed then
        local variance = 25
        upRange.under = upRange.under + variance
        upRange.over = upRange.over - variance
        downRange.under = downRange.under + variance
        downRange.over = downRange.over - variance
        leftRange.under = leftRange.under + variance
        leftRange.over = leftRange.over - variance
        rightRange.under = rightRange.under + variance
        rightRange.over = rightRange.over - variance
    end
    --calculate up and down button states
    if angle < upRange.under and angle > upRange.over then
        padState.up = true
    elseif angle < downRange.under and angle > downRange.over then
        padState.down = true
    end
    --calculate left and right button states
    if angle < leftRange.under or angle > leftRange.over then
        padState.left = true
    elseif (angle < rightRange.under and angle > 0 ) or (angle > rightRange.over and angle < 0) then
        padState.right = true
    end
    return padState
end
    
function Joystick:touched(t)
    if t.id == self.touchID then
        self.touchX = t.x
        self.touchY = t.y
        self.delta = vec2(self.touchX - self.ox, self.touchY - self.oy)
    end
end


end
------------------------------
-- rigidCapsuleRig.lua
------------------------------
do
-- A function that attaches a rigid body capsule to an entity and 
--provides a way to push the body along an angle. The body does a small 
-- jump when it bumps into something.
function rigidCapsuleRig(anEntity, scene, shouldShowCapsule)
    if not anEntity.rig then anEntity.rig = {} end
    local rig = anEntity.rig
    rig.GROUP = 1<<11
    rig.speed = 10
    rig.maxForce = 80
    rig.jumpForce = 20.5 -- was 5.5
    rig.rb = anEntity:add(craft.rigidbody, DYNAMIC, 1)
    rig.rb.angularFactor = vec3(0,0,0) -- disable rotation
    rig.rb.sleepingAllowed = false
    rig.rb.friction = 0.5
    rig.rb.group = rig.GROUP
    anEntity:add(craft.shape.capsule, 0.5, 1.0)  
    scene.physics.gravity = vec3(0,-14.8,0)  
    rig.contollerYInputAllowed = false
    if shouldShowCapsule then        
        anEntity.model = craft.model(asset.builtin.Primitives.Capsule)
        anEntity.material = craft.material(asset.builtin.Materials.Standard)
    end
    function rig.move(direction)
        rig.rb:applyForce(direction * rig.maxForce)
        
        local hit1 = scene.physics:sphereCast(anEntity.position, vec3(0,-1,0), 0.52, 0.48, ~0, ~rig.GROUP)       
        if hit1 and hit1.normal.y > 0.5 then
            rig.grounded = true
        end
        
        local hit2 = scene.physics:sphereCast(anEntity.position, vec3(0,-1,0), 0.5, 0.52, ~0, ~rig.GROUP)
        if hit2 and hit2.normal.y < 0.5 then
            rig.jump()
        end
    end
    function anEntity.update()
       -- rig.rb.friction = 0.95      --seems unnecessary    
        local v = rig.rb.linearVelocity
        v.y = 0
        
        if v:len() > rig.speed then
            v = v:normalize() * rig.speed
            v.y = rig.rb.linearVelocity.y
            rig.rb.linearVelocity = v
        end       
    end
    function rig.jump()
        local v = rig.rb.linearVelocity
        v.y = rig.jumpForce
        rig.rb.linearVelocity = v
    end
    return anEntity
end


function makeCapsuleBodyOn(anEntity, scene, shouldShowCapsule)
    anEntity.GROUP = 1<<11
    anEntity.speed = 10
    anEntity.maxForce = 10
    anEntity.jumpForce = 5.5
    anEntity.rb = anEntity:add(craft.rigidbody, DYNAMIC, 1)
    anEntity.rb.angularFactor = vec3(0,0,0) -- disable rotation
    anEntity.rb.sleepingAllowed = false
    anEntity.rb.friction = 0.5
    anEntity.rb.group = anEntity.GROUP
    anEntity:add(craft.shape.capsule, 0.5, 1.0)  
    scene.physics.gravity = vec3(0,-14.8,0)  
    anEntity.contollerYInputAllowed = false
    if shouldShowCapsule then        
        anEntity.model = craft.model(asset.builtin.Primitives.Capsule)
        anEntity.material = craft.material(asset.builtin.Materials.Standard)
    end
    function anEntity.move(direction)
        anEntity.rb:applyForce(direction * anEntity.maxForce)
        
        local hit1 = scene.physics:sphereCast(anEntity.position, vec3(0,-1,0), 0.52, 0.48, ~0, ~anEntity.GROUP)       
        if hit1 and hit1.normal.y > 0.5 then
            anEntity.grounded = true
        end
        
        local hit2 = scene.physics:sphereCast(anEntity.position, vec3(0,-1,0), 0.5, 0.52, ~0, ~anEntity.GROUP)
        if hit2 and hit2.normal.y < 0.5 then
            anEntity.jump()
        end
    end
    function anEntity.update()
        anEntity.rb.friction = 0.95          
        local v = anEntity.rb.linearVelocity
        v.y = 0
        
        if v:len() > anEntity.speed then
            v = v:normalize() * anEntity.speed
            v.y = anEntity.rb.linearVelocity.y
            anEntity.rb.linearVelocity = v
        end       
    end
    function anEntity.jump()
        local v = anEntity.rb.linearVelocity
        v.y = anEntity.jumpForce
        anEntity.rb.linearVelocity = v
    end
    return anEntity
end
end
------------------------------
-- Legacy.lua
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

FPSWalkerViewer = class()

local IDLE = 1
local ROTATE = 2

FPSWalkerViewer.NONE = 1
FPSWalkerViewer.BEGAN = 2
FPSWalkerViewer.DRAGGING = 3
FPSWalkerViewer.LONG_PRESS = 4

function FPSWalkerViewer:init(camera, longPressDuration, dragThreshold, callbacks)
    self.camera = camera
    self.rx = 0
    self.ry = 0
    self.state = IDLE
    self.enabled = true
    self.sensitivity = 0.25
    self.longPressDuration = longPressDuration or 1.0
    self.dragThreshold = dragThreshold or 5
    self.touchState = FPSWalkerViewer.NONE
    self.outputs = {}
    self.joysticks = {}   
end

function FPSWalkerViewer:setOutputReciever(functionForLeftStick, functionForRightStick)
    local outputTable = {left = functionForLeftStick, right = functionForRightStick}
    table.insert(self.outputs, outputTable)
end

function FPSWalkerViewer:isActive()
    return self.state ~= IDLE
end

function FPSWalkerViewer:longPressProgress()
    if self.touchState == FPSWalkerViewer.BEGAN then
        return (ElapsedTime - self.startTime) / self.longPressDuration
    elseif self.touchState == FPSWalkerViewer.LONG_PRESS then
        return 1.0
    end
    return 0
end

function FPSWalkerViewer:update()
    if self.touchState == FPSWalkerViewer.BEGAN then
        if ElapsedTime - self.startTime >= self.longPressDuration then
            self.touchState = FPSWalkerViewer.LONG_PRESS
            touches.share(self, self.lastTouch, 0)
            --if self.callbacks.longPressed then self.callbacks.longPressed(self.lastTouch) end
        end
    end
    
    if self.touchState == FPSWalkerViewer.LONG_PRESS then
       -- if self.callbacks.longPressing then self.callbacks.longPressing(self.lastTouch) end
    end
    
    if self.touchState == FPSWalkerViewer.DRAGGING then
    --    if self.callbacks.dragging then self.callbacks.dragging(self.lastTouch) end
    end

    for _, stick in ipairs(self.joysticks) do
        for _, outputTable in ipairs(self.outputs) do
            if outputTable.left and stick.type == "leftStick" then
                outputTable.left(stick)
            elseif outputTable.right and stick.type == "rightStick" then
                outputTable.right(stick)
            end 
        end
    end
end

function FPSWalkerViewer:scroll(gesture)
    if gesture.state == BEGAN then 
        return true
    elseif gesture.state == MOVING then
        self.rx = self.rx - gesture.delta.y * self.sensitivity
        self.ry = self.ry - gesture.delta.x * self.sensitivity    
    end
end

function FPSWalkerViewer:touched(touch)
    
    if touch.state==BEGAN then
        if #self.joysticks < 2 then
            if touch.x<WIDTH/2 then 
                if #self.joysticks == 0 or (self.joysticks[1] and self.joysticks[1].type ~= "leftStick") then 
                    table.insert(self.joysticks,Joystick(touch.x,touch.y,touch.id,"leftStick")) 
                end
            elseif #self.joysticks == 0 or (self.joysticks[1] and self.joysticks[1].type ~= "rightStick") then
                 table.insert(self.joysticks,Joystick(touch.x,touch.y,touch.id,"rightStick")) 
            end
        end
    elseif touch.state == ENDED or touch.state == CANCELLED then
        for i=#self.joysticks, 1, -1 do
            if self.joysticks[i].touchID == touch.id then
                table.remove(self.joysticks, i)
            end
        end
    else 
        for i, stick in ipairs(self.joysticks) do
            if stick.touchID == touch.id then
                stick:touched(touch)
            end 
        end
    end    
    
    if self.state == IDLE then
        if touch.state == BEGAN then
            self.start = vec2(touch.x, touch.y)
        elseif touch.state == MOVING and self.start then
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
    
    self.lastTouch = touch
    
    if self.touchState == FPSWalkerViewer.NONE then
        if touch.state == BEGAN then
            self.startPos = vec2(touch.x, touch.y)
            self.startTime = ElapsedTime
            self.touchState = FPSWalkerViewer.BEGAN
          --  if self.callbacks.began then self.callbacks.began(touch) end
            return true
        end
    end
    
    if self.touchState ~= FPSWalkerViewer.NONE then
        if touch.state == ENDED or touch.state == CANCELLED then
            if self.touchState == FPSWalkerViewer.BEGAN then
              --  if self.callbacks.tapped then self.callbacks.tapped(touch) end
            end
         --   if self.callbacks.ended then self.callbacks.ended(touch) end
            self.touchState = FPSWalkerViewer.NONE
        end
    end
    
    
    if self.touchState == FPSWalkerViewer.BEGAN then
        if touch.state == MOVING then
            self.endPos = vec2(touch.x, touch.y)
            if self.startPos:dist(self.endPos) >= self.dragThreshold then
                self.touchState = FPSWalkerViewer.DRAGGING
                touches.share(self, touch, 0)
            end
        end
    end
    
    return true
end

function FPSWalkerViewer:draw()
    for a,j in pairs(self.joysticks) do
        j:draw()
    end
end
    
    
voxelWalkerMaker = function(currentScene, x, y, z)
    return currentScene:entity():add(VoxelWalker, currentScene, currentScene.camera:get(craft.camera), x, y, z)
end

VoxelWalker = class()
VoxelWalker.GROUP = 1<<11

function VoxelWalker:init(entity, currentScene, sceneCamera, x, y, z)
    local x = x or 40
    local y = y or 20
    local z = z or 40
    assert(touches, "Please include Touches project as a dependency")
    self.scene = currentScene
    self.entity = self.scene:entity()  
    self.camera = sceneCamera
    self.viewer = self.camera.entity:add(FPSWalkerViewer, 0.6, 5, {})
    self.viewer:setOutputReciever(self:defaultLeftStickFunction(), self:defaultRightStickFunction())
    self.camera.ortho = false    
    self.speed = 10
    self.maxForce = 35
    self.jumpForce = 5.5
    self.viewer.rx = 45
    self.viewer.ry = -45   
    self.entity.position = vec3(x, y, z)
    self.camera.entity.parent = self.entity
    self.camera.entity.position = vec3(0,0.85,0)    
    touches.addHandler(self, 0, true)    
    -- Player physics
    self.rb = self.entity:add(craft.rigidbody, DYNAMIC, 1)
    self.rb.angularFactor = vec3(0,0,0) -- disable rotation
    self.rb.sleepingAllowed = false
    self.rb.friction = 0.5
    self.rb.group = VoxelWalker.GROUP
    self.entity:add(craft.shape.capsule, 0.5, 1.0)    
    self.scene.physics.gravity = vec3(0,-14.8,0)
    self.contollerYInputAllowed = false
end

function VoxelWalker:setOutputReciever(functionForLeftStick, functionForRightStick)
    self.viewer:setOutputReciever(functionForLeftStick, functionForRightStick)
end

function VoxelWalker:setupCameras()
    if not self.camera then
        self.camera = self.scene.camera:get(craft.camera)
    end
    if not self.viewer then
        self.viewer = self.camera.entity:add(FPSWalkerViewer, 0.6, 5, {})
    end
end

function VoxelWalker:touched(touch)
    if (not self.camera) or (not self.viewer) or (not self.viewer.touch) then
        self:setupCameras()
    end
    if self.viewer then
        self.viewer:touched(touch)
    end
    return true
end

function VoxelWalker:defaultLeftStickFunction()
    return function(stick)
        local delta = stick.delta          
        local forward = self.camera.entity.forward * delta.y
        local right = self.camera.entity.right * -delta.x   
        local finalDir = forward + right   
        if not self.contollerYInputAllowed then       
            finalDir.y = 0
        end
        if finalDir:len() > 0 then
            finalDir = finalDir:normalize()
        end    
        finalDir.x = math.min(finalDir.x or 2)
        finalDir.z = math.min(finalDir.z or 2)
        self.rb:applyForce(finalDir * self.maxForce)
        
        local hit1 = self.scene.physics:sphereCast(self.entity.position, vec3(0,-1,0), 0.52, 0.48, ~0, ~VoxelWalker.GROUP)
        
        if hit1 and hit1.normal.y > 0.5 then
            self.grounded = true
        end
        
        local hit2 = self.scene.physics:sphereCast(self.entity.position, vec3(0,-1,0), 0.5, 0.52, ~0, ~VoxelWalker.GROUP)
        if hit2 and hit2.normal.y < 0.5 then
            self:jump()
        end
    end
end

function VoxelWalker:defaultRightStickFunction()
    return function(_)
        if self.viewer.enabled then  
            -- clamp vertical rotation between -90 and 90 degrees (no upside down view)
            self.viewer.rx = math.min(math.max(self.viewer.rx, -90), 90)
            local rotation = quat.eulerAngles(self.viewer.rx,  self.viewer.ry, 0)
            self.viewer.camera.rotation = rotation
        end
    end
end

function VoxelWalker:update()
    
    if (not self.camera) or (not self.viewer) or (not self.viewer.touch)  then
        self:setupCameras()
    end
    if not self.viewer.joysticks then
        self.viewer.joysticks = {}
    end
    
    for _, stick in ipairs(self.viewer.joysticks) do
        ----------
    end
    
    self.rb.friction = 0.95          
    local v = self.rb.linearVelocity
    v.y = 0
    
    if v:len() > self.speed then
        v = v:normalize() * self.speed
        v.y = self.rb.linearVelocity.y
        self.rb.linearVelocity = v
    end       
end

function VoxelWalker:dpadStates(diagonalsAllowed)
    local rightStick = {left = false, right = false, up = false, down = false}
    local leftStick = {left = false, right = false, up = false, down = false}
    if self.viewer.joysticks then
        for _, stick in ipairs(self.viewer.joysticks) do
            if stick.type == "rightStick" then
                rightStick = stick:activatedDpadDirections(diagonalsAllowed)
            end
            if stick.type == "leftStick" then
                leftStick = stick:activatedDpadDirections(diagonalsAllowed)
            end
        end
    end
    return {rightStick = rightStick, leftStick = leftStick}
end

function VoxelWalker:draw()
    if (not self.camera) or (not self.viewer) or (not self.viewer.touch)  then
        self:setupCameras()
    end
    if self.viewer and self.viewer.draw then 
        self.viewer:draw()
    end
end

function VoxelWalker:jump()
    local v = self.rb.linearVelocity
    v.y = self.jumpForce
    self.rb.linearVelocity = v
end

end
