Fish = class()

function Fish:init(x,y)
    -- you can accept and set parameters here
    self.x = x
    self.y=y
    self.frame=1
    self.col=color(math.random(255),math.random(255),math.random(255))
    self.eyeline=35
    self.scale=0.2+math.random(8)/10
end

function Fish:draw()
    -- Codea does not automatically call this method
    self.frame = self.frame + 0.1
    if self.frame>=#bb then self.frame=1 end
    
    sprite("Project:puffyfin",self.x-55*self.scale-2*math.sin(5*ElapsedTime),self.y+30*self.scale,(50+5*math.sin(5*ElapsedTime))*self.scale,50*self.scale)
    sprite("Project:puffyfin",self.x+55*self.scale+2*math.sin(5*ElapsedTime),self.y+30*self.scale,-((50+5*math.sin(5*ElapsedTime)))*self.scale,50*self.scale)
    
    tint(self.col)
    sprite("Project:barrybody"..bb[math.floor(self.frame)],self.x,self.y,200*self.scale)
    noTint()
    
    sprite("Project:puffyeyes",self.x,self.y+35*self.scale,200*self.scale)
    sprite("Project:barrysmile",self.x,self.y,200*self.scale)
    noTint()
    fill(0)
    
    local eyeyoff=0
    local eyexoff=0
    
    if #crates>0 then
        local ang=math.atan(crates[1].y-self.y,crates[1].x-self.x)
        eyexoff=6*math.cos(ang)
        eyeyoff=10*math.sin(ang)
    end
    ellipse(self.x-(25+eyexoff)*self.scale,self.y+(30+eyeyoff)*self.scale+self.eyeline*self.scale,20*self.scale)
    ellipse(self.x+(25+eyexoff)*self.scale,self.y+(30+eyeyoff)*self.scale+self.eyeline*self.scale,20*self.scale)
    
for i,c in pairs(crates) do
        if (self.x-c.x)<200 and (self.x-c.x)>100 and self.y<c.y-100 and  c.y-self.y<200 then
            self.x = self.x + 3
            self.y = self.y - 1
        elseif (c.x-self.x)<200 and (c.x-self.x)>100 and self.y<c.y-100 and  c.y-self.y<200 then
            self.x = self.x - 3
            self.y = self.y - 1
        end
        if self.y<100 then self.y=100 end
        if math.abs(self.x-c.x)<120 and self.y<c.y then
            
            if c.y-self.y<180 then
                self.y = self.y - c.spd
                if self.y<100 then self.y=100 end
                --       sprite("Project:puffysad",puffy.x,puffy.y,200)
            else
                --          sprite("Project:puffyshock",puffy.x,puffy.y,200)
            end
            if c.y-self.y<170 and c.y-self.y>160 then
                
                sound(asset.downloaded.Game_Sounds_One.Female_Grunt_3)
                
                
            end
        else
            --       sprite("Project:puffysmile",puffy.x,puffy.y,200)
        end
        
    
    end
    
    
    if math.random(50)==1 then
        table.insert(bubbles,Bubble(self.x,self.y,2))
    end
    
    
end

function Fish:touched(touch)
    -- Codea does not automatically call this method
end
