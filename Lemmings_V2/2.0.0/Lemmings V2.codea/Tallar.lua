

function tallarTot (c)
    blocs={}
    tallar()
    -- fons=tallarFons()
    ninos= {}
    porta={}
    ferPorta()
    sortida={}
    ferSortida(c)
    lletra={}
    ferLletra()
    
end
function tallar(b)
    for a=1,16 do
        for b=0,13 do
            blocs[a+b*16]= tallarImage(a,b)
        end
    end
end

function tallarImage(a,b)
    local img = image(48,47)
    x=(a-1)*-48
    spriteMode(CORNER)
    setContext(img)
    sprite(asset.dreta,x,-624+b*48)
    setContext()
    return img
end
function tallarFons()
    fermusica()
    local nom=asset
    spriteMode(CORNER)
    local img = image(mida,590)
    setContext(img)
    fill(46, 39, 67, 255)
    rect(0,0,mida,590)
    sprite(nom["fons"..(screen)..".png"],0,0,mida)
    setContext()
    return img
end

function tallarPorta(y)
    local img = image(123,75)
    setContext(img)
    sprite(asset.trapdoors,0,y)
    setContext()
    return img
end
function ferPorta()
    for i=1, 10 do
        porta[i]=tallarPorta(-750+i*75)
    end
end
function ferSortida(c)
    for a=1,3 do
        for b=0,1 do
            sortida[a+b*3]= tallarSortida(a,b,c)
        end
    end
end

function tallarSortida(a,b,c)
    local nom=asset
    local img = image(120,96)
    x=(a-1)*-120
    spriteMode(CORNER)
    setContext(img)
    sprite(nom["sortida"..(c)..".png"],x,-96+b*96)
    setContext()
    return img
end
function tallarLletra(y)
    local img = image(19,25)
    setContext(img)
    sprite(asset.lemm_font,0,y)
    setContext()
    return img
end
function ferLletra()
    for i=1, 58 do
        lletra[i]=tallarLletra(-1450+i*25)
    end
end
function tallarPic(x,y)
    clip()
    spriteMode(CORNER)
    local img = image(mida,590)
    setContext(img)
    fill(46, 39, 67, 255)
    sprite(fons)
        ellipse(x+20,y-25,36,36) -- 36
    setContext()
    fons=img
end

function tallarExp(x,y)
clip()
    spriteMode(CORNER)
    local img = image(mida,590)
    setContext(img)
    fill(46, 39, 67, 255)
    -- fill(238, 62, 56)
    sprite(fons)
    -- for i=1, 2 do
    ellipse(x+20,y-25,46,36) -- 36
-- end
    setContext()
    fons=img
end
function fermusica()
    local nom=asset
    music(nom["Lemming"..(screen%3)..".mp3"],true)
    music.paused=musik
end
