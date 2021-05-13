-- API Overrides
--
-- Global overrides of various Codea APIs to ensure the app runs correctly in
-- our nested environment

local asset_codea = asset
local sprite_codea = sprite
local readText_codea = readText
local saveText_codea = saveText
local readImage_codea = readImage
local saveImage_codea = saveImage

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
end
