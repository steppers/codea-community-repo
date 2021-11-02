Bubble = class()

function Bubble:init(x,y,sc)
    -- you can accept and set parameters here
    self.x = x
    self.y=y
    self.size=(10+math.random(10))*sc
    self.wobblerate=(10+math.random(10))*sc
    self.wobblemag=math.random(5)*sc
    self.wobbleoff=0
    self.rate=2*sc
    self.active=1
end

function Bubble:draw()
    -- Codea does not automatically call this method
    wobble=self.wobblemag+math.sin((ElapsedTime+self.wobbleoff)*self.wobblerate)
    sprite("Project:bubble",self.x+wobble,self.y,self.size)
    self.y=self.y+self.rate
    if self.y>HEIGHT+100 then self.active=0 end
end

function Bubble:touched(touch)
    -- Codea does not automatically call this method
end
