--# Butterflies
Butterflies = class()

function Butterflies:init(n)
    self.colorList = {}
    
    self.colorList[1] = color(253, 255, 0, 255) 
    self.colorList[2] = color(255, 188, 0, 255) 
    self.colorList[3] = color(255, 75, 0, 255) 
    self.colorList[4] = color(255, 0, 157, 255) 
    self.colorList[5] = color(252, 0, 255, 255) 
    
    self.colorList[6] = color(138, 0, 255, 255) 
    self.colorList[7] = color(0, 159, 255, 255) 
    self.colorList[8] = color(0, 247, 255, 255) 
    self.colorList[9] = color(0, 255, 158, 255) 
    self.colorList[10] = color(41, 255, 0, 255) 
    
    self.n = n
    local id = {}
    local ms = mesh()
    self.id = id
    self.ms = ms
    rnd = math.random
    --[[
    
    local rndTable = {}
    for i=1,3121 do rndTable[i] = rnd() end
    function list_iter(t)
        local i = 0
        return function ()
            i = i + 1; 
            if i>3121 then i=1 end
            return t[i]
        end
    end
    rnd = list_iter(rndTable)
]]
cos = math.cos
sin = math.sin
pi = math.pi
floor = math.floor
for i =1,n do
local c = self.colorList [floor(rnd()*9.99)+1]
local j = (i-1)*12
id[i] = Butterfly(ms,c)
end
end

function Butterflies:draw()
self.ms:draw()
for i,p in ipairs(self.id) do
p:draw()
end
end

function Butterflies:touched(touch)
for i,p in ipairs(self.id) do
p:touched(touch)
end
end

--# Butterfly
Butterfly = class()

local rnd = math.random
local cos = math.cos
local sin = math.sin
local pi = math.pi

function Butterfly:init(ms,c)
local x,y,z,w,h,o,r,j
local xc,yc = WIDTH/2,HEIGHT/2
local shape = {}
x = (rnd()-0.5)*WIDTH*0.9 + xc
y = (rnd()-0.5)*HEIGHT*0.9 + yc
z = 0
w = (rnd()+2)*4
h = w
o = 1  -- this is the opening of the wings
r = rnd()*2*math.pi
j = #ms.vertices
ms:addRect(x,y,w,h,r)
ms:addRect(x,y,w,h,r)
self.ms = ms
local p =self
p.j, p.shape, p.r, p.c, p.w, p.h, p.o, p.x, p.y = j,shape,r,c,w,h,o,x,y
p.dtBeat= 0.5
p.tfBeat= 0
self:redraw()
end

function Butterfly:redraw()
local p= self
local j,shape,r,c0,w,h,o,x,y = p.j, p.shape, p.r, p.c, p.w, p.h, p.o, p.x, p.y
local ms = self.ms
shape[1]=vec2(0,0):rotate(r)
shape[2]=vec2(w*o*1.3,h):rotate(r)
shape[3]=vec2(w*o/2,-h):rotate(r)
shape[4]=vec2(0,0):rotate(r)
shape[5]=vec2(-w*o*1.3,h):rotate(r)
shape[6]=vec2(-w*o/2,-h):rotate(r)
c = color(0,0,0,128)
local d,s
if self.flying then d=10 s=1.1 else d=4 s=1 end
for k=1,6 do 
ms:vertex(j+k,shape[k]*s+vec2(x+d,y-d))
ms:color(j+k,c) 
end

for k=1,6 do 
ms:vertex(j+k+6,shape[k]*s+vec2(x,y)) 
ms:color(j+k+6,c0) 
end
end

function Butterfly:draw()
local limit = DeltaTime/0.016
if rnd()<=limit/500 then self:turn() end
if rnd()<=limit/500 then self:wingBeat(rnd()*0.7+0.3) end
if rnd()<=limit/10000 then self:fly("random") end
self:wingBeat()
if self.flying then self:fly() end
end

function Butterfly:wingBeat(dt)
--if true then return 0 end
local pap = self
if dt then -- this is a start
pap.dtBeat= dt
pap.tfBeat = ElapsedTime + dt
--   sound(SOUND_HIT, 39771)
else -- continue beating
if pap.tfBeat > ElapsedTime then
    local o = (1.5+ cos((ElapsedTime - pap.tfBeat)/pap.dtBeat*2*pi))/2.5
    pap.o = o
    self:redraw()
end
end
end

function Butterfly:turn()
local pap = self
local r = (rnd()-0.5)*pi/2
pap.r = pap.r + r
if self.flying then self.flySpeed = (rnd() + 1)*70 end
self:redraw()
end

function Butterfly:fly(type,t,mult)
local alpha 

if type then
self.flying = true
self.flyType = type
if self.flyType == "random" then  
    self.flySpeed = (rnd() + 1)*70
    if mult then self.flySpeed = self.flySpeed * mult end
    if t then 
        alpha = (rnd() -0.5)*pi
        local v = vec2(self.x-t.x,self.y-t.y)+vec2(cos(alpha),sin(alpha))
        self.r = vec2(0,0):angleBetween(v) - pi/2
    end
    alpha = self.r + pi/2
    self.flyDir = vec2(cos(alpha),sin(alpha))
end
else
if self.tfBeat<ElapsedTime then self:wingBeat(rnd()*0.3+0.2) end
if self.flyType == "random" then 
    if rnd(30)==1 then 
        self:turn() 
        alpha = self.r + pi/2
        self.flyDir = vec2(cos(alpha),sin(alpha))
    end
    local limit = DeltaTime/0.016
    if rnd()<limit/300 then  self.flying=false end
end
if self.x <0     then self.x = self.x + WIDTH end
if self.x >WIDTH then self.x = self.x - WIDTH end
if self.y<0      then self.y = self.y + HEIGHT end
if self.y>HEIGHT then self.y = self.y - HEIGHT end
local dir,speed = self.flyDir,self.flySpeed
self.x = self.x + dir.x * speed * DeltaTime
self.y = self.y + dir.y * speed * DeltaTime
self:redraw()
end
end

function Butterfly:touched(touch)
if vec2(touch.x,touch.y):dist(vec2(self.x,self.y))<80 then 
self:fly("random",touch,2) end
end





--# Main
-- 0  papillon

displayMode(FULLSCREEN)

-- Use this function to perform your initial setup
function setup()
papillons = Butterflies(300)
end

-- This function gets called once every frame
function draw()
-- This sets a dark background color 
background(68, 68, 68, 255)
papillons:draw()
end
function touched(touch)
papillons:touched(touch)
end