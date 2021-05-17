-- GlobalFuncWrapper
--
-- Provides a simple interface for intercepting global function
-- calls.

-- WebRepo provides this already so don't add it here.
if _WEB_REPO_LAUNCH_ then
    return
end

-- Global shadow table & remappings
local shadow = nil
local remap = nil

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
        shadow = {}
        remap = {}
        
        if getmetatable(_G) ~= nil then
            error("Unable to wrap a global function as the global environment already has a metatable!")
        end
        
        -- Set the metatable of the global table
        -- We can then apply any remappings
        setmetatable(_G, {
            __index = function(t, k)
                -- Indexing never does a remap.
                -- This means we cannot read back the wrapped global
                -- directly as it will always return the wrapper.
                -- Use getWrappedGlobalFunc() below instead
                return shadow[k]
            end,
            __newindex = function(t, k, v)
                k = remap[k] or k
                shadow[k] = v
            end
        })
    end
    
    if remap[global_name] ~= nil then
        error("Wrapping already wrapped global function!")
    end
    
    -- Setup mapping and wrapper
    remap[global_name] = "_wrap_" .. global_name
    shadow[global_name] = wrapper
    shadow["_wrap_" .. global_name] = rawget(_G, global_name)
end

-- Returns the function currently wrapped for the specified global
function getWrappedGlobalFunc(global_name)
    return shadow["_wrap_" .. global_name]
end
