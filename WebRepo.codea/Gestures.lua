-- Gestures

local touches = {}
local panning = {}
local velocities = {}

-- Gesture events
-- function pan(pos, delta, state)
-- function tap(pos)
-- function press(pos)

-- Raw Touch events
-- touchDown(id, pos)
-- touchMoved(id, pos)
-- touchUp(id, pos)

-- Base Handler & detector
function touched(touch)
    if touch.state == BEGAN then
        panning[touch.id] = false
        touches[touch.id] = touch
        
        if touchDown then touchDown(touch.id, touch.pos) end
        
    elseif touch.state == CHANGED then
        local delta_time = touch.timestamp - touches[touch.id].timestamp
        
        velocities[touch.id] = {
            x = touch.delta.x / delta_time,
            y = touch.delta.y / delta_time
        }
        
        -- New touch
        touches[touch.id] = touch
        
        if touchMoved then touchMoved(touch.id, touch.pos) end
        
        if panning[touch.id] then
            if pan then pan(touch.pos, touch.delta, velocities[touch.id], CHANGED) end
        elseif touch.delta:lenSqr() > 20 then
            panning[touch.id] = true
            if pan then pan(touch.pos, touch.delta, velocities[touch.id], BEGAN) end
        end
        
    elseif touch.state == CANCELLED or touch.state == ENDED then
        local delta_time = touch.timestamp - touches[touch.id].timestamp
        
        if touchUp then touchUp(touch.id, touch.pos) end
        
        if panning[touch.id] then
            if pan then pan(touch.pos, touch.delta, velocities[touch.id], ENDED) end
        elseif delta_time < 0.3 then
            if tap then tap(touch.pos) end
        else
            if press then press(touch.pos) end
        end
        
        touches[touch.id] = nil
    end
end