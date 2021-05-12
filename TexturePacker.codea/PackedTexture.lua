-- PackedTexture

-- Read a packed Texture from project local assets like so
-- spriteSheet = PackedTexture("my_spritesheet")
-- my_sprite = spriteSheet:get("dog")

PackedTexture = class()

local function GetOffset(packer, width, height)
    if (width > packer.size) or
    (height > packer.size) or
    (width*height > packer.freePixels) then
        return -- Unable to pack
    end
    
    local besty = packer.size
    local bestx = packer.size
    
    for x = packer.size, width, -1 do
        
        local valid = true
        local y = packer.colPixels[x]
        for tx = x, x-width+1, -1 do
            if packer.colPixels[tx] > y then
                valid = false
                break
            end
        end
        
        if valid and y < besty then
            besty = y
            bestx = x - width + 1
        end
        
    end
    
    -- Best y wasn't good enough
    if (besty + height) > packer.size then
        return
    end
    
    -- Update values
    local newy = besty + height
    for x = bestx, bestx + width - 1 do
        packer.colPixels[x] = newy
    end
    packer.freePixels = packer.freePixels - (width * height)
    
    -- Return valid offset
    return bestx, besty + 1
end

-- Initialise with a project file (no documents)
-- If size is specified then a new texture will
-- be initialised. If nil, we will load from the
-- specified file.
function PackedTexture:init(name, size, padding)
    self.pngAsset = asset .. name .. ".png"
    self.jsonAsset = asset .. name .. ".json"
    self.name = name
    
    if size == nil then -- Load
        local meta = readText(self.jsonAsset)
        if meta then
            self.packed = json.decode(meta)
            self.canPack = true
        else
            print("[ERROR] Failed to open texture pack '" .. name .. "'")
        end
    else -- New Pack
        self.size = size
        self.img = image(size, size)
        self.packed = {}
        
        self.canPack = true
        self.freePixels = size * size
        self.colPixels = Array(size, function() return 0 end) -- used pixels
        self.padding = padding or 1
    end
end

-- Gets a texture from the packed texture
function PackedTexture:get(texId)
    local uvs = self.packed[texId]
    return self.pngAsset:copy(uvs.u, uvs.v, uvs.w, uvs.h) 
end

function PackedTexture:pack(texAsset, as)
    if not self.canPack then
        return false
    end
    
    if self.packed[as] ~= nil then
        return true
    end
    
    local img = readImage(texAsset)
    
    local w = img.width
    local h = img.height
    
    local xdst, ydst = GetOffset(self, w + self.padding*2, h + self.padding*2)
    if xdst == nil then
        return false
    end
    
    xdst = xdst + self.padding
    ydst = ydst + self.padding
    
    -- Copy
    for y = 1, img.height do
        for x = 1, img.width do
            local r,g,b,a = img:get(x, y)
            self.img:set(x + xdst - 1, y + ydst - 1, r, g, b, a)
        end
    end
    
    -- Add Metadata
    self.packed[as] = {
        u = (xdst - 1),
        v = (ydst - 1),
        w = (w - 1),
        h = (h - 1)
    }
    
    return true
end

function PackedTexture:save(toDocs)
    if self.canPack then
        local meta = json.encode(self.packed, {indent = true})
        if toDocs then
            saveImage(asset.documents .. self.name .. ".png", self.img)
            saveText(asset.documents .. self.name .. ".json", meta)
        else
            saveImage(self.pngAsset, self.img)
            saveText(self.jsonAsset, meta)
        end
    end
end
