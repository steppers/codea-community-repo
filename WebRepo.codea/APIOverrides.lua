-- API Overrides
--
-- Global overrides of various Codea APIs to ensure the app runs correctly in
-- our nested environment

-- Save Codea's own implementations
local mesh_codea = mesh
local asset_codea = asset
local sprite_codea = sprite
local readText_codea = readText
local saveText_codea = saveText
local readImage_codea = readImage
local saveImage_codea = saveImage
local CurrentTouch_codea = CurrentTouch
local setContext_codea = setContext
local perspective_codea = perspective
local ortho_codea = ortho
local WIDTH_codea = WIDTH
local HEIGHT_codea = HEIGHT
local layout_codea = layout
local viewer_codea = viewer

-- Internal state
local orientation = nil
local orientation_rot = 0
local orientation_width = 0
local orientation_height = 0
local orientation_fb = nil

-- Maps supported orientations to transforms depending on
-- the current orientation
--
-- map[orientation][CurrentOrientation] = { rot, tx, ty }
local orientation_rot_map = {
    [PORTRAIT_ANY] = {
        [LANDSCAPE_LEFT] = 90,
        [LANDSCAPE_RIGHT] = 90,
        [PORTRAIT] = 0,
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

-- Translate a position into framebuffer space
local function toFB(pos)
    pos = pos - vec2(WIDTH_codea/2, HEIGHT_codea/2)
    pos = pos:rotate(math.rad(-orientation_rot))
    pos = pos + vec2(orientation_width/2, orientation_height/2)
    return pos
end

-- Initialise orientation lock variables
local function initOrientationLock()
    if orientation == nil then
        orientation_fb = nil
        return
    end
    
    local is_portrait = (CurrentOrientation == PORTRAIT) or (CurrentOrientation == PORTRAIT_UPSIDE_DOWN)
    
    -- Update the orientation resolution
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
    if orientation == nil then
        return
    end
    
    -- Get the intended rotation
    orientation_rot = orientation_rot_map[orientation][CurrentOrientation]
end

-- Handle storage API overrides
local function doStorageAPI(path)
    
    -- Overridden asset object
    asset = setmetatable({}, {
        __index = function(t, k)
            if asset_codea[k] ~= nil then
                return asset_codea[k]
            end
            return asset_codea .. path .. k
        end,
        __concat = function(l, r)
            return asset_codea .. path .. r
        end
    })

    readText = function(asset_key)
        if type(asset_key) ~= "string" then
            return readText_codea(asset_key)
        else -- Old API style
            asset_key, n = string.gsub(asset_key, "Project:", "", 1)
            if n == 1 then
                return readText_codea(asset .. asset_key .. ".txt")
            else
                return readText_codea(asset_key)
            end            
        end
    end

    saveText = function(asset_key, data)
        if type(asset_key) ~= "string" then
            return saveText_codea(asset_key, data)
        else -- Old API style
            asset_key, n = string.gsub(asset_key, "Project:", "", 1)
            if n == 1 then
                return saveText_codea(asset .. asset_key .. ".txt", data)
            else
                return saveText_codea(asset_key, data)
            end
        end
    end
    
    readImage = function(asset_key)
        if type(asset_key) ~= "string" then
            return readImage_codea(asset_key)
        else -- Old API style
            asset_key, n = string.gsub(asset_key, "Project:", "", 1)
            if n == 1 then
                return readImage_codea(asset .. asset_key)
            else
                return readImage_codea(asset_key)
            end
        end
    end
    
    saveImage = function(asset_key, data)
        if type(asset_key) ~= "string" then
            return saveImage_codea(asset_key, data)
        else -- Old API style
            asset_key, n = string.gsub(asset_key, "Project:", "", 1)
            if n == 1 then
                return saveImage_codea(asset .. asset_key, data)
            else
                return saveImage_codea(asset_key, data)
            end
        end
    end
    
end

local function doGraphicsAPI(path, restore)
    
    sprite = function(asset_key, x, y, w, h)
        -- Defaults
        x = x or 0
        y = y or 0
        
        if type(asset_key) ~= "string" then
            if w and h then
                return sprite_codea(asset_key, x, y, w, h)
            elseif w then
                return sprite_codea(asset_key, x, y, w)
            else
                return sprite_codea(asset_key, x, y)
            end
        else -- Old API style
            asset_key, n = string.gsub(asset_key, "Project:", "", 1)
            if n == 1 then
                if w and h then
                    return sprite_codea(asset .. asset_key, x, y, w, h)
                elseif w then
                    return sprite_codea(asset .. asset_key, x, y, w)
                else
                    return sprite_codea(asset .. asset_key, x, y)
                end
            else
                if w and h then
                    return sprite_codea(asset_key, x, y, w, h)
                elseif w then
                    return sprite_codea(asset_key, x, y, w)
                else
                    return sprite_codea(asset_key, x, y)
                end
            end
        end
    end
    
    -- Overriden mesh objects to direct mesh.texture
    -- assignment to the correct file in the launched
    -- project.
    mesh = function()
        return setmetatable({ _internal = mesh_codea() }, {
            __index = function(t, k)
                local v = t._internal[k]
                
                -- If we're accessing a mesh function
                -- we need to make sure we pass the correct
                -- value for 'self' and not the wrapper
                if type(v) == "function" then
                    return function(_, ...)
                        return t._internal[k](t._internal, ...)
                    end
                end
                
                return v
            end,
            __newindex = function(t, k, v)
                -- If we're trying to set the texture with a string use our
                -- readImage override so we get the correct asset
                --
                -- If for some reason the project tries to read the
                -- texture it'll be an image though rather than an
                -- asset string so bear that in mind
                if k == "texture" and type(v) == "string" then 
                    v = readImage(v)
                end
                t._internal[k] = v
            end
        })
    end
    
    -- Update orientation lock setup
    sizeChanged = function(newWidth, newHeight)
        -- Update true res
        WIDTH_codea = newWidth
        HEIGHT_codea = newHeight
        
        -- adjust the orientation rotation if set
        updateOrientationLock()
        
        -- Override the WIDTH & HEIGHT values
        WIDTH = orientation_width
        HEIGHT = orientation_height
        print(WIDTH, HEIGHT)
        
        -- Call wrapped function
        if wr_sizeChanged then wr_sizeChanged(orientation_width, orientation_height) end
    end
    
    -- Save intended orientation so we can enforce it in our
    -- pre draw hook
    supportedOrientations = function(orientation_in)
        orientation = orientation_in
        initOrientationLock()
        
        -- Override the WIDTH & HEIGHT values
        WIDTH = orientation_width
        HEIGHT = orientation_height
        
        print("so", WIDTH, HEIGHT)
    end
    
    perspective = function(fov, aspect, near, far)
        if fov == nil then
            perspective_codea(45, orientation_width/orientation_height)
        elseif aspect == nil then
            perspective_codea(fov, orientation_width/orientation_height)
        else
            perspective_codea(fov, aspect, near, far)
        end
    end
    
    ortho = function(left, right, bottom, top, near, far)
        if left == nil then
            ortho_codea(0, orientation_width, 0, orientation_height, -10, 10)
        else
            ortho_codea(left, right, bottom, top, near, far)
        end
    end
    
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
    
    draw = function()
        if orientation == nil then
            wr_draw()
            return
        end
        
        -- Override the WIDTH & HEIGHT values
        WIDTH = orientation_width
        HEIGHT = orientation_height
        
        -- Set framebuffer
        setContext_codea(orientation_fb, true)
            
        -- Draw into framebuffer
        wr_draw()
        
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
    
    -- TODO: Safe areas not supported with fixed orientations yet
    layout = setmetatable({}, {
        __index = function(t, k)
            return layout_codea[k]
        end
    })
end

local function doInputAPI()
    
    touched = function(touch)
        -- No transformation needed
        if orientation == nil or orientation == CurrentOrientation then
            return wr_touched(touch)
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
        
        wr_touched(t)
    end
    
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
            --    return v:rotate(math.rad(-trans.rot))
                
            elseif k == "delta" then
                return v:rotate(math.rad(-orientation_rot))
            end
            
            return v
        end,
        __newindex = function(t, k, v)
            CurrentTouch_codea[k] = v
        end
    })
end

-- Initialises all overrides
function overrideAPI(path)
    
    -- Nil out user defined callbacks
    setup = nil
    draw = function() background(0, 0, 0) end
    
    -- Nil out Codea input callbacks WebRepo uses itself
    touched = nil
    keyboard = nil
    scroll = nil
    
    -- Nil out our custom input callbacks
    tap = nil
    pan = nil
    press = nil
    
    -- Setup overrides for the nested environment
    doStorageAPI(path)
    doGraphicsAPI(path)
    doInputAPI()
end

-- Returns a modified version of code_str
-- to override certain API usages
function adjustCode(code_str)
    
    -- draw() intercept
    code_str = string.gsub(code_str, "(%s)function%sdraw%(", "%1function wr_draw(")
    code_str = string.gsub(code_str, "(%s)draw%s*=", "%1wr_draw =")
    
    -- touched() intercept
    code_str = string.gsub(code_str, "(%s)function%stouched%(", "%1function wr_touched(")
    code_str = string.gsub(code_str, "(%s)touched%s*=", "%1wr_touched =")
    
    -- sizeChanged() intercept
    code_str = string.gsub(code_str, "(%s)function%ssizeChanged%(", "%1function wr_sizeChanged(")
    code_str = string.gsub(code_str, "(%s)sizeChanged%s*=", "%1wr_sizeChanged =")
    
    return code_str
end
