    function Faderdraw(c)
    pushStyle()
    noSmooth()
    noStroke()
    fill(46, 39, 37, alpha)
    rect(0,0,WIDTH,HEIGHT)
    popStyle()
    alpha=math.min(alpha+c,255)
    alpha=math.max(alpha+c,0)
    if alpha>=255 or alpha<0 then
        fadeAnimationDone()
    end
end
function frase()
    spriteMode(CENTER)
    timeInterval = timeInterval + DeltaTime
    if timeInterval > 1 then
        gameTime = gameTime - 1
        timeInterval = 0
    end
    local  t=math.floor((gameTime)/60)
    local t2=math.floor(math.fmod(gameTime,60))
    local t3=math.floor((vides3/vides4)*100)
    
    s="OUT "..#ninos.." IN "..t3.."% TIME "..t.."-"..string.format("%02d",t2)
    ttext=WIDTH-string.len(s)*30
    for i=1,string.len(s) do
        a=string.byte(s,i)
        if a>32 then sprite(lletra[a-32],ttext/2+i*30,HEIGHT-38,38)end
    end
    
end
function numeros()
    fill(0)
    textMode(CENTER)
    font("AmericanTypewriter-CondensedBold")
    fontSize(26)
    for i,v in pairs(num) do
        text(v,(WIDTH-768)/2+768/12*(i+1)+768/24,106)
    end
    local c=math.floor( 119-velocitat*20)-2
    text(c,(WIDTH-768)/2+768/24,106)
    text(c,(WIDTH-768)/2+768/8,106)
    if musik then text("OFF",(WIDTH-768)/2+768-768/24,106) else
        text("ON",(WIDTH-768)/2+768-768/24,106) end
end

function fadeAnimationDone()
    if jocsetup=="joc" then jocsetup="pantalla"
        if vides3>=vides2 then
        screen=screen+1 
            music.stop() 
        end
     else jocsetup="joc" end
    
    if jocsetup=="joc" then
        velocitat=3.35
        explo=true -- maxim 0.8 minim 5
        if screen==1 then setup1()
        elseif  screen==2 then setup2()
        elseif screen==3 then setup3()
        elseif screen==4 then setup4()
        elseif screen==5 then setup5()
        elseif screen==6 then setup6() 
        elseif screen==7 then setup7() 
        elseif screen==8 then setup8() 
        elseif screen==9 then viewer.close()
        end
    end
    paused=2
    t1= os.date('%M')*60 +os.date('%S')
end
