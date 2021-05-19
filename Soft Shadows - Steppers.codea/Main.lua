-- Shader Testing

local testMesh, testMesh2
local shadowShader, shadowedFlatShader
local shadowMap

-- Use this function to perform your initial setup
function setup()
    smooth()
    
    -- Create meshes
    testMesh = Plane(4, 4, color(255))
    testMesh2 = Cube(1, 1, 1, color(255, 0, 0))
    
    -- Transform red plane
    testMesh2.trans.pos.y = 0.5
    testMesh2.trans.pos.x = 0.5
    testMesh2.trans.pos.z = 0.5
    testMesh2.trans.rot.y = 25
    
    -- Initialise shaders
    shadowShader = ShadowMapShader()
    shadowedFlatShader = RenderShader()
    
    -- Generate the fix matrix
    ortho(-1, 1, -1, 1, -1, 1)
    local fixMatrix = projectionMatrix()
    shadowShader.fixMatrix = fixMatrix
    shadowedFlatShader.fixMatrix = fixMatrix
    
    -- Set viewProjection for shadows shader
    camera(3, 3, 3, 0, 0, 0, 0, 1, 0)
    ortho(-3, 3, -3, 3, 0, 10)
    shadowShader.projection = projectionMatrix()
    shadowShader.view = viewMatrix()
    shadowedFlatShader.shadowProjection = projectionMatrix()
    shadowedFlatShader.shadowView = viewMatrix()
    
    -- Set viewProjection for render shader
    camera(1, 3, -4, 0, 0, 0, 0, 1, 0)
    perspective(60)
    shadowedFlatShader.projection = projectionMatrix()
    shadowedFlatShader.view = viewMatrix()
    
    -- Generate shadow map and set the sampler on the
    -- render shader
    shadowMap = image(512, 512)
    shadowedFlatShader.shadowMap = shadowMap
end

local rotation = 0
function draw()
    
    -- Rotate the object
    rotation = rotation + 8*DeltaTime
    testMesh2.trans.rot.y = rotation
    --testMesh2.trans.rot.x = rotation

    -- Draw shadow map
    setContext(shadowMap, true)
    blendMode(ONE, ZERO)
    background(0)
    testMesh:draw(shadowShader)
    testMesh2:draw(shadowShader)
    setContext()
    
    -- Draw lighting
    background(0)
    testMesh:draw(shadowedFlatShader)
    testMesh2:draw(shadowedFlatShader)
    
    --[[
    resetMatrix()
    ortho()
    viewMatrix(matrix())
    spriteMode(CORNER)
    sprite(shadowMap, 0, 0)
    ]]
end

