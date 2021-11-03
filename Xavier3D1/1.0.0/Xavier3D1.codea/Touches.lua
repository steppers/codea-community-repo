-- Touch Handling --
------------------------------------------------------
    
function touched(touch)
    local state = touch.state
    local touches = touches
    
    -- Get number of touches
    if state == BEGAN then
        nbTouches = nbTouches + 1 
    end
    
    if state == ENDED then
        nbTouches = nbTouches - 1
        touches[touch.id] = nil
    else
        touches[touch.id] = touch
    end
    
    local delta = delta
    
    -- need to save delta before looping through vertices, 
    -- else laggy on high quality model
    local deltaX = touch.deltaX
    local deltaY = touch.deltaY
    dx = dx + deltaX
    dy = dy + deltaY
    
    -- Handle pinch to zoom
    if nbTouches == 2 then
        local newPt = {}
        local lastPt = {}
        local ins = table.insert 
        for k, p in pairs(touches) do
            local px = p.x
            local py = p.y
            ins(newPt, vec2(px, py))
            if state == BEGAN then
                ins(lastPt, vec2(px, py))
            else
                ins(lastPt, vec2(px - p.deltaX, py - p.deltaY))
            end
        end
        
        delta = lastPt[1]:dist(lastPt[2]) - newPt[1]:dist(newPt[2])
        currentZ = currentZ + delta
        if currentZ<1 then
            currentZ = 1
            delta = 0
        end
        
    end
    
    -- change light vector and reduce texture quality for smoother animation
    if moveLight == 1 then
        if state == BEGAN then
            textureQ = 64
        end
        lx = ((WIDTH*.5 - touch.x)/WIDTH)*.5
        lz = (-(HEIGHT*.5 - touch.y)/HEIGHT)*.5
        if state == ENDED then
            textureQ = defaultTextureQuality*64
            moveLight = 0
        end
    else
        
        -- this would normally be processed in a vertex shader, but this is software
        -- i didn't find any other way
        local vs = mdl.vertices
        
        for i=1, #vs do
            local v = vs[i]
            local vx = v.x
            local vz = v.z
            
            -- restore the shape of the model (turn it from pseudo-sphere to simple heightmap)
            if sphere == 1 then
                v.y = v.y - (vx * vx + vz * vz)*0.001
            end
            
            -- due to the way the trick works, translating the vertices rotates the "planet"
            v.x = vx + deltaX
            v.z = vz + deltaY
            v.y = v.y + delta
            
            -- once the translation work is done, turn it back into a pseudo-sphere
            if sphere == 1 then
                vx = v.x
                vz = v.z
                v.y = v.y + (vx * vx + vz * vz)*0.001
            end
            
            v.done = false
        end 
    end
end
    