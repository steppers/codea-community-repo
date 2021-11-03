
--# Main


-- Meshchopper

--various goals
--chop without letting fragments on screen go above a certain amount
--get x fragments on screen at once
--use limited number of slashes
--time limits
displayMode(FULLSCREEN)

-- Use this function to perform your initial setup
function setup()
    --chop a subsection of the following sprite to look a bit like ice
    bg=readImage("Tyrian Remastered:Space Ice 5")
    bg2=bg:copy(20,20,55,55)
    
    --tables to hold the touch interactions
    slash={}
    slashcount=0
    touches={}
    tsup={}
    
    --table to hold information about each fragment/polygon
    fragments={}
    --the initial shape. Currently works for convex polygons where internal angles are less than 180 degrees
    --in future would like to expand to include concave ones too
    --simple rectangle
    --pt={vec2(0,0),vec2(0,1),vec2(1,1),vec2(1,0)}
    
    --generate a regular polygon with vn sides
    pt={}
    local vn=10
    for i=1,vn do
        local va=math.rad((i-1)*360/vn)
        local vx=0.5+0.5*math.sin(va)
        local vy=0.5+0.5*math.cos(va)
        table.insert(pt,vec2(vx,vy))
    end
    --add initial polygon
    table.insert(fragments,Part(WIDTH/2-150,HEIGHT/2-150,0,0,300,pt,math.rad(0),0.01,1,1))
    table.insert(fragments,Part(WIDTH/4-100,HEIGHT/2-150,0,0,200,pt,math.rad(0),0.02,1,1))
    table.insert(fragments,Part(3*WIDTH/4-100,HEIGHT/2-150,0,0,200,pt,math.rad(0),0.02,1,1))
    --variables to limit the slashes interacting with newly generated fragments
    spawndelay=0
    spawndelaymarker=0
    
    --variables for holding the slash line parameters
    linestarty=-10
    ncc=-10
    
    particles={} -- a table to hold the particles
    
end

-- This function gets called once every frame
function draw()
    spawndelay = spawndelay - 1
    -- This sets a dark background color
    background(40, 40, 50)
    strokeWidth(5)
    --loop through each fragment and draw it
    for i,b in pairs(fragments) do
        b:draw()
    end
    --draw active slashes onscreen
    for i,s in pairs(slash) do
        pushMatrix()
        translate(s.x,s.y)
        rotate(math.deg(s.a)-90)
        stroke(255,255,255,s.fade)
        fill(255,255,255,s.fade)
        line(0,0,0,-20)
        local wing=255-s.fade
        stroke(255,255,255,s.fade/2)
        fill(255,255,255,s.fade/2)
        line(0,0,wing,-2000)
        line(0,0,-wing,-2000)
        stroke(255,255,255,s.fade/3)
        fill(255,255,255,s.fade/3)
        line(0,0,2*wing,-2000)
        line(0,0,-2*wing,-2000)
        local linespd=20
        s.x = s.x + linespd*math.cos(s.a)
        s.y = s.y + linespd*math.sin(s.a)
        s.fade = s.fade - 5
        if s.fade<0 then table.remove(slash,i) end
        popMatrix()
        
        if s.active==1 then
            s.active=0
        end
    end
    
    fill(255)
    doParticles()
    
    --clean up by removing any pieces with an active flag of 0
    for i,b in pairs(fragments) do
        if b.active==0 then
            table.remove(fragments,i)
        end
    end
    --display some game variables
    font("AmericanTypewriter")
    text("Fragments "..#fragments,WIDTH/4,0.95*HEIGHT)
    text("Swipes "..slashcount,0.75*WIDTH,0.95*HEIGHT)
    line(WIDTH,linestarty,0,ncc)
end


function touched(touch)
    if touch.state==MOVING then
        --record path
        if tsup[touch.id]~=nil then
            table.insert(tsup[touch.id].path,{pos=vec2(touch.x,touch.y),age=ElapsedTime})
        end
    end
    if touch.state==ENDED or touch.state==CANCELLED then
        processTouch(touch)
        touches[touch.id] = nil
        tsup[touch.id]=nil
    else
        touches[touch.id] = touch
        --if there is no supplementary info associated with the current touch then add it
        if tsup[touch.id]==nil then
            tsup[touch.id]={tstartx=touch.x,tstarty=touch.y,starttime=ElapsedTime,path={}}
        end
    end
end

function processTouch(touch)
    
    if true==true then
        if ElapsedTime-tsup[touch.id].starttime<0.2 then
            --very short event
            if tsup[touch.id]==nil  then
                --recognises tap but no function yet
                sound("Game Sounds One:Slap")
            elseif vec2(touch.x,touch.y):dist(vec2(tsup[touch.id].tstartx,tsup[touch.id].tstarty))<10  then
                --recognises tap but no function yet
                sound("Game Sounds One:Slap")
            else                
                local ang=math.atan2(touch.y-tsup[touch.id].tstarty,touch.x-tsup[touch.id].tstartx)
                table.insert(slash,{x=tsup[touch.id].tstartx,y=tsup[touch.id].tstarty,a=ang,fade=255,count=0,active=1})
                slashcount = slashcount + 1
                sound("Game Sounds One:Blaster")
                --check to see if it splits any objects
                local mm=((touch.y-tsup[touch.id].tstarty)/(touch.x-tsup[touch.id].tstartx))
                local cc=-touch.x*mm+touch.y
                --prevent from getting caught in a loop
                local partcount=#fragments
                for i,b in pairs(fragments) do
                    if i<=partcount then
                        b:touched(touch,mm,cc)
                    end
                end
                if spawndelaymarker>0 then
                    spawndelay=10
                    spawndelaymarker=0
                end                
            end
        end
    end
    
end

--# Part
Part = class()

function Part:init(x,y,xdir,ydir,size,ptable,a,s,tin,trapped)
    --currently one mesh per fragment - use a global mesh to increase performance?
    self.m=mesh()
    self.m.texture=bg2
    self.points=ptable
    self.pts={}
    self.x=x
    self.y=y
    self.size=size
    self.xdir=xdir
    self.ydir=ydir
    self.active=1
    local cxtotal=0
    local cytotal=0
    --calculate centroid
    for i,p in pairs(self.points) do
        cxtotal = cxtotal + p.x
        cytotal = cytotal + p.y
    end
    self.cx=cxtotal/#self.points
    self.cy=cytotal/#self.points
    --manual override over centroid - currently causes issues with spawn position
    self.cx=0.5
    self.cy=0.5
    self.angle=a
    self.spin=s --rotational speed
    self.type=tin
    self.fade=100
    self.col={}
    self.trapped=trapped
end

function Part:draw()
    -- Codea does not automatically call this method
    self.angle = self.angle + self.spin
    self.m:clear()
    
    t=triangulate(self.points)
    
    for i,p in pairs(t) do
        local ptemp=p
        ptemp=ptemp-vec2(self.cx,self.cy)
        ptemp=ptemp:rotate(self.angle)
        ptemp=ptemp+vec2(self.cx,self.cy)
        self.pts[i]=vec2(ptemp.x*self.size+self.x,ptemp.y*self.size+self.y)
        
        --setting each triangle as a different color
        --[[
        if i%3==1 then
            ranb=155+math.random(100)
            ranr=50+math.random(ranb-50)
            rang=50+math.random(ranb-50)
            rana=100+math.random(155)
        end
        if self.col[i]==nil then
            --     self.col[i]=color(math.random(255),math.random(255),math.random(255),math.random(255))
            self.col[i]=color(ranr,rang,ranb,rana)
        end
    ]]--
end


self.y=self.y+self.ydir
self.x=self.x+self.xdir
if self.y+(self.cy*self.size)>HEIGHT or self.y+(self.cy*self.size)<0 then
self.ydir = self.ydir * -1
end
if self.x+(self.cx*self.size)>WIDTH or self.x+(self.cx*self.size)<0 then
self.xdir = self.xdir * -1
end
self.m.vertices=self.pts
--replaces the setColors call if individual triangles are being colored
--self.m.colors=self.col
self.m:setColors(255,255,255,200)
self.m.texCoords=t

--add a flag which tracks where the person is
--always starts in the centre so ok - will likely cause issues if using a non texture centre
if self.trapped==1 then
pushMatrix()
translate(self.cx*self.size+self.x,self.cy*self.size+self.y)
rotate(math.deg(self.angle))
tint(155,200,255)
sprite("Platformer Art:Guy Standing",0,0,65/2,92/2)
noTint()
popMatrix()
end
self.m:draw()
end

function Part:touched(touch,mm,cc)
-- go round the points and see if any cross the boundary
--remember toclose the loop by checking the last point with the first
if spawndelay<0 then
splits={}
--this area is currently based on the texture map rather than scaled to the size of the polygon

local arealimit=0.03
local arealimitmax=0.15
--loop round the sides and check to see if the line of the slash intercepts a side - if so log its position to set it as a split point
for i=1,#self.points do
    cp=i --current point position
    np=i+1 --nextpoint position
    if i==#self.points then np=1 end
    --fairly rough and ready - could do with cleaning up
    cptemp=self.points[cp]
    nptemp=self.points[np]
    --move and rotate the points to their actual screen position
    cptemp=cptemp-vec2(self.cx,self.cy)
    cptemp=cptemp:rotate(self.angle)
    cptemp=cptemp+vec2(self.cx,self.cy)
    nptemp=nptemp-vec2(self.cx,self.cy)
    nptemp=nptemp:rotate(self.angle)
    nptemp=nptemp+vec2(self.cx,self.cy)
    
    cpx=cptemp.x*self.size+self.x
    cpy=cptemp.y*self.size+self.y
    npx=nptemp.x*self.size+self.x
    npy=nptemp.y*self.size+self.y
    cpnewy=cpx*mm+cc
    npnewy=npx*mm+cc
    ncc=cc
    linestarty=WIDTH*mm+cc
    if (cpnewy-cpy<0 and npnewy-npy>0) or (cpnewy-cpy>0 and npnewy-npy<0) then
        local a1 = cpy-npy
        local b1 = npx-cpx
        local c1 = a1*npx+b1*npy
        
        local a2 =linestarty-cc
        local b2=    0-WIDTH
        local c2=a2*0+b2*cc
        
        local det = a1*b2 - a2*b1
        local sx = (b2*c1 - b1*c2)/det
        local sy = (a1*c2 - a2*c1)/det
        
        --unwind the rotation
        local nptemp=vec2((sx-self.x)/self.size,(sy-self.y)/self.size)
        nptemp=nptemp-vec2(self.cx,self.cy)
        nptemp=nptemp:rotate(-self.angle)
        nptemp=nptemp+vec2(self.cx,self.cy)
        
        table.insert(splits,{pos=np,pt=nptemp})
    end
    
end
--need to reorder to ensure highest order is first
table.sort(splits,greaterthanpos)

split1=nil
split2=nil
for i,s in pairs(splits) do
    table.insert(self.points,s.pos,s.pt)
    if split2==nil then
        split2=s.pos+1
    else
        split1=s.pos
    end
end

if split1~=nil and split2~=nil then
    --create two new tables of points based on the previously defined split points
    --first fragment
    local p1={}
    local p2={}
    local c1=1
    local c2=1
    for i=1,#self.points do
        if i>=split1 and i<=split2 then
            p1[c1]=self.points[i]
            c1 = c1 + 1
        end
        if i<=split1 or i>=split2 then
            p2[c2]=self.points[i]
            c2 = c2 + 1
        end
    end
    --second fragment
    local ptx1=0
    local pty1=0
    local area1=0
    for i,p in pairs(p1) do
        ptx1 = ptx1 + p.x
        pty1 = pty1 + p.y
        if i>1 then
            area1 = area1 + ((p.x+p1[i-1].x)*(p1[i-1].y-p.y))
        else
            area1 = area1 + ((p.x+p1[#p1].x)*(p1[#p1].y-p.y))
        end
    end
    area1=area1/2
    ptx1 = ptx1/#p1
    pty1 = pty1/#p1
    
    local ptx2=0
    local pty2=0
    local area2=0
    for i,p in pairs(p2) do
        ptx2 = ptx2 + p.x
        pty2 = pty2 + p.y
        if i>1 then
            area2 = area2 + ((p.x+p2[i-1].x)*(p2[i-1].y-p.y))
        else
            area2 = area2 + ((p.x+p2[#p2].x)*(p2[#p2].y-p.y))
        end
    end
    area2=area2/2
    ptx2 = ptx2/#p2
    pty2 = pty2/#p2
    
    --check to see if the new fragments contain a trapped person
    local tr1=0
    local tr2=0
    local freed=0
    if self.trapped==1 then
        
        if (pnpoly(p1,self.cx,self.cy))==1 then
            tr1=1
            if area1<arealimitmax and area1>arealimit then
                freedom(self.x+self.cx*self.size,self.y+self.cy*self.size,10,self.angle)
                freed=1
                freeman(self.x+self.cx*self.size,self.y+self.cy*self.size,self.angle)
            end
        else
            if area2<arealimitmax and area2>arealimit then
                freedom(self.x+self.cx*self.size,self.y+self.cy*self.size,10,self.angle)
                freed=1
                freeman(self.x+self.cx*self.size,self.y+self.cy*self.size,self.angle)
            end
            tr2=1
        end
    end
    
    
    --should be able to pick any point from p1 and check to see if it needs to move away from the split line
    --same shold be true of the transposed centre
    local  tran=vec2(ptx1,pty1)
    tran = tran - vec2(self.cx,self.cy)
    tran=tran:rotate(self.angle)
    tran = tran + vec2(self.cx,self.cy)
    
    tranx=self.x+tran.x*self.size
    trany=self.y+tran.y*self.size
    
    testy=mm*(self.x+tran.x*self.size)+cc
    testx=((self.y+tran.y*self.size)-cc)/mm
    
    xsign=1
    ysign=1
    if testx<=tranx then
        xsign=1
    else
        xsign=-1
    end
    if testy<=trany then
        ysign=1
    else
        ysign=-1
    end
    
    
    --calculate normals to the slash line
    local atemp=math.atan((ncc-linestarty)/(0-WIDTH))+math.rad(90)
    --volume determines speed
    local spd1=(1-area1)*5
    local spd2=(1-area2)*5
    
    if #p1>2 then
        if area1<arealimit or freed==1 then
            explodeStar(tranx,trany,10)
            
            if tr1==1 then
                --killed the man
                --print("fail")
            end
        else
            --need to add spin too - current default 0
            
            table.insert(fragments,Part(self.x,self.y,xsign*spd1*math.abs(math.cos(atemp)),ysign*spd1*math.sin(atemp),self.size,p1,self.angle,xsign*0.01,1,tr1))
        end
    end
    if #p2>2 then
        if area2<arealimit or freed==1 then
            
            local pp=vec2(ptx2,pty2)
            pp=pp-vec2(self.cx,self.cy)
            pp=pp:rotate(self.angle)
            pp=pp+vec2(self.cx,self.cy)
            explodeStar(self.x+pp.x*self.size,self.y+pp.y*self.size,10)
            
            if tr2==1 then
                --killed the man
                --print("fail")
            end
        else
            table.insert(fragments,Part(self.x,self.y,-xsign*spd2*math.abs(math.cos(atemp)),-ysign*spd2*math.sin(atemp),self.size,p2,self.angle,-xsign*0.01,1,tr2))
        end
    end
    self.active=0
    spawndelaymarker=1
    
    split1=nil
    split2=nil
end
end

end

function greaterthanpos(a, b)
return a.pos > b.pos
end

--test to see if a point lies within a polygon
function pnpoly(pts,testx,testy)
j=#pts
oddNodes=-1
for i=1,#pts do
if (pts[i].y<testy and pts[j].y>=testy or  pts[j].y<testy and pts[i].y>=testy) then
    if (pts[i].x+(testy-pts[i].y)/(pts[j].y-pts[i].y)*(pts[j].x-pts[i].x)<testx) then
        oddNodes = oddNodes * -1
    end
end
j=i
end
return oddNodes
end



--# Particles


function doParticles()
--loop through the particle table
for i,p in pairs(particles) do
pushMatrix()
tint(255,255,255,p.fade)  --set the transparency of the particle based on its fade property
translate(p.x,p.y) --- move it to the correct position
rotate(p.rotation) --rotate it by the coorect amount
sprite(p.img,0,0,p.w,p.h) --draw the particle
noTint() -- remove transparencies
popMatrix()
--if the particle is a star or smoke then fade it out
if p.type<3 then
    p.fade = p.fade -3
    --if the star or smoke has faded to invisible then remove it
    if p.fade<0 then
        table.remove(particles,i)
    end
else
    p.fade = p.fade - 1
    if p.fade<0 then
        table.remove(particles,i)
    end
end
--rotate the particle
p.rotation = p.rotation + p.rotspd
--adjust the position of the particle
p.x = p.x + p.xspd
p.y = p.y + p.yspd

--if the particle is smoke then increase the size of it
if p.type==2 then
    if math.random(20)==1 then
        freedom(p.x,p.y,10+math.random(20),p.rotation)
    end
end


end
end
function explodeStar(xin,yin,sizein)
--generate an explosion at position xin,yin with sizein indicating the density of the explosion.
--stars
for a=1,360,sizein do
local spd=1+math.random(100)/10
local s=math.random(20)+5
table.insert(particles,{img="Cargo Bot:Star",x=xin,y=yin,w=s,h=s,angle=a,fade=255,rotation=0, rotspd=-4+math.random(7),xspd=spd*math.sin(math.rad(a)),yspd=spd*math.cos(math.rad(a)),type=1})
--        table.insert(particles,{img="Project:snowflake",x=xin,y=yin,w=s,h=s,angle=a,fade=255,rotation=0, rotspd=-4+math.random(7),xspd=spd*math.sin(math.rad(a)),yspd=spd*math.cos(math.rad(a)),type=1})
end
end

function freedom(xin,yin,sizein,anglein)
--generate an explosion at position xin,yin with sizein indicating the density of the explosion.
--stars
for b=1,360,sizein do

a=anglein-10+math.random(20)

local spd=-(math.random(10)+5)
local s=20

table.insert(particles,{img="Cargo Bot:Star Filled",x=xin,y=yin,w=s,h=s,angle=a,fade=255,rotation=0, rotspd=-4+math.random(7),xspd=spd*math.sin(math.rad(a)),yspd=spd*math.cos(math.rad(a)),type=1})

end
end

function freeman(xin,yin,anglein)
spd=1
a=anglein
sprite("Platformer Art:Guy Standing")
table.insert(particles,{img="Platformer Art:Guy Standing",x=xin,y=yin,w=65/2,h=92/2,angle=a,fade=255,rotation=0, rotspd=0,xspd=spd*math.sin(math.rad(a)),yspd=spd*math.cos(math.rad(a)),type=3})
end