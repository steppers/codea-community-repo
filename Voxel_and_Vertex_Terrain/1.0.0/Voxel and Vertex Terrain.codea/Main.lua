-- UberGoober Craft Terrain based on dave1707 terrain

viewer.mode=OVERLAY

function setup()
    
    textMode(CENTER)
    textAlign(CENTER)
    
    if hasDependencies() then
    
        scene = craft.scene() 
        craft.scene.main = scene
        scene.voxels.visibleRadius=40
        
        defineVoxelBlocks()
        makeVolumes()   
        setParameters()   
        
        generateFrom(presets[1])     
    end
end

function generateFrom(theseSettings)
    
    print("please wait while setting up voxels, volumes, and vertices :)")    
    arrangeScene()
    useSettings(theseSettings)
    setupModels()    
    voxelPositions = {}

    sideSize = 400
    perlin=craft.noise.perlin()
    decimal=1/sideSize
    xx=0 
    for x=1,sideSize do        
        xx=xx+decimal
        zz=0
        for z=1,sideSize do              
            zz=zz+decimal
            y=math.abs(perlin:getValue(xx+offsetX,0,zz+offsetZ))*150//1
            if y>127 then
                y=127-(y-127)
            end            
            setVoxels(x, y, z, waterLevel)
            prepareVertsColorsAndUv(x, y, z, waterLevel, sideSize, terrainVerts, waterVerts, vertsIndex)
      end  
    end
    
    prepareIndicesAndNormals(sideSize, terrainVerts, terrainIndices, terrainNormals, waterVerts, waterIndices, waterNormals)
    assembleModels()
    createEntitiesWith(terrainModel, waterModel)   
    assignRigidbodyTo(terrainEntity)
end    

function clear()  
    clearVolumes()
    clearModels()
end

function printSpecs()
     output.clear()
    print("presets: "..title.."\n--------"
    .."\noffsetX    "..offsetX
    .."\noffsetZ    "..offsetZ
    .."\ndirtLevel  "..dirtLevel
    .."\ngrassLevel "..grassLevel
    .."\nwaterLevel "..waterLevel)
end

function draw()
    
    if  errorText ~= "" then
        text(errorText, WIDTH/2, HEIGHT/2)
        return
    end
    
    if playerBody then 
        playerBody:update() 
        playerBody:draw() 
    end
    
    if volumes then
        for _, entity in pairs(volumes.entities) do
            entity.active = showVoxels
        end 
    end

    terrainEntity.active = showModel
    waterEntity.active = showModel
    text(presets[settingsSet].title.."\n*** move slider slowly to prevent crashes ***", WIDTH/2, HEIGHT*0.95)
    
    if useSpecularMaterial then
        pushStyle()
        textWrapWidth(math.min(WIDTH, HEIGHT) * 0.9)
        fontSize(fontSize() * 1.1)
        fill(255, 62, 0)
        font("ArialRoundedMTBold")
        text("specular material uses normals to calculate reflections and shadows\n\nas you can see I can't quite figure out how to do the normals right", WIDTH/2, HEIGHT*0.75)
        popStyle()
    end
    
    if rotateVolumes then
        spinVolumesBy(1, volumes.entities)
    end
end