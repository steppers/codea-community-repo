-- Procedural Underwater
--Inspired by the book Barry the Fish with Fingers by Sue Hendra
viewer.mode=FULLSCREEN
-- Use this function to perform your initial setup
function setup()
    touches={}
    tsup={}
    bubbles={}
    splinters={}
    crates={}
    cratedelay=0
    table.insert(crates,Crate(100+math.random(WIDTH-200),HEIGHT+200,2+math.random(5)))
    crate=vec2(WIDTH/2+110,HEIGHT+200)
    puffy=vec2(WIDTH/2,HEIGHT/2)
    barry=vec2(WIDTH/2-200,HEIGHT/2)
    
    cratespd=3
    blendMode(NORMAL)
    ff=vec2(0,0)
    ffactive=0
    bbcount=1
    bb={4,3,2,1,2,3,4,5,6,7,6,5}
    
    HAPPY=1
    SAD=2
    SHOCKED=3
    
    fishes={}
    for i=1,10 do
    table.insert(fishes,Fish(100+math.random(WIDTH-200),200+math.random(HEIGHT-300)))
        end
    
end

-- This function gets called once every frame
function draw()
    cratedelay = cratedelay - 1
    
    background(114,121,141)
    
    fill(74,67,101)
    ellipse(100,-100,1000)
    ellipse(800,-110,1200)
    tint(74,67,101)
    sprite("Project:coral1",620,500)
    
    noTint()
    fill(45,36,55, 255)
    ellipse(-170,-320,1200)
    ellipse(420,-60,700)
    ellipse(920,-90,760)
  ellipse(1420,-90,960)
      
    tint(94, 136, 204, 255)
    sprite("Project:anenome",720,160,80)
    noTint()
    
    tint(45,36,55, 255)
    sprite("Project:coral2",870,420)
    noTint()
    
    fill(19,24,34, 255)
    ellipse(-170,-400,1200)
    ellipse(420,-210,700)
    ellipse(920,-170,760)
  ellipse(1420,-170,660)
  
    tint(144, 171, 214, 255)
    sprite("Project:anenome",120,140)
    noTint()
    
    fill(217,164,36, 255)
    ellipse(-170,-700,1500)
    ellipse(200,-700,1500)
    ellipse(600,-750,1630)
    ellipse(1200,-700,1500)
    
    for i,b in pairs (bubbles) do
        b:draw()
    end
    
    if math.random(20)==1 then
        table.insert(bubbles,Bubble(197,80,1))
    end
    
    if math.random(20)==1 then
        table.insert(bubbles,Bubble(737,150,0.7))
    end
    
    if math.random(20)==1 then
        table.insert(bubbles,Bubble(360,280,0.5))
    end
    
    for i,f in pairs(fishes) do
        f:draw()
    end
    
    sprite("Project:puffybody",puffy.x,puffy.y,200+2*math.sin(5*ElapsedTime))
    sprite("Project:puffyfin",puffy.x-90-2*math.sin(5*ElapsedTime),puffy.y,50+5*math.sin(5*ElapsedTime),50)
    sprite("Project:puffyfin",puffy.x+90+2*math.sin(5*ElapsedTime),puffy.y,-(50+5*math.sin(5*ElapsedTime)),50)
    sprite("Project:puffyeyes",puffy.x,puffy.y,200)
    sprite("Project:puffysmile",puffy.x,puffy.y,200)
    
    --add in check on nearest crate to change expression
    fill(0)
    
    local eyeyoff=0
    local eyexoff=0
    
    if #crates>0 then
        local ang=math.atan(crates[1].y-puffy.y,crates[1].x-puffy.x)
        eyexoff=6*math.cos(ang)
        eyeyoff=10*math.sin(ang)
    end
    ellipse(puffy.x-25+eyexoff,puffy.y+30+eyeyoff,20)
    ellipse(puffy.x+25+eyexoff,puffy.y+30+eyeyoff,20)
    
    if math.random(50)==1 then
        table.insert(bubbles,Bubble(puffy.x,puffy.y,2))
    end
    
    for i,c in pairs(crates) do
        c:draw()
    end
    
    --foreground
    sprite("Project:redcoral",850,200,400)
    sprite("Project:redcoral",80,100,-300,300)
    tint(224, 53, 41, 255)
    sprite("Project:anenome",420,-8,200)
    noTint()
    
    for i=#bubbles,1,-1 do
        if bubbles[i].active==0 then table.remove(bubbles,i) end
    end
    for i=#crates,1,-1 do
        if crates[i].active==0 then table.remove(crates,i) end
    end
    
    for i,t in pairs(touches) do
        tsup[i].x=t.x
        tsup[i].y=t.y
        tsup[i]:draw()
    end
    
    for i,s in pairs(splinters) do
        s:draw()
    end
    
end

function touched(touch)
    
    for i,c in pairs(crates) do
        c:touched(touch)
    end
    
    if touch.state==ENDED or touch.state==CANCELLED then
        --     processTouch(touch)
        touches[touch.id] = nil
        tsup[touch.id]=nil
    else
        touches[touch.id] = touch
        --if there is no supplementary info associated with the current touch then add it
        if tsup[touch.id]==nil then
            tsup[touch.id]=Fishfinger(touch.x,touch.y)
        end
    end
end

--function processTouch(touch)

--end
