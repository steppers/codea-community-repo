function specialBlocks()
    
    makeTrack("Track Corner", packPrefix.."Track Corner")
    makeTrack("Track Straight", packPrefix.."Track Straight")
    
    local bedrock = scene.voxels.blocks:new("Bedrock")
    bedrock.setTexture(ALL, packPrefix.."Greystone")
    bedrock.static.canDig = false
    bedrock.static.canPlace = false
    --bedrock.tinted = true
    bedrock.setColor(ALL, color(128, 128, 128, 255))
    
    local water = scene.voxels.blocks:new("Water")
    water.setTexture(ALL, packPrefix.."Water")
    water.setColor(ALL, color(100,100,200,170))
    -- Translucent geometry prevents blocks from rendering internal faces between each other
    water.geometry = TRANSLUCENT
    -- Translucent renderPass is for semi-transparent blocks (i.e alpha less than 255 and greater than 0)
    water.renderPass = TRANSLUCENT
    
    local glass = scene.voxels.blocks:new("Glass")
    glass.setTexture(ALL, packPrefix.."Glass")
    glass.geometry = TRANSLUCENT
    glass.renderPass = TRANSLUCENT
    
    local glassFrame = scene.voxels.blocks:new("Glass Frame")
    glassFrame.setTexture(ALL, packPrefix.."Glass Frame")
    glassFrame.geometry = TRANSLUCENT
    glassFrame.renderPass = TRANSLUCENT
    
    local craftingTable = scene.voxels.blocks:new("Crafting Table")
    craftingTable.setTexture(ALL, packPrefix.."Table Side")
    craftingTable.setTexture(DOWN, packPrefix.."Table Bottom")
    craftingTable.setTexture(UP, packPrefix.."Table")
    
    crossViewBlock("Rock", packPrefix.."Rock")
    crossViewBlock("Mossy Rock", packPrefix.."Rock Moss")
    
end


function makeTrack(displayName, textureName)
    local newFlat = scene.voxels.blocks:new(displayName)
    newFlat.setTexture(ALL, textureName)  
    newFlat.scripted = true
    newFlat.geometry = TRANSLUCENT
    newFlat.renderPass = TRANSLUCENT
    newFlat.state:addRange("facing", 0,3,0)   

    function newFlat:buildModel(model)
        model:clear()
        model:addElement
        {
        lower = vec3(0, 0, 0), 
        upper = vec3(255, 5, 255), 
        textures = textureName,           
        ao = false
        }        
        model:rotateY(self:get("facing"))
    end
end