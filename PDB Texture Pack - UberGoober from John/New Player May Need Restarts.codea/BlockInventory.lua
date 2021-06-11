-- BlockInventory
-- A basic inventory class for viewing and selecting block types.

BlockInventory = class()

function BlockInventory:init(rows, cols, itemCallback)
    self.gridRows = rows or 8
    self.gridCols = cols or 8
    self.gridSize = 64
    self.border = 5
    self.spacing = 5
    
    local w,h =
    self.gridCols * self.gridSize + self.border * 2 + (self.gridCols-1) * self.spacing,
    self.gridRows * self.gridSize + self.border * 2 + (self.gridRows-1) * self.spacing
    
    self.panel = ui.panel
    {
        anchor = vec2(0.5, 1.0),
        pivot = vec2(0.5, 0.0),
        w = w,
        h = h,
        align = {h = ui.CENTER, v = ui.TOP},
        bg = "UI:Grey Panel",
        inset = 10,
    }
    
    self.panel.cornerRadius = 5
    
    self.title = ui.label
    {
        text = "",
        fontSize = 30,
        w = 200,
        h = 25,
        pivot = vec2(0.5,0),
        align = {h = ui.CENTER, v = ui.TOP}
    }
    self.panel:addChild(self.title)
    self.title.anchor = vec2(0.5,1.0)
    
    self.itemCallback = itemCallback
    
    self.slots = {}
    for y = 1,self.gridRows do
        for x = 1,self.gridCols do
            local button = self:slotButton(x,self.gridRows+1-y)
            local slot = {button = button}
            slot.index = #self.slots+1
            
            slot.button.onPressed = function(b)
                if self.itemCallback then
                    self.itemCallback(self, slot)
                end
            end
            
            table.insert(self.slots, slot)
        end
    end
end

function BlockInventory:save(name)
    local data = {}
    data.selected = self.selected and self.selected.index
    data.slots = {}
    for k,v in pairs(self.slots) do
        local slot = {}
        if v.block then
            slot.block = v.block.name
        end
        table.insert(data.slots, slot)
    end
    print(json.encode(data))
    saveText(name, json.encode(data) )
end

function BlockInventory:load(name)
    local txt = readText(name)
    if txt then
        local data = json.decode(txt)
        local selected = data.selected
        for k,v in pairs(self.slots) do
            local blockName = data.slots[v.index].block
            if blockName then
                self:setBlock(v.index, scene.voxels.blocks:get(blockName))
                if v.index == selected then
                    self:setSelected(v)
                end
            end
        end
    end
end

function BlockInventory:open()
    
end

function BlockInventory:close()
    
end

function BlockInventory:getSlot(i)
    return self.slots[i]
end

function BlockInventory:slotCount()
    return #self.slots
end

function BlockInventory:setSelected(slot)
    if self.selected then
        self.selected.button.selected = false
    end
    self.selected = slot
    if self.selected then
        self.selected.button.selected = true
    end
end

function BlockInventory:getSelected()
    return self.selected
end


-- Add item to next empty slot
function BlockInventory:addBlock(block)
    for k,v in pairs(self.slots) do
        if v.block == nil then
            self:setBlock(v.index, block)
            return true
        end
    end
    return false
end

-- Set item for a specific slot
function BlockInventory:setBlock(index, block)
    local slot = self.slots[index]
    
    if block then
        slot.block = block
        if block.hasIcon then
            slot.button.icon.img = block.icon
            slot.button.label.text = ""
        else
            slot.button.icon.img = nil
            slot.button.label.text = block.longName or block.name
        end
    end
    
end

-- Create a new slot button
function BlockInventory:slotButton(x,y)
    local button = ui.button
    {
        x = self.border + self.gridSize * (x-1) + self.spacing * (x-1),
        y = self.border + self.gridSize * (y-1) + self.spacing * (y-1),
        w = self.gridSize,
        h = self.gridSize,
        normalBg = readImage(asset.builtin.UI.Grey_Panel),
        normalFill = color(127, 127, 127, 255),
        selectedBg = readImage(asset.builtin.UI.Blue_Panel),
        selectedFill = color(255, 255, 255, 255)
        --selectedBg = readImage()
        --bg = "Documents:grey_button11",
        --normalFill = color(79, 79, 79, 255)
    }
    button.icon = ui.image({x = 5, y = 5, w = self.gridSize-10, h = self.gridSize-10})
    button:addChild(button.icon)
    button.unselectedFill = color(255, 255, 255, 255)
    button.selectedFill = color(199, 199, 199, 255)
    button.opaque = false
    
    self.panel:addChild(button)
    return button
end

function BlockInventory:draw()
    self.panel:update()
    self.panel:draw()
end
