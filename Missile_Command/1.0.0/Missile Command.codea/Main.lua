-- Missile command type game
-- by West

displayMode(FULLSCREEN)
function setup()
    touches={}
    tsup={} --tsup contains the supplementary info about the start position of the touch
    resetGame()
    --starfield setup --credit to Simeon @TLL: http://codea.io/talk/discussion/644/flicker-drawing-large-images-any-advice/p1
    local gradSize = 2
    grad = image(gradSize,gradSize)
    local toColor = color(29, 27, 38, 255)
    local fromColor = color(31, 32, 59, 255)    
    -- Make a gradient
    local c = nil
    for i = 1,gradSize do
        for x = 1,gradSize do
            local a = i/gradSize
            c = blend( fromColor, toColor, a )
            grad:set(x, i, c)
        end
    end
    starMesh = mesh()
    starMesh.texture = starImage(32)   
    for i = 1,100 do
        local x = math.random(WIDTH)
        local y = math.random(HEIGHT)
        local s = math.random(8, 32)
        local idx = starMesh:addRect(x, y, s, s)
        local o = math.random(40,255)
        starMesh:setRectColor( idx, color(255,255,255,o) )
    end
    
end

-- This function gets called once every frame
function draw()
    --check to see if there are any bases or missle silos left
    basecount=0
    missilebasecount=0 --number of missile bases
    missilemax=0
    for i,b in pairs(base) do
        if b.state==1 then
            basecount = basecount + 1
        elseif b.state==2 then
            missilebasecount = missilebasecount + 1
            missilemax = missilemax + mps
        end
    end
    if missilestock>missilemax then
        missilestock=missilemax
    end
    if basecount==0 then
        gamestate=2
    end
    if gamestate==1 then
        --generate new stock of missles
        if missilestock<missilemax then
            missileregen = missileregen + 3
            if missileregen>missileregenrate then
                missileregen=0
                missilestock = missilestock + 1
            end
        end
        if math.random(100-math.min(80,math.floor((ElapsedTime-gametime)/2)))==1 then
            local kind=math.random(15)
            if kind>4 then kind=1 end            
            local startx=math.random(WIDTH)
            local starty=HEIGHT*1.05            
            addMissle(startx,starty,kind)
        end       
        -- This sets a background color
        background(106, 164, 152, 255)
        sprite( grad, WIDTH/2, HEIGHT/2,
        WIDTH+20, HEIGHT+20 )
        starMesh:draw()
        --draw the ground
        noStroke()
        fill(59, 135, 41, 255)
        rect(0,0,WIDTH,40)
        fill(255)
        font("Futura-CondensedExtraBold")
        text("Score: "..score.."     Hi-score: "..hiscore,WIDTH/2,HEIGHT*0.98)
        --draw bases
        for i,b in pairs(base) do
            if b.state==1 then
                sprite("Small World:Observatory",b.x,b.y,40)
            elseif b.state==2 then
                sprite("Small World:Windmill",b.x,b.y,40)
            else
                sprite("Small World:Base Small",b.x,b.y-10,40)
                
                if math.random(45)==1 then
                    table.insert(smoke,{x=b.x-4+math.random(7),y=b.y,fade=255,size=0.5+math.random(5)/10,ang=math.random(360),rot=math.random(6)-3,shrink=math.random(10)/1000,rise=1})
                end
            end
        end        
        --draw the missile stock
        for m= 1,missilemax do
            if m<=missilestock then
                sprite("Tyrian Remastered:Missile Small",(WIDTH*0.05)+(m-1)*WIDTH/50,0.98*HEIGHT,10,20)
            end
        end
        --draw spacedust sparkles
        for s,d in pairs(spacedust) do
            tint(255,255,255,d.fade)
            if d.type==1 then
                sprite("Cargo Bot:Star Filled",d.x,d.y,1*d.size)
            else
                sprite("Space Art:Asteroid Small",d.x,d.y,1*d.size)
            end
            d.x = d.x + d.speed*math.sin(math.rad(-d.dir))
            d.y = d.y + d.speed*math.cos(math.rad(-d.dir))
            d.fade = d.fade -d.faderate
            if d.fade<0 then
                table.remove(spacedust,s)
            end
        end
        tint(255)
        --draw smoke
        for i,s in pairs(smoke) do
            tint(255,255,255,s.fade)
            pushMatrix()
            translate(s.x,s.y)
            rotate(s.ang)
            sprite("Cargo Bot:Smoke Particle",0,0,30*s.size)
            popMatrix()
            s.ang = s.ang + s.rot
            s.size = s.size-s.shrink
            s.fade = s.fade -2
            if s.rise==1 then
                s.y = s.y + 1
            end
            if s.fade<0 or s.size<0 then
                table.remove(smoke,i)
            end
            noTint()
        end
        --draw missles
        for i,m in pairs(a) do
            if m.mtype==2 then
                tint(255, 186, 0, 255)
            elseif m.mtype==3 then
                tint(215, 0, 255, 255)
                if math.random(200)==1 or m.y<HEIGHT/3 then
                    num=1+math.random(4)
                    for w=1,num do
                        addMissle(m.x,m.y,1)
                    end
                    table.remove(a,i)
                end
            elseif m.mtype==4 then
                tint(4, 255, 0, 255)
                if math.random(200)==1 or m.y<HEIGHT/3 then
                    num=1+math.random(4)
                    for w=1,num do
                        addMissle(m.x,m.y,2)
                    end
                    table.remove(a,i)
                end
            end
            pushMatrix()
            translate(m.x,m.y)
            rotate(-m.angle+180)
            sprite("Tyrian Remastered:Missile Big",0,0,15,28)
            popMatrix()
            noTint()
            if math.random(25)==1 then
                table.insert(smoke,{x=m.x,y=m.y,fade=255,size=0.5+math.random(5)/10,ang=math.random(360),rot=math.random(6)-3,shrink=math.random(10)/1000,rise=0})
            end
            m.x = m.x + m.spd*math.sin(math.rad(m.angle))
            m.y = m.y + m.spd*math.cos(math.rad(m.angle))
            --check if missle has hit base
            for j,b in pairs(base) do
                if vec2(m.x,m.y):dist(vec2(b.x,b.y))<20 and b.state~=0 then
                    explode(b.x,b.y,i)
                    b.state=0
                end
            end
            --check if missle has hit ground
            if m.y<30 then
                table.remove(a,i)
            end
        end
        --draw any active touch pulses
        for i,p in pairs(pulse) do
            local pulsesize=p.size --the maximum radius of the touch circle pulse
            local fade=100-(p.r/pulsesize)*100 --calculate the fade factor
            fill(255,255,255,fade)
            ellipse(p.x,p.y,p.r)
            p.rate = p.rate + 1.5
            p.r = p.r + p.rate
            if p.r>pulsesize then
                table.remove(pulse,i)
            end
            for j,missile in pairs(a) do
                if vec2(missile.x,missile.y):dist(vec2(p.x,p.y))<p.r/2 and missile.mtype~=2 and missile.mtype~=4 then
                    explode(missile.x,missile.y,j)
                    score = score + 10
                end
            end
        end
        fill(255)
        stroke(255)
        strokeWidth(2)
        for i,t in pairs(touches) do
            if missilebasecount>0 then
                ellipse(t.x,t.y,10)
                local endpt=math.max(1200-800*(ElapsedTime-tsup[i].starttime),50+10*math.sin(5*ElapsedTime))
                local spin=ElapsedTime*40
                tint(248, 19, 19, 255)
                if ElapsedTime-tsup[i].starttime>1.5 then
                    tint(38, 255, 0, 255)
                end
                pushMatrix()
                translate(t.x,t.y)
                rotate(spin)
                for sp=1,4 do
                    translate(-endpt,0)
                    sprite("Cargo Bot:How Arrow",0,0)
                    translate(endpt,0)
                    rotate(90)
                end
                popMatrix()
            end
        end
        noTint()
        if flash==1 then
            flash=0
            background(255)
            sound(SOUND_SHOOT, 21350)
        end
    else
        --game over
        noStroke()
        fill(255,0,0,gameoverfade)
        gameoverfade = gameoverfade + 1
        rect(0,0,WIDTH,HEIGHT)
        fill(0,0,0,255)
        fontSize(70)
        text("Game Over",WIDTH/2,0.55*HEIGHT)
        text("Final Score: "..score,WIDTH/2,0.45*HEIGHT)
        if gameoverfade>300 then
            text("Tap to play again",WIDTH/2,0.3*HEIGHT)
        end
        
    end
end

function touched(touch)
    if touch.state==ENDED or touch.state==CANCELLED then
        if gamestate==2 and gameoverfade>300 then
            if score>hiscore then
                saveLocalData("hiscore",score)
            end
            resetGame()
        end
        if missilebasecount>0 and missilestock>0 then processTouch(touch) end
        touches[touch.id] = nil
        tsup[touch.id]=nil
    else
        touches[touch.id] = touch
        --if there is no supplementary info associated with the current touch then add it
        if tsup[touch.id]==nil then
            tsup[touch.id]={tstartx=touch.x,tstarty=touch.y,starttime=ElapsedTime}
        end
    end
end

function processTouch(touch)
    for j,missile in pairs(a) do
        if ElapsedTime-tsup[touch.id].starttime>1.5 then
            flash=1
        end
        if ElapsedTime-tsup[touch.id].starttime>0 and vec2(touch.x,touch.y):dist(vec2(missile.x,missile.y))<touchacc then
            explode(missile.x,missile.y,j)
            sound(SOUND_EXPLODE, 21347)
        end
    end
    table.insert(pulse,{x=touch.x,y=touch.y,r=8,rate=1,size=50+300*math.min(1.5,ElapsedTime-tsup[touch.id].starttime)}) --add a new pulse
    missilestock = missilestock -1
    sound(SOUND_SHOOT, 21338)
end

function starImage(s)
    local s2 = s/2
    local i = image(s,s)
    setContext(i)
    pushStyle()
    for i = 1,6 do
        fill( 240, 245, 255, i*10 )
        ellipse( s2, s2, (s-1) / i )
    end
    fill(255)
    ellipse( s2, s2, 3 )
    popStyle()
    setContext()
    return i
end

function blend(c1, c2, a)
    return color(c1.r * a + c2.r * (1-a),
    c1.g * a + c2.g * (1-a),
    c1.b * a + c2.b * (1-a),
    c1.a)
end

function addMissle(startx,starty,kind)
    local t=math.random(#base)
    local startangle=math.deg(math.atan2(startx-base[t].x,starty-base[t].y))
    table.insert(a,{x=startx,y=starty,dir=-1^math.random(2),spd=0.5+math.random(5)/2,angle=startangle+180,mtype=kind})
end

function explode(x,y,j)
    local   ix=x
    local    iy=y
    
    if a[j].mtype==2 then
        score = score + 25
        sound(SOUND_EXPLODE, 21337)
    elseif a[j].mtype==4 then
        score = score + 50
        sound(SOUND_EXPLODE, 28733)
    else
        score = score + 10
        sound(SOUND_EXPLODE, 42349)
    end
    table.remove(a,j) --remove missle
    table.insert(pulse,{x=ix,y=iy,r=8,rate=7,size=200}) --add a new pulse
    for s=0,360,12 do
        table.insert(spacedust,{x=ix,y=iy,dir=s,fade=175+math.random(50)+3,size=2+math.random(5),speed=4+math.random(10),faderate=2+math.random(3),type=1})
    end
end

function resetGame()
    points={}
    pulse={}
    smoke={}
    score=0
    gamestate=1
    gameoverfade=0    
    spacedust={}
    base={}
    for i= 1,10 do
        local bldg=1
        if i==1 or i==10 or i==5 then
            bldg=2
        end
        table.insert(base,{x=i*WIDTH/11,y=0.05*HEIGHT,state=bldg})
    end
    missilestock=9
    missileregen=0
    missileregenrate=200
    mps=5 --missiles per silo
    touchacc=25 -- how near to a missile a touch is to cause an explosion
    a={}
    for i=1,5 do
        local startx=math.random(WIDTH)
        local starty=HEIGHT*1.05        
        addMissle(startx,starty,1)
    end
    flash=0
    missilemax=0
    --calculate missle stockpile
    for i,b in pairs(base) do
        if b.state==2 then
            missilemax = missilemax + mps
        end
    end
    missilestock=missilemax
    if readLocalData("hiscore")~=nil then
        hiscore=readLocalData("hiscore")
    else
        hiscore=0
    end
    fontSize(22)
    gametime=ElapsedTime
end