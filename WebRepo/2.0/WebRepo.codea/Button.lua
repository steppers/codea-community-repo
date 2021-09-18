Button = class()

function Button:init(str, x, y, w, h, col, txt_col)
    self.str = str
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    self.col = col
    self.txt_col = txt_col
end

function Button:reinit(x, y, w, h)
    self.x = x
    self.y = y
    self.w = w
    self.h = h    
end

function Button:draw()
    strokeWidth(self.h)
    stroke(255)
    local y = self.y + self.h/2
    local x1 = self.x + self.h/2
    local x2 = self.x + self.w - self.h/2
    line(x1, y, x2, y)
    strokeWidth(self.h - 4)
    stroke(self.col)
    line(x1, y, x2, y)
        
    fill(self.txt_col or 0)
    textMode(CENTER)
    text(self.str, (x2 + x1)/2, y)
end

function Button:tap(pos)
    if  pos.x >= self.x and pos.x <= self.x + self.w and
        pos.y >= self.y and pos.y <= self.y + self.h then
        return true
    end
    
    return false
end
