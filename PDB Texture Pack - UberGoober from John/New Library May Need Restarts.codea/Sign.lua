-- The sign block
function signBlock()
    local sign = scene.voxels.blocks:new("Sign")
    sign.setTexture(ALL, packPrefix.."Wood")
    sign.scripted = true
    sign.geometry = TRANSPARENT
    
    sign.state:addFlag("wall", false)
    sign.state:addRange("facing", EAST, NORTH, EAST)
      
    function sign:placed(entity, normal, forward)
        local pos = vec3(self:xyz())
        local surface = self.voxels:get(pos - normal)
        if surface.class.geometry ~= SOLID then
            
        end        
        
        if normal.y == 0 then
            self:set("wall", true)
            self:set("facing", craft.block.directionToFace(normal) )
        else
            self:set("facing", craft.block.directionToFace(forward) )
        end

    end
    
    function sign:buildModel(model)   
        model:clear()
        
        if self:get("wall") then
            model:addElement
            {
                lower = vec3(235,50,10),
                upper = vec3(255,205,245),        
                ao = false
            } 
        else      
            model:addElement
            {
                lower = vec3(118+20,100,10),
                upper = vec3(138+20,255,245),        
                ao = false
            } 
            
            model:addElement
            {
                lower = vec3(118,0,118),
                upper = vec3(138,255,138),        
                ao = false
            } 
        end
        
        model:rotateY(self:get("facing"))
    end
    
    return sign
end
    
function stairsBlock(name, texture)
    local stairs = scene.voxels.blocks:new(name)
    stairs.setTexture(ALL, texture)
    stairs.geometry = TRANSPARENT
    stairs.scripted = true
    
    -- custom block state (max 32 bits worth of data)
    stairs.state:addFlag("corner", false)
    stairs.state:addRange("facing", EAST, NORTH, EAST)
    
    function stairs:placed(entity, normal, forward)
        self:set("facing", craft.block.directionToFace(forward) )
    end
    
    -- custom model from state
    function stairs:buildModel(model)
        
        model:clear()
        if self:get("corner") then
            model:addElement
            {
                lower = vec3(0,0,0),
                upper = vec3(255,128,255),
                collision = STEP,
                ao = false
            }
            model:addElement
            {
                lower = vec3(128,128,128),
                upper = vec3(255,255,255),
                collision = STEP,
                ao = false    
            }
        else
            model:addElement
            {
                lower = vec3(0,0,0),
                upper = vec3(128,128,255),
                collision = STEP,
                ao = false
            }
            model:addElement
            {
                lower = vec3(128,0,0),
                upper = vec3(255,255,255),
                collision = STEP,
                ao = false
            }
        end
        
        model:rotateY(self:get("facing")+2)
    end
    
    return stairs
end