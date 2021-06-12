function plants()

    crossViewBlock("Thin Trunk Bottom", packPrefix.."Trunk Bottom")
    crossViewBlock("Thin Trunk Middle", packPrefix.."Trunk Mid")
    
    local wood = scene.voxels.blocks:new("Wood")
    wood.setTexture(ALL, packPrefix.."Trunk Side")
    wood.setTexture(DOWN, packPrefix.."Trunk Top")
    wood.setTexture(UP, packPrefix.."Trunk Top")
    
    local leaves = scene.voxels.blocks:new("Leaves")
    leaves.setTexture(ALL, packPrefix.."Leaves")
    leaves.geometry = TRANSPARENT
    leaves.scripted = true
        
    local birch = scene.voxels.blocks:new("Birch")
    birch.setTexture(ALL, packPrefix.."Trunk White Side")
    birch.setTexture(DOWN, packPrefix.."Trunk White Top")
    birch.setTexture(UP, packPrefix.."Trunk White Top")
    
    local orangeLeaves = scene.voxels.blocks:new("Orange Leaves")
    orangeLeaves.setTexture(ALL, packPrefix.."Leaves Orange")
    orangeLeaves.geometry = TRANSPARENT
    orangeLeaves.scripted = true
    
    local cactusTrunk = scene.voxels.blocks:new("Cactus Trunk")
    cactusTrunk.setTexture(ALL, packPrefix.."Cactus Side")  
    cactusTrunk.setTexture(UP, packPrefix.."Cactus Inside")  
    cactusTrunk.setTexture(DOWN, packPrefix.."Cactus Inside")  
    cactusTrunk.scripted = true
    cactusTrunk.geometry = TRANSPARENT   
    
    -- Custom appearance
    function cactusTrunk:buildModel(model)
        model:clear()
        model:addElement
        {
            lower = vec3(18, 0, 18),
            upper = vec3(237, 255, 237), 
            ao = false
        }
        
    end
    
    
    local cactusTop = scene.voxels.blocks:new("Cactus Top")
    cactusTop.setTexture(ALL, packPrefix.."Cactus Side")  
    cactusTop.setTexture(UP, packPrefix.."Cactus Top")  
    cactusTop.setTexture(DOWN, packPrefix.."Cactus Inside")  
    cactusTop.scripted = true
    cactusTop.geometry = TRANSPARENT   
    
    -- Custom appearance
    function cactusTop:buildModel(model)
        model:clear()
        model:addElement
        {
            lower = vec3(18, 0, 18),
            upper = vec3(237, 255, 237), 
            ao = false
        }
        
    end
    
    crossViewBlock("Brown Grass", packPrefix.."Grass Brown")
    crossViewBlock("Tan Grass", packPrefix.."Grass Tan")
    crossViewBlock("Small Grass Tuft", packPrefix.."Grass1")
    crossViewBlock("Bug Grass Tuft", packPrefix.."Grass2")
    crossViewBlock("Short Reedy Grass", packPrefix.."Grass3")
    crossViewBlock("Tall Reedy Grass", packPrefix.."Grass4")
    crossViewBlock("Brown Mushroom", packPrefix.."Mushroom Brown")
    crossViewBlock("Red Mushroom", packPrefix.."Mushroom Red")
    crossViewBlock("Tan Mushroom", packPrefix.."Mushroom Tan")
    crossViewBlock("Wheat Stage 1", packPrefix.."Wheat Stage1")
    crossViewBlock("Wheat Stage 2", packPrefix.."Wheat Stage2")
    crossViewBlock("Wheat Stage 3", packPrefix.."Wheat Stage3")
    crossViewBlock("Wheat Stage 4", packPrefix.."Wheat Stage4")
end


