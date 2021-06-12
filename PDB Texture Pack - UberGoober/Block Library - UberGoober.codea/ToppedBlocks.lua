
function toppedBlocks()

    local grassDirt = scene.voxels.blocks:new("Grass")
    grassDirt.setTexture(ALL, packPrefix.."Dirt Grass")
    grassDirt.setTexture(DOWN, packPrefix.."Dirt")
    grassDirt.setTexture(UP, packPrefix.."Grass Top")
    
    
    local sandDirt = scene.voxels.blocks:new("Sandy Dirt")
    sandDirt.setTexture(ALL, packPrefix.."Dirt Sand")
    sandDirt.setTexture(DOWN, packPrefix.."Dirt")
    sandDirt.setTexture(UP, packPrefix.."Sand")
    
    local snowDirt = scene.voxels.blocks:new("Snowy Dirt")
    snowDirt.setTexture(ALL, packPrefix.."Dirt Snow")
    snowDirt.setTexture(DOWN, packPrefix.."Dirt")
    snowDirt.setTexture(UP, packPrefix.."Snow")
    
    
    
    local grassStone = scene.voxels.blocks:new("Grassy Stone")
    grassStone.setTexture(ALL, packPrefix.."Stone Grass")
    grassStone.setTexture(DOWN, packPrefix.."Stone")
    grassStone.setTexture(UP, packPrefix.."Grass Top")
    
    
    local sandyStone = scene.voxels.blocks:new("Sandy Stone")
    sandyStone.setTexture(ALL, packPrefix.."Stone Sand")
    sandyStone.setTexture(DOWN, packPrefix.."Stone")
    sandyStone.setTexture(UP, packPrefix.."Sand")
    
    local snowStone = scene.voxels.blocks:new("Snowy Stone")
    snowStone.setTexture(ALL, packPrefix.."Stone Snow")
    snowStone.setTexture(DOWN, packPrefix.."Stone")
    snowStone.setTexture(UP, packPrefix.."Snow")
       
    local greysandyGreystone = scene.voxels.blocks:new("Greysandy Greystone")
    greysandyGreystone.setTexture(ALL, packPrefix.."Greystone Sand")
    greysandyGreystone.setTexture(DOWN, packPrefix.."Greystone")
    greysandyGreystone.setTexture(UP, packPrefix.."Greysand")
    
    local redsandyRedstone = scene.voxels.blocks:new("Redsandy Redstone")
    redsandyRedstone.setTexture(ALL, packPrefix.."Redstone Sand")
    redsandyRedstone.setTexture(DOWN, packPrefix.."Redstone")
    redsandyRedstone.setTexture(UP, packPrefix.."Redsand")
end