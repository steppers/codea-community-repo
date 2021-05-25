Loader = class()

function Loader:init()
    self.loaded = 0
    
    self.loading = nil
    
    self.doneLoading = false
    
    self.onEnterTime = 0
    
    self.colour = color(0, 133, 255, 255)
    
    self.circSize = (WIDTH / 3)*2 + 40
    
    self.displayErrorMessage = false
    
    self.queue = {}
    
    self:onEnter()
end

function Loader:onEnter()
    self.loaded = 0
    
    self.loading = nil
    
    self.doneLoading = false
    
    self.changing = nil
    
    self.onEnterTime = ElapsedTime
    
    self.displayErrorMessage = false
    
    self.queue = {}
    
    self:loadImages()
end

function Loader:loadImages()
    for id, stuff in ipairs(ImagesToLoad) do
        if readImage(stuff.spriteKey) == nil then
            self:addToQueue(stuff)
        else
            self.loaded = self.loaded + 1
        end
    end
    
    self:checkQueue()
end

function Loader:addToQueue(stuff)
    table.insert(self.queue, stuff)
    
    self:checkQueue()
end  

function Loader:checkQueue()
    if self.loaded == #ImagesToLoad then
        self.doneLoading = true
    end
    
    for id, stuff in ipairs(self.queue) do
        if id == 1 and self.loading == nil then
            self:load(stuff)
            self.loading = "busy"
            table.remove(self.queue, id)
        end
    end
end

function Loader:load(stuff)
    local saveThenNext = function(img)
        saveImage(stuff.spriteKey, img)
        
        self.loaded = self.loaded + 1
        self.loading = nil
        
        self:checkQueue()
    end
    
    --[[local getActualUrl = function(data)
        local check = '<meta content="Shared with Dropbox" property="og:description" /><meta content="(.*)" property="og:image" />'
        --local a, b = data:find(';\nShmodelPreview.init_photo("', 1, true)
        --local c, d = data:find('", ', b, true)
        --local acUrl = data:sub(b+1, c-1)
        local acUrl = data:match(check)
        
        http.request(acUrl, saveThenNext, function() self:failed() end)
    end]]
    
    http.request(stuff.url, saveThenNext, function() self:failed() end)
end

function Loader:failed()
    self.displayErrorMessage = true
end

function Loader:draw()
    background(255)
    
    if self.displayErrorMessage == false then
        pushStyle()
        stroke(self.colour) noFill() strokeWidth(1)
        ellipse(WIDTH/2, HEIGHT/2, self.circSize)
    
        font("HelveticaNeue-Light") fontSize(35)
        fill(self.colour)
        text("Loading", WIDTH/2, fontSize())

        for i = 1, #ImagesToLoad do
            stroke(self.colour) strokeWidth(2)
            noFill()
            if self.loaded >= i then
                fill(self.colour)
            end
            
            local perRow = 6
            local spacing, size = 50, 25
            local rows = math.ceil(#ImagesToLoad / perRow)
            local row = math.ceil(i / perRow)
            local off = rows / 2
            local startY = HEIGHT/2 + off * size + off * spacing
            local y = startY - size * (row-0.5) - spacing * (row-0.5)
            local inRow = i - ((row-1) * perRow)
            local startX = WIDTH/2 - (perRow/2 * size) - (perRow/2 * spacing)
            local x = startX + size * (inRow-0.5) + spacing * (inRow-0.5)
            
            ellipse(x, y, size)
        end
        popStyle()
    else
        font(STANDARDFONT) fontSize(35)
        fill(38, 38, 38, 255) textAlign(CENTER)
        text("An Error Occured. Please Check\nYour Internet And Reload Codea.", WIDTH/2, HEIGHT/2)
    end
end

function Loader:touched(touch)
    -- Codea does not automatically call this method
end


