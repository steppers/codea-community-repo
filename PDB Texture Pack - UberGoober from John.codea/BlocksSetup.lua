-- A set of basic blocks (mainly cubes)
function blocksSetup()

    -- Assets must be added to the voxel system for them to be available
    --  scene.voxels.blocks:addAssetPack("Blocks")
 --   packPrefix = "Blocks:"
    scene.voxels.blocks:addAssetPack("NewBlocksPack")
    packPrefix = "NewBlocksPack:"

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
    scene.voxels.blocks.Solid.static.canPlace = false

end

--a block type that shows a verical sprite along the centers of the x and z axes of a block
function crossViewBlock(displayName, textureName)
    local newBlock = scene.voxels.blocks:new(displayName)
    newBlock.setTexture(ALL, textureName)  
    newBlock.scripted = true
    newBlock.geometry = TRANSLUCENT
    newBlock.renderPass = TRANSLUCENT
    newBlock.state:addRange("facing", 0,3,0)
    
    function newBlock:buildModel(model)
        model:clear()
        model:addElement
        {
            lower = vec3(0, 0, 127),
            upper = vec3(255, 255, 127), 
            ao = false
        }      
        
        model:addElement
        {
            lower = vec3(127, 0, 0),
            upper = vec3(127, 255, 255), 
            ao = false
        } 
        model:rotateY(self:get("facing"))
    end
    
end


function makeFlat(displayName, textureName)
    local newFlat = scene.voxels.blocks:new(displayName)
    newFlat.setTexture(ALL, textureName)  
    newFlat.scripted = true
    newFlat.geometry = TRANSPARENT   
    newFlat.state:addRange("facing", 0,3,0)   
    -- Custom appearance
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