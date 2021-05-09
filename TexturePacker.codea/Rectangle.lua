-- Rectangle

Rect = class()

function Rect:init(x, y, width, height)
    self.xmin = x
    self.ymin = y
    self.xmax = x + width
    self.ymax = y + height
    self.width = width
    self.height = height
end

function Rect:contains(pos)
    return pos.x >= self.xmin and pos.y >= self.ymin and pos.x <= self.xmax and pos.y <= self.ymax
end

function Rect:transform(pos)
    return vec2(pos.x - self.xmin, pos.y - self.ymin)
end

function Rect:center()
    return vec2(self.xmin + self.width/2, self.ymin + self.height/2)
end
