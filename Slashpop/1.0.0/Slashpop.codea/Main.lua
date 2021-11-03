--Slash, Pop, Spin & Squash
-- by West
-- basic game framework in place.  Flick on the screen to slash - create a vertical line slash through the V Slash rectangles, and a horizontal line through the H Slash ones
--Tap inside the rectangle to destroy the Pop ones. Draw a circle (making sure start and end meets) to destroy the spin rectangles.  Pinch screen inside rectangle to destry the Pinch ones.
function setup()
    displayMode(FULLSCREEN)
    READY=1
    PLAYING=2
    LEVELCOMPLETE=3
    GAMEOVER=4
    gamestate=READY
    
    --create a texture image
    tex=image(500,100)
    setContext(tex)
    
    --vertical slash
    fill(255, 21, 0, 255)
    rect(0,0,100,100)
    fill(0,234,255)
    text("V Slash",50,50)
    --horizontal slash
    fill(243, 255, 0, 255)
    rect(100,0,100,100)
    fill(12,0,255)
    text("H Slash",150,50)
    --pop
    fill(69, 255, 0, 255)
    rect(200,0,100,100)
    fill(186,0,255)
    text("Pop",250,50)
    --spin
    fill(0, 187, 255, 255)
    rect(300,0,100,100)
    fill(255,68,0)
    text("Spin",350,50)
    --pinch
    fill(238, 0, 255, 255)
    rect(400,0,100,100)
    fill(17,255,0)
    text("Squash",450,50)
    setContext()
    
    currentLevel=1
    objProgress=1
    level={}
    level[1]={obj={1,2,1,2,1,1,2,1,2,2,2,1},rate=0.1,startrate=1}
    level[2]={obj={3,3,3,1,1,2,2,1,2,2,1,2,2,1},rate=0.1,startrate=1}
    level[3]={obj={2,1,1,2,3,2,2,3,3,2,1,2,3,3,2,1,2,3,3,1},rate=0.1,startrate=1}
    level[4]={obj={4,4,4,4,4,4,4,4},rate=0.1,startrate=1}
    level[5]={obj={5,5,5,5,5,5,5,5},rate=0.1,startrate=1}
    level[6]={obj={2,1,1,2,1,2,2,1,1,1,2,1,2,2,1},rate=0.2,startrate=1.5}
    level[7]={obj={2,1,5,1,2,5,2,2,2,4,5,2,3,3,5,3,4,3,3,2,1,1,1},rate=0.1,startrate=1.5}
    level[8]={obj={2,1,1,2,1,2,2,1,1,1,2,1,2,2,1},rate=0.3,startrate=2.5}
    level[9]={obj={1,2,1,1,2,3,1,2,2,4,1,1,1,5,2,1,2,4,3,3,2,1},rate=0.3,startrate=2.5}
    level[10]={obj={1,2,3,5,1,1,2,5,3,1,2,2,4,1,1,4,1,5,2,1,2,5,3,3,2,1},rate=0.3,startrate=5}
    -- Create a new empty mesh
    triMesh = mesh()
    --  triMesh.texture=readImage("Project:icons")
    triMesh.texture=tex
    initialise()
    
    --from touch handler
    touches={}
    tsup={} --tsup contains the supplementary info about the start position of the touch
    points={}
    pulse={}
    slash={}
    circ={}
    prevtouch={sx=0,sy=0,x=0,y=0,t=ElapsedTime}
    pinch={}
    pinchtemp={}
    
    parameter.boolean("includeTrail",true)
    parameter.boolean("includeStart",false)
    parameter.boolean("includeDuration",false)
    parameter.boolean("includeHistory",false)
    parameter.boolean("joinHistory",false)
    parameter.boolean("includePulse",false)
    parameter.boolean("includeClassification",true)
    
    activetouches=0
    score=0
end

function initialise()
    x=WIDTH/2
    y=HEIGHT/2
    a=0
    a1=0
    a2=0
    size1=10
    size2=10
    texverts={}
    verts={}
    state=1
    adjx1=0
    adjy1=0
    adjx2=0
    adjy2=0
    kind=level[currentLevel].obj[objProgress]
    a=0
    
    ts=0.5
    bs=0.5
    ls=0.5
    rs=0.5
    mx=0.5
    my=0.5
    cwang=0
    cwdir=1
    cwspd=1
    fade=255
    sizespd=level[currentLevel].startrate    
end

-- This function gets called once every frame
function draw()
    if gamestate==PLAYING then
        play()
    elseif gamestate==READY then
        menu()
    elseif gamestate==LEVELCOMPLETE then
        levelover()
    elseif gamestate==GAMEOVER then
        gameoverscreen()
    end
    
end

function menu()
    background(33, 71, 148, 255)
    strokeWidth(2)
    fill(141, 127, 33, 255)
    text("Slash, Pop, Spin & Squash",WIDTH/2,HEIGHT/2)
    
    
end
function levelover()
    background(33, 71, 148, 255)
    strokeWidth(2)
    fill(141, 127, 33, 255)
    text("Level "..currentLevel.." complete",WIDTH/2,HEIGHT/2)    
end
function gameoverscreen()
    background(33, 71, 148, 255)
    strokeWidth(2)
    fill(141, 127, 33, 255)
    text("Game over. Final score "..score..".",WIDTH/2,HEIGHT/2)    
end
function play()
    -- Dark background color
    background(20, 20, 40)
    noStroke()
    fill(61, 119, 38, 255)
    rect(0,0,WIDTH,HEIGHT/2)
    
    --create as two halves then shift corner points?
    
    
    local topleft = vec2(0,1)
    local midleft = vec2(0,ls)
    local bottomleft = vec2(0,0)
    local topmid = vec2(ts,1)
    local bottomright = vec2(1,0)
    local midright = vec2(1,rs)
    local topright=vec2(1,1)
    local bottommid=vec2(bs,0)
    local mid=vec2(mx,my)
    
    size1 = size1 + sizespd
    if size1>500 then
        --this should be a gameover instead
        if state==1 then
            sound("Game Sounds One:Wrong")
            gamestate=GAMEOVER
        end
        
        
        resetTarget()
        
    end
    size2=size1
    if kind==1 then
        --factor in cw or ccw with negative plus check if upswipe or downswipe
        upswipe=1
        sepspin1=upswipe*10*((1-(ts+bs)/2))
        sepspin2=upswipe*10*(((ts+bs)/2))
        
        if state==2 then
            adjx1 = adjx1 - 0.01
            adjx2 = adjx2 + 0.01
            a1 = a1 + sepspin1
            a2 = a2 - sepspin2
        end
        
    elseif kind==2 then
        --factor in cw or ccw with negative plus check if upswipe or downswipe
        upswipe=1
        sepspin1=upswipe*10*((1-(ls+rs)/2))
        sepspin2=upswipe*10*(((ls+rs)/2))
        
        if state==2 then
            adjy1 = adjy1 + 0.01
            adjy2 = adjy2 - 0.01
            a1 = a1 + sepspin1
            a2 = a2 - sepspin2
        end
        
    elseif kind==3 then
        if state==2 then
            adjx1 = adjx1 + 0.1
            a1=a1+5
        end
    elseif kind==4 then
        if state==2 then
            --sin and cos of x and y adj based on end angle
            local cws=0.1*cwspd
            local cwrot=5*cwspd
            adjx1 = adjx1 + cws*math.cos((cwang+math.deg(90)))
            adjy1 = adjy1 + cws*math.sin((cwang+math.deg(90)))
            --alter for cw/ccw
            a1=a1-cwrot*cwdir
        end
    elseif kind==5 then
        if state==2 then
            --squash factor
            adjx1 = adjx1 + 0.02
            if adjx1>0.99 then adjx1=0.99 end
            --alter for cw/ccw
            a1=math.deg(cwang)
        end
    end
    
    
    
    if kind==1 then
        texverts = {topleft,bottomleft,bottommid,bottommid,topleft,topmid,topmid,bottommid,bottomright,bottomright,topmid,topright }
    elseif kind==2 then
        texverts = {topright,topleft,midleft,midleft,topright,midright,midright,midleft,bottomleft,bottomleft,midright,bottomright }
    elseif kind==3 then
        texverts = {midleft,topleft,mid,mid,topleft,topmid,topmid,topright,mid,mid,topright,midright,midright,bottomright,mid,mid,bottomright,bottommid,bottommid,bottomleft,mid,mid,bottomleft,midleft}
    elseif kind==4 then
        texverts={topleft,topright,bottomright,bottomright,topleft,bottomleft}
    elseif kind==5 then
        texverts = {midleft,topleft,mid,mid,topleft,topmid,topmid,topright,mid,mid,topright,midright,midright,bottomright,mid,mid,bottomright,bottommid,bottommid,bottomleft,mid,mid,bottomleft,midleft}
    end
    verts=texverts
    --deal with the post hit changes to the shape on a case by case basis
    
    
    --deal with the two slash cases
    if kind<3 then
        for i=1,6 do
            --adjust to be the centre of the new half based on horizontal or vertical slashes
            if kind==1 then
                verts[i] = verts[i] + vec2(-0.25,-0.5)
                verts[i]=verts[i]:rotate(math.rad(a1))
                verts[i] = verts[i] - vec2(-0.25,-0.5)
            elseif kind==2 then
                verts[i] = verts[i] + vec2(-0.5,-0.75)
                verts[i]=verts[i]:rotate(math.rad(a1))
                verts[i] = verts[i] - vec2(-0.5,-0.75)
            end
            verts[i] = (verts[i] + vec2(adjx1,adjy1))*size1
        end
        
        for i=7,12 do
            if kind==1 then
                verts[i] = verts[i] + vec2(-0.75,-0.5)
                verts[i]=verts[i]:rotate(math.rad(a2))
                verts[i] = verts[i] - vec2(-0.75,-0.5)
            elseif kind==2 then
                verts[i] = verts[i] + vec2(-0.5,-0.25)
                verts[i]=verts[i]:rotate(math.rad(a2))
                verts[i] = verts[i] - vec2(-0.5,-0.25)
            end
            verts[i] = (verts[i] + vec2(adjx2,adjy2))*size2
        end
        
    end
    a=0
    if kind==3 then
        for i=1,#verts do
            verts[i] = (verts[i] + vec2(adjx1*math.sin(math.rad(a)),adjx1*math.cos(math.rad(a))))            
            verts[i]=verts[i]*size1
            if math.fmod(i,3)==0 then
                a=a+45
            end
        end
    elseif kind==4 then
        for i=1,#verts do
            verts[i] = verts[i] + vec2(-0.5,-0.5)
            verts[i]=verts[i]:rotate(math.rad(a1))
            verts[i] = verts[i] - vec2(-0.5,-0.5)
            verts[i]=(verts[i]+vec2(adjx1,adjy1))*size1
        end
        
    elseif kind==5 then
        local squashfactor=1-adjx1
        local squash=0
        for i=1,#verts do
            --move to centre
            verts[i] = verts[i] + vec2(-0.5,-0.5)
            --rotate
            verts[i] = verts[i]:rotate(math.rad(a1))
            --squash
            if verts[i].y>squashfactor then
                squash = squash + (verts[i].y-squashfactor)
                verts[i].y = squashfactor
            end
            if verts[i].y<-squashfactor then
                squash = squash + (-squashfactor-verts[i].y)
                verts[i].y = -squashfactor
            end            
        end
        
        for i=1,#verts do
            
            if verts[i].x>0 then
                verts[i].x = verts[i].x + squash/10
            elseif verts[i].x<-0 then
                verts[i].x = verts[i].x - squash/10
            end           
            
            -- rotate back
            verts[i] = verts[i]:rotate(math.rad(-a1))
            --move back
            verts[i] = verts[i] - vec2(-0.5,-0.5)
            verts[i]=(verts[i])*size1          
        end        
    end
    
    
    triMesh.vertices=verts
    --recalibrate for the thin strip texture
    --assuming there are 5 kinds
    local m=(kind-1)/5
    local n=kind/5
    local topleft = vec2(m,1)
    local midleft = vec2(m,ls)
    local bottomleft = vec2(m,0)
    local topmid = vec2(m+ts/5,1)
    local bottomright = vec2(n,0)
    local midright = vec2(n,rs)
    local topright=vec2(n,1)
    local bottommid=vec2(m+bs/5,0)
    local mid=vec2(m+mx/5,my)
    
    if kind==1 then      
        triMesh.texCoords = { topleft,bottomleft,bottommid,bottommid,topleft,topmid,topmid,bottommid,bottomright,bottomright,topmid,topright }
    elseif kind==2 then        
        triMesh.texCoords = {topright,topleft,midleft,midleft,topright,midright,midright,midleft,bottomleft,bottomleft,midright,bottomright }
    elseif kind==3 then
        triMesh.texCoords = {midleft,topleft,mid,mid,topleft,topmid,topmid,topright,mid,mid,topright,midright,midright,bottomright,mid,mid,bottomright,bottommid,bottommid,bottomleft,mid,mid,bottomleft,midleft}       
    elseif kind==4 then        
        triMesh.texCoords={topleft,topright,bottomright,bottomright,topleft,bottomleft}        
    elseif kind==5 then
        triMesh.texCoords = {midleft,topleft,mid,mid,topleft,topmid,topmid,topright,mid,mid,topright,midright,midright,bottomright,mid,mid,bottomright,bottommid,bottommid,bottomleft,mid,mid,bottomleft,midleft}
    end
    triMesh:setColors(255,255,255,fade)
    -- Draw the mesh that we setup
    pushMatrix()
    translate(x,y)
    translate(-size1/2,-size1/2)
    triMesh:draw()
    popMatrix()
    
    a=a+1
    if state==2 then
        fade = fade - 4
        if fade<0 then
            resetTarget()
        end
    end
    --stuff from touch handler
    stroke(255)
    strokeWidth(2)
    --draw pinch animation
    for i,p in pairs(pinch) do
        
        if state==1 and kind==5 and p.x >x-size1/2 and p.x<x+size1/2 and p.y>y-size1/2 and p.y<y+size1/2 then
            
            cwang=p.ang+math.rad(90)
            sound("A Hero's Quest:Eat 1")
            state=2
            score = score + 1
        end
        
        for d=1,4 do
            stroke(255,255,255,255-(d-1)*50)
            line(
            p.x+p.mag*math.sin(p.ang)+d*p.dist*math.cos(p.ang),
            p.y+p.mag*math.cos(p.ang)+d*p.dist*math.sin(p.ang),
            p.x-p.mag*math.sin(p.ang)+d*p.dist*math.cos(p.ang),
            p.y-p.mag*math.cos(p.ang)+d*p.dist*math.sin(p.ang)
            )
            line(
            p.x+p.mag*math.sin(p.ang)-d*p.dist*math.cos(p.ang),
            p.y+p.mag*math.cos(p.ang)-d*p.dist*math.sin(p.ang),
            p.x-p.mag*math.sin(p.ang)-d*p.dist*math.cos(p.ang),
            p.y-p.mag*math.cos(p.ang)-d*p.dist*math.sin(p.ang)
            )
        end
        p.dist = p.dist - 2
        if p.dist<0 then
            table.remove(pinch,i)
        end
    end
    
    
    --draw circle animation
    stroke(255)
    noFill()
    for i,c in pairs(circ) do
        
        --check to see if pulse centre has activated the target
        if state==1 and kind==4 and c.centrex >x-size1/2 and c.centrex<x+size1/2 and c.centrey>y-size1/2 and c.centrey<y+size1/2 then
            
            cwang=math.atan(c.starty-c.centrey,c.startx-c.centrex)
            cwdir=1
            
            if c.cw==false then
                cwdir=-1
            end
            cwspd=math.max(0.3,c.duration)
            cwspd=(1-cwspd)*3
            
            state=2
            sound("Game Sounds One:Wheel 1")
            score = score + 1            
        end
        
        if c.cw==true then
            stroke(227, 25, 110, c.fade)
        else
            stroke(106, 255, 0, c.fade)
        end
        for d=1,10 do
            stroke(255,255,255,c.fade-(d-1)*20)
            if d<2 then
                ellipse(c.centrex,c.centrey,c.dia+20*d)
            end
            local dir=1
            if c.cw==true then
            else
                dir=-1
            end
            ellipse(c.centrex+c.dia*0.5*math.sin(math.rad(c.ang-d*dir*15)),c.centrey+c.dia*0.5*math.cos(math.rad(c.ang-d*dir*15)),c.dia/10)
        end
        c.dia = c.dia * 1.03
        c.fade = c.fade - 5
        if c.cw==true then
            c.ang = c.ang + 5
        else
            c.ang = c.ang - 5
        end
        if c.fade<0 then
            table.remove(circ,i)
        end
    end
    
    --draw slash animation
    for i,s in pairs(slash) do
        
        --   if state==1 and kind==2 then
        if state==1 and kind==2 and s.x >x-size1/2 and s.x<x+size1/2 and s.y>y-size1/2 and s.y<y+size1/2 then
            
            
            --y=mx+c
            --c=y-mx
            
            local mm=(math.tan(s.a))
            local cc=s.starty-mm*s.startx
            
            local  leftcross=mm*(x-size1/2)+cc
            local  rightcross=mm*(x+size1/2)+cc
            if leftcross>(y-size1/2) and leftcross<(y+size1/2) and rightcross>(y-size1/2) and rightcross<(y+size1/2) then
                ls=(leftcross-(y-size1/2))/size1
                rs=(rightcross-(y-size1/2))/size1 
                state=2
                sound("Game Sounds One:Whoosh 2")
                score = score + 1
            end
            
        end
        
        --           if state==1 and kind==1 then
        if state==1 and kind==1 and s.x >x-size1/2 and s.x<x+size1/2 and s.y>y-size1/2 and s.y<y+size1/2 then        
            --y=mx+c
            --c=y-mx
            
            local mm=(math.tan(s.a))
            local cc=s.starty-mm*s.startx
            
            local  topcross=((y+size1/2)-cc)/mm
            local  bottomcross=((y-size1/2)-cc)/mm
            if topcross>(x-size1/2) and topcross<(x+size1/2) and bottomcross>(x-size1/2) and bottomcross<(x+size1/2) then
                ts=(topcross-(x-size1/2))/size1
                bs=(bottomcross-(x-size1/2))/size1 
                state=2
                sound("Game Sounds One:Whoosh 3")
                score = score + 1
            end
            
        end
        
        pushMatrix()
        translate(s.x,s.y)
        rotate(math.deg(s.a)-90)
        stroke(255,255,255,s.fade)
        fill(255,255,255,s.fade)
        line(0,0,0,-2000)
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
    end
    --   rect(x-size1/2,y-size1/2,size1,size1)
    --draw any active touch pulses
    for i,p in pairs(pulse) do
        
        --check to see if pulse centre has activated the target
        if state==1 and kind==3 and p.x >x-size1/2 and p.x<x+size1/2 and p.y>y-size1/2 and p.y<y+size1/2 then
            
            mx=(p.x-(x-size1/2))/(size1)
            my=(p.y-(y-size1/2))/(size1)
            
            state=2
            sound("A Hero's Quest:Bottle Break 1")
            score = score + 1
        end
        
        local pulsesize=500 --the maximum radius of the touch circle pulse
        local ffade=100-(p.r/pulsesize)*100 --calculate the
        fill(255,255,255,ffade)
        noFill()
        stroke(255,255,255,ffade)
        ellipse(p.x,p.y,p.r)
        p.rate = p.rate + 0.7
        p.r = p.r + p.rate
        if p.r>pulsesize then
            table.remove(pulse,i)
        end
    end
    
    fill(255)
    --draw the history
    if includeHistory==true then
        for i,pt in pairs(points) do
            ellipse(pt.x,pt.y,10)
            if joinHistory==true then
                --draw lines between all historic touch points
                strokeWidth(2)
                if i>1 then
                    stroke(255)
                    line(pt.x,pt.y,prevx,prevy)
                end
                prevx=pt.x
                prevy=pt.y
            end
        end
    end
    --draw start and stop circles and connect them with lines for all active touches
    strokeWidth(2)
    activetouches=0
    for i,t in pairs(touches) do
        activetouches = activetouches + 1
        fill(255)
        stroke(255)
        if includeStart==true then
            line(tsup[i].tstartx,tsup[i].tstarty,t.x,t.y)
            ellipse(tsup[i].tstartx,tsup[i].tstarty,10)
        end
        fill(255)
        if includeDuration==true then
            local formattime=math.floor(10*(ElapsedTime-tsup[i].starttime))/10
            text(formattime,t.x,t.y+50)
        end
        --draw path of touch
        if includeTrail==true then
            fadespeed=500
            for j,p in pairs(tsup[i].path) do
                trailfade=math.max((p.age-ElapsedTime)*fadespeed,-255)
                stroke(255,255,255,255+trailfade)
                fill(255,255,255,255+trailfade)
                if trailfade>-255 then
                    if j>1 then
                        line(prevx,prevy,p.pos.x,p.pos.y)
                    end
                end
                prevx=p.pos.x
                prevy=p.pos.y
            end
        end
    end
    
    text("Score: "..score,WIDTH/2,HEIGHT-50)
end


function touched(touch)
    if touch.state==MOVING then
        --record path
        if tsup[touch.id]~=nil then
            table.insert(tsup[touch.id].path,{pos=vec2(touch.x,touch.y),age=ElapsedTime})
        end
    end
    if touch.state==ENDED or touch.state==CANCELLED then
        if gamestate==PLAYING then
            processTouch(touch)
        elseif gamestate==READY then
            gamestate=PLAYING
        elseif gamestate==LEVELCOMPLETE then
            gamestate=PLAYING
            currentLevel = currentLevel + 1
            objProgress=1
            initialise()
        elseif gamestate==GAMEOVER then
            gamestate=READY
            initialise()
            currentLevel=1
            objProgress=1
            score=0
        end
        
        prevtouch={sx=tsup[touch.id].tstartx,sy=tsup[touch.id].tstarty,x=touch.x,y=touch.y,t=ElapsedTime}
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
    dashblock=0
    if includeHistory==true then
        table.insert(points,vec2(touch.x,touch.y)) --add a point to the points table
    end
    if includePulse==true then
        table.insert(pulse,{x=touch.x,y=touch.y,r=8,rate=1}) --add a new pulse
    end
    if includeClassification==true then
        if ElapsedTime-tsup[touch.id].starttime<0.2 then
            --very short event
            if tsup[touch.id]==nil then
                table.insert(pulse,{x=touch.x,y=touch.y,r=8,rate=1}) --add a new pulse
            elseif vec2(touch.x,touch.y):dist(vec2(tsup[touch.id].tstartx,tsup[touch.id].tstarty))<10 then
                table.insert(pulse,{x=touch.x,y=touch.y,r=8,rate=1}) --add a new pulse
            else
                local ang=math.atan2(touch.y-tsup[touch.id].tstarty,touch.x-tsup[touch.id].tstartx)
                if activetouches==1 then
                    table.insert(slash,{x=touch.x,y=touch.y,a=ang,fade=255,startx=touch.x,starty=touch.y})
                    dashblock=1
                end
            end
        end
        --check for pinch
        if prevtouch.x~=nil and dashblock==0 then
            local sx1=prevtouch.sx
            local sy1=prevtouch.sy
            local x1=prevtouch.x
            local y1=prevtouch.y
            local sx2=tsup[touch.id].tstartx
            local sy2=tsup[touch.id].tstarty
            local x2=touch.x
            local y2=touch.y
            
            local cx=(((sx1+x2)/2)+((x1+sx2)/2))/2
            local cy=(((sy1+y2)/2)+((y1+sy2)/2))/2
            local mag=2000
            local normang=math.atan(((sy1+y2)/2)-((y1+sy2)/2),((x1+sx2)/2)-((sx1+x2)/2))
            
            if ElapsedTime-prevtouch.t<0.1 then
                pinch={}
                table.insert(pinch,{x=cx,y=cy,ang=normang,mag=2000,dist=50})
            end
        end
        
        --check for circle
        if #tsup[touch.id].path>5 then
            local ct=tsup[touch.id].path[1].pos
            local cend=tsup[touch.id].path[#tsup[touch.id].path].pos
            local cl=tsup[touch.id].path[math.floor(#tsup[touch.id].path/4)].pos
            local cr=tsup[touch.id].path[math.floor(3*#tsup[touch.id].path/4)].pos
            local cb=tsup[touch.id].path[math.floor(#tsup[touch.id].path/2)].pos
            if  ct:dist(cend)<30 then
                local w1=(ct.x+cb.x)
                local w2=(cl.x+cr.x)
                local h1=(ct.y+cb.y)
                local h2=(cl.y+cr.y)
                local ww=w2
                local hh=h1
                if math.abs(w1)>math.abs(w2) and math.abs(w1)>math.abs(h1) and math.abs(w1)>math.abs(h2)then
                    ww=w1
                    hh=h2
                elseif math.abs(h2)>math.abs(w1) and math.abs(h2)>math.abs(w2) and math.abs(h2)>math.abs(w1) then
                    ww=w1
                    hh=h2
                end
                local cc=vec2(ww/2,hh/2)
                local dia=(cc:dist(ct)+cc:dist(cl)+cc:dist(cb)+cc:dist(cr))/2
                local cw=true
                if cl.x>=cr.x then
                    if cb.y<ct.y then
                        --clockwise
                    else
                        --anticlockwise
                        cw=false
                    end
                elseif cl.x<cr.x then
                    if cb.y<ct.y then
                        --anticlockwise
                        cw=false
                    else
                        --clockwise
                    end
                end
                table.insert(circ,{centrex=ww/2,centrey=hh/2,dia=dia,cw=cw, fade=255,ang=math.random(360),startx=touch.x,starty=touch.y,duration=ElapsedTime-tsup[touch.id].starttime})
            end
        end
    end
end

function resetTarget()
    
    objProgress = objProgress + 1
    if objProgress>#level[currentLevel].obj then
        print("level complete")
        objProgress=1
        gamestate=LEVELCOMPLETE
    end
    size1=10
    state=1
    adjx1=0
    adjy1=0
    adjx2=0
    adjy2=0
    a1=0
    a2=0
    fade=255
    kind=level[currentLevel].obj[objProgress]
    
    
    x=50+math.random(WIDTH-100)
    y=50+math.random(HEIGHT-100)
    
    sizespd = sizespd + level[currentLevel].rate
end