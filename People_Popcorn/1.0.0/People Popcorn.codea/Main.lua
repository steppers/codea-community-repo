-- People Popcorn
-- by West

--two space chameleons, Clive and Agnes descend on the unsuspecting planet. Who will gobble up the most people?
supportedOrientations(LANDSCAPE_ANY)
-- Use this function to perform your initial setup
function setup()
    displayMode(FULLSCREEN_NO_BUTTONS)
    --  displayMode(FULLSCREEN)
    WALK=1
    STAND=2
    FALL=3
    READY=1
    GAMEOVER=2
    PLAY=3
    gamestate=READY
    deadtimer=0
    gamemode=1 --default 1 player mode - 2 will be 2 player mode
    --create some custom graphics
    head=image(70,70)
    setContext(head)
    headmesh = mesh()
    
    headmesh.vertices = triangulate({vec2(29,43),vec2(29,55),vec2(31,61),vec2(37,61),vec2(49,53),vec2(55,51),vec2(59,47),vec2(61,39),vec2(61,31),vec2(47,35),vec2(35,35)})
    headmesh:setColors(255,255,255,255)
    headmesh:draw()
    
    strokeWidth(1)
    fill(255)
    stroke(150)
    ellipse(50,50,16)
    fill(0)
    ellipse(50,53,4)
    fill(255)
    noStroke()
    setContext()
    
    jaw=image(70,70)
    setContext(jaw)
    jawmesh = mesh()
    jawmesh.vertices = triangulate({vec2(29,47),vec2(35,39),vec2(47,39),vec2(61,35),vec2(55,31),vec2(28,31)})
    jawmesh:setColors(230,230,230,255)
    jawmesh:draw()
    setContext()
    
    
    fill(255)
    fontSize(80)
    bombimg=image(80,80)
    setContext(bombimg)
    local char = unicode2UTF8(128163)
    text(char,40,40)
    setContext()
    
    fontSize(80)
    cow=image(80,80)
    setContext(cow)
    local char = unicode2UTF8(128004)
    text(char,40,40)
    setContext()
    
    bike=image(80,80)
    setContext(bike)
    local char = unicode2UTF8(128692)
    text(char,40,40)
    setContext()
    --    saveLocalData("hiscore",0)
    if readLocalData("hiscore")~=nil then
        hiscore=readLocalData("hiscore")
    else
        hiscore=0
    end
    
    obj={
        {img="Planet Cute:Character Boy",w=25,h=42,spd=1},
        {img="Planet Cute:Character Cat Girl",w=25,h=42,spd=1.5},
        {img="Planet Cute:Character Horn Girl",w=25,h=42,spd=2},
        {img="Planet Cute:Character Pink Girl",w=25,h=42,spd=2.5},
        {img="Planet Cute:Character Princess Girl",w=33,h=57,spd=1},
        {img=cow,w=-25,h=25,spd=0.5},
        {img=bike,w=-25,h=25,spd=3}
    }
    
    initialise()
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
    
    triMesh = mesh()
    col1=color(29,27,38)
    timer=0
    coladjust=1
    col2=color(44,76,35)
    -- This is an array of colours we'll assign to the triMesh vertices
    triCol = { col1,col2,col2,col1,col2,col2}
    -- Assign colors to the mesh, there must be the same number of colours as vertices
    triMesh.colors = triCol
    touches={}
    tsup={} --tsup contains the supplementary info about the start position of the touch
end

-- This function gets called once every frame
function draw()
    --increase the scoring as more peopleare rescued
    if #men<10 then
        multiplier=3
    elseif #men<20 then
        multiplier=2
    else
        multiplier=1
    end
    if redcount>0 then redcount = redcount - 1 end
    if redcount2>0 then redcount2 = redcount2 - 1 end
    -- This sets a dark background color
    background(40, 40, 50)
    sprite( grad, WIDTH/2, HEIGHT/2,
    WIDTH+20, HEIGHT+20 )
    starMesh:draw()
    fill(44, 76, 35, 255)
    noStroke()
    rect(0,0,WIDTH,92)
    local topleft = vec2(0,92)
    local bottomleft = vec2(0,78)
    local bottomright = vec2(WIDTH,78)
    local topright=vec2(WIDTH,92)
    -- Set points on mesh
    triMesh.vertices = { topleft,
        bottomleft,
    bottomright,bottomright,topleft,topright }
    triMesh.colors={col1,col2,col2,col2,col1,col1}
    -- Draw the mesh that we setup
    triMesh:draw()
    
    --Clive
    --experimental tongue
    tonguex = tonguex + tongueacc*math.cos(math.rad(tongueangle))
    tonguey = tonguey + tongueacc*math.sin(math.rad(tongueangle))
    tongueacc = tongueacc - 0.2
    if tonguex>WIDTH then tongueacc = tongueacc * -1 tonguex=WIDTH end
    if tonguey<150 then tongueacc = tongueacc * -1 tonguey=150 end
    if tonguey>HEIGHT then tongueacc = tongueacc * -1 tonguey=HEIGHT end
    if tonguex<0 then
        tongueready=1
        tongueangle=0
        tonguex=0
        tonguey=chamy
    end
    
    tint(255, 0, 197, 255)
    pushMatrix()
    translate(tonguex,tonguey)
    
    popMatrix()
    noTint()
    strokeWidth(5)
    stroke(157, 0, 255, 255)
    line(chamx,chamy,tonguex,tonguey)
    noStroke()
    fill(42, 89, 33, 255)
    ellipse(chamx-10,chamy,20)
    pushMatrix()
    local choffset=12
    
    local mouthopen=math.min(35,(tonguex-chamx)/5)
    if redcount>40 then mouthopen=math.random(10) end
    
    translate(chamx,chamy)
    rotate(tongueangle)
    rotate(-mouthopen)
    tint(math.max(redcount,33),136,47,255)
    sprite(jaw,0,0)
    rotate(mouthopen)
    rotate(mouthopen)
    sprite(head,0,0)
    noTint()
    rotate(-mouthopen)
    popMatrix()
    
    --Agnes
    --experimental tongue
    tonguex2 = tonguex2 - tongueacc2*math.cos(math.rad(tongueangle2))
    tonguey2 = tonguey2 - tongueacc2*math.sin(math.rad(tongueangle2))
    tongueacc2 = tongueacc2 + 0.2
    if tonguex2<0 then tongueacc2 = tongueacc2 * -1 tonguex2=0 end
    if tonguey2<150 then tongueacc2 = tongueacc2 * -1 tonguey2=150 end
    if tonguey2>HEIGHT then tongueacc2 = tongueacc2 * -1 tonguey2=HEIGHT end
    if tonguex2>WIDTH then
        tongueready2=1
        tongueangle2=180
        tonguex2=WIDTH
        tonguey2=chamy2
        
    end
    
    tint(255, 0, 197, 255)
    pushMatrix()
    translate(tonguex2,tonguey2)
    
    popMatrix()
    noTint()
    strokeWidth(5)
    stroke(157, 0, 255, 255)
    line(chamx2,chamy2,tonguex2,tonguey2)
    noStroke()
    fill(30, 45, 128, 255)
    ellipse(chamx2+10,chamy2,20)
    pushMatrix()
    local choffset=12
    
    local mouthopen=math.min(35,(chamx2-tonguex2)/5)
    mouthopen=-mouthopen
    if redcount2>40 then mouthopen=math.random(10) end
    
    translate(chamx2,chamy2)
    rotate(tongueangle2)
    rotate(-mouthopen)
    tint(math.max(redcount2,13),147,220,255)
    sprite(jaw,0,0,70,-70)
    rotate(mouthopen)
    rotate(mouthopen)
    sprite(head,0,0,70,-70)
    noTint()
    rotate(-mouthopen)
    popMatrix()
    
    
    for i,m in pairs(men) do
        if m.xacc>0 and m.y<=100 then m.xacc = m.xacc -0.06 end
        if m.xacc<0 and m.y<=100 then m.xacc = m.xacc + 0.06 end
        if math.abs(m.xacc)<0.05 then m.xacc=0 end
        if m.y>100 then
            m.yacc = m.yacc -0.1
            if m.xacc>0 then m.face=1 end
            if m.xacc<0 then m.face=-1 end
        else
            --make the people jump up and down at the end
            if gamestate==GAMEOVER and math.random(10)==1 then
                m.yacc=math.random(20)/10
            else
                m.y=100
                m.yacc=0
                if gamestate~=GAMEOVER then
                    m.x = m.x + (m.face*obj[m.col].spd)
                end
            end
        end
        --draw the active bombs
        for j,b in pairs(bomb) do
            if b.fuse<=0 then
                bound=50+b.size
                local mag=vec2(m.x,m.y):dist(vec2(b.x,b.y-20))
                local angle=math.atan2((b.y-20)-m.y,b.x-m.x)
                if mag<bound and mag>-bound then
                    local mag2=(bound-math.abs(mag))*mag/math.abs(mag)
                    m.xacc=m.xacc-(mag2/10)*math.cos(angle)
                    m.yacc=m.yacc-(mag2/10)*math.sin(angle)
                elseif math.abs(b.x-m.x)<3*bound and m.y==100 then
                    m.yacc = m.yacc + 1
                end
            end
            if b.fuse<-0.2 then table.remove(bomb,j)
                sound("Game Sounds One:Pop 1")
            end
        end
        if m.x>WIDTH or m.x<0 then
            m.face = m.face * -1
            m.xacc = m.xacc * -1
        end
        m.y = m.y + m.yacc
        m.x = m.x + m.xacc
        
        if m.stuck==1 then
            m.x=tonguex
            m.y=tonguey
        elseif m.stuck==2 then
            m.x=tonguex2
            m.y=tonguey2
        end
        pushMatrix()
        if m.col==5 then
            translate(m.x,m.y+6)
        else
            translate(m.x,m.y)
        end
        if m.xacc~=0 and m.yacc~=0 then
            rotate(math.deg(math.atan2(m.yacc,m.xacc))-90)
        end
        --draw the people
        
        sprite(obj[m.col].img,0,0,m.face*obj[m.col].w,obj[m.col].h)
        popMatrix()
        noTint()
        if math.abs(m.x-tonguex)<25 and math.abs(m.y-tonguey)<25 then
            if m.stuck==0 then
                sound("Game Sounds One:Punch 1")
            end
            m.stuck=1
        end
        if math.abs(m.x-tonguex2)<25 and math.abs(m.y-tonguey2)<25 then
            if m.stuck==0 then
                sound("Game Sounds One:Punch 1")
            end
            m.stuck=2
        end
        
        if m.stuck==1 and tonguex<10 then
            table.remove(men,i)
            if m.col==5 then
                if #men==49 or #men==0 then
                    --bonus for eating queen first or last
                    score = score + 200
                end
                score = score + (100*multiplier)
                sound("A Hero's Quest:Drink 2")
                queensaved=1
            else
                score = score + (10*multiplier)
                sound("A Hero's Quest:Eat 1")
                --play a bike bell if cyclist is consumed
                if m.col==7 then
                    sound("Game Sounds One:Bell 1")
                end
            end
            p1count = p1count + 1
        end
        if m.stuck==2 and tonguex2>WIDTH-10 then
            table.remove(men,i)
            if m.col==5 then
                score = score + (100*multiplier)
                sound("A Hero's Quest:Drink 2")
                queensaved=2
            else
                score = score + (10*multiplier)
                sound("A Hero's Quest:Eat 1")
                --play a bike bell if cyclist is consumed
                if m.col==7 then
                    sound("Game Sounds One:Bell 1")
                end
            end
            if gamemode==2 then
                p2count = p2count + 1
            end
        end
    end
    --kiss: if tongue tips touch then generate a heart
    if math.abs(tonguex2-tonguex)<30 and math.abs(tonguey2-tonguey)<30 then
        table.insert(particle,{x=tonguex-math.random(40),y=tonguey+math.random(20),size=math.random(5),fade=255,t=2})
        sound("Game Sounds One:Slap")
        score = score + 5
    end
    
    for i,b in pairs(bomb) do
        if b.stuck==1 then
            b.x=tonguex
            b.y=tonguey
            b.fuse=1
        elseif b.stuck==2 then
            b.x=tonguex2
            b.y=tonguey2
            b.fuse=1
        end
        
        
        if math.abs(b.x-tonguex)<25 and math.abs(b.y-tonguey)<25 then
            if b.stuck==0 then
                sound("Game Sounds One:Punch 1")
            end
            b.stuck=1
        end
        if b.stuck==1 and tonguex<10 then
            table.remove(bomb,i)
            score = score -100
            sound("Game Sounds One:Horror Howl 1")
            redcount=255
        end
        if math.abs(b.x-tonguex2)<25 and math.abs(b.y-tonguey2)<25 then
            if b.stuck==0 then
                sound("Game Sounds One:Punch 1")
            end
            b.stuck=2
        end
        if b.stuck==2 and tonguex2>WIDTH-10 then
            table.remove(bomb,i)
            score = score -100
            sound("Game Sounds One:Horror Howl 1")
            redcount2=255
        end
        if b.fuse<=0 then
            sprite("Small World:Explosion",b.x,b.y+4,24+2*b.size+math.sin(7*ElapsedTime),24+2*b.size+math.cos(11*ElapsedTime))
        else
            sprite(bombimg,b.x,b.y,15+b.size+math.sin(7*ElapsedTime),15+b.size+math.cos(11*ElapsedTime))
            strokeWidth(2)
            fill(252, 252, 252, 255)
            text(math.ceil(b.fuse),b.x,b.y+20)
        end
        b.fuse = b.fuse - 0.03
        
        if b.y>100 then
            b.yacc = b.yacc -0.1
        else
            b.y=100
        end
        b.y = b.y + b.yacc
        
    end
    
    if redcount>50 then
        if math.random(5)==1 then
            table.insert(particle,{x=chamx+math.random(40),y=chamy+math.random(20),size=math.random(5),fade=255,t=1})
        end
    end
    if redcount2>50 then
        if math.random(5)==1 then
            table.insert(particle,{x=chamx2-math.random(40),y=chamy2+math.random(20),size=math.random(5),fade=255,t=1})
        end
    end
    
    for i,s in pairs(particle) do
        tint(255,255,255,s.fade)
        if s.t==1 then
            sprite("Cargo Bot:Smoke Particle",s.x,s.y,s.size,s.size)
        else
            sprite("Small World:Heart Glow",s.x,s.y,s.size,s.size)
        end
        noTint()
        s.fade = s.fade - math.random(3)
        s.size = s.size + math.random(10)/10
        s.y = s.y + 2
        if s.fade<0 then
            table.remove(particle,i)
        end
    end
    
    fill(255)
    --draw start and stop circles and connect them with lines for all active touches
    strokeWidth(2)
    --  for i,t in pairs(touches) do
    --      stroke(255)
    --   sprite(bombimg,t.x,t.y,12+math.sin(7*ElapsedTime),12+math.cos(11*ElapsedTime))
    --    end
    textMode(CENTER)
    font("ArialRoundedMTBold")
    fontSize(24)
    
    if gamemode==1 then
        text("People eaten: "..50-#men,WIDTH*0.1,30)
        text("Score: "..score,0.10*WIDTH,HEIGHT-30)
        text("Hi-score: "..hiscore,WIDTH*0.9,HEIGHT-30)
    else
        text("People eaten: "..p1count,WIDTH*0.1,30)
        text("People eaten: "..p2count,WIDTH*0.85,30)
    end
    --add a queen icon if the queen has been eaten
    if queensaved==1 then
        sprite(obj[5].img,WIDTH*0.22,33,101/3,171/3)
    end
    --display the countdown
    fontSize(72)
    text(math.floor(counter),WIDTH/2,HEIGHT-50)
    fontSize(16)
    if #men==0 then
        if gamestate~=GAMEOVER then
            score = score + 250
        end
        gamestate=GAMEOVER
        
    end
    if gamestate==PLAY then
        counter = counter - 0.02
        if counter<=1 then
            gamestate=GAMEOVER
        end
        
        if gamemode==2 and math.random(50)==1 then
            table.insert(bomb,{x=30+math.random(WIDTH-60),y=HEIGHT,yacc=0,fuse=4+math.random(3),stuck=0,size=3+math.random(9)})
            
        end
        
        -- Draw the "Ready" screen
    elseif gamestate==READY then
        deadtimer = deadtimer + 1
        playerxspd=0
        font("ArialRoundedMTBold")
        fill(220, 194, 30, 255)
        strokeWidth(3)
        fontSize(72)
        text("People Popcorn",WIDTH/2,HEIGHT*0.8)
        fontSize(40)
        text("Ready?",WIDTH/2,HEIGHT*0.3)
        textAlign(CENTER)
        textWrapWidth(WIDTH-200)
        fontSize(24)
        if gamemode==1 then
            instruct="Clive and Agnes are hungry space chameleons whose favourite food is people popcorn!"
            instruct = instruct.."\nTap screen to create a bomb to pop the people from the planet"
            instruct = instruct.."\nThe longer the tap the bigger the POP!"
            instruct = instruct.."\nSwipe right for Clive's tongue, swipe left for Agnes'"
            instruct = instruct.."\nDon't eat the bombs though, they cause terrible indigestion"
        else
            instruct="Clive and Agnes are hungry space chameleons whose favourite food is people popcorn!"
            instruct = instruct.."\nWho eats the most, WINS!"
            instruct = instruct.."\nPlayer 1 controls Clive by swiping in the left of the screen only."
            instruct = instruct.."\nPlayer 2 controls Agnes by swiping in the right of the screen only."
            instruct = instruct.."\nBombs automatically appear."
        end
        
        --add a fortune cookie statement to the end
        instruct = instruct.."\n\nOnly "..wordlist1[w[1]].." can save "..wordlist2[w[2]]..wordlist3[w[3]]
        text(instruct,WIDTH/2,HEIGHT*0.6)
        
        fill(200,255,255)
        text(gamemode.." Player Mode",WIDTH/2,HEIGHT*0.07)
        
        
        -- draw the game over screen
    elseif gamestate==GAMEOVER then
        
        if gamemode==1 then
            if deadtimer==1 then
                if #men>0 then
                    sound("Game Sounds One:Pac Death 2")
                else
                    sound("Game Sounds One:Crowd Cheer")
                end
            end
            
            fill(25, 164, 221, 255)
            strokeWidth(3)
            fontSize(40)
            --Print a different message if all the people have been eaten
            if #men>0 then
                text("Time up",WIDTH/2,HEIGHT/2)
            else
                text("Population Popcorn Popped!",WIDTH/2,HEIGHT/2)
            end
            text("Score: "..math.floor(score),WIDTH/2,2*HEIGHT/3)
            
            fontSize(24)
            --check the score and store it if it is a new high score
            if score>hiscore then
                saveLocalData("hiscore",score)
                hiscore=score
            end
        else
            fontSize(74)
            if p1count>p2count then
                if deadtimer==1 then
                    sound("Game Sounds One:Crowd Cheer")
                end
                fill(33, 167, 47, 255)
                text("Clive Wins!",WIDTH/2,HEIGHT/2)
            elseif p1count<p2count then
                if deadtimer==1 then
                    sound("Game Sounds One:Crowd Cheer")
                end
                fill(13,147,220,255)
                text("Agnes Wins!",WIDTH/2,HEIGHT/2)
            elseif p1count==p2count then
                if deadtimer==1 then
                    sound("Game Sounds One:Crowd Sad")
                end
                fill(255, 193, 0, 255)
                text("Draw",WIDTH/2,HEIGHT/2)
            end
        end
        fontSize(40)
        text("Double Tap to restart",WIDTH/2,HEIGHT/3)
        deadtimer = deadtimer + 1
        fontSize(16)
        --restart the game after a double tap and a short delay
        if deadtimer>100 and CurrentTouch.tapCount==2 then
            gamestate=READY
            deadtimer=0
            initialise()
        end
    end
    
    
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
    if gamestate==PLAY then
        if ElapsedTime-tsup[touch.id].starttime<0.2 then
            --very short event
            if tsup[touch.id]==nil then
                if gamemode==1 then
                    table.insert(bomb,{x=touch.x,y=touch.y,yacc=0,fuse=3,stuck=0,size=math.ceil(math.max(2,math.min(10,(ElapsedTime-tsup[touch.id].starttime)*6)))})
                end
            elseif vec2(touch.x,touch.y):dist(vec2(tsup[touch.id].tstartx,tsup[touch.id].tstarty))<10 then
                if gamemode==1 then
                    table.insert(bomb,{x=touch.x,y=touch.y,yacc=0,fuse=3,stuck=0,size=math.ceil(math.max(2,math.min(10,(ElapsedTime-tsup[touch.id].starttime)*6)))})
                end
            else
                local ang=math.atan2(touch.y-tsup[touch.id].tstarty,touch.x-tsup[touch.id].tstartx)
                local dang=math.deg(ang)
                if dang>-90 and dang<90 then
                    if tongueready==1 and redcount<1 and ((gamemode==2 and touch.x<WIDTH/2) or gamemode==1)then
                        table.insert(slash,{x=touch.x,y=touch.y,a=ang,fade=255})
                        tongueacc=30
                        tongueready=0
                        tongueangle=dang
                    end
                else
                    if tongueready2==1 and redcount2<1 and ((gamemode==2 and touch.x>WIDTH/2) or gamemode==1) then
                        table.insert(slash,{x=touch.x,y=touch.y,a=ang,fade=255})
                        tongueacc2=-30
                        tongueready2=0
                        tongueangle2=dang
                    end
                end
            end
        else
            if gamemode==1 then
                table.insert(bomb,{x=touch.x,y=touch.y,yacc=0,fuse=3,stuck=0,size=math.ceil(math.max(2,math.min(10,(ElapsedTime-tsup[touch.id].starttime)*6)))})
            end
        end
    elseif gamestate==READY then
        if touch.y<HEIGHT*0.15 then
            gamemode = gamemode + 1
            sound("Game Sounds One:Radar")
            if gamemode>2 then gamemode=1 end
        elseif deadtimer>120 then
            gamestate=PLAY
            playerxspd=1
            deadtimer=0
            sound(SOUND_POWERUP, 14384)
        end
    end
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

function initialise()
    men={}
    --insert 1 queen
    table.insert(men,{x=math.random(WIDTH),y=100+math.random(200),ang=0,state=math.random(3),face=1,yacc=0,xacc=0,col=5})
    for i=1,49 do
        local f=math.random(2)
        if f==2 then f=-1 end
        local kind=math.random(7)
        if kind==5 then kind = kind - math.random(3) end
        table.insert(men,{x=math.random(WIDTH),y=100+math.random(200),ang=0,state=math.random(3),face=f,yacc=0,xacc=0,col=kind,stuck=0})
    end
    bomb={}
    counter=100
    score=0
    score=0
    queensaved=0
    multiplier=1
    wordlist1={"you","bacon","JakAttak","salvation","yojimbo2000","CodeaNoob","Simeon","Chuck Norris","the meek","Ignatz","dave1707","andymac3d","Flash","truth","justice","deactive","Nathan","TechDojo","Wibble"}
    wordlist2={"mankind","the human race","tomorrow","yesterday","my bacon","planet earth","me","time and effort","us","my soul","humanity","money","for a rainy day","our dignity","wibble"}
    wordlist3={"!","?","?!!?!",".","...","!!","!!!"," now",". Wibble!"}
    w={math.random(#wordlist1),math.random(#wordlist2),math.random(#wordlist3)}
    
    chamx=10
    chamy=500
    tonguex=chamx
    tonguey=chamy
    tongueacc=0
    tongueangle=-20+math.random(40)
    tongueready=1
    
    chamx2=WIDTH-10
    chamy2=500
    tonguex2=chamx2
    tonguey2=chamy2
    tongueacc2=0
    tongueangle2=-20+math.random(40)+180
    tongueready2=1
    
    slash={}
    redcount=0
    redcount2=0
    particle={}
    p1count=0
    p2count=0
end

-- thanks to mpilgrem for the following code posted on the forums
-- Unicode code point to UTF-8 format string of bytes
--
-- Bit Last point Byte 1   Byte 2   Byte 3   Byte 4   Byte 5   Byte 6
-- 7   U+007F     0xxxxxxx
-- 11  U+07FF     110xxxxx 10xxxxxx
-- 16  U+FFFF     1110xxxx 10xxxxxx 10xxxxxx
-- 21  U+1FFFFF   11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
-- 26  U+3FFFFFF  111110xx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
-- 31  U+7FFFFFFF 1111110x 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
--
-- However, largest integer in Codea's Lua is 0x7FFFFF (23 bit)
-- With acknowledgement also to Andrew Stacey's UTF-8 library
function unicode2UTF8(u)
    u = math.max(0, math.floor(u)) -- A positive integer
    local UTF8
    if u < 0x80 then          -- less than  8 bits
        UTF8 = string.char(u)
    elseif u < 0x800 then     -- less than 12 bits
        local b2 = u % 0x40 + 0x80
        local b1 = math.floor(u/0x40) + 0xC0
        UTF8 = string.char(b1, b2)
    elseif u < 0x10000 then   -- less than 16 bits
        local b3 = u % 0x40 + 0x80
        local b2 = math.floor(u/0x40) % 0x40 + 0x80
        local b1 = math.floor(u/0x1000) + 0xE0
        UTF8 = string.char(b1, b2, b3)
    elseif u < 0x200000 then  -- less than 22 bits
        local b4 = u % 0x40 + 0x80
        local b3 = math.floor(u/0x40) % 0x40 + 0x80
        local b2 = math.floor(u/0x1000) % 0x40 + 0x80
        local b1 = math.floor(u/0x40000) + 0xF0
        UTF8 = string.char(b1, b2, b3, b4)
    elseif u < 0x800000 then -- less than 24 bits
        local b5 = u % 0x40 + 0x80
        local b4 = math.floor(u/0x40) % 0x40 + 0x80
        local b3 = math.floor(u/0x1000) % 0x40 + 0x80
        local b2 = math.floor(u/0x40000) % 0x40 + 0x80
        local b1 = math.floor(u/0x1000000) + 0xF8
        UTF8 = string.char(b1, b2, b3, b4, b5)
    else
        print("Error: Code point too large for Codea's Lua.")
    end
    return UTF8
end