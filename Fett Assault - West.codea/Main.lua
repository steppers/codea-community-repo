-- Codea competition 2015
-- by West
displayMode(FULLSCREEN)
-- Use this function to perform your initial setup
function setup()
    createImages()
    ground=100
    building={}
    for i=1,40 do
        table.insert(building,{x=math.random(WIDTH),w=20+10*math.random(3),h=60+10*math.random(9),type=math.random(2),t=math.random(2)})
    end
    house={} --foreground buildings
    for i=1,10 do
        table.insert(house,{x=math.random(3*WIDTH),y=ground+28,type=math.random(3)})
    end
    
    spd=0
    torigspd=0
    hspd=0
    hanim=1
    angle=-10
    hx=200
    hy=HEIGHT/2
    tactive=0
    torig=vec2(0,0)
    ladder={}
    ladderactive=0
    wave=1
    waveframe={1,2,1,3}
    man={}
    table.insert(man,{x=math.random(5000),y=ground+12,wave=math.random(4),lift=0,type=1,a=0,vx=0,vy=0,rotspd=0,active=1})
    table.insert(man,{x=math.random(5000),y=ground+12,wave=math.random(4),lift=0,type=2,a=0,vx=0,vy=0,rotspd=0,active=1})
    for i=1,20 do
        table.insert(man,{x=math.random(5000),y=ground+12,wave=math.random(4),lift=0,type=2+math.random(3),a=0,vx=0,vy=0,rotspd=0,active=1})
    end
    --   person={"c3po","r2d2","sand","jawa","storm"}
    laser={}
    smoke={}
    gunangle=0
    gunxoff=7
    gunyoff=-36
    damage=0
end

function draw()
    
    --damage
    if math.random(200)<damage then
        table.insert(smoke,{x=hx,y=hy,a=math.random(360),active=1,rise=math.random(10),fade=355})
    end
    
    
    if spd>10 then spd=10 end
    if spd<-3 then spd=-3 end
    angle=-spd*3.5
    --colors
    
    sprite(asset.backdrop,WIDTH/2,HEIGHT/2,WIDTH,HEIGHT)
    --damage bar
    fill(0,100)
    rect(0.1*WIDTH,0.94*HEIGHT,0.8*WIDTH,0.02*HEIGHT)
    local barlen=((100-damage)/100)*WIDTH*0.78
    fill(238, 230, 5, 255)
    rect(0.101*WIDTH,0.941*HEIGHT,barlen,0.018*HEIGHT)
    
    noStroke()
    
    for i,b in pairs(building) do
        if b.type==1 then
            sprite(mountainimg[b.t],b.x,130,64,64)
            b.x = b.x - spd*b.type/4
            if b.x<-100 then b.x=WIDTH+100 end
            if b.x>WIDTH+100 then b.x=-100 end
        end
    end
    
    for i,b in pairs(building) do
        if b.type==2 then
            sprite(mountainimg[b.t],b.x,130,64,64)
            b.x = b.x - spd*b.type/4
            if b.x<-100 then b.x=WIDTH+100 end
            if b.x>WIDTH+100 then b.x=-100 end
        end
    end
    fill(186, 99, 26, 255)
    rect(0,0,WIDTH,ground)
    fill(216, 162, 17, 255)
    rect(0,ground-9,WIDTH,10)
    --draw ladder
    
    for i,r in pairs(ladder) do
        pushMatrix()
        translate(r.x+0.05*i*i*math.sin(math.rad(angle)),hy+r.y+i*math.cos(math.rad(angle)))
        rotate(angle)
        if i==#ladder then
            sprite(beam,0,0,12,12)
        else
            sprite(beam,0,0,8,8)
        end
        popMatrix()
    end
    --draw slave ship
    
    pushMatrix()
    translate(hx,hy)
    rotate(angle)
    sprite(slave,0,0,156/4,360/4)
    popMatrix()
    
    --gun
    pushMatrix()
    translate(hx,hy)
    
    rotate(angle)
    translate(gunxoff,gunyoff)
    rotate(math.deg(gunangle))
    sprite(gun,0,0,64/4,64/4)
    popMatrix()
    hanim = hanim + 0.5
    if hanim>3.99 then hanim=1 end
    
    hy = hy + hspd
    if tactive==0 then
        if math.abs(hspd)>0 then
            hspd=(math.abs(hspd)-0.03)*hspd/math.abs(hspd)
        end
        
        if math.abs(spd)>0 then
            spd=(math.abs(spd)-0.02)*spd/math.abs(spd)
        end
        
    end
    if ladderactive==1 then
        table.insert(ladder,{x=hx,y=ladder[#ladder].y-8})
    end
    if #ladder>0 then
        if hy+ladder[#ladder].y+#ladder*math.cos(math.rad(angle))<ground then
            ladderactive=2
            for i,m in pairs(man) do
                if math.abs(m.x-ladder[#ladder].x)<10 then
                    if m.lift==0 then
                        m.lift=1
                    end
                end
            end
        end
        
        if ladderactive==2 then
            table.remove(ladder,#ladder)
        end
        
        if hy>HEIGHT-20 then hy=HEIGHT-20 end
        if hy<ground+20 then hy=ground+20 end
    end
    for i,h in pairs(house) do
        sprite(houseimg[h.type],h.x,h.y)
        h.x = h.x - spd
    end
    for i,m in pairs(man) do
        
        if m.x>0 and m.x<WIDTH and math.random(200)==1 and m.type>2 then
            local ang=math.atan(hy-m.y,hx-m.x)
            table.insert(laser,{x=m.x,y=m.y,active=1,a=ang})
        end
        
        if m.lift==0 then
            pushMatrix()
            translate(m.x,m.y)
            rotate(m.a)
            if m.active==2 then
                sprite(person[m.type+5],0,0,32,32)
            else
                sprite(person[m.type],0,0,32,32)
            end
            popMatrix()
            m.x = m.x - spd
            m.a = m.a + m.rotspd
            m.x = m.x + m.vx
            m.y = m.y + m.vy
            --only do this if flying
            if m.active==2 then
                m.vy = m.vy - 0.1
            end
            if m.y<0 then m.active=0 end
        elseif m.lift==1 then
            sprite(person[m.type],m.x+0.05*#ladder*#ladder*math.sin(math.rad(angle)),m.y,32,32)
            if #ladder>0 then
                m.y=hy+ladder[#ladder].y+#ladder*math.cos(math.rad(angle))-12
            else
                m.lift=2 --inside heli
            end
        end
    end
    
    for i,b in pairs(laser) do
        pushMatrix()
        translate(b.x,b.y)
        rotate(-90)
        rotate(math.deg(b.a))
        sprite("Space Art:Green Bullet",0,0,6,18)
        popMatrix()
        if math.abs(hx-b.x)<20 and math.abs(hy-b.y)<20 then
            damage = damage + 1
            b.active=0
            table.insert(smoke,{x=b.x,y=b.y,a=math.random(360),active=1,rise=math.random(10),fade=255})
        end
        
        b.x = b.x + 10*math.cos(b.a)
        b.y = b.y + 10*math.sin(b.a)
        b.x = b.x - spd
        if b.y>HEIGHT then b.active=0 end
        if b.y<ground then
            b.active=0
            table.insert(smoke,{x=b.x,y=b.y,a=math.random(360),active=1,rise=math.random(10),fade=255})
            
            for j,m in pairs(man) do
                if math.abs(m.x-b.x)<20 and m.active==1 then
                    m.rotspd=-5+math.random(110)/10
                    local dir=math.rad(-20+math.random(40))
                    local vel=5+math.random(5)
                    m.vx=vel*math.sin(dir)
                    m.vy=vel*math.cos(dir)
                    m.active=2
                end
            end
        end
    end
    for i,b in pairs(laser) do
        
        if b.active==0 then
            table.remove(laser,i)
        end
    end
    
    for i,s in pairs(smoke) do
        tint(255,s.fade)
        pushMatrix()
        translate(s.x,s.y)
        rotate(s.a)
        sprite("Cargo Bot:Smoke Particle",0,0,s.rise,s.rise)
        popMatrix()
        s.x = s.x - spd
        s.y = s.y + s.rise/5
        s.rise = s.rise + 0.25
        s.fade = s.fade - math.random(10)
        if s.fade<0 then
            s.active=0
        end
        noTint()
    end
    for i,b in pairs(smoke) do
        
        if b.active==0 then
            table.remove(smoke,i)
        end
    end
    for i,b in pairs(man) do
        
        if b.active==0 then
            table.remove(man,i)
        end
    end
end

function touched(t)
    if t.tapCount==2 then
        if #ladder==0 then
            table.insert(ladder,{x=hx,y=-16})
            ladderactive=1
        end
    end
    
    if tactive==0 then
        torig=t
        tactive=1
        torigspd=spd
    end
    if t.state==MOVING then
        spd=torigspd+(t.x-torig.x)/50
        hspd=(t.y-torig.y)/100
    end
    if t.state==ENDED then
        tactive=0
        if t.y<ground then
            
            --add in ship rotation - angle
            local ga=math.atan(gunyoff,gunxoff)
            local gr=math.sqrt(gunyoff*gunyoff+gunxoff*gunxoff)
            
            local gxo=gr*math.cos(ga+math.rad(angle))
            local gyo=gr*math.sin(ga+math.rad(angle))
            
            local gx=hx+gxo
            local gy=hy+gyo
            
            local ang=math.atan(t.y-gy,t.x-gx)
            table.insert(laser,{x=gx,y=gy,active=1,a=ang})
            gunangle=ang
        end
    end
end

function createImages()
    ss=image(384,384)
    setContext(ss)
    sprite(asset.spritesheet,384/2,384/2,384,384)
    setContext()
    slave=ss:copy(0,0,192,384)
    gun=ss:copy(320,256,64,64)
    houseimg={}
    houseimg[1]=ss:copy(192,320,64,64)
    houseimg[2]=ss:copy(256,320,64,64)
    houseimg[3]=ss:copy(320,320,64,64)
    mountainimg={}
    mountainimg[1]=ss:copy(192,256,64,64)
    mountainimg[2]=ss:copy(256,256,64,64)
    person={}
    person[1]=ss:copy(192,0,32,32)
    person[2]=ss:copy(192,32,32,32)
    person[3]=ss:copy(192,64,32,32)
    person[4]=ss:copy(192,96,32,32)
    person[5]=ss:copy(192,128,32,32)
    person[6]=ss:copy(224,0,32,32)
    person[7]=ss:copy(224,32,32,32)
    person[8]=ss:copy(224,64,32,32)
    person[9]=ss:copy(224,96,32,32)
    person[10]=ss:copy(224,128,32,32)
    beam= ss:copy(368,224,16,16)
end