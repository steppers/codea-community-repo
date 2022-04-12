function setupModels()
    terrainModel = craft.model()
    terrainVerts = {}
    terrainIndices = {}
    terrainNormals = {}
    terrainUvs = {}
    terrainColors = {}
    uvTicker = 0
    
    waterModel = craft.model()
    waterVerts = {}
    waterIndices = {}
    waterUvs = {}
    waterNormals = {}
    waterColors = {}
end

function assembleModels()        
    terrainModel.positions = terrainVerts
    terrainModel.uvs = terrainUvs
    terrainModel.colors = terrainColors
    terrainModel.normals = terrainNormals
    terrainModel.indices = terrainIndices
    waterModel.positions = waterVerts
    waterModel.uvs = waterUvs
    waterModel.colors = waterColors
    waterModel.normals = waterNormals
    waterModel.indices = waterIndices
end

function createEntitiesWith(terrainModel, waterModel)   
    terrainEntity = scene:entity()
    terrainEntity.model = terrainModel
    terrainEntity.material = craft.material(asset.builtin.Materials.Basic)
    waterEntity = scene:entity()
    waterEntity.model = waterModel
    waterEntity.material = craft.material(asset.builtin.Materials.Basic)
end

function assignRigidbodyTo(terrainEntity)
    if terrainEntity:get(craft.rigidbody) then
        print(terrainEntity:remove(craft.shape.model))
        terrainEntity:remove(craft.rigidbody)
        rigidBody = nil
        modelShape = nil
    end
    rigidBody = terrainEntity:add(craft.rigidbody, STATIC)
    modelShape = terrainEntity:add(craft.shape.model, terrainModel)
end

function prepareVertsColorsAndUv(x, y, z, waterLevel, sideSize, terrainVerts, waterVerts, vertsIndex)
    
    local rowOffset = (x - 1) * sideSize
    local vertsIndex = z + rowOffset
    
    prepareVertsUsing(x, y, z, waterLevel, terrainVerts, waterVerts, vertsIndex)
    
    terrainColors[vertsIndex] = vertColorsBasedOnHeight(y)
    if y < waterLevel then 
        waterColors[vertsIndex] = variedColorFor("Water")
    else
        waterColors[vertsIndex] = color(86, 149, 212)
    end
    
    local nextUv = nextUvVec(x, z, sideSize)
    terrainUvs[vertsIndex] = nextUv
    waterUvs[vertsIndex] = nextUv 
end

function prepareIndicesAndNormals(sideSize, terrainVerts, terrainIndices, terrainNormals, waterVerts, waterIndices, waterNormals)
    for i=1, sideSize - 1 do
        for x=1, sideSize - 1 do         
            local rowOffset = (i - 1) * sideSize
            local start = x + rowOffset
            local lr, ul, ur, ll = start, start + sideSize + 1, start + sideSize, start + 1
            --  local lr, ur, ll, ul = start, start + sideSize + 1, start + sideSize, start + 1
            table.insert(terrainIndices, lr) --lower right
            table.insert(terrainIndices, ur) --upper right
            table.insert(terrainIndices, ll) --lower left
            norm(terrainVerts[ll], terrainVerts[ul], terrainVerts[ur], terrainNormals)
            
            table.insert(terrainIndices, ul) --upper left
            table.insert(terrainIndices, ll) --lower left
            table.insert(terrainIndices, ur)  --upper right  
            norm(terrainVerts[ll], terrainVerts[ur], terrainVerts[lr], terrainNormals)
            
            table.insert(waterIndices, lr) --lower right
            table.insert(waterIndices, ur) --upper right
            table.insert(waterIndices, ll) --lower left
            norm(waterVerts[lr], waterVerts[ul], waterVerts[ll], waterNormals)
            
            table.insert(waterIndices, ul) --upper left
            table.insert(waterIndices, ll) --lower left
            table.insert(waterIndices, ur)  --upper right  
            norm(waterVerts[ul], waterVerts[ll], waterVerts[ur], waterNormals)
        end
    end
end

function prepareVertsUsing(x, y, z, waterLevel, terrainVerts, waterVerts, vertsIndex)
    local adjX, adjY, adjZ
    adjX = x + (math.random(12) * 0.1)
    adjY = y + (math.random(16) * 0.1)
    adjZ = z + (math.random(12) * 0.1)
    terrainVerts[vertsIndex] = vec3(adjX, adjY, adjZ)
    waterVerts[vertsIndex] = vec3(adjX, waterLevel + (math.random(5) * 0.1), adjZ)
end

function nextUvVec(x, z, sideSize)
    if not uvTicker then
        uvTicker = 0
    end
    uvTicker = uvTicker + 1
    uvAmt = sideSize / x / z
    local uvVec
    if uvTicker == 1 then 
        uvVec = vec2(uvAmt, 0)
    elseif uvTicker == 2 then
        uvVec = vec2(uvAmt, uvAmt)
    elseif uvTicker == 3 then
        uvVec = vec2(0, 0)
    elseif uvTicker == 4 then
        uvVec = vec2(0, uvAmt)
        uvTicker = 0
    end
    return uvVec
end

function norm(a,b,c, normTable)
    v1=b-a
    v2=c-b
    n1=v1:cross(v2)
    table.insert(normTable,n1)
    table.insert(normTable,n1)
    table.insert(normTable,n1)
end

function clearModels()
    if terrainEntity then
        terrainEntity:destroy()
        waterEntity:destroy()
        terrainModel.positions = {}
        waterModel.positions = {}
    end 
end
