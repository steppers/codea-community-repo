-- Foggy Bummer
-- By West

--Game overview: A sideways scroller where the player controls a bumblebee.  Touch screen to provide upward thrust to the bee.  Collect as many rings as you can in 24 hours or until you complete the full course.  Don't hit the top or bottom of the screen and watch out for spiders!

--Feel free to use this code as you wish to help you learn and understand codea.  Most of the images are either hand drawn or sections extracted from photos - feel free to use, mangle and adapt the sprite sheet too.  Just please don't take the code and images wholesale and upload them to the apple store (this is something I may well do myself to learn about the process rather than to make money - I don't think the game as it stands is worthy of release.)

--As a learning experiment, if you want to use the code as a basis and improve here are some challenges

--Basic Challenges

--Make the spiders move up and down the screen
--Swap the moon image for an image of a planet sized space station (That's no moon...)
--Add a bonus which reverses the direction of gravity for a short period of time
--Add an explosion of flower particles when bonuses are picked up
--Change the control of the bee to use a tilt input from the ipad instead of touches

--More advanced challenges

--Make the bee fire a globule of pollen if the screen is double tapped - this can be used to kill spiders
--Add a hi-score table
--Re-cast the game as an underwater adventure with the main character as a submarine picking up jellyfish and avoiding sharks.  Different weather effects would be required, for example bubbles rising to the surface instead of raindrops
--Add "the flight of the bumblebee" as a soundtrack - the faster you go, the faster the soundtrack plays
--Add vertical scrolling and hills rather than a flat terrain.

--Have fun!  Any questions, then drop me (@West) on the Codea forums

--Set up screen and fix orientation to landscape
--for development change to FULLSCREEN to make it easier to get back to the development environment.  A triple tap while in FULLSCREEN_NO_BUTTONS will bring up the buttons to allow you to exit, but this can be a pain.
displayMode(FULLSCREEN_NO_BUTTONS)
supportedOrientations(LANDSCAPE_ANY)
backingMode(STANDARD)

function setup()
--Set up constants to hold the various game states
    MENU=1 --the main start screen
    PLAY=2 --the game is being played
    GAMEOVER=3 --the game has been lost    
    WON=4 -- the game has been won
    gamestate=MENU --set the current state of the game to menu
--set up constants for possible weather conditions    
    SUNNY=1
    RAINY=2
    MISTY=3
    weather=SUNNY --set the initial state of the weather to be sunny
--an array to hold the touches    
    touches={}
--A variable to hold different game over messages
    msg=""
--set initial sizes for the bee
    beebodysizex=100
    beebodysizey=100
    beewingsizex=130
    beewingsizey=130

        
    --Sprite sheet information
    --The spritesheet image contains all the graphical elements of the game
    --The spritesheet is split into 100 by 100 pixel blocks (in the main)   
    --download the spritesheet from here:https://www.dropbox.com/s/ztwc51abhl3ks1k/foggyspritesheet%402x.png
    --update the next line to point to the spritesheet file
    spritesheetimg=readImage(asset.foggyspritesheet)
    cols=10  --number of columns thatmakeupthe spritesheet
    rows=6  -- number of rows that make up the spritesheet
    
    --Set up the information about the bonuses
    
    bonus={}
    --array of bonuses
    bx={0,5,3,2,1,4,0}  --x position of the spritesheet block - 0 is the first column of 100 by 100 blocks, 1 is the second column...
    by={5,5,5,5,5,5,2}  --y position of the spritesheet block - 0 is the bottom row of 100 by 100 blocks, 1 is the next row up...
    bonusx={} --array holding x positions of the bonuses
    bonusy={} --array holding y positions of the bonuses
    bonustype={} --array holding the type of bonus -number refers to the position in the bx and by array as well to assign the appropriate image
    bonusmarker={}
    
    --Weather

    --variables for the clouds
    cloudx={} --array holding x position of the clouds
    cloudy={} --array holding y position of the clound
    cloudxsize={}  --array holding the x size of the clouds
    cloudysize={} --array holding y size of the clouds
    cloudtrans={} --array holding the transparency of the clouds
    cloudspd={} --array holding the speed of the clouds
    numclouds=20 --number of clouds to generate
--Populate arrays with initial parameters
    for j=1,numclouds do
        cloudx[j]=math.random(3*WIDTH)-WIDTH --a random x position anywhere on the screen - adjustments to alalow the cloud to start halfway off the screen
        cloudy[j]=math.random(300)+450  --a random y position above a ceratin limit
        cloudxsize[j]=math.random(330)+300 --a random size above a certain size
        cloudysize[j]=360/530*cloudxsize[j] --keep clound in proportion
        cloudtrans[j]=math.random(120)      --a random transparency
        cloudspd[j]=math.random(4) --a random speed
    end
--variables for the mist    
    mistcounter=0 --a counter for fading in and out the mist
    mistlevel=0
    mistmax=150
    lightlevelr=100
    lightlevelg=100
    lightlevelb=100
--variables for the lightning flashes
    lightning=math.random(5000)
    flashcount=0
--variables for the stars
    starx={} --array for x position of the stars
    stary={} --array for y position of the stars
    starsize={} --array for size of the stars
    starbright={} --array for the brightness of the stars
    --initialise starfield
    for i=1,100 do
        starsize[i]=math.random(5)
        starx[i]=math.random(WIDTH)
        stary[i]=math.random(HEIGHT)
        starbright[i]=math.random(255)
    end
    --Background
    
    --background is made up of a number of repeating objects which scroll across the screen at different speeds
    numlayers=8
    bgxsize={WIDTH,800,20,200,30,40,65,98}
    bgysize={HEIGHT,450,120,60,90,114,195,289} 
    bgxpos={WIDTH/2,0,0,0,0,0,0,0}
    bgypos={120,80,100,50,20,15,10,100}
    --x,y,width and height arrays of each background object with reference to the appropriate spritesheet 100 by 100 block 
    --layers are: mountain, mountain, fence, wall, flowers x4
    bgx={6,6,4,0,5,5,5,5}
    bgy={0,0,0,3,0,0,0,0}    
    bgw={4,4,0.5,3,1,1,1,1}
    bgh={3,3,2,1,3,3,3,3}    
    scrollspeed={0,0.2,0.3,0.4,0.6,0.7,0.8,0.9} -- the speed at which the object moves across the screen - 0 means it doesn't move
    overlap={1.5,1.9,1,1,1,1,1,1}--the amount an object overlaps the next object
    
    layerdata={}
    for i=1,numlayers do
        layerdata[i]={} --an array for holding a list of the objects. If a 0 is stored the then object will be drawn.  If it is a 0 then it won't
        for j=1,1000 do
            
        --for the nearest layer (large flower) don't draw 14 out of 15 (on average)    
            if i==8 then
                layerdata[i][j]=math.random(15)-1
                if layerdata[i][j]>1 then
                    layerdata[i][j]=1
                end
        --for the second nearest layer don't draw half of them (on average)
            elseif i==7 then
                layerdata[i][j]=math.random(2)-1
            else
                layerdata[i][j]=0 
            end
        end           
    end
    --a table to hold the currently active particles
    particles={}
    --a mesh to hold all the graphical elements.  The order in which the objects are added to the mesh matters, so in draw the scene will be built up from the back forward.  The sky elements will be drawn first, followed by the mountains then clouds, then fence and wall, etc
    mainmesh=mesh()
    mainmesh.texture=spritesheetimg
end

function initialise()
    --initialise variables - called when the game is reset
    weather=SUNNY
    sunx=100
    suny=100
    moonx=100
    moony=100
    sunAngle=math.rad(180)
    globalx=150
    anim=0
    speed=8
    minspeed=8
    upthrust=0
    beex=150
    grav=-12
    beevel=0
    t=0.1
    beey=HEIGHT/2
    topSpeed=30    
    score=0
    numrings=250
    ringx={}
    ringy={}
    ringmarker={}
    ringscale={}
    ringcount=0
    ringy[1]=HEIGHT/2
    b=0
    beescalefactor=0.5   
    --generate 500 rings at random.  Each subsequent ring should be displaced vertically by a random distance between -50 and +50
    for i=1,numrings do
        ringx[i]=500*i --each ring is placed 500 pixels apart
        ringmarker[i]=0
        ringscale[i]=2+math.random(6)/2
        if i>1 then
            ringy[i]=ringy[i-1]-100+math.random(200) 
            if ringy[i]>HEIGHT-100 then
                ringy[i]=HEIGHT-100
            end
            if ringy[i]<100 then
                ringy[i]=100
            end
        end
        
        --add a random bonus every 10 rings
        if math.fmod(i,10)==0 then
            bonusx[b]=500*i+250 -- place bonus between two rings
            bonusy[b]=ringy[i]
            bonustype[b]=math.random(7)
            bonusmarker[b]=0
            b = b + 1
        end
    end
end


-- This function gets called once every frame
function draw()
    if gamestate==MENU then
        --main menu screen - not very exciting but does the job.   Double tap to play the game
        background(33, 46, 69, 255)
        font("ArialRoundedMTBold")
        fontSize(72)
        text("Foggy Bummer",WIDTH/2,HEIGHT/2)
        fontSize(36)
        text("by West",WIDTH/2,HEIGHT/2-120)               
        text("Double tap screen to start",WIDTH/2,HEIGHT/2-240)
        fontSize(12)
--check for a double tap
    for k,touch in pairs(touches) do                
        if touch.tapCount==2 then
            initialise()
            gamestate=PLAY
        end
    end
    elseif gamestate==GAMEOVER then    
        --Display a message to the user stating the game is over along with the score
        background(63, 32, 32, 255)    
        fill(230, 165, 61, 255)
        font("ArialRoundedMTBold")
        fontSize(72)
        text("Game Over",WIDTH/2,HEIGHT/2+120)
        fontSize(36)
        text(msg,WIDTH/2,HEIGHT/2)
        text("Your score was: "..score,WIDTH/2,HEIGHT/2-120)
        fontSize(12)
        --check for as double tap to restart
        for k,touch in pairs(touches) do                
            if touch.tapCount==2 then
                initialise()
                gamestate=PLAY
            end
        end
    elseif gamestate==WON then    
    --Display a message to the user stating they have won
        background(87, 246, 23, 255)    
        fill(57, 58, 220, 255)
        font("ArialRoundedMTBold")
        fontSize(72)
        text("Congratulations you won!",WIDTH/2,HEIGHT/2)
        fontSize(36)
        text("Your score was: "..score,WIDTH/2,HEIGHT/2-120)
        fontSize(12)
        --check for a double tap to play again
        for k,touch in pairs(touches) do                
            if touch.tapCount==2 then
                initialise()
                gamestate=PLAY
            end
        end
    elseif gamestate==PLAY then
        --Clear the mesh
        mainmesh:clear()        
        --Set the appropriate background colour based on the sun position
        if math.deg(sunAngle)<180 then
            background(60, 120, 240, 255)
            startemp=30
        elseif math.deg(sunAngle)<210 then
            --sunset
            temp=math.deg(sunAngle)-180
            background(2*(-1*temp+30),4*(-1*temp+30),8*(-1*temp+30),255)
            startemp=30-temp
        elseif math.deg(sunAngle)>330 then
            --sunrise part1
            temp=math.deg(sunAngle)-330
            background(2*temp, 4*temp, 8*temp, 255)   
            startemp=temp
        elseif math.deg(sunAngle)<30 then
            --sunrise part2
            temp=math.deg(sunAngle)+60
            background(2*temp, 4*temp, 8*temp, 255)   
            startemp=temp
        else
            background(0,0,0,255)
            startemp=0
        end
    
        --Add the stars to the mesh
        for i=1,100 do
            local idx = mainmesh:addRect(starx[i],stary[i],starsize[i],starsize[i]) 
            mainmesh:setRectTex(idx, 0/cols, 4/rows, 1/cols, 1/rows)
            mainmesh:setRectColor(idx,starbright[i],starbright[i],starbright[i],8*(30-startemp))    
        end
        --Calculate the sun/moon position
        sunx = WIDTH/2 + math.cos(sunAngle) * 400
        suny = HEIGHT/2 -100 + math.sin(sunAngle) * 400
        moonx = WIDTH/2 + math.cos(sunAngle+math.rad(180)) * 400
        moony = HEIGHT/2 -100 + math.sin(sunAngle +math.rad(180)) * 400
        sunAngle = sunAngle - 0.001
        time=360-math.deg(sunAngle)+270
        if time>360 then
            time = time- 360
        end
        --Calculate an equivalent time
        hours=math.floor(24*time/360)
        mins=math.floor(60*((24*time/360)-hours))
        if mins<10 then
            timestr=hours..":0"..mins
        else
            timestr=hours..":"..mins
        end
        if sunAngle<0 then
            sunAngle=math.rad(360)
        end
        --Add the sun and the moon to the mesh
        local sunid=mainmesh:addRect(sunx,suny,88,88)
        mainmesh:setRectTex(sunid,1/cols,0/rows,1/cols,1/rows)
        local moonid=mainmesh:addRect(moonx,moony,70,70)
        mainmesh:setRectTex(moonid,0/cols,0/rows,1/cols,1/rows)
        --Deal with the user interaction
        --If the screen is currently being touched
            if CurrentTouch.state==MOVING or CurrentTouch.state==BEGAN then    
                upthrust = upthrust + 10 --cumulatively add some upward force - alter the 10 to get different levels of force
                --limit the force
                if upthrust>30 then
                    upthrust=30
                end
            end
            --decrease the upward force when the finger is removed, but not immediately
            if CurrentTouch.state==ENDED then
                upthrust=upthrust-5
                if upthrust<0 then
                    upthrust=0
                end
            accx=0
        end
        acc=upthrust+grav -- change the vertical displacemnt according to the amount of force
    --equation of motion to calculate the displacement in the y direction s=ut+0.5at*t
        beey=beey+beevel*t+0.5*acc*t*t
    --equation of motion for the new velocity v=u+at
        beevel=beevel+acc*t
        speed=speed-0.01
        if speed>topSpeed then
            speed=topSpeed
        end
        if speed<minspeed then
            speed=minspeed
        end
          globalx = globalx + speed 
    --Check to see if the bee hits the top of the screen - if so then game over
        if beey>HEIGHT-20 then
            beey=HEIGHT-20
            upthrust=0
            gamestate=GAMEOVER
            msg="Like Icarus, you flew too high"
        end
        --check to see if the been hits the ground - if so then game over
        if beey<20 then
            beey=20
            speed=speed-0.5
            gamestate=GAMEOVER
            msg="Bees cannot run"
        end
        --add the clouds to the mesh
        for i=1,numclouds do
            local idx = mainmesh:addRect(WIDTH/2+cloudx[i],cloudy[i],cloudxsize[i],cloudysize[i]) 
            mainmesh:setRectTex(idx, 6/cols, 3/rows, 4/cols, 3/rows)
            mainmesh:setRectColor(idx,255,255,255,cloudtrans[i]) 
            --move the clouds according to their speed
            cloudx[i] = cloudx[i] - cloudspd[i]
            --wrap around the clouds to make them repeat infinitely
            if cloudx[i]<-WIDTH then
                cloudx[i] = cloudx[i] + 2*WIDTH
            end
        end
        
        --create the meshes for the scrolling background layer by layer
        for i=1,numlayers do   
            for j=1,overlap[i]*(WIDTH/bgxsize[i])+3 do    
                if layerdata[i][j]==0 then                         
                    local gid = mainmesh:addRect(((bgxpos[i])+bgxsize[i]*j-bgxsize[i])/overlap[i],bgypos[i],bgxsize[i],bgysize[i]) 
                    mainmesh:setRectTex(gid, bgx[i]/cols, bgy[i]/rows, bgw[i]/cols, bgh[i]/rows)                        
                    if math.deg(sunAngle)>180 and math.deg(sunAngle)<360 and i<5 then
                        mainmesh:setRectColor(gid,100,100,100,255)                            
                    end         
                end
            end   
            --add in mist if appropriate
            if (i==6 or i==2) and weather==MISTY then
                --add a big rectangle for the mesh
                local mid=mainmesh:addRect(WIDTH/2,HEIGHT/2,WIDTH,HEIGHT)
                mainmesh:setRectTex(mid, 2/cols, 1/rows, 1/cols, 1/rows)                        
                mainmesh:setRectColor(mid,lightlevelr,lightlevelg,lightlevelb,mistlevel+50)                  
            end
        end
        --calculate and shift the layers depending on speed
        for i=1,numlayers do
            bgxpos[i]=bgxpos[i]-(scrollspeed[i]*speed)
            if bgxpos[i]>bgxsize[i] then
                bgxpos[i]=0        
                temp=layerdata[i][#layerdata[i]]
                for c=1,#layerdata[i] do
                    layerdata[i][#layerdata[i]-c+1]=layerdata[i][#layerdata[i]-c]          
                end
                layerdata[i][1]=temp
            end    
            if bgxpos[i]<-1*bgxsize[i] then
                bgxpos[i]=0        
                temp=layerdata[i][1]
                for c=1,#layerdata[i]-1 do
                    layerdata[i][c]=layerdata[i][c+1]          
                end
                layerdata[i][#layerdata[i]]=temp 
            end    
        end
          
--deal with the particles - stars and raindrops controlled by the other tab
    for i,s in pairs(particles) do
        s:draw()
        --check to see if the current particle has been flagged to be deleted and if so, remove from the table
        if s.delete==1 then
            table.remove(particles,i)
        end
    end

    --draw the rings.  The rings are split into 2 to give the impression that the bee is flying through the rings rather than in front or behind them
        for i=1,numrings do
            if ringx[i]>globalx-(WIDTH) and ringx[i]<globalx+(WIDTH) then
                local idx = mainmesh:addRect(WIDTH/2+ringx[i]-globalx,ringy[i],(107/10)*ringscale[i],(224/5)*ringscale[i]) 
                mainmesh:setRectTex(idx, 3/cols, 0/rows, 0.5/cols, 2/rows)
                mainmesh:setRectColor(idx,255,255,255,90)                 
                --check to see if the bee has hit a ring
                if globalx>ringx[i]-20+WIDTH/2-150 and globalx<ringx[i]+20+WIDTH/2-150 and beey>ringy[i]-25*ringscale[i] and beey<ringy[i]+25*ringscale[i] and ringmarker[i]==0 then
                    --increase the score
                    score = score + (6-ringscale[i])*10
                    --increase the speed
                    speed = speed*2
                    ringmarker[i]=1
                    ringcount = ringcount + 1
                    --add in a ring of random stars projecting out in a circle
                    for s=1,360,36 do
                        local mag=math.random(8)+5
                        local sx=mag*math.sin(math.rad(s))
                        local sy=mag*math.cos(math.rad(s))
                        table.insert(particles,Particle(beex,beey,sx,sy,1,255))
                    end
                    sound(SOUND_PICKUP, 49740)                
                end
            end
        end
        --always be slowing the bee
        speed = speed*0.99
        --draw the bonuses
        for i=1,#bonusx do
            if bonusx[i]>globalx-(WIDTH) and bonusx[i]<globalx+(WIDTH) and bonusmarker[i]==0 then
                local idx = mainmesh:addRect(WIDTH/2+bonusx[i]-globalx,bonusy[i],100,100) 
                mainmesh:setRectTex(idx, bx[bonustype[i]]/cols, by[bonustype[i]]/rows, 1/cols, 1/rows)
                --check to see if the bonus has been collected
                if globalx>bonusx[i]-40+WIDTH/2-150 and globalx<bonusx[i]+40+WIDTH/2-150 and beey>bonusy[i]-40 and beey<bonusy[i]+40 and bonusmarker[i]==0 then
                    bonusmarker[i]=1
                    if bonustype[i]==1 then
                        --speed up bonus
                        speed = speed + 30
                        sound(SOUND_POWERUP, 9735)
                    elseif bonustype[i]==2 then
                        --rainy weather
                        weather=RAINY
                        sound(SOUND_RANDOM, 20160)
                    elseif bonustype[i]==3 then
                        --mist
                        mistcounter=2000
                        weather=MISTY
                        sound(SOUND_RANDOM, 17484)
                    elseif bonustype[i]==4 then
                        --increase bee size with also speeds up its fall rate
                        beescalefactor = beescalefactor + 0.1
                        grav=grav-3
                        sound(SOUND_POWERUP, 45739)                        
                    elseif bonustype[i]==5 then
                        --decrease bee size which slows down its fall rate
                        beescalefactor = beescalefactor -0.1
                        if beescalefactor<0 then
                            beescalefactor=0.1
                        end
                        grav=grav+3
                        sound(SOUND_RANDOM, 11423)
                    elseif bonustype[i]==6 then
                        -- sunny weather
                        weather=SUNNY
                        sound(SOUND_RANDOM, 19933)
                    elseif bonustype[i]==7 then
                        --dead
                        gamestate=GAMEOVER
                        msg="Gobbled by a spider"
                        sound(SOUND_RANDOM, 17386)
                    end
                end
            end
        end
        --add the bee body to the mesh
        local idx = mainmesh:addRect(beex,beey,beebodysizex*beescalefactor,beebodysizey*beescalefactor) 
        mainmesh:setRectTex(idx, 0/cols, 1/rows, 1/cols, 1/rows)
        --add the bee wing to the mesh.  When adding rotate by anim degrees (use math.rad to convert to the equivalent im radians)
        local idw = mainmesh:addRect(beex,beey+28*beescalefactor,beewingsizex*beescalefactor,beewingsizey*beescalefactor,math.rad(anim)) 
        mainmesh:setRectTex(idw, 1/cols, 1/rows, 1/cols, 1/rows)
        mainmesh:setRectColor(idw,255,255,255,180)
        --cycle the bee wing animation marker
        anim = anim + 6
        if anim>27 then
            anim=-6
        end
        --draw the second half of the rings which should appear in front of the bee
        for i=1,numrings do
            if ringx[i]>globalx-(WIDTH) and ringx[i]<globalx+(WIDTH) then
                local idx = mainmesh:addRect(WIDTH/2+ringx[i]-globalx+(105/10)*ringscale[i]+1,ringy[i],(107/10)*ringscale[i],(224/5)*ringscale[i]) 
                mainmesh:setRectTex(idx, 3.5/cols, 0/rows, 0.5/cols, 2/rows)
                mainmesh:setRectColor(idx,255,255,255,90) 
            end
        end
        --reset the level of the mist
        if mistcounter==0 then
            lightlevelr=100
            lightlevelg=100
            lightlevelb=100
            mistlevel=0
        end
        if weather==MISTY then
            mistlevel = mistlevel + 1
            --stop everything disappearing completely in the mist
            if mistlevel>mistmax then
                mistlevel=mistmax
            end
        else 
            mistlevel = mistlevel -1
            if mistlevel<0 then
                mistlevel=0
            end
        end
        if weather==RAINY then        
            --add a raindrop at a random location
            table.insert(particles,Particle(math.random(WIDTH),HEIGHT,0,-2,2,255))
            -- add a lightning flash at random intervals
            if flashcount==lightning then
                background(255,255,255)
            end
            flashcount = flashcount + 1
            if flashcount>50000 then
                flashcount=0
                lightning=math.random(50000)
            end
        end    
        --if the full distance is covered then the player wins
        if globalx>ringx[numrings]+500 then
            gamestate=WON
        end
        --if time runs out then the player loses
        if hours==5 and mins==59 then
            gamestate=GAMEOVER
            msg="You ran out of time"
        end
        --draw the mesh on the screen
        mainmesh:draw()  
        font("ArialRoundedMTBold")
        fontSize(36)
        fill(213, 198, 89, 255)
        --add the score and time to the screen
        text("Score: "..score,100,730)
        text(timestr,900,730)    
    end
end

function touched(touch)
    --handle the touches    
    if touch.state == ENDED then
        touches[touch.id] = nil        
    else
        touches[touch.id] = touch
    end   
end  
