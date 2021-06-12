function fence(name, texture)
    local fence = scene.voxels.blocks:new(name)
    fence.setTexture(ALL, texture)
    fence.scripted = true
    fence.geometry = TRANSPARENT
    
    fence.state:addFlag("n", false)
    fence.state:addFlag("e", false)   
    fence.state:addFlag("s", false)   
    fence.state:addFlag("w", false) 
    
    function fence:triggerUpdate()
        self:schedule(0)
        local x,y,z = self:xyz()
        self.voxels:updateBlock(x,y,z-1,0)
        self.voxels:updateBlock(x,y,z+1,0)
        self.voxels:updateBlock(x-1,y,z,0)
        self.voxels:updateBlock(x+1,y,z,0)        
    end
    
    function fence:created()
        self:triggerUpdate()
    end
    
    function fence:destroyed()
        self:triggerUpdate()
    end
    
    function fence:blockUpdate()  
        local x,y,z = self:xyz()
        self:set("n", self.voxels:get(x,y,z-1,BLOCK_ID) ~= 0)
        self:set("s", self.voxels:get(x,y,z+1,BLOCK_ID) ~= 0)
        self:set("w", self.voxels:get(x+1,y,z,BLOCK_ID) ~= 0)
        self:set("e", self.voxels:get(x-1,y,z,BLOCK_ID) ~= 0)
    end
    
    function fence:addSlats(model, var, x1, x2, z1, z2)
        if self:get(var) then
            model:addElement
            {
                lower = vec3(x1,180,z1),
                upper = vec3(x2,230,z2)
            }
            
            model:addElement
            {
                lower = vec3(x1,180-90,z1),
                upper = vec3(x2,230-90,z2)
            }
        end        
    end
    
    function fence:buildModel(model)
        model:clear()
        
        model:addElement
        {
            lower = vec3(98,0,98),
            upper = vec3(158,255,158)
        }
        
        --local n = self.get("n")
        self:addSlats(model, "n", 114, 142, 0, 98)
        self:addSlats(model, "s", 114, 142, 158, 255)        
        self:addSlats(model, "e", 0, 98, 114, 142)
        self:addSlats(model, "w", 158, 255, 114, 142)        
    end
        
    return fence
end
