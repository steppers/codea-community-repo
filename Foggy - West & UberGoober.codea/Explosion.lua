Explosion = class()

function Explosion:init(x,y,r,s)
    -- you can accept and set parameters here
    self.x = x
    self.y=y
    self.rot=r
    self.size=s
    self.counter=0
    self.active=1
end

function Explosion:draw()
    -- Codea does not automatically call this method
        self.counter = self.counter + 0.4
        local c=math.fmod(math.floor(self.counter),8)+1
        pushMatrix()
        translate(self.x,self.y)
        rotate(self.rot)
    --sprite(boom[c],0,0,60*self.size,40*self.size)
    local boomindexes = {54,55,62,63,64,65,66,65}
    sprite(spriteTable[boomindexes[c]],0,0,60*self.size,40*self.size)
        popMatrix()    
    if c>7 then self.active=0 end
    
end

function Explosion:touched(touch)
    -- Codea does not automatically call this method
end
