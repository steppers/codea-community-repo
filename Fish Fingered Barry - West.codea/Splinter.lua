Splinter = class()

function Splinter:init(x,y)
    -- you can accept and set parameters here
    self.x = x
    self.y=y
    self.active=1
    self.ang=0
    self.rotspd=-4+math.random(9)
    self.dir=-90+math.random(180)
    self.xspd=-5+math.random(9)
    self.yspd=math.random(10)
end

function Splinter:draw()
    -- Codea does not automatically call this method
    self.ang = self.ang + self.rotspd
    self.x = self.x + self.xspd
    self.y = self.y + self.yspd
    self.yspd = self.yspd - 0.2
    pushMatrix()
    translate(self.x,self.y)
    rotate(self.ang)
    sprite("Project:splinter",0,0)
    popMatrix()
end

function Splinter:touched(touch)
    -- Codea does not automatically call this method
end
