-- Gestures

local touches = {}
local panning = {}

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
        local delta = touch.pos - touches[touch.id].pos
        
        if touchMoved then touchMoved(touch.id, touch.pos) end
        
        if panning[touch.id] then
            if pan then pan(touch.pos, touch.delta, CHANGED) end
        elseif delta:lenSqr() > 20 then
            panning[touch.id] = true
            if pan then pan(touch.pos, touch.delta, BEGAN) end
        end
        
    elseif touch.state == CANCELLED or touch.state == ENDED then
        local duration = touch.timestamp - touches[touch.id].timestamp
        
        if touchUp then touchUp(touch.id, touch.pos) end
        
        if panning[touch.id] then
            if pan then pan(touch.pos, touch.delta, ENDED) end
        elseif duration < 0.3 then
            if tap then tap(touch.pos) end
        else
            if press then press(touch.pos) end
        end
        
        touches[touch.id] = nil
    end
end