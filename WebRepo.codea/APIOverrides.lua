-- API Overrides
--
-- Global overrides of various Codea APIs to ensure the app runs correctly in
-- our nested environment

local asset_codea = asset
local sprite_codea = sprite

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
    
end

local function doGraphicsAPI(path, restore)
    
    --sprite = function(img, x, y, w, h)
        --print(type(img))
    --end
    
end

-- Initialises all overrides
function overrideAPI(path)
    doStorageAPI(path)
    doGraphicsAPI(path)
    
    -- Nil out user defined callbacks
    setup = nil
    draw = function() background(0, 0, 0) end
end
