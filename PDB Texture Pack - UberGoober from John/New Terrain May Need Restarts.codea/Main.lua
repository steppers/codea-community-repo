-----------------------------------------
-- Voxel Terrain
-- Written by John Millard
-----------------------------------------
-- Description:
-- This example provides a template for making streaming voxel terrain style games.
-- The generation tab contains code for creating voxel landscapes with support for 
-- rivers, caves, trees, minerals and varying hills.
--
-- This project depends on several other projects for addition code including:
--   * Block Library - A library of built-in block types
--   * Voxel Player - A basic player for use with voxel games (movement, jumping, digging etc...)
--   * UI - Used for the user interface (buttons, hotbar, inventory)
--   * Cameras - Used for first person camera support
--   * Touches - Used to handle touch input
-----------------------------------------

function setup()    
    printExplanation()

    scene = craft.scene()
    
    -- Load standard blocks (from the Block Library project dependency)
    blocks()

    -- Load the cave generator block (for underground winding caves)
    caveGenerator()

    -- Load the deposit generator block (for underground minerals)
    depositGenerator()  
    
    -- Get a list of all loaded blocks
    allBlocks = scene.voxels.blocks:all()
  
    -- Define the sky colors and setup the sun and ambient lighting conditions
    skyColor = color(0, 134, 255, 255)
    horizonColor = color(157, 191, 223, 255)    
    
    scene.ambientColor = color(96, 96, 96, 255)
    scene.sun:get(craft.light).intensity = 0.6
    scene.sun.rotation = quat.eulerAngles(25, 125, 0)
    scene.fogEnabled = false
    scene.sky.active = false
    
    cameraSettings = scene.camera:get(craft.camera)
    
    camera = scene.camera
    
    params = {}
    
    -- Spawn a player to explore the terrain
    parameter.action("Spawn Player", function()
        -- Make the display fullscreen for first person mode
        viewer.mode = FULLSCREEN
        
        if viewer == nil then return end
        
        -- Use the current camera position as the target location to spawn the player
        local pos = vec3( viewer.target:unpack() )
        pos.y = 128
        
        -- Disable the initial viewer so it doesn't fight with the player one
        touches.removeHandler(viewer)
        scene.camera:remove(viewer)
        viewer = nil
    
        -- Get surface position using a raycast
        scene.voxels:raycast(pos, vec3(0,-1,0), 128, function(coord, id, face)
            if id and id ~= 0 then
                pos.y = coord.y + 2
                return true
            end
        end)
                
        -- Create a basic player 
        player = scene:entity():add(BasicPlayer, scene.camera:get(craft.camera), pos:unpack())

        -- Re-enable fog
        scene.fogEnabled = true

    end)

    -- Generation parameter controls
    parameter.integer("Seed", 0, 1000000, readLocalData("seed"))
    
    -- Should we generate rivers?
    parameter.boolean("Rivers", readLocalData("rivers"))
    
    -- How wobly should rivers be?
    parameter.number("RiverTurbulence", 0, 5, readLocalData("riverTurbulence") or 0.5)
    
    -- How much chance is there for a cave in each chunk?
    parameter.number("CaveChance", 0, 1, readLocalData("caveChance") or 0.1)
    
    -- The minimum number of mineral deposits in a given chunk
    parameter.integer("MinDeposits", 0, 20, readLocalData("minDeposits") or 2)
    
    -- The maximum number of mineral deposits in a given chunk
    parameter.integer("MaxDeposits", 0, 20, readLocalData("maxDeposits") or 3)
    
    -- Button to reset the example and regenerate the terrain
    parameter.action("Restart", function()
        -- Remove old save
        scene.voxels:deleteStorage("Save01")
        saveLocalData("seed", Seed)
        saveLocalData("rivers", Rivers)
        saveLocalData("caveChance", CaveChance)
        saveLocalData("riverTurbulence", RiverTurbulence)
        saveLocalData("minDeposits", MinDeposits)        
        saveLocalData("maxDeposits", MaxDeposits)                
        viewer.restart()
    end)

    parameter.watch("scene.voxels.visibleChunks")
    parameter.watch("scene.voxels.generatingChunks")
    parameter.watch("scene.voxels.meshingChunks")
    parameter.watch("scene.renderBatchCount")
    parameter.watch("scene.renderBatchCullCount")
       
    skyMaterial = scene.sky.material

    -- Uncomment to setup disk based streaming (Experimental!)
    -- scene.voxels:enableStorage("Save01")
    
    sizeX = 100
    sizeZ = 100
    
    -- Set the size of the terrain in chunks
    scene.voxels:resize(vec3(sizeX,1,sizeZ))
    
    -- Set the maximum visible distance for voxels
    scene.voxels.visibleRadius = 10
    
    -- Set the fog to be roughly the same as the visibleRadius to hide chunk streaming
    scene.fogNear = (scene.voxels.visibleRadius-1.25)*16
    scene.fogFar = (scene.voxels.visibleRadius-0.5)*16
    scene.fogColor = skyColor
    
    -- Use the OrbitViewer for observing terrain generation
    viewer = scene.camera:add(OrbitViewer, vec3(16*sizeX/2,40,16*sizeZ/2), 100, 50, 400)
    viewer.rx = 45
    viewer.ry = 45
    
    generate()
    
    -- Create a cloud for fun :D
    createCloud(viewer.target.x, 140, viewer.target.z)
    
    if not creditsDisplayed then
        print("Textures adapted from PureBDcraft ResourcePack by https://bdcraft.net")
        creditsDisplayed = true
    end
end

function generate()
    -- Generate the terrain using the code in the 'Generation' tab
    
    -- Pack parameters for generation as a json string to transfer
    -- This has to be done since generation occurs on a separate thread so we cant use globals
    params.seed = Seed
    params.rivers = Rivers
    params.caveChance = CaveChance
    params.riverTurbulence = RiverTurbulence
    params.minDeposits = MinDeposits
    params.maxDeposits = MaxDeposits
    
    local paramsCode = "\nparams = json.decode([["..json.encode(params).."]])"
    
    scene.voxels:generate(readProjectTab("Generation")..paramsCode, "generateTerrain")   
end

function update(dt)
    scene:update(dt)

    -- Update the voxel coordinates using the player or viewer
    -- The voxel system will automatically generate, load and unload voxels around this area based on visibleRadius
    if player then
        scene.voxels.coordinates = player.entity.position
    elseif viewer then
        scene.voxels.coordinates = viewer.target
    end
end

-- This function gets called once every frame
function draw()
    update(DeltaTime)

    scene:draw()

    if player then 
        -- Draw player UI
        player:draw() 
        
        -- Adjust sky colors based on player camera
        local fogInterp = 1 - (player.viewer.rx + 90) / 180
        local fogColor = horizonColor:mix(skyColor, fogInterp)
        scene.fogColor = fogColor
        cameraSettings.clearColor = fogColor
    end   
end

function printExplanation()
    print("Voxel Terrain Example")
    print("Swipe with one finger to rotate.")
    print("Pan and pinch with two fingers to move the camera and zoom in/out")
    print("Spawn a player to explore the world first hand!")
end

-- Experimental voxel cloud
function createCloud(x,y,z)
    local c = scene:entity()
    c.position = vec3(x,y,z)
    local v = c:add(craft.volume, 25, 25, 25)
    local cx, cy, cz = v:size()

    
    local white = color(255, 255, 255, 255)
    local f = 0.07
    local power = 4
    local wx = craft.noise.perlin()
    wx.seed = x
    wx.frequency = f
    local wy = craft.noise.perlin()
    wy.seed = y
    wy.frequency = f 
    local wz = craft.noise.perlin()
    wz.seed = z
    wz.frequency = f 
    
    local r = 9
    local r2 = r*r
    
    for i = 0, cx-1 do
        for j = 0, cy-1 do
            for k = 0, cz-1 do
                local ox, oy, oz = wx:getValue(i,j,k), wy:getValue(i,j,k), wz:getValue(i,j,k)
                local dx, dy, dz = cx/2 - (i + ox * power), cy/2 - (j + oy * power), cz/2 - (k + oz * power)
                local d = dx*dx + dy*dy + dz*dz
                if d < r2 then
                    v:set(i,j,k, BLOCK_ID, 1, COLOR, white)  
                end
            end
        end        
    end
    
    c.scale = vec3(1,0.5,1)
        
    return c
end
