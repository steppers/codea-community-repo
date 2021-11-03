-- Touch based space invaders
-- by West
-- Use this function to perform your initial setup
supportedOrientations(PORTRAIT_ANY)
function setup()
    displayMode(FULLSCREEN)
    
    READY=1
    GAMEOVER=2
    PLAY=3
    gamestate=READY
    deadtimer=0
    
    if readLocalData("hiscore")~=nil then
        hiscore=readLocalData("hiscore")
        hiscore=math.floor(hiscore)
    else
        hiscore=0
    end
    
    touches={}
    tsup={} --tsup contains the supplementary info about the start position of the touch
    points={}
    pulse={}
    slash={}
    bonus={}
    
    parameter.boolean("includeTrail",false)
    parameter.boolean("includeHistory",false)
    parameter.boolean("joinHistory",false)
    parameter.boolean("includePulse",false)
    parameter.boolean("includeClassification",true)
    
    triMesh = mesh()
    col1=color(48, 28, 58, 255)
    --   coladjust=1
    col2=color(99, 31, 185, 255)
    -- This is an array of colours we'll assign to the triMesh vertices
    triCol = { col1,col2,col2,col1,col2,col2}
    -- Assign colors to the mesh, there must be the same number of colours as vertices
    triMesh.colors = triCol
    
    initialise()
end

function initialise()
    alien={}
    bomb=5
    shield=3
    score=0
    aliencount=0
    guntemp=0
    freeze=0
    wordlist1={"you","bacon","Derek","salvation"}
    wordlist2={"mankind","the human race","tomorrow","yesterday","my bacon"}
    wordlist3={"!","?","?!!?!","."}
    w={math.random(#wordlist1),math.random(#wordlist2),math.random(#wordlist3)}
end

-- This function gets called once every frame
function draw()
    guntemp = guntemp - 0.3
    if guntemp<0 then guntemp=0 end
    if guntemp>100 then guntemp=100 end
    freeze = freeze - 0.2
    if freeze <=0 then
        freeze=0
    else
        guntemp=0
    end
    if freeze>100 then freeze=100 end
    
    
    -- This sets a background color
    background(106, 164, 152, 255)
    
    local topleft = vec2(0,HEIGHT)
    local bottomleft = vec2(0,0)
    local bottomright = vec2(WIDTH,0)
    local topright=vec2(WIDTH,HEIGHT)
    -- Set points on mesh
    triMesh.vertices = { topleft,
        bottomleft,
    bottomright,bottomright,topleft,topright }
    --cycle the colors
    
    col2=color(91,33.155+freeze,255)
    triMesh.colors={col1,col2,col2,col2,col1,col1}
    -- Draw the mesh that we setup
    triMesh:draw()
    
    
    fill(0, 133, 255, 255)
    stroke(126,184,162,255)
    ellipse(WIDTH/2,-2.5*WIDTH+30,WIDTH*5)
    noFill()
    for i=1,shield do
        stroke(255)
        ellipse(WIDTH/2,-2.5*WIDTH+30+5*i,WIDTH*5)
    end
    
    for j,a in pairs(alien) do
        if a.t==2 then
            tint(255,50,60)
        elseif a.t==3 then
            tint(125,255,125)
        elseif a.t==4 then
            tint(16, 231, 249, 255)
        end
        sprite("Platformer Art:Guy Standing",a.x,a.y,64/3,92/3)
        noTint()
        a.y = a.y - a.spd
        if a.y<30 then
            shield = shield - 1
            
            table.remove(alien,j)
            --if shield is less the 0 then game over
            if shield<0 then
                gamestate=GAMEOVER
            end
        end
    end
    
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
        for j,a in pairs(alien) do
            if vec2(s.x,s.y):dist(vec2(a.x,a.y))<20 then
                s.count = s.count + 1
                score = score + 5
                sound("Game Sounds One:Pop 2")
                if a.t==2 then
                    table.insert(bonus,{x=a.x,y=a.y,txt="+1 bomb",fade=255})
                    bomb = bomb + 1
                    sound("Game Sounds One:Reload 1")
                    
                    if bomb>20 then bomb=20 end
                elseif a.t==3 then
                    table.insert(bonus,{x=a.x,y=a.y,txt="+1 shield",fade=255})
                    shield = shield + 1
                    sound("Game Sounds One:Bell 2")
                    if shield>5 then shield=5 end
                elseif a.t==4 then
                    freeze = freeze + 100
                    sound("Game Sounds One:Radar")
                    table.insert(bonus,{x=a.x,y=a.y,txt="Freeze",fade=255})
                    guntemp=0
                elseif s.count>1 then
                    table.insert(bonus,{x=a.x,y=a.y,txt="x"..s.count,fade=255})
                end
                table.insert(pulse,{x=a.x,y=a.y,r=16,rate=2,max=100}) --add a new pulse
                table.remove(alien,j)
                
            end
        end
        
        
        if s.fade<0 then table.remove(slash,i) end
        popMatrix()
    end
    
    for k,b in pairs(bonus) do
        fill(46, 112, 99, b.fade)
        text(b.txt,b.x,b.y)
        b.fade = b.fade - 3
        if b.fade<0 then
            table.remove(bonus,k)
        end
    end
    
    noStroke()
    
    --draw any active touch pulses
    for i,p in pairs(pulse) do
        local pulsesize=p.max --the maximum radius of the touch circle pulse
        local fade=100-(p.r/pulsesize)*100 --calculate the
        fill(255,255,255,fade)
        ellipse(p.x,p.y,p.r)
        p.rate = p.rate + 1
        p.r = p.r + p.rate
        
        for j,a in pairs(alien) do
            if vec2(p.x,p.y):dist(vec2(a.x,a.y))<p.r/2 then
                table.insert(pulse,{x=a.x,y=a.y,r=16,rate=2,max=100}) --add a new pulse
                table.remove(alien,j)
                score = score + 3
            end
        end
        if p.r>pulsesize then
            table.remove(pulse,i)
        end
    end
    if bomb>20 then bomb=20 end
    --draw console
    fill(46, 112, 99, 255)
    text("Score: "..score,WIDTH*0.1,HEIGHT-20)
    text("High Score: "..hiscore,WIDTH*0.9,HEIGHT-20)
    text("Bombs:",WIDTH/2,HEIGHT-20)
    
    for i=1,bomb do
        rect(WIDTH/2+23+i*10,HEIGHT-27,8,14)
    end
    text("Temp:",WIDTH/2,HEIGHT-40)
    rect(WIDTH/2+30,HEIGHT-46,guntemp,14)
    
    
    fill(255)
    --draw a circle at each of the touched points
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
    for i,t in pairs(touches) do
        fill(255)
        stroke(255)
        
        --draw path of touch
        if includeTrail==true then
            fadespeed=500
            for j,p in pairs(tsup[i].path) do
                trailfade=math.max((p.age-ElapsedTime)*fadespeed,-255)
                stroke(255,255,255,255+trailfade)
                fill(255,255,255,255+trailfade)
                if trailfade>-255 then
                    -- ellipse(p.pos.x,p.pos.y,5)
                    if j>1 then
                        line(prevx,prevy,p.pos.x,p.pos.y)
                    end
                end
                prevx=p.pos.x
                prevy=p.pos.y
            end
        end
    end
    
    if gamestate==PLAY then
        if math.random(30)==1 then
            local atype=1
            if math.random(30)==1 then atype=1+math.random(3) end
            table.insert(alien,{x=50+math.random(WIDTH-100),y=HEIGHT+50,t=atype,spd=0.2+aliencount/80+math.random(10)/10})
            aliencount = aliencount + 1
        end
        
    elseif gamestate==READY then
        deadtimer = deadtimer + 1
        fill(220, 194, 30, 255)
        strokeWidth(3)
        fontSize(72)
        text("Alien Invasion",WIDTH/2,HEIGHT*0.8)
        fontSize(40)
        text("Ready?",WIDTH/2,HEIGHT*0.3)
        
        
        
        textAlign(CENTER)
        textWrapWidth(WIDTH-100)
        fontSize(24)
        local instruct="Flick the screen in the direction you wish to fire rockets."
        instruct = instruct.."\nBeware, firing rockets increases the temperature. Overheat and you won't be able to fire"
        instruct = instruct.."\n\nTap to fire nuclear bomb. Any aliens caught in the blast will perish."
        instruct = instruct.."\n\nLookout for special aliens bearing gifts!"
        
        
        instruct = instruct.."\n\nOnly "..wordlist1[w[1]].." can save "..wordlist2[w[2]]..wordlist3[w[3]]
        text(instruct,WIDTH/2,HEIGHT*0.6)
        fontSize(18)
        if deadtimer==20 then
            sound("Game Sounds One:1-2 Go")
        end
        
        
        -- draw the game over screen
    elseif gamestate==GAMEOVER then
        
        if deadtimer==1 then
            sound("Game Sounds One:Pac Death 2")
        end
        deadtimer = deadtimer + 1
        fill(25, 164, 221, 255)
        strokeWidth(3)
        fontSize(40)
        text("Game Over",WIDTH/2,HEIGHT/2)
        text("Score: "..math.floor(score),WIDTH/2,2*HEIGHT/3)
        text("Double Tap to restart",WIDTH/2,HEIGHT/3)
        fontSize(18)
        --check the score and store it if it is a new high score
        if score>hiscore then
            saveLocalData("hiscore",score)
            hiscore=score
        end
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
        if includeHistory==true then
            table.insert(points,vec2(touch.x,touch.y)) --add a point to the points table
        end
        
        if includeClassification==true then
            if ElapsedTime-tsup[touch.id].starttime<0.2 then
                --very short event
                if tsup[touch.id]==nil and bomb>0 then
                    --        print("tap")
                    table.insert(pulse,{x=touch.x,y=touch.y,r=8,rate=1,max=500}) --add a new pulse
                    bomb = bomb - 1
                    sound("Game Sounds One:Slap")
                elseif vec2(touch.x,touch.y):dist(vec2(tsup[touch.id].tstartx,tsup[touch.id].tstarty))<10 and bomb>0 then
                    --    print("tap")
                    table.insert(pulse,{x=touch.x,y=touch.y,r=8,rate=1,max=500}) --add a new pulse
                    bomb = bomb - 1
                    sound("Game Sounds One:Slap")
                elseif guntemp<=90 then
                    
                    local ang=math.atan2(touch.y-tsup[touch.id].tstarty,touch.x-tsup[touch.id].tstartx)
                    --       print("dash")
                    table.insert(slash,{x=tsup[touch.id].tstartx,y=tsup[touch.id].tstarty,a=ang,fade=255,count=0})
                    guntemp = guntemp + 10
                    sound("Game Sounds One:Blaster")
                end
            elseif ElapsedTime-tsup[touch.id].starttime<1 then
                --a slightly longer gesture
                if touch.x>tsup[touch.id].tstartx+25 and math.abs(touch.y-tsup[touch.id].tstarty)<50 then
                    print("swipe right")
                elseif touch.x<tsup[touch.id].tstartx-25 and math.abs(touch.y-tsup[touch.id].tstarty)<50 then
                    print("swipe left")
                elseif touch.y>tsup[touch.id].tstarty+25 and math.abs(touch.x-tsup[touch.id].tstartx)<50 then
                    print("swipe up")
                elseif touch.y<tsup[touch.id].tstarty-25 and math.abs(touch.x-tsup[touch.id].tstartx)<50 then
                    print("swipe down")
                end
            end
        end
    elseif gamestate==READY then
        if deadtimer>120 then
            gamestate=PLAY
            deadtimer=0
        end
    end
end