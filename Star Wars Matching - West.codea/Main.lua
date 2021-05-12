-- Match The Cards
displayMode(FULLSCREEN_NO_BUTTONS)
-- Use this function to perform your initial setup
function setup()

p1={name="Luke",score=0}
p2={name="Vader",score=0}    
    activeplayer=1
    row=9
    col=4
    total=row*col
    ss=image(384,384)
    setContext(ss)
    sprite("Project:spritesheet",384/2,384/2,384,384)
    setContext()
    numPics=9    
    pic={}
    pic[1]=ss:copy(0,0,192,384)
    pic[2]=ss:copy(192,320,64,64)
    pic[3]=ss:copy(256,320,64,64)
    pic[4]=ss:copy(320,320,64,64)
    pic[5]=ss:copy(192,0,32,32)
    pic[6]=ss:copy(192,32,32,32)
    pic[7]=ss:copy(192,64,32,32)
    pic[8]=ss:copy(192,96,32,32)
    pic[9]=ss:copy(192,128,32,32)

    tabh=0.8*HEIGHT --height of playing area

cards={}
    ct=1
    local cnt=0
    for i=0,WIDTH-1,WIDTH/row do
        for j=0,tabh-1,tabh/col do
        table.insert(cards,{x=i+WIDTH/(2*row),y=j+tabh/(2*col),active=1,t=ct})
            cnt = cnt + 1
            if cnt>=total/numPics then
                cnt=0
                ct = ct + 1
            end
            
        end
    end
    for i=1,100 do
        exchange()
    end
    selectIndex1=0
    selectIndex2=0
    vistime=60
    checkpair=0
end

-- This function gets called once every frame
function draw()
    -- This sets a dark background color 
    background(40, 40, 50)
    font("ArialRoundedMTBold")
    fontSize(40)
    if activeplayer==1 then
        fill(255, 243, 0, 255)
    else
        fill(149, 148, 135, 255)        
    end
text(p1.name..": "..p1.score,WIDTH*0.1,HEIGHT*0.9)
    if activeplayer==2 then
        fill(255, 243, 0, 255)
    else
        fill(149, 148, 135, 255)        
    end
text(p2.name..": "..p2.score,WIDTH*0.9,HEIGHT*0.9)
    -- This sets the line thickness
    strokeWidth(5)

for i,c in pairs(cards) do
        if c.active==1 then
        sprite("Platformer Art:Block Special Brick",c.x,c.y,0.8*WIDTH/row,0.8*tabh/col)
        elseif c.active>1 then            
        sprite(pic[c.t],c.x,c.y,0.8*WIDTH/row,0.8*tabh/col)
            end
        if c.active>2 then
            c.active = c.active + 1
            if c.active>vistime then
                checkpair=1
            end
        end
    end
    if checkpair==1 then
        checkpair=0
        if cards[selectIndex1].t==cards[selectIndex2].t then
            cards[selectIndex1].active=0
            cards[selectIndex2].active=0
            sound("Game Sounds One:Bell 2")
            if activeplayer==1 then
                p1.score = p1.score + 1
                else
                p2.score = p2.score + 1
            end
            else
            cards[selectIndex1].active=1
            cards[selectIndex2].active=1
            sound("Game Sounds One:Wrong")
            activeplayer = activeplayer + 1
            if activeplayer>2 then activeplayer=1 end
        end
         selectIndex1=0
         selectIndex2=0        
    end
for i,c in pairs(cards) do
        if c.active==0 then
            table.remove(cards,i)
        end
    end
    if #cards==0 then
        if p1.score>p2.score then
            text(p1.name.." Wins!",WIDTH/2,HEIGHT/2)
        elseif p1.score<p2.score then
            text(p2.name.." Wins!",WIDTH/2,HEIGHT/2)
        else
            text("Draw,",WIDTH/2,HEIGHT/2)
        end
    end
end

function touched(t)
    if t.state==ENDED then
        for i,c in pairs(cards) do
         if c.active==1 and (selectIndex1==0 or selectIndex2==0) and t.x>c.x-WIDTH/(2*row) and t.x<c.x+WIDTH/(2*row) and t.y>c.y-tabh/(2*col) and t.y<c.y+tabh/(2*col) then
               c.active = c.active + 1
                if selectIndex1==0 then
                selectIndex1=i
                else
                    selectIndex2=i
                end
             if c.active>2 then 
           c.active=1 
                if selectIndex1==i then
                        selectIndex1=0
                    end
                if selectIndex2==i then
                        selectIndex2=0
                    end
             end
            end
        end
        
        if selectIndex1~=0 and selectIndex2~=0 then
            cards[selectIndex1].active=3
            cards[selectIndex2].active=3

        end
        
    end
end

function exchange()
  local   c1=math.random(#cards)
   local  c2=math.random(#cards)
    while(c1==c2) do
        c2=math.random(#cards)
    end
    local sub=cards[c1].t
    cards[c1].t=cards[c2].t
    cards[c2].t=sub
end
