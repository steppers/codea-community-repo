-- Basic Player

viewer.mode = FULLSCREEN

function setup()
    scene = craft.scene()
    scene.voxels.blocks:addAssetPack("NewBlocksPack")
    -- Setup camera and lighting
    scene.sun.rotation = quat.eulerAngles(25, 125, 0)
    
    -- Set the scenes ambient lighting
    scene.ambientColor = color(127, 127, 127, 255)   
    
    allBlocks = blocks()    
    
    -- Setup voxel terrain
    scene.voxels:resize(vec3(5,1,5))      
    scene.voxels.coordinates = vec3(0,0,0)
    
    -- Create ground out of grass
    scene.voxels:fill("Redstone")
    scene.voxels:box(0,10,0,16*5,10,16*5)
    scene.voxels:fill("Dirt")
    scene.voxels:box(0,0,0,16*5,9,16*5)
    
    player = scene:entity():add(BasicPlayer, scene.camera:get(craft.camera), 40, 20, 40)

    allBlocks = scene.voxels.blocks:all()

    if not creditsDisplayed then
        print("Textures adapted from PureBDcraft ResourcePack by https://bdcraft.net")
        creditsDisplayed = true
    end
end

function update(dt)
    scene:update(dt)
end

function draw()
    update(DeltaTime)
    
    scene:draw()
    player:draw()
end

