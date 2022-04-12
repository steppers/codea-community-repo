function defineVoxelBlocks()
    
    if not dirtgrass then        
        scene.voxels.blocks:addAssetPack("Blocks")
        
        dirtgrass = scene.voxels.blocks:new("DirtGrass")
        dirtgrass.setTexture(ALL, "Blocks:Dirt Grass")
        dirtgrass.geometry = SOLID
        
        water = scene.voxels.blocks:new("Water")
        water.setTexture(ALL, "Blocks:Water")
        water.geometry = TRANSLUCENT
        
        snow = scene.voxels.blocks:new("Snow")
        snow.setTexture(ALL, "Blocks:Snow")
        snow.geometry = SOLID
        
        grass = scene.voxels.blocks:new("Grass Top")
        grass.setTexture(ALL, "Blocks:Grass Top")
        grass.geometry = SOLID
    end
end

function setVoxels(x, y, z, waterLevel)            
    voxelPositions[#voxelPositions + 1] = vec3(x, y, z)
    placeCorrectVoxel(x, y, z)   
    if y < waterLevel then
        voxelPositions[#voxelPositions + 1] = vec3(x, waterLevel, z) 
    end 
end

function placeCorrectVoxel(x, y, z)
    if y>=dirtLevel then
        placeInCorrectVolume(x, y, z, "Snow")
    elseif y>=grassLevel then
        placeInCorrectVolume(x, y, z, "DirtGrass")
    elseif y>=waterLevel then
        placeInCorrectVolume(x, y, z, "Grass Top")
    else
        placeInCorrectVolume(x, y, z, "DirtGrass")
        placeInCorrectVolume(x, waterLevel, z, "Water", volumes)
    end
end

function makeVolumes() 
    if volumes then return end
    local ent1, vol1 = volumeOfSizeAndPosition(256, 128, 256)
    local ent2, vol2 = volumeOfSizeAndPosition(144, 128, 256, vec3(256, 0, 0))
    local ent3, vol3 = volumeOfSizeAndPosition(256, 128, 144, vec3(0, 0, 256))
    local ent4, vol4 = volumeOfSizeAndPosition(144, 128, 144, vec3(256, 0, 256))
    volumes = {vol1, vol2, vol3, vol4}
    volumes.entities = {ent1, ent2, ent3, ent4}
end

function volumeOfSizeAndPosition(xSize, ySize, zSize, position)
    local newEntity = scene:entity()
    newEntity.position = position or newEntity.position
    newVolume = newEntity:add(craft.volume)
    newVolume:resize(xSize, ySize, zSize)
    return newEntity, newVolume
end

function placeInCorrectVolume(x, y, z, blockName)
    if not volumes then return end
    if x <= 255 then
        correctVolume = volumes[1]
        if z > 255 then
            correctVolume = volumes[3]
            z = z - 256
        end
    else
        x = x - 256
        if z <= 255 then
            correctVolume = volumes[2]
        else
            correctVolume = volumes[4]
            z = z - 256
        end
    end
    correctVolume:set(x, y, z, blockName)
end

function clearVolumes()
    if not voxelPositions then return end
    for _, pointy in ipairs(voxelPositions) do
        placeInCorrectVolume(pointy.x, pointy.y, pointy.z, 'empty')
    end
end

function spinVolumesBy(amount, volumeEntities)
    
    vol1Angles = volumeEntities[1].eulerAngles
    vol2Angles = volumeEntities[2].eulerAngles
    vol3Angles = volumeEntities[3].eulerAngles
    vol4Angles = volumeEntities[4].eulerAngles
    
    volumeEntities[1].rotation = quat.eulerAngles(vol1Angles.x - amount, vol1Angles.y, vol1Angles.z)
    volumeEntities[2].rotation = quat.eulerAngles(vol2Angles.x, vol2Angles.y, vol2Angles.z + amount)
    volumeEntities[3].rotation = quat.eulerAngles(vol3Angles.x - amount / 1.3, vol3Angles.y, vol3Angles.z)
    volumeEntities[4].rotation = quat.eulerAngles(vol4Angles.x, vol4Angles.y, vol4Angles.z + amount * 1.3)
end
