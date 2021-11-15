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

