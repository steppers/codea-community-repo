-- Dave1707Mesh2

function setup()
    parameter.integer("number",200,5000,1000)
    parameter.action("init",calc)
    m=mesh()
    m.texture=readImage(asset.builtin.Platformer_Art.Block_Brick)
    pos()
    calc()
end

function pos()
    local sin=math.sin
    local cos=math.cos
    local rad=math.rad
    newPos={}
    for a=0,359 do
        local x1=cos(math.rad(a))*14
        local y1=sin(math.rad(a))*14        
        local x2=cos(math.rad(a+120))*14
        local y2=sin(math.rad(a+120))*14
        local x3=cos(math.rad(a+240))*28
        local y3=sin(math.rad(a+240))*28
        newPos[a]={x1=x1,y1=y1,x2=x2,y2=y2,x3=x3,y3=y3}
    end
end

function calc()
    tab={}
    tc={}
    fps,dc,dt=0,0,0
    size=number
    for z=1,size do
        x=math.random(WIDTH)
        y=math.random(HEIGHT)
        table.insert(tab,{x=x,y=y,ang=0,angVel=math.random(-4,4),
            xVel=math.random(-5,5),yVel=math.random(-5,5),
        col=color(math.random(255),math.random(255),math.random(255))})
        table.insert(tc,vec2(0,0))
        table.insert(tc,vec2(1,0))
        table.insert(tc,vec2(0,1))
    end
    m.texCoords=tc
    create()
    m:setColors(255,255,255)
    for z=1,size*3 do
        m:color(z,tab[math.ceil(z/3)].col)
    end
end

function draw()
    background(0, 251, 255, 255)
    parameter.watch("fps")
    parameter.watch("memory")
    create()
    m:draw() 
    dt=dt+DeltaTime
    dc=dc+1
    if dc==10 then
        fps=dc/dt
        dc,dt=0,0
        memory=collectgarbage("count")
    end
end

function create()
    local tab1={}
    for z=1,size do
        local t2=tab[z]
        t2.x=(t2.x+t2.xVel)%WIDTH
        t2.y=(t2.y+t2.yVel)%HEIGHT
        t2.ang=(t2.ang+t2.angVel)%360
        local p=#tab1+1
        tab1[p]=vec2(newPos[t2.ang].x1+t2.x,newPos[t2.ang].y1+t2.y)    
        tab1[p+1]=vec2(newPos[t2.ang].x2+t2.x,newPos[t2.ang].y2+t2.y)
        tab1[p+2]=vec2(newPos[t2.ang].x3+t2.x,newPos[t2.ang].y3+t2.y)
    end
    m.vertices=tab1
end
