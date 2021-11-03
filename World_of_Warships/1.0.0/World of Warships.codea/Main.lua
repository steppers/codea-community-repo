
--# Main
-- Main

displayMode(FULLSCREEN)

function setup()
    states={{"Start",nil},{"Creating ships",SetupShips},{"Building terrain",SetupTerrain},
        {"Set up UI",SetupUI},{"Touch to Play"}}
    state=1
    draw=drawWhileLoading
    touched=nil --disable touching while loading
    parameter.integer("fog",0,3,2)
    mapPixels,cellSize=2000,10
end

function drawWhileLoading()
    if states[state][2] then states[state][2]() else touched=touchToPlay end
    background(148, 177, 193, 255)
    pushStyle()
    font("Copperplate-Bold") fontSize(96) fill(255, 0, 0, 255)
    text("Warships",WIDTH/2,HEIGHT*0.6)
    if states[state][1]=="Touch to Play" then touched=touchToPlay else state=state+1 end
    font("ArialRoundedMTBold") fontSize(36) fill(50, 78, 167, 255)
    text(states[state][1],WIDTH/2,HEIGHT*0.4)
    textMode(CORNER)
    popStyle()   
end

function SetupShips()
    local s=MakeShip()
    --set up our ship
    S=Ship(s,vec3(0,0,0),4,90,true)
    viewAngle=0
    --set up enemies
    E={}
    for i=1,3 do
        local v
        while true do
            v=vec3(math.random()-0.5,0,math.random()-0.5)*0.8*mapPixels
            if v:dist(S.pos)>600 then break end
        end
        E[i]=Ship(s,v,0,0)
        E[i].angle=math.random(0,360)
    end
end

function SetupTerrain()
    --add ships to log of island positions so we don't add islands on top of them
    Terrain.islands={}
    LogTerrainIsland(S.pos,40,40) --our ship
    for _,e in pairs(E) do LogTerrainIsland(e.pos,40,40) end --enemy ships
    --math.randomseed(12345) --xxx
    Terrain.setup(mapPixels,cellSize)
    --now we can remove the ship positions from the island position log
    for i=1,#E+1 do table.remove(Terrain.islands,1) end
    MakeMemoryMap()
    --fogRadius=1000    
    skyColor=color(163, 208, 214, 255)
end

function SetupUI()
    joy=JoyStick()
    viewConsole=MakeViewConsole(viewList)
    viewConsolePos=vec2(300+viewConsole.width/2,viewConsole.height/2+5)
    FPS=60
    shots,splashes,explosions={},{},{} 
    camView="Behind1"
    zoom=1 
    tick=1/60 --DeltaTime
    aimRadius=200
    aimPos=vec2(WIDTH-aimRadius,HEIGHT-aimRadius)
    aimOffset=vec2(0,0)
    aimCircleRadius=25
    aimCircleCentre=vec2(WIDTH-160,aimCircleRadius+5)
end

function touchToPlay(t)
    if t.state==ENDED then
        if (restartTime and ElapsedTime>restartTime) or not restartTime then
            draw=drawPlay
            touched=touchPlay
            Message=nil
            if runWhenTouched then runWhenTouched() end
            runWhenTouched=nil
        end
    end
end

function drawPlay()
    FPS=FPS*0.9+0.1/DeltaTime
    CheckForWinner()
    background(skyColor)
    perspective(viewZoom[zoom]) 
    SetCamera()
    local v=joy:update() --update joystick
    --if target and not IsVisible(S.pos,E[target].pos) then target=nil end --xxx
    S:draw(-v.x,v.y)
    DrawEnemyShips()
    
    Terrain.draw()
    S:drawTrack() --track behind our ship
    DrawShots()
    DrawSplashes()
    DrawExplosions()
    joy:draw()
    DrawHUD()
    if aiming then DrawAimingCircle() end
end

function drawEnd()
    background(148, 177, 193, 255)
    pushStyle()
    font("Copperplate-Bold") fontSize(96) fill(255,0,0)
    text("Warships",WIDTH/2,HEIGHT*0.6)
    touched=touchToPlay
    runWhenTouched=setup
    font("ArialRoundedMTBold") fontSize(36) fill(50, 78, 167, 255)
    if Message then text(Message,WIDTH/2,HEIGHT*0.4) end
    popStyle()   
end

function DrawEnemyShips()
    for _,e in pairs(E) do 
        if IsShipVisible(e.pos,S.pos) then 
            if not e.readyToShoot then e.readyToShoot=ElapsedTime+2+math.random()*3
            elseif e.readyToShoot==true then e:AimAt(S)
            elseif e.readyToShoot<ElapsedTime then e.readyToShoot=true end
        else e.readyToShoot=nil
        end
        e:draw(0,0) 
    end
end

function CheckForWinner()
    local gameOver
    if S.health<0 then Message="You lose!" gameOver=true
    else
        for i,e in pairs(E) do 
            if e.health<0 then 
                Message="You sunk an enemy ship"
                table.remove(E,i)
                target=nil
            end
        end
        if #E==0 then 
            gameOver=true 
            Message=Message.."\nYou win the game"
        end
    end
    if gameOver then 
        Message=Message.."\n\nTouch to restart"
        draw=drawEnd 
        gameOver=nil 
        restartTime=ElapsedTime+1.5
    end
end

function DrawHUD()
    ortho()
    viewMatrix(matrix())
    sprite(viewConsole,viewConsolePos.x,viewConsolePos.y)
    local s=S:GetGunStatus()
    pushStyle()
    local x=WIDTH-20
    for i=#s,1,-1 do
        fill(gunStateColours[s[i]])
        ellipse(x,10,15)
        x=x-20
    end
    rectMode(CORNER)
    fill(150)
    rect(WIDTH-90,25,80,10)
    rect(WIDTH-90,45,80,10)
    fill(0,255,0)
    rect(WIDTH-90,25,80*S.health/2000,10)
    local message=LookForEnemies()
    if message then 
        fill(0,0,255)
        text(message,WIDTH/2,HEIGHT-50) 
    end
    if targetMessage then
        text("Target acquired",WIDTH/2,HEIGHT/2)
        targetMessageTime=(targetMessageTime or 2) - DeltaTime
        if targetMessageTime<0 then targetMessage=nil end
    end
    if target then 
        fill(0,255,0)
        rect(WIDTH-90,45,80*E[target].health/2000,10)
        fill(255,0,0)
        ellipse(aimCircleCentre.x,aimCircleCentre.y,aimCircleRadius*2)
    end
    fill(0)
    text("Speed: "..math.floor(S.speed+0.5),50,HEIGHT-20)
    text("FPS: "..math.floor(FPS+0.5),WIDTH-50,HEIGHT-20)
    popStyle()
end

function LookForEnemies()
    local message
    for i=1,#E do
        local s=0
        if IsShipVisible(E[i].pos,S.pos) then 
            local d=RotateVector(E[i].pos-S.pos,-S.angle,0)
            if d.x>0 then if d.z>0 then s=1 else s=4 end
            elseif d.z>0 then s=2 else s=3 end
        end
        if s>0 then 
            if message then message=message.."\n" else message="" end
            message=message.."Enemy in "..enemyPosition[s] 
        end
    end
    return message
end

function DrawAimingCircle()
    local e=E[target]
    pushMatrix()
    pushStyle()
    translate(aimPos:unpack())
    stroke(0,0,0,100)
    fill(39, 105, 204, 50)
    ellipse(0,0,aimRadius*2)
    strokeWidth(aimRadius/11)
    line(-aimRadius*3/4,0,-aimRadius/4,0)
    strokeWidth(10)
    line(-aimRadius/4,0,-aimRadius/4+aimRadius/30,0)
    local d=e.pos:dist(S.pos)
    local a=AngleToTarget(S.ship.muzzleSpeed,Shot.grav.y,d,0,S.ship.maxElevation)
    --estimate time taken to reach target
    textSize(12)
    fill(255,255,0,125)
    if a then 
        local t=d/S.ship.muzzleSpeed/math.cos(math.rad(a))        
        text("Time to target: "..math.floor(t+0.5),0,-aimRadius*.75)
    else
        text("Cannot reach target",0,-aimRadius*.75)
        aiming=false
    end
    popStyle()
    popMatrix()
end

function DrawShots()
    for i,s in pairs(shots) do 
        local m=LookAtMatrix(s.pos,s.pos+s.vel)
        pushMatrix()
        modelMatrix(m)
        S.ship.shell:draw()
        popMatrix()
        if s:update()==true then
            if S.shot==shots[i] then 
                S.shot=nil 
                --if camView=="Shot" then end --camView="Behind1" end
            end 
            shots[i]=nil 
        end
    end
end

function DrawSplashes()
    table.sort(splashes,function(a,b) return a.pos:dist(camPos)<b.pos:dist(camPos) end)
    for i=#splashes,1,-1 do
        if splashes[i]:draw()==true then table.remove(splashes,i) end
    end
end

function DrawExplosions()
    table.sort(explosions,function(a,b) return a.pos:dist(camPos)<b.pos:dist(camPos) end)
    for i=#explosions,1,-1 do
        pushMatrix()
        if explosions[i]:draw()==true then table.remove(explosions,i) end
        popMatrix()
    end
end

function SetCamera()
    if zooming then 
        zoom=zoom+1
        if zoom>#viewZoom then zoom=1 end
        zooming=false
    end
    if shotView and S.shot then
        camPos=S.shot.pos+vec3(0,1,0)
        camLook=camPos+vec3(S.shot.vel.x,math.min(0,S.shot.vel.y),S.shot.vel.z)
    elseif camView=="Behind1" or camView=="Behind2" or camView=="Bridge" then
        camPos=S.pos+RotateVector(viewPos[camView],S.angle,0)
        camLook=camPos+RotateVector(vec3(40,0,0),S.angle,0)
        viewAngle=0
    elseif camView=="Scan" then
        camPos=S.pos+RotateVector(vec3(-40,10,0),viewAngle,0)
        camLook=S.pos+vec3(0,10,0)   
    elseif target and camView=="Target" then
        camLook=E[target].pos
        camPos=S.pos+(S.pos-E[target].pos):normalize()*30+vec3(0,10,0)
        viewAngle=0
    else 
        --camView="Behind1"
        --SetCamera()
    end
    camera(camPos.x,camPos.y,camPos.z,camLook.x,camLook.y,camLook.z) 
end

function touchPlay(t)
    if joy:touched(t) then return
    elseif t.state==MOVING then
        local y=t.deltaX/WIDTH*viewZoom[zoom]
        if viewAngle==0 then viewAngle=S.angle end
        viewAngle=viewAngle+y*2
        camView="Scan"
    elseif t.state==ENDED then 
        if ViewConsoleTouched(t) 
        or FireButtonTouched(t) 
        or target and AimCircleTouched(t) 
        or TargetTouched(t)
        then return
        end
    end
end

function ViewConsoleTouched(t)
    local w,h=spriteSize(viewConsole)
    if math.abs(t.x-viewConsolePos.x)<w/2 and math.abs(t.y-viewConsolePos.y)<h/2 then
        local v=viewList[math.floor((t.x-viewConsolePos.x+w/2)/w*#viewList)+1]
        if v=="Zoom" then zooming=true 
        elseif v=="Shot" then 
            shotView=not shotView
        else camView=v end
        return true
    else return nil end
end

function FireButtonTouched(t)
    if vec2(t.x,t.y):dist(aimCircleCentre)<aimCircleRadius then 
        aiming=not aiming
        return true
    end
end


function AimCircleTouched(t)
    if aiming and vec2(t.x,t.y):dist(aimPos)<aimRadius then  
        local v=(vec2(t.x,t.y)-aimPos+vec2(aimRadius/2,0))*45*2/aimRadius     
        local w=E[target].pos+RotateVector(vec3(v.x,1,-v.y),E[target].angle)
        S:ShootAt(w)
        aiming=false
        return true
    end
end

function TargetTouched(t)
    local v=camLook-camPos
    local ca=math.deg(math.atan2(-v.z,v.x))
    local y=S.angle+ca-90-(t.x/WIDTH-0.5)*viewZoom[zoom]
    for i,e in pairs(E) do
        local v=e.pos-camPos
        local a=math.deg(math.atan2(-v.z,v.x))
        if math.abs(a-y)<10 then target=i print("target="..i) break else print(a,y) end
    end
end

function TargetTouched(t)
    local y=-(t.x/WIDTH-0.5)*viewZoom[zoom]
    local a=(RotateVector(camLook-camPos,y,0)):normalize()
    for i,e in pairs(E) do
        if IsShipVisible(S.pos,e.pos) then
            local d=camPos:dist(e.pos)
            local v=(camPos+a*d):dist(e.pos) 
            if v<50 then 
                target=i
                targetMessage=true
                return true
            end
        end
    end
end

--# Ship
--ship

--damage settings
proximityRadius=3
damageRadius=10

--viewing options
viewList={"Behind1","Behind2","Bridge","Target","Zoom","Shot"}
viewPos={["Behind1"]=vec3(-50,5,0),["Behind2"]=vec3(-50,5,-5),["Bridge"]=vec3(12,6,0),["Top"]=vec3(0,3000,0)}
viewZoom={45,20,5,2}
gunStates={Ready=1,Reloading=2,Disabled=3}
gunStateColours={color(0,255,0),color(200,200,0),color(255,0,0)}
enemyPosition={"Starboard Fore quadrant","Starboard Aft quadrant","Port aft quadrant","Port Fore quadrant"}
fogRadius={1000,800,300,100} fogRadius[0]=5000

function deckHeight(x)
    if x<0 then return 1.5+.5*x/20.5 elseif x>0 then return 1.5+1.5*x/24.5 else return 1.5 end
end

function MakeShip()
    local m=mesh()
    local s=100
    local shipColour=color(141, 163, 172, 255)
    --deck vertex list
    local v={vec3(-20.5,0,0),vec3(-20.25,0,1),vec3(-19.5,0,2),vec3(-16.2,0,2.2),
        vec3(-13,0,2.4),vec3(-10,0,2.45),vec3(-7,0,2.5),vec3(-3,0,2.55),
        vec3(0,0,2.6),vec3(3,0,2.55),vec3(6,0,2.5),vec3(8.5,0,2.45),
        vec3(11,0,2.4),vec3(14.5,0,2.15),vec3(18,0,1.9),vec3(20,0,1.5),
        vec3(22.5,0,0.75),vec3(24.5,0,0),
        vec3(22.5,0,-0.75),vec3(20,0,-1.5),vec3(18,0,-1.9),vec3(14.5,0,-2.15),
        vec3(11,0,-2.4),vec3(8.5,0,-2.45),vec3(6,0,-2.5),vec3(0,0,-2.6),
        vec3(-3,0,-2.55),vec3(-7,0,-2.5),vec3(-10,0,-2.45),vec3(-13,0,-2.4),
    vec3(-16.2,0,-2.2),vec3(-19.5,0,-2),vec3(-20.25,0,-1),vec3(-20.5,0,0)}
    --adjust height
    for i=1,#v do v[i].y=deckHeight(v[i].x) end
    --make triangles
    --make central point
    local vc=vec3(0,deckHeight(0),0)
    local vert,norm={},{}
    for i=2,#v do
        vert[#vert+1]=v[i-1] 
        vert[#vert+1]=v[i]   
        vert[#vert+1]=vc     
    end
    vert[#vert+1]=v[#v]      
    vert[#vert+1]=v[1]       
    vert[#vert+1]=vc         
    for i=1,#vert do norm[i]=vec3(0,1,0) end
    --make hull  
    local yy=-.2
    for i=2,#v do
        vert[#vert+1]=v[i-1]                      norm[#vert]=CalcNormal(vert[#vert])
        vert[#vert+1]=vec3(v[i-1].x,yy,v[i-1].z)  norm[#vert]=CalcNormal(vert[#vert])
        vert[#vert+1]=vec3(v[i].x,yy,v[i].z)      norm[#vert]=CalcNormal(vert[#vert])
        vert[#vert+1]=vec3(v[i].x,yy,v[i].z)      norm[#vert]=CalcNormal(vert[#vert])
        vert[#vert+1]=v[i]                        norm[#vert]=CalcNormal(vert[#vert])
        vert[#vert+1]=v[i-1]                      norm[#vert]=CalcNormal(vert[#vert])
    end
    for i=1,#vert do
        if vert[i].x==24.5 and vert[i].y<0 then vert[i].x=vert[i].x-1
        elseif vert[i].x==22.5 and vert[i].y<0 then vert[i].x=vert[i].x-0.5 end
    end
    --colours
    local cols={}
    for i=1,#vert do cols[i]=shipColour end
    --add superstructure
    vert,cols=AddDeckBlock(-7,0,13,1.5,3,shipColour*0.8,vert,cols) --aft block
    vert,cols=AddDeckBlock(7.5,0,15,2.5,3,shipColour*0.8,vert,cols) --fore block
    vert,cols=AddDeckBlock(10,2.5,3,3.5,2,shipColour*1.15,vert,cols) --bridge block
    local c1=shipColour*1.5
    vert,cols=AddDeckBlock(10,4.5,0.2,1,0.2,c1,vert,cols) --radar block
    vert,cols=AddDeckBlock(10,5,0.2,0.5,1,c1,vert,cols) --radar block
    vert,cols=AddDeckBlock(5,1.5,7,1.5,2,shipColour,vert,cols) --mid block
    vert,cols=AddDeckBlock(-7,1,5,0.5,1.5,shipColour,vert,cols) --aft top block
    --add to mesh
    m.vertices=vert
    m.normals=CreateNormals(vert,norm)
    m.colors=cols
    SetLighting(m)
    local sh={}
    sh.m=m
    --calculate the corner positions for collision detection
    local xMin,xMax,yMin,yMax,zMin,zMax=999,-999,999,-999,999,-999
    for _,v in pairs(vert) do 
        if v.x>xMax then xMax=v.x end if v.x<xMin then xMin=v.x end
        if v.y>yMax then yMax=v.y end if v.y<yMin then yMin=v.y end
        if v.z>zMax then zMax=v.y end if v.y<zMin then zMin=v.y end
    end
    sh.front,sh.back=vec3(xMax,0,0),vec3(xMin,0,0) --front and back of ship
    sh.corners={vec3(xMin,yMin,zMin)-vec3(5,5,5),vec3(xMax,yMax,zMax)+vec3(5,5,5)} 
    sh.vertices=GetUniqueVertices(vert,#vert)
    --make the guns
    sh.guns={}
    sh.guns[1]=MakeGun(s*0.01,17,deckHeight(20),0,shipColour*1.2)  
    sh.guns[2]=MakeGun(s*0.01,13,deckHeight(13)+1.25,0,shipColour*1.2)   
    sh.guns[3]=MakeGun(s*0.01,-12,deckHeight(-12)+0.75,180,shipColour*1.2)    
    sh.guns[4]=MakeGun(s*0.01,-15,deckHeight(-15),180,shipColour*1.2) 
    for i=1,4 do 
        sh.guns[i].vertices=GetUniqueVertices(sh.guns[i].m:buffer("position"),sh.guns[i].m.size) 
        sh.guns[i].maxAngle=140 
    end
    sh.track=MakeBubbleTrack(80,20,seaColor)
    sh.minSpeed=-1
    sh.maxSpeed=12
    sh.muzzleSpeed=300
    sh.maxElevation=85
    sh.flame=MakeFlame()
    sh.splash=MakeSplash()
    sh.explosion=MakeExplosion(30)
    sh.shell=MakeShell()
    return sh
end

function GetUniqueVertices(v,s)
    local u,uu={},{} 
    for i=1,s do
        local vv=v[i]
        local w=vv.x..","..vv.y..","..vv.z
        if not uu[w] then uu[w]=true table.insert(u,vv) end
    end
    return u
end


function CalcNormal(v)
    if v.x<=-19.5 then
        return (v-vec3(-19.5,0,0)):normalize()
    elseif v.x>17.9 then
        return (v-vec3(18,0,0)):normalize()
    else
        return (v-vec3(v.x,0,0)):normalize()
    end
end

function AddDeckBlock(x,y,w,h,d,col,vv,cc)
    local v,n,c2,t=AddBlock(w,h,d,col,vec3(0,0,0))
    local v1=deckHeight(x+w/2)-deckHeight(x-w/2)
    local a1=math.deg(math.atan2(v1,w))
    local mm=matrix(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)
    mm=mm:rotate(a1,0,0,1)
    local vh=vec3(x,deckHeight(x)+y,0)
    for i=1,#v do vv[#vv+1]=mm*v[i]+vh end
    for i=1,#v do cc[#cc+1]=col end
    return vv,cc
end

function MakeGun(s,x,y,a,col)
    local w,d,h,col,pos=s*1.5,s*1.2,s*1.2,col,vec3(x,y+s/2,0)
    --main gun block
    local v,n,c,t=AddBlock(w,h,d,col,vec3(0,0,0))
    local m=mesh()
    m.vertices,m.normals,m.texCoords=v,n,t
    m:setColors(col)
    --gun barrels
    local gw,gh,gd=s*1.4*2,s*0.1,s*0.1
    local bpos=vec3(w/2,h*0.2,0)
    local vg,ng,tg=AddBlock(gw,gh,gd,col,vec3(0,0,s*0.3),nil)
    local vg2,ng2,tg2=AddBlock(gw,gh,gd,col,vec3(0,0,-s*0.3),nil)
    for i=1,#vg2 do table.insert(vg,vg2[i]) table.insert(ng,ng2[i]) end --add second barrel to first
    local bm=mesh()
    bm.vertices,bm.normals,bm.texCoords=vg,ng --,tg
    bm:setColors(col*0.75)
    local bf={vec3(gw/2+0.1,gh/2,s*0.3),vec3(gw/2+0.1,gh/2,-s*0.3)} --end of barrel position for flame
    local gun={m=m,bm=bm,p=pos,bp=bpos,a=a,ba=0,bf=bf}
    SetLighting(gun.m)
    SetLighting(gun.bm)
    return gun
end



Ship=class()

function Ship:init(ship,pos,speed,angle,user)
    self.ship=ship
    self.pos=pos
    self.lastPos=pos 
    self.speed=speed
    self.angle=angle
    self.user=user
    self.maxSpeedChange=1/3
    self.maxTurnSpeed=1/5
    --rotation angles (y,z)
    self.gunAngles,self.gunAngles={},{}
    self.nguns=#self.ship.guns
    self.firing,self.gunState,self.lastShot={},{},{}
    for i=1,self.nguns do 
        self.gunAngles[i]=vec2(0,0) 
        self.lastShot[i]=-30 
        self.gunState[i]=gunStates.Ready
    end
    self.reloadTime=10  
    self.health=2000 
    self.gunHealth={}
    for i=1,self.nguns do self.gunHealth[i]=100 end
end

function Ship:draw(turnAngle,accel)
    local S=self.ship
    --steer ship away from islands and control speed
    if not self.user then self:NavigateTodeepWater() end
    if turnAngle~=0 then turnAngle=turnAngle*self.maxTurnSpeed
    elseif self.turnAngle then 
        turnAngle=self.turnAngle 
        self.turnAngle=nil
    end
    self.angle=self.angle+turnAngle
    
    if accel~=0 then
        accel=accel*self.maxSpeedChange
    elseif self.accel then 
        accel=self.accel 
        self.accel=nil
    end
    self.speed=math.min(S.maxSpeed,math.max(S.minSpeed,self.speed+accel))
    --translate and draw ship
    pushMatrix()
    translate(self.pos:unpack())
    rotate(self.angle,0,1,0)
    local m=modelMatrix()
    local d=self.speed*vec3(m[1],m[2],m[3])*tick
    --store prev position before we change it
    self.lastPos=self.pos 
    --check we haven't collided with any islands, then move
    if not TerrainCollision(m*S.front+d,m*S.back+d) then self.pos=self.pos+d
    else 
        speed=0 
        sound(SOUND_EXPLODE, 29626) --TODO make collision noise
    end
    pushMatrix()
    local f=.1
    local a,b=ElapsedTime*f,ElapsedTime*math.pi*f
    rotate(10*noise(a,b),1,0,0)
    rotate(3*noise(b,a),0,0,1)
    S.m.shader.mModel=modelMatrix()
    AddFog(S.m)
    S.m:draw()
    for i=1,#S.guns do
        if self.gunState[i]==gunStates.Reloading and ElapsedTime>self.lastShot[i]+self.reloadTime then
            self.gunState[i]=gunStates.Ready 
        end
        local g=S.guns[i]
        pushMatrix()
        translate(g.p:unpack())
        rotate(g.a+self.gunAngles[i][1],0,1,0)
        g.m.shader.mModel=modelMatrix()
        AddFog(g.m)
        g.m:draw()
        translate(g.bp:unpack())
        rotate(self.gunAngles[i][2],0,0,1)
        if self.firing[i] then
            local m=modelMatrix()
            for j=1,2 do
                local r1,r2,r3=math.random()-0.5,math.random()-0.5,math.random()-0.5
                local mm=m:translate(g.bf[j]:unpack())
                --if self.user then sound(DATA, "ZgBACQBQQEBAQEBAjT3MPVVVFT+0eR8+dABAf0BAQEBAQEBA") end
                if self.user then sound(DATA, "ZgNACQBQQEBAQEBAjT3MPVVVFT+0eR8+dABAf0BAQEBAQEBA") end
                local shot=Shot(vec3(mm[13],mm[14],mm[15]),
                self.angle+g.a+self.gunAngles[i][1]+2*r1,
                self.gunAngles[i][2]+r2,
                S.muzzleSpeed*(1.0+r3/50),self.target,S.splash)
                table.insert(shots,shot)
                self.shot=shot --store in case we want to follow shot
            end
            self.firing[i]=nil
        end
        g.bm.shader.mModel=modelMatrix()
        AddFog(g.bm)
        g.bm:draw()
        popMatrix()
    end
    popMatrix()
    popMatrix()
end

function Ship:drawTrack()
    pushMatrix()
    translate(self.pos:unpack())
    rotate(self.angle,0,1,0)
    translate(-20+math.sin(ElapsedTime/2),0.1,0)
    scale(0.9+0.2*math.sin(ElapsedTime/6+.3))
    self.ship.track:draw()
    popMatrix()
end

function Ship:AimAt(s) --s=target ship
    self.target=s
    --get elevation angle
    local d=s.pos:dist(self.pos)
    local e=AngleToTarget(self.ship.muzzleSpeed,Shot.grav.y,d,0,self.ship.maxElevation)
    if not e then return end
    --estimate time taken to reach target
    local t=d/self.ship.muzzleSpeed/math.cos(math.rad(e))
    --adjust future position of target
    local tgtPos=s.pos+(s.pos-s.lastPos)/DeltaTime*t
    --recalculate angle
    d=tgtPos:dist(self.pos)
    e=AngleToTarget(self.ship.muzzleSpeed,Shot.grav.y,d,0,self.ship.maxElevation)
    if not e then return end
    for i=1,self.nguns do
        if self.gunState[i]==gunStates.Ready then
            local g=self.ship.guns[i] 
            local d=(tgtPos-self.pos-RotateVector(g.p,self.angle,0)):normalize() --direction vector to target
            local ga=math.deg(math.atan2(-d.z,d.x))-self.angle-g.a
            if ga>180 then ga=ga-360 elseif ga<-180 then ga=360+ga end
            if math.abs(ga)<=g.maxAngle then 
                self.gunAngles[i][1]=ga+math.random()*5-2.5
                self.gunAngles[i][2]=e+math.random()*4-2
                self.lastShot[i]=ElapsedTime+math.random()*2-1
                self.gunState[i]=gunStates.Reloading
                self.firing[i]=true
            end
        end
    end
    return true
end

function Ship:ShootAt(p) --s=target ship
    self.target=E[target]
    --get elevation angle
    local d=p:dist(self.pos)
    local e=AngleToTarget(self.ship.muzzleSpeed,Shot.grav.y,d,0,self.ship.maxElevation)
    if not e then return end
    for i=1,self.nguns do
        if self.gunState[i]==gunStates.Ready then
            local g=self.ship.guns[i] 
            local d=(p-self.pos-RotateVector(g.p,self.angle,0)):normalize() --direction vector to target
            local ga=math.deg(math.atan2(-d.z,d.x))-self.angle-g.a
            if ga>180 then ga=ga-360 elseif ga<-180 then ga=360+ga end
            if ga>180 then ga=ga-360 elseif ga<-180 then ga=360+ga end
            if math.abs(ga)<=g.maxAngle then 
                self.gunAngles[i][1]=ga--+math.random()*5-2.5
                self.gunAngles[i][2]=e--+math.random()*4-2
                self.lastShot[i]=ElapsedTime+math.random()*2-1
                self.gunState[i]=gunStates.Reloading
                self.firing[i]=true
            else print(ga)
            end
        end
    end
    return true
end

function Ship:GetGunStatus()
    return self.gunState
end

function Ship:Damage(pos,lastPos)
    --calculate positions of shell relative to ship and reverse rotation
    local p0=RotateVector(lastPos-self.pos,-self.angle,0)
    local p=RotateVector(pos-self.pos,-self.angle,0)
    local c1,c2=self.ship.corners[1],self.ship.corners[2]
    --test if the shell is inside the "box" around our ship, this frame or the previous frame
    if ( IsBetween(p.x,c1.x,c2.x)  and IsBetween(p.y,c1.y,c2.y)  and IsBetween(p.z,c1.z,c2.z)) or
    (IsBetween(p0.x,c1.x,c2.x) and IsBetween(p0.y,c1.y,c2.y) and IsBetween(p0.z,c1.z,c2.z)) then
        --if the shell is inside the box, test the intersection of each vertex with the path of the shell
        --if it is less than the proximity distance, explode the shell
        --if there is more than one vertex inside the proximity distance, use the one that is first along
        --the path of the shell
        local v=self.ship.vertices
        local f,p0p=999,p0:dist(p) --f is fraction of line at which we are first inside proximity
        local pr2=proximityRadius*proximityRadius
        for i=1,#v do
            local d,dp=DistanceToLine(v[i],p,p0) --distance to line and intersection point
            local d1=math.sqrt(pr2-d*d)
            local d2=p0:dist(dp)-d1
            if d2>0 then 
                f=math.min(f,d2/p0p) 
            else 
                d2=p:dist(dp)-d1
                if d1>0 then f=math.min(f,1-d2/p0p) end
            end
        end
        if f>1 then return false end
        --if we got this far, then the shell explodes at fraction f of line between p0 and p
        --recalculate p
        --print("explode")
        local p1=p0*(1-f)+p*f
        --calculate damage
        local td=0
        for i=1,#v do
            local d=math.max(0,damageRadius-v[i]:dist(p1)) td=td+d
            self.health=self.health-d
        end
        for g=1,self.nguns do
            local pp=p1-self.ship.guns[g].p
            if self.gunState[g]~=gunStates.Disabled then
                local v=self.ship.guns[g].vertices
                for i=1,#v do
                    local d=math.max(0,damageRadius-v[g]:dist(pp)) td=td+d
                    self.gunHealth[g]=self.gunHealth[g]-d
                end
                if self.gunHealth[g]<0 then self.gunState[g]=gunStates.Disabled end
            end
        end
        if td>0 then 
            --print("damage")
            if self.user then 
                --sound(DATA, "ZgNAEwQ+Pj47OTdAPNPfPCk19j6rqqo+fwBAdD1AQD5APkI8") 
                sound("Game Sounds One:Explode Big") 
                tween.delay(2,function() sound("A Hero's Quest:FireBall Blast 1",.3,0.3) end)
            end
            local p2=lastPos*(1-f)+pos*f --real world position of interpolated shell position
            table.insert(explosions,Explosion(p2,1.5+0.5*math.random(),math.random(0,360)))
            return true 
        end
    end
    return false
end

function Ship:Patrol()
    
end

function GetSquare(p)  
    local x,z=math.ceil(p.x/mapCellSize),math.ceil(-p.z/mapCellSize)
    if map[x] and map[x][z] then return map[x][z] else return 0 end
end

function Ship:NavigateTodeepWater()
    --look ahead a few squares
    local min,mini,max,maxi=self:LookAheadSquare(5,0)
    local s=self.maxTurnSpeed
    local left,right=self:LookAheadSquare(5,45),self:LookAheadSquare(5,-45)
    if self.user==true then min11,left11,right11=min,left,right end
    if self.prevAngle then
        if min>0 then self.prevAngle=nil else self.turnAngle=self.prevAngle end
    end
    if not self.prevAngle then
        if left>min or right>min then
            if left>right then self.turnAngle=s elseif left<right then self.turnAngle=-s
            elseif math.random()>0.5 then self.turnAngle=s else self.turnAngle=-s end
        end 
        self.prevAngle=self.turnAngle
    end
    --set maximum speed based on proximity to islands
    local s=self.maxSpeedChange
    if (min>0 and maxi>=mini) or min>self.speed then self.accel=s aaaa="+"
    elseif min<self.speed then self.accel=-s aaaa="-" end
end

function Ship:LookAheadSquare(n,a) --number of squares, angle)
    local max,min,maxi,mini=-99,99
    local v=RotateVector(vec3(mapCellSize,0,0),self.angle+a,0)
    for i=0,n do
        local a=GetSquare(self.pos+v*i)
        if a>max then max=a maxi=i end
        if a<min then min=a mini=i end
    end
    return min,mini,max,maxi
end


--# Shots
--shots

Shot=class()

Shot.grav=vec3(0,-42,0)

function Shot:init(p,y,z,vel,tgt,splash)
    self.pos=p
    self.a=z
    self.target=tgt
    self.vel=RotateVector(vec3(1,0,0),y,z)*vel
    self.splash=splash
    self.lastPos=p
end

function Shot:update()
    self.pos=self.pos+self.vel*tick
    self.vel=self.vel+Shot.grav*tick
    if self.target:Damage(self.pos,self.lastPos)==true then return true --return if we hit the ship
    else 
        local p=ShellHitsIsland(self.lastPos,self.pos) 
        if p then
            table.insert(explosions,Explosion(p))
            return true 
        elseif self.pos.y<0 then
            local f=self.lastPos.y/(self.lastPos.y+self.pos.y) --calculate where it hit the water
            local s=self.lastPos*(1-f)+self.pos*f
            table.insert(splashes,Splash(s,self.splash,0.7+0.6*(math.random()-0.5)))
            return true
        end
    end
end

Splash=class()

function Splash:init(pos,splash,size)
    self.pos=pos
    self.splash=splash
    self.size=size or 1
    self.t=0
end

function Splash:draw()
    self.t=self.t+1
    local m=LookAtMatrix(self.pos,camPos)
    pushMatrix()
    modelMatrix(m)
    local f,a,b,c=1,40,60,80
    if self.t<=a then 
        f=self.t/a
        scale(f*0.10)
    elseif self.t>b then 
        f=(self.t-b)/(c-b)
        translate(0,-10*f,0)
        scale(0.1)
    else scale(0.1)
    end 
    scale(self.size)   
    S.ship.splash:draw()
    popMatrix()
    if self.t>c then return true end
end

Explosion=class()

function Explosion:init(pos,size,rot)
    self.pos=pos
    self.size=size or 1
    self.rot=rot or 0
    self.t=0
    self.scale=0.1
    self.fade=120+math.random(0,120)    
end

function Explosion:draw()
    self.t=self.t+1
    if self.t>self.fade then return true end
    local m=LookAtMatrix(self.pos,camPos)
    pushMatrix()
    modelMatrix(m)   
    scale(self.size*self.scale*(1+self.t/100))
    rotate(self.rot)
    local f=self.t/self.fade
    S.ship.explosion.shader.a=1-f*f
    S.ship.explosion:draw()
    popMatrix()
end
--# Terrain
--terrain

Terrain={}

seaColor=color(150, 185, 210, 255)
local islandColor=color(137, 193, 141, 255)
local borderColor=color(0,0,0,0) --color(seaColor.r,seaColor.g,seaColor.b,0) 
local cellSize=10
local islandList={} --islands between the ships
islandList.updatePeriod=3 --frames between update
islandList.nextUpdate=0 --frames since last update
Terrain.islands={}

function Terrain.setup(s,size)
    Terrain.size=s
    cellSize=size or 10
    Terrain.sea=MakeSea(s)
    local v,n={},{}
    for i=1,30 do
        v,n=AddIsland(v,n) 
    end
    local m=mesh()
    m.vertices,m.normals=v,n
    m:setColors(color(150, 177, 43, 255)) 
    SetLighting(m)
    m.shader.mModel=modelMatrix()
    --m.shader.sky=skyColor
    Terrain.m=m
end

function LogTerrainIsland(v,w,d)
    Terrain.islands=Terrain.islands or {}
    table.insert(Terrain.islands,{pos=vec3(v.x,0,v.z),w=w,d=d}) 
end

function TerrainCollision(f,b) --front and back vertex positions
    local p,d,m=0,99999
    if b then m=(f+b)/2 else m=f end
    for _,i in pairs(Terrain.islands) do
        local a=m:dist(i.pos)
        if a<d then p,d=i,a end
    end
    if b then
        if (math.abs(f.x-p.pos.x)<p.w/2 and math.abs(f.z-p.pos.z)<p.d/2) 
        or (math.abs(b.x-p.pos.x)<p.w/2 and math.abs(b.z-p.pos.z)<p.d/2) then return true,p 
        end
    elseif (math.abs(f.x-p.pos.x)<p.w/2 and math.abs(f.z-p.pos.z)<p.d/2) then return true,p 
    end
end

function Terrain.draw()
    AddFog(Terrain.m)
    Terrain.m:draw()
    local mm=Terrain.sea
    local b=mm:buffer("texCoord")
    for i=1,6 do
        mm.t[i]=mm.t[i]+vec2(0.05/mm.w,0.05/mm.h)
        b[i]=mm.t[i]
    end
    AddFog(Terrain.sea)
    Terrain.sea:draw()
end

--sea surface
function MakeSea(s)
    s=s or 2000
    local m=mesh()
    local x1,y,z1,x2,z2=-s,0,s,s,-s
    m.vertices={vec3(x1,y,z1),vec3(x2,y,z1),vec3(x2,y,z2),vec3(x2,y,z2),vec3(x1,y,z2),vec3(x1,y,z1)}
    m:setColors(seaColor)
    return m
end

function AddIsland(vert,norm)
    local x,y,r
    --find a blank spot on the map
    local r1,r2,r3
    while true do
        --generate a location and size
        x,z=math.random(-Terrain.size*0.45,Terrain.size*.45),math.random(-Terrain.size*.45,Terrain.size*.45)
        r1,r2,r3=math.random(6,12),math.random(6,12),math.random(10,20)
        local u=math.max(r1,r2)*cellSize/2
        local collisions=false
        for _,i in pairs(Terrain.islands) do
            if vec3(x,0,z):dist(i.pos)-u-math.max(i.w/2,i.d/2)<50 then collisions=true break end
        end
        if collisions==false then break end
    end
    local h=50*r1*r2/100
    local v,n=MakeIsland(vec3(x,0,z),r1,r2,h,cellSize,0.2)
    table.insert(Terrain.islands,{pos=vec3(x,0,z),w=r1*cellSize,d=r2*cellSize,vert=vec2(#vert+1,#vert+#v)}) 
    for i=1,#v do
        vert[#vert+1]=v[i]
        norm[#norm+1]=n[i]
    end
    return vert,norm    
end

function MakeIsland(pos,width,depth,height,cellSize,smoothness)
    local abs,min=math.abs,math.min
    local w2,d2=width/2,depth/2
    local grid0={}
    local c=vec2(width,depth)/2
    local max=c:dist(vec2(0,0)) --max distance
    local rw,rd=math.random(),math.random()
    local P=pos-vec3(width,0,depth)*cellSize/2
    for w=0,width do
        local ww=min(1,(1-abs(w-w2)/w2)/0.3)
        grid0[w]={}
        for d=0,depth do
            local dd=min(1,(1-abs(d-d2)/d2)/0.3)
            local h=ww*dd*height/2*(1+noise(rw+w*smoothness,rd+d*smoothness))-1
            grid0[w][d]=vec3(w*cellSize,h,d*cellSize)+P
        end
    end
    local grid={}
    for w=0,width do
        grid[w]={}
        for d=0,depth do
            grid[w][d]=grid0[w][d]
        end
    end
    for w=1,width-1 do
        for d=1,depth-1 do
            grid[w][d]=(grid0[w][d-1]+grid0[w-1][d]+grid0[w][d+1]+grid0[w+1][d])/8+grid0[w][d]/2
        end
    end
    --normals are averaged
    gn={}
    for w=0,width do
        gn[w]={}
        for d=0,depth do
            if w==0 or w==width or d==0 or d==depth then gn[w][d]=0 
            else 
                gn[w][d]=(GetNormal(grid[w][d],grid[w-1][d],grid[w][d-1])+
                GetNormal(grid[w][d],grid[w+1][d],grid[w][d-1])+
                GetNormal(grid[w][d],grid[w+1][d],grid[w][d+1])+
                GetNormal(grid[w][d],grid[w-1][d],grid[w][d+1]))/4
            end
        end
    end
    local v,c,n={},{},{} 
    for w=1,width do
        for d=1,depth do
            local v1,v2,v3,v4=grid[w-1][d-1],grid[w][d-1],grid[w][d],grid[w-1][d]
            local n1,n2,n3,n4=gn[w-1][d-1],gn[w][d-1],gn[w][d],gn[w-1][d]
            local c1,c2,c3,c4=islandColor,islandColor,islandColor,islandColor
            if w==1     or d==1     then c1=borderColor end
            if w==width or d==1     then c2=borderColor end
            if w==width or d==depth then c3=borderColor end
            if w==1     or d==depth then c4=borderColor end
            v[#v+1]=v1  n[#n+1]=n1 c[#c+1]=c1
            v[#v+1]=v2  n[#n+1]=n2 c[#c+1]=c2
            v[#v+1]=v3  n[#n+1]=n3 c[#c+1]=c3
            v[#v+1]=v3  n[#n+1]=n3 c[#c+1]=c3
            v[#v+1]=v4  n[#n+1]=n4 c[#c+1]=c4
            v[#v+1]=v1  n[#n+1]=n1 c[#c+1]=c1
        end
    end
    local m=mesh()
    m.vertices=v
    m.normals=n
    --m:setColors(color(137, 193, 141, 255))
    m.colors=c
    SetLighting(m)
    return v,n,m
end

function GetNormal(v1,v2,v3)
    local a,b=v1-v3,v2-v3
    return (a:cross(b)):normalize()
end

function IsShipVisible(p1,p2)
    if ElapsedTime>islandList.nextUpdate then --is it time to update list of islands to check
        local d=p1:dist(p2) --distance between the ships
        if d>0.8*fogRadius[fog] then return false end
        islandList.list={}
        for i=1,#Terrain.islands do
            if p1:dist(Terrain.islands[i].pos)<d and p2:dist(Terrain.islands[i].pos)<d then 
                table.insert(islandList.list,i) 
            end
        end  
        islandList.nextUpdate=ElapsedTime+islandList.updatePeriod  
    end
    --do the checks
    for i=1,#islandList.list do
        if IsVisible(p1,p2,islandList.list[i])==false then return false end
    end
    return true
end

function GetIslandsBetweenShips(p1,p2)
    
end

function MakeMemoryMap()
    local ceil,min,max=math.ceil,math.min,math.max
    --initialise map with zeros
    --local t=os.time()
    mapCellSize=cellSize/2
    local c=mapCellSize
    map,mapSize,maxDepth={},mapPixels/c,15
    --[
    -- for i=-mapSize/2,mapSize/2 do
    --      map[i]={}
    --     for j=-mapSize/2,mapSize/2 do
    --         local d0,d1=min(i+mapSize/2,j+mapSize/2,mapSize/2-i,mapSize/2-j)
    --         map[i][j]=maxDepth
    --    end
    --   end
    --]
    for i=0,mapSize do
        local ii=i-mapSize/2
        map[ii]={}
        for j=0,mapSize do
            local jj=j-mapSize/2
            map[ii][jj]=min(maxDepth,i,j,mapSize-i,mapSize-j)
        end
    end
    --
    for _,a in pairs(Terrain.islands) do
        local i0,i1,j0,j1=a.pos.x-a.w/2,a.pos.x+a.w/2,a.pos.z-a.d/2,a.pos.z+a.d/2
        for i=i0,i1,c do
            local col=ceil(i/c)  
            for j=j0,j1,c do
                local row=-ceil(j/c)
                map[col][row]=0
            end
        end
        local minX,maxX,minZ,maxZ=ceil(i0/c),ceil(i1/c),ceil(j0/c),ceil(j1/c)
        for k=1,maxDepth do
            for i=minX-k,maxX+k do
                SetMin(i,-(minZ-k),k)
                SetMin(i,-(maxZ+k),k)
            end
            for i=minZ-k+1,maxZ+k-1 do
                SetMin(minX-k,-i,k)
                SetMin(maxX+k,-i,k)
            end
        end
    end
    --[[
    mapImg=image(mapSize,mapSize)
    for i=-mapSize/2,mapSize/2 do
        local ii=i+mapSize/2
        for j=-mapSize/2,mapSize/2 do
            local jj=j+mapSize/2
            mapImg:set(ii,jj,color(map[i][j])/maxDepth*255)
        end
    end
    --]]
end

function SetMin(i,j,v)
    if map[i] and map[i][j] then map[i][j]=math.min(map[i][j],v) end
end

function ShellHitsIsland(p0,p)
    local abs=math.abs
    local i,a=TerrainCollision(p)
    if i then
        local v=Terrain.m:buffer("position")
        for i=a.vert[1],a.vert[2],3 do
            local pos=IsPointUnderTriangle(p0,p,v[i],v[i+1],v[i+2]) 
            if pos then return pos+(p0-p):normalize()*3+vec3(0,2,0) end
        end
    end
end

--barycentric method
function IsPointUnderTriangle(p0,p,a,b,c)
    local v0,v1,v2=c-a,b-a,p-a
    v0.y,v1.y,v2.y=0,0,0 --flatten to 2D
    local dot00,dot01,dot02,dot11,dot12=v0:dot(v0),v0:dot(v1),v0:dot(v2),v1:dot(v1),v1:dot(v2)
    local invDenom=1/(dot00*dot11-dot01*dot01)
    local u=(dot11*dot02-dot01*dot12)*invDenom
    local v=(dot00*dot12-dot01*dot02)*invDenom
    local n=((a-c):cross(b-c)):normalize()
    local w=((a-p):normalize()):dot(n)
    if u>=0 and v>=0 and u+v<1 and w<0 then 
        local pos=LineIntersectsPlane(p0,p,a,n)
        return pos
    else return nil end
end

--# Controls
--Controls

--contains Joystick controls 

JoyStick = class()

--Note all the options you can set below. Pass them through in a named table
function JoyStick:init(t)
    t = t or {}
    self.radius = t.radius or 100  --size of joystick on screen
    self.stick = t.stick or 30 --size of inner circle
    self.centre = t.centre or self.radius * vec2(1,1) + vec2(5,5)
    self.damp=t.damp or vec2(0.1,0.1)
    self.position = vec2(0,0) --initial position of inner circle
    self.target = vec2(0,0) --current position of inner circle (used when we interpolate movement)
    self.value = vec2(0,0)
    self.delta = vec2(0,0)
    self.mspeed = 30
    self.moving = 0
end

function JoyStick:draw()
    ortho()
    viewMatrix(matrix())
    pushStyle()
    fill(160, 182, 191, 1)
    stroke(118, 154, 195, 100) stroke(0,0,0,25)
    strokeWidth(3) 
    ellipse(self.centre.x,self.centre.y,2*self.radius)
    fill(78, 131, 153, 1)
    ellipse(self.centre.x+self.position.x, self.centre.y+self.position.y, self.stick*2)
    popStyle()
end

function JoyStick:touched(t)
    if t.state == BEGAN then
        local v = vec2(t.x,t.y)
        if v:dist(self.centre)<self.radius-self.stick then
            self.touch = t.id
            --else return false
        end
    end
    if t.id == self.touch then
        if t.state~=ENDED then
            local v = vec2(t.x,t.y)
            if v:dist(self.centre)>self.radius-self.stick then
                v = (v - self.centre):normalize()*(self.radius - self.stick) + self.centre
            end  --set x,y values for joy based on touch
            self.target=v - self.centre
        else --reset joystick to centre when touch ends
            self.target=vec2(0,0)
            self.touch = false
        end
    else return false
    end
    return true
end

function JoyStick:update()
    local p = self.target - self.position
    if p:len() < tick * self.mspeed then
        self.position = self.target
        if not self.touch then
            if self.moving ~= 0 then
                self.moving = self.moving - 1
            end
        else
            self.moving = 2
        end
    else
        self.position = self.position + p:normalize() * tick * self.mspeed
        self.moving = 2
    end
    local v=self.position/(self.radius - self.stick)
    return self:Dampen(v)
end

function JoyStick:Dampen(v)
    if not self.damp then return v end
    if v.x>0 then v.x=math.max(0,(v.x-self.damp.x)/(1-self.damp.x))
    else v.x=math.min(0,(v.x+self.damp.x)/(1-self.damp.x)) end
    if v.y>0 then v.y=math.max(0,(v.y-self.damp.y)/(1-self.damp.y))
    else v.y=math.min(0,(v.y+self.damp.y)/(1-self.damp.y)) end
    return v
end

function JoyStick:isMoving()
    return self.moving
end
function JoyStick:isTouched()
    return self.touch
end





--# Utility
--Utility

--lighting
function SetLighting(m)
    m.shader=shader(LightingShader.v,LightingShader.f)
    m.shader.directColor=color(255)*0.5
    m.shader.directDirection=vec4(-1,1,1,0):normalize()
    m.shader.ambientColor=color(255)*0.5
    m.shader.reflec=1.0
    --blendMode(}
end

--SkyGlobe functions
--to create a 360 sky image all around

function CreateSphere(r,tex,col,nx,ny)
    local vertices,tc = Sphere_OptimMesh(nx or 40,ny or 20)
    vertices = Sphere_WarpVertices(vertices)
    for i=1,#vertices do vertices[i]=vertices[i]*r end
    local ms = mesh()
    ms.vertices=vertices
    if tex then ms.texture,ms.texCoords=tex,tc end
    ms:setColors(col or color(255))
    return ms
end

function Sphere_OptimMesh(nx,ny)
    local v,t={},{}
    local k,s,x,y,x1,x2,i1,i2,sx,sy=0,1,0,0,{},{},0,0,nx/ny,1/ny
    local c = vec3(1,0.5,0)
    local m1,m2
    for y=0,ny-1 do
        local nx1 = math.floor( nx * math.abs(math.cos(( y*sy-0.5)*2 * math.pi/2)) )
        if nx1<6 then nx1=6 end
        local nx2 = math.floor( nx * math.abs(math.cos(((y+1)*sy-0.5)*2 * math.pi/2)) ) 
        if nx2<6 then nx2=6 end
        x1,x2 = {},{}
        for i1 = 1,nx1 do x1[i1] = (i1-1)/(nx1-1)*sx end  x1[nx1+1] = x1[nx1]
        for i2 = 1,nx2 do x2[i2] = (i2-1)/(nx2-1)*sx end  x2[nx2+1] = x2[nx2]
        local i1,i2,n,nMax,continue=1,1,0,0,true
        nMax = nx*2+1
        while continue do
            m1,m2=(x1[i1]+x1[i1+1])/2,(x2[i2]+x2[i2+1])/2
            if m1<=m2 then 
                v[k+1],v[k+2],v[k+3]=vec3(x1[i1],sy*y,1)-c,vec3(x1[i1+1],sy*y,1)-c,vec3(x2[i2],sy*(y+1),1)-c
                t[k+1],t[k+2],t[k+3]=vec2(-x1[i1]/2,sy*y) ,vec2(-x1[i1+1]/2,sy*y),vec2(-x2[i2]/2,sy*(y+1))
                if i1<nx1 then i1 = i1 +1 end
            else
                v[k+1],v[k+2],v[k+3]=vec3(x1[i1],sy*y,1)-c,vec3(x2[i2],sy*(y+1),1)-c,vec3(x2[i2+1],sy*(y+1),1)-c
                t[k+1],t[k+2],t[k+3]=vec2(-x1[i1]/2,sy*y),vec2(-x2[i2]/2,sy*(y+1)),vec2(-x2[i2+1]/2,sy*(y+1))
                if i2<nx2 then i2 = i2 +1 end
            end        
            if i1==nx1 and i2==nx2 then continue=false end
            k,n=k+3,n+1
            if n>nMax then continue=false  end
        end
    end   
    return v,t
end

function Sphere_WarpVertices(verts)
    local m = matrix(0,0,0,0, 0,0,0,0, 1,0,0,0, 0,0,0,0)
    local vx,vy,vz,vm        
    for i,v in ipairs(verts) do
        vx,vy = v[1], v[2]
        vm = m:rotate(180*vy,1,0,0):rotate(180*vx,0,1,0)
        vx,vy,vz = vm[1],vm[5],vm[9]
        verts[i] = vec3(vx,vy,vz)
    end    
    return verts
end  

Sky=class()
function Sky:init(r,tex)  
    if tex.width==tex.height*4 then
        local img=image(tex.width,tex.width/2)
        setContext(img)
        sprite(tex,img.width/2,img.height*3/4)
        sprite(tex,img.width/2,img.height*1/4,tex.width,tex.height)
        setContext()
        self.sky=CreateSphere(r,img)
    else self.sky=CreateSphere(r,tex) end
end
function Sky:draw(p) pushMatrix() translate(p:unpack()) self.sky:draw() popMatrix() end


--code to make a simple block plane

function CreateBlock(w,h,d,col,pos,tex,ms) --width,height,depth,colour,position,texture
    local x,X,y,Y,z,Z=pos.x-w/2,pos.x+w/2,pos.y-h/2,pos.y+h/2,pos.z-d/2,pos.z+d/2
    local v={vec3(x,y,Z),vec3(X,y,Z),vec3(X,Y,Z),vec3(x,Y,Z),vec3(x,y,z),vec3(X,y,z),vec3(X,Y,z),vec3(x,Y,z)}
    local vert={v[1],v[2],v[3],v[1],v[3],v[4],v[2],v[6],v[7],v[2],v[7],v[3],v[6],v[5],v[8],v[6],v[8],v[7],
        v[5],v[1],v[4],v[5],v[4],v[8],v[4],v[3],v[7],v[4],v[7],v[8],v[5],v[6],v[2],v[5],v[2],v[1]}
    local texCoords
    if tex then    
        local t={vec2(0,0),vec2(1,0),vec2(0,1),vec2(1,1)}            
        texCoords={t[1],t[2],t[4],t[1],t[4],t[3],t[1],t[2],t[4],t[1],t[4],t[3],t[1],t[2],t[4],t[1],t[4],t[3],
            t[1],t[2],t[4],t[1],t[4],t[3],t[1],t[2],t[4],t[1],t[4],t[3],t[1],t[2],t[4],t[1],t[4],t[3]}
    end
    local n={vec3(0,0,1),vec3(1,0,0),vec3(0,0,-1),vec3(-1,0,0),vec3(1,0,0),vec3(-1,0,0)}
    local norm={}
    for i=1,6 do for j=1,6 do norm[#norm+1]=n[i] end end
    if not ms then ms=mesh() end 
    if ms.size==0 then
        ms.vertices=vert
        ms.normals=norm
        if tex then ms.texture,ms.texCoords=tex,texCoords end
    else   
        for i=1,#vert do
            table.insert(ms.vertices,vert[i])
            table.insert(ms.normals,norm[i])
            if tex then table.insert(ms.texCoords,texCoords[i]) end
        end
    end
    ms:setColors(col or color(255))
    return ms
end  

function MakePlane()
    local img=readImage("Platformer Art:Block Brick"):copy(4,4,62,62)
    local b=CreateBlock(1,1,1,color(255),vec3(0,0,0),img)
    local bv,bt=b:buffer("position"),b:buffer("texCoord")
    local m=mesh()
    local v,t={},{}
    local w,h,d=1.5,1.5,15 --body
    for i=1,b.size do v[#v+1]=vec3(bv[i].x*w,bv[i].y*h,bv[i].z*d) end for i=1,b.size do t[#t+1]=bt[i] end
    local w,h,d=1.5,0.5,2 --cockpit
    for i=1,b.size do v[#v+1]=vec3(bv[i].x*w,bv[i].y*h+1.25,bv[i].z*d-4) end for i=1,b.size do t[#t+1]=bt[i] end
    local w,h,d=16,0.25,3  --wings
    for i=1,b.size do v[#v+1]=vec3(bv[i].x*w,bv[i].y*h+0.5,bv[i].z*d-3) end for i=1,b.size do t[#t+1]=bt[i] end
    local w,h,d=8,0.25,1.5 --tail horizontal
    for i=1,b.size do v[#v+1]=vec3(bv[i].x*w,bv[i].y*h+0.5,bv[i].z*d+7) end for i=1,b.size do t[#t+1]=bt[i] end
    local w,h,d=0.25,3,2 --tail vertical
    for i=1,b.size do v[#v+1]=vec3(bv[i].x*w,bv[i].y*h+2,bv[i].z*d+7) end for i=1,b.size do t[#t+1]=bt[i] end
    m.texture=img
    m.vertices=v
    m.texCoords=t
    m:setColors(color(255))
    return m
end

function AddBlock(w,h,d,col,pos,tex) --width,height,depth,colour,position,texture
    local x,X,y,Y,z,Z=pos.x-w/2,pos.x+w/2,pos.y-h/2,pos.y+h/2,pos.z-d/2,pos.z+d/2
    local v={vec3(x,y,Z),vec3(X,y,Z),vec3(X,Y,Z),vec3(x,Y,Z),vec3(x,y,z),vec3(X,y,z),vec3(X,Y,z),vec3(x,Y,z)}
    local vert={v[1],v[2],v[3],v[1],v[3],v[4],v[2],v[6],v[7],v[2],v[7],v[3],v[6],v[5],v[8],v[6],v[8],v[7],
        v[5],v[1],v[4],v[5],v[4],v[8],v[4],v[3],v[7],v[4],v[7],v[8],v[5],v[6],v[2],v[5],v[2],v[1]}
    local texCoords
    if tex then    
        local t={vec2(0,0),vec2(1,0),vec2(0,1),vec2(1,1)}            
        texCoords={t[1],t[2],t[4],t[1],t[4],t[3],t[1],t[2],t[4],t[1],t[4],t[3],t[1],t[2],t[4],t[1],t[4],t[3],
            t[1],t[2],t[4],t[1],t[4],t[3],t[1],t[2],t[4],t[1],t[4],t[3],t[1],t[2],t[4],t[1],t[4],t[3]}
    end
    local n={vec3(0,0,1),vec3(1,0,0),vec3(0,0,-1),vec3(-1,0,0),vec3(1,0,0),vec3(-1,0,0)}
    local norm,cols={},{}
    for i=1,6 do for j=1,6 do norm[#norm+1]=n[i] end end
    for i=1,6 do for j=1,6 do cols[#cols+1]=col end end
    return vert,norm,cols,texCoords
end 

function MakeBubbleTrack(w,d,col)
    local ww,dd=w*10,d*10
    local img=image(ww,dd)
    local r1,r2=math.random(),math.random()
    for i=1,ww do
        for j=1,dd do
            local u=(i/ww)^1.5
            local u2=dd*(1-0.9*i/ww)
            local u3=(1-math.max(0,math.min(1,math.abs(j-dd/2)/u2)))
            local n=(150+100*math.random())*u*u3*(1+0.05*noise(i+r1,j+r2))
            --if n<100 then img:set(i,j,col) else img:set(i,j,color(255,255,255,n)) end
            img:set(i,j,color(255,255,255,n))
        end
    end
    local m=mesh()
    local x1,y,z1,x2,z2=-w,0,d/2,0,-d/2
    m.vertices={vec3(x1,y,z1),vec3(x2,y,z1),vec3(x2,y,z2),vec3(x2,y,z2),vec3(x1,y,z2),vec3(x1,y,z1)}
    m.texture=img
    m.texCoords={vec2(0,0),vec2(1,0),vec2(1,1),vec2(1,1),vec2(0,1),vec2(0,0)}
    m:setColors(color(255))
    return m
end

function RotateVector(v,y,z)
    local m=matrix(1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1)
    if y then m=m:rotate(y,0,1,0) end
    if z then m=m:rotate(z,0,0,1) end
    return m*v,m
end

function CreateNormals(v,n)
    n=n or {}
    for i=1,#v,3 do
        if n[i]==nil then
            local v1,v2,v3=v[i],v[i+1],v[i+2]
            local a,b=v1-v3,v2-v3
            local c=(a:cross(b)):normalize()
            for j=1,3 do n[i+j-1]=c end
        end
    end
    return n
end

function MakeFlame()
    local ww,dd=100,25
    local img=image(ww,dd)
    local r1,r2=math.random(),math.random()
    for i=1,ww do
        for j=1,dd do
            local w
            if i<0.3*ww then w=(i/ww/.3)^.5 else w=((1-i/ww)/0.7)^0.5 end
            local s=(1-math.max(0,math.min(1,2*math.abs(j-dd/2)/dd/w)))
            if s>0 then
                local n=255*s*(1+0.05*noise(i+r1,j+r2))
                img:set(i,j,color(255,255,255*n,n))
            else img:set(i,j,color(0,0,0,0))
            end
        end
    end
    local m=mesh()
    local x1,y,z1,x2,z2=0,0,dd/2,ww,-dd/2
    m.vertices={vec3(x1,y,z1),vec3(x2,y,z1),vec3(x2,y,z2),vec3(x2,y,z2),vec3(x1,y,z2),vec3(x1,y,z1)}
    m.texture=img
    m.texCoords={vec2(0,0),vec2(1,0),vec2(1,1),vec2(1,1),vec2(0,1),vec2(0,0)}
    m:setColors(color(255))
    m.shader=shader(TransparentShader.v,TransparentShader.f)
    return m
end

function LookAtMatrix(source,target,up) 
    local Z=(source-target):normalize() 
    up=up or vec3(0,1,0) 
    local X=(up:cross(Z)):normalize() 
    local Y=(Z:cross(X)):normalize() 
    return matrix(X.x,X.y,X.z,0,Y.x,Y.y,Y.z,0,Z.x,Z.y,Z.z,0,source.x,source.y,source.z,1) 
end 

function TurnMeshToCam(c,m)
    local m=LookAtMatrix(m,c)    
end

function MakeSplash()
    local ww,hh=60,100
    local img=image(ww,hh)
    setContext(img)
    strokeWidth(0)
    for i=1,10000 do
        local w,a
        a=(math.random()^1.5)/2
        local h=hh*math.random()^2
        local wa=ww
        if math.random()<0.5 then w=ww*.5+a*wa else w=ww*0.5-a*wa end
        local a=255*(.5-a)
        a=a*math.min(1,1-(h/hh-0.9)/0.1)
        local s=math.random()*2+1
        fill(255,255,255,a)
        ellipse(w,h,s)
    end
    setContext()
    local m=mesh()
    local x1,y1,z,x2,y2=-ww/2,0,0,ww/2,hh
    m.vertices={vec3(x1,y1,z),vec3(x2,y1,z),vec3(x2,y2,z),vec3(x2,y2,z),vec3(x1,y2,z),vec3(x1,y1,z)}
    m.texture=img
    m.texCoords={vec2(0,0),vec2(1,0),vec2(1,1),vec2(1,1),vec2(0,1),vec2(0,0)}
    m:setColors(color(255))
    m.shader=shader(TransparentShader.v,TransparentShader.f)
    return m
end

function MakeShell()
    local v,n,c,t=AddBlock(0.1,0.1,10,color(0),vec3(0,0,-5))
    local m=mesh()
    m.vertices=v
    m:setColors(color(255,255,0,100))
    return m
end

function AngleToTarget(s,g,d,y,m)
    g=-g
    local a=s*s*s*s-g*(g*d*d+2*y*s*s)
    if a>0 then
        local b,c=math.deg(math.atan2(s*s+math.sqrt(a),g*d)),math.deg(math.atan2(s*s-math.sqrt(a),g*d))
        local q=90
        if b>0 then q=b end
        if c>0 then q=math.min(q,c) end
        if q==90 then return nil else return math.min(q,m) end 
    end
    return nil
end

function DistanceTravelled(v,g,a,h) --unused
    a=math.rad(a)
    s,c=math.sin(a),math.cos(a)
    return -v*c/g*(v*s+math.sqrt(v*v*s*s+2*g*h)) --is actually -g and -h at the end, but minuses cancel
end

function MakeViewConsole(list)
    pushStyle()
    font("AmericanTypewriter")
    fill(0)
    fontSize(12)
    local w,h=0,0
    for i=1,#list do 
        local a,b=textSize(list[i])
        w,h=math.max(w,a),math.max(h,b) 
    end
    w=w+10 --10 pixels is spacing between words
    local img=image(#list*w,h)
    setContext(img)
    local x=w/2
    for i=1,#list do
        text(list[i],x,h/2)
        x=x+w
    end
    setContext()
    popStyle()
    return img
end

--p1,p2 are start and end of line
--i is table containing rectangle details, pos=vec3 centre position, w=width, d=depth
--returns true if line does not intersect rectangle
function IsVisible(p1,p2,i)
    if p1:dist(p2)>fogRadius[fog] then return false end
    if not i then return true end
    local m=(p2.z-p1.z)/(p2.x-p1.x+0.0000001)
    local a,b=-m,m*p2.x-p2.z
    local u
    local ii=Terrain.islands[i]
    for x=-1,1,2 do
        for z=-1,1,2 do 
            local xx,zz=ii.pos.x+x*ii.w/2,ii.pos.z+z*ii.d/2
            local q=a*xx+zz+b
            u=u or q
            if q/u<0 then return false end
        end
    end
    return true
end

--these functions create the sea pattern and mesh
--creates mesh, draws it with a shader, and returns a seamless image
function MakeSea(TileSize)
    local Scale=50
    local Colour=color(65, 123, 149, 200)
    local Alpha=210
    local Offset=math.random()
    --ready variable just stops this function running until all parameters are set
    --if not ready then return end
    local m=mesh()
    local w,h=TileSize,TileSize
    m:addRect(w/2,h/2,w,h)
    m.shader=shader(SimplexShader2.v,SimplexShader2.f)
    m.shader.scale=Scale
    m.shader.offset=Offset
    c=Colour
    c.a=Alpha
    m.shader.c=color(255)
    local i=image(w,h)
    setContext(i)
    m:draw()
    c=Colour
    if Alpha>0 then
        c.a=Alpha
        fill(c)
        rect(-5,-5,w+10,h+10)
    end
    setContext() 
    --set up tiling
    mm=setupTiles(i,w,h)
    mm.pos=vec2(0,0)
    seaImage=i
    return mm
end

function setupTiles(img,w,d)
    local m=mesh()
    m.texture=img
    local v,t={},{}
    --now calculate how many times the image is used along the x and z axes
    --use these as the maximum texture settings
    --the shader will just use the fractional part of the texture mapping
    --(the shader only requires one line to change, to do this)
    local x1,x2,z1,z2=-w/2,w/2,-d/2,d/2
    local tw,td=w/img.width,d/img.height
    local tx1,tx2,ty1,ty2=0,tw,0,td
    v[1]=vec3(x1,0,z1) t[1]=vec2(tx1,ty1)
    v[2]=vec3(x2,0,z1) t[2]=vec2(tx2,ty1)
    v[3]=vec3(x2,0,z2) t[3]=vec2(tx2,ty2)
    v[4]=vec3(x1,0,z2) t[4]=vec2(tx1,ty2)
    v[5]=vec3(x1,0,z1) t[5]=vec2(tx1,ty1)
    v[6]=vec3(x2,0,z2) t[6]=vec2(tx2,ty2)
    m.vertices=v
    m.texCoords=t
    m.shader=shader(TileShader.v,TileShader.f)
    m:setColors(color(255))
    m.t=t
    m.w,m.h=img.width,img.height
    return m
end

function MakeExplosion(s)
    local sin,cos,rand,pi2=math.sin,math.cos,math.random,math.pi*2
    local ss=s*1.5
    local img=image(ss,ss)
    pushMatrix()
    setContext(img)
    translate(ss/2,ss/2)
    for i=1,1000 do
        local f=i/2000
        local m=0.4-0.2*f
        local a,d,r=rand()*pi2,rand()*s*.5,rand()*s*m
        local col=150+100*f
        fill(color(col,col,col,50))
        rotate(a)
        ellipse(d*sin(a),d*cos(a),r)        
    end
    setContext()
    popMatrix()
    local m=mesh()
    local x1,y1,z,x2,y2=-s/2,-s/2,0,s/2,s/2
    m.vertices={vec3(x1,y1,z),vec3(x2,y1,z),vec3(x2,y2,z),vec3(x2,y2,z),vec3(x1,y2,z),vec3(x1,y1,z)}
    m.texture=img
    m.texCoords={vec2(0,0),vec2(1,0),vec2(1,1),vec2(1,1),vec2(0,1),vec2(0,0)}
    m:setColors(color(255))
    m.shader=shader(TransparentFadeShader.v,TransparentFadeShader.f)
    m.shader.a=1
    return m,img
end

function DistanceToLine(p,a,b)
    local ap,ab=p-a,b-a
    q=math.max(math.min(ap:dot(ab)/ab:lenSqr(),1),0)*ab+a
    return p:dist(q),q
end

function IsBetween(a,b,c)
    return (a>=b and a<=c)
end

--use bilinear interpolation (most common method) for interpolating 4 corner values
--formula taken from: http://en.wikipedia.org/wiki/Bilinear_interpolation            
function HeightAtPos(x,z)   
    local Q11,Q21,Q12,Q22=v.t[mx][mz],v.t[mx+1][mz],v.t[mx][mz+1],v.t[mx+1][mz+1]
    local x1,x2,y1,y2,x,y=mx,mx+1,mz,mz+1,1+(x-v.x1)/v.p,1+(z-v.z1)/v.p
    return (Q11*(x2-x)*(y2-y)+Q21*(x-x1)*(y2-y)+Q12*(x2-x)*(y-y1)+Q22*(x-x1)*(y-y1))/(x2-x1)/(y2-y1)
end

--returns point along the line p1-p2 where it intersects, if any
function LineIntersectsPlane(p1,p2,a,n)
    local p = p2-p1  
    local d=(a-p1):dot(n)/(p:dot(n))
    return p1+d*p
end

function AddFog(m)
    m.shader.fog=fogRadius[fog]
    m.shader.camPos=camPos
    m.shader.mistColor=skyColor
    m.shader.mModel=modelMatrix()
end

--# Shaders2
--Lighting

LightingShader={
    v=[[
    uniform mat4 modelViewProjection;
    uniform mat4 mModel;
    uniform vec4 directColor;
    uniform vec4 directDirection;
    uniform vec4 ambientColor;
    uniform float reflec;
    uniform float fog;
    uniform vec4 mistColor;
    uniform vec3 camPos;
    attribute vec4 position;
    attribute vec4 color;
    attribute vec3 normal;
    varying lowp vec4 vColor;
    
    void main()
    {
        gl_Position = modelViewProjection * position;
        vec4 norm = normalize(mModel * vec4( normal, 0.0 ));
        float diffuse =  max( 0.0, dot( norm, directDirection ));
        vec4 p=mModel*position;
        float f = clamp(distance(p.xyz,camPos)/fog,0.0,1.0);
        vColor = mix(reflec * color * ( diffuse * directColor + ambientColor ),mistColor,f);
        vColor.a=1.0;
    }
]],
f=[[
precision highp float;
varying lowp vec4 vColor;

void main()
{
gl_FragColor=vColor;
}
]]}

--Tile

TileShader = {
v = [[
uniform mat4 modelViewProjection;
uniform mat4 mModel;
attribute vec4 position;
attribute vec2 texCoord;
varying highp vec2 vTexCoord;
varying highp vec4 vPosition;

void main()
{
vTexCoord = texCoord;
vPosition=mModel*position;
gl_Position = modelViewProjection * position;
}
]],
f = [[
precision highp float;
uniform lowp sampler2D texture;
uniform float fog;
uniform vec4 mistColor;
uniform vec3 camPos;
varying highp vec2 vTexCoord;
varying highp vec4 vPosition;

void main()
{
lowp vec4 col = texture2D(texture, vec2(mod(vTexCoord.x,1.0),mod(vTexCoord.y,1.0)));
float f = clamp(distance(vPosition.xyz,camPos)/fog,0.0,1.0);
gl_FragColor = mix(col,mistColor,f);
}
]]}

TransparentShader = {
v = [[
uniform mat4 modelViewProjection;
attribute vec4 position;
attribute vec2 texCoord;
varying highp vec2 vTexCoord;

void main()
{
vTexCoord = texCoord;
gl_Position = modelViewProjection * position;
}
]],
f = [[
precision highp float;
uniform lowp sampler2D texture;
varying highp vec2 vTexCoord;

void main()
{
lowp vec4 col = texture2D( texture, vTexCoord );
if (col.a<0.2) discard;
gl_FragColor = col;
}
]]}

TransparentFadeShader = {
v = [[
uniform mat4 modelViewProjection;
attribute vec4 position;
attribute vec2 texCoord;
varying highp vec2 vTexCoord;

void main()
{
vTexCoord = texCoord;
gl_Position = modelViewProjection * position;
}
]],
f = [[
precision highp float;
uniform lowp sampler2D texture;
uniform lowp float a;
varying highp vec2 vTexCoord;

void main()
{
lowp vec4 col = texture2D( texture, vTexCoord );
gl_FragColor = col*a;
}
]]}

LightingTextureShader={
v=[[
uniform mat4 modelViewProjection;
uniform mat4 mModel;
uniform vec4 directColor;
uniform vec4 directDirection;
uniform vec4 ambientColor;
uniform float reflec;
attribute vec4 position;
attribute vec4 color;
attribute vec3 normal;
attribute vec2 texCoord;
varying lowp vec4 vColor;
varying highp vec2 vTexCoord;

void main()
{
gl_Position = modelViewProjection * position;
vTexCoord = texCoord;
vec4 norm = normalize(mModel * vec4( normal, 0.0 ));
float diffuse =  max( 0.0, dot( norm, directDirection ));
vColor = reflec * ( diffuse * directColor + ambientColor );
}
]],
f=[[
precision highp float;
uniform lowp sampler2D texture;
varying lowp vec4 vColor;
varying highp vec2 vTexCoord;

void main()
{
lowp vec4 col = vColor*texture2D( texture, vec2(mod(vTexCoord.x,1.0), mod(vTexCoord.y,1.0)));
col.a=1.0;
gl_FragColor=col;
}
]]}

SimplexShader2 = {
v = [[
uniform mat4 modelViewProjection;
attribute vec4 position;
attribute vec4 color;
attribute vec2 texCoord;
varying lowp vec4 vColor;
varying highp vec2 vTexCoord;

void main()
{
vColor = color;
vTexCoord = texCoord;
gl_Position = modelViewProjection * position;
}

]],
f = [[
precision highp float;
//uniform lowp sampler2D texture;
uniform float offset;
uniform float scale;

varying lowp vec4 vColor;
varying highp vec2 vTexCoord;

highp vec4 pParam = vec4(289.0, 34.0, 1.0, 7.0);

float permute(float x0,vec3 p) { 
float x1 = mod(x0 * p.y, p.x);
return floor(  mod( (x1 + p.z) *x0, p.x ));
}
vec2 permute(vec2 x0,vec3 p) { 
vec2 x1 = mod(x0 * p.y, p.x);
return floor(  mod( (x1 + p.z) *x0, p.x ));
}
vec3 permute(vec3 x0,vec3 p) { 
vec3 x1 = mod(x0 * p.y, p.x);
return floor(  mod( (x1 + p.z) *x0, p.x ));
}
vec4 permute(vec4 x0,vec3 p) { 
vec4 x1 = mod(x0 * p.y, p.x);
return floor(  mod( (x1 + p.z) *x0, p.x ));
}

//uniform vec4 pParam; 
// Example constant with a 289 element permutation
//const vec4 pParam = vec4( 17.0*17.0, 34.0, 1.0, 7.0);

//--------
float simplexNoise2(vec2 v)
{
const vec2 C = vec2(0.211324865405187134, // (3.0-sqrt(3.0))/6.;
0.366025403784438597); // 0.5*(sqrt(3.0)-1.);
const vec3 D = vec3( 0., 0.5, 2.0) * 3.14159265358979312;
// First corner
vec2 i  = floor(v + dot(v, C.yy) );
vec2 x0 = v -   i + dot(i, C.xx);

// Other corners
vec2 i1  =  (x0.x > x0.y) ? vec2(1.,0.) : vec2(0.,1.) ;

//  x0 = x0 - 0. + 0. * C
vec2 x1 = x0 - i1 + 1. * C.xx ;
vec2 x2 = x0 - 1. + 2. * C.xx ;

// Permutations
i = mod(i, pParam.x);
vec3 p = permute( permute( 
i.y + vec3(0., i1.y, 1. ), pParam.xyz)
+ i.x + vec3(0., i1.x, 1. ), pParam.xyz);

// N points around a unit circle.
vec3 phi = D.z * mod(p,pParam.w) /pParam.w ;
vec4 a0 = sin(phi.xxyy+D.xyxy);
vec2 a1 = sin(phi.zz  +D.xy);
vec3 g = vec3( dot(a0.xy, x0), dot(a0.zw, x1), dot(a1.xy, x2) );
// mix
vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x1,x1), dot(x2,x2)), 0.);
m = m*m ;
return 1.66666* 70.*dot(m*m, g);
}

void main()
{
//create scaled copy of texture position
highp vec2 p = offset+scale*vec2(vTexCoord.x,vTexCoord.y);
//interpolate
float A = simplexNoise2(p);
float B = simplexNoise2(vec2(p.x+scale,p.y));
float C = simplexNoise2(vec2(p.x,p.y+scale));
float D = simplexNoise2(p+scale);
float xx = 1.0 - vTexCoord.x;
float yy = 1.0 - vTexCoord.y; 
float AB = mix(A,B,xx);
float CD = mix(C,D,xx);
float u = mix(AB,CD,yy);
u=(u+1.0)/2.0;  //because noise goes from -1 to +1, and we want it 0-1
gl_FragColor = vec4(u,u,u,1.0);
}

]]}