presets = {
    
    {title = "scratch", 
    offsetX=2.15,
    offsetZ=2.15,   
    dirtLevel=90,
    grassLevel=60,
    waterLevel=15},
        
    {title = "original", 
    offsetX=2,
    offsetZ=156,   
    dirtLevel=70,
    grassLevel=42,
    waterLevel=7},
    
    {title = "multiple thin rivers",
    offsetX=2.5,
    offsetZ=2.5,   
    dirtLevel=2.5,
    grassLevel=2.5,
    waterLevel=12.5},
    
    {title = "neat mini-lakes and islands", 
    offsetX=500,
    offsetZ=00,
    dirtLevel=90,
    grassLevel=60,
    waterLevel=15},
    
    {title = "big & intricate waterways",
    offsetX=400,
    offsetZ=333,
    dirtLevel=40,
    grassLevel=60,
    waterLevel=15}
}

function useSettings(theseSettings)
    offsetX, offsetZ, dirtLevel, grassLevel, waterLevel, title = theseSettings.offsetX, theseSettings.offsetZ, theseSettings.dirtLevel, theseSettings.grassLevel, theseSettings.waterLevel, theseSettings.title
end
