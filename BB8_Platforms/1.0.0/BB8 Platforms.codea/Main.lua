--Bb8
--By West
displayMode(FULLSCREEN)
-- Use this function to perform your initial setup
function setup()
    size=25
    bbody=physics.body(CIRCLE,size)
    bbody.x=WIDTH*0.05
    bbody.y=HEIGHT
    bbody.bullet=true
    
    e1=physics.body(EDGE,vec2(0,0),vec2(0,HEIGHT))  -- changed
    e2=physics.body(EDGE,vec2(WIDTH,0),vec2(WIDTH,HEIGHT))  -- changed
    
    bbody.restitution=0.2
    platform={}
    platform[1]={x1=0,y1=HEIGHT*0.8,x2=WIDTH*0.5,y2=HEIGHT*0.8}
    platform[2]={x1=WIDTH*0.6,y1=HEIGHT*0.8,x2=WIDTH,y2=HEIGHT*0.8}
    platform[3]={x1=WIDTH*0.2,y1=HEIGHT*0.6,x2=WIDTH,y2=HEIGHT*0.6}
    platform[4]={x1=0,y1=HEIGHT*0.4,x2=WIDTH*0.3,y2=HEIGHT*0.4}
    platform[5]={x1=WIDTH*0.4,y1=HEIGHT*0.4,x2=WIDTH*0.6,y2=HEIGHT*0.4}
    platform[6]={x1=WIDTH*0.7,y1=HEIGHT*0.4,x2=WIDTH,y2=HEIGHT*0.4}
    platform[7]={x1=WIDTH*0.2,y1=HEIGHT*0.2,x2=WIDTH,y2=HEIGHT*0.2}
    platform[8]={x1=0,y1=HEIGHT*0.05,x2=WIDTH,y2=HEIGHT*0.05}
    
    pl={}   -- add this
    for i,p in pairs(platform) do
        plat=physics.body(EDGE,vec2(p.x1,p.y1),vec2(p.x2,p.y2)) -- changed
        table.insert(pl,plat)   -- add this
    end
    
    obj={}
    obj[1]={x=WIDTH*0.9,y=HEIGHT*0.85}
    obj[2]={x=WIDTH*0.35,y=HEIGHT*0.65}
    obj[3]={x=WIDTH*0.85,y=HEIGHT*0.45}
    obj[4]={x=WIDTH*0.55,y=HEIGHT*0.25}
end

-- This function gets called once every frame
function draw()
    -- This sets a dark background color
    background(40, 40, 50)
    sprite(asset.background,WIDTH/2,HEIGHT/2, WIDTH, HEIGHT)
    physics.gravity(Gravity)
    for i,b in pairs(obj) do
        sprite("Tyrian Remastered:Evil Head",b.x,b.y,3*size)
        if vec2(b.x,b.y):dist(vec2(bbody.x,bbody.y))<20 then
            bbody.x=WIDTH*0.05
            bbody.y=HEIGHT
        end
    end
    
    -- This sets the line thickness
    strokeWidth(5)
    pushMatrix()
    translate(bbody.x,bbody.y)
    rotate(bbody.angle)
    sprite(asset.bb8body,0,0,2*size)
    popMatrix()
    sprite(asset.bb8head,bbody.x,bbody.y+size,2*size)
    stroke(60, 78, 31, 255)
    for i,p in pairs(platform) do
        line(p.x1,p.y1,p.x2,p.y2)
    end
    
end

function touched(t)
    if t.state==ENDED then
        print(bbody.linearVelocity.y)
        if math.abs(bbody.linearVelocity.y)<1 then
            bbody:applyForce(vec2(0,600))
        end
    end
end