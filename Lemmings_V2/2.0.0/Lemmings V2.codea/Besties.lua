Besties = class()

function Besties:init(x)
    self.nom="cau"
    self.x=166 --310
    self.y=460 --360
    self.vel = 5
    self.tems= 0
    self.tipo=33
    self.dire=0
    self.dire2=1
    self.tope=vec2(33,36)
    self.caiguda=0
    self.tocat=0
end

function Besties:draw()
    spriteMode(CENTER)
    self.tems=self.tems+1
    r,g,b = fons:get( self.x,math.max( self.y-24,1))
    if self.tems== self.vel then
        self.tems=0
        if self.nom=="cau"then self:cau() end
        if self.nom=="camina" then self:camina()end
        if self.nom=="forat" then self:forat() end
        if self.nom=="stop" then self:stop() end
        if self.nom=="fin" then self:fin() end
        if self.nom=="explota" then self:explota() end
        if self.nom=="xafat" then self:xafat() end
        if self.nom=="paraca" then self:paraca() end
        if self.nom=="pic" then self:pic() end
        if self.nom=="rampa" then self:rampa() end
        if self.nom=="tunel" then self:tunel() end
        if self.nom=="escala" then self:escala() end
        
    end
    pushStyle()
    if self.tocat>0 then
        stroke(243, 221, 36, 255)
        strokeWidth(4)
        noFill()
        rect(self.x-20+mou,self.y+120,40,60)
        self.tocat=self.tocat-1
    end
    popStyle()
    if r==46 and self.nom~="rampa" then self.y=self.y-2 end
    if r==46 and self.nom=="tunel" then self.y=self.y+2 end
    sprite(blocs[self.tipo],self.x+mou,self.y+162,55)
    if self.y<0 then self.tipo=223 end
    if self.y<41 then self.y=self.y-2 end
    
end
function Besties:hit(p)
    local l = self.x - 20
    local r = self.x + 20
    local t = self.y + 20
    local b = self.y -20
    if p.x > l and p.x < r and
    p.y > b and p.y < t then
        return true
    end
    
    return false
end

function Besties:touched(touch)
    llista={"rampa","paraca","explota","stop","escala","tunel","pic","forat"}
    if estil>1 and estil<10 then
        if touch.state == ENDED and self:hit(vec2(touch.x-mou,touch.y-160)) and   num[estil-1]~="" then
            num[estil-1]=num[estil-1]-1
            self.tocat=10    
            if num[estil-1]==0 then num[estil-1]="" end
            if estil==3 or estil==2 or estil==7 then self.caiguda=258-estil
                
            else self:canvi(llista[estil-1])
            end
        end
    end
end
function Besties: anaEstatua()
    for i=1,#ninos do
        if ninos[i].nom=="stop" and self:hit(vec2(ninos[i].x,ninos[i].y))  then
            return(true)
        end
    end
end
function Besties: cau()
    self.tipo=self.tipo+1
    if r~=46 then
        if self.tope.y-self.y>230  then self:canvi("xafat")
        else self:canvi("camina") self.dire=self.dire2 self.tipo=8-self.dire
        end
    end
    if self.tipo==37 then self.tipo=33 end
end

function Besties: camina()
    self.tipo=self.tipo+self.dire
    if self.dire==-1 then self.x=self.x-2 end
    if self.dire==1 then self.x=self.x+2 end
    if r~=46 then self.y=self.y+2 end
    if self.tipo==9 and self.dire==1 then self.tipo=1 end
    if self.tipo==8 and self.dire==-1 then  self.tipo=16 end
    r1,g,b = fons:get( self.x+15,math.max( self.y-5,1)) -- -5
    if g~=39 and self.dire==1 then
        if self.caiguda==256 then self:canvi("rampa") self.x=self.x+8
        elseif self.caiguda==251 then self:canvi("tunel")
        else
        self.dire=-1 self.tipo=9 end
    end
    r1,g,b = fons:get( self.x-12,math.max( self.y-5,1))
    if g~=39 and self.dire==-1 and g~=100 then self.dire=1 self.tipo=1 end
    if self:hit(vec2(xsalida+68+self.dire*20,ysalida-130)) then self:canvi("fin") end
    if self:anaEstatua() then
        self.tipo=self.tipo+self.dire*8
        self.dire=self.dire*-1
    end
    bg=0
    -- if self.y>41 then
    -- print(self.y)
    for a=0,3 do --4
        r2,g,b = fons:get( self.x,math.max(self.y-24-a*4,1))
        if r2~=46 then bg=1  end
    end
    if bg==0 then
        if self.caiguda==255 then self:canvi("paraca")
        else self.dire2=self.dire self:canvi("cau")  end
    end
    -- end 
end
function Besties: forat()
    self.tipo=self.tipo+1
    if self.tipo==209 then self.tipo=193 end
    self.y=self.y+1
    for a=self.x-15, self.x+15 do
        for b=1,3 do
            fons:set( a,self.y-22-b, ColourFons)
        end
    end
    if r==46 then self:canvi("cau") end
end
function Besties: stop()
    self.tipo=self.tipo+1
    if self.tipo==65 then self.tipo=49 end
end
function Besties: fin()
    self.tipo=self.tipo+1
    if self.tipo>25 then self.tipo=25 end
end
function Besties: explota()
    self.tipo=self.tipo+1
    if self.tipo==177 then self.tipo=216 end
    if self.tipo>=223 then self.tipo=223 
       if explo then tallarExp(self.x-18,self.y) end

    end
end
function Besties: paraca()
    self.tipo=self.tipo+1
    self.y=self.y+2
    if r~=46 then self:canvi("camina") end
    
    if self.tipo==49 then self.tipo=41 end
end
function Besties: xafat()
    self.tipo=self.tipo+1
    if self.tipo>192 then self.tipo=192 end
end
function Besties: pic()
    self.tipo=self.tipo+1
    
    if self.tipo>160 then self.tipo=138
        tallarPic(self.x,self.y)
        self.x=self.x+4 self.y=self.y-2
        bg=0
        for a=1,4 do --4
            r2,g,b = fons:get( self.x,self.y-24-a*4)
            if r2~=46 then bg=1  end
        end
        if bg==0 then self:canvi("cau")  end
        
    end
end
function Besties: rampa()
    self.tipo=self.tipo+1
    self.y=self.y+2
    if self.tipo>73 then self.tipo=65 end
    r1,g,b = fons:get( self.x+15,self.y-15)
    if r1==46 then self:canvi("camina") self.x=self.x+8 self.caiguda=0 end
end
function Besties: tunel()
    self.tipo=self.tipo+1
    if self.tipo==129 then self.tipo=97
        r1,g,b = fons:get( self.x+15,self.y-5)
        if r1==46 then self.caiguda=0 self:canvi("camina")  end
        for a=self.y-25, self.y+5 do
            for b=1,6 do
                fons:set( self.x+12+b,a,ColourFons)
            end
        end
        self.x=self.x+6    
    end
end
function Besties: escala()
    self.tipo=self.tipo+1
    if self.tipo==97 then self.tipo=81
        for a=self.x, self.x+10 do
            for b=1,4 do
                fons:set( a,self.y-24+b,color(100,100,255))
            end
        end
        self.x=self.x+8 self.y=self.y+4
        self.tope.x=self.tope.x-1
        r1,g,b = fons:get( self.x+15,self.y-5)
        if r1~=46 or self.tope.x<0 then
            self:canvi("camina")
        end
    end
end
function Besties: canvi(aNino)
    if aNino=="cau" then levels = {nom="cau",tipo=33,dire=0,tope=vec2(33,self.y),vel=6}end
    if aNino=="camina" then levels = {nom="camina",tipo=1,dire=1,tope=vec2(0,9),vel=4}end
    if aNino=="forat" then levels = {nom="forat",tipo=193,dire=0,tope=vec2(3,0),vel=7}end
    if aNino=="stop" then levels = {nom="stop",tipo=49,dire=0,tope=vec2(49,64),vel=5}end
    if aNino=="fin" then levels = {nom="fin",tipo=18,dire=0,tope=vec2(18,25),vel=4}end
    if aNino=="explota" then levels = {nom="explota",tipo=161,dire=0,tope=vec2(161,176),vel=6}end
    if aNino=="xafat" then levels = {nom="xafat",tipo=177,dire=0,tope=vec2(177,192),vel=6}end
    if aNino=="paraca" then levels = {nom="paraca",tipo=33,dire=0,tope=vec2(33,44),vel=3}end
    if aNino=="pic" then levels = {nom="pic",tipo=138,dire=0,tope=vec2(33,self.y),vel=6}end
    if aNino=="rampa" then levels = {nom="rampa",tipo=66,dire=0,tope=vec2(3,0),vel=8}end
    if aNino=="tunel" then levels = {nom="tunel",tipo=97,dire=0,tope=vec2(3,0),vel=2}end
    if aNino=="escala" then levels = {nom="escala",tipo=81,dire=0,tope=vec2(8,0),vel=4}end
    self.nom=levels["nom"]
    self.tipo=levels["tipo"]
    self.dire=levels["dire"]
    self.tope=levels["tope"]    if r==46 and self.nom~="rampa" then self.y=self.y-2 end
    self.vel=levels["vel"]
end


