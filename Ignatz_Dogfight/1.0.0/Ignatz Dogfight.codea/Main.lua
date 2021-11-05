--Main

displayMode(FULLSCREEN)
supportedOrientations(LANDSCAPE_ANY)

LOAD,INTRO,PLAY,WIN,LOSE=0,1,2,3,4

function setup()
    state=LOAD
    if music then music("A Hero's Quest:Exploration",true) end
    GeneralSettings()
    SetupSky()
    SetupPlane()
    SetupTarget()
end

function GeneralSettings()
    pixelSize=1.5 --metres per pixel
    radarScreen,radarRange=200,2000 --diam of radar screen and diameter of area covered by screen
    radarScale=radarScreen/radarRange --calculate scaling of radar screen
    fireButtonSize=100 --diam of firing button on screen
    fireButton=vec2(WIDTH-fireButtonSize/2-25,radarScreen+25+fireButtonSize/2) --position of fire button
    viewButton=vec2(WIDTH-radarScreen-fireButtonSize/2-25,fireButtonSize/2+25)
    --create bullet image
    bullet=image(1,1)
    setContext(bullet)
    background(218, 205, 95, 255)
    setContext()
    --initialise FPS
    FPS=60
end

function SetupPlane()
    --read in model from obj file
    --download if not stored locally
    model=OBJ("SpitfireP",
    "https://gist.github.com/dermotbalson/8039714/raw/08e2e70ce59a7f570f9a156b63c905f3fcfdf6ba/gistfile1.txt",1)
    imgProp=readImage(asset.Prop2) --extra image needed
    speed=90 --pixels/sec
    sensitivity=vec3(1.5,1,2) --sensitivity to tilting of iPad
    limits=vec3(0.004,1,0.02) --max degrees plane can tilt per draw
    guns={vec3(-3,0,0),vec3(3,0,0)} --gun locations relative to plane body
    gunRange=25*model.size.z --distance at which bullets converge to one point
    --(25 chosen because this is approximately correct for spitfires, about 220m)
    timeToTarget=1 --seconds from firing until bullets converge
    --set up three different views of our plane, found by trial and error
    views={vec3(0,0,25),vec3(0,8,25),vec3(0,0.6,1.5)} 
    selView=1 --initial view selected
end

function SetupTarget()
    --read in model from obj file
    --download if not stored locally
    target=OBJ("Zero",
    "https://gist.github.com/dermotbalson/8178362/raw/e306b19f71206fea117f541201c994e9a7b3c3af/gistfile1.txt",1)
end

--this function is run after each of the models loads, to set up lighting
--to remove unneeded parts of the model, etc
function ConfigureModel(M) 
        local m=M.m
        for i=1,#m do --add lighting to each mesh
            m[i]:setColors(color(255))
            m[i].shader=shader(diffuseShader.vertexShader,diffuseShader.fragmentShader)
            --use the lighting settings from the model file, if provided
            local ca,cd,cs
            if m[i].settings then 
                ca = m[i].settings.Ka or color(255)  
                cd = m[i].settings.Kd or color(255)  
                cs = m[i].settings.Ks or color(255)  
                sp = m[i].settings.Ns or 32
                if m[i].settings.map then m[i].texture=OBJ.imgPrefix..m[i].settings.map end
            else ca,cd=color(255),color(255)
            end
            local a=0.2 --ambient light strength
            m[i].shader.ambientColor=color(ca.r*a,ca.g*a,ca.b*a,ca.a*a)
            local d=0.8  --diffuse light strength
            m[i].shader.directColor=color(cd.r*d,cd.g*d,cd.b*d,cd.a*d)
            m[i].shader.directDirection=vec4(0,1,0,0):normalize()   
            m[i].shader.specularColor=cs --only applies if shader handles specular reflection
            m[i].shader.specularPower=sp
            m[i].shader.shine=1
            if m[i].hasNormals~=true then 
                m[i].normals=CalculateAverageNormals(m[i].vertices,0) 
            end
            m[i].shader.reflect=1
            if m[i].texture then m[i].shader.hasTexture=true else m[i].shader.hasTexture=false end
        end 
        --these lines are specific to these models
        --propellor is removed because it is a non moving propellor
        --cockpit and pilot aren't needed because they can't be seen anyway
        for i=#m,1,-1 do
            if m[i].name=="Propellor" then table.remove(m,i) 
            elseif m[i].name=="Cockpit" then table.remove(m,i) 
            elseif m[i].name=="Pilot" then table.remove(m,i)
            elseif m[i].name=="propeller_rotation" then table.remove(m,i) end
        end
end

function draw()
    --======== model setup ======================
    --draw is used to tell us when a model finishes loading, then go configure it
    --if it hasn't been done
    if state==LOAD then
        if model and model.m then 
            if not model.m[1].shader then ConfigureModel(model) return end 
        end
        if target and target.m then 
            if not target.m[1].shader then ConfigureModel(target) return end 
        end
        if model.m[1].shader and target.m[1].shader then
            state=INTRO 
            if music then music("A Hero's Quest:Battle") end
        end
    end
    
    if state==INTRO then
        ShowIntro()
    elseif state==PLAY then
        ManageMusic()
        Fly() 
        DrawUI()
    elseif state==WIN then
        ShowWin()
    elseif state==LOSE then
        ShowLose()
    end
end

function DrawText(txt)
    background(170, 188, 208, 255)
    pushStyle()
    font("Futura-Medium")
    fill(0,0,255)
    fontSize(48)
    textMode(CENTER)
    text("Spitfire vs Zero",WIDTH/2,HEIGHT*0.75)
    font("Futura-Medium")
    fontSize(24)
    for i=1,#txt do
        text(txt[i],WIDTH/2,HEIGHT*.7-40*i)
    end
    popStyle()
end

function ShowIntro()
    local txt={"You are going to fly a Spitfire against a Japanese Zero.",
        "Tilt the iPad to steer, and use the radar at bottom right to find the Zero.",
        "Press the red button to fire (you need to be quite close).",
        "Touch the bottom left of screen to toggle three different views of your plane.",
        "Now touch the screen to start"}
    DrawText(txt)   
end

function ShowWin() 
    local txt={"You won!",
        "",
        "Touch the screen to play again"}
    DrawText(txt)
end

function ShowLose()
    local txt={"You lost!",
        "",
        "Touch the screen to play again"}
    DrawText(txt)
end

function ManageMusic()
    --====== manage sounds if shooting =========
    --if we are shooting and we have a bullet noise, we want to follow it either with
    --normal engine noise afterwards, or with victory music if we shot down the enemy
    --We have a problem in not knowing when the music finishes, because music.currentTime
    --resets to zero when the music stops. Problem is it is also zero when the music starts!
    --So we use the firing variable to skip the first time we go in here (ie when 
    --music.currentTime is zero) by increasing it by 1 and doing nothing else. After that, we
    --wait for music.currentTime to be zero, then we set the music that follows the bullet noise
    if firing and music then       
        if firing==1 then firing=2 --to skip the first time we come in here (see above)
        elseif music.currentTime==0 then music(asset.Spitfire,true) end 
    end
end

function Start()
    if music then music(asset.Spitfire,true) end --genuine spitfire sound
    state=PLAY 
    --initialise our plane
    pos=vec3(0,0,0) --initial position
    modelQ=vec4(1,0,0,0) --our plane's quaternion, used only for yaw
    modelRot = vec3(0,0,0) --initial rotation
    --set up enemy plane
    targetQ=vec4(1,0,0,0) --initialise quaternion
    --set random position fairly near zero
    target.pos=vec3(math.random(-500,500),math.random(-150,-50),math.random(-500,500))
    target.health=100  --initialise target health
end

function DrawUI()  --===== draw UI ======
    ortho()
    fill(0)
    viewMatrix(matrix())
    --draw indicators
    textMode(CORNER)
    text("Width: "..tostring(pos.x*pixelSize),50,700)
    text("Height: "..tostring(pos.y*pixelSize),50,680)
    text("Depth: "..tostring(pos.z*pixelSize),50,660)
    text("Opp.Health: "..tostring(target.health),50,640)
    FPS=FPS*.9+.1/DeltaTime
    text("FPS: "..tostring(FPS),50,620)
    pushMatrix()
    pushStyle()
    --firing button
    textMode(CENTER)
    strokeWidth(0)
    fill(255,0,0,50)
    ellipse(fireButton.x,fireButton.y,fireButtonSize)
    stroke(0,255,0) fontSize(24)
    text("Fire",fireButton.x,fireButton.y)    
    --draw view toggle
    fill(0,255,0,50)
    ellipse(viewButton.x,viewButton.y,fireButtonSize)
    stroke(0,255,0) fontSize(24)
    text("View",viewButton.x,viewButton.y)    
    --radar
    translate(WIDTH-radarScreen/2,radarScreen/2)
    fill(224, 224, 205, 50)
    strokeWidth(1) stroke(100,100,100,150)
    ellipse(0,0,radarScreen)
    stroke(0) fill(0,0,0,100)
    ellipse(0,0,3) --centre of screen
    --draw our plane with direction indicator
    local p1=pos*radarScale --scale our position to the radar screen
    local p2=p1+(p0*radarScale):normalize()*5 --calculate the position 5 pixels ahead of our plane
    strokeWidth(3)
    stroke(0,0,255) fill(0,0,255)
    ellipse(p1.x,-p1.z,8) --our plane
    line(p1.x,-p1.z,p2.x,-p2.z) --a line showing our direction
    --draw enemy plane
    local t1=target.pos*radarScale
    stroke(255,0,0) fill(255,0,0)
    ellipse(t1.x,-t1.z,8)
    popStyle()
    popMatrix()
end

--[[this function does all the work of flying
Pitch and roll are based directly on the current tilt of the iPad (subject to any limits on
  how fast the plane can pitch or roll per draw, of course).
So when you bring the iPad back to a flat position, pitch and roll will be nil.
Yaw is based on side tilt (as for roll), except that tilt increments the existing yaw.
So if you hold the iPad steady at an angle, roll will be steady but yaw will keep increasing.
We will need separate quaternions for pitch/roll, and for yaw.
--]]

function Fly()
    background(116, 173, 182, 255)
    perspective()
    local s=speed/60 --speed per redraw
    --the Limit function restricts rotation to preset limits
    --pitch and roll have variables which hold total pitch and roll
    --because that is what we will feed into our quaternion
    modelRot.x=modelRot.x+Limit(sensitivity.x*Gravity.y-modelRot.x,limits.x) --total pitch
    local rotY=Limit(sensitivity.y*Gravity.x,limits.y) --incremental yaw
    modelRot.z=modelRot.z+Limit(sensitivity.z*Gravity.x-modelRot.z,limits.z) --total roll
    local qxz=Q.EulerToQuat(modelRot.x,0,modelRot.z) --pitch and roll quaternion
    modelQ=Q.AddRotation(modelQ,0,rotY,0) --adjust yaw rotation for any change
    local q=Q.Multiply(qxz,modelQ):normalize() --combine yaw, pitch and roll
    local m=Q.QToMatrix(pos.x,pos.y,pos.z,q) --calculate rotation matrix
    --calculate new plane position after moving s pixels forward (in object space)
    sx,sy,sz=0,0,-s --speed in a forward direction
    p0=vec3(0,0,0) --initialise vector telling us how far we move this time
    p0.x=sx*m[1]+sy*m[5]+sz*m[9] --multiply speed vector by rotation matrix
    p0.y=sx*m[2]+sy*m[6]+sz*m[10]
    p0.z=sx*m[3]+sy*m[7]+sz*m[11]
    pos=pos+p0 --new position
    local viewPos=pos+p0*25 --our camera will look ahead of the plane
    --insert the plane position in the rotation matrix to give us the full modelMatrix
    m[13],m[14],m[15]=pos.x,pos.y,pos.z 
    local camPos=vec3(0,0,0) --initialise cam pos
    local VP=views[selView] --get offset to selected view
    camPos.x=pos.x+VP.x*m[1]+VP.y*m[5]+VP.z*m[9] --calculate camera position
    camPos.y=pos.y+VP.x*m[2]+VP.y*m[6]+VP.z*m[10]
    camPos.z=pos.z+VP.x*m[3]+VP.y*m[7]+VP.z*m[11]
    camera(camPos.x,camPos.y,camPos.z,viewPos.x,viewPos.y,viewPos.z)
    ---------------------
    --draw skyglobe around plane, centred on plane position so plane can never fly outside it
    pushMatrix() 
    translate (pos.x,pos.y,pos.z)
    planet1:draw() 
    popMatrix()      
    ---------------------
    --draw target plane
    pushMatrix() 
    local mt=Q.QToMatrix(target.pos.x,target.pos.y,target.pos.z,targetQ) --rotate
    modelMatrix(mt)
    target:draw(camPos,"All")
    popMatrix() 
    ---------------------
    --draw our plane
    pushMatrix()
    modelMatrix(m)   
    --if view is inside cockpit, only draw the front of the plane
    if selView==3 then model:draw(camPos,"Body_Front") else model:draw(camPos,"All") end
    pushStyle() 
    --draw prop separately
    translate(0,0,-2.12)
    spriteMode(CENTER)
    sprite(imgProp,0,0,3)
    popStyle() 
    popMatrix()
    ---------------------
    --draw bullets on the way to the target, pro rate the distance
    if firing then
        if ElapsedTime-fireTime>timeToTarget then --bullets have reached target, ignore them
            firing=nil
            fireDest=nil
        else
            if fireDest==nil then --calculate (once only) where bullets meet 
                local g=vec3(0,0,-gunRange)
                local x=pos.x+g.x*m[1]+g.y*m[5]+g.z*m[9] --in direction of plane
                local y=pos.y+g.x*m[2]+g.y*m[6]+g.z*m[10]
                local z=pos.z+g.x*m[3]+g.y*m[7]+g.z*m[11]
                fireDest=vec3(x,y,z)
            end
            stroke(224, 224, 127, 255)
            strokeWidth(1)
            --draw bullets
            for i=1,2 do
                for j=1,2 do
                pushMatrix()
                local p=firePos+guns[i]*j+(fireDest-firePos-guns[i]*j)*(ElapsedTime-fireTime)/timeToTarget
                translate(p.x,p.y,p.z)
                sprite(bullet,0,0,0.25)
                --if within 3 pixels of enemy plane centre, calculate random damage
                if p:dist(target.pos)<3 then
                    target.health=target.health-100*math.random()^3 
                    if target.health<0 then 
                        state=WIN 
                        if music then music("A Hero's Quest:Battle") end
                    end
                end
                popMatrix()
                end
            end
            popStyle() 
        end
    end
    ---------------------        
    --test for collision
    if pos:dist(target.pos)<4 then
        sound("Game Sounds One:Explode Big") 
        state=LOSE
        if music then music("A Hero's Quest:Hero's Loss") end
    end
end

--limits rotation to preset limits
function Limit(a,b)
    if a>=0 then 
        if a>b then return b end
    elseif a<-b then 
        return -b 
    end
    return a
end

function touched(t)
    if t.state==ENDED then
        if state==INTRO or state==WIN or state==LOSE then
            Start()
        elseif state==PLAY then
            --change view if user touches button
            if viewButton:dist(vec2(t.x,t.y))<=fireButtonSize/2 then 
                selView=selView+1
                if selView>#views then selView=1 end
            --shoot if red buttn pressed
            elseif fireButton:dist(vec2(t.x,t.y))<=fireButtonSize/2 then 
                if not firing then 
                    firing=1 
                    firePos=vec3(pos.x,pos.y,pos.z)
                    fireTime=ElapsedTime
                    if music then music(asset.SpitGun) end
                end
            end
        end
    end
end
