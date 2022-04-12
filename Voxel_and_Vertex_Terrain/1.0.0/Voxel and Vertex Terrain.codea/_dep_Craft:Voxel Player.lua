-- Contents:
--    Main.lua
--    FirstPersonTouch.lua
--    NavigationPad.lua
--    BlockInventory.lua
--    BasicPlayer.lua

------------------------------
-- Main.lua
------------------------------
do
-- Basic Player

viewer.mode = FULLSCREEN

function setup()
    scene = craft.scene()

    -- Setup camera and lighting
    scene.sun.rotation = quat.eulerAngles(25, 125, 0)

    -- Set the scenes ambient lighting
    scene.ambientColor = color(127, 127, 127, 255)   
    
    allBlocks = blocks()    
    
    -- Setup voxel terrain
    scene.voxels:resize(vec3(5,1,5))      
    scene.voxels.coordinates = vec3(0,0,0)
    
    -- Create ground put of grass
    scene.voxels:fill("Redstone Ore")
    scene.voxels:box(0,10,0,16*5,10,16*5)
    scene.voxels:fill("Dirt")
    scene.voxels:box(0,0,0,16*5,9,16*5)

    player = scene:entity():add(BasicPlayer, scene.camera:get(craft.camera), 40, 20, 40)

end

function update(dt)
    scene:update(dt)
end

function draw()
    update(DeltaTime)

    scene:draw()
    player:draw()
end


end
------------------------------
-- FirstPersonTouch.lua
------------------------------
do
FirstPersonTouch = class()

FirstPersonTouch.NONE = 1
FirstPersonTouch.BEGAN = 2
FirstPersonTouch.DRAGGING = 3
FirstPersonTouch.LONG_PRESS = 4

function FirstPersonTouch:init(entity, longPressDuration, dragThreshold, callbacks)
    self.longPressDuration = longPressDuration or 1.0
    self.dragThreshold = dragThreshold or 5
    self.state = FirstPersonTouch.NONE
    self.callbacks = callbacks or {}
    touches.addHandler(self, -1, false)
end

function FirstPersonTouch:longPressProgress()
    if self.state == FirstPersonTouch.BEGAN then
        return (ElapsedTime - self.startTime) / self.longPressDuration
    elseif self.state == FirstPersonTouch.LONG_PRESS then
        return 1.0
    end
    return 0
end

function FirstPersonTouch:update()
    if self.state == FirstPersonTouch.BEGAN then
        if ElapsedTime - self.startTime >= self.longPressDuration then
            self.state = FirstPersonTouch.LONG_PRESS
            touches.share(self, self.lastTouch, 0)
            if self.callbacks.longPressed then self.callbacks.longPressed(self.lastTouch) end
        end
    end
    
    if self.state == FirstPersonTouch.LONG_PRESS then
        if self.callbacks.longPressing then self.callbacks.longPressing(self.lastTouch) end
    end
    
    if self.state == FirstPersonTouch.DRAGGING then
        if self.callbacks.dragging then self.callbacks.dragging(self.lastTouch) end
    end
end

function FirstPersonTouch:touched(touch)
    self.lastTouch = touch    
    
    if self.state == FirstPersonTouch.NONE then
        if touch.state == BEGAN then
            self.startPos = vec2(touch.x, touch.y)
            self.startTime = ElapsedTime
            self.state = FirstPersonTouch.BEGAN
            if self.callbacks.began then self.callbacks.began(touch) end
            return true
        end
    end
    
    if self.state == FirstPersonTouch.BEGAN then
        if touch.state == MOVING then
            self.endPos = vec2(touch.x, touch.y)
            if self.startPos:dist(self.endPos) >= self.dragThreshold then
                self.state = FirstPersonTouch.DRAGGING
                touches.share(self, touch, 0)
            end
        end
    end
    
    if self.state ~= FirstPersonTouch.NONE then
        if touch.state == ENDED or touch.state == CANCELLED then
            if self.state == FirstPersonTouch.BEGAN then
                if self.callbacks.tapped then self.callbacks.tapped(touch) end
            end
            if self.callbacks.ended then self.callbacks.ended(touch) end
            self.state = FirstPersonTouch.NONE
        end
    end

end

end
------------------------------
-- NavigationPad.lua
------------------------------
do
NavigationPad = class()

NavigationPad.ButtonSize = 64

function NavigationPad:init()

    local bs = NavigationPad.ButtonSize

    -- you can accept and set parameters here
    self.panel = ui.panel
    {
        x = WIDTH - bs*3 - 20,
        y = 100,
        w = bs*3,
        h = bs*3,
        pivot = vec2(1,0),
        align = {h = ui.RIGHT, v = ui.BOTTOM}
        --bg = readImage("Documents:grey_button11"),
        --fill = color(67, 67, 67, 107)
    }
    self.panel.interactive = true

    sprite(asset.builtin.Blocks.Blank_White)

    self.buttons =
    {
        forward = self:navButton(bs, bs*2, bs, bs, 2, "UI:Grey Arrow Up White", 0),
        right = self:navButton(bs*2, bs, bs, bs, 2, "UI:Grey Arrow Up White", -90),
        backward = self:navButton(bs, 0, bs, bs, 2, "UI:Grey Arrow Up White", -180),
        left = self:navButton(0, bs, bs, bs, 2 ,"UI:Grey Arrow Up White", 90),
        middle = self:navButton(bs, bs, bs, bs, 2, "UI:Grey Circle", 0),
        forwardLeft = self:navButton(0, bs*2, bs, bs, 2, "UI:Grey Arrow Up White", 45),
        forwardRight = self:navButton(bs*2, bs*2, bs, bs, 2, "UI:Grey Arrow Up White", -45)
    }
end

function NavigationPad:navButton(x,y,w,h,border,icon,r)
    local button = ui.button
    {
        x=x-5,
        y=y-5,
        w=w+10,
        h=h+10,
        align = {h = ui.STRETCH, v = ui.STRETCH},
        normalBg = "Blocks:Blank White",
        parent = self.panel,
        border = border + 5,
        normalFill = color(63, 63, 63, 255),
        highlightedFill = color(127, 127, 127, 255),
        inset = 0
    }

    if icon then
        button.icon.img = icon
        button.icon.rotation = r
    end

    button.share = true

    return button
end

function NavigationPad:draw()
    self.panel:update()
    self.panel:draw()
end

end
------------------------------
-- BlockInventory.lua
------------------------------
do
-- BlockImventory
-- A basic inventory class for viewing and selecting block types.

BlockInventory = class()

function BlockInventory:init(rows, cols, itemCallback)
    self.gridRows = rows or 8
    self.gridCols = cols or 8
    self.gridSize = 64
    self.border = 5
    self.spacing = 5

    local w,h =
        self.gridCols * self.gridSize + self.border * 2 + (self.gridCols-1) * self.spacing,
        self.gridRows * self.gridSize + self.border * 2 + (self.gridRows-1) * self.spacing

    self.panel = ui.panel
    {
        anchor = vec2(0.5, 1.0),
        pivot = vec2(0.5, 0.0),
        w = w,
        h = h,
        align = {h = ui.CENTER, v = ui.TOP},
        bg = "UI:Grey Panel",
        inset = 10,
    }

    self.panel.cornerRadius = 5

    self.title = ui.label
    {
        text = "",
        fontSize = 30,
        w = 200,
        h = 25,
        pivot = vec2(0.5,0),
        align = {h = ui.CENTER, v = ui.TOP}
    }
    self.panel:addChild(self.title)
    self.title.anchor = vec2(0.5,1.0)

    self.itemCallback = itemCallback

    self.slots = {}
    for y = 1,self.gridRows do
        for x = 1,self.gridCols do
            local button = self:slotButton(x,self.gridRows+1-y)
            local slot = {button = button}
            slot.index = #self.slots+1

            slot.button.onPressed = function(b)
                if self.itemCallback then
                    self.itemCallback(self, slot)
                end
            end

            table.insert(self.slots, slot)
        end
    end
end

function BlockInventory:save(name)
    local data = {}
    data.selected = self.selected and self.selected.index
    data.slots = {}
    for k,v in pairs(self.slots) do
        local slot = {}
        if v.block then
            slot.block = v.block.name
        end
        table.insert(data.slots, slot)
    end
    print(json.encode(data))
    saveText(name, json.encode(data) )
end

function BlockInventory:load(name)
    local txt = readText(name)
    if txt then
        local data = json.decode(txt)
        local selected = data.selected
        for k,v in pairs(self.slots) do
            local blockName = data.slots[v.index].block
            if blockName then
                self:setBlock(v.index, scene.voxels.blocks:get(blockName))
                if v.index == selected then
                    self:setSelected(v)
                end
            end
        end
    end
end

function BlockInventory:open()

end

function BlockInventory:close()

end

function BlockInventory:getSlot(i)
    return self.slots[i]
end

function BlockInventory:slotCount()
    return #self.slots
end

function BlockInventory:setSelected(slot)
    if self.selected then
        self.selected.button.selected = false
    end
    self.selected = slot
    if self.selected then
        self.selected.button.selected = true
    end
end

function BlockInventory:getSelected()
    return self.selected
end


-- Add item to next empty slot
function BlockInventory:addBlock(block)
    for k,v in pairs(self.slots) do
        if v.block == nil then
            self:setBlock(v.index, block)
            return true
        end
    end
    return false
end

-- Set item for a specific slot
function BlockInventory:setBlock(index, block)
    local slot = self.slots[index]

    if block then
        slot.block = block
        if block.hasIcon then
            slot.button.icon.img = block.icon
            slot.button.label.text = ""
        else
            slot.button.icon.img = nil
            slot.button.label.text = block.longName or block.name
        end
    end

end

-- Create a new slot button
function BlockInventory:slotButton(x,y)
    local button = ui.button
    {
        x = self.border + self.gridSize * (x-1) + self.spacing * (x-1),
        y = self.border + self.gridSize * (y-1) + self.spacing * (y-1),
        w = self.gridSize,
        h = self.gridSize,
        normalBg = readImage(asset.builtin.UI.Grey_Panel),
        normalFill = color(127, 127, 127, 255),
        selectedBg = readImage(asset.builtin.UI.Blue_Panel),
        selectedFill = color(255, 255, 255, 255)
        --selectedBg = readImage()
        --bg = "Documents:grey_button11",
        --normalFill = color(79, 79, 79, 255)
    }
    button.icon = ui.image({x = 5, y = 5, w = self.gridSize-10, h = self.gridSize-10})
    button:addChild(button.icon)
    button.unselectedFill = color(255, 255, 255, 255)
    button.selectedFill = color(199, 199, 199, 255)
    button.opaque = false

    self.panel:addChild(button)
    return button
end

function BlockInventory:draw()
    self.panel:update()
    self.panel:draw()
end

end
------------------------------
-- BasicPlayer.lua
------------------------------
do
BasicPlayer = class()

BasicPlayer.GROUP = 1<<11

function BasicPlayer:init(entity, camera, x, y, z)
    assert(touches, "Please include Touches project as a dependency")
    assert(ui, "Please include UI project as a dependency")
    assert(FirstPersonViewer, "Please include Cameras project as a dependency")
    assert(blocks, "Please include Block Library project as a dependency")
    assert(allBlocks, "Blocks arent loaded, please add 'allBlocks = blocks()' to setup()")
    
    self.entity = entity
    
    self.camera = camera
    self.camera.ortho = false
 
    self.speed = 4
    self.maxForce = 35
    self.jumpForce = 5.5

    self.inventory = BlockInventory(8, 8, function(inventory, slot)
        local hotbarSlot = self.hotbar:getSelected()
        if hotbarSlot and slot.block then
            local block = slot.block
            inventory.title.text = string.upper( block.longName or block.name )
            self.hotbar:setBlock(hotbarSlot.index, block)    
            self.hotbar:save("Project:Hotbar")
            sound(SOUND_PICKUP, 41674)          
        end
    end)
    
    for k,v in pairs(allBlocks) do
        if v.canPlace then
            self.inventory:addBlock(v)
        end
    end
    
    self.hotbar = BlockInventory(1,8, function(inventory, slot)
        inventory:setSelected(slot)
        self.slot = slot
        sound(SOUND_PICKUP, 41674)          
    end)
    self.hotbar.panel.pivot = vec2(0.5, 0)
    self.hotbar.panel.anchor = vec2(0.5, 15/HEIGHT)
    self.hotbar.panel.align.h = ui.CENTER
    self.hotbar.panel.align.v = ui.BOTTOM
    
    local lastSlot = self.hotbar:getSlot(self.hotbar:slotCount())
    lastSlot.button.onPressed = function(b)
        sound(SOUND_PICKUP, 41674)          
        if self.isInventoryOpen then
            tween(0.6, self.inventory.panel.anchor, {y = 1.0}, tween.easing.cubicInOut)
            self.isInventoryOpen = false
        else
            tween(0.6, self.inventory.panel.anchor, {y = 0.2}, tween.easing.cubicInOut) 
            self.isInventoryOpen = true       
        end
    end
    lastSlot.button.label.text = "INV"
    
    self.hotbar:load("Project:Hotbar")
    self.slot = self.hotbar.selected

    
    self.navPad = NavigationPad()
    
    self.navPad.buttons.middle.onPressed = function(b,t)
        if t.tapCount == 2 then
            self:setFlying(not self.flying)
            if self.flying then
                self.navPad.buttons.middle.icon:setImage("UI:Blue Box Tick")
            else
                self.navPad.buttons.middle.icon:setImage("UI:Grey Box Tick")               
            end
        end
    end
    
    -- Helper class for interactive camera
    self.viewer = self.camera.entity:add(FirstPersonViewer)
    self.viewer.rx = 45
    self.viewer.ry = -45
  
    self.entity.position = vec3(x,y,z)
    self.camera.entity.parent = self.entity
    self.camera.entity.position = vec3(0,0.85,0) 
    
    self.fpsTouch = self.camera.entity:add(FirstPersonTouch, 0.6, 5,
    {
        tapped = function(t)
            self:tapBlock(t.x, t.y)
        end,
    
        longPressed = function(t)
            self:digBlock(t.x, t.y)
            self.digTimer = 0
        end,
    
        longPressing = function(t)
            self.digTimer = self.digTimer + DeltaTime
            if self.digTimer > 0.6 then
                self:digBlock(t.x, t.y)
                self.digTimer = 0
            end 
        end
    })
    
    -- Player physics
    self.rb = self.entity:add(craft.rigidbody, DYNAMIC, 1)
    self.rb.angularFactor = vec3(0,0,0) -- disable rotation
    self.rb.sleepingAllowed = false
    self.rb.friction = 0.5
    self.rb.group = BasicPlayer.GROUP
    self.entity:add(craft.shape.capsule, 0.5, 1.0)

    self:setFlying(false)
end

function BasicPlayer:setFlying(flying)
    self.flying = flying
    if self.flying then
        scene.physics.gravity = vec3(0,0,0)
        self.rb.linearDamping = 0.9
    else
        scene.physics.gravity = vec3(0,-14.8,0)
    end
end

function BasicPlayer:update()
    self.grounded = false
    
    local moveDir = vec3(0,0,0)
    
    if self.navPad.buttons.forward.highlighted then
        moveDir.z = 1
    end
    if self.navPad.buttons.backward.highlighted then
        moveDir.z = moveDir.z - 1
    end
    if self.navPad.buttons.right.highlighted then
        moveDir.x = -1
    end
    if self.navPad.buttons.left.highlighted then
        moveDir.x = moveDir.x + 1
    end
    if self.flying and self.navPad.buttons.middle.highlighted then
        moveDir.y = moveDir.y + 1
    end
    
    local hit1 = scene.physics:sphereCast(self.entity.position, vec3(0,-1,0), 0.52, 0.48, ~0, ~BasicPlayer.GROUP)
    
    if hit1 and hit1.normal.y > 0.5 then
        self.grounded = true
    end
    
    local hit2 = scene.physics:sphereCast(self.entity.position, vec3(0,-1,0), 0.5, 0.52, ~0, ~BasicPlayer.GROUP)
    if hit2 and hit2.normal.y < 0.5 and moveDir.z == 1 then
        self:jump()
    end
    
    
    if not self.flying and self.navPad.buttons.middle.highlighted then
        self:jump()
    end
    
    if not self.flying then
        if self.grounded then
            self.rb.friction = 0.95          
        else
            self.rb.friction = 0           
        end
        self.rb.linearDamping = 0.0 
    end

    if moveDir:len() > 0 then
        moveDir = moveDir:normalize()
        
        local forward = self.camera.entity.forward * moveDir.z
        local right = self.camera.entity.right * moveDir.x
        local up = vec3(0,1,0) * moveDir.y
        
        local finalDir = forward + right + up
        
        if not self.flying then
            finalDir.y = 0
        end
        
        if finalDir:len() > 0 then
            finalDir = finalDir:normalize()
        end
        
        self.rb:applyForce(finalDir * self.maxForce)
    end
    
    local v = self.rb.linearVelocity
    if not self.flying then
        v.y = 0
    end

    if v:len() > self.speed then
        v = v:normalize() * self.speed
        if not self.flying then
            v.y = self.rb.linearVelocity.y
        end
        self.rb.linearVelocity = v
    end
    
end

function BasicPlayer:draw()
    
    local progress = self.fpsTouch:longPressProgress()
    if progress > 0 then
        pushStyle()
        noFill()
        stroke(255, 255, 255, 255)
        strokeWidth(3)
        ellipseMode(CENTER)
        ellipse(self.fpsTouch.lastTouch.x, self.fpsTouch.lastTouch.y, progress * 35 + 65 + 20 * (self.digTimer or 0))
        popStyle()      
    end
    
    self.navPad:draw()
    self.inventory:draw()
    self.hotbar:draw()
    
end

function BasicPlayer:jump()
    if self.grounded then
        local v = self.rb.linearVelocity
        v.y = self.jumpForce
        self.rb.linearVelocity = v
    end
end

function BasicPlayer:digBlock(x,y)
    local origin, dir = self.camera:screenToRay(vec2(x, y))
    scene.voxels:raycast(origin, dir, 100,
    function(coord, id, face)
        if id and id ~= 0 then
            if scene.voxels:get(coord).class.canDig then
                scene.voxels:set(coord, 0)
                sound(SOUND_HIT, 26744)
            end
            return true -- stop raycast
        else
            return false -- keep going
        end
    end)
end

function BasicPlayer:tapBlock(x,y)
    local origin, dir = self.camera:screenToRay(vec2(x, y))
    scene.voxels:raycast(origin, dir, 100,
    function(coord, id, face)
        if id and id ~= 0 then
            local b = scene.voxels:get(coord)

            if b.interact then 
                b:interact() 
            elseif self.slot and self.slot.block then
                scene.voxels:set(coord + face, self.slot.block.id)     
                local b2 = scene.voxels:get(coord + face)
                if b2.placed then
                    b2:placed(nil, face, self.camera.entity.forward)
                end
                sound(SOUND_POWERUP, 26734)           
            end
            
            return true -- stop raycast
        else
            return false -- keep going
        end
    end)
end


end
