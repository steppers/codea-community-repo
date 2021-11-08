Zip = class()

function Zip:init(zip_asset, openForWrite)
    self.file = io.open(zip_asset.path, (openForWrite and "wb") or "rb")
    self.cd = {}
    self.prefix = ""
    self.readOnly = not openForWrite
    self.uncompressed_size = 0
    
    -- Load the central directory
    if not openForWrite then
        self.file:seek("end", -22)
        
        -- Read EOCD
        local sig, _, _, numFiles, _, cdSize, cdStart, _ = struct.unpack('<IHHHHIIH', self.file:read(22))
        if sig ~= 0x06054b50 then
            error("Failed to open archive!")
        end
        
        -- Read CD
        self.file:seek("set", cdStart)
        for i = 1, numFiles do
            local sig, _, _, _, _, _, method, _, _, crc, csize, size, nameLen, _, _, _, _, _, offset = struct.unpack('<IBBBBHHHHIIIHHHHHII', self.file:read(46))
            local name = self.file:read(nameLen)
            self.cd[name] = {
                compression = method,
                crc = crc,
                size_compressed = csize,
                size_uncompressed = size,
                offset = offset
            }
        end
    end
end

function Zip:listFiles()
    if not self.readOnly then
        error("Archive is opened writing!")
    end
    
    local files = {}
    for k,_ in pairs(self.cd) do
        table.insert(files, k)
    end
    return files
end

function Zip:readFile(path)
    if not self.readOnly then
        error("Archive is opened writing!")
    end
    
    local entry = self.cd[path]
    
    if entry == nil then
        error("Unable to find " .. path .. " in archive!")
    end
    
    -- Seek to file entry
    self.file:seek("set", entry.offset)
    
    -- Read header
    local sig, _, _, _, method, _, _, crc, csize, size, nameLen, _ = struct.unpack('<IBBHHHHIIIHH', self.file:read(30))
    self.file:seek("cur", nameLen)
    
    -- Read compressed data
    local data = self.file:read(csize)
    
    if method ~= 8 then
        error("Only DEFLATE compression is supported! " .. path)
    end
    
    if crc ~= entry.crc then
        error("local crc doesn't match central directory crc! " .. path)
    end
    
    if data == nil then
        error("Failed to read file data! " .. path)
    end
    
    -- Decompress
    data = LibDeflate:DecompressDeflate(data)
    
    if data == nil then
        error("Failed to decompress data! " .. path)
    end
    
    -- Check the crc to verify data integrity
    if LibDeflate:crc32(data) ~= entry.crc then
        error("crc doesn't match. Data is corrupt! " .. path)
    end
    
    return data
end

function Zip:addFile(file_asset)
    
    if self.readOnly then
        error("Archive is opened read only!")
    end
    
    -- Get the internal zip path
    local path = self.prefix .. file_asset.name
    
    local file = io.open(file_asset.path, "rb")
    local uncompressed = file:read("*a")
    file:close()
    
    local compressed = LibDeflate:CompressDeflate(uncompressed)
    
    self.uncompressed_size = self.uncompressed_size + #uncompressed
    
    local crc32 = LibDeflate:crc32(uncompressed)
    
    local offset = self.file:seek()
    
    local header = struct.pack(
        '<IBBHHHHIIIHHc0',
        0x04034b50, -- signature
        19, 20, -- version to extract
        0, -- general purpose flags
        8, -- compression
        0, 0, -- mod time & date
        crc32, -- uncompressed crc
        #compressed, -- compressed size
        #uncompressed, -- uncompressed size
        #path, -- filename length
        0, -- extra field length
        path -- filename
    )
    
    self.file:write(header)
    self.file:write(compressed)
    
    local cdh = struct.pack(
        '<IBBBBHHHHIIIHHHHHIIc0',
        0x02014b50,
        19, 20,
        19, 20,
        0,
        8,
        0, 0,
        crc32,
        #compressed,
        #uncompressed,
        #path,
        0,
        0,
        0,
        0x0000,
        0,
        offset,
        path
    )
    table.insert(self.cd, cdh)
end

function Zip:addFolder(folder_asset, as)
    
    if self.readOnly then
        error("Archive is opened read only!")
    end
    
    -- Append the folder name to the prefix
    local old_prefix = self.prefix
    self.prefix = self.prefix .. (as or folder_asset.name) .. "/"
    
    local entries = folder_asset.all
    
    for _,e in ipairs(entries) do
        if e.type == "folder" or e.type == "project" then
            self:addFolder(e)
        else
            self:addFile(e)
        end
    end
    
    -- Restore the old prefix
    self.prefix = old_prefix
end

function Zip:close()
    
    if not self.readOnly then
        local cdStart = self.file:seek()
        
        -- Write central directory entries
        for _,cdh in ipairs(self.cd) do
            self.file:write(cdh)
        end
        
        local cdSize = self.file:seek() - cdStart
        
        -- Write EOCD
        local eocd = struct.pack(
            '<IHHHHIIH',
            0x06054b50,
            0,
            0,
            #self.cd,
            #self.cd,
            cdSize,
            cdStart,
            0
        )
        self.file:write(eocd)
    end
    
    -- We're done. Close the archive file
    self.file:close()
end
