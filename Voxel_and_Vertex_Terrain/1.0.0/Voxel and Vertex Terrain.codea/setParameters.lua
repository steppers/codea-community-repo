function setParameters()
    parameter.integer("settingsSet", 1, #presets, 1, function(value) 
        clear()       
        useSpecularMaterial = false
        generateFrom(presets[value])
        output.clear()
        printSpecs()  
    end)
    parameter.action("Spawn Player", function()
        if playerBody then
            playerBody:destroy()
            playerBody = nil
        end
        touches.removeHandler(viewer)
        scene.camera:remove(viewer)
        playerBody = joystickWalkerRig(scene:entity(), scene, asset.builtin.Blocky_Characters.Soldier) 
        playerBody.rig.isThirdPersonView = true
        
        playerBody.position = vec3(100, 150, 100)
    end)
    parameter.boolean("showVoxels", true)
    parameter.boolean("showModel", true)
    parameter.boolean("rotateVolumes", false, function(value)
        if value == false then
            for _, entity in ipairs(volumes.entities) do
                entity.eulerAngles = vec3(0,0,0) 
            end
        else
            showVoxels = true
        end
    end)
    parameter.boolean("useSpecularMaterial", false, function(value)
        if value == false then
            terrainEntity.material = craft.material(asset.builtin.Materials.Basic)
            waterEntity.material = craft.material(asset.builtin.Materials.Basic)
        else
            terrainEntity.material = craft.material(asset.builtin.Materials.Specular)
            waterEntity.material = craft.material(asset.builtin.Materials.Specular)
            showVoxels = false
            showModel = true
        end
    end)
end
