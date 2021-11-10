DebugServer = {}

-- Stores expression strings that are evaluated during
-- update
local watched_values = {}

-- Stores key-value pairs that are updated and cleared
-- every frame.
local frame_values = {}

-- The webserver object
local webserver = nil

-- Stores the source we provide to the browser every time
-- it updates
local source_html = "Please call DebugServer:update() in Codea's draw() function."

function DebugServer.start(port)
    if webserver ~= nil then
        print("Debug Server already running at port " .. webserver.port)
        return
    end
    
    DebugServer.port = port or 80
    
    webserver = WebServer(asset, DebugServer.port)
    DebugServer.ip = webserver.ip
    
    -- Provide the normal html first
    webserver:add_custom_source("index.html", function()
        return index_html
    end)
    
    -- This content is updated at runtime
    webserver:add_custom_source("debug_update.lua", function()
        return source_html
    end)
    
    if webserver.port ~= 80 then
        print("Debug server running at " .. webserver.ip .. ":" .. webserver.port .. " and localhost:" .. webserver.port)
    else
        print("Debug server running at " .. webserver.ip .. " and localhost")
    end
    
    -- Add a button to open the debug monitor
    parameter.action("Open Debug Monitor", function()
        openURL("http://localhost:" .. webserver.port)
    end)
end

-- Same behaviour as parameter.watch
function DebugServer.watch(expression)
    table.insert(watched_values, expression)
end

function DebugServer.log(id, value)
    frame_values[id] = value
end

-- Generates the HTML content provided to the browser
function DebugServer.update()
    local t = {}
    
    local function add(source)
        table.insert(t, source)
    end
    
    add("<h2>Codea Debug Monitor</h2>")
    add("<hr>")
    
    add("<h4>Watches:</h4>")
    for _,v in ipairs(watched_values) do
        local fn, err = load("return " .. v)
        if not err then
            add(v .. ": " .. fn())
        else
            add(v .. ": " .. err)
        end
    end

    add("<hr>")
    add("<h4>Current Frame:</h4>")
    for id,v in pairs(frame_values) do
        add(id .. ": " .. v)
    end
    frame_values = {} -- Clear for next frame
    
    -- Generate the final source
    source_html = table.concat(t)
end
