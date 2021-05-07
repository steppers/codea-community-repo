Enemy = class()

function Enemy:init(x,y,bonus,path,bug)
    -- TODO: Move hitrad out as a paramter and standardise for the type of enemy
    self.x = x
    self.y=y
    self.wingangle=0
    self.size=70
    self.wingspd=15+math.random(5)
    self.active=1
    self.flash=0
    self.bonus=bonus
    self.path=path
    self.bug=bug
    self.hitrad=50
    self.age=2
    self.spd=1
    self.winglima=11
    self.winglimb=-20
    self.offset=vec2(0,0)
    self.value=10
    self.dir=1
    if self.path==4 then
        self.dir=-1
    end
    if self.bug==SNAIL then
        self.size=300
        self.hitrad=190
        self.offset=vec2(30,-30)
        self.value=500
        self.hp=25
        self.bfreq=75
    elseif self.bug==WASP then
        self.hitrad=50
        self.offset=vec2(10,0)
        self.spd=6
        self.value=50
        self.hp=5
        self.bfreq=100
    elseif self.bug==BLUEBUTTERFLY then
        self.size=58
        self.wingspd=5
        self.winglima=45
        self.winglimb=5
        self.hitrad=65
        self.offset=vec2(30,-10)
        self.spd=4
        self.value=20
        self.hp=2
        self.bfreq=150
    elseif self.bug==YELLOWBUTTERFLY then
        self.size=58
        self.wingspd=5
        self.winglima=45
        self.winglimb=5
        self.hitrad=65
        self.offset=vec2(30,-10)
        self.spd=4
        self.value=20
        self.hp=2
        self.bfreq=100
    elseif self.bug==REDBUTTERFLY then
        self.size=58
        self.wingspd=5
        self.winglima=45
        self.winglimb=5
        self.hitrad=65
        self.offset=vec2(30,-10)
        self.spd=4
        self.value=20
        self.hp=2
        self.bfreq=125
    elseif self.bug==BLACKBUTTERFLY then
        self.size=58
        self.wingspd=5
        self.winglima=45
        self.winglimb=5
        self.hitrad=65
        self.offset=vec2(30,-10)
        self.spd=4
        self.value=20
        self.hp=2
        self.bfreq=75
    elseif self.bug==FLYINGANT then
        self.size=40
        self.hitrad=40
        self.offset=vec2(10,0)
        self.spd=5
        self.value=10
        self.hp=1
        self.bfreq=100
    elseif self.bug==BOSSCAT then
        self.hitrad=120
        self.offset=vec2(-45,-20)
        self.value=2000
        self.hp=1000
        self.bfreq=-1
    elseif self.bug==FLYINGLADY then
        self.size=60
        self.hitrad=50
        self.offset=vec2(0,-5)
        self.spd=5
        self.value=20
        self.hp=3
        self.bfreq=200
    elseif self.bug==LADYBIRD then
        self.value=20
        self.size=50
        self.hp=3
        self.bfreq=60
    elseif self.bug==DRAGONFLY then
        self.value=50
        self.size=100
        self.flap=0
        self.wingspd=5
        self.winglima=20
        self.winglimb=-10
        self.flapspd=5
        self.flaplima=20
        self.flaplimb=-10
        self.hitrad=50
        self.offset=vec2(-55,0)
        self.spd=2
        self.hp=50
        self.bfreq=80
    end
    self.butterflyBodyX = -5
    self.butterflyBodyY = -2
end

function Enemy:draw()
    
    
    self.age = self.age + 1
    if math.fmod(self.age,self.bfreq)==1 then
        --straight ahead
        --  table.insert(ebullets,Bullet(self.x,self.y,180,1))
        --need to choose which to target
        if #bee>0 then
            local targetbee=math.random(#bee)
            local ta=math.deg(math.atan(self.y-bee[targetbee].y,self.x-bee[targetbee].x))+180
            table.insert(ebullets,Bullet(self.x,self.y,-ta,1,1))
        end
    end

    if self.bug==1 then
        pushMatrix()
        translate(self.x,self.y)
        rotate(self.wingangle)
        tint(255,255,255,100)
        
        -- sprite("Project:waspwing",0,0,self.size*1.5*self.dir,self.size*1.5)
        sprite(spriteTable[26],0,0,self.size*1.5*self.dir,self.size*1.5)
        
        noTint()
        if self.flash==1 then
            tint(0)
            self.flash=0
        end
        rotate(-self.wingangle)
        translate(5,-3)
        --   sprite("Project:wasphead",0,0,self.size*self.dir,self.size)
        sprite(spriteTable[22],0,0,self.size*self.dir,self.size)

        --   sprite("Project:wasplegl",0,0,self.size*self.dir,self.size)
        sprite(spriteTable[24],0,0,self.size*self.dir,self.size)
        
        --   sprite("Project:wasplegm",0,0,self.size*self.dir,self.size)
        sprite(spriteTable[23],0,0,self.size*self.dir,self.size)
        
        --   sprite("Project:wasplegs",0,0,self.size*self.dir,self.size)
        sprite(spriteTable[25],0,0,self.size*self.dir,self.size)
        
        rotate(-5+5*math.sin(ElapsedTime*20))
        
        --     sprite("Project:waspthorax",0,0,self.size*self.dir,self.size)
        sprite(spriteTable[21],0,0,self.size*self.dir,self.size)
        
        popMatrix()
    elseif self.bug==2 then
        if self.flash==1 then
            tint(0)
            self.flash=0
        end
        -- sprite("Project:snail",self.x,self.y,self.size*self.dir,self.size)
        sprite(spriteTable[42],self.x,self.y,self.size*self.dir,self.size/3)
        noTint()
    elseif self.bug==BLUEBUTTERFLY then
        if self.flash==1 then
            tint(0)
            self.flash=0
        end
        pushMatrix()
     --   self.wingangle = self.wingangle - self.wingspd
        translate(self.x,self.y)
        rotate(-45)
        rotate(60)
        rotate(-60)
        spriteMode(CORNER)
        --  sprite("Project:butterflybody",34*self.size/100,11*self.size/100,self.size*self.dir,self.size/3)
        sprite(spriteTable[30],self.butterflyBodyX, self.butterflyBodyY,self.size*self.dir*1.4,self.size*1.2)

        -- sprite("Project:butterflywing4",0,0,1.4*self.size*self.dir,self.size*0.02*self.wingangle)
        sprite(spriteTable[34],0,0,1.4*self.size*self.dir,self.size*0.02*self.wingangle)
        popMatrix()
    elseif self.bug==YELLOWBUTTERFLY then
        if self.flash==1 then
            tint(0)
            self.flash=0
        end
        pushMatrix()
        translate(self.x,self.y)
        rotate(-45)
        rotate(60)
        rotate(-60)
        spriteMode(CORNER)
        --  sprite("Project:butterflybody",34*self.size/100,11*self.size/100,self.size*self.dir,self.size/3)
        sprite(spriteTable[30],self.butterflyBodyX, self.butterflyBodyY+1,self.size*self.dir*1.4,self.size*1.2)
        
        --   sprite("Project:butterflywing2",0,0,1.4*self.size*self.dir,self.size*0.02*self.wingangle)
        sprite(spriteTable[32],0,0,1.4*self.size*self.dir,self.size*0.02*self.wingangle)
        popMatrix()
    elseif self.bug==BLACKBUTTERFLY then
        if self.flash==1 then
            tint(0)
            self.flash=0
        end
        pushMatrix()
      --  self.wingangle = self.wingangle - self.wingspd
        translate(self.x,self.y)
        rotate(-45)
        rotate(60)
        rotate(-60)
        spriteMode(CORNER)
        --  sprite("Project:butterflybody",34*self.size/100,11*self.size/100,self.size*self.dir,self.size/3)
        sprite(spriteTable[30],self.butterflyBodyX, self.butterflyBodyY+1,self.size*self.dir*1.4,self.size*1.2)
        --   sprite("Project:butterflywing1",0,0,1.4*self.size*self.dir,self.size*0.02*self.wingangle)
        sprite(spriteTable[31],0,0,1.4*self.size*self.dir,self.size*0.02*self.wingangle)
        popMatrix()
    elseif self.bug==REDBUTTERFLY then
        if self.flash==1 then
            tint(0)
            self.flash=0
        end
        pushMatrix()
   --     self.wingangle = self.wingangle - self.wingspd
        translate(self.x,self.y)
        rotate(-45)
        rotate(60)
        rotate(-60)
        spriteMode(CORNER)
        --  sprite("Project:butterflybody",34*self.size/100,11*self.size/100,self.size*self.dir,self.size/3)
        sprite(spriteTable[30],self.butterflyBodyX+10, self.butterflyBodyY+1,self.size*self.dir*1.05,self.size*1.5)
        --  sprite("Project:butterflywing3",0,0,1.4*self.size*self.dir,self.size*0.02*self.wingangle)
        sprite(spriteTable[33],0,0,1.4*self.size*self.dir,self.size*0.02*self.wingangle)
        popMatrix()
    elseif self.bug==4 then
        
        --  sprite("Project:ladybird",self.x,self.y,self.size*self.dir,self.size)
        sprite(spriteTable[9],self.x,self.y,self.size*self.dir,self.size)
        
    elseif self.bug==5 then
        
        pushMatrix()
        translate(self.x,self.y)
        rotate(self.wingangle)
        tint(255,255,255,100)
        
        --  sprite("Project:waspwing",0,0,self.size*1.5*self.dir,self.size*1.5)
        sprite(spriteTable[26],0,0,self.size*1.5*self.dir,self.size*1.5)
        
        noTint()
        if self.flash==1 then
            tint(0)
            self.flash=0
        end
        rotate(-self.wingangle)
        translate(5,-3)
        --  sprite("Project:anthead",0,0,self.size*self.dir,self.size)
        sprite(spriteTable[36],0,0,self.size*self.dir,self.size)
        
        --   sprite("Project:antlegl",0,0,self.size*self.dir,self.size)
        sprite(spriteTable[39],0,0,self.size*self.dir,self.size)
        
        --    sprite("Project:antlegm",0,0,self.size*self.dir,self.size)
        sprite(spriteTable[37],0,0,self.size*self.dir,self.size)
        
        --   sprite("Project:antlegs",0,0,self.size*self.dir,self.size)
        sprite(spriteTable[38],0,0,self.size*self.dir,self.size)
        rotate(-5+5*math.sin(ElapsedTime*20))
        --   sprite("Project:antthorax",0,0,self.size*self.dir,self.size)
        sprite(spriteTable[35],0,0,self.size*self.dir,self.size)
        popMatrix()
        
        
        --end of level boss
    elseif self.bug==6 then
        --  sprite("Project:cat",self.x,self.y,600*self.dir,1200)
        sprite(spriteTable[66],self.x,self.y,600*self.dir,1200)
        if self.age==250 then
            stop=true
        elseif self.age>300 then
            --fire projectiles
            if math.fmod(self.age,50)==1 then
                if #bee>0 then
                    local targetbee=math.random(#bee)
                    local ta=math.deg(math.atan(self.y-bee[targetbee].y,self.x-bee[targetbee].x))+180
                    table.insert(ebullets,Bullet(self.x-100,self.y,-ta,1,1))
                end
                
                if math.fmod(self.age,75)==1 then
                    table.insert(enemies,Enemy(self.x-100,self.y,0,1,FLYINGANT))
                    
                    for k=1,10 do
                        local ang=-90
                        table.insert(particles,Particle(self.x-100,self.y,ang,7,math.random(10),ang,0,0,50+math.random(50)))
                    end
                    
                end
                
                
            end
        end
    elseif self.bug==FLYINGLADY then
        pushMatrix()
        translate(self.x,self.y)
        rotate(self.wingangle)
        
        --   sprite("Project:ladywing",0,0,self.size*self.dir,self.size)
        sprite(spriteTable[29],0,0,self.size*self.dir,self.size)
        tint(255,255,255,100)
        --  sprite("Project:waspwing",0,0,self.size*1.5*self.dir,self.size*1.5)
        sprite(spriteTable[27],0,0,self.size*1.5*self.dir,self.size*1.5)
        
        noTint()
        if self.flash==1 then
            tint(0)
            self.flash=0
        end
        rotate(-self.wingangle)
        translate(5,-3)
        --    sprite("Project:ladyhead",0,0,self.size*self.dir,self.size)
        sprite(spriteTable[28],0,0,self.size*self.dir,self.size)
        --    rotate(-3+3*math.sin(ElapsedTime*40))
        
        --   sprite("Project:wasplegl",0,0,self.size*self.dir,self.size)
        sprite(spriteTable[24],0,0,self.size*self.dir,self.size)
        
        --   sprite("Project:wasplegm",0,0,self.size*self.dir,self.size)
        sprite(spriteTable[23],0,0,self.size*self.dir,self.size)
        
        --  sprite("Project:wasplegs",0,0,self.size*self.dir,self.size)
        sprite(spriteTable[25],0,0,self.size*self.dir,self.size)
        
        rotate(-5+5*math.sin(ElapsedTime*20))
        --   sprite("Project:ladythorax",0,0,self.size*self.dir,self.size)
        sprite(spriteTable[27],0,0,self.size*self.dir,self.size)
        popMatrix()
        
    elseif self.bug==DRAGONFLY then
        
        pushMatrix()
        translate(self.x,self.y)
        rotate(-self.wingangle)
        tint(255,255,255,100)
        spriteMode(CORNER)
        -- sprite("Project:dragonflywing",-85,-12,self.size*0.75*self.dir,self.size*3*self.flap/43)
        sprite(spriteTable[46],-self.size/2,0,self.size*self.dir,self.size*self.flap*0.08)
        spriteMode(CENTER)
        noTint()
        if self.flash==1 then
            tint(0,0,0,25)
            self.flash=0
        end
        rotate(self.wingangle)
        -- sprite("Project:dragonflyhead",0,0,self.size*self.dir*2,self.size)
      sprite(spriteTable[40],0,0,self.size*self.dir,self.size)
        pushMatrix()
        self:localRotate(1,9,96,14)
        --   sprite("Project:dragonflylegl",0,0,self.size*self.dir*2,self.size)
        sprite(spriteTable[51],-1*self.size/4,-1*self.size/4,self.size*self.dir/2,self.size/2)
        popMatrix()
        pushMatrix()
        self:localRotate(1,7,110,18)
        --    sprite("Project:dragonflylegm",0,0,self.size*self.dir*2,self.size)
        sprite(spriteTable[50],-1*self.size/4,-1*self.size/4,self.size*self.dir/2,self.size/2)
        popMatrix()        
        pushMatrix()
                self:localRotate(1,5,117,10)
        --   sprite("Project:dragonflylegs",0,0,self.size*self.dir*2,self.size)
        sprite(spriteTable[49],-1*self.size/4,-1*self.size/4,self.size*self.dir/2,self.size/2)
        popMatrix()
        pushMatrix()
        self:localRotate(1,15,50,0)
        --   sprite("Project:dragonflythorax",0,0,self.size*self.dir*4,self.size)
        sprite(spriteTable[41],self.size/2,0,self.size*self.dir*2,self.size)
        popMatrix()
        popMatrix()
        noTint()
        self.flap = self.flap + self.flapspd
        if self.flap>self.flaplima or self.flap<self.flaplimb  then
            self.flapspd = self.flapspd *-1
        end    
    end
    
    self.wingangle = self.wingangle + self.wingspd
    if self.wingangle>self.winglima or self.wingangle<self.winglimb  then
        self.wingspd = self.wingspd *-1
    end
    noTint()
    
    --move enemy based on path
    
    if self.path==1 then
        self.x = self.x - self.spd
    elseif self.path==2 then
        self.x = self.x - self.spd
        self.y = self.y + 2*math.sin(ElapsedTime*3)
    elseif self.path==3 then

        if self.age>275 and self.age<475 then
        elseif self.age>475 and self.age<875 then
   --         self.x=self.x-self.spd*math.cos((self.age-50)/40)
            self.y=self.y+self.spd*math.sin((self.age-50)/40)
        else
            self.x=self.x-self.spd
        end        
        
    elseif self.path==4 then
        self.x = self.x + self.spd
    elseif self.path==5 then
        --dont move
        if not stop then
            self.x = self.x - self.spd
        end
    elseif self.path==6 then
        
        if self.age>75 and self.age<275 then
            self.x=self.x-self.spd*math.cos((self.age-50)/40)
            self.y=self.y+self.spd*math.sin((self.age-50)/40)
        else
            self.x=self.x-self.spd
        end
    elseif self.path==7 then
        self.x = self.x - (-3+math.random(10))*self.spd/5
        self.y = self.y +(-5 + math.random(9))*self.spd/5
    end

    
    if self.x>WIDTH+200 or self.x<-200 or self.y<-200 or self.y>HEIGHT+200 then self.active=0 end
    
    
    --draw hitbox
--[[
    noStroke()
    fill(255,0,255,100)
    ellipse(self.x+self.offset.x,self.y+self.offset.y,self.hitrad)
    fill(255,100)
 ]]--   
end

function Enemy:localRotate(rot,rotspd,tx,ty)
            rotate(rot+rot*math.sin(ElapsedTime*rotspd))
        translate(-tx,-ty)
        rotate(-rot+rot*math.sin(ElapsedTime*rotspd))
        translate(tx,ty)
end

function Enemy:checkhit()
    for i,b in pairs(bullets) do
        if vec2(b.x,b.y):dist(vec2(self.x+self.offset.x,self.y+self.offset.y))<self.hitrad then
            local hpp=self.hp
            self.hp = self.hp - b.power
            b.power = b.power - hpp
            if b.power<0 then b.power=0 end
            self.flash=1
            if self.hp<1 then
                self.active=0
                score = score + self.value
                sound(SOUND_EXPLODE, 46354)
        table.insert(exp,Explosion(self.x,self.y,math.random(360),1+math.random(self.size)/100))

                if self.bug==BOSSCAT then
                    stop=false
                end
                
                if self.bug==WASP then
                    table.insert(particles,Particle(self.x,self.y,math.random(360),1,math.random(5),-90+math.random(180),math.random(3),0,self.size))
                    table.insert(particles,Particle(self.x,self.y,math.random(360),2,math.random(5),-90+math.random(180),math.random(3),0,self.size))
                    table.insert(particles,Particle(self.x,self.y,math.random(360),3,math.random(5),-90+math.random(180),math.random(3),0,self.size))
                    table.insert(particles,Particle(self.x,self.y,math.random(360),4,math.random(5),-90+math.random(180),math.random(3),0,self.size))
                    table.insert(particles,Particle(self.x,self.y,math.random(360),5,math.random(5),-90+math.random(180),math.random(3),0,self.size))
                    table.insert(particles,Particle(self.x,self.y,math.random(360),6,math.random(5),-90+math.random(180),math.random(3),0,self.size))
                elseif self.bug==FLYINGANT then
                    table.insert(particles,Particle(self.x,self.y,math.random(360),16,math.random(5),-90+math.random(180),math.random(3),0,self.size))
                    table.insert(particles,Particle(self.x,self.y,math.random(360),17,math.random(5),-90+math.random(180),math.random(3),0,self.size))
                    table.insert(particles,Particle(self.x,self.y,math.random(360),18,math.random(5),-90+math.random(180),math.random(3),0,self.size))
                    table.insert(particles,Particle(self.x,self.y,math.random(360),19,math.random(5),-90+math.random(180),math.random(3),0,self.size))
                    table.insert(particles,Particle(self.x,self.y,math.random(360),20,math.random(5),-90+math.random(180),math.random(3),0,self.size))
                    table.insert(particles,Particle(self.x,self.y,math.random(360),3,math.random(5),-90+math.random(180),math.random(3),0,self.size))
                else
                    for k=1,10 do
                        table.insert(particles,Particle(self.x,self.y,math.random(360),7,math.random(5),-90+math.random(360),math.random(3),0,50+math.random(50)))
                    end
                end
                if self.bonus~=0 then
                    local bcol=math.min(math.ceil(self.y/(HEIGHT*0.9/#palette)),7)
                    table.insert(bonus,Bonus(self.x,self.y,self.bonus,bcol))
                end
            end
            
            if b.power<=0 then
                b.active=0
                
            end
        end
        
    end
end
