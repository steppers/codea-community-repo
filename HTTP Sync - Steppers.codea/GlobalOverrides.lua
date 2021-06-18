-- GlobalOverrides, also available on WebRepo
--
-- Provides a simple interface for intercepting global
-- variable and function usage.
--
-- Steppers - 2021

-- WebRepo provides this already so don't add it here.
if _WEB_REPO_LAUNCH_ then
    return
end

-- Global shadow table & remappings
local shadow = nil
local func_remap = nil
local value_remap = nil

-- Initialises the global environment's metatable
-- and sets up the shadow & remap tables
local function initGlobalMetatable()
    shadow = {}
    func_remap = {}
    value_remap = {}
    
    if getmetatable(_G) ~= nil then
        error("Unable to init global metatable as the global environment already has a metatable!")
    end
    
    -- Set the metatable of the global table
    -- We can then apply any remappings
    setmetatable(_G, {
        __index = function(t, k)
            -- Only remap values when read
            k = value_remap[k] or k
            return shadow[k]
        end,
        __newindex = function(t, k, v)
            -- Only remap functions when writing
            k = func_remap[k] or k
            shadow[k] = v
        end
    })
end

-- Wraps a global function with the provided function
--
-- The wrapper function should call _wrap_<global_name>
-- to call the wrapped function.
--
-- Reads of the wrapped global will always return the
-- wrapper itself rather than the currently wrapped
-- function. This means you cannot read the wrapped value
-- directly. Use getWrappedGlobalFunc() instead.
function wrapGlobalFunc(global_name, wrapper)
    
    if shadow == nil then
        initGlobalMetatable()
    end
    
    if func_remap[global_name] ~= nil then
        error("Wrapping already wrapped global function! (" .. global_name .. ")")
    end
    
    -- Setup mapping and wrapper
    func_remap[global_name] = "_wrap_" .. global_name
    shadow[global_name] = wrapper
    shadow["_wrap_" .. global_name] = rawget(_G, global_name)
    
    -- Make sure the raw global is not set
    rawset(_G, global_name, nil)
end

-- Returns the function currently wrapped for the specified global
function getWrappedGlobalFunc(global_name)
    return shadow["_wrap_" .. global_name]
end

-- Overrides the value of a Global variable
-- The value can then only be set using this function
-- Any write to the global outside of this function
-- will not be visible to the rest of the project.
function overrideGlobal(global_name, value)
    if shadow == nil then
        initGlobalMetatable()
    end
    
    -- Setup mapping and override
    value_remap[global_name] = "_ovrd_" .. global_name
    shadow["_ovrd_" .. global_name] = value
    shadow[global_name] = rawget(_G, global_name)
    
    -- Make sure the raw global is not set
    -- so we force access via the shadow
    rawset(_G, global_name, nil)
end

-- Returns the value of the provided global
-- ignoring any override.
function getOverriddenGlobal(global_name)
    if shadow == nil then return nil end
    return shadow[global_name]
end
