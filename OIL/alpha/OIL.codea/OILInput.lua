-- OIL Input Handlers

-- Event types
OIL.ETTouchDown = 0
OIL.ETTouchUp = 1
OIL.ETTouchMoved = 2
OIL.ETTap = 3
OIL.ETPan = 4
OIL.ETPress = 5
OIL.ETScroll = 6
OIL.ETHover = 7
OIL.ETKey = 8

local function dispatch(event)
    OIL.handle_event(event)
end

-- Gestures

local touches = {}
local panning = {}
local velocities = {}

-- Gesture events
local function pan(touch, vel, state)
    dispatch({
        id = touch.id,
        pos = touch.pos,
        delta = touch.delta,
        vel = vel,
        time = touch.timestamp,
        type = OIL.ETPan,
        state = state
    })
end

local function tap(touch)
    dispatch({
        pos = touch.pos,
        time = touch.timestamp,
        type = OIL.ETTap
    })
end

local function press(touch)
    dispatch({
        id = touch.id,
        pos = touch.pos,
        time = touch.timestamp,
        type = OIL.ETPress
    })
end

-- Raw Touch events
local function touchDown(touch)
    dispatch({
        id = touch.id,
        pos = touch.pos,
        time = touch.timestamp,
        type = OIL.ETTouchDown
    })
end

local function touchMoved(touch)
    dispatch({
        id = touch.id,
        pos = touch.pos,
        delta = touch.delta,
        time = touch.timestamp,
        type = OIL.ETTouchMoved
    })
end

local function touchUp(touch)
    dispatch({
        id = touch.id,
        pos = touch.pos,
        delta = touch.delta,
        time = touch.timestamp,
        type = OIL.ETTouchUp
    })
end

-- Base Handler & detector
function OIL.touched(touch)
    if touch.state == BEGAN then
        panning[touch.id] = false
        touches[touch.id] = touch
        
        if touchDown then touchDown(touch) end
        
    elseif touch.state == CHANGED then
        local delta_time = touch.timestamp - touches[touch.id].timestamp
        
        velocities[touch.id] = {
            x = touch.delta.x / delta_time,
            y = touch.delta.y / delta_time
        }
        
        -- New touch
        touches[touch.id] = touch
        
        if touchMoved then touchMoved(touch) end
        
        if panning[touch.id] then
            if pan then pan(touch, velocities[touch.id], CHANGED) end
        elseif touch.delta:lenSqr() > 20 then
            panning[touch.id] = true
            if pan then pan(touch, velocities[touch.id], BEGAN) end
        end
        
    elseif touch.state == CANCELLED or touch.state == ENDED then
        local delta_time = touch.timestamp - touches[touch.id].timestamp
        
        if touchUp then touchUp(touch) end
        
        if panning[touch.id] then
            if pan then pan(touch, velocities[touch.id], ENDED) end
        elseif delta_time < 0.3 then
            if tap then tap(touch) end
        else
            if press then press(touch) end
        end
        
        touches[touch.id] = nil
    end
end

function OIL.hover(gesture)
    dispatch({
        pos = gesture.location,
        type = OIL.ETHover
    })
end

function OIL.scroll(gesture)
    dispatch({
        pos = gesture.location - gesture.translation,
        delta = gesture.delta,
        type = OIL.ETScroll,
        state = gesture.state
    })
end

function OIL.pinch(gesture)
    
end

function OIL.keyboard(key)
    dispatch{
        type = OIL.ETKey,
        key = key
    }
end
