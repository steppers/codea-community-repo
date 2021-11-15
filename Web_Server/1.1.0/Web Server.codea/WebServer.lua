local socket = require("socket")

local slen = string.len
local schar = string.char
local spack = string.pack
local sunpack = string.pack
local tinsert = table.insert
local tconcat = table.concat
local tpack = table.pack
local tmove = table.move
local ioopen = io.open

WebServer = class()

local local_ip = "x.x.x.x"

-- Get the local ip address
do
    local s = socket.udp()
    s:setpeername("8.8.8.8",80) -- Google DNS IP
    local_ip = s:getsockname()
    s:close()
end

-- Runs the server side scripts on the provided source
-- and returns the result
function WebServer.preprocess_html(html)
    
    -- Override print() in the env to write to a table instead
    -- so we can insert the result into the html
    local env = setmetatable({}, {__index=_G})
    local out = {}
    function env.print(...)
        tinsert(out, tconcat(tpack(...), " "))
    end
    
    -- Run script blocks
    for script in html:gmatch("<%?lua(.-)%?>") do
        local fn, err = load(script, "sslua", "t", env)
        if fn then
            fn()
            out = tconcat(out)
            html = html:gsub("<%?lua.-%?>", out, 1)
            out = {}
        else
            html = html:gsub("<%?lua.-%?>", "", 1)
            print("Server Side script failure:\n" .. err)
        end
    end
    
    -- Return the pre-processed html
    return html
end

-- Private helper
function WebServer.response(status_code, headers, body)
    local r = {}
    local function add(val)
        tinsert(r, val)
    end
    
    local rcode_desc = {
        [101] = "Switching Protocols",
        [200] = "OK",
        [201] = "Created",
        [202] = "Accepted",
        [400] = "Bad Request",
        [401] = "Unauthorized",
        [403] = "Forbidden",
        [404] = "Not Found",
        [500] = "Internal Server Error",
        [501] = "Not Implemented",
        [502] = "Bad Gateway",
        [505] = "HTTP Version Not Supported"
    }
    
    add("HTTP/1.1 " .. status_code .. " " .. (rcode_desc[status_code] or "<Undefined>"))
    
    for k,v in pairs(headers or {}) do
        add(k .. ": " .. v)
    end
    
    if body then
        -- Add content length header
        add("Content-Length: " .. #body)
    end
    
    -- Add any body
    if body then
        -- add blank line to mark end of meta-information
        -- (CRLF added in concat)
        add("")
        add(body)
    else
        -- add CRLF to mark end of meta-information
        add("\r\n")
    end
    
    return tconcat(r, "\r\n")
end
local response = WebServer.response




-- Constructor
function WebServer:init(source_folder, port)

    self.source_folder = source_folder
    self.ip, self.port = local_ip, (port or 80)
    self.resources = {}
    self.websockets = {}
    
    -- Create the socket and bind to the specified port (or 80 by default)
    self.socket = assert(socket.bind("*", self.port))
    self.socket:settimeout(0)
    
    do
        -- The async loop to execute once per frame
        tween.interval(0.00001, function()
            self:_update()
        end)
    end
    
    -- Add default resource
    self:add_resource("/(.*)", function(request, path)
        -- Only GET supported on default resource handler
        if request.method ~= "GET" then
            return 501
        end
        
        -- Empty path opens index.html
        if path == "" then
            path = "index.html"
        end
        
        -- Get the file from the server source directory
        local source = self:get_file(path)
        if source then
            -- Pre-process html source, running any server-side
            -- <?lua ... ?> script blocks
            if path:find(".html$") then
                source = WebServer.preprocess_html(source)
            end
            return 200, source
        end
    end)
end

function WebServer:add_resource(...)
    local patterns = {}
    local func = nil
    
    for _,v in ipairs({...}) do
        local t = type(v)
        if t == "string" then
            tinsert(patterns, v)
        elseif t == "function" then
            func = v
            break
        end
    end
    
    for _,pattern in ipairs(patterns) do
        tinsert(self.resources, {
            pattern = "^" .. pattern,
            func = func
        })
    end
    
    return self
end

function WebServer:add_websocket(uri, on_open)
    tinsert(self.websockets, {
        uri = "^" .. uri .. "$",
        ws = WebSocket(on_open)
    })
    return self
end

function WebServer:get_file(path)
    local res_asset = self.source_folder .. path
    
    -- Read the asset and return the content
    -- or return nil if it doesn't exist
    if res_asset then
        local file = ioopen(res_asset.path, "rb")
        if file then
            local data = file:read("*a")
            file:close()
            return data
        end
    end
    return nil
end





------------------------------------------------------------
-- PRIVATE - Used internally only
------------------------------------------------------------
function WebServer:_update()
    
    -- Handle new connections
    while true do
        -- Accept a new client connection
        local should_close = true
        local client, err = self.socket:accept()
        if err then
            -- No more clients
            break
        end
        
        local buffer = ""
        
        -- Set a 1 second timeouts
        client:settimeout(1)
        
        -- Get the request meta-information
        -- (Request line + headers)
        local chunk = {}
        while true do
            local ln, err = client:receive()
            if err or ln == "" then
                -- End of meta-info
                break
            end
            tinsert(chunk, ln)
        end
        
        if #chunk ~= 0 then
            local method, uri = chunk[1]:match("(.-) (.-) ")
            local headers = {}
            tmove(chunk, 2, #chunk, 1, headers)
            for i,h in ipairs(headers) do
                local k,v = h:match("(.-) *: *(.*)")
                headers[k] = v
            end
            
            -- Get the body of the request
            local body, err = nil, nil
            if headers["Content-Length"] then
                body, err = client:receive(headers["Content-Length"])
                if err then
                    client:send(response(400, nil, "400 Bad Request"))
                end
            end
            
            if not err then
                parsed_uri = socket.url.parse(uri)
                
                -- Unescape the URI path
                uri = socket.url.unescape(parsed_uri.path)
                
                -- Handled flag
                local handled = false
                
                -- Is this a websocket upgrade request?
                if  headers["Upgrade"] == "websocket" and
                    headers["Connection"] == "Upgrade" then
                    
                    -- Scan for a suitable websocket
                    for i = #self.websockets,1,-1 do
                        local ws = self.websockets[i]
                        if uri:find(ws.uri) then
                            ws.ws:_new_connection(client, headers["Sec-WebSocket-Key"])
                            -- Websocket remains open
                            should_close = false
                            handled = true
                            break
                        end
                    end
                else
                    
                    -- Parse query values
                    local query = nil
                    if parsed_uri.query then
                        query = {}
                        for k, v in parsed_uri.query:gmatch("(.-)=([^&]*)&?") do
                            query[socket.url.unescape(k)] = socket.url.unescape(v)
                        end
                    end
                    
                    -- Check defined resources
                    for i = #self.resources,1,-1 do
                        local r = self.resources[i]
                        if uri:find(r.pattern) then
                            -- Init the request object
                            local request = {
                                uri = uri,
                                method = method,
                                headers = headers,
                                body = body,
                                query = query
                            }
                            
                            -- Pass to handler
                            local status_code, body, headers = r.func(request, uri:match(r.pattern))
                            
                            -- Was it handled?
                            if status_code then
                                client:send(response(status_code, headers, body))
                                handled = true
                                break
                            end
                        end
                    end
                end
                
                -- Not Found
                if not handled then
                    client:send(response(404, nil, "404 Not Found"))
                end
                
                if should_close then
                    client:close()
                end
            end
        end
    end
    
    -- Update connected websockets
    for _,ws in ipairs(self.websockets) do
        ws.ws:_update()
    end
end
