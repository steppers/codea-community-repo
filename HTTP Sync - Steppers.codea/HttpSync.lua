-- HttpSync
--
-- Provides http.requestSync, a synchronous alternative to http.request
-- avoiding the need for callbacks.
--
-- http.requestSync returns the values: ok, data, status_code, headers
--
-- Steppers - 2021
    
local function callOnMain(fn, ...)
    coroutine.yield(fn, table.pack(...))
end

-- Single coroutine handles the setup() & draw() functions
local main_cr = coroutine.create(function()
        
    -- Only call setup() if it exists
    if _wrap_setup then _wrap_setup() end
    
    while true do
        -- Wait for the next call to draw() from the Codea runtime
        coroutine.yield()
        
        -- Only call draw() if it exists
        if _wrap_draw then _wrap_draw() end
    end
end)

function drawWrapper()
    
    -- Loop until the main coroutine yields without
    -- passing a function for us to run
    while true do
        ok, fn, args = coroutine.resume(main_cr)
        
        if ok and fn ~= nil then
            
            -- Call the function the main cr has passed to us
            fn(table.unpack(args))
        elseif ok then
            
            -- No function for us to call so we're done
            break
        else
            
            -- Error in the main coroutine
            error(fn)
        end
    end
end

-- Asynchronous http request needs to be called on main thread
local http_request_codea = http.request
http.request = function(url, success, fail, params)
    callOnMain(http_request_codea, url, success, fail, params)
end

-- Synchronous http request
http.requestSync = function(url, params)
    
    local result = nil
    
    local function success(data, status, headers)
        result = table.pack(true, data, status, headers)
    end
    
    local function fail(err)
        result = table.pack(false, err)
    end
    
    -- http.request must be called on the main thread
    http.request(url, success, fail, params)
    
    -- Wait for the request to complete
    while result == nil do
        coroutine.yield()
    end
    
    -- Return the result of the request
    return table.unpack(result)
end

-- Override the setup() and draw() functions
-- so we don't call the original setup() directly
-- and only utilise the coroutine we create
-- above.
wrapGlobalFunc("setup", nil)
wrapGlobalFunc("draw", drawWrapper)
