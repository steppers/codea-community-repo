
function oven()


    local oven = scene.voxels.blocks:new("Oven")  
    oven.setTexture(ALL, packPrefix.."Oven Side")
    oven.setTexture(DOWN, packPrefix.."Oven Top")
    oven.setTexture(UP, packPrefix.."Oven Top")
    oven.geometry = TRANSPARENT
    oven.scripted = true    
    oven.state:addRange("facing", 0,3,0)
    oven.static.maxPush = 5
    oven.static.hasIcon = true
    
    function oven:buildModel(model)
        model:clear()
        model:addElement
        {
            lower = vec3(0,0,5),
            upper = vec3(255,255,255),        
            ao = false
        } 
        

            model:addElement
            {
                lower = vec3(0,0,0),
                upper = vec3(255,255,5), 
                textures = packPrefix.."Oven",           
                ao = false
            }             
        
        model:rotateY(self:get("facing"))
    end
    
    function oven:placed(entity, normal, forward)
        self:set("facing", (craft.block.directionToFace(forward)+1)%4 )
    end
    
    return oven
end
