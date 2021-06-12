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

