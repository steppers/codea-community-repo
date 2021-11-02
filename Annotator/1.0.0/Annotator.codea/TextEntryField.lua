TextEntryField = class()

function TextEntryField:init(x, y, width, height, default_text, font_size, resizeable)
    self.typing = false
    self.default_text = default_text
    self.buffer = default_text
    self.buffer_selected = false
    
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    
    self.current_x = x
    self.current_width = width
    
    self.font_size = font_size or 24
    self.resizeable = resizeable or false
end

function TextEntryField:draw()
    pushStyle()
    
    fontSize(self.font_size)
    textMode(CENTER)
    
    -- Default width & pos
    self.current_x = self.x
    self.current_width = self.width
    
    -- Draw box
    strokeWidth(self.height)
    stroke(212)
    local offset = self.height/2
    
    -- Determine if the box should auto resize to fit text
    local tw = textSize(self.buffer)
    local resize = tw > self.width - offset*2 and self.resizeable
    
    if resize then
        
        -- Draw the entry field
        local mid = self.x + self.width/2
        line(mid - tw/2, self.y + offset, mid + tw/2, self.y + offset)
        
        -- Save the adjusted width
        self.current_width = tw + offset*2
        self.current_x = mid - tw/2 - offset
    else
        line(self.x + offset, self.y + offset, self.x + self.width - offset, self.y + offset)
    end
    
    -- Draw text
    if not self.buffer_selected then
        fill(128)
    else
        fill(32)        
    end
    text(self.buffer, self.x + self.width/2, self.y + self.height/2) 
        
    popStyle()
end

function TextEntryField:tap(pos)
    
    -- Show keyboard
    if  pos.x >= self.current_x and pos.x <= self.current_x + self.current_width and
        pos.y >= self.y and pos.y <= self.y + self.height and
        not self.typing then
        
        showKeyboard()
        self.buffer_selected = true
        self.typing = true
        return true
        
    -- Hide keyboard
    elseif self.typing then
        self.typing = false
        hideKeyboard()
        if string.len(self.buffer) == 0 then
            self.buffer = self.default_text
        end
        self.buffer_selected = false
    end
    
    return false
end

function TextEntryField:keyboard(key)
    if not self.typing then
        return false
    end
    
    if self.buffer == self.default_text then
        self.buffer = ""
    end
    
    if string.len(self.buffer) > 0 and key == BACKSPACE then
        self.buffer = string.sub(self.buffer, 1, -2)
    else
        self.buffer = self.buffer .. key
    end
    
    if string.len(self.buffer) == 0 then
        self.buffer = self.default_text
    end
    
    return true
end
