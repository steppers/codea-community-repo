-- Handles all input related stuff in OIL

local touches = {}

local press_duration = 0.4

local StateDown = 0
local StatePress = 1
local StateDrag = 2

local current_time = 0
        
-- Dispatchers
local last_handler = nil
local function dispatch_event(event)
    local handled = false
    
    -- Give the previous handler priority
    if last_handler then
        handled, last_handler = last_handler:handle_event(event)
    end
    
    -- If nothing has handled it so far then pass it to root
    if not handled and Oil.root then
        _, last_handler = Oil.root:handle_event(event)
    end
end


-- Our handlers
function Oil.hover(gesture)
    dispatch_event{
        type = "hover",
        pos = gesture.location
    }
end

-- Convert a scroll gesture into a drag gesture
function Oil.scroll(gesture)
    local pos = gesture.location - gesture.translation
    if gesture.state == BEGAN then
        -- Send raw event
        dispatch_event{
            type = "drag",
            pos = pos,
            delta = gesture.delta,
            state = BEGAN
        }
    elseif gesture.state == CHANGED then
        dispatch_event{
            type = "drag",
            pos = pos,
            delta = gesture.delta,
            state = CHANGED
        } 
    else
        dispatch_event{
            type = "drag",
            pos = pos,
            state = ENDED
        }
    end
end

function Oil.keyboard(key)
    dispatch_event{
        type = "key",
        key = key
    }
end

function Oil.touch(touch)
    -- Get current tracked touch
    local current = touches[touch.id]
    
    -- New touch?
    if touch.state == BEGAN then
        touches[touch.id] = {
            pos = touch.pos,
            time = touch.timestamp,
            state = StateDown
        }
        
        -- Send raw event
        dispatch_event{
            type = "touchdown",
            pos = touch.pos
        }
        
        -- Set the start time
        if current_time == 0 then
            current_time = touch.timestamp
        end
        
    elseif touch.state == CHANGED then
        if current.state ~= StateDrag and current.pos:distSqr(touch.pos) > 25 then
            current.state = StateDrag
            
            dispatch_event{
                type = "drag",
                pos = touch.pos,
                delta = touch.delta,
                state = BEGAN
            }
        end
        
        if current.state == StateDrag then
            dispatch_event{
                type = "drag",
                pos = touch.pos,
                delta = touch.delta,
                state = CHANGED
            }
        end
    else
        dispatch_event{
            type = "touchup",
            pos = touch.pos
        }
        
        -- Dispatch tap/click event?
        if current.state == StateDown and touch.timestamp - current.time < press_duration then
            dispatch_event{
                type = "tap",
                pos = touch.pos,
                is_click = (touch.type == POINTER)
            }
        elseif current.state == StateDrag then
            dispatch_event{
                type = "drag",
                pos = touch.pos,
                state = ENDED
            }
        end
        
        -- Stop tracking this touch
        touches[touch.id] = nil
    end
end

-- Called once per frame to detect long presses
-- without requiring the user to lift their finger
function update_touches()
    if current_time ~= 0 then
        current_time = current_time + DeltaTime
        for _,touch in pairs(touches) do
            if touch.state == StateDown and (current_time - touch.time > press_duration) then
                touch.state = StatePress
                
                dispatch_event{
                    type = "press",
                    pos = touch.pos
                }
            end
        end
    end
end
