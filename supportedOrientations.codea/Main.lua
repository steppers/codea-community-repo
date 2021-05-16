-- supportedOrientations
--
-- Implementation of the old supportedImplementations function
--
-- Usage:
--      Call supportedOrientations(lock) with the desired orientation
--      lock. Choose from the following:
--          PORTRAIT_ANY
--          LANDSCAPE_ANY
--          PORTRAIT
--          PORTRAIT_UPSIDE_DOWN
--          LANDSCAPE_LEFT
--          LANDSCAPE_RIGHT

-- Save original Codea values
local setContext_codea = setContext
local perspective_codea = perspective
local ortho_codea = ortho
local layout_codea = layout
local viewer_codea = viewer
local sprite_codea = sprite

local WIDTH_codea = WIDTH
local HEIGHT_codea = HEIGHT

local CurrentTouch_codea = CurrentTouch

-- Maps supported orientations and current orientation to the
-- rotation to apply
local orientation_rot_map = {
    [PORTRAIT_ANY] = {
        [LANDSCAPE_LEFT] = 90,
        [LANDSCAPE_RIGHT] = 90,
        [PORTRAIT] = 0,
        [PORTRAIT_UPSIDE_DOWN] = 0
    },
    [PORTRAIT] = {
        [LANDSCAPE_LEFT] = -90,
        [LANDSCAPE_RIGHT] = 90,
        [PORTRAIT] = 0,
        [PORTRAIT_UPSIDE_DOWN] = 180
    },
    [PORTRAIT_UPSIDE_DOWN] = {
        [LANDSCAPE_LEFT] = 90,
        [LANDSCAPE_RIGHT] = -90,
        [PORTRAIT] = 180,
        [PORTRAIT_UPSIDE_DOWN] = 0
    },
    [LANDSCAPE_ANY] = {
        [LANDSCAPE_LEFT] = 0,
        [LANDSCAPE_RIGHT] = 0,
        [PORTRAIT] = 90,
        [PORTRAIT_UPSIDE_DOWN] = 90
    },
    [LANDSCAPE_RIGHT] = {
        [LANDSCAPE_LEFT] = 180,
        [LANDSCAPE_RIGHT] = 0,
        [PORTRAIT] = -90,
        [PORTRAIT_UPSIDE_DOWN] = 90
    },
    [LANDSCAPE_LEFT] = {
        [LANDSCAPE_LEFT] = 0,
        [LANDSCAPE_RIGHT] = 180,
        [PORTRAIT] = 90,
        [PORTRAIT_UPSIDE_DOWN] = -90
    },
}

-- Internal state
local orientation = nil
local orientation_rot = 0
local orientation_width = 0
local orientation_height = 0
local orientation_fb = nil

-- Translate a position into framebuffer space
local function toFB(pos)
    pos = pos - vec2(WIDTH_codea/2, HEIGHT_codea/2)
    pos = pos:rotate(math.rad(-orientation_rot))
    pos = pos + vec2(orientation_width/2, orientation_height/2)
    return pos
end

-- Initialise orientation lock variables
local function initOrientationLock()
    
    -- If no lock is set, ignore it
    if orientation == nil then
        orientation_fb = nil
        return
    end
    
    local is_portrait = (CurrentOrientation == PORTRAIT) or (CurrentOrientation == PORTRAIT_UPSIDE_DOWN)
    
    -- Determine the target orientation's resolution
    if orientation == PORTRAIT_ANY or orientation == PORTRAIT or orientation == PORTRAIT_UPSIDE_DOWN then
        if is_portrait then
            orientation_height = HEIGHT_codea
            orientation_width = WIDTH_codea
        else
            orientation_height = WIDTH_codea
            orientation_width = HEIGHT_codea
        end
    elseif orientation == LANDSCAPE_ANY or orientation == LANDSCAPE_LEFT or orientation == LANDSCAPE_RIGHT then
        if is_portrait then
            orientation_height = WIDTH_codea
            orientation_width = HEIGHT_codea
        else
            orientation_height = HEIGHT_codea
            orientation_width = WIDTH_codea
        end
    end
    
    -- Get the intended rotation
    orientation_rot = orientation_rot_map[orientation][CurrentOrientation]
    
    -- Create a new orientation framebuffer
    orientation_fb = image(orientation_width, orientation_height)
end

-- Update orientation lock variables
local function updateOrientationLock()
    
    -- If no lock is set return immediately
    if orientation == nil then
        return
    end
    
    -- Get the intended rotation
    orientation_rot = orientation_rot_map[orientation][CurrentOrientation]
end

-- Our implementation
function supportedOrientations(orientations)
    
    -- Initialise the orientation lock
    orientation = orientations
    initOrientationLock()
    
    -- Override the WIDTH & HEIGHT values
    WIDTH = orientation_width
    HEIGHT = orientation_height
    
    -- Overridden CurrentTouch object to apply orientation
    -- transforms
    CurrentTouch = setmetatable({}, {
        __index = function(t, k)
            local v = CurrentTouch_codea[k]
            
            -- No transformation needed
            if orientation == nil or orientation == CurrentOrientation then
                return v
            end
            
            if k == "x" then
                return toFB(v.pos).x
                
            elseif k == "y" then
                return toFB(v.pos).y
                
            elseif k == "pos" or k == "prevPos" or k == "precisePos" or k == "precisePrevPos" then
                return toFB(v)
                
                -- I don't have a stylus to check this behaviour
                -- elseif k == "azimuthVec" then
                --    return v:rotate(math.rad(-orientation_rot))
                
            elseif k == "delta" then
                return v:rotate(math.rad(-orientation_rot))
            end
            
            return v
        end,
        __newindex = function(t, k, v)
            CurrentTouch_codea[k] = v
        end
    })
    
    -- Override the Codea perspective() function to account for
    -- a locked orientation resolution
    perspective = function(fov, aspect, near, far)
        if fov == nil then
            perspective_codea(45, orientation_width/orientation_height)
        elseif aspect == nil then
            perspective_codea(fov, orientation_width/orientation_height)
        else
            perspective_codea(fov, aspect, near, far)
        end
    end
    
    -- Override the Codea ortho() function to account for
    -- a locked orientation resolution
    ortho = function(left, right, bottom, top, near, far)
        if left == nil then
            ortho_codea(0, orientation_width, 0, orientation_height, -10, 10)
        else
            ortho_codea(left, right, bottom, top, near, far)
        end
    end
    
    -- Override the Codea setContext() function to reinstate
    -- the orientation framebuffer when the project tries
    -- to apply nil
    setContext = function(img, useDepth)
        if img == nil then
            if orientation_fb ~= nil then
                setContext_codea(orientation_fb, true)
            else
                setContext_codea()
            end
        else
            setContext_codea(img, useDepth)
        end
    end
    
    -- Setting the mode on the viewer resets the WIDTH & HEIGHT
    -- variables so we need to intercept it
    viewer = setmetatable({}, {
        __index = function(t, k)
            return viewer_codea[k]
        end,
        __newindex = function(t, k, v)
            viewer_codea[k] = v
            
            -- If we're setting the mode, set the
            -- WIDTH & HEIGHT again
            if k == "mode" then
                WIDTH = orientation_width
                HEIGHT = orientation_height
            end
        end,
    })
end

-- The functions contained within this table
-- are used rather than the project provided
-- ones which are remapped to '_so_<function_name>'
--
-- This is done in order to wrap the project
-- provided implementations automatically.
local G_shadow = {
    draw = function()
        
        -- Just call the project provided impl.
        -- if we have no lock
        if orientation == nil then
            if _so_draw then _so_draw() end
            return
        end
        
        -- Override the WIDTH & HEIGHT values
        WIDTH = orientation_width
        HEIGHT = orientation_height
        
        -- Set framebuffer
        setContext_codea(orientation_fb, true)
        
        -- Draw into framebuffer
        if _so_draw then _so_draw() end
        
        -- Draw to display buffer
        setContext_codea()
        
        -- Blit the backbuffer with the locked rotation
        -- Push style & matrix
        pushMatrix()
        pushStyle()
        
        -- Reset matrices
        resetMatrix()
        ortho_codea()
        viewMatrix(matrix())
        
        -- Transform
        translate(WIDTH_codea/2, HEIGHT_codea/2)
        rotate(orientation_rot)
        
        -- Draw framebuffer
        spriteMode(CENTER)
        sprite_codea(orientation_fb, 0, 0)
        
        popStyle()
        popMatrix()
    end,
    
    touched = function(touch)
        -- No transformation needed
        if orientation == nil or orientation == CurrentOrientation then
            return _so_touched(touch)
        end
        
        -- Transform touch values
        local pos = toFB(touch.pos)
        local prevPos = toFB(touch.prevPos)
        local precisePos = toFB(touch.precisePos)        
        local precisePrevPos = toFB(touch.precisePos)
        local delta = touch.delta:rotate(math.rad(-orientation_rot))
        
        local t = {
            x = pos.x,
            y = pos.y,
            pos = pos,
            prevPos = prevPos,
            precisePos = precisePos,
            precisePrevPos = precisePrevPos,
            delta = delta,
        }
        
        -- Fallback to the original touch object
        t = setmetatable(t, {
            __index = function(t, k)
                return touch[k]
            end,
            __newindex = function(t, k, v)
                touch[k] = v
            end
        })
        
        _so_touched(t)
    end,
    
    sizeChanged = function(newWidth, newHeight)
        -- Update true res
        WIDTH_codea = newWidth
        HEIGHT_codea = newHeight
        
        -- adjust the orientation rotation if set
        updateOrientationLock()
        
        -- Override the WIDTH & HEIGHT values
        WIDTH = orientation_width
        HEIGHT = orientation_height
        
        -- Call wrapped function
        if _so_sizeChanged then _so_sizeChanged(orientation_width, orientation_height) end
    end
}

-- Global remappings
local remap = {
    ["draw"] = "_so_draw",
    ["touched"] = "_so_touched",
    ["sizeChanged"] = "_so_sizeChanged"
}

-- Set the metatable of the global table
-- We can then apply remappings
setmetatable(_G, {
    __index = function(t, k)
        return rawget(G_shadow, k)
    end,
    __newindex = function(t, k, v)
        k = remap[k] or k
        rawset(G_shadow, k, v)
    end
})

