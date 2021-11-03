-- Trench
displayMode(FULLSCREEN)
-- Use this function to perform your initial setup
function setup()
    starfield=image(WIDTH,HEIGHT)
    setContext(starfield)
    fill(255)
    for i=1,100 do
        ellipse(math.random(WIDTH),math.random(HEIGHT),3)
    end
    setContext()
    dest=vec2(WIDTH/2,HEIGHT/2)
    target=vec2(-10,200)
    
    lim=2
    laser={}
    xwing={}
    for i=1,4 do
        addXwing()
    end
    counter=0
    
    img=readImage(asset.texture):copy(0,0,50,50)
    w,h=80,50
    d=w --NB flickers if w~=d
    trench=CreateTrench(30,w,h,d,img)
    offset=0
    speed=5
    camx=0
    camy=5
end

function CreateTrench(n,w,h,d,img)
    local d=w
    local m=mesh{}
    m.texture=img
    local v,t={},{}
    --left side
    for i=1,n do
        local x,y1,y2,z1,z2=-w/2,-h/2,h/2,-d/2-i*d,d/2-i*d
        local v1,v2,v3,v4=vec3(x,y1,z1),vec3(x,y1,z2),vec3(x,y2,z2),vec3(x,y2,z1)
        local vv={v1,v2,v3,v3,v4,v1} for i=1,6 do v[#v+1]=vv[i] end
    end
    --right side
    for i=1,n do
        local x,y1,y2,z1,z2=w/2,-h/2,h/2,d/2-i*d,-d/2-i*d
        local v1,v2,v3,v4=vec3(x,y1,z1),vec3(x,y1,z2),vec3(x,y2,z2),vec3(x,y2,z1)
        local vv={v1,v2,v3,v3,v4,v1} for i=1,6 do v[#v+1]=vv[i] end
    end
    --bottom
    for i=1,n do
        local x1,x2,y,z1,z2=-w/2,w/2,-h/2,-d/2-i*d,d/2-i*d
        local v1,v2,v3,v4=vec3(x1,y,z1),vec3(x2,y,z1),vec3(x2,y,z2),vec3(x1,y,z2)
        local vv={v1,v2,v3,v3,v4,v1} for i=1,6 do v[#v+1]=vv[i] end
    end
    --textures
    local tt={vec2(0,0),vec2(1,0),vec2(1,1),vec2(1,1),vec2(0,1),vec2(0,0)}
    for i=1,#v,6 do
        for j=1,6 do t[#t+1]=tt[j] end
    end
    m.vertices=v
    m.texCoords=t
    m:setColors(color(255))
    return m
end

-- This function gets called once every frame
function draw()
    -- This sets a dark background color
    background(40, 40, 50)
    perspective()
    camera(0,5,10,0,5,0)
    pushMatrix()
    translate(target.x,-target.y,offset)
    print(target.x,target.y)
    trench:draw()
    popMatrix()
    --this adjustment makes it an infinite trench
    offset=math.fmod(offset+speed,d)
    ortho()
    viewMatrix(matrix())
    
    strokeWidth(5)
    for i,l in pairs(laser) do
        
        stroke(115, 255, 0, 255)
        line(l.x1,l.y1,l.x1+l.s1*math.cos(l.a1),l.y1+l.s1*math.sin(l.a1))
        l.x1 = l.x1 + l.s1*math.cos(l.a1)
        l.y1 = l.y1 + l.s1*math.sin(l.a1)
        
        line(l.x2,l.y2,l.x2+l.s2*math.cos(l.a2),l.y2+l.s2*math.sin(l.a2))
        l.x2 = l.x2 + l.s2*math.cos(l.a2)
        l.y2 = l.y2 + l.s2*math.sin(l.a2)
        
        line(l.x3,l.y3,l.x3+l.s3*math.cos(l.a3),l.y3+l.s3*math.sin(l.a3))
        l.x3 = l.x3 + l.s3*math.cos(l.a3)
        l.y3 = l.y3 + l.s3*math.sin(l.a3)
        
        line(l.x4,l.y4,l.x4+l.s4*math.cos(l.a4),l.y4+l.s4*math.sin(l.a4))
        l.x4 = l.x4 + l.s4*math.cos(l.a4)
        l.y4 = l.y4 + l.s4*math.sin(l.a4)
        
        l.f = l.f - 11
        if l.f<0 then
            for i,x in pairs(xwing) do
                if vec2(l.tx,l.ty):dist(vec2(x.x,x.y))<20*x.size then
                    x.active=2
                    sound(SOUND_EXPLODE, 14788)
                end
            end            
            table.remove(laser,i)            
        end
    end
    
    for i,x in pairs(xwing) do
        tint(255,x.fade)        
        pushMatrix()
        translate(x.x,x.y)
        rotate(x.a)
        if x.active==1 then
            sprite(asset.xwing,0,0,x.size*100)
        else
            sprite("Tyrian Remastered:Explosion Huge",0,0,x.size*100)
        end
        popMatrix()
        noTint()
        x.x = x.x -2+math.random(3)
        x.y = x.y -2+math.random(3)
        x.a = x.a + math.sin(ElapsedTime+x.off)/5
        if x.active==1 then            
            if x.size<1 then x.size = x.size + 0.002
            else               
                x.size = x.size +0.007*math.sin(ElapsedTime+x.off)
            end
            
        elseif x.active==2 then
            x.size = x.size * 1.08
            x.fade = x.fade - 3
            if x.fade<0 then
                x.active=0
            end
        end
    end
    
    for i,x in pairs(xwing) do
        if x.active==0 then table.remove(xwing,i) end
    end
    
    dest.x=(CurrentTouch.x-WIDTH/2)/(WIDTH*0.05)
    dest.y=math.max(-10,(CurrentTouch.y-HEIGHT/2)/(HEIGHT*0.025))
    
    if target.x<dest.x then target.x = target.x + 1 end
    if target.x>dest.x then target.x = target.x - 1 end
    if target.y<dest.y then target.y = target.y + 1 end
    if target.y>dest.y then target.y = target.y - 1 end
    sprite(asset.cockpit,WIDTH/2,HEIGHT/2)
    counter = counter + math.random(3)
    if counter>300 then
        addXwing()
        counter=0
    end
end

function touched(t)
    if t.state==ENDED then
        local a1=math.atan(t.y-0,t.x-0)
        local s1=vec2(t.x,t.y):dist(vec2(0,0))
        
        local a2=math.atan(-(HEIGHT-t.y),t.x-0)
        local s2=vec2(t.x,t.y):dist(vec2(0,HEIGHT))
        
        local a3=math.atan(-(HEIGHT-t.y),-(WIDTH-t.x))
        local s3=vec2(t.x,t.y):dist(vec2(WIDTH,HEIGHT))
        
        local a4=math.atan(t.y,-(WIDTH-t.x))
        local s4=vec2(t.x,t.y):dist(vec2(WIDTH,0))
        
        table.insert(laser,{tx=t.x,ty=t.y,f=255,a1=a1,s1=s1/25,x1=0,y1=0,a2=a2,s2=s2/25,x2=0,y2=HEIGHT,a3=a3,s3=s3/25,x3=WIDTH,y3=HEIGHT,a4=a4,s4=s4/25,x4=WIDTH,y4=0})
        sound(SOUND_SHOOT, 30296)
    end
    
    
end

function addXwing()
    table.insert(xwing,{x=WIDTH*0.45+math.random(math.floor(WIDTH*0.1)),y=HEIGHT*0.45+math.random(math.floor(HEIGHT*0.1)),size=0.1,a=-14+math.random(30),off=math.random(10),fade=255,active=1})
end