-- Lemmings

-- Use this function to perform your initial setup
function setup()
    viewer.mode=FULLSCREEN
    mida=1574
    timer,timer2=0,0
    timeInterval = 0
    mou=(WIDTH-mida)/2
    screen=1
    sort=1
    tallarTot(1)
    ninos=Besties()
    ColourFons= color(46,39,67)
    jocsetup="pantalla"
    paused=1
    alpha=0
    musik=false
end


function draw()
    if jocsetup=="joc" then jocdraw()end
    if jocsetup=="pantalla" then pantalladraw() end
end

function touched(touch)
    if jocsetup=="joc" then
        if touch.state == MOVING and touch.y>160 then 
            mou=math.min( mou+touch.delta.x,0)
            mou=math.max( mou+touch.delta.x,WIDTH-mida)
        end
        if  touch.state == ENDED and touch.y<155  then
            estil=(touch.x-(WIDTH-768)/2)//(768/12)
            explo=true
            if estil==10 then
                explo=false
                for i=1,#ninos do
                    ninos[i]:canvi("explota")
                end
            end
            if estil==11 then musik=not musik music.paused=musik end
        end
        for i=1,#ninos do
            ninos[i]:touched(touch)
        end
    end
    if     jocsetup=="pantalla" then
        paused=0
    end
end

function jocdraw()
    print(velocitat)
    background(17, 17, 19, 255)
    spriteMode(CENTER)
    sprite(asset.barra,WIDTH/2,80,768)--617
    spriteMode(CORNER)
    sprite(fons,mou,160)
    timer=timer+DeltaTime
    if timer>1/8 then
        sort=sort+1
        if sort==7 then sort=1 end
        if ninot<10 then ninot=ninot+1 end
        timer=0
    end
    if   os.date('%M')*60 +os.date('%S')>t1+1 and inici==false then
        inici=true
        table.insert(ninos,Besties())
        ninos[#ninos].x=origin.x
        ninos[#ninos].y=origin.y
    end
    if inici then timer2=timer2+DeltaTime end
    if timer2>velocitat and inici and vides>1 then
        table.insert(ninos,Besties())
        ninos[#ninos].x=origin.x
        ninos[#ninos].y=origin.y
        vides=vides-1
        timer2=0
    end
    sprite(porta[ninot],xporta+mou,yporta,138)
    sprite(sortida[sort],xsalida+mou,ysalida,134)
    if  CurrentTouch.state == BEGAN and CurrentTouch.y<155  then
        local estil2=(CurrentTouch.x-(WIDTH-768)/2)//(768/12)
        if estil2==1 and velocitat>0.9 then velocitat=velocitat-0.05 end
        if estil2==0 and velocitat<5 then velocitat=velocitat+0.05 end
        end
    pushStyle()
    if estil>=0 and estil<11 then
        stroke(243, 221, 36, 255)
        strokeWidth(4)
        noFill()
        rectMode(CENTER)
        rect((WIDTH-768)/2+estil*768/12+768/24,80,768/12,100)
    end
    popStyle()
    numeros()
    frase()
    a,bb=0,0
    clip(0,160,WIDTH,590)
    for i=1,#ninos do
        ninos[i]:draw()
        if ninos[i].tipo==25 then a=i end
        if ninos[i].tipo==223 or ninos[i].tipo==192 then bb=i end
    end
    clip()
    if a~=0 then table.remove(ninos,a) -- han sortit
        vides3=vides3+1
        sound(asset.downloaded.Game_Sounds_One.Block_3)
    end
    if bb~=0 then table.remove(ninos,bb)   end
    if gameTime==0 then
        for i=#ninos, 1 ,-1 do
            table.remove(ninos,i)
        end
    end
    if #ninos==0 and vides~=vides4 then
        Faderdraw(3)
    end
    if alpha>0 then
        Faderdraw(-1)
    end
end
function pantalladraw()
    pushStyle()
    local nom=asset
    spriteMode(CENTER)
    fill(ColourFons)
    rect(0,0,WIDTH,HEIGHT)
    sprite(nom["info"..(screen)..".png"],WIDTH/2,HEIGHT/2,WIDTH)
    a=0
    if paused==0 then Faderdraw(3) end -- va a negre
    if paused==2 then Faderdraw(-2) end -- va a blanc
    popStyle()
end
