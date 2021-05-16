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

-- Handle storage API overrides
local function doStorageAPI(path)
    
    -- Overridden asset object
    asset = setmetatable({}, {
        __index = function(t, k)
            if asset_codea[k] ~= nil then
                return asset_codea[k]
            end
            return asset_codea.documents .. path .. k
        end,
        __concat = function(l, r)
            return asset_codea.documents .. path .. r
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
    
    -- Parse project Data.plist
    local data_plist = readText(asset .. path .. "Data.plist")
    if data_plist ~= nil then
        data_plist = parsePList(data_plist)
    end
    
    saveProjectData = function(key, value)
        -- Do nothing
    end
    
    readProjectData = function(key, default)
        return data_plist[key] or default
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
end

local function doInputAPI()
end

-- Initialises all overrides
function overrideAPI(path)
    
    -- Nil out user defined callbacks
    setup = nil
    draw = nil
    
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
