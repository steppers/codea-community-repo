-- Main program --
------------------------------------------------------

viewer.mode = FULLSCREEN
viewer.mode = OVERLAY
function setup()
    -- saveProjectInfo("Description", "3D renderer")
    -- saveProjectInfo("Author", "Xavier de Boysson")
    setupParameters()
    
    textureQ = defaultTextureQuality*64
    baseW = wrapping
    baseS = str
    baseQ = quality
    baseSp = sphere 
    baseP = nPower 
    baseX = X
    baseZ = Z
    baseT = textureQ
    baseTex = textured
    baseC = colored
    baseR = Red
    baseG = Green
    baseB = Blue
    baseDTQ = defaultTextureQuality
    
    cnt = 0
    txt = ""
    lx = 0.1
    lz = 0.1
    baseX = lx
    baseZ = lz
    
    nbTouches = 0
    touches = {}
    delta = 0
    dx = -256*wrapping
    dy = -256*wrapping
    
    currentZ = 512
    
    --stroke(255)
    --strokeWidth(5)
    --noSmooth()
    
    p = mesh()
    loadMdl()
    
    detailTexture = genWireframe(32)
    colorTexture = genTexture(textureQ)
    
    textMode(CORNER)
    
end
    
-- Load the heightmap
function loadMdl()
    
    mdl = Model:init(quality, nPower, wrapping, str)
    for i=1, #mdl.vertices do
        local v = mdl.vertices[i]
        
        v.x = v.x + dx
        v.z = v.z + dy
        
        -- the initial pseudo-sphere wrapping formula
        if sphere == 1 then
            v.y = v.y + (v.x * v.x + v.z * v.z)*0.001
        end
    end
    cnt = 0
    
end
    
    
    
    