Fishfinger = class()

function Fishfinger:init(x,y)
    -- you can accept and set parameters here
    self.x = x
    self.y=y
end

function Fishfinger:draw()
    -- Codea does not automatically call this method
        sprite("Project:roundfishfinger",self.x,self.y)
    
            local fang=math.atan(puffy.y-self.y,puffy.x-self.x)
        local dis=math.max(0,(25-math.abs(puffy:dist(vec2(self.x,self.y))*0.1))*0.5)
     puffy.x=puffy.x+dis*math.cos(fang)
    puffy.y=puffy.y+dis*math.sin(fang)       
        
        if puffy.x>WIDTH-80 then puffy.x=WIDTH-80 end
        if puffy.x<80 then puffy.x=80 end
        if puffy.y>HEIGHT-80 then puffy.y=HEIGHT-80 end
        if puffy.y<100 then puffy.y=100 end
    
    
    for i,f in pairs(fishes) do
                    local fang=math.atan(f.y-self.y,f.x-self.x)
        local dis=math.max(0,(25-math.abs(vec2(f.x,f.y):dist(vec2(self.x,self.y))*0.1))*0.5)
     f.x=f.x+dis*math.cos(fang)
    f.y=f.y+dis*math.sin(fang)       
        
        if f.x>WIDTH-80 then f.x=WIDTH-80 end
        if f.x<80 then f.x=80 end
        if f.y>HEIGHT-80 then f.y=HEIGHT-80 end
        if f.y<100 then f.y=100 end
    end
    
end

function Fishfinger:touched(touch)
    -- Codea does not automatically call this method
end
