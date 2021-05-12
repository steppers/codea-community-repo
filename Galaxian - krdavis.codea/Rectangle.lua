-----------------
--  Galaxian   --
-----------------

-- Keith Davis --
--  (c) 2021   --
--  ZuniSoft   --

Rectangle = class()

function Rectangle:init(x, y, w, h)
    -- you can accept and set parameters here
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    return self
end

function Rectangle:intersects(r)
    return self.x < r.x + r.w and r.x < self.x + self.w and self.y < r.y + r.h and r.y < self.y + self.h
end
