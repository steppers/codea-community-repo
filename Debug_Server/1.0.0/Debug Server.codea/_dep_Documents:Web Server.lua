-- Contents:
--    Main.lua
--    WebServer.lua

------------------------------
-- Main.lua
------------------------------
do
-- Demo

function setup()
    -- Open up this project as a webserver
    local server = WebServer(asset, 80)
    print("Web Server running!")
    
    -- Print the access URLs
    print("Connect at:\n\nhttp://localhost\n\nor\n\nhttp://" .. server.ip .. ":" .. server.port .. "\n(for other devices on the local network)")
end

function draw()
    background(113, 206, 155)
end


end
------------------------------
-- WebServer.lua
------------------------------
do
-- Basic Web Server

local socket = require("socket")

WebServer = class()

-- Get the local ip address
do
    local s = socket.udp()
    s:setpeername("8.8.8.8",80) -- Google DNS IP
    WebServer.local_ip = s:getsockname()
    s:close()
end

--  Web Server constructor
function WebServer:init(source_folder, port)
    self.socket = assert(socket.bind("*", port or 80))
    self.socket:settimeout(0.001) -- minimise waiting
    self.source_folder = source_folder
    self.custom_resources = {}
    self.ip, self.port = WebServer.local_ip, (port or 80)
    
    local function webserver_loop()
        http.request("http://imnotarealurl.lua", function() end, function()
            self:_update()
            webserver_loop()
        end)
    end
    
    -- Kick off the async web server loop
    webserver_loop()
end

function WebServer:add_custom_source(path, func)
    self.custom_resources[path] = func
end





------------------------------------------------------------
-- PRIVATE - Used internally only
------------------------------------------------------------
function WebServer:_get_resource(path)
    -- Use the index page when the path
    -- is blank
    if path == "" then
        path = "index.html"
    end
    
    -- Use the custom sources if available
    if self.custom_resources[path] then
        return self.custom_resources[path]()
    end
    
    local res_asset = self.source_folder .. path
    
    -- Read the asset and return the content
    -- or return nil if it doesn't exist
    if res_asset then
        local file = io.open(res_asset.path, "rb")
        if file then
            local data = file:read("*a")
            file:close()
            return data
        end
    end
    return nil
end

function WebServer:_update()
    
    -- wait for a connection from any client
    local client = self.socket:accept()
    if client then
        -- Make sure we don't take too long to respond to the client
        client:settimeout(1 / 60)
        
        -- Receive the request
        local line, err = client:receive()
        
        -- If no error then send our response
        if not err then
            
            -- Only handle GET requests
            if line:find("^GET") ~= nil then
                local res = self:_get_resource(line:match("^GET /([^ ]-) "))
                if res then
                    client:send("HTTP/1.0 200 Success \r\n\r\n" .. res)
                else
                    client:send("HTTP/1.0 404 Not Found \r\n\r\n404 This page does not exist!")
                end
            else
                client:send("HTTP/1.0 501 Not Implemented \r\n\r\n")
            end
        end
            
        -- Close the client object
        client:close()
    end
end


end
