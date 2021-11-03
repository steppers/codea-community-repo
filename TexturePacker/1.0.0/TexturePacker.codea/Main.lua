-- TexturePacker

local inset = 30

local selectionHeight = HEIGHT*0.75 - inset*2
local selectionRect = Rect(
    inset,
    HEIGHT - inset - selectionHeight,
    WIDTH - (inset * 2),
    selectionHeight
)
local selCols = 4

local packBtn = Rect(
    inset,
    inset,
    WIDTH - (inset * 2),
    HEIGHT * 0.25
)
local packBtnHighlight = false

local scroll = 0
local scrollVelocity = 0
local scrollMax = 0
local scrolling = false

local thumbnailSize = 0

local pngs = {}
local selected = {}

local packedSize = 512
local packed = nil

local function detectTextures()
    local docs = asset.documents.all
    
    local len = #pngs
    for i = len, 1, -1 do
        table.remove(pngs)
    end
    
    for _,v in pairs(docs) do
        if string.find(v.path, "@2x%.png") == nil and (string.find(v.path, "%.png") ~= nil) or (string.find(v.path, "%.PNG") ~= nil) then
            table.insert(pngs, v)
            table.insert(selected, false)
        end
    end
end

local function packSelected()
    packed = PackedTexture("atlas", packedSize, 1)
    
    local sorted = {}
    for i,sel in ipairs(selected) do
        if sel then
            table.insert(sorted, pngs[i])
        end
    end
    
    -- Largest width textures first
    table.sort(sorted, function(l, r)
        local lx, _ = spriteSize(l)
        local rx, _ = spriteSize(r)
        return rx < lx
    end)
    
    for _,v in ipairs(sorted) do
        local name = string.sub(v.name, 1, -5)
        packed:pack(v, name)
    end
end

local function savePacked()
    if packed == nil then
        packed = PackedTexture("atlas", packedSize, 1)
    end
    packed:save(true) -- Save to docs
    detectTextures()
    
    -- HACK!!!
    viewer.restart()
end

function setup()
    viewer.mode = FULLSCREEN
    
    parameter.text("Atlas Size", "512", function(v)
        v = tonumber(v)
        if v == nil then -- ignore, use prev
            return
        end
        packedSize = v
        packed = PackedTexture("atlas", v, 1)
        packSelected()
    end)

    packed = PackedTexture("atlas", packedSize, 1)
    detectTextures()
    
    thumbnailSize = (WIDTH - inset*2) / selCols
    scrollMax = (math.ceil(#pngs / selCols) * thumbnailSize) - selectionHeight
    
    selected = Array(#pngs, function() return true end)
    packSelected()
    
    noSmooth()
    spriteMode(CORNER)
end

local function update(dt)
    if scrolling == false and math.abs(scrollVelocity) > 1 then
        scroll = scroll + scrollVelocity*dt
        local decel = scrollVelocity * 3
        scrollVelocity = scrollVelocity - (decel * dt)
    end
    
    scroll = math.max(math.min(scroll, scrollMax), 0)
end

local function drawSelector()
    clip(selectionRect.xmin, selectionRect.ymin, selectionRect.width, selectionRect.height)
    
    noFill()
    stroke(0, 143, 255, 192)
    strokeWidth(3)
    
    local rowMax = math.ceil(#pngs / selCols)
    local rowStart = math.floor(scroll / thumbnailSize)
    local rowEnd = math.min(rowMax, rowStart + 1 + math.ceil(selectionRect.height / thumbnailSize))
    
    local x = selectionRect.xmin
    local y = selectionRect.ymax - thumbnailSize + (scroll % thumbnailSize)
    
    local col = 0
    local istart = 1 + (rowStart * selCols)
    local iend = math.min(rowEnd * selCols, #pngs)
    
    for i = istart, iend do
        local w, h = spriteSize(pngs[i])
        local ar = w / h
        
        local rx = x
        local ry = y
        local renderSize = thumbnailSize
        
        if ar < 1 then
            renderSize = renderSize * ar
            rx = rx + (thumbnailSize - renderSize) / 2
        end
        
        if ar > 1 then
            ry = ry + (thumbnailSize - (thumbnailSize * (1/ar))) / 2
        end
        
        sprite(pngs[i], rx, ry, renderSize)
        
        if selected[i] then
            rect(x, y, thumbnailSize, thumbnailSize)
        end
        
        col = col + 1
        x = x + thumbnailSize
        if col == selCols then
            col = 0
            x = inset
            y = y - thumbnailSize
        end
    end
    
    clip()
end

local function drawPackButton()
    if packBtnHighlight then
        fill(0, 180, 255)
        stroke(255)
    else
        fill(0, 91, 255)
        stroke(0, 147, 255)
    end
    rect(packBtn.xmin, packBtn.ymin, packBtn.width, packBtn.height)
    
    fill(255)
    text("Save to 'atlas.png' (will overwrite!)", WIDTH/2, packBtn.ymax - 15)
    
    local imgSize = (packBtn.height - 15) * 0.9
    local c = packBtn:center()
    sprite(packed.img, c.x - imgSize/2, (c.y - 7.5) - imgSize/2, imgSize, imgSize)
end

function draw()
    update(DeltaTime)
    
    -- Render
    background(0)
    drawSelector()
    drawPackButton()
end

-- Gesture Handlers
function pan(pos, delta, state)
    if state == BEGAN then
        if selectionRect:contains(pos) then
            scrolling = true
        end
    elseif state == CHANGED then
        if scrolling then
            scrollVelocity = (1 / DeltaTime) * delta.y
        end
    elseif state == ENDED then
        if scrolling then
            scrolling = false
        end
    end
    
    if scrolling then
        scroll = scroll + delta.y
    end
end

function tap(pos)
    -- Update Selection
    if selectionRect:contains(pos) then
        pos = selectionRect:transform(pos)
        
        local row = math.floor((scroll + (selectionHeight - pos.y)) / thumbnailSize) 
        local col = math.floor(pos.x / thumbnailSize)
        local index = 1 + col + (row * selCols)
        selected[index] = not selected[index]
        
        print(pngs[index].name)
        
        packSelected()
        
    elseif packBtn:contains(pos) then
        savePacked()
    end
end

function touchDown(id, pos)
    if packBtn:contains(pos) then
        packBtnHighlight = true
    end
end

function touchUp(id, pos)
    packBtnHighlight = false
end
