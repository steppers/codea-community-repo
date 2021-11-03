--explodeyCraft: dave1707's explosion code made into a self-contained function and enhanced with un-exploding by UberGoober
    
function explodeyCraft(entity, shardColor)
    local entityHolder = scene:entity()
    entityHolder.position = entity.position
    entityHolder.rotation = entity.rotation 
    entityHolder.scale = entity.scale
    entity.shards = {}
    local ind=entity.model.indices
    local pos=entity.model.positions
    for z=1, entity.model.indexCount, 3 do
        local triangle = scene:entity()
        local p1=pos[ind[z] ]
        local p2=pos[ind[z+1] ]
        local p3=pos[ind[z+2] ]
        local avg=(p1+p2+p3)/3    
        local posAvg={p1-avg,p2-avg,p3-avg}
        triangle.origin = avg
        triangle.position=avg
        triangle.model = craft.model()
        triangle.model.positions=posAvg
        triangle.model.indices={1,2,3,3,2,1}
        triangle.model.colors={color(255),color(255),color(255)}
        triangle.material = craft.material(asset.builtin.Materials.Basic)  
        triangle.material.diffuse=shardColor
        triangle.rot=vec3(math.random(360),math.random(360),math.random(360))
        triangle.vel=avg*math.random(5,29)*.05
        triangle.parent = entityHolder
        triangle.active = false
        table.insert(entity.shards,triangle)
    end
    entity.explodeOneFrame = function(increment)
        local vMultiplier = increment or 1
        entity.active = false
        for a,b in pairs(entity.shards) do
            if not b.active then
                b.active = true
            end
        end        
        for a,b in pairs(entity.shards) do
            b.rot=b.rot+vec3(math.random(),math.random(),math.random()) * 3
            b.rotation=quat.eulerAngles(b.rot.x,b.rot.y,b.rot.z)
            b.position=b.position + (b.vel * vMultiplier)
        end
    end
    entity.unexplodeOneFrame = function(increment)
        if entity.active then return end
        local vMultiplier = increment or 1
        local tallyHome = 0
        for i,b in ipairs(entity.shards) do  
            b.rot=b.rot-vec3(math.random(),math.random(),math.random()) * 3
            b.rotation=quat.eulerAngles(b.rot.x,b.rot.y,b.rot.z)            
            b.position=b.position-(b.vel * vMultiplier)
            local originDistance = b.origin:dist(b.position)
            local incrementDistance = vec3(0):dist(b.vel * vMultiplier)
            if originDistance < incrementDistance / 2 then
                tallyHome = tallyHome + 1
            end
            if tallyHome > #entity.shards * 0.99 then
                for ii,bb in ipairs(entity.shards) do  
                    bb.position = bb.origin
                    bb.active = false
                end               
                entity.active = true
                return
            else
                b.active = true
            end           
        end
    end
    return entity 
end