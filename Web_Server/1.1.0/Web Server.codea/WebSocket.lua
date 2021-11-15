local socket = require("socket")
local mime = require("mime")

local sha1_binary = sha1.binary
local mime_b64 = mime.b64

local slen = string.len
local schar = string.char
local spack = string.pack
local sunpack = string.pack
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
