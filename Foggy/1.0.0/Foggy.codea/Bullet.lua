Bullet = class()

function Bullet:init(x,y,a,e,pow,spd)
    self.x = x
    self.y=y
    self.active=1
    self.angle=a
    self.kind=e --0 is player, 1 is vanilla enemy, 2 is mega bullet
    self.power=pow
    self.rot=math.random(360)
    self.rotspd= math.random(8)/2
    self.yacc=0
    self.age=0
    if e==4 then self.yacc=-7 end
    self.spd=spd
end

function Bullet:draw()
    self.age = self.age + 1
    pushMatrix()
    translate(self.x,self.y)
    rotate(-self.angle)
    if self.kind==0 then      
        sprite(spriteTable[61],0,10,50,50) --bullet 1
        self.x = self.x + 15*math.sin(math.rad(self.angle+90))
        self.y = self.y + 15*math.cos(math.rad(self.angle+90))
        self.rot = self.rot -self.rotspd      
    elseif self.kind==1 then
        rotate(self.rot)
        local ebc=math.fmod(math.floor(ElapsedTime*20),4)+1
        local ebIndexes = {91,90,80,81} --indexes of 4 enemy bullet sprites
        sprite(spriteTable[ebIndexes[ebc]],0,0,31,31)
        rotate(-self.rot)
        noTint()
        self.x = self.x + 8*math.sin(math.rad(self.angle+90))
        self.y = self.y + 8*math.cos(math.rad(self.angle+90))     
    elseif self.kind==2 then
        tint(255,180)
        sprite(spriteTable[79],0,0,30+self.power*2) --player bullet?
        noTint()
        self.x = self.x + 15*math.sin(math.rad(self.angle+90))
        self.y = self.y + 15*math.cos(math.rad(self.angle+90))
        self.rot = self.rot -2      
    elseif self.kind==3 or self.kind==4 then
        self.y = self.y - self.yacc
        self.yacc = self.yacc + 0.2
        self.x = self.x + self.spd
        self.angle=-90+math.deg(math.atan(self.yacc,self.spd))
        sprite(spriteTable[18],0,0,20,20) --bomb
    end
    popMatrix()
    
    if self.x>WIDTH+100 or self.x<-100 or self.y<-100 or self.y>HEIGHT+100 then self.active=0 end
     
end