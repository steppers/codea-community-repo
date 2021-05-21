--
--

function setupParameters()
    parameter.integer("moveLight", 0, 1, 0)
    -- wrapping is how much the heightmap wraps to the pseudo-sphere
    parameter.integer("sphere", 0, 1, 1)
    parameter.number("wrapping", 1, 10, 4)
    
    -- quality is the heightmap level of detail (step size)
    parameter.integer("quality", 1, 6, 2)
    -- quality of the texture, warning :P
    parameter.integer("defaultTextureQuality", 1, 4, 4)
    
    -- str is the scaling of height values
    parameter.integer("str", 0, 2048, 768)
    
    -- npower is the perlin noise scaling
    parameter.integer("nPower", 10, 200, 100)
    
    parameter.integer("wireframe", 0, 1, 0)
    parameter.integer("textured", 0, 1, 1)
    parameter.integer("colored", 0, 1, 0)
    
    parameter.number("Red", 0, 1, 1) 
    parameter.number("Green", 0, 1, 0)
    parameter.number("Blue", 0, 1, 0)
end
    
-- Ugly mess to handle parameters
function readParameters()
    if (baseW ~= wrapping) then
        dx = -256*wrapping
        dy = -256*wrapping
        loadMdl()
        baseW = wrapping
    end
    if (baseSp ~= sphere or baseQ ~= quality or baseS ~= str) then
        loadMdl()
        
        baseS = str
        baseQ = quality
        baseSp = sphere
    end
    if (baseP ~= nPower ) then
        loadMdl()
        if textured == 1 then
            colorTexture = genTexture(textureQ)
        end
        baseP = nPower
    end
    if (baseTex ~= textured or baseT ~= textureQ or baseX ~= lx or baseZ ~= lz) then
        colorTexture = genTexture(textureQ)
        baseX = lx
        baseZ = lz
        
        baseT = textureQ
        baseTex = textured
    end
    if baseDTQ ~= defaultTextureQuality then
        baseDTQ = defaultTextureQuality
        textureQ = defaultTextureQuality*64
        colorTexture = genTexture(textureQ)
        baseT = textureQ
    end
    if (baseC ~= colored or baseR ~= Red or baseG ~= Green or baseB ~= Blue) then
        for i=1, #mdl.vertices do
            v = mdl.vertices[i]
            v.done = false
        end
        baseC = colored
    end
end
