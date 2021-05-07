Bonus = class()

function Bonus:init(x,y,t,c)
    -- you can accept and set parameters here
    self.x = x
    self.y=y
    self.type=t
    self.active=1
    self.col=8-c
    self.flashrate=math.random(30)
end

function Bonus:draw()
    -- Codea does not automatically call this method
    -- sprite("Project:daisy",self.x,self.y,50)
    sprite(spriteTable[56],self.x,self.y,50)
    tint(palette[self.col].r,palette[self.col].g,palette[self.col].b,120)
    -- sprite("Project:daisymask",self.x,self.y,50)
    sprite(spriteTable[58],self.x,self.y,50)
    noTint()
    -- sprite("Project:daisymiddle",self.x,self.y,50)
    sprite(spriteTable[57],self.x,self.y,50)

        local ff=math.fmod(math.floor(ElapsedTime*20),50+self.flashrate)+1
    if ff<5 then
        local daisyFlashIndexes = {59,60,68,69}
        -- sprite("Project:daisyflash"..ff,self.x,self.y,50)
        sprite(spriteTable[daisyFlashIndexes[ff]],self.x,self.y,50)
    end
   if math.fmod(math.floor(ElapsedTime*50),2)==1 then
 --   sprite("Project:daisy",self.x,self.y,50)
        sprite(spriteTable[56],self.x,self.y,50)
     end
    if not stop then
    self.x = self.x - 1
        end
end

function Bonus:checkCollision()
    --check for each bee
    for i,b in pairs (bee) do
        if vec2(b.x,b.y):dist(vec2(self.x,self.y))<30 then
            self.active=0
            bonuscount = bonuscount + 1
            sound(SOUND_BLIT, 36263)
            if rainbow[self.col]==0 then
            local rmax=0
            for j=1,#rainbow do
                if rainbow[j]>rmax then rmax=rainbow[j] end
            end
            rainbow[self.col]=rmax+1
                --could also add a check to see if the order is correct - extra bonus
                if rmax==6 then
                    sound(SOUND_POWERUP, 31686)
                    for i,b in pairs(bee) do
                        b.invincible=500
                        rainbow={0,0,0,0,0,0,0}
                    end
                    
                end
            end
        end
    end
end

function Bonus:touched(touch)
    -- Codea does not automatically call this method
end
