-- Mountains
-- Simple endless runner game by West
-- taking inspiration from "Alto's adventure" for the Mountain backdrop and day to night cycle
-- Use this function to perform your initial setup
function setup()
    --get rid of the sidebar
    displayMode(FULLSCREEN)
    -- define 3 the three game states for the finite state machine game engine and initialise gamestate variable
    READY=1
    GAMEOVER=2
    PLAY=3
    gamestate=READY
    --reset highscore
    --   saveLocalData("hiscore",0)
    if readLocalData("hiscore")~=nil then
        hiscore=readLocalData("hiscore")
    else
        hiscore=0
    end
    --perform set up function
    initialise()
    -- set up variables to control the day
    --position of the sun
    sunx=0
    suny=0
    suncount=-6 --controls the speed of the sun
    sunbeam=mesh() -- a mesh for the brief sunbeams that appear when crossing the mountain threshhold
    sunray=image(500,500)
    --create an image to use as the blended sky fade around the sun
    setContext(sunray)
    for i=1,250 do
        fill(255,255,255,1)
        ellipse(250,250,251-i)
    end
    setContext()
end

-- This function gets called once every frame
function draw()
    -- This variable sets a colour offset based on the height of the sun and will allow the sky colour and all objects to be tinted appropriately
    local hadj=math.max(-30,(HEIGHT-suny)/6)
    --Colour the sky
    background(200-hadj,200-hadj,255-hadj)
    noStroke()
    --draw the sun blending into the sky
    fill(255, 255, 255, 255)
    tint(255,255,155)
    sprite(sunray,sunx,suny,1000,1000)
    noTint()
    -- draw the sun
    ellipse(sunx,suny,40)
    -- draw the sun "cross"
    for i=1,10 do
        fill(255,255,100,10)
        rect(sunx-8*(15-i),suny-16,8*(15-i)*2,32)
        rect(sunx-16,suny-8*(15-i),32,8*(15-i)*2)
    end
    --calculate the new sun position based on the time of day (suncount)
    suny = HEIGHT/2 + 600*math.sin(math.rad(suncount))
    sunx = WIDTH/2 - 400*math.cos(math.rad(suncount))
    --advance the time of day
    suncount = suncount + 0.03
    --update the base level of each mountain layer
    for i=1,mntDepth do
        mntFloor[i] = mntFloor[i] +mntSpeed[i]*-playeryspd/8
    end
    --clear points to be used to store the mountain layers
    points={}
    cols={}
    -- cycle through all the points in the mountain table and create a triangle in the mesh for each one, the colour with respect to the time of day using the earlier calculated hadj variable
    for i,m in pairs(mountain) do
        popMatrix()
        local top = vec2(0, 2)
        top = top * m.triSize
        top = top + vec2(m.x,m.y)
        
        local left = vec2(-1,0)
        left = left * m.triSize*m.triWidth
        left = left + vec2(m.x,m.y)
        
        local right = vec2(1,0)
        right = right * m.triSize*m.triWidth
        right = right + vec2(m.x,m.y)
        
        table.insert(points,top)
        table.insert(points,left)
        table.insert(points,right)
        local mc=color(m.c.r-hadj/2,m.c.g-hadj/2,m.c.b-hadj/2)
        table.insert(cols,mc)
        table.insert(cols,mc)
        table.insert(cols,mc)
        pushMatrix()
        --shift the mountains left according to the speed of the player.  Different m.spd values for each point gives the parallax scrolling effect
        m.x = m.x - (m.spd*playerxspd)
        --if the mountain has moved far enough off the left of the screen shift it to the far right to create a continuous scrolling effect
        if m.x<-200 then m.x = m.x + 2000 end
        m.y = m.y +m.spd*(-playeryspd)/8
    end
    triMesh.colors=cols
    triMesh.vertices=points
    -- Draw the mesh for the mountains
    triMesh:draw()
    --draw and move the cloud objects stored in the clouds table
    tint(255,255,255,50)
    for i,c in pairs(clouds) do
        sprite("Platformer Art:Cloud "..c.n,c.x,c.y,132*c.scale,64*c.scale)
        c.x = c.x - (c.spd*playerxspd)
        if c.x<-200 then c.x = c.x + 1800 end
    end
    noTint()
    --draw and move the objects (bats) in the objects table
    for i,c in pairs(objects) do
        sprite("Platformer Art:Battor Flap "..math.floor((math.sin(ElapsedTime*10))/2)+2,c.x,c.y,72,36)
        c.x = c.x - (c.spd*playerxspd)
        if c.x<-200 then
            c.x = c.x + 1800 +math.random(500)
            c.y=100+math.random(500)
            c.spd=math.random(3)
        end
    end
    -- draw and move the ground
    tint(255-hadj,255-hadj,255-hadj)
    for i,g in pairs(ground) do
        if g.type==1 then
            sprite("Platformer Art:Block Grass",g.x,g.y)
        end
        g.x = g.x - 2*playerxspd
        --if the ground is far enough off the left of the screen remove it from the table and create a new one at the end of the table
        if g.x<-140 then
            table.remove(ground,i)
            table.insert(ground,{x=ground[#ground].x+70,y=ground[#ground].y,type=math.min(math.random(progress),2)-1})
        end
    end
    --draw the player - use a different image if he is jumping
    if playery<=100 then
        sprite("Platformer Art:Guy Look Right",playerx,playery,42*shrink,60*shrink)
    else
        sprite("Platformer Art:Guy Jump",playerx,playery,42*shrink,60*shrink)
    end
    noTint()
    -- Draw the "Ready" screen
    if gamestate==READY then
        deadtimer = deadtimer + 1
        playerxspd=0
        font("ArialRoundedMTBold")
        fill(37, 31, 130-hadj, 255)
        strokeWidth(3)
        fontSize(40)
        text("Ready?",WIDTH/2,HEIGHT/2)
        if deadtimer==20 then
            sound("Game Sounds One:1-2 Go")
        end
        -- after the timer runs out then start the game
        if deadtimer>120 then
            gamestate=PLAY
            playerxspd=1
            deadtimer=0
        end
        -- draw the game over screen
    elseif gamestate==GAMEOVER then
        shrink = shrink * 0.9
        if deadtimer==1 then
            sound("Game Sounds One:Pac Death 2")
        end
        deadtimer = deadtimer + 1
        fill(37, 31, 130-hadj, 255)
        strokeWidth(3)
        fontSize(40)
        text("Game Over",WIDTH/2,HEIGHT/2)
        text("Score: "..math.floor(score),WIDTH/2,2*HEIGHT/3)
        text("Double Tap to restart",WIDTH/2,HEIGHT/3)
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
        --main gameplay
    elseif gamestate==PLAY then
        --  check for a touch event
        if CurrentTouch.state==BEGAN and jumpcount<20 and playerstate==1 then
            playeryspd=10
            --increase the jump variable
            jumpcount = jumpcount + 1
            sound(SOUND_JUMP, 11233)
        end
        --reset jump bar if ground is touched
        if CurrentTouch.state==ENDED and playery==100 then
            jumpcount=0
        end
        --make the player accelerate towards ground if in the air
        playery = playery + playeryspd
        playeryspd = playeryspd - 0.5
        --check to see if player has fallen down hole
        if playery<=100 then
            for i=2,4 do
                if playerx>ground[i].x-30 and playerx<ground[i].x+35 then
                    groundtype=ground[i].type
                end
            end
            --ground under player is empty (0) so stop the x speed of player and let fall
            if groundtype==0 then
                playerxspd=0
                --flag player as unable to jump
                playerstate=0
            else
                playery=100
                playeryspd=0
                --accelerate player on ground
                playerxspd = playerxspd + 0.02
                if playerxspd>7 then playerxspd=7 end
            end
            
        else
            --slow player if in the air
            playerxspd = playerxspd - 0.009
            if playerxspd<1 then playerxspd=1 end
        end
        -- if the player has fallen all the way to the bottom of the hole change state to game over
        if playery<=-100 then
            playery=-100
            playeryspd=0
            gamestate=GAMEOVER
        end
        --check for collision between enemy and player
        for i,b in pairs(objects) do
            if math.abs(b.x-playerx)<30 and math.abs(b.y-playery)<30 then
                gamestate=GAMEOVER
                playeryspd=0
                playerxspd=0
            end
        end
        --increment scor based on speed
        score = score + playerxspd
    end
    --display jump bar
    strokeWidth(1)
    fill(0)
    rect(WIDTH/2-162,HEIGHT-50,324,24)
    fill(137+hadj, 31+hadj, 130+2*hadj, 255)
    rect(WIDTH/2-160,HEIGHT-48,320-jumpcount*16,20)
    fill(37+hadj, 31+hadj, 130+2*hadj, 255)
    strokeWidth(1)
    fontSize(25)
    --display scores
    text("Score: "..math.floor(score),100,HEIGHT-37)
    text("High Score: "..math.floor(hiscore),WIDTH-160,HEIGHT-37)
    text("Jump ",WIDTH/2-200,HEIGHT-37)
    
    --add in sunlight glint coinciding with backmost mountain threshold crossing
    if suny>360 and suny<365 then
        local sunadj=suny-360
        sunbeam.vertices=({
            vec2(sunx,suny),vec2(sunx+400-(sunadj*10),0),vec2(sunx+470+sunadj*10,0),
            vec2(sunx,suny),vec2(sunx-1800-(sunadj*10),100),vec2(sunx-130+sunadj*10,0),
            vec2(sunx,suny),vec2(sunx+200-(sunadj*10),HEIGHT),vec2(sunx+270+sunadj*10,HEIGHT),
            vec2(sunx,suny),vec2(sunx-80-(sunadj*10),HEIGHT),vec2(sunx-130+sunadj*10,HEIGHT)
        })
        sunbeam:setColors(255,255,255,50-10*sunadj)
        sunbeam:draw()
    end
    --increase difficulty - this variable is used to set the chance of generating an empty pit instead of a ground element
    progress=math.max(3,8-math.floor(score/3000))
end

--set up variables
function initialise()
    triMesh=mesh()
    mountain={}
    mtx=-200
    mty=0
    scaler=4
    mntDepth=4
    mntFloor={}
    mntSpeed={}
    mntCol={}
    ground={}
    playerx=100
    playery=100
    playeryspd=0
    playerxspd=1
    jumpcount=0
    groundtype=1
    playerstate=1
    score=0
    progress=8
    shrink=1
    for i=1,20 do
        table.insert(ground,{x=-70+i*70,y=35,type=math.random(1)})
    end
    --set up mountain layers
    for lev=1,mntDepth do
        local rbase=150
        local gbase=160
        local bbase=140
        table.insert(mntFloor,mty)
        table.insert(mntCol,mty)
        table.insert(mntSpeed,(scaler-4)*3)
        if lev==1 then
            --hard code the backmost layer
            table.insert(mountain,{triSize=300,triWidth=2,x=WIDTH/2,y=mty,spd=(scaler-4)*3,c=color(rbase,gbase,bbase+mty/5)})
            table.insert(mountain,{triSize=200,triWidth=3,x=3*WIDTH/4,y=mty,spd=(scaler-4)*3,c=color(rbase,gbase,bbase+mty/5)})
            table.insert(mountain,{triSize=200,triWidth=3,x=WIDTH/4,y=mty,spd=(scaler-4)*3,c=color(rbase,gbase,bbase+mty/5)})
            table.insert(mountain,{triSize=180,triWidth=2.5,x=9*WIDTH/10,y=mty,spd=(scaler-4)*3,c=color(rbase,gbase,bbase+mty/5)})
            table.insert(mountain,{triSize=180,triWidth=2.5,x=WIDTH/10,y=mty,spd=(scaler-4)*3,c=color(rbase,gbase,bbase+mty/5)})
            table.insert(mountain,{triSize=160,triWidth=2.5,x=WIDTH,y=mty,spd=(scaler-4)*3,c=color(rbase,gbase,bbase+mty/5)})
            table.insert(mountain,{triSize=160,triWidth=2.5,x=0,y=mty,spd=(scaler-4)*3,c=color(rbase,gbase,bbase+mty/5)})
        else
            for i=1,40 do
                table.insert(mountain,{triSize=(30+math.random(35))*scaler,triWidth=1.5+math.random(100)/100,x=mtx,y=mty,spd=(scaler-4)*3,c=color(150,160,140+mty/5)})
                mtx = mtx + 50*scaler
            end
        end
        --move to the next layer - shift down and decrease the mountain size
        mty = mty - 20*scaler
        mtx=-50*scaler
        scaler = scaler + 0.1
    end
    
    clouds={}
    for i=1,5 do
        table.insert(clouds,{x=math.random(1000),y=400+math.random(200),n=math.random(3),spd=math.random(4)/10,scale=1+math.random(100)/100})
    end
    objects={}
    for i=1,3 do
        table.insert(objects,{x=1000+math.random(3000),y=100+math.random(500),type=math.random(2),spd=math.random(3)})
    end
    deadtimer=0
end