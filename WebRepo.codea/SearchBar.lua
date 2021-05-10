SearchBar = class()

function SearchBar:init(x)
    self.typing = false
    self.buffer = "Search"
    self.buffer_selected = false
end

function SearchBar:draw(y, w, h)
    pushStyle()
    
    -- Draw background
    fill(96)
    rectMode(CORNER)
    rect(0, y, WIDTH, h + 1)
    
    y = y + 6
    h = h - 12
    
    y = y + h/2
    
    -- Draw box
    strokeWidth(h)
    stroke(212)
    local half_w = (w - h)/2
    line(WIDTH/2 - half_w, y, WIDTH/2 + half_w, y)
    
    -- Draw text
    fontSize(24)
    if not self.buffer_selected then
        fill(128)
    else
        fill(32)        
    end
    
    textMode(CENTER)
    text(self.buffer, WIDTH/2, y)
    
    popStyle()
end

function SearchBar:select(enable)
    self.typing = enable
    
    -- Display the keyboard if necessary
    if self.typing then
        showKeyboard()
        self.buffer_selected = true
    else
        hideKeyboard()
        if string.len(self.buffer) == 0 then
            self.buffer = "Search"
        end
        self.buffer_selected = false
    end
end

function SearchBar:keyboard(key)
    self.typing = true
    
    if self.buffer == "Search" then
        self.buffer = ""
    end
    
    if string.len(self.buffer) > 0 and key == BACKSPACE then
        self.buffer = string.sub(self.buffer, 1, -2)
    else
        self.buffer = self.buffer .. key
    end
    
    if string.len(self.buffer) == 0 then
        self.buffer = "Search"
    end
end
