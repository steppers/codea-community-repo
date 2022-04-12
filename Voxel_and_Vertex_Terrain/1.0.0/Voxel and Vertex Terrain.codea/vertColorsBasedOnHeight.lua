function vertColorsBasedOnHeight(y)
    local vertColor, waterVertColor
    if y>=dirtLevel then
        vertColor = variedColorFor("Snow")
    elseif y>=grassLevel then
        vertColor = variedColorFor("DirtGrass")                                        
    elseif y>=waterLevel then
        vertColor = variedColorFor("Grass Top")                                        
    else
        vertColor = variedColorFor("Underwater Dirt")                                        
        waterVertColor = variedColorFor("Water")                                       
    end
    return vertColor, waterVertColor
end

function variedColorFor(terrainKind)
    
    local vertColor, darkener
    
    if terrainKind == "Snow" then
        vertColor = color(255)
        local blueShift = math.random(35)
        if blueShift > 15 then blueShift = 0 end
        vertColor.r = vertColor.r - (blueShift * 3)
        vertColor.g = vertColor.g - (blueShift * 2) 
    elseif terrainKind == "DirtGrass" then
        vertColor = color(140, 85, 10)
        darkener = 80 - y
        vertColor.g = vertColor.g - darkener
        local brownshift = math.random(45)
        if brownshift > 18 then brownshift = 0 end
        vertColor.r = vertColor.r - brownshift
        vertColor.g = vertColor.g - brownshift
        vertColor.b = vertColor.b - brownshift
    elseif terrainKind == "Grass Top" then
        vertColor = color(0, 255, 0)
        darkener = 180 - y
        vertColor.g = vertColor.g - darkener
        local greenshift = math.random(45)
        if greenshift > 38 then greenshift = 0 end
        vertColor.r = vertColor.r - greenshift
        vertColor.g = vertColor.g - greenshift
        vertColor.b = vertColor.b - greenshift
    elseif terrainKind == "Underwater Dirt" then
        vertColor = color(60, 45, 10)
        darkener = waterLevel - y
        vertColor.g = vertColor.g - darkener
        local brownshift = math.random(25)
        if brownshift > 18 then brownshift = 0 end
        vertColor.r = vertColor.r - brownshift
        vertColor.b = vertColor.b - brownshift
    elseif terrainKind == "Water" then
        vertColor = color(20, 155, 220)
        darkener = waterLevel - y
        vertColor.g = vertColor.g - darkener
        local blueShift = math.random(25)
        if blueShift > 18 then 
            blueShift = 0 
        end
        vertColor.r = vertColor.r - (blueShift * 1.75)
        vertColor.g = vertColor.g - blueShift
    end        
    return vertColor
end
