Background = class()
--need to make backgroud objects specific locations rather than recycling
function Background:init()
    bgobj={}
    table.insert(bgobj,BackgroundObject(1000,-70,1,1))
    table.insert(bgobj,BackgroundObject(1000,-120,0,1))
end

function Background:drawBG()

    -- This sets a dark background color
    background(255)
    
    tint(198, 53)
 sprite(asset.builtin.Environments.Sunny_Right,WIDTH/2,HEIGHT/2,WIDTH,HEIGHT)

 --sprite(spriteTable[math.random(#spriteTable)],WIDTH/2,HEIGHT/2,WIDTH,HEIGHT)
    noTint()
    --fixed - doesn't move
    pushStyle()
    spriteMode(CORNER)
    for i=1,12 do
        -- if i % 2 == 1 then
        --sprite("Project:hedge",-100+150*i,120,67*3,127*3)
            local hedge = spriteTable[47]
        sprite(spriteTable[47],-300+130*i,-54, hedge.width * 1.5, hedge.height*1.5)
 --         end
       -- local dir=-1
      --  if i==3 or i==5 or i==7 or i==9 then
   --         dir=1
--  end
    end
    popStyle()
    tint(188, 79)
--sprite(asset.ref,WIDTH/2,HEIGHT/2,WIDTH,HEIGHT)
--    sprite(asset.ref2,WIDTH/2,HEIGHT/2,WIDTH,HEIGHT)
    noTint()
    
    for i,b in pairs(bgobj) do
        if b.lev==1 then
        b:draw()
            end
    end
        for i,b in pairs(bgobj) do
        if b.lev==2 then
        b:draw()
            end
    end
    for i,b in pairs(bgobj) do
        if b.lev==3 then
        b:draw()
            end
    end    
   -- sprite("Project:trunk",trunkx,300,600,HEIGHT*1.5)
    sprite(spriteTable[44],trunkx,300,600,HEIGHT*1.5)
    if not stop then
        trunkx = trunkx - 1
        lampx=lampx-0.5
    end
    if trunkx<-1000 then trunkx=1500+math.random(2000) end
    
    
    --default levels
    --back y=80, size 135 x 45
    --middle y=60, size=270 x 90
    --front y=40, size 405 x 135
    
    --grass
    for lev=1,3 do
        for i=1,12 do
            if lev<2 then
                --sprite("Project:foggygrass",lev*gx+lev*100*i,100-20*lev,135*lev,45*lev)
                sprite(spriteTable[7],lev*gx+lev*100*i,100-20*lev,135*lev,180*lev)
                else
            --sprite("Project:dirt",lev*gx+lev*100*i,100-20*lev,135*lev,45*lev)
              sprite(spriteTable[43],lev*gx+lev*100*i,100-20*lev,135*lev,45*lev)
                end
        end
    end
    
    
    if not stop then
        gx = gx - 1
        if gx<-200 then gx=-100 end
    end
    
    
end

function Background:drawFG()

    for i,b in pairs(bgobj) do
        if b.lev==4 then
        b:draw()
            end
    end
    
    lev=4
    for i=1,10 do

        --sprite("Project:dirt",lev*gx+lev*100*i,70-20*lev,135*lev,45*lev)
      sprite(spriteTable[43],lev*gx+lev*100*i,70-20*lev,135*lev,45*lev)
    end

end
