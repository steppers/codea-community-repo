--simple lemmings clone with all the basic skills.  All images used are shipped with Codea.  Not an exact clone, rough and ready in places. No scrolling and no finite state machine control but basics demonstrateed.
--by West

--alternative selection
--use tap or drag to select active men then click on buttons to apply to them. use arrows to indicate selectiom
displayMode(FULLSCREEN)
function setup()
    FALL=1
    WALK=2
    DOWNDIG=3
    FLOAT=4
    BLOCK=5
    DIAGDIG=6
    CLIMB=7
    SIDEDIG=8
    BRIDGE=9
    img=image(WIDTH,HEIGHT)
    bg1=CreateLandscape(WIDTH,HEIGHT/6,color(255,122,6),50)
    bg2=CreateLandscape(WIDTH,HEIGHT/6,color(55,122,60),80)
    setContext(img)
    background(0)
    sprite(bg1,WIDTH/2,HEIGHT/4)
    sprite(bg2,WIDTH/2,HEIGHT/2)
    fill(40, 118, 35, 255)
    rect(0,5*HEIGHT/12,300,200)
    setContext()
    
    manimg={}
    manimg[1]=readImage("Platformer Art:Guy Standing")
    manimg[2]=readImage("Platformer Art:Guy Look Right")
    manimg[3]=readImage("Platformer Art:Guy Standing")
    manimg[4]=readImage("Platformer Art:Guy Standing")
    manimg[5]=readImage("Platformer Art:Hill Short")
    manimg[6]=readImage("Platformer Art:Guy Look Right")
    manimg[7]=readImage("Platformer Art:Guy Look Right")
    manimg[8]=readImage("Platformer Art:Guy Look Right")
    manimg[9]=readImage("Platformer Art:Guy Jump")
    
    man={}
    particles={}
    startx=150
    starty=650
    endx=850
    endy=220
    release=500
    releaseRate=500
    saved=0
    
    minFPS=60
    buttons={}
    numbuttons=11
    butimg=readImage("Tyrian Remastered:Ring")
    for i=1,numbuttons do
        table.insert(buttons,{x=200+(i-0.5)*(WIDTH-400)/numbuttons,y=HEIGHT-50,sel=0,img=butimg})
    end
    buttons[1].img=readImage("Tyrian Remastered:Explosion Huge")
    buttons[2].img=readImage("Tyrian Remastered:Drill")
    buttons[3].img=readImage("Platformer Art:Cloud 1")
    buttons[4].img=readImage("Platformer Art:Mushroom")
    buttons[5].img=readImage("Platformer Art:Hill Short")
    buttons[6].img=readImage("Space Art:Part Green Wing 4")
    buttons[7].img=readImage("Platformer Art:Spikes")
    buttons[8].img=readImage("Cargo Bot:Command Right")
    buttons[9].img=readImage("Platformer Art:Fence")
    buttons[10].img=readImage("Space Art:Green Explosion")
    buttons[11].img=readImage("Space Art:Red Explosion")
    
end

function draw()
    sprite(img,WIDTH/2,HEIGHT/2)
    releaseMen()
    drawMen()
    drawParticles()
    sprite("Cargo Bot:Crate Yellow 1",startx,starty,40,40)
    sprite("Small World:Flag",endx,endy,30,40)
    drawMenu()
    fps()
end

function drawMenu()
    for i,b in pairs(buttons) do
        if b.sel==1 then
            sprite("Cargo Bot:Crate Goal Yellow",b.x,b.y,(WIDTH-400)/numbuttons)
        else
            sprite("Cargo Bot:Crate Goal Blue",b.x,b.y,(WIDTH-400)/numbuttons)
        end
        sprite(b.img,b.x,b.y,30,30)
    end
end

function fps()
    --borrowed from @Ignatz
    FPS=(FPS or 60)*0.9+0.1/DeltaTime
    minFPS=math.min(minFPS,FPS)
    fontSize(14)
    text("FPS "..math.floor(FPS),WIDTH-100,HEIGHT-30)
    text("min FPS "..math.floor(minFPS),WIDTH-100,HEIGHT-50)
    text("Saved "..saved,100,HEIGHT-30)
    text("Out "..#man,100,HEIGHT-50)
    text("Rate "..releaseRate,100,HEIGHT-70)
end

function releaseMen()
    release = release + 1
    if release>releaseRate then
        table.insert(man,{x=startx,y=starty,f=1,fuse=0,state=FALL,a=0,adir=1,action=0,fall=0,floater=0,climber=0,brick=0})
        release=0
    end
end

function drawMen()
    fill(255)
    noStroke()
    noSmooth()
    for i,p in pairs(man) do
        if p.fuse>0 then
            tint(255,255-p.fuse,255-p.fuse)
            p.fuse = p.fuse + 2
            if p.fuse>254 then
                explode(p.x,p.y+5)
                p.fuse=0
                table.remove(man,i)
                sound("Game Sounds One:Pop 2")
            end
        end
        pushMatrix()
        translate(p.x,p.y+7)
        rotate(p.a)
        sprite(manimg[p.state],0,0,p.f*65/5,92/5)
        popMatrix()
        noTint()
    end
    
    for i,p in pairs(man) do
        if p.y>1 and p.x>1 and p.x<WIDTH-1 then
            if p.x==endx-7 and math.abs(p.y-endy)<30 then
                saved = saved + 1
                table.remove(man,i)
                sound("Game Sounds One:Female Cheer 2")
            end
            if p.state~=BRIDGE then
                p.brick=0
            end
            local r,g,b,a=img:get(p.x,p.y)
            local rl,gl,bl,al=img:get(p.x-1,p.y+1)
            local s=r+g+b
            local sl=rl+gl+bl
            if s==0 and p.state~=CLIMB then
                if p.floater==1 then
                    if p.state~=FLOAT then
                        p.a=0
                    end
                    p.state=FLOAT
                    p.fall=0
                else
                    p.state=FALL
                    p.fall = p.fall + 1
                end
                local rb,gb,bb,ab=img:get(p.x,p.y-1)
                if rb+gb+bb==0 then
                    if p.state==FALL then
                        p.y = p.y - 2
                        p.a = p.a - p.f*3
                    else
                        p.y = p.y -1
                        p.a = p.a + p.adir
                        if p.a>30 or p.a<-30 then
                            p.adir = p.adir * -1
                        end
                    end
                else
                    p.y = p.y -1
                end
                
            elseif p.state==DOWNDIG then
                --have a delay between digging actions
                p.action = p.action + 1
                if p.action>10 then
                    p.y = p.y - 1
                    downdig(p.x,p.y)
                    p.action=0
                    sound("Game Sounds One:Kick")
                end
            elseif p.state==SIDEDIG then
                --have a delay between digging actions
                p.action = p.action + 1
                if p.action>10 then
                    --check to see if there is breakthrough before removing the dirt
                    local rb,gb,bb,ab=img:get(p.x+6*p.f,p.y+2)
                    local sb=rb+gb+bb
                    if sb==0 then
                        p.state=WALK
                    end
                    
                    p.x=p.x+2*p.f
                    diagdig(p.x+5*p.f,p.y+10)
                    p.action=0
                    sound("Game Sounds One:Kick")
                end
            elseif p.state==BLOCK then
                --maintain state      
            elseif p.state==DIAGDIG then
                --have a delay between digging actions
                p.action = p.action + 1
                p.a=60*p.f
                if p.action>10 then
                    p.y = p.y - 1
                    p.x = p.x + 2*p.f
                    diagdig(p.x+4*p.f,p.y+7)
                    p.action=0
                    sound("Game Sounds One:Kick")
                end
            elseif p.state==BRIDGE then
                p.action = p.action + 1
                if p.action>20 then
                    p.y = p.y + 3
                    p.x = p.x + 5*p.f
                    laybrick(p.x+2*p.f,p.y,p.f)
                    p.action=0
                    p.brick = p.brick + 1
                    if p.brick>12 then
                        sound("A Hero's Quest:Sword Hit 1")
                    else
                        sound("Game Sounds One:Knock 1")
                    end
                    if p.brick>=15 then
                        p.state=WALK
                        p.brick=0
                    end
                    
                    --check for head bump and side bump
                    local ru,gu,bu,au=img:get(p.x-1*p.f,p.y+10)
                    local su=ru+gu+bu
                    local rs,gs,bs,as=img:get(p.x+1*p.f,p.y+5)
                    local ss=rs+gs+bs
                    
                    if su~=0 or ss~=0 then
                        p.f = p.f * -1
                        p.x = p.x + 2*p.f
                        p.state=WALK
                    end
                end
                
            else
                if p.fall>100 then
                    splut(p.x,p.y)
                    table.remove(man,i)
                    sound("A Hero's Quest:Drink 1")
                end
                p.fall=0
                p.state=WALK
                p.a=0
                local rs,gs,bs,as=img:get(p.x+1*p.f,p.y+5)
                local rr,gr,br,ar=img:get(p.x+1*p.f,p.y+1)
                local ss=rs+gs+bs
                local sr=rr+gr+br
                if ss==0 then
                    p.x = p.x + 1*p.f
                    if sr~=0 then
                        p.y = p.y + 1
                    end
                elseif as==253 and p.f==-1 then
                    p.x = p.x + p.f*1
                elseif as<255 and as>240 and p.f==1 then
                    p.x = p.x + p.f*1
                else
                    if p.climber==1 then
                        p.state=CLIMB
                        p.y = p.y + 1
                        p.a=90*p.f
                        --have I reached the top?
                        if ss==0 then
                            p.state=WALK
                            p.x = p.x + 10*p.f
                        else
                            --check for head bump
                            local ru,gu,bu,au=img:get(p.x-1*p.f,p.y+10)
                            local su=ru+gu+bu
                            if su~=0 then
                                p.x = p.x - p.f*1
                                p.f = p.f * -1
                                p.state=FALL
                            end
                        end
                    else
                        --turn around, bright eyes
                        p.f = p.f * -1
                    end
                end
            end
            --check against blockers
            for i,m in pairs(man) do
                if p.x+3*p.f-m.x<0 and p.x+3*p.f-m.x>-3 and math.abs(p.y-m.y)<10 and m.state==BLOCK then
                    p.f = p.f * -1
                end
            end
        end
        if p.x>WIDTH-3 or p.x<3 then
            p.f = p.f * -1
            p.x = p.x + 1*p.f
        end
    end
end

function drawParticles()
    for i,p in pairs(particles) do
        tint(p.r,p.g,p.b,p.fade)
        sprite("Cargo Bot:Star",p.x,p.y,3)
        p.x=p.x+p.spd*math.sin(math.rad(p.a))
        p.y=p.y+p.spd*math.cos(math.rad(p.a))
        p.y = p.y - p.grav
        p.grav = p.grav + 1
        noTint()
        p.fade = p.fade - 5
        if p.fade<0 then
            table.remove(particles,i)
        end
    end
end

function touched(t)
    if t.state==ENDED or t.state==MOVING then
        if t.y>HEIGHT-100 then
            for i,b in pairs(buttons) do
                b.sel=0
                if math.abs(t.x-b.x)<((WIDTH-400)/numbuttons)/2 then
                    b.sel=1
                    if i==4 and t.tapCount==2 then
                        --armageddon
                        for i,p in pairs(man) do
                            p.fuse=1
                        end
                    elseif i==10 then
                        releaseRate = releaseRate - 1
                        if releaseRate<10 then releaseRate=10 end
                    elseif i==11 then
                        releaseRate = releaseRate + 1
                        if releaseRate>500 then
                            releaseRate=500
                        end
                    end
                end
            end
        else
            for i,p in pairs(man) do
                if vec2(p.x,p.y):dist(vec2(t.x,t.y))<20 and p.fuse==0 then
                    if buttons[1].sel==1 then
                        p.fuse=1
                    elseif buttons[2].sel==1 then
                        p.state=DOWNDIG
                    elseif buttons[3].sel==1 then
                        p.floater=1
                    elseif buttons[5].sel==1 then
                        p.state=BLOCK
                    elseif buttons[6].sel==1 then
                        p.state=DIAGDIG
                    elseif buttons[7].sel==1 then
                        p.climber=1
                    elseif buttons[8].sel==1 then
                        p.state=SIDEDIG
                    elseif buttons[9].sel==1 then
                        p.state=BRIDGE
                        
                    end
                end
            end
        end
    end
    
    --for destroying scenery
    --[[
    if t.state==ENDED or t.state==MOVING then
        setContext(img)
        clip(t.x-10,t.y-10,21,21)
        fill(0)
        ellipse(t.x,t.y,20)
        clip()
        setContext()
    end
]]--
end

function explode(ex,ey)
setContext(img)
clip(ex-20,ey-20,41,41)
fill(0)
ellipse(ex,ey,40)
clip()
setContext()
for i=0,360,10 do
table.insert(particles,{x=ex,y=ey,a=i,spd=10+math.random(10),fade=255,r=math.random(255),g=math.random(255),b=math.random(255),grav=0})
end
end

function splut(ex,ey)
for i=-90,90,5 do
table.insert(particles,{x=ex,y=ey,a=i,spd=5+math.random(5),fade=255,r=math.random(255),g=math.random(255),b=math.random(255),grav=0})
end
end

function downdig(ex,ey)
setContext(img)
clip(ex-10,ey,21,5)
fill(0)
rect(ex-10,ey,21,5)
clip()
setContext()
end

function diagdig(ex,ey)
setContext(img)
clip(ex-20,ey-20,41,41)
fill(0)
ellipse(ex,ey,20)
clip()
setContext()
end

function laybrick(ex,ey,f)
ey=ey-1
setContext(img)
clip(ex-5,ey-4,21,6)
if f==1 then
fill(235, 210, 19, 254)
else
fill(225, 56, 30, 253)
end
--   blendMode(ZERO, ONE_MINUS_SRC_ALPHA)
noSmooth()
blendMode(SRC_ALPHA,ZERO)
rect(ex-5,ey-4,10,5)
blendMode(NORMAL)
smooth()
clip()
setContext()
end

--code from @Ignatz for mountain generation
--x,y is start tile; ww,hh are width and height of landscape
--in tiles; c is colour, rr is roughness of landscape (I used rr=2)
function CreateLandscape(w,h,c,r)
--create blank image and draw landscape
local i=image(w,h)
setContext(i)
strokeWidth(1)
stroke(c)
--use a random number to make the results slightly different
--each time, by adding it to the x value we provide
local z=math.random()
--draw a series of vertical lines. pixel by pixel
for c=1,w do
local a=h-r+r*noise(z+c/200)
line(c,1,c,a)
end
--add in a vertical wall obstacle
local posx=200+math.random(WIDTH-400)
rect(posx,0,10,600)
rect(posx-20,120,100,10)
setContext()
return i
end