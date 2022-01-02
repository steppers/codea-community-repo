
-- Enums
MOUSELEFT = 1
MOUSERIGHT = 2
MOUSEMIDDLE = 3

-- Mouse callbacks
local mouseInput = objc.cls.GCMouse:current().mouseInput
mouseInput.mouseMovedHandler = function(objMouse, floatDeltaX, floatDeltaY)
    mousemove(floatDeltaX, floatDeltaY)
end

mouseInput.leftButton.pressedChangedHandler = function(objButton, floatValue, boolPressed)
    if boolPressed then
        mousedown(MOUSELEFT)
    else
        mouseup(MOUSELEFT)
    end
end

-- right mouse button is optional
if mouseInput.rightButton then
    mouseInput.rightButton.pressedChangedHandler = function(objButton, floatValue, boolPressed)
        if boolPressed then
            mousedown(MOUSERIGHT)
        else
            mouseup(MOUSERIGHT)
        end
    end
end
    
-- left mouse button is optional
if mouseInput.middleButton then
    mouseInput.middleButton.pressedChangedHandler = function(objButton, floatValue, boolPressed)
        if boolPressed then
            mousedown(MOUSEMIDDLE)
        else
            mouseup(MOUSEMIDDLE)
        end
    end
end

function ismousedown(bttn)
    local mi = nil
    if bttn == MOUSELEFT then
        mi = mouseInput.leftButton
    elseif bttn == MOUSECENTER then
        mi = mouseInput.centerButton
    elseif bttn == MOUSERIGHT then
        mi = mouseInput.rightButton
    end
    
    -- Return nil if the button isn't available
    if mi == nil then
        return nil
    end
    
    return (mi.value == 1.0)
end

-- Keyboard callbacks
local keyboardInput = objc.cls.GCKeyboard:coalescedKeyboard().keyboardInput
keyboardInput.keyChangedHandler = function(objKeyboard, objKey, intKeyCode, boolPressed)
    if boolPressed then
        keydown(intKeyCode)
    else
        keyup(intKeyCode)
    end
end

function iskeydown(key)
    local k = keyboardInput:buttonForKeyCode_(key)
    return (k and (k.value == 1.0)) or false
end


-- User callback definitions
function mousemove(dx, dy) end
function mousedown(bttn) end
function mouseup(bttn) end

function keydown(key) end
function keyup(key) end

