-- Bee New

--TODO 
-- add in checkpoints and lives
-- investigate boss flash
--proper blood splashes -rotate with gravity
--dragonfly movement





--enemy bullets
--cycle between red orange and black

--track touch start positions - if touching bee to start with then build up a super blast

function reset()
    enemies={}
    bonus={}
    bullets={}
    ebullets={}
    counter=0
    particles={}
    bee={}
    table.insert(bee,Bee(100,HEIGHT*0.5,70))    
end

function setup()
    bg=Background()
    gx=-100
    
    displayMode(FULLSCREEN)
    
    loadSprites()
    
    -- Use this function to perform your initial setup
    WASP=1
    SNAIL=2
    BLUEBUTTERFLY=3
    LADYBIRD=4
    FLYINGANT=5
    BOSSCAT=6
    FLYINGLADY=7
    DRAGONFLY=8
    YELLOWBUTTERFLY=9
    BLACKBUTTERFLY=10
    REDBUTTERFLY=11
    
    --GAME STATES
    READY=1
    MENU=2
    PLAY=3
    
    --set up explosion
    
    boom={}
    --m=readImage("Project:explosion")
    --[[  
    boom[1]=m:copy(0,120,60,40)
    boom[2]=m:copy(60,120,60,40)
    boom[3]=m:copy(0,80,60,40)
    boom[4]=m:copy(60,80,60,40)
    boom[5]=m:copy(0,40,60,40)
    boom[6]=m:copy(60,40,60,40)
    boom[7]=m:copy(0,0,60,40)
    boom[8]=m:copy(60,0,60,40)
    ]]
    
    boom[1]=spriteTable[53]
    boom[2]=spriteTable[54]
    boom[3]=spriteTable[61]
    boom[4]=spriteTable[62]
    boom[5]=spriteTable[63]
    boom[6]=spriteTable[64]
    boom[7]=spriteTable[65]
    boom[8]=spriteTable[64]
    
    exp={}
    
    score=0
    lives=3
    rainbow={0,0,0,0,0,0,0}
    
    
    bonusbary=HEIGHT*0.95
    bonusbarw=WIDTH*0.6
    bonusbarx=WIDTH*0.2
    numbonus=7
    bonuscount=0
    stop=false
    
    palette={color(255,0,0, 255),color(255, 127, 0, 255),color(255, 255, 0, 255),color(0, 255, 0, 255),color(0, 0, 255, 255),color(75, 0, 130, 255),color(148, 0, 211, 255)}
    
    touches={}
    tsup={}
    
    reset()
    
    
    dspread={1,1,1,2,2,3,4}
    dandy={}
    for i=1,#dspread do
        local r=math.random(4)
        table.insert(dandy,{x=math.random(WIDTH),y=40+10*r,lev=dspread[i],t=math.random(6)})
    end
    
    trunkx=2000
    lampx=1000
    
    wave={}
    --[[    
    bb=1
    table.insert(wave,{t=100,x=WIDTH+95, y=400,bonus=bb,path=7,bug=REDBUTTERFLY})        
    table.insert(wave,{t=150,x=WIDTH+95, y=400,bonus=bb,path=7,bug=YELLOWBUTTERFLY})        
    table.insert(wave,{t=200,x=WIDTH+95, y=400,bonus=bb,path=7,bug=BLUEBUTTERFLY})        
    table.insert(wave,{t=250,x=WIDTH+95, y=400,bonus=bb,path=7,bug=BLACKBUTTERFLY})        
    ]]--
    bb=0
    for i=1,8 do
        if i==8 then bb=1 end
    table.insert(wave,{t=i*30,x=WIDTH+15, y=600,bonus=bb,path=1,bug=FLYINGANT})
    end
    bb=0
    for i=1,8 do
        if i==8 then bb=1 end
        table.insert(wave,{t=200+i*30,x=WIDTH+15, y=400,bonus=bb,path=1,bug=FLYINGANT})        
    end
    
    bb=1
    table.insert(wave,{t=600,x=WIDTH+160, y=90,bonus=bb,path=1,bug=SNAIL})
    bb=0
    for i=1,8 do
        if i==8 then bb=1 end
     table.insert(wave,{t=500+i*30,x=WIDTH+15, y=400+30*i,bonus=bb,path=1,bug=FLYINGANT})
    end
    
    bb=0
    for i=1,5 do
        if i==5 then bb=1 end
        table.insert(wave,{t=800+i*30,x=WIDTH+15, y=500,bonus=bb,path=1,bug=YELLOWBUTTERFLY})
    end
    
    
    
    bb=0
    for i=1,5 do
        if i==5 then bb=1 end
        table.insert(wave,{t=1200+i*30,x=WIDTH+15, y=400+10*i,bonus=bb,path=2,bug=WASP})
    end
    
    bb=0
    for i=1,5 do
        if i==5 then bb=1 end
        table.insert(wave,{t=1600+i*30,x=WIDTH+15, y=200+i*50,bonus=bb,path=1,bug=WASP})
    end
    bb=0
    for i=1,5 do
        if i==5 then bb=1 end
        table.insert(wave,{t=1800+i*100,x=WIDTH+15, y=50,bonus=bb,path=1,bug=LADYBIRD})
    end
    
    bb=0
    for i=1,5 do
        if i==5 then bb=1 end
        table.insert(wave,{t=2400+i*30,x=WIDTH+15, y=600-i*50,bonus=bb,path=1,bug=WASP})
    end
    
    bb=0
    for i=1,13 do
        if i==13 then bb=1 end
        table.insert(wave,{t=2800+i*20,x=WIDTH+15, y=200,bonus=bb,path=6,bug=FLYINGLADY})
    end   
    
    bb=0
    for i=1,4 do
        if i==4 then bb=1 end
        table.insert(wave,{t=3200+i*20,x=WIDTH+15, y=500,bonus=bb,path=2,bug=FLYINGANT})
        table.insert(wave,{t=3200+i*20,x=WIDTH+15, y=200,bonus=bb,path=3,bug=FLYINGANT})
    end   
    
    bb=1
    table.insert(wave,{t=3400,x=WIDTH+160, y=90,bonus=bb,path=1,bug=SNAIL})  
    
    bb=0
    for i=1,3 do
        if i==1 then bb=1 else bb=0 end
        table.insert(wave,{t=3400+i*30,x=-50, y=600,bonus=bb,path=4,bug=FLYINGANT})
    end   
    bb=0
    for i=1,5 do
        if i==1 then bb=1 else bb=0 end
        table.insert(wave,{t=3700+i*30,x=-50, y=600-20*i,bonus=bb,path=4,bug=FLYINGANT})
    end   
    
    bb=0
    for i=1,5 do
        if i==5 then bb=1 end
        table.insert(wave,{t=4000+i*30,x=WIDTH+15, y=250,bonus=bb,path=6,bug=BLUEBUTTERFLY})
    end
    
    bb=0
    for i=1,8 do
        if i==8 then bb=1 end
        table.insert(wave,{t=4200+i*30,x=WIDTH+15, y=350,bonus=bb,path=6,bug=BLUEBUTTERFLY})
    end
    
    bb=0
    for i=1,5 do
        if i==1 then bb=1 else bb=0 end
        table.insert(wave,{t=4300+i*30,x=-50, y=300+20*i,bonus=bb,path=4,bug=FLYINGANT})
    end       
    
    bb=0
    for i=1,5 do
        if i==1 then bb=1 else bb=0 end
        table.insert(wave,{t=4500+i*30,x=-50, y=300+20*i,bonus=bb,path=4,bug=WASP})
    end       
    bb=1
    table.insert(wave,{t=4700,x=WIDTH+160, y=90,bonus=bb,path=1,bug=SNAIL})  
    table.insert(wave,{t=5100,x=WIDTH+160, y=90,bonus=bb,path=1,bug=SNAIL})  
    table.insert(wave,{t=5500,x=WIDTH+160, y=90,bonus=bb,path=1,bug=SNAIL})  
    
    for i=1,5 do  
        table.insert(wave,{t=5100+100*i,x=WIDTH+95,y=300+50*i,bonus=bb,path=3,bug=DRAGONFLY})        
    end
    
    
    
    bb=0
    for i=1,5 do
        if i==5 then bb=1 end
        table.insert(wave,{t=6000+i*30,x=WIDTH+15, y=500-10*i,bonus=bb,path=1,bug=YELLOWBUTTERFLY})
        table.insert(wave,{t=6100+i*30,x=WIDTH+15, y=200+10*i,bonus=bb,path=1,bug=REDBUTTERFLY})
    end
    
    
    table.insert(wave,{t=6500,x=WIDTH+100, y=600,bonus=bb,path=5,bug=BOSSCAT})   
    
    
end

function loadSprites()
    pushStyle()
    spriteMode(CORNER)
    img1=readImage(asset.spritesheet)    
    w,h = spriteSize( img1 ) 
    -- print(w,h)
    spriteTable={}
    count=1
    --load all the 120x120 sprites
    for y=960,600,-120 do

        for x=0,1080,120 do
                print(count.." "..x.." ", y.." ".."120".." ".."120" )
            local offset = 1
            if x==0 then
                offset = 0
            end
            
                table.insert(spriteTable,img1:copy(x+offset,y+1,120,120))
         count=count+1      
        end
    end
    --load everything touching row 5, starting from index 41
    table.insert(spriteTable,img1:copy(0,480,240,120))--dragonfly thorax (index 41)
    table.insert(spriteTable,img1:copy(240,480,360,120))--snail
    table.insert(spriteTable,img1:copy(600,480,240,120))--dirt
    table.insert(spriteTable,img1:copy(840,0,360,600))--tree
    --load everything touching row 6, starting from index 45
    table.insert(spriteTable,img1:copy(0,480,240,120))--dragonfly placement model
    table.insert(spriteTable,img1:copy(240,240,120,240))--dragonfly wings
    table.insert(spriteTable,img1:copy(360,240,240,240))--hedge
    table.insert(spriteTable,img1:copy(600,0,240,480))--cat
    --load the 60x60 things on row 8, starting from index 49
    table.insert(spriteTable,img1:copy(0,300,60,60))--small dragonfly leg
    table.insert(spriteTable,img1:copy(60,300,60,60))--medium dragonfly leg
    table.insert(spriteTable,img1:copy(0,241,60,60))--large dragonfly leg
    count = count + 11
    --load all the 60x60 sprites in the bottom two rows, starting from index 52
    for y=180,0,-60 do        
        for x=0,540,60 do
            print(count.." "..x.." ", y.." ".."60".." ".."60" )
            table.insert(spriteTable,img1:copy(x,y,60,60))
          count=count+1      
        end
    end
    print("total sprite count: "..#spriteTable)
    popStyle()
end

-- This function gets called once every frame
function draw()

    for i,w in pairs(wave) do
        if counter==w.t then
            table.insert(enemies,Enemy(w.x,w.y,w.bonus,w.path,w.bug))
        end
    end
    
    bg:drawBG()
    
    -- This sets the line thickness
    strokeWidth(5)
    
    
    for i,e in pairs(exp) do
        e:draw()
    end
    
    for i=#exp,1,-1 do
        if exp[i].active==0 then table.remove(exp,i) end
    end
    
    
    --draw enemies
    for i,e in pairs(enemies) do
        e:draw()
        e:checkhit()
    end
    for i,b in pairs(bullets) do
        b:draw()
    end
    for i,b in pairs(ebullets) do
        b:draw()
    end
    
    for i,b in pairs(bonus) do
        b:checkCollision()
        b:draw()
    end
    --draw players
    for i,b in pairs(bee) do
        b:draw()
        b:checkhit()
    end
    for i,p in pairs(particles) do
        p:draw()
    end
    
    --draw foreground
    bg:drawFG()
    
    counter = counter + 1
    
    --clean up
    for i=#bullets,1,-1 do
        if bullets[i].active==0 then
            table.remove(bullets,i)
        end
    end
    
    for i=#ebullets,1,-1 do
        if ebullets[i].active==0 then
            table.remove(ebullets,i)
        end
    end
    
    for i=#bonus,1,-1 do
        if bonus[i].active==0 then
            table.remove(bonus,i)
        end
    end
    
    for i=#enemies,1,-1 do
        if enemies[i].active==0 then
            table.remove(enemies,i)
        end
    end
    
    for i=#particles,1,-1 do
        if particles[i].active==0 then
            table.remove(particles,i)
        end
    end
    
    for i=#bee,1,-1 do
        if bee[i].active==0 then
            table.remove(bee,i)
        end
    end
    
    if #bee<1 then
        fill(100,100)
        stroke(200,200)
        fontSize(60)
        font("Futura-CondensedExtraBold")
        text("GAME OVER", WIDTH/2,HEIGHT/2)
        stop=true
        
        --temp state control to test reset
        if CurrentTouch.tapCount==2 then
            reset()
            stop=false
            lives = lives - 1
            counter=0
        end
        
    end
    
    fill(100,100)
    stroke(200,200)
    strokeWidth(2)
    for i=1,numbonus do
        if i<=bonuscount then
            fill(100,200,100,100)
        else
            fill(100,100)
        end
        local bwidth=bonusbarw/numbonus
        rect(bonusbarx+(i-1)*bwidth,bonusbary,bwidth,HEIGHT-bonusbary)
        local bonusIndexes = {74,75,76,77,84,85,86,87}
        -- sprite("Project:bonus"..i,bonusbarx+(i-0.5)*bwidth,bonusbary+(HEIGHT-bonusbary)/2,35,35)
        sprite(spriteTable[bonusIndexes[i]],bonusbarx+(i-0.5)*bwidth,bonusbary+(HEIGHT-bonusbary)/2,35,35)
    end
    
    
    font("Futura-CondensedExtraBold")
    fontSize(16)
    fill(0,100)
    textMode(CORNER)
    text("Score: "..score,20,HEIGHT-30)
    textMode(CENTER)
    
    for i=1,lives do
        -- sprite("Project:foggyhead",WIDTH*0.8+30*i,HEIGHT-10,40,40)
        sprite(spriteTable[3],WIDTH*0.8+30*i,HEIGHT-10,40,40)
    end
    
    for i,r in pairs(rainbow) do
        if r==0 then
            tint(0,100)
            -- sprite("Project:daisymask",WIDTH*0.8+20*i,HEIGHT-30,10,10)
            sprite(spriteTable[73],WIDTH*0.8+20*i,HEIGHT-30,10,10)
            noTint()  
        else
            tint(palette[i])
            -- sprite("Project:daisymask",WIDTH*0.8+20*i,HEIGHT-30,20,20)
            sprite(spriteTable[73],WIDTH*0.8+20*i,HEIGHT-30,20,20)
            noTint()  
            --          text(r,WIDTH*0.8+20*i,HEIGHT-50)
        end
    end   
    
    
    
    
    for k,t in pairs(touches) do
        
        if tsup[k].starty>bonusbary and tsup[k].startx>bonusbarx and tsup[k].startx<bonusbarx+bonusbarw then
            
        else
            --check to see if assigned
            local ct=0
            for i,b in pairs(bee) do
                if b.tid==t.id then
                    ct=t.id
                    b.tx=t.x
                    b.ty=t.y
                end
            end
            
            if ct==0 then
                local nearest=0
                local touching=0
                for i,b in pairs(bee) do
                    if b.tid==nil then
                        if nearest==0 then
                            nearest=i
                            if vec2(bee[i].x,bee[i].y):dist(vec2(t.x,t.y))<bee[i].size then
                                --started off touching too!
                                touching=1
                            end
                        else
                            --  check distance to old nearest , if nearer then replace
                            if vec2(bee[i].x,bee[i].y):dist(vec2(t.x,t.y))< vec2(bee[nearest].x,bee[nearest].y):dist(vec2(t.x,t.y)) then
                                nearest=i
                                
                                if vec2(bee[i].x,bee[i].y):dist(vec2(t.x,t.y))<bee[i].size then
                                    --started off touching too!
                                    touching=1
                                end
                                
                            end
                        end
                    end
                end
                if nearest~=0 then
                    bee[nearest].tid=t.id
                    bee[nearest].tx=t.x
                    bee[nearest].ty=t.y
                    bee[nearest].drag=touching
                end
            end
        end
    end
end

function touched(touch)
    if touch.state==ENDED or touch.state==CANCELLED then
        processTouch(touch)
        touches[touch.id] = nil
        tsup[touch.id]=nil
    else
        touches[touch.id] = touch
        --if there is no supplementary info associated with the current touch then add it
        if tsup[touch.id]==nil then
            --check to see if there is an exisitng touch event assigned to the movement, and log in the "kind" variable
            tsup[touch.id]={startx=touch.x,starty=touch.y,startt=ElapsedTime,kind=k}
        end
    end
end

function processTouch(touch)
    if touch.y>bonusbary and touch.x>bonusbarx and touch.x<bonusbarx+bonusbarw then
        local dd=bonusbarw/numbonus
        local bselect=math.ceil((touch.x-bonusbarx)/dd)
        
        if bselect<=bonuscount then
            sound(SOUND_PICKUP, 711)
            bonuscount = bonuscount - bselect
            if bselect==1 then
                for i,b in pairs(bee) do
                    b.bulletspeed = b.bulletspeed - 1
                    if b.bulletspeed<6 then b.bulletspeed=6 end
                end
            elseif bselect==2 then
                for i,b in pairs(bee) do
                    b.shield=1
                    b.injured=0
                end
            elseif bselect==3 then
                for i,b in pairs(bee) do
                    b.bulletspread = b.bulletspread+ 1
                    if b.bulletspread>4 then b.bulletspread=4 end
                end
            elseif bselect==4 then                
                --rear
                for i,b in pairs(bee) do
                    
                    b.rearbullet= b.rearbullet + 1
                    if b.rearbullet>3 then b.rearbullet=3 end
                end
            elseif bselect==5 then                
                --bomb
                for i,b in pairs(bee) do
                    b.bombrate = b.bombrate + 1
                    if b.bombrate>3 then b.bombrate=3 end
                end
                
            elseif bselect==6 then                
                --upbomb
                for i,b in pairs(bee) do
                    b.upbombrate = b.upbombrate + 1
                    if b.upbombrate>3 then b.upbombrate=3 end
                    
                    
                end                               
                
                
            elseif bselect==7 then                
                --extra bee
                if #bee<3 then
                    table.insert(bee,Bee(-100,HEIGHT*0.5,70))
                end
            end
            
            
        end
    end
    
    
    for i,b in pairs(bee) do
        if b.tid==touch.id then
            --could do the release of build up weapon here
            if b.drag==1 then
                local pow=math.min(50,math.floor((ElapsedTime-tsup[touch.id].startt)*40))
                table.insert(bullets,Bullet(b.x,b.y+2*b.size/70,0,2,pow))
                sound(SOUND_SHOOT, 21132)
            end
            b.drag=0
            b.tid=nil
        end
    end
end
