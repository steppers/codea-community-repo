Bee = class()

function Bee:init(x,y,sz)
    self.x = x
    self.y = y
    self.size=sz
    self.wingangle=0
    self.wingspd=20
    self.bodyangle=0
    self.bodyspd=0.17
    self.bodyoffsetangle=0
    self.legsangle=0
    self.legsspd=0.21
    self.legmangle=0
    self.legmspd=0.23
    self.acc=12
    self.tx=100
    self.ty=y
    self.tid=nil
    self.injured=0
    self.drag=0 --track whether touch originated on bee
    self.active=1
    self.shield=0
    self.bulletspread=0
    self.bulletspeed=10
    self.bombrate=0
    self.upbombrate=0
    self.rearbullet=0
    self.invincible=200
    self.old={}
end

function Bee:draw()    
    
    table.insert(self.old,1,vec2(self.x,self.y))
    
    if #self.old>7 then table.remove(self.old,8) end
    if self.invincible>0 then
        self.invincible = self.invincible - 1
    end
    if self.invincible<0 then self.invincible=0 end
    if self.bodyoffsetangle>0 then
        self.bodyoffsetangle = self.bodyoffsetangle -0.5
    elseif self.bodyoffsetangle<0 then
        self.bodyoffsetangle = self.bodyoffsetangle + 0.5
    end   
    if self.x<self.tx then
        self.x=self.x+(self.tx-self.x)/self.acc
        if self.x<self.tx-10 then
            self.bodyoffsetangle=-20
        end
    elseif self.x>self.tx then
        self.x=self.x-(self.x-self.tx)/self.acc
        if self.x>self.tx+10 then
            self.bodyoffsetangle=20
        end
    end
    if self.y<self.ty then
        self.y = self.y + (self.ty-self.y)/self.acc
    elseif self.y>self.ty then
        self.y = self.y - (self.y-self.ty)/self.acc
    end
    
    if self.ty<80 then self.ty=80 end
    self.wingangle = self.wingangle + self.wingspd
    if self.wingangle>11 or self.wingangle<-20 then
        self.wingspd = self.wingspd *-1
    end
    self.bodyangle = self.bodyangle + self.bodyspd
    if self.bodyangle>2 or self.bodyangle<-2 then
        self.bodyspd = self.bodyspd *-1
    end
    self.legsangle = self.legsangle + self.legsspd
    if self.legsangle>2.7 or self.legsangle<-2.7 then
        self.legsspd = self.legsspd*-1
    end
    self.legmangle = self.legmangle + self.legmspd
    if self.legmangle>2.3 or self.legmangle<-2.1 then
        self.legmspd = self.legmspd *-1
    end

    self.x=self.x+0.1*math.sin(ElapsedTime*10)
    self.y = self.y + 0.1*math.cos(ElapsedTime*10)
    self.x = self.x + 0.1*math.sin(ElapsedTime*7)
    
    for i=1,#self.old do
        pushMatrix()
        tint(palette[i].r,palette[i].g,palette[i].b,100-10*i)
        translate(self.old[i].x,self.old[i].y)
        rotate(self.bodyangle+self.bodyoffsetangle)
        sprite(spriteTable[19],0,0,self.size*(30-i)/30) --body mask
        noTint()
        popMatrix()
    end
    pushMatrix()
    translate(self.x,self.y)
    sprite(spriteTable[3],0,0,self.size) --head
    rotate(self.bodyangle+self.bodyoffsetangle)
    
    
    
    if self.injured==0 then
        sprite(spriteTable[2],0,0,self.size) --body
    else
        sprite(spriteTable[17],0,0,self.size) --damaged body
        if math.random(50)==1 then
            --(x,y,a,t,spd,dir,rot,bonus,sz)
            table.insert(particles,Particle(self.x-9-math.random(10),self.y-7,0,7,0,-90,0,0,50+math.random(30)))
        end
    end
    
    rotate(-self.bodyangle-self.bodyoffsetangle)
    translate(-0.025*self.size,0.05*self.size)
    rotate(self.wingangle)
    tint(255,255,255,100)
    sprite(spriteTable[5],0,0,self.size) --wing    
    noTint()
    
    rotate(-self.wingangle)
    translate(0.025*self.size,-0.05*self.size)
    rotate(self.legsangle+self.bodyoffsetangle)
    sprite(spriteTable[6],0,0,self.size) --small leg
    
    rotate(-self.legsangle-self.bodyoffsetangle)
    rotate(self.legmangle+self.bodyoffsetangle)
    sprite(spriteTable[1],0,0,self.size) --medium leg
    rotate(-self.legmangle-self.bodyoffsetangle)
    rotate((self.bodyangle+self.bodyoffsetangle)*1.5)
    sprite(spriteTable[4],0,0,self.size) --large leg
    rotate(-(self.bodyangle+self.bodyoffsetangle)*1.5)
    popMatrix()
    
    if self.invincible>0 then
        table.insert(particles,Particle(self.x,self.y,0,15,0,0,0,0,10)) --sparkles     
    end
    
    if self.shield==1 then
        tint(255,255,255,100)
        sprite(spriteTable[10],self.x-5,self.y-5,100,100) --bubble
        noTint()
    end
    
    
    if math.fmod(counter,self.bulletspeed)==1 and self.drag==0 then      
        local n=math.floor(self.y/30)
        local pitch=2^(((n-1)/12)-1)
        --a pitch of 1 is the base pitch of the sound.
        --a pitch of 2 is one octave higher
        --a pitch of 0.5 is one octave lower
        sound(SOUND_SHOOT,19478,1.0,pitch,0.0,false)                

        if self.bulletspread==0 then
            table.insert(bullets,Bullet(self.x,self.y-6*self.size/70,0,0,1,0))
        elseif self.bulletspread==1 then
            table.insert(bullets,Bullet(self.x,self.y-6*self.size/70-4,0,0,1,0))
            table.insert(bullets,Bullet(self.x,self.y-6*self.size/70+4,0,0,1,0))
        elseif self.bulletspread==2 then
            table.insert(bullets,Bullet(self.x,self.y-6*self.size/70,0,0,1,0))
            table.insert(bullets,Bullet(self.x-4,self.y-6*self.size/70-8,0,0,1,0))
            table.insert(bullets,Bullet(self.x-4,self.y-6*self.size/70+8,0,0,1,0))
        elseif self.bulletspread==3 then
            table.insert(bullets,Bullet(self.x,self.y-6*self.size/70,0,0,1,0))
            table.insert(bullets,Bullet(self.x-4,self.y-6*self.size/70-8,0,0,1,0))
            table.insert(bullets,Bullet(self.x-4,self.y-6*self.size/70+8,0,0,1,0))
            table.insert(bullets,Bullet(self.x-8,self.y-6*self.size/70,-2,0,1,0))
            table.insert(bullets,Bullet(self.x-8,self.y-6*self.size/70,2,0,1,0))

        elseif self.bulletspread==4 then
            table.insert(bullets,Bullet(self.x,self.y-6*self.size/70,0,0,1,0))
            table.insert(bullets,Bullet(self.x-4,self.y-6*self.size/70-8,0,0,1,0))
            table.insert(bullets,Bullet(self.x-4,self.y-6*self.size/70+8,0,0,1,0))
            table.insert(bullets,Bullet(self.x-8,self.y-6*self.size/70,-2,0,1,0))
            table.insert(bullets,Bullet(self.x-8,self.y-6*self.size/70,2,0,1,0))
            table.insert(bullets,Bullet(self.x-8,self.y-6*self.size/70,-3,0,1,0))
            table.insert(bullets,Bullet(self.x-8,self.y-6*self.size/70,3,0,1,0))            
        end        
        
        if self.rearbullet==1 then
            table.insert(bullets,Bullet(self.x,self.y+2*self.size/70,180,0,1,0))
        elseif self.rearbullet==2 then
            table.insert(bullets,Bullet(self.x,self.y+2*self.size/70+4,180,0,1,0))
            table.insert(bullets,Bullet(self.x,self.y+2*self.size/70-4,180,0,1,0))
        elseif self.rearbullet==3 then
            table.insert(bullets,Bullet(self.x,self.y+2*self.size/70,180,0,1,0))
            table.insert(bullets,Bullet(self.x,self.y+2*self.size/70,178,0,1,0))
            table.insert(bullets,Bullet(self.x,self.y+2*self.size/70,182,0,1,0))
        end
    end
    
    if self.bombrate>=1 and math.fmod(counter+5,self.bulletspeed*10)==1 and self.drag==0 then
        table.insert(bullets,Bullet(self.x-12,self.y-4,0,3,3,3))
        sound(SOUND_SHOOT, 46595)
    end
    
    if self.bombrate>=2 and math.fmod(counter,self.bulletspeed*10)==1 and self.drag==0 then
        table.insert(bullets,Bullet(self.x-12,self.y-4,0,3,3,2))
        sound(SOUND_SHOOT, 46595)        
    end
    
    if self.bombrate>=3 and math.fmod(counter+10,self.bulletspeed*10)==1 and self.drag==0 then
        table.insert(bullets,Bullet(self.x-12,self.y-4,0,3,3,4))
        sound(SOUND_SHOOT, 46595)        
    end
    
    if self.upbombrate>=1 and math.fmod(counter+20,(self.bulletspeed*10))==1 and self.drag==0 then
        table.insert(bullets,Bullet(self.x-12,self.y-4,0,4,3,3))
        sound(SOUND_SHOOT, 46595)
    end
    
    if self.upbombrate>=2 and math.fmod(counter+15,self.bulletspeed*10)==1 and self.drag==0 then
        table.insert(bullets,Bullet(self.x-12,self.y-4,0,4,3,2))
        sound(SOUND_SHOOT, 46595)        
    end
    
    if self.upbombrate>=3 and math.fmod(counter+25,self.bulletspeed*10)==1 and self.drag==0 then
        table.insert(bullets,Bullet(self.x-12,self.y-4,0,4,3,4))
        sound(SOUND_SHOOT, 46595)        
    end
 
end



function Bee:checkhit()
    --check collision with enemies
    if self.invincible==0 then
        for i,e in pairs(enemies) do           
            --might need a better hit radius in here
            if vec2(e.x,e.y):dist(vec2(self.x+10,self.y))<20 then
                if self.shield==1 then
                    self.shield=0
                    sound("Game Sounds One:Pop 1")
                    e.active=0
                else
                    e.active=0
                    self:die()
                end
            end
            
        end
                
        --check collision with enemy bullets
        for i,b in pairs(ebullets) do
            if vec2(b.x,b.y):dist(vec2(self.x+10,self.y))<10 then
                if self.shield==1 then
                    self.shield=0
                    sound("Game Sounds One:Pop 1")
                    b.active=0
                else
                    sound(SOUND_EXPLODE, 22324)
                    b.active=0
                    --dead
                    self:die()
                end
            elseif vec2(b.x,b.y):dist(vec2(self.x-10,self.y-7))<15 then
                if self.shield==1 then
                    self.shield=0
                    sound("Game Sounds One:Pop 1")
                    b.active=0
                else
                    sound(SOUND_PICKUP, 22325)
                    b.active=0
                    if self.injured==0 then                        
                        self.injured=1
                    else
                        self:die()
                    end
                end                
            end
        end
    end
end


function Bee:die()
    self.active=0
    table.insert(particles,Particle(self.x,self.y,math.random(360),8,math.random(5),-90+math.random(180),math.random(3),0,self.size))
    table.insert(particles,Particle(self.x,self.y,math.random(360),9,math.random(5),-90+math.random(180),math.random(3),0,self.size))
    table.insert(particles,Particle(self.x,self.y,math.random(360),10,math.random(5),-90+math.random(180),math.random(3),0,self.size))
    table.insert(particles,Particle(self.x,self.y,math.random(360),11,math.random(5),-90+math.random(180),math.random(3),0,self.size))
    table.insert(particles,Particle(self.x,self.y,math.random(360),12,math.random(5),-90+math.random(180),math.random(3),0,self.size))
    table.insert(particles,Particle(self.x,self.y,math.random(360),13,math.random(5),-90+math.random(180),math.random(3),0,self.size))
    for k=1,10 do
        table.insert(particles,Particle(self.x,self.y,math.random(360),7,math.random(5),-90+math.random(360),math.random(3),0,50+math.random(50)))
    end
end
