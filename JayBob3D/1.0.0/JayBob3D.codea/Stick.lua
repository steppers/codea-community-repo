--# Stick
--

Stick = class()

function Stick:init(ratio,x,y)
    self.ratio = ratio or 1
    self.i = vec2(x or 120,y or 120)-- initial pos
    self.v = vec2(0,0) -- stick pos relative to initial pos
    self.b = b or 180  -- base diameter
    self.s = s or 100  -- stick diameter
    self.d = d or 50  -- dead zone diameter
    self.a = 0         -- stick angle relative to initial pos
    self.touchId = nil
    self.x,self.y = 0,0
end

function Stick:draw()

    if touches[self.touchId] == nil then
        for i,t in pairs(touches) do
            if vec2(t.x,t.y):dist(self.i) < self.b/2 then self.touchId = i end
        end
        self.v = vec2(0,0)
    else
        self.v = vec2(touches[self.touchId].x,touches[self.touchId].y) - self.i
        self.a = math.deg(math.atan2(self.v.y,self.v.x))
    end
    self.t = math.min(self.b/2,self.v:len())
    if self.t >= self.b/2 then
        self.v = vec2(math.cos(math.rad(self.a))*self.b/2,math.sin(math.rad(self.a))*self.b/2)
    end

    fill(127, 127, 127, 150)
    ellipse(self.i.x,self.i.y,self.b)
    ellipse(self.i.x+self.v.x,self.i.y+self.v.y,self.s)

    self.v = self.v/(self.b/2)*self.ratio
    self.t = self.t/(self.b/2)*self.ratio
    self.x,self.y = self.v.x,self.v.y

end

