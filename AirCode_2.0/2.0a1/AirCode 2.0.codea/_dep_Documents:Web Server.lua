-- Contents:
--    Main.lua
--    sha1.lua
--    WebServer.lua
--    WebSocket.lua
--    WebSocketClient.lua
--    TweenMod.lua

------------------------------
-- Main.lua
------------------------------
do
-- Web Server
-- By Steppers

local server = nil      -- Web Server

viewer.mode = FULLSCREEN

function setup()
    -- Change the 'asset' value to point to another
    -- folder in your Codea Documents directory if
    -- you want to create your own website.
    --
    -- This is technically the only line you need to
    -- create a simple static website!
    server = WebServer(asset)
end

function draw()
    -- Clear and init style settings
    background(49, 84, 65)
    textMode(CENTER)
    textAlign(CENTER)
    fill(255)
    
    
    -- Print connection info
    text("Web Server running at:\nhttp://" .. server.ip .. ":" .. server.port .. "\nand\nhttp://localhost:" .. server.port, WIDTH/2, HEIGHT/2)
end


end
------------------------------
-- sha1.lua
------------------------------
do
local common = {}

-- Merges four bytes into a uint32 number.
function common.bytes_to_uint32(a, b, c, d)
   return a * 0x1000000 + b * 0x10000 + c * 0x100 + d
end

-- Splits a uint32 number into four bytes.
function common.uint32_to_bytes(a)
   local a4 = a % 256
   a = (a - a4) / 256
   local a3 = a % 256
   a = (a - a3) / 256
   local a2 = a % 256
   local a1 = (a - a2) / 256
   return a1, a2, a3, a4
end

sha1 = {
   -- Meta fields retained for compatibility.
   _VERSION     = "sha.lua 0.6.0",
   _URL         = "https://github.com/mpeterv/sha1",
   _DESCRIPTION = [[
SHA-1 secure hash and HMAC-SHA1 signature computation in Lua,
using bit and bit32 modules and Lua 5.3 operators when available
and falling back to a pure Lua implementation on Lua 5.1.
Based on code orignally by Jeffrey Friedl and modified by
Eike Decker and Enrique García Cota.]],
   _LICENSE = [[
MIT LICENSE

Copyright (c) 2013 Enrique García Cota, Eike Decker, Jeffrey Friedl
Copyright (c) 2018 Peter Melnichenko

Permission is hereby granted, free of charge, to any person obtaining a
copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.]]
}

sha1.version = "0.6.0"

local ops = {}

function ops.uint32_lrot(a, bits)
   return ((a << bits) & 0xFFFFFFFF) | (a >> (32 - bits))
end

function ops.byte_xor(a, b)
   return a ~ b
end

function ops.uint32_xor_3(a, b, c)
   return a ~ b ~ c
end

function ops.uint32_xor_4(a, b, c, d)
   return a ~ b ~ c ~ d
end

function ops.uint32_ternary(a, b, c)
   -- c ~ (a & (b ~ c)) has less bitwise operations than (a & b) | (~a & c).
   return c ~ (a & (b ~ c))
end

function ops.uint32_majority(a, b, c)
   -- (a & (b | c)) | (b & c) has less bitwise operations than (a & b) | (a & c) | (b & c).
   return (a & (b | c)) | (b & c)
end

local uint32_lrot = ops.uint32_lrot
local byte_xor = ops.byte_xor
local uint32_xor_3 = ops.uint32_xor_3
local uint32_xor_4 = ops.uint32_xor_4
local uint32_ternary = ops.uint32_ternary
local uint32_majority = ops.uint32_majority

local bytes_to_uint32 = common.bytes_to_uint32
local uint32_to_bytes = common.uint32_to_bytes

local sbyte = string.byte
local schar = string.char
local sformat = string.format
local srep = string.rep

local function hex_to_binary(hex)
   return (hex:gsub("..", function(hexval)
      return schar(tonumber(hexval, 16))
   end))
end

-- Calculates SHA1 for a string, returns it encoded as 40 hexadecimal digits.
function sha1.sha1(str)
   -- Input preprocessing.
   -- First, append a `1` bit and seven `0` bits.
   local first_append = schar(0x80)

   -- Next, append some zero bytes to make the length of the final message a multiple of 64.
   -- Eight more bytes will be added next.
   local non_zero_message_bytes = #str + 1 + 8
   local second_append = srep(schar(0), -non_zero_message_bytes % 64)

   -- Finally, append the length of the original message in bits as a 64-bit number.
   -- Assume that it fits into the lower 32 bits.
   local third_append = schar(0, 0, 0, 0, uint32_to_bytes(#str * 8))

   str = str .. first_append .. second_append .. third_append
   assert(#str % 64 == 0)

   -- Initialize hash value.
   local h0 = 0x67452301
   local h1 = 0xEFCDAB89
   local h2 = 0x98BADCFE
   local h3 = 0x10325476
   local h4 = 0xC3D2E1F0

   local w = {}

   -- Process the input in successive 64-byte chunks.
   for chunk_start = 1, #str, 64 do
      -- Load the chunk into W[0..15] as uint32 numbers.
      local uint32_start = chunk_start

      for i = 0, 15 do
         w[i] = bytes_to_uint32(sbyte(str, uint32_start, uint32_start + 3))
         uint32_start = uint32_start + 4
      end

      -- Extend the input vector.
      for i = 16, 79 do
         w[i] = uint32_lrot(uint32_xor_4(w[i - 3], w[i - 8], w[i - 14], w[i - 16]), 1)
      end

      -- Initialize hash value for this chunk.
      local a = h0
      local b = h1
      local c = h2
      local d = h3
      local e = h4

      -- Main loop.
      for i = 0, 79 do
         local f
         local k

         if i <= 19 then
            f = uint32_ternary(b, c, d)
            k = 0x5A827999
         elseif i <= 39 then
            f = uint32_xor_3(b, c, d)
            k = 0x6ED9EBA1
         elseif i <= 59 then
            f = uint32_majority(b, c, d)
            k = 0x8F1BBCDC
         else
            f = uint32_xor_3(b, c, d)
            k = 0xCA62C1D6
         end

         local temp = (uint32_lrot(a, 5) + f + e + k + w[i]) % 4294967296
         e = d
         d = c
         c = uint32_lrot(b, 30)
         b = a
         a = temp
      end

      -- Add this chunk's hash to result so far.
      h0 = (h0 + a) % 4294967296
      h1 = (h1 + b) % 4294967296
      h2 = (h2 + c) % 4294967296
      h3 = (h3 + d) % 4294967296
      h4 = (h4 + e) % 4294967296
   end

   return sformat("%08x%08x%08x%08x%08x", h0, h1, h2, h3, h4)
end

function sha1.binary(str)
   return hex_to_binary(sha1.sha1(str))
end

-- Precalculate replacement tables.
local xor_with_0x5c = {}
local xor_with_0x36 = {}

for i = 0, 0xff do
   xor_with_0x5c[schar(i)] = schar(byte_xor(0x5c, i))
   xor_with_0x36[schar(i)] = schar(byte_xor(0x36, i))
end

-- 512 bits.
local BLOCK_SIZE = 64

function sha1.hmac(key, text)
   if #key > BLOCK_SIZE then
      key = sha1.binary(key)
   end

   local key_xord_with_0x36 = key:gsub('.', xor_with_0x36) .. srep(schar(0x36), BLOCK_SIZE - #key)
   local key_xord_with_0x5c = key:gsub('.', xor_with_0x5c) .. srep(schar(0x5c), BLOCK_SIZE - #key)

   return sha1.sha1(key_xord_with_0x5c .. sha1.binary(key_xord_with_0x36 .. text))
end

function sha1.hmac_binary(key, text)
   return hex_to_binary(sha1.hmac(key, text))
end

setmetatable(sha1, {__call = function(_, str) return sha1.sha1(str) end})
end
------------------------------
-- WebServer.lua
------------------------------
do
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
function WebServer.preprocess_html(html, env)
    
    -- Override print() in the env to write to a table instead
    -- so we can insert the result into the html
    local env = setmetatable(env or {}, {__index=_G})
    local out = {}
    function env.print(...)
        tinsert(out, tconcat(tpack(...), " "))
    end
    
    function env.log(...)
        print(...)
    end
    
    -- Run script blocks
    for script in html:gmatch("<%?lua(.-)%?>") do
        local fn, err = load(script, "sslua", "t", env)
        if fn then
            fn()
            out = tconcat(out):gsub("%%", "%%%%")
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
                source = WebServer.preprocess_html(source, {request=request})
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

end
------------------------------
-- WebSocket.lua
------------------------------
do
local socket = require("socket")
local mime = require("mime")

local sha1_binary = sha1.binary
local mime_b64 = mime.b64

local slen = string.len
local schar = string.char
local spack = string.pack
local sunpack = string.unpack
local tinsert = table.insert
local tconcat = table.concat

local function xor_cipher32(data, key)
    local out = {}
    for i=1,slen(data) do
        tinsert(out, schar(data:byte(i) ~ key:byte(((i-1) % 4) + 1)))
    end
    return tconcat(out)
end

WebSocket = class()
function WebSocket:init(on_open)
    self.connections = {}
    self.clients = {}
    self.on_open = on_open
end

function WebSocket:_new_connection(connection, key)
    -- Register connection
    tinsert(self.connections, connection)
    self.clients[connection] = WebSocketClient(connection)
    
    -- Blocking, if we're expecting a full frame
    -- be damn sure we receive it.
    --
    -- Well, as best we can for now...
    connection:settimeout(nil)
    
    -- Take key, append constant, hash it then base64 encode
    key = key .. "258EAFA5-E914-47DA-95CA-C5AB0DC85B11"
    key = sha1_binary(key)
    key = mime_b64(key)

    -- Send our connection upgrade response so the browser
    -- knows we're ready
    connection:send(WebServer.response(101, {
        ["Upgrade"] = "websocket",
        ["Connection"] = "Upgrade",
        ["Sec-WebSocket-Accept"] = key
    }))
    
    -- Trigger callback
    self.on_open(self.clients[connection])
end

function WebSocket:_update()
    
    local function receive_frame(con)        
        local bytes, err = con:receive(2)
        if err then return nil end
        
        -- Header values
        local b1, b2 = bytes:byte(1, 2)
        local fin = (b1 & 0x80) >> 7
        local op = b1 & 0x0F
        local mask = (b2 & 0x80) >> 7
        
        -- The spec says if a server receives an
        -- unmasked message, it is to close the
        -- connection.
        if mask ~= 1 then
            con:close()
            return nil
        end
        
        -- Get the payload length
        local len = b2 & 0x7F
        if len == 126 then
            bytes, err = con:receive(2)
            if err then return nil end
            len = sunpack(">I2", bytes)
        elseif len == 127 then
            bytes, err = con:receive(8)
            if err then return nil end
            len = sunpack(">I8", bytes)
        end
        
        -- Get masking key
        local mask_key, err = con:receive(4)
        if err then return nil end
        
        -- Read the payload
        local payload, err = con:receive(len)
        if err then return nil end
        
        -- Unmask the payload
        if mask == 1 then
            payload = xor_cipher32(payload, mask_key)
        end
            
        -- Return frame data
        return fin, op, mask, mask_key, payload
    end
    
    -- Identify connections with data available
    local ready = socket.select(self.connections, nil, 0)
    
    -- Process connections with data available
    for _,con in ipairs(ready) do
        local client = self.clients[con]
        local fin, op, mask, mask_key, payload
        
        -- Check the socket is still connected
        local _, err = con:receive(0)
        if err == "closed" then
            client.open = false
            self.clients[con] = nil
            -- Remove from connections list
            for i,c in ipairs(self.connections) do
                if c == con then
                    table.remove(self.connections, i)
                end
            end
            goto continue
        end
        
        -- Keep reading message frames until the message is complete
        while true do
            -- Get next frame
            fin, op, mask, mask_key, payload = receive_frame(con)
            if fin == nil then goto continue end
            
            -- Add the new payload data
            tinsert(client.buffers, payload)
            
            -- Is the message complete?
            if fin then break end
        end
        
        -- Get the full message and clear the payloads list
        local message = tconcat(client.buffers)
        client.buffers = {}
        
        -- Check for a PING op
        if op == 0x9 then
            -- Reply with PONG
            print("PING -> PONG")
            con:send(create_frame(message, 0xA))
        else
            -- Pass our message on to the handler
            client:on_message(message)
        end     
            
        ::continue::
    end
end

end
------------------------------
-- WebSocketClient.lua
------------------------------
do
local socket = require("socket")

local slen = string.len
local schar = string.char
local spack = string.pack
local tinsert = table.insert
local tconcat = table.concat

-- NOTE: All created frames are unmasked
local function create_frame(msg, op)
    -- Default to TEXT opcode
    op = op or 1
    
    local parts = {}
    tinsert(parts, schar(0x80 | op))
    
    -- Add the payload length
    local len = slen(msg)
    if len > 65535 then -- 64 bit len
        tinsert(parts, schar(0x7F))
        tinsert(parts, spack(">I8", len))
    elseif len > 125 then -- 16 bit len
        tinsert(parts, schar(0x7E))
        tinsert(parts, spack(">I2", len))
    else -- 7 bit len
        tinsert(parts, schar(len))
    end
    
    -- Add message
    tinsert(parts, msg)
    
    -- Combine all parts
    return tconcat(parts)
end

WebSocketClient = class()
function WebSocketClient:init(connection)
    self.connection = connection
    self.buffers = {}
    self.open = true
    
    -- Uncomment to verify connection is being
    -- freed when closed
    --
    --getmetatable(self).__gc = function(self)
    --    print("delete handle", self)
    --end
end

function WebSocketClient:send(msg, is_binary)
    if self.open then -- Ignore if the connection is closed
        self.connection:send(create_frame(msg, (is_binary and 2) or nil))
    end
end

function WebSocketClient:is_open()
    return self.open
end

-- Default callbacks
function WebSocketClient:on_message(msg)
end




-- WebSocketClientGroup
--
-- Simplifies message broadcasting
WebSocketClientGroup = class()
function WebSocketClientGroup:init()
    self.group = {}
    self.num = 0
end

function WebSocketClientGroup:add(client)
    self.num = self.num + 1
    self.group[client] = client
end

function WebSocketClientGroup:remove(client)
    assert(self.group[client] ~= nil)
    
    self.num = self.num - 1
    self.group[client] = nil
end

function WebSocketClientGroup:broadcast(msg, is_binary)
    local frame = create_frame(msg, (is_binary and 2) or nil)
    for _,client in pairs(self.group) do
        if client.open then
            client.connection:send(frame)
        else
            -- Remove disconnected client
            self.group[client] = nil
            self.num = self.num - 1
        end
    end
end

function WebSocketClientGroup:size()
    return self.num
end


end
------------------------------
-- TweenMod.lua
------------------------------
do
-- This Tween 'mod' modifies the local finishTween
-- function from the tween source to stop the tween
-- before executing the callback.
--
-- This allows the restart of a tween from inside the callback
-- and avoids having to recreate one after every callback
-- which led to excess memory consumption.





-- tween.update uses finishTween as an upvalue so this is
-- our way in.
local nups = debug.getinfo(tween.update, "u").nups

-- Find the finishTween upvalue
local finishTweenOrig = nil
local upvalueIndexToOverride = nil
for i=1,nups do
    local name, val = debug.getupvalue(tween.update, i)
    if name == "finishTween" then
        upvalueIndexToOverride = i
        finishTweenOrig = val
        break
    end
end

-- Get all of the upvalues from the original function
local upvalues = {}
for i=1,debug.getinfo(finishTweenOrig, "u").nups do
    local name, val = debug.getupvalue(finishTweenOrig, i)
    upvalues[name] = val
end

-- Get all the upvalues we need to override the function
local easeWithTween = assert(upvalues["easeWithTween"])
local copyTable = assert(upvalues["copyTables"])
local tweens = assert(upvalues["tweens"])

-- Define our override
-- This will use the same upvalues as the original
local function finishTweenNew(self)
    self.overshoot = self.running - self.time
    self.running = self.time
    easeWithTween(self, self.subject, self.target, self.initial)
    
    -- Stop BEFORE we execute the callback
    tween.stop(self)
    
    if self.callback then self.callback(table.unpack(self.args)) end

    if self.next then
        self.next.initial = copyTables(self.next.initial, self.target, self.subject)
        tweens[self.next] = self.next
    end
end

debug.setupvalue(tween.update, upvalueIndexToOverride, finishTweenNew)

-- Executes a function every 'period' seconds
-- 
-- Period is not accurate & is bound to frame
-- rate. The callback will be called a maximum
-- of once per frame.
--
-- If for instance your period is equivalent
-- to 1.5x framerate, when the period elapses
-- mid-frame the callback will not be executed
-- until the following frame.
function tween.interval(period, callback)
    local loop = tween.delay(period)
    loop.callback = function()
        
        -- Call the interval callback
        callback()
        
        -- Execute as accurately as we can
        -- so account for any overshoot of timing
        -- in the current invocation
        loop.time = math.max(0.0000001, period - loop.overshoot)
            
        -- Restart our tween
        tween.reset(loop)
        tween.play(loop)
    end
end

-- Original Function
--[[
local function finishTween(self)
    self.running = self.time
    easeWithTween(self, self.subject, self.target, self.initial)
    if self.callback then self.callback(table.unpack(self.args)) end

    tween.stop(self)

    if self.next then
        self.next.initial = copyTables(self.next.initial, self.target, self.subject)
        tweens[self.next] = self.next
    end
end
]]
end
