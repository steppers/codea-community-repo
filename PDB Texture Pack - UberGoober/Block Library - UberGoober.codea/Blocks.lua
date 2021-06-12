-- Loads all blocks
function blocks()

    blocksSetup()
    cottonCarpets()
    uniformBlocks()
    toppedBlocks()
    specialBlocks()
    signBlock()
    piston()
    oven()
    stairsBlock("Wooden Stairs", packPrefix.."Wood")    
    stairsBlock("Stone Stairs", packPrefix.."Stone")    
    fence("Wooden Fence", packPrefix.."Wood") 
    fence("Stone Fence", packPrefix.."Stone")       
    chest(40)
    soundb()
    tnt()
    plants()
    treeGenerator()
      
    -- Get a list of all block types
    local allBlocks = scene.voxels.blocks:all()
    
    -- Generate preview icons for all blocks
    for k,v in pairs(allBlocks) do
        --if v.hasIcon == true then
            v.static.icon = generateBlockPreview(v)
      --  end
    end
    
    return allBlocks
end
