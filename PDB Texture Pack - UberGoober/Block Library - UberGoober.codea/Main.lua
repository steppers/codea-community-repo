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

    packPrefix = "PDB Blocks:"
    
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
    local n = nearestTriangle(#allBlocks+6)
    local k = -11
    --I don't get what the the above numbers are but their original values don't show all the blocks, so I just messed with them until all the blocks did get shown.
    local pos = vec3(32,10,32) 
    local center = vec3(0,0,0)
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
    
    if not creditsDisplayed then
        print("Textures adapted from PureBDcraft ResourcePack by https://bdcraft.net")
        creditsDisplayed = true
    end
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
