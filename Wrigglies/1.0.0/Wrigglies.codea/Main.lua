-- Wrigglies
-- Super mega rainbow worm
viewer.mode=FULLSCREEN_NO_BUTTONS
-- Use this function to perform your initial setup
--explosions?

--Crates etc to break above ground?  double hitters?
--ghost trail from last run
--think score as a function or multiplier of length
--multi worm?

function setup()
    score=0
    scoreflag={}
    flashrate=2.8
    tunnel={}
    blink=0
    wormlen=14
    maxwormlen=28
    parameter.integer("maxspd",5,12,12)
    parameter.number("turnrad",0.1,0.2,0.1)
    maxspd=6
    wormsegments={}
    for i=1,wormlen do
        wormsegments[i]=0
    end
    wormsegments[1]=1
    wormsize=28 --radius of worm
    head=vec2(100,100)
    target=vec2(500,100)
    targacc=0
    dir=0
    spd=5 --go up in steps of 1
    turnrad=0.1 --go up in steps of 0.01
    scrollspd=4
    ground=HEIGHT*0.85 --652.8

    dirt={}
    splash={}
    gemsplash={}
    for i=1,10 do
        table.insert(dirt,{x=math.random(WIDTH),y=math.random(math.floor(ground-25)),size=20+math.random(20)})
    end
    shake=vec2(0,0)
    grass={}
    for i=1,3 do
        table.insert(grass,{x=math.random(WIDTH)})
    end
    palette={color(255,0,0, 255),color(255, 127, 0, 255),color(255, 255, 0, 255),color(0, 255, 0, 255),color(0, 0, 255, 255),color(75, 0, 130, 255),color(148, 0, 211, 255)}
    goodies={}
    for i=1,4 do
        table.insert(goodies,{x=math.random(WIDTH),y=math.random(math.floor(ground-25)),id=math.random(#palette),active=1})
    end
    
    baddies={}
    table.insert(baddies,{x=WIDTH+math.random(WIDTH),y=math.random(math.floor(ground-25)),id=math.random(3),active=1,size=75+math.random(50)})
    table.insert(baddies,{x=WIDTH+math.random(WIDTH),y=math.random(math.floor(ground-25)),id=math.random(3),active=1,size=75+math.random(50)})
    table.insert(baddies,{x=WIDTH+math.random(WIDTH),y=math.random(math.floor(ground-25)),id=math.random(3),active=1,size=75+math.random(50)})
    --  table.insert(baddies,{x=WIDTH+math.random(WIDTH),y=math.random(math.floor(ground-25)),id=math.random(3),active=1,size=75+math.random(50)})
    -- table.insert(baddies,{x=WIDTH+math.random(WIDTH),y=math.random(math.floor(ground-25)),id=math.random(3),active=1,size=75+math.random(50)})
    
    
    
    --ther ratio of rocks to gems and also the respawn distance to the right will make easier/harder
    veg={}
    table.insert(veg,{x=math.random(500),kind=3,face=1})

sparkles={}
    taildir=0
    
    
end

-- This function gets called once every frame
function draw()
    if spd<5 then spd = spd + 0.1
    elseif spd<maxspd then spd = spd + 0.01 end
    scrollspd=spd*2/3
    blink = blink - 1
    -- This sets a dark background color
    noStroke()
    background(150,100,39)
    for i,g in pairs(dirt) do
        sprite("Project:dirt",g.x+shake.x,g.y+shake.y,g.size,g.size)
        g.x = g.x - scrollspd
        
        if g.x<-100 then
            g.x=WIDTH+50
            g.y=math.random(math.floor(ground-50))
        end
    end
    for i,g in pairs(goodies) do
        sprite("Project:diamondshadow",0,0,wormsize,3*wormsize)
    end
    
    for i,v in pairs(veg) do
        --653 ground ref
        if v.kind==1 then
            sprite("Project:beetroot",v.x+shake.x,ground-133+shake.y)
            sprite("Project:beetbody",v.x+shake.x,ground-43+shake.y)
        elseif v.kind==2 then
            sprite("Project:carrotbody",v.x+shake.x,ground-43+shake.y-100)
        else
            sprite("Project:parsnipbody",v.x+shake.x,ground-43+shake.y-100)
            
        end
        sprite("Project:beetface"..v.face,v.x+shake.x,ground-43+shake.y)
    end
    
    
    --good dirt color
    fill(129,77,37,60)
    --   fill(0,10)
    for i,t in pairs(tunnel) do
        ellipse(t.x+shake.x,t.y+shake.y,wormsize+2)
    end

    
    fill(147, 188, 216, 255)
    
    rect(0,ground+shake.y,WIDTH,HEIGHT)
    
    
    for i,g in pairs(grass) do
        sprite("Project:grass",g.x+shake.x,ground+25+shake.y,50,50)
        g.x = g.x - scrollspd
        if g.x<-200 then g.x=WIDTH+200+math.random(100) end
    end
    
--vegetable
    for i,v in pairs(veg) do
        if v.kind==1 then
            sprite("Project:beettop",v.x+shake.x,ground+47+shake.y)
        elseif v.kind==2 then
            sprite("Project:carrottop",v.x+shake.x,ground+47+shake.y+28,150,150)
        else
            sprite("Project:parsniptop",v.x+shake.x,ground+47+shake.y+28,150,150)
        end
        
        v.x = v.x - scrollspd
        if v.x<-200 then v.x=WIDTH+200+math.random(300) v.face=1 v.kind=math.random(3) end
        
    end
    noStroke()
    
    for i,s in pairs(splash) do
        sprite("Project:dirt",s.x+shake.x,s.y+shake.y,5,5)
        
        s.x = s.x + s.xspd
        s.y = s.y + s.yspd
        s.x = s.x - scrollspd
        s.yspd = s.yspd - 0.2
        if s.y<ground then table.remove(splash,i) end
    end
    
    if shake.x>0 then shake.x = shake.x - 1 end
    if shake.x<0 then shake.x = shake.x + 1 end
    if shake.y>0 then shake.y = shake.y - 1 end
    if shake.y<0 then shake.y = shake.y + 1 end
    for i=#tunnel,1,-1 do
        
        if i==1 then
            --      text(math.floor(100*math.sin(5*ElapsedTime)),tunnel[i].x,tunnel[i].y+50)
            pushMatrix()
            translate(tunnel[1].x+shake.x,tunnel[1].y+shake.y)
            if #tunnel>1 then
                rotate(math.deg(math.atan((tunnel[1].y-tunnel[2].y),(tunnel[1].x-tunnel[2].x))))
            else
                rotate(0)
            end
            
            sprite("Project:wormheadside",0,0,wormsize,wormsize)
            if math.random(500)==1 then
                --blink
                blink=3
            end
            if blink>0 then
                sprite("Project:wormheadsideblink",0,0,wormsize,wormsize)
            end
            if spd==0 then
                sprite("Project:wormheadsidedead",0,0,wormsize,wormsize)
            end
            
            popMatrix()
            if tunnel[i].y>ground-3 and tunnel[i].y<ground+3 then
                shoogle()
                sound("Game Sounds One:Land")
                for i=1,15 do
                    table.insert(splash,{x=tunnel[i].x,y=tunnel[i].y,xspd=-5+math.random(11),yspd=math.random(7)})
                    
                end
                
            end
            
        elseif i<wormlen then
            pushMatrix()
            translate(tunnel[i].x+shake.x,tunnel[i].y+shake.y)
            rotate(math.deg(math.atan((tunnel[i-1].y-tunnel[i].y),(tunnel[i-1].x-tunnel[i].x)))-90)
            
            --only display every second segment - when adding colours to the segment then this needs to be doubled up too
            if math.fmod(i,2)==0 then
                --default worm face colour
                --171,102,146
                if wormsegments[i]==0 then
                    
                    tint(171,102,146,255)
                    --  noTint()
                else
                    tint(palette[wormsegments[i]].r,palette[wormsegments[i]].g,palette[wormsegments[i]].b,125+125*math.sin(flashrate*i+5*ElapsedTime))
                end
                local tempsize=4*(spd-6)
                if tempsize<0 then tempsize=0 end
                sprite("Project:wormbodyemptytri",0,0,wormsize,wormsize+tempsize)
                
                noTint()
                sprite("Project:wormbodyoutlinetri",0,0,wormsize,wormsize+tempsize)
            end
            popMatrix()
            
        elseif i==wormlen then
            pushMatrix()
            translate(tunnel[i].x+shake.x,tunnel[i].y+shake.y)
            taildir=(math.floor(math.deg(math.atan((tunnel[wormlen-1].y-tunnel[wormlen].y),(tunnel[wormlen-1].x-tunnel[wormlen].x)))-90))
      --      rotate(math.floor(math.deg(math.atan((tunnel[wormlen-1].y-tunnel[wormlen].y),(tunnel[wormlen-1].x-tunnel[wormlen].x)))-90))
            rotate(taildir)
            sprite("Project:wormtail",0,0,wormsize,3*wormsize)
            popMatrix()
            fill(0)
        end
        
    end
    
    for i,g in pairs(goodies) do
        tint(palette[g.id])
        if g.active==1 then
            sprite("Project:diamond",g.x+shake.x,g.y+shake.y,50,50)
        end
        noTint()
        g.x = g.x - scrollspd
        if g.x<-100 then
            g.x=WIDTH+50
            g.y=math.random(math.floor(ground-50))
            local div=HEIGHT/7
            local gemcol=math.floor(target.y/div)+1
            if gemcol>7 then gemcol=7 end
            if gemcol<1 then gemcol=1 end
            g.id=gemcol
            
            g.active=1
        end
    end
    for i,b in pairs(baddies) do
        
        if b.active==1 then
            sprite("Project:rock"..b.id,b.x+shake.x,b.y+shake.y,b.size,b.size)
        end
        noTint()
        b.x = b.x - scrollspd
        if b.x<-100 then
            b.x=WIDTH+50+math.random(WIDTH)
            b.y=math.random(math.floor(ground-50))
            b.size=75+math.random(50)
            b.id=math.random(3)
            
            b.active=1
        end
    end
    
    fill(129,77,37)
    
    
    head.x = head.x + spd*math.cos(dir)
    head.y = head.y + spd*math.sin(dir)
    
    targetdir=math.deg(math.atan(target.y-head.y,target.x-head.x))
    fill(0)
    local diff=math.deg(math.rad(targetdir)-dir)
    
    if dir<math.rad(targetdir) then
        if math.abs(diff)<180 then
            dir = dir + turnrad
        else
            dir=dir-turnrad
        end
    else
        if math.abs(diff)<180 then
            
            dir = dir - turnrad
        else
            dir=dir+turnrad
        end
    end
    --restrict dir to between -180 and 180
    if dir>math.rad(180) then dir=dir-math.rad(360) end
    if dir<-math.rad(180) then dir=dir+math.rad(360) end
    head.x = head.x - scrollspd
    
    table.insert(tunnel,1,{x=head.x,y=head.y})
    
    
    for i=#tunnel,1,-1 do
        tunnel[i].x = tunnel[i].x -scrollspd
        
        if tunnel[i].x<-250 then
            table.remove(tunnel,i)
        end
    end
    
    if head.y>ground then
        target.y = target.y - targacc
        targacc = targacc + 0.3
        
    end
    if head.y<ground then targacc=0 end
    
    for i,b in pairs(baddies) do
        if head:dist(vec2(b.x,b.y))<b.size/2+5 and b.active==1 then
            spd=-5
            shoogle()
            --        b.active=0
            sound("A Hero's Quest:Sword Hit 1")
            losegems()
            resetsegcols()
        end
    end
    
    --check veg collision
    for i,v in pairs(veg) do
        if v.kind==1 then
            if head:dist(vec2(v.x,610))<50 then
                if v.face==1 then
                    sound("A Hero's Quest:Eat 3")
                end
                v.face=2
            end
        else
            --carrot and parsnip detection
            if head.y>ground-290 and head.y<ground then
                if head.x>v.x-50 and head.x<v.x+50 then
                    
                    if v.face==1 then
                        sound("A Hero's Quest:Eat 3")
                    end
                    v.face=2
                    
                end
            end
            
        end
    end
    
    for i,g in pairs(goodies) do
        if head:dist(vec2(g.x,g.y))<25 and g.active==1 then
            
            --    sound("A Hero's Quest:Eat 1")
            sound(SOUND_POWERUP, 878)
            
            if g.active==1 then
                table.insert(scoreflag,{x=g.x,y=g.y,txt="+5",fade=255,active=1})
                score = score + 5
                --might want to tie this to the gem value?
                table.insert(wormsegments,2,g.id)
                table.insert(wormsegments,2,g.id)
                --check here for combos
                if wormsegments[#wormsegments]==wormsegments[#wormsegments-2] and wormsegments[#wormsegments]~=0 then
                    --what are the possible bonuses?
                    --inc worm length
                    --inc speed
                    --inc turn radius
                    --Invinciblity?
                                
                    
                    if wormsegments[#wormsegments]==1 then
                        
                        sound(DATA, "ZgJANABEQEBAaFFAlwzBPhPFAj1zb5E+QABAf0BAQEBAQEBA")
                        wormlen = wormlen + 2
                                                table.insert(scoreflag,{x=g.x,y=g.y,txt="Elongate!",fade=255,active=1})
                        if wormlen>maxwormlen then wormlen=maxwormlen end
                    elseif wormsegments[#wormsegments]==2 then
                        
                        sound(SOUND_POWERUP, 871)
                        maxspd = maxspd + 1
                        table.insert(scoreflag,{x=g.x,y=g.y,txt="Speed Up!",fade=255,active=1})                        
                        if maxspd>12 then maxspd=12 end
                    elseif wormsegments[#wormsegments]==3 then
                        sound(SOUND_JUMP, 8527)
                        turnrad = turnrad + 0.01
                        table.insert(scoreflag,{x=g.x,y=g.y,txt="Turn!",fade=255,active=1})
                        if turnrad>0.2 then turnrad=0.2 end
                    else
                        sound(SOUND_POWERUP, 28970)
                        table.insert(scoreflag,{x=g.x,y=g.y,txt="+50",fade=255,active=1})
                        score = score + 50
                        
   for w=1,360,10 do
                            table.insert(sparkles,{x=head.x,y=head.y,active=1,fade=255,col=wormsegments[#wormsegments],size=5,spd=7,ang=w,spin=-3+math.random(70)/10,rot=math.random(360)})
                    end                       
                        
                    end
                    
                    
                    resetsegcols()
                end
                
                table.remove(wormsegments,#wormsegments)
                table.remove(wormsegments,#wormsegments)
            end
            
            g.active=0 -- catch end of worm
        end
    end
    fontSize(30)
    font("AmericanTypewriter-CondensedBold")
    textMode(CORNER)
    text("Score:"..score,10,HEIGHT-50)
    textMode(CENTER)
    for i,g in pairs(gemsplash) do
        tint(palette[g.col])
        sprite("Project:diamond",g.x,g.y,25,25)
        noTint()
        g.x = g.x + g.xspd
        g.y = g.y + g.yspd
        g.yspd = g.yspd - g.yacc
        g.yacc = g.yacc + 0.01
        if g.y<-100 then g.active=0 end
    end
    for i=#gemsplash,1,-1 do
        if gemsplash[i].active==0 then
            table.remove(gemsplash,i)
        end
    end
    
    for i,s in pairs(scoreflag) do
        font("GillSans-Bold")
        fontSize(40)
        fill(math.random(255),math.random(255),math.random(255),s.fade)
        text(s.txt,s.x,s.y)
        s.y = s.y + 3
        s.fade = s.fade - 5
        if s.fade<0 then
            s.active=0
        end
    end
    for i=#scoreflag,1,-1 do
        if scoreflag[i].active==0 then
            table.remove(scoreflag,i)
        end
    end
    
    if #tunnel>=wormlen then
 --   table.insert(sparkles,{x=tunnel[wormlen].x+45*math.cos(math.rad(taildir-90)),y=tunnel[wormlen].y+45*math.sin(math.rad(taildir-90)),active=1,fade=255,col=math.random(#palette),size=5,spd=3+math.random(50)/10,ang=taildir-90,spin=-3+math.random(70)/10,rot=math.random(360)})
        end
    for i,s in pairs(sparkles) do
        pushMatrix()
        tint(palette[s.col].r,palette[s.col].g,palette[s.col].b,s.fade)
        translate(s.x,s.y)
        rotate(s.rot)
        sprite("Project:star",0,0,s.size)
        popMatrix()
        noTint()
     s.x = s.x - scrollspd
       s.x=s.x+s.spd*math.cos(math.rad(s.ang))
        s.y=s.y+s.spd*math.sin(math.rad(s.ang))
    --    s.x=s.x+s.spd*math.cos(math.rad())
   --     s.y=s.y+s.spd*math.sin(math.rad(taildir-90))
        s.rot = s.rot + s.spin
        s.size = s.size + 0.75
        s.fade = s.fade - 5
        if s.fade<0 then s.active=0 end
    end
    
    for i=#sparkles,1,-1 do
        if sparkles[i].active==0 then
            table.remove(sparkles,i)
        end
    end
    
    
    sprite("UI:Blue Circle",target.x,target.y,7,7)
    fontSize(16)
    fill(0)
    text(wormlen.." "..maxspd.." "..turnrad,WIDTH-100,HEIGHT-20)
    
end

function shoogle()
    shake.x=5
    shake.y=5
    if math.random(2)==1 then shake.x = -shake.x end
    if math.random(2)==1 then shake.y = -shake.y end
end
function resetsegcols()
    wormsegments={}
    for i=1,wormlen do
        wormsegments[i]=0
    end
    
end

function losegems()
    for i=1,#wormsegments do
        if math.fmod(i,2)==0 and wormsegments[i]~=0 then
            local ang=math.rad(i*180/#wormsegments)
            local ys=3*math.sin(ang)
            local xs=3*math.cos(ang)
            table.insert(gemsplash,{x=tunnel[i].x,y=tunnel[i].y,col=wormsegments[i],yspd=ys,yacc=0,xspd=xs,active=1})
        end
        
    end
end

function touched(t)
    if t.state==MOVING or t.state==ENDED then
        if head.y>ground and t.y>ground then
            --don,t move target
            
        else
            target=vec2(t.x,t.y)
        end
    end
end


