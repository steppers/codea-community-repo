Crate = class()

function Crate:init(x,y,spd)
    -- you can accept and set parameters here
    self.x = x
    self.y=y
    self.spd=spd
    self.active=1
end

function Crate:draw()
    if self.active==1 then
        local penumbra=math.max(0,math.min(40,(500-(self.y-HEIGHT))/10))
        
        fill(0,penumbra)
        rect(self.x-100,10,200,self.y)
        
        local shadow=255*(HEIGHT-self.y)/HEIGHT
        
        fill(0,shadow)
        rect(self.x-100,10,200,20)
        
        sprite("Project:crate",self.x,self.y,200)
        table.insert(bubbles,Bubble(self.x-90,self.y+100,math.random(10)/10))
        table.insert(bubbles,Bubble(self.x+90,self.y+100,math.random(10)/10))
        
        self.y = self.y - self.spd
        
        if self.y<110 and self.active==1 then
            self:bust()
        end
        if (puffy.x-self.x)<200 and (puffy.x-self.x)>100 and puffy.y<self.y-100 and  self.y-puffy.y<200 then
            puffy.x = puffy.x + 3
            puffy.y = puffy.y - 1
        elseif (self.x-puffy.x)<200 and (self.x-puffy.x)>100 and puffy.y<self.y-100 and  self.y-puffy.y<200 then
            puffy.x = puffy.x - 3
            puffy.y = puffy.y - 1
        end
        if puffy.y<100 then puffy.y=100 end
        if math.abs(puffy.x-self.x)<120 and puffy.y<self.y then
            
            if self.y-puffy.y<180 then
                puffy.y = puffy.y - self.spd
                if puffy.y<100 then puffy.y=100 end
                --       sprite("Project:puffysad",puffy.x,puffy.y,200)
            else
                --          sprite("Project:puffyshock",puffy.x,puffy.y,200)
            end
            if self.y-puffy.y<170 and self.y-puffy.y>160 then
                
                sound(asset.downloaded.Game_Sounds_One.Female_Grunt_2)
                
                
            end
        else
            --       sprite("Project:puffysmile",puffy.x,puffy.y,200)
        end
        
        
        
    end
    
end

function Crate:touched(touch)
    -- Codea does not automatically call this method
    if vec2(touch.x,touch.y):dist(vec2(self.x,self.y))<100 then
        self:bust()
    end
    
end

function Crate:bust()
    for i=1,100 do
        table.insert(bubbles,Bubble(self.x-120+math.random(240),self.y-110+math.random(190),1+math.random(10)/10))
    end
    for i=0,3 do
        table.insert(splinters,Splinter(self.x,self.y-100+50*(i)))
    end
    sound(asset.downloaded.Game_Sounds_One.Land)
    self.active=0
    if cratedelay<0 then
        table.insert(crates,Crate(100+math.random(WIDTH-200),HEIGHT+200,2+math.random(5)))
        cratedelay=50
    end
end
