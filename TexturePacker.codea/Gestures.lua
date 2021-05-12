-- Gestures

local touches = {}
local panning = {}

-- Gesture events
function pan(pos, delta, state)
    
end

function tap(pos)
    
end

function press(pos)
    
end

-- Raw Touch events
function touchDown(id, pos)
    
end

function touchMoved(id, pos)
    
end

function touchUp(id, pos)
    
end

-- Base Handler & detector
function touched(touch)
    if touch.state == BEGAN then
        panning[touch.id] = false
        touches[touch.id] = touch
        
        touchDown(touch.id, touch.pos)
        
    elseif touch.state == CHANGED then
        local delta = touch.pos - touches[touch.id].pos
        
        touchMoved(touch.id, touch.pos)
        
        if panning[touch.id] then
            pan(touch.pos, touch.delta, CHANGED)
        elseif delta:lenSqr() > 20 then
            panning[touch.id] = true
            pan(touch.pos, touch.delta, BEGAN)
        end
        
    elseif touch.state == CANCELLED or touch.state == ENDED then
        local duration = touch.timestamp - touches[touch.id].timestamp
        
        touchUp(touch.id, touch.pos)
        
        if panning[touch.id] then
            pan(touch.pos, touch.delta, ENDED)
        elseif duration < 0.3 then
            tap(touch.pos)
        else
            press(touch.pos)
        end
        
        touches[touch.id] = nil
    end
end