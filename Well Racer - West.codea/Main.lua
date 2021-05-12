-- Well Racer
-- Codea Cook Off 2013
-- by West
-- v1.0 First release
supportedOrientations(PORTRAIT_ANY)
function draw()
    func()
end


function setup()
    displayMode(FULLSCREEN)
    saveProjectInfo("Description", "Well Racer: An entry for the 2013 Codea Cook Off Challenge")
    saveProjectInfo("Author", "Graeme West")
    --Play the sounds sliently at the start to avoid jitter when they are played for the first time
    sound(SOUND_EXPLODE, 14832,0)
    sound(SOUND_RANDOM, 42399,0)                
    sound(SOUND_POWERUP, 13232,0)
    sound(SOUND_RANDOM, 13247,0)
    sound(SOUND_RANDOM, 17243,0)
    sound(SOUND_RANDOM, 93235,0)
    sound(SOUND_RANDOM, 16235,0)
    sound(SOUND_RANDOM, 1350,0)
    sound(SOUND_EXPLODE, 14832,0)
    sound(SOUND_RANDOM, 599,0,0)
    sound(SOUND_RANDOM, 28443,0)
    sound(SOUND_POWERUP, 12891,0)
    sound(SOUND_HIT, 12909,0)
    sound(SOUND_JUMP, 631,0)
    
    sc=1
    scene={menu,playing,gameover,guide,nextlevel}
    ALIVE=1
    DEAD=2  
    touches={}
    platforms={}
    rocks={}
    walls={}
    bonus={}
    tsup={}
    droplets={}
    starburst={}
    scoretext={}
    menudelay=0
    newgame()
    charshade=color(255)
    --read in the high score
    --reset the hiscore
    --hiscore=nil
    hiscore=readLocalData("hiscore")
    if hiscore==nil then
        hiscore=0
    end
end

function newgame()
    score=0
    currentlevel=1
    playergaming=0
    lastflag=0
end

function initialise(lev)
    clearPhysics()
    --level specific variables    
    rockcount=8+2*lev
    depth=300+100*lev
    bonuscount=8+2*lev
    skullcount=lev
    multiplier=1
    weakplatforms=0
    mancollision=0
    
    startamnesty=0
    menudelay=0
    ang=0
    man=physics.body(CIRCLE,30)
    man.x=WIDTH/2
    man.y=HEIGHT-300
    man.angle=180
    man.restitution=0.3
    man.gravityScale=0.5
    man.info="man"
    rocks={}
    for i=1,rockcount do
        r=physics.body(CIRCLE,30)
        r.x=150+math.random(WIDTH-300)
        r.y=HEIGHT-200
        r.restitution=0.3
        r.gravityScale=(2+math.random(5))/20
        r.info="rock"
        table.insert(rocks,r)
    end
    bgbricks={}
    bgbrickcount=depth
    bottomlevel=(depth)*-50
    splashspeed=0
    splashcount=0
    soundcount=0
    fallsoundplay=200
    --walls
    local offset=0
    walls={}
    for i=1,depth do
        offset=i*-50
        
        local w1=physics.body(EDGE,vec2(WIDTH-68,25+offset),vec2(WIDTH-68,75+offset))
        local w2=physics.body(EDGE,vec2(50,25+offset),vec2(50,75+offset))
        w1.info="wall"
        w2.info="wall"
        table.insert(walls,w1)
        table.insert(walls,w2)
    end
    bottom=physics.body(EDGE,vec2(0,25+offset),vec2(WIDTH,25+offset))
    bottom.info="bottom"
    bonus={}
    for i=1,bonuscount do
        local btype=1
        if i<=skullcount then
            btype=2
        elseif i==bonuscount then
            btype=2+math.random(5) --or 2+random
        end
        bonus[i]={x=100+math.random(WIDTH-200),y=-math.random(50*(depth-11))-500,type=btype}
    end
    --check the extra bonus flag - if the player has been "gaming" then turn the extra bonus to a skull
    btype=2+math.random(5) 
    if playergaming==1 then
        btype=2
        playergaming=0
    end
    bonus[bonuscount+1]={x=WIDTH/2,y=-50*30,type=btype}
    
    
    --13 possible x locations
    for i=1,bgbrickcount do
        bgbricks[i]={x=25+math.random(13)*50,y=-50*math.random((depth-1))}
    end
    --location of cloud
    numclouds=math.random(20)
    cloudx={}
    cloudy={}
    for i=1,numclouds do
        cloudx[i]=math.random(WIDTH)
        cloudy[i]=math.random(800)
    end
    
end


function clearPhysics()
    if man~=nil then man:destroy() man=nil end
    if bottom~=nil then bottom:destroy() bottom=nil end
    for k,r in pairs(rocks) do
        r:destroy()
        r=nil
    end
    for k,p in pairs(platforms) do
        p.pbody:destroy()
        p.pbody=nil
        table.remove(platforms,k)
    end
    for k,w in pairs(walls) do
        w:destroy()
        w=nil
    end
    --apparently calling it three times
    collectgarbage()
    collectgarbage()
    collectgarbage()
end


function draw()
    scene[sc]()
end

function gameover()
    background(31, 95, 153, 255)
    fill(234, 192, 25, 255)
    fontSize(64)
    font("Copperplate-Bold")
    text("Game Over",WIDTH/2,HEIGHT/2)
    fontSize(32)
    if menudelay>50 then
        text("Tap to return to menu",WIDTH/2,150)
    end
    menudelay = menudelay + 1
    for k,touch in pairs(touches) do
        if menudelay>50 then
            sc=1
            newgame()
            initialise(currentlevel)
        end
    end
    
    tint(charshade)
    pushMatrix()
    translate(WIDTH/2,HEIGHT-400)
    rotate(ElapsedTime*50) 
    sprite("Platformer Art:Guy Jump",0,0)
    popMatrix()
    tint(255)
    text("Final score: "..score,WIDTH/2,HEIGHT/2-150)
    if score>=hiscore then
        text("New High Score!",WIDTH/2,HEIGHT/2-200)
        saveLocalData("hiscore",score)
        hiscore=score
    end
    
end

function guide()
    background(31, 95, 153, 255)
    fill(234, 192, 25, 255)
    fontSize(64)
    font("Copperplate-Bold")
    text("Instructions",WIDTH/2,HEIGHT-120)
    fontSize(32)
    textAlign(LEFT)
    textWrapWidth(WIDTH-200)
    local instruct="Ding Dong Bell, there's spacemen in the well!  Race Poppet, Butch or Ginger to the bottom of the well by "
    instruct = instruct.."drawing lines to create platforms to alter the spaceman's trajectory. "
    instruct = instruct.."Collect stars for points (the faster you fall the bigger the bonus) but watch out for skulls. Bump other competitors "
    instruct = instruct.."for added points. Big reward for reaching the bottom first but "
    instruct = instruct.. "don't be last!  Arrows along the bottom of the screen indicate upcoming bonus positions. X indicates a skull. "
    instruct = instruct.. "Successive wells get deeper and deeper.  Good Luck!"
    text(instruct,WIDTH/2,HEIGHT/2)
    
    textAlign(CENTER)
    fontSize(32)
    if menudelay>50 then
        text("Tap to return to menu",WIDTH/2,150)
    end
    menudelay = menudelay + 1
    for k,touch in pairs(touches) do
        if menudelay>50 then
            sc=1
            menudelay=0
        end
    end   
end

function nextlevel()
    background(31, 95, 153, 255)
    fill(234, 192, 25, 255)
    fontSize(64)
    font("Copperplate-Bold")
    text("Well Done!",WIDTH/2,HEIGHT/2+200)
    text("Level "..currentlevel.." complete",WIDTH/2,HEIGHT/2)
    fontSize(32)
    if menudelay>50 then
        text("Tap to enter next well",WIDTH/2,150)
    end
    menudelay = menudelay + 1
    for k,touch in pairs(touches) do
        if menudelay>50 then
            sc=2
            menudelay=0
            currentlevel=currentlevel+1
            initialise(currentlevel)
        end
    end   
end

function menu()
    local infobuttonx=WIDTH/2
    local infobuttony=100
    --Select one of three players - Poppet (pink), Butch (Green), Jinja (Orange)
    local px=WIDTH/4
    local jx=3*WIDTH/4
    local playery=270
    
    background(31, 95, 153, 255)
    fill(234, 192, 25, 255)
    fontSize(64)
    font("Copperplate-Bold")
    text("Well Racer",WIDTH/2,3*HEIGHT/4)
    text("by West",WIDTH/2,3*HEIGHT/4-100)
    fontSize(32)
    if menudelay>50 then
        text("Select a character",WIDTH/2,HEIGHT/2-100)
        strokeWidth(3)
        stroke(200,170,10,255)
        ellipse(infobuttonx,infobuttony,100)
        
        tint(244, 21, 189, 255)
        pushMatrix()
        translate(px,playery)
        rotate(ElapsedTime*50) 
        sprite("Platformer Art:Guy Jump",0,0)
        popMatrix()
        text("Poppet",px,200)
        
        tint(60, 179, 29, 255)
        pushMatrix()
        translate(infobuttonx,playery)
        rotate(ElapsedTime*50) 
        sprite("Platformer Art:Guy Jump",0,0)
        popMatrix()
        text("Butch",infobuttonx,200)
        
        tint(244, 111, 20, 255)
        pushMatrix()
        translate(jx,playery)
        rotate(ElapsedTime*50) 
        sprite("Platformer Art:Guy Jump",0,0)
        popMatrix()
        text("Ginger",jx,200)
        tint(255)
        fill(0)
        font("AmericanTypewriter-CondensedBold")
        fontSize(64)
        text("i",infobuttonx,infobuttony)
    end
    menudelay = menudelay + 1
    for k,touch in pairs(touches) do
        if menudelay>50 then
            if vec2(touch.x,touch.y):dist(vec2(infobuttonx,infobuttony))<50 then
                sc=4
                menudelay=0
            elseif vec2(touch.x,touch.y):dist(vec2(px,playery))<50 then
                sc=2
                charshade=color(244, 21, 189, 255)
                initialise(currentlevel)
            elseif vec2(touch.x,touch.y):dist(vec2(infobuttonx,playery))<50 then
                sc=2
                charshade=color(60, 179, 29, 255)
                initialise(currentlevel)
            elseif vec2(touch.x,touch.y):dist(vec2(jx,playery))<50 then
                sc=2
                charshade=color(244, 111, 20, 255)
                initialise(currentlevel)
            end
        end
    end
    fill(234, 192, 25, 255)
    fontSize(32)
    font("Copperplate-Bold")
    textMode(CORNER)
    text("Hiscore: "..hiscore,20,HEIGHT-40)
    textMode(CENTER)
end

function playing()
    tint(255)
    startamnesty=startamnesty+1
    -- Play a "heartbeat" sound based on vertical speed
    -- Going for a similar feel to the original asteroids
    soundcount=soundcount+math.floor(man.linearVelocity.y/-100)
    if soundcount>fallsoundplay then
        sound(SOUND_BLIT, 41745, 0.1)
        soundcount=0
    end
    --varaible to control the darkness of the well
    --We want to darken by 30 over the whole length of the well
    local dimming=40*man.y/bottomlevel
    background(80-dimming, 57-dimming, 40-dimming, 255)
    --sky: Draw a rectangle of blue to represent the sky
    noStroke()
    fill(42, 44, 158, 255)
    rect(0,HEIGHT-300-man.y+HEIGHT-1000,WIDTH,1000)
    --add some clouds
    for i=1,numclouds do
        if i%2==1 then
            sprite("Platformer Art:Cloud 1",cloudx[i],HEIGHT-300-man.y+HEIGHT-800+cloudy[i])
        elseif i%3==1 then
            sprite("Platformer Art:Cloud 2",cloudx[i],HEIGHT-300-man.y+HEIGHT-800+cloudy[i])
        else
            sprite("Platformer Art:Cloud 3",cloudx[i],HEIGHT-300-man.y+HEIGHT-800+cloudy[i])
        end
    end
    --Add a black rectangle to the bottom
    fill(0)
    rect(0,((5+depth)*-50)-man.y+HEIGHT-1000,WIDTH,1000)
    stroke(252, 8, 221, 255)
    strokeWidth(3)
    --draw background bricks
    for k,b in pairs(bgbricks) do
        if (b.y-man.y+HEIGHT-300>-60) and (b.y-man.y+HEIGHT-300<HEIGHT) then
            local fade=5+(math.abs(WIDTH/2-b.x))/3
            tint(255,255,255,fade)
            sprite("Platformer Art:Block Brick",b.x,b.y-man.y+HEIGHT-300,50,50)
        end
    end
    tint(255)
    --draw active platforms
    for k,p in pairs(platforms) do
        stroke(245, 244, 246, p.fade)
        line(p.x1,p.y1-man.y+HEIGHT-300,p.x2,p.y2-man.y+HEIGHT-300)
        p.fade = p.fade -2
        --remove platforms which have faded out
        if p.fade<0 then
            table.remove(platforms,k)
            p.pbody:destroy()
            p.pbody=nil
        end
    end
    --draw main character
    tint(charshade)
    pushMatrix()
    translate(man.x,HEIGHT-300)
    rotate(man.angle) 
    sprite("Platformer Art:Guy Jump",0,0,50,70)
    popMatrix()
    tint(255)
    strokeWidth(5)
    --draw rocks
    for k,r in pairs(rocks) do
        if r.gravityScale<0.25 then
            tint(206, 26, 21, 255)
        elseif r.gravityScale<0.3 then
            tint(120, 108, 124, 255)
        else
            tint(0, 128, 255, 255)
        end
        pushMatrix()
        translate(r.x,r.y-man.y+HEIGHT-300)
        rotate(r.angle) 
        sprite("Platformer Art:Guy Jump",0,0,50,70)
        --sprite("Space Art:Asteroid Large",0,0,60,60)
        popMatrix()
        tint(255)
        --check if rocks are at bottom and draw splash
        if r.y<bottomlevel+150 then
            r.restitution=0
            table.insert(droplets,
            {x=r.x,y=r.y,dir=340+math.random(40),
            fade=175+math.random(50),size=12+math.random(5),speed=5+math.random(5)})
        end    
        if r.y<bottomlevel+100 then
            --remove rock
            r:destroy()
            r=nil
            table.remove(rocks,k)
            sound(SOUND_EXPLODE, 14832)
        end
    end
    --handle touches by drawing circles for active ones
    for k,touch in pairs(touches) do
        local circlesize=70
        --Green start circle
        stroke(14, 230, 11, 255)
        strokeWidth(2)
        fill(34, 189, 31, 130)
        ellipse(tsup[touch.id].tstartx,tsup[touch.id].tstarty,circlesize)
        --red end circle
        stroke(238, 15, 15, 255)
        strokeWidth(2)
        fill(189, 32, 32, 130)
        ellipse(touch.x,touch.y,circlesize)
    end
    -- Draw the bonuses
    for k,b in pairs(bonus) do
        if b.type==1 then
            pushMatrix()
            translate(b.x,b.y-man.y+HEIGHT-300)
            rotate(-ElapsedTime*100) 
            sprite("SpaceCute:Star",0,0)   
            popMatrix()     
        elseif b.type==2 then
            pushMatrix()
            translate(b.x,b.y-man.y+HEIGHT-300)
            sprite("Small World:Bunny Skull",0,0,43+10*math.sin(ElapsedTime*5),
            43+10*math.sin(ElapsedTime*5))    
            popMatrix()
        else
            sprite("Platformer Art:Block Special",b.x,b.y-man.y+HEIGHT-300,43,43)        
        end
        if b.y-man.y+HEIGHT+3500>0 and b.y-man.y+HEIGHT+1000<HEIGHT then
            local indSize=30
            pushMatrix()
            if b.type==2 then
                tint(180,0,0)
                translate(b.x,50+25*math.sin(ElapsedTime*10))
                rotate(-45)
                sprite("Space Art:Star",0,0,indSize,indSize)
            elseif b.type==1 then
                tint(0,180,0)
                translate(b.x,50+25*math.sin(ElapsedTime*10))
                rotate(-90)
                sprite("Cargo Bot:How Arrow",0,0,indSize,indSize)
            else
                tint(255)
                translate(b.x,50+25*math.sin(ElapsedTime*10))
                rotate(0)
                sprite("Platformer Art:Coin",0,0,indSize,indSize)
            end
            popMatrix()
            tint(255)
        end
        --check for collision with bonus
        if vec2(b.x,b.y):dist(vec2(man.x,man.y))<50 then
            if b.type==2 then
                --instant death
                sound(SOUND_RANDOM, 42399)
                sc=3 
            else
                for s=0,360,12 do      
                    if math.random(3)>1 then                      
                        table.insert(starburst,
                        {x=b.x,y=b.y,dir=s-3+math.random(6),fade=175+math.random(50),size=10+math.random(5),speed=5+math.random(5)})
                    end  
                end              
                table.remove(bonus,k)
                if b.type==1 then
                    sound(SOUND_POWERUP, 13232)
                    local val=math.abs(math.floor(-man.linearVelocity.y*multiplier/3))
                    score = score + val
                    table.insert(scoretext,{msg="+"..val,x=man.x,y=HEIGHT-250,fade=255})   
                elseif b.type==3 then
                    sound(SOUND_RANDOM, 13247)
                    multiplier = multiplier + 1
                    table.insert(scoretext,{msg="Multiplier",x=man.x,y=HEIGHT-250,fade=255})   
                elseif b.type==4 then
                    sound(SOUND_RANDOM, 17243)
                    weakplatforms=1
                    table.insert(scoretext,{msg="Weak Platforms",x=man.x,y=HEIGHT-250,fade=255})          
                elseif b.type==5 then
                    sound(SOUND_RANDOM, 93235)
                    man.linearVelocity = man.linearVelocity *-0.9
                    table.insert(scoretext,{msg="Reverse Boost",x=man.x,y=HEIGHT-250,fade=255})       
                elseif b.type==6 then
                    sound(SOUND_RANDOM, 16235)
                    score = score *2
                    table.insert(scoretext,{msg="Double Score",x=man.x,y=HEIGHT-250,fade=255})      
                elseif b.type==7 then
                    sound(SOUND_RANDOM, 1350)
                    score = math.floor(score/2)
                    table.insert(scoretext,{msg="Halve Score",x=man.x,y=HEIGHT-250,fade=255})       
                end
            end
        end
    end        
    -- Draw the water droplets
    for s,d in pairs(droplets) do
        --add transparency to the droplets so they fades away
        tint(77, 194, 231, d.fade)
        pushMatrix()
        translate(d.x,d.y-man.y+HEIGHT-300)
        rotate(180)
        sprite("Small World:Raindrop Soft",0,0,d.size,d.size) 
        popMatrix()
        d.x = d.x + d.speed*math.sin(math.rad(-d.dir))
        d.y = d.y + d.speed*math.cos(math.rad(-d.dir))
        d.fade = d.fade -5
        if d.fade<0 then
            table.remove(droplets,s)
        end
    end
    tint(255)
    --water    
    if (25+bottomlevel-man.y+HEIGHT-300>-60) and (25+bottomlevel-man.y+HEIGHT-300<HEIGHT) then
        for x=50,WIDTH-50,50 do
            sprite("Platformer Art:Water",x+25,40+bottomlevel-man.y+HEIGHT-240,50,50)
            sprite("Platformer Art:Water",x+17,40+bottomlevel-man.y+HEIGHT-260,50,50)
            sprite("Platformer Art:Water",x+8,40+bottomlevel-man.y+HEIGHT-280,50,50)
            sprite("Platformer Art:Water",x,40+bottomlevel-man.y+HEIGHT-300,50,50)
        end
    end
    --draw the walls
    
    local counta=0
    for k,w in pairs(walls) do
        counta = counta + 1
        local offset=counta*-50
        --bit of a bodge to double up the walls 
        if (25+offset-man.y+HEIGHT-300>-60) and (25+offset-man.y+HEIGHT-300<HEIGHT) and counta<depth+2 then
            --print(w.position)
            sprite("Platformer Art:Block Brick",WIDTH-42,50+offset-man.y+HEIGHT-300,50,50)
            sprite("Platformer Art:Block Brick",25,50+offset-man.y+HEIGHT-300,50,50)
        end
    end
    -- Draw the bottom of the well
    if (-25+bottomlevel-man.y+HEIGHT-300>-60) and (-25+bottomlevel-man.y+HEIGHT-300<HEIGHT) then
        for x=25,WIDTH,50 do
            sprite("Platformer Art:Block Brick",x,bottomlevel-man.y+HEIGHT-300,50,50)
        end
    end
    
    -- Draw the starburst
    for s,d in pairs(starburst) do
        --add transparency to the stars so they fades away
        tint(math.random(255),math.random(255),math.random(255),d.fade)
        pushMatrix()
        translate(d.x,d.y-man.y+HEIGHT-300)
        sprite("Cargo Bot:Star Filled",0,0,d.size,d.size) 
        popMatrix()
        d.x = d.x + d.speed*math.sin(math.rad(-d.dir))
        d.y = d.y + d.speed*math.cos(math.rad(-d.dir))
        d.fade = d.fade -5
        if d.fade<0 then
            table.remove(starburst,s)
        end
    end
    tint(255)
    
    -- Check to see if the player is at the bottom of the well for the first time
    if man.y<bottomlevel+150 and splashcount<10 then
        splashcount=splashcount+1
        if splashspeed==0 then
            splashspeed=man.linearVelocity.y/-100
        end
        --reset restitution of main character so he doesn't bounce off the bottom
        man.restitution=0
        table.insert(droplets,
        {x=man.x,y=man.y,dir=340+math.random(40),
        fade=175+math.random(50),size=12+math.random(5),speed=splashspeed+math.random(5)})
        stroke(255)
        strokeWidth(3)
        fill(255)
        if splashcount==1 then
            levelover=0
            sound(SOUND_EXPLODE, 14832)
            if #rocks==rockcount then
                --first in bonus
                score = score + 1000*multiplier
                table.insert(scoretext,{msg="FIRST IN BONUS! +1000",x=man.x,y=HEIGHT-250,fade=255})
            elseif #rocks==0 then
                --last in penalty
                table.insert(scoretext,{msg="YOU LOST!",x=man.x,y=HEIGHT-250,fade=255})
                lastflag=1
            end
        end
    end      
    if splashcount==10 then
        levelover=levelover+1
        if levelover>300 then
            man:destroy()
            man=nil
            if score<0 or lastflag==1 then
                sc=3
            else
                sc=5
            end
        end
    end
    
    for k,s in pairs(scoretext) do
        fill(math.random(255),math.random(255),math.random(255),s.fade)
        text(s.msg,s.x,s.y)
        s.y = s.y + 1
        s.fade = s.fade -1
        if s.fade<0 then
            table.remove(scoretext,k)
        end
    end
    font("AmericanTypewriter-CondensedBold")
    fontSize(32)
    fill(255,205,30)
    text("Score: "..score, WIDTH/2,HEIGHT-35)   
end

function touched(touch)
    if touch.state == ENDED then
        --create a new platform provided both start and end of the touch are within
        --the drawing zone (well) and the line is at least a minimum length
        if sc==2 and man~=nil then
            if (tsup[touch.id].tstarty+man.y-HEIGHT+300>-50*depth+100) and
            (touch.y+man.y-HEIGHT+300>-50*depth+100) and
            (tsup[touch.id].tstarty+man.y-HEIGHT+300<50) and
            (touch.y+man.y-HEIGHT+300<50) and
            vec2(tsup[touch.id].tstartx,tsup[touch.id].tstarty):dist(vec2(touch.x,touch.y))>50 then
                local bod=physics.body(EDGE,
                vec2(tsup[touch.id].tstartx,tsup[touch.id].tstarty+man.y-HEIGHT+300),
                vec2(touch.x,touch.y+man.y-HEIGHT+300))     
                bod.info="platform"
                
                table.insert(platforms,
                {x1=tsup[touch.id].tstartx,y1=tsup[touch.id].tstarty+man.y-HEIGHT+300,
                    x2=touch.x,y2=touch.y+man.y-HEIGHT+300,fade=255,
                pbody=bod})
                sound(SOUND_RANDOM, 599)
                --there is a cost associated with drawing the platform
                score = score - multiplier*math.floor(vec2(tsup[touch.id].tstartx,tsup[touch.id].tstarty):dist(vec2(touch.x,touch.y))/5)
                
            elseif startamnesty>100 then
                sound(SOUND_RANDOM, 28443) --good ominous sound
                score=score-200*multiplier
                table.insert(scoretext,{msg="-200",x=touch.x,y=touch.y,fade=255})
            end      
        end
        touches[touch.id] = nil
        tsup[touch.id]=nil
    else
        touches[touch.id] = touch      
        if tsup[touch.id]==nil then
            tsup[touch.id]={tstartx=touch.x,tstarty=touch.y}
        end
    end
end

function collide(contact)
    if contact.state==BEGAN and sc==2 then
        if contact.bodyA.info=="man" or contact.bodyB.info=="man" then
            
            if contact.bodyA.info=="platform" or contact.bodyB.info=="platform" then
                sound(SOUND_POWERUP, 12891)
                mancollision=1
            elseif contact.bodyA.info=="rock" or contact.bodyB.info=="rock" then
                sound(SOUND_HIT, 12909)
                mancollision=1
                score = score + 1*multiplier
                table.insert(scoretext,{msg="+10",x=man.x,y=HEIGHT-250,fade=255})
            elseif contact.bodyA.info=="wall" or contact.bodyB.info=="wall" then
                sound(SOUND_JUMP, 631)
                mancollision=1
            elseif contact.bodyA.info=="bottom" or contact.bodyB.info=="bottom" then
                --player hasn't collided with anything so make a skull appear as the extra bonus next level
                if mancollision==0 then playergaming=1 end
                man.restitution=0
            end
        end
        if contact.bodyA.info=="platform" and weakplatforms==1 then
            for k,p in pairs(platforms) do
                if p.pbody.id==contact.bodyA.id then
                    p.pbody:destroy()
                    p.pbody=nil
                    table.remove(platforms,k)
                end
            end
        end
        if contact.bodyB.info=="platform" and weakplatforms==1 then
            for k,p in pairs(platforms) do
                if p.pbody.id==contact.bodyB.id then
                    p.pbody:destroy()
                    p.pbody=nil
                    table.remove(platforms,k)
                end
            end
        end
    end
end