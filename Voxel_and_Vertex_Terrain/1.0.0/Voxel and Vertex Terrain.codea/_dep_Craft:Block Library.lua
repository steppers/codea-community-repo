-- Contents:
--    Main.lua
--    Basic.lua
--    Generators.lua
--    Sign.lua
--    Fence.lua
--    Piston.lua
--    Chest.lua
--    Sound.lua
--    TNT.lua
--    Blocks.lua
--    BlockPreview.lua

------------------------------
-- Main.lua
------------------------------
do
-----------------------------------------
-- Block Library
-- Written by John Millard
-----------------------------------------
-- Description:
-- This project contains the shared block library for Codea.
-- Add this project as a dependency and call the function blocks() to make use 
-- of it in your own voxel-based projects.
-- Run this project to see a preview of each block type
-----------------------------------------

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
    
    -- Place block pyramid
    local n = nearestTriangle(#allBlocks-1)
    local pos = vec3(32,10,32) 
    local center = vec3(0,0,0)
    local k = 2
    local offset = 0
    
    for i = n,1,-1 do
        pos.z = 40+offset
        pos.x = 40
        for j = 1,i do
            local bt = allBlocks[k]
            if bt then
                scene.voxels:set(pos, bt.id)  
                pos.x = pos.x + 1
                pos.z = pos.z + 1    
                center = center + pos  
            end
            k = k + 1
        end
        pos.y = pos.y + 1 
        offset = offset + 1 
    end
    
    -- Create ground put of grass
    scene.voxels:fill("Bedrock")
    scene.voxels:box(0,10,0,16*5,10,16*5)
    scene.voxels:fill("Dirt")
    scene.voxels:box(0,0,0,16*5,9,16*5)

    player = scene:entity():add(BasicPlayer, scene.camera:get(craft.camera), 40+n, 20, 40)
    
    printExplanation()
end


function triangle(n)
    return (n*n + n) / 2
end

function nearestTriangle(num)
    local n = 0
    local t = 0
    while t < num do
        t = triangle(n+1)
        n = n + 1
    end
    return n
end

function update(dt)
    scene:update(dt)
end

function draw()
    update(DeltaTime)

    scene:draw()
    player:draw()
end

function printExplanation()
    output.clear()
    print("This project contains a library of pre-built block types that are used by other voxel projects.")
    print("Basic blocks are generally simple solid blocks, like Grass, Dirt and Stone.")    
    print("Generator blocks, such as Tree Generator is used during terrain generation to build larger structures.")
    print("Block types can be scripted for advanced functionality and custom appearance.")
end

end
------------------------------
-- Basic.lua
------------------------------
do
-- A set of basic blocks (mainly cubes)
function basicBlocks()

    -- Assets must be added to the voxel system for them to be available
    scene.voxels.blocks:addAssetPack("Blocks")

    -- Add some helper functions to the block class
    local directions =
    {
        [NORTH] = vec3(0,0,-1),
        [EAST] = vec3(1,0,0),
        [SOUTH] = vec3(0,0,1),
        [WEST] = vec3(-1,0,0),
        [UP] = vec3(0,1,0),
        [DOWN] = vec3(0,-1,0)
    }

    function craft.block.static.faceToDirection(face)
        return directions[face]
    end

    function craft.block.static.directionToFace(dir)
        dir = vec3(dir.x, dir.y/2, dir.z):normalize()
        local minFace = nil
        local minDot = nil
        for k,v in pairs(directions) do
            local dot = dir:dot(v)
            if minFace == nil or dot < minDot then
                minFace = k
                minDot = dot
            end
        end
        return minFace
    end

    -- By default all blocks can be dug, have icons and can be placed by the player
    -- Individual block types can override these defaults
    craft.block.static.canDig = true
    craft.block.static.hasIcon = true
    craft.block.static.canPlace = true

    -- Empty block cannot be placed and has no icon
    scene.voxels.blocks.Empty.static.hasIcon = false
    scene.voxels.blocks.Empty.static.canPlace = false

    local grass = scene.voxels.blocks:new("Grass")
    grass.setTexture(ALL, "Blocks:Dirt Grass")
    grass.setTexture(DOWN, "Blocks:Dirt")
    grass.setTexture(UP, "Blocks:Grass Top")

    local dirt = scene.voxels.blocks:new("Dirt")
    dirt.setTexture(ALL, "Blocks:Dirt")

    local sand = scene.voxels.blocks:new("Sand")
    sand.setTexture(ALL, "Blocks:Sand")

    local stone = scene.voxels.blocks:new("Stone")
    stone.setTexture(ALL, "Blocks:Stone")

    local bedrock = scene.voxels.blocks:new("Bedrock")
    bedrock.setTexture(ALL, "Blocks:Greystone")
    bedrock.static.canDig = false
    bedrock.static.canPlace = false
    --bedrock.tinted = true
    bedrock.setColor(ALL, color(128, 128, 128, 255))

    local water = scene.voxels.blocks:new("Water")
    water.setTexture(ALL, "Blocks:Water")
    water.setColor(ALL, color(100,100,200,170))
    -- Translucent geometry prevents blocks from rendering internal faces between each other
    water.geometry = TRANSLUCENT
    -- Translucent renderPass is for semi-transparent blocks (i.e alpha less than 255 and greater than 0)
    water.renderPass = TRANSLUCENT

    local glass = scene.voxels.blocks:new("Glass")
    glass.setTexture(ALL, "Blocks:Glass")
    glass.geometry = TRANSLUCENT
    glass.renderPass = TRANSLUCENT

    local glassFrame = scene.voxels.blocks:new("Glass Frame")
    glassFrame.setTexture(ALL, "Blocks:Glass Frame")
    glassFrame.geometry = TRANSLUCENT
    glassFrame.renderPass = TRANSLUCENT

    local brickRed = scene.voxels.blocks:new("Red Brick")
    brickRed.setTexture(ALL, "Blocks:Brick Red")

    local brick = scene.voxels.blocks:new("Brick")
    brick.setTexture(ALL, "Blocks:Brick Grey")

    local coalOre = scene.voxels.blocks:new("Coal Ore")
    coalOre.setTexture(ALL, "Blocks:Stone Coal")

    local goldOre = scene.voxels.blocks:new("Gold Ore")
    goldOre.setTexture(ALL, "Blocks:Stone Gold")

    local diamondOre = scene.voxels.blocks:new("Diamond Ore")
    diamondOre.setTexture(ALL, "Blocks:Stone Diamond")

    local redstoneOre = scene.voxels.blocks:new("Redstone Ore")
    redstoneOre.setTexture(ALL, "Blocks:Redstone")

    local planks = scene.voxels.blocks:new("Planks")
    planks.setTexture(ALL, "Blocks:Wood")

    local wood = scene.voxels.blocks:new("Wood")
    wood.setTexture(ALL, "Blocks:Trunk Side")
    wood.setTexture(DOWN, "Blocks:Trunk Top")
    wood.setTexture(UP, "Blocks:Trunk Top")

    local leaves = scene.voxels.blocks:new("Leaves")
    leaves.setTexture(ALL, "Blocks:Leaves Transparent")
    --leaves.geometry = TRANSPARENT
    --leaves.renderPass = CUTOUT
    leaves.scripted = true

    local craftingTable = scene.voxels.blocks:new("Crafting Table")
    craftingTable.setTexture(ALL, "Blocks:Table")
end

end
------------------------------
-- Generators.lua
------------------------------
do

function treeGenerator()
    local tree = scene.voxels.blocks:new("Tree Generator")
    tree.scripted = true
    tree.geometry = EMPTY -- Make generator block invisible
    tree.static.canDig = false
    tree.static.hasIcon = false
    tree.static.canPlace = false
          
    function tree:created()
        self:schedule(60)
    end
    
    function tree:blockUpdate(t)
        local x,y,z = self:xyz()
        
        -- Check is enough surrounding area has been loaded to generate
        if self.voxels:isRegionLoaded(x-3, y, z-3, x+3, y,z+3) then
            self:generate()
        -- If this fails then try again in a second
        else
            self:schedule(60)
        end
    end
    
    function tree:generate()
        local x,y,z = self:xyz()
        
        -- Base random seed on location of tree
        math.randomseed(x * y * z)
        local height = math.random(4,7)
        local size = math.floor(height/2)
        local branches = math.random(2,3) -- TODO
        self.voxels:set(x,y,z,"empty")

        -- Only grow on dirt or grass
        local ground = self.voxels:get(x, y-1, z, BLOCK_NAME)
        if ground ~= "Dirt" and ground ~= "Grass" then
            return
        end
        
        -- Check if there is enough space to grow properly
        local clear = true
        self.voxels:iterateBounds(x-1,y,z-1,x+1,y,z+1, function(x,y,z,id)
            if id and id ~= 0 then
                clear = false
            end
        end)
        self.voxels:iterateBounds(x-2,y+1,z-2,x+2,y+height,z+2, function(x,y,z,id)
            if id and id ~= 0 then
                clear = false
            end
        end)
        
        if clear == false then return end
        
        -- Trunk 
        --self.voxels:pushStyle()       
        self.voxels:set(x,y-1,z,"dirt")    
        self.voxels:fill("wood")
        self.voxels:box(x,y,z,x,y+height,z)
        
        -- Leaves
        self.voxels:fill("leaves")
        self.voxels:fillStyle(UNION)
        self.voxels:sphere(x,y+height,z,size)
        --self.voxels:popStyle()
    end
end

end
------------------------------
-- Sign.lua
------------------------------
do
-- The sign block
function signBlock()
    local sign = scene.voxels.blocks:new("Sign")
    sign.setTexture(ALL, "Blocks:Wood")
    sign.scripted = true
    sign.geometry = TRANSPARENT
    
    sign.state:addFlag("wall", false)
    sign.state:addRange("facing", EAST, NORTH, EAST)
      
    function sign:placed(entity, normal, forward)
        local pos = vec3(self:xyz())
        local surface = self.voxels:get(pos - normal)
        if surface.class.geometry ~= SOLID then
            
        end        
        
        if normal.y == 0 then
            self:set("wall", true)
            self:set("facing", craft.block.directionToFace(normal) )
        else
            self:set("facing", craft.block.directionToFace(forward) )
        end

    end
    
    function sign:buildModel(model)   
        model:clear()
        
        if self:get("wall") then
            model:addElement
            {
                lower = vec3(235,50,10),
                upper = vec3(255,205,245),        
                ao = false
            } 
        else      
            model:addElement
            {
                lower = vec3(118+20,100,10),
                upper = vec3(138+20,255,245),        
                ao = false
            } 
            
            model:addElement
            {
                lower = vec3(118,0,118),
                upper = vec3(138,255,138),        
                ao = false
            } 
        end
        
        model:rotateY(self:get("facing"))
    end
    
    return sign
end
    
function stairsBlock(name, texture)
    local stairs = scene.voxels.blocks:new(name)
    stairs.setTexture(ALL, texture)
    stairs.geometry = TRANSPARENT
    stairs.scripted = true
    
    -- custom block state (max 32 bits worth of data)
    stairs.state:addFlag("corner", false)
    stairs.state:addRange("facing", EAST, NORTH, EAST)
    
    function stairs:placed(entity, normal, forward)
        self:set("facing", craft.block.directionToFace(forward) )
    end
    
    -- custom model from state
    function stairs:buildModel(model)
        
        model:clear()
        if self:get("corner") then
            model:addElement
            {
                lower = vec3(0,0,0),
                upper = vec3(255,128,255),
                collision = STEP,
                ao = false
            }
            model:addElement
            {
                lower = vec3(128,128,128),
                upper = vec3(255,255,255),
                collision = STEP,
                ao = false    
            }
        else
            model:addElement
            {
                lower = vec3(0,0,0),
                upper = vec3(128,128,255),
                collision = STEP,
                ao = false
            }
            model:addElement
            {
                lower = vec3(128,0,0),
                upper = vec3(255,255,255),
                collision = STEP,
                ao = false
            }
        end
        
        model:rotateY(self:get("facing")+2)
    end
    
    return stairs
end
end
------------------------------
-- Fence.lua
------------------------------
do
function fence(name, texture)
    local fence = scene.voxels.blocks:new(name)
    fence.setTexture(ALL, texture)
    fence.scripted = true
    fence.geometry = TRANSPARENT
    
    fence.state:addFlag("n", false)
    fence.state:addFlag("e", false)   
    fence.state:addFlag("s", false)   
    fence.state:addFlag("w", false) 
    
    function fence:triggerUpdate()
        self:schedule(0)
        local x,y,z = self:xyz()
        self.voxels:updateBlock(x,y,z-1,0)
        self.voxels:updateBlock(x,y,z+1,0)
        self.voxels:updateBlock(x-1,y,z,0)
        self.voxels:updateBlock(x+1,y,z,0)        
    end
    
    function fence:created()
        self:triggerUpdate()
    end
    
    function fence:destroyed()
        self:triggerUpdate()
    end
    
    function fence:blockUpdate()  
        local x,y,z = self:xyz()
        self:set("n", self.voxels:get(x,y,z-1,BLOCK_ID) ~= 0)
        self:set("s", self.voxels:get(x,y,z+1,BLOCK_ID) ~= 0)
        self:set("w", self.voxels:get(x+1,y,z,BLOCK_ID) ~= 0)
        self:set("e", self.voxels:get(x-1,y,z,BLOCK_ID) ~= 0)
    end
    
    function fence:addSlats(model, var, x1, x2, z1, z2)
        if self:get(var) then
            model:addElement
            {
                lower = vec3(x1,180,z1),
                upper = vec3(x2,230,z2)
            }
            
            model:addElement
            {
                lower = vec3(x1,180-90,z1),
                upper = vec3(x2,230-90,z2)
            }
        end        
    end
    
    function fence:buildModel(model)
        model:clear()
        
        model:addElement
        {
            lower = vec3(98,0,98),
            upper = vec3(158,255,158)
        }
        
        --local n = self.get("n")
        self:addSlats(model, "n", 114, 142, 0, 98)
        self:addSlats(model, "s", 114, 142, 158, 255)        
        self:addSlats(model, "e", 0, 98, 114, 142)
        self:addSlats(model, "w", 158, 255, 114, 142)        
    end
        
    return fence
end

end
------------------------------
-- Piston.lua
------------------------------
do
-- A piston block (pushes other blocks 1 unit in a given direction)
function piston()
    -- By default all blocks can be pushed
    craft.block.static.canPush = true
    
    -- Helper function to move a block
    local function moveBlock(x,y,z,u,v,w)
        local id, state = scene.voxels:get(x,y,z, BLOCK_ID, BLOCK_STATE)
        scene.voxels:set(u,v,w, BLOCK_ID, id, BLOCK_STATE, state)
        scene.voxels:set(x,y,z, 0)
    end
    
    -- Block representing the piston's pusher
    local pusher = scene.voxels.blocks:new("Pusher")
    pusher.setTexture(ALL, "Blocks:Wood")  
    pusher.scripted = true
    pusher.geometry = TRANSPARENT   
    pusher.state:addRange("facing", 0,3,0)
    -- Cannot be dug or pushed as this will break the piston it's attached to
    pusher.static.canDig = false
    pusher.static.canPush = false
    pusher.static.hasIcon = false
    pusher.static.canPlace = false

    -- Custom appearance
    function pusher:buildModel(model)
        model:clear()
        model:addElement
        {
            lower = vec3(0,0,190),
            upper = vec3(255,255,255), 
            textures = "Blocks:Wood",           
            ao = false
        }
        
        model:addElement
        {
            lower = vec3(100,100,0),
            upper = vec3(156,156,190),  
            textures = "Blocks:Wood",    
            ao = false
        }  
    
        model:rotateY(self:get("facing"))
    end
    
    
    local piston = scene.voxels.blocks:new("Piston")  
    piston.setTexture(ALL, "Blocks:Stone")
    piston.geometry = TRANSPARENT
    piston.scripted = true    
    piston.state:addFlag("on", false)
    piston.state:addRange("facing", 0,3,0)
    piston.static.maxPush = 5
    piston.static.hasIcon = true
        
    function piston:buildModel(model)
        model:clear()
        model:addElement
        {
            lower = vec3(0,0,0),
            upper = vec3(255,255,190),        
            ao = false
        } 
        
        if not self:get("on") then
            model:addElement
            {
                lower = vec3(0,0,190),
                upper = vec3(255,255,255), 
                textures = "Blocks:Wood",           
                ao = false
            }            
        else
            model:addElement
            {
                lower = vec3(80,80,190),
                upper = vec3(176,176,255),  
                textures = "Blocks:Wood",    
                ao = false
            }            
        end  
        
        model:rotateY(self:get("facing"))
    end
    
    function piston:placed(entity, normal, forward)
        self:set("facing", (craft.block.directionToFace(forward)+1)%4 )
    end
    
    function piston:destroyed()
        local on = self:get("on")   
        
        if on then
            local px,py,pz = self:pushPos()
            self.voxels:set(px, py, pz, 0)            
        end
    end
    
    function piston:pushPos()
        local facing = self:get("facing")
        local x,y,z = self:xyz()
        if facing == 0 then z = z + 1 end
        if facing == 1 then x = x - 1 end
        if facing == 2 then z = z - 1 end
        if facing == 3 then x = x + 1 end   
        return x,y,z                            
    end
    
    -- this function will push a line of blocks in tne direction of the piston up
    -- to a set maximum after which it will fail to push
    function piston:push()
        local x,y,z = self:xyz()
        local px,py,pz = self:pushPos()
        local dx, dy, dz = px-x, py-y, pz-z
     
        -- Check for empty air
        local mp = 0       
        for i = 1,self.class.maxPush do
            local sx,sy,sz = x + dx*i, y + dy*i, z + dz*i 
            local b = self.voxels:get(sx, sy, sz)  
            if b and b.name == "piston" and b:get("on") then
                return false
            elseif b and not b.class.canPush then
                return false
            elseif b and b.class.id == 0 then
                break
            end
            mp = mp + 1
        end
        
        if mp == 0 then return true end
        
        if self.voxels:get(px + dx*mp, py + dy*mp, pz + dz*mp, BLOCK_ID) == 0 then
            for i = mp,1,-1 do
                local sx,sy,sz = x + dx*i, y + dy*i, z + dz*i            
                moveBlock(sx,sy,sz,sx+dx,sy+dy,sz+dz)     
            end  
            return true                
        end
            
        return false   
    end
    
    function piston:interact()
        
        local on = self:get("on")
        
        local px,py,pz = self:pushPos()
        local facing = self:get("facing")
        if not on then                
            if self:push() then
                self.voxels:set(px, py, pz, "name", "Pusher", "facing", facing)
                self:set("on", true)
            end
        else
            self.voxels:set(px, py, pz, 0) 
            self:set("on", false)         
        end         
    end
     
    return piston
end

end
------------------------------
-- Chest.lua
------------------------------
do
-- A storage block
function chest(capacity)
    local chest = scene.voxels.blocks:new("Chest")
    chest.dynamic = true
    chest.geometry = TRANSPARENT

    function chest:created()
        e = self.entity
        self.base = scene:entity()
        self.base.parent = e
        self.base.position = vec3(0.5, 0.3, 0.5)
        local r = self.base:add(craft.renderer, craft.model.cube(vec3(0.8,0.6,0.8)))
        r.material = craft.material(asset.builtin.Materials.Specular)
        r.material.diffuse = color(133, 79, 30, 255)

        self.top = scene:entity()
        self.top.parent = e
        self.top.position = vec3(0.1, 0.6, 0.1)
        local r2 = self.top:add(craft.renderer, craft.model.cube(vec3(0.8,0.2,0.8), vec3(0.4,0.1,0.4)))
        r2.material = craft.material(asset.builtin.Materials.Specular)
        r2.material.diffuse = color(66, 47, 30, 255)
        self.angle = 0
    end

    function chest:update()
        self.top.rotation = quat.eulerAngles(0,  0, self.angle)
    end

    function chest:interact()
        if not self.open then
            self.open = true
            tween(0.6, self, {angle = 90}, tween.easing.backOut)
        else
            self.open = false
            tween(0.6, self, {angle = 0}, tween.easing.cubicIn)
        end
    end

    return chest
end

end
------------------------------
-- Sound.lua
------------------------------
do
function soundb()
    local soundb = scene.voxels.blocks:new("Sound")
    soundb.setTexture(ALL, "Blocks:Blank White")
    soundb.tinted = true
    soundb.scripted = true
    
    function soundb:created()
        -- Randomise colour based on location
        local x,y,z = self:xyz()
        math.randomseed(x * y * z)
        local c =color(math.random(128,255), math.random(128,255), math.random(128,255))
        self.voxels:set(x,y,z,"color", c)
    end
        
    -- Play a sound when interacted with
    function soundb:interact()
        local x,y,z = self:xyz()
        sound(SOUND_RANDOM, x * y * z)
    end 
    
    return soundb
end  
end
------------------------------
-- TNT.lua
------------------------------
do
-- A TNT block
function tnt()
    
    local tnt = scene.voxels.blocks:new("TNT")
    tnt.setTexture(ALL, "Blocks:Blank White")
    tnt.setColor(ALL, color(203, 57, 53, 255))
    tnt.scripted = true
    
    function tnt:interact()
        local x,y,z = self:xyz()
        self.voxels:fill(0)
        self.voxels:sphere(x,y,z,10)
        sound(SOUND_EXPLODE, 10526)
    end
    
    return tnt
end

end
------------------------------
-- Blocks.lua
------------------------------
do
-- Loads all blocks
function blocks()
    basicBlocks()
    signBlock()
    piston()
    stairsBlock("Wooden Stairs", "Blocks:Wood")    
    stairsBlock("Stone Stairs", "Blocks:Stone")
    fence("Wooden Fence", "Blocks:Wood") 
    fence("Stone Fence", "Blocks:Stone")       
    chest(40)
    soundb()
    treeGenerator()
    tnt()
        
    -- Get a list of all block types
    local allBlocks = scene.voxels.blocks:all()
    
    -- Generate preview icons for all blocks
    for k,v in pairs(allBlocks) do
        if v.hasIcon == true then
            v.static.icon = generateBlockPreview(v)
        end
    end
    
    return allBlocks
end

end
------------------------------
-- BlockPreview.lua
------------------------------
do
-- Uses the camera to generate previews of blocks before the scene starts
function generateBlockPreview(block)
    
    -- Try to read a cached version of the icon first
    local img = readImage("Project:"..block.name)
    
    if img then
        return img
    end
    
    local camera = scene.camera:get(craft.camera)
    local sky = scene.sky
    
    local ortho = camera.ortho
    local orthoSize = camera.orthoSize
    
    camera.ortho = true
    camera.orthoSize = 0.9
    camera.entity.rotation = quat.eulerAngles(35, 45, 0)
    camera.entity.position = vec3(0.5, 0.5, 0.5) - camera.entity.forward * 5
    camera.clearColorEnabled = false
    sky.active = false
    
    local volumeObj = scene:entity()
    local volume = volumeObj:add(craft.volume, 1, 1, 1)   

    if block.tinted then
        volume:set(0,0,0,"name", block.name, "color", color(255,255,255,255))        
    else
        volume:set(0,0,0,block.name)
    end

    img = image(48, 48)
    setContext(img, true)
    camera:draw()
    setContext()
    
    volumeObj:destroy() 
    
    camera.ortho = ortho
    camera.orthoSize = orthoSize
    camera.clearColorEnabled = true
    sky.active = true
    
    saveImage("Project:"..block.name, img)
    return img 
end

end
