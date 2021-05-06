Particle = class()
--Class to deal with individual particles.  Used for the starburst and raindrops
function Particle:init(x,y,xspd,yspd,type,fade)    
    -- you can accept and set parameters here
    --map to the position of the 100 by 100 blocks in the sprite sheet.  The location in the array refers to the type of particle
    local map={}
    map[1]={x=0, y=4}--stars
    map[2]={x=2, y=4}--rain
    
    self.type=type --the type of particle
    self.y=y --the x position of the particle
    self.x=x -- the y position of the particle
    self.yspd=yspd --the y speed of the particle
    self.xspd=xspd --the x speed of the particle
    self.size=25+math.random(20) -- the size of the particle
    self.fade=fade --the transparency of the particle
    self.delete=0 -- a flag to determine whether the particle should be deleted
    self.spin=math.rad(-5+math.random(10)) --the rate of rotation of the particle
    self.ang=math.atan2(xspd,yspd)-math.rad(90) --the current angle of the particle
    self.px=map[type].x --the x position in the sprite sheet
    self.py=map[type].y -- the y position in the sprite sheet
end

function Particle:draw()
--shrink the size of the particle
    self.size = self.size -0.1
    self.y = self.y-self.yspd
    if self.type==1 then
    --stars
        self.ang = self.ang + self.spin --rotate the star
        self.fade = self.fade -5
    else
        --rain
        self.ang=math.rad(0)
        self.yspd = self.yspd + 0.1 --apply gravity
    end
    self.x = self.x + self.xspd

    idx=mainmesh:addRect(self.x,self.y,self.size,self.size,self.ang)       
    mainmesh:setRectTex(idx,self.px/cols,self.py/rows,1/cols,1/rows)
    mainmesh:setRectColor(idx,255,255,255,self.fade)    
    if self.fade<10 or self.y<40 then
        self.delete=1 --flag for deletion if the partcle falls below a certain point on the screen or has faded out
    end
end

function Particle:touched(touch)
    -- Codea does not automatically call this method
end

