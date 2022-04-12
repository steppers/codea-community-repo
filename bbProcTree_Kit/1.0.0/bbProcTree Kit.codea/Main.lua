-- MyProcTree
-- https://codea.io/talk/discussion/13300/javascript-library-available-on-webrepo#latest
treeMakingNeeded = true

function main()
    
    ::startJSMain::
    
    if not webview then
        webview = WebView()       
        webview:loadJS(ProcTree)
        webview:loadJS(MakeTree)    
    end

    local result = webview:call("makeTree", getStats())    
    
    --to make a random tree uncomment this alternate makeTree call, but
    --be sure to also comment out the "goto startJSMain" line at the end of this function
    --or else you'll different tree shapes every time the loop runs
    --local result = webview:call("makeTree", getRandomStats())
    
    jsverts,jsfaces,jsnormals,jsUV = result[1],result[2],result[3],result[4]
    jsvertsTwig,jsfacesTwig,jsnormalsTwig,jsUVTwig = result[5],result[6],result[7],result[8]   
    
    --calling JS methods outside of main() will crash because the JS environment relies on unseen coroutines, it seems, and calls from external functions interrupt those routines, and cause crashes. 
    --however, keeping main() in an endless loop keeps the coroutines active, apparently, and allows limited direct interaction between the lua and the JS environment  
    --it's limited because main() retains its own scope, it seems, even when accessing global variables, so any changes to global variables will only momentarily affect the main() loop (which will apparently reset those variables once the loop restarts)
    --this is why the tree can't be changed by directly modifying global values sent to makeTree()--those values will just reset. However by having main() call external functions, those functions can be made to return user-changeable values, and then those values will get used to make the tree, hence causing persistent modifications to the tree. 
    --thats why there's a loop here, and that's why the main() code calls external functions instead of trying to access external variables
    --although I'm not quite sure how to keep it from re-making the tree on every single loop--I can't seem to get it to correctly check an external boolean to prevent unnecessary re-makings... 
    
    goto startJSMain
end
    
function getStats()
 --[[   print(seed,
    segments,
    levels,
    vMultiplier,
    twigScale,
    initalBranchLength,
    lengthFalloffFactor,
    lengthFalloffPower,
    clumpMax,
    clumpMin,
    branchFactor,
    dropAmount,
    growAmount,
    sweepAmount,
    maxRadius,
    climbRate,
    trunkKink,
    treeSteps,
    taperRate,
    radiusFalloffRate,
    twistRate,
    trunkLength)]]
    local segmentOptions = {1, 2, 3, 4, 6, 8, 10, 12, 14, 16}
    segments = segmentOptions[segmentsIndex]
    return {
        seed,
        segments,
        levels,
        vMultiplier,
        twigScale,
        initalBranchLength,
        lengthFalloffFactor,
        lengthFalloffPower,
        clumpMax,
        clumpMin,
        branchFactor,
        dropAmount,
        growAmount,
        sweepAmount,
        maxRadius,
        climbRate,
        trunkKink,
        treeSteps,
        taperRate,
        radiusFalloffRate,
        twistRate,
        trunkLength
    }
end

function getRandomStats()
    local segmentOptions = {4, 6, 8, 10, 12}
    local settings = {
        --  "seed":252
        math.random(5000),
        --  "segments":8, --affects how many polygons are used per tree segment
        segmentOptions[math.random(5)],
        --  "levels":5 --how many steps of branching there are, above 9 gets hard for Codea to handle
        math.random(1, 9),
        --  "vMultiplier":1.16, --apparently controls how large the tree texture is drawn on the tree surfaces
        math.random(200) * 0.01,
        --   "twigScale":0.39,
        math.random(50) * 0.01,
        --  "initalBranchLength": 0.49 --smaller than 0.25 seems silly
        (math.random(150) + 25) * 0.01,
        --  "lengthFalloffFactor": 0.85 --between 0.85 and 1 is actually a lot of variety
        (math.random(15) + 85) * 0.01,
        --  "lengthFalloffPower":0.99, --not sure how this is different than above
        (math.random(15) + 85) * 0.01,
        --  "clumpMax":0.454,
        math.random(550) * 0.001,
        --  "clumpMin":0.454,
        math.random(450) * 0.001,
        --  "branchFactor":3.2
        (math.random(400) + 200) * 0.01,
        --   "dropAmount":0.09,
        math.random(10) * 0.01,
        --   "growAmount":0.235,
        math.random(100) * 0.01,
        --   "sweepAmount":0.051,
        math.random(50) * 0.001,
        --   "maxRadius":0.105,
        math.random(40) * 0.01, --where i left off fine-tuning
        --   "climbRate":0.322
        math.random(50) * 0.01,
        --  "trunkKink":0
        math.random(125) * 0.01,
        --   "treeSteps":1
        math.random(12),
        --   "taperRate":0.964,
        math.random(100) * 0.01,
        --    "radiusFalloffRate":0.73,
        math.random(90) * 0.01,
        --    "twistRate":1.5,
        math.random(180) * 0.01,
        --    "trunkLength":2.4
        math.random(10)
    }
    return settings
end

function setup()
        
    print("starting setup")
    if CodeaUnit then 
        codeaTestsVisible(true)
        runCodeaUnitTests() 
    end

    scene = craft.scene()
    local sunny = readText(asset.builtin.Environments.Night)
    local env = craft.cubeTexture(json.decode(sunny))
    scene.sky.material.envMap = env
    scene.sun.eulerAngles = vec3(45, 45, 0)
    
    scene.camera:add(OrbitViewer, vec3(0,2.5,0), 6, 1, 10000)
       
    parameter.boolean("showTwig",true)
    
    parameter.integer("seed", 1, 5000, 2112)
    parameter.integer("segmentsIndex", 1, 10, 6)
    parameter.integer("levels", 1, 15, 5)
    parameter.number("vMultiplier", 0.001, 2, 1.16)
    parameter.number("twigScale", 0.001, 2, 0.39)
    parameter.number("initalBranchLength", 0.001, 2, 0.49)
    parameter.number("lengthFalloffFactor", 0.001, 2, 0.85)
    parameter.number("lengthFalloffPower", 0.001, 2, 0.99)
    parameter.number("clumpMax", 0.001, 2, 0.454)
    parameter.number("clumpMin", 0.001, 2, 0.454)
    parameter.number("branchFactor", 0.001, 6, 3.2)   
    parameter.number("dropAmount", 0.001, 1, 0.09)
    parameter.number("growAmount", 0.001, 2, 0.235)
    parameter.number("sweepAmount", 0.001, 2, 0.051)
    parameter.number("maxRadius", 0.001, 2, 0.105)
    parameter.number("climbRate", 0.001, 2, 0.322)
    parameter.number("trunkKink", 0.0, 2, 0.0)
    parameter.integer("treeSteps", 1, 10, 2)
    parameter.number("taperRate", 0.001, 2, 0.964)
    parameter.number("radiusFalloffRate", 0.001, 2, 0.73)
    parameter.number("twistRate", 0.001, 2, 1.5)
    parameter.number("trunkLength", 1, 10, 2.4)
    
    -- create trunk model   
    myTreeTrunkMesh = craft.model()
    -- create twig model
    myTreeTwigMesh = craft.model()
    -- set the mesh parameters
    updateMeshData(myTreeTrunkMesh, myTreeTwigMesh)
    
    -- create trunk entity   
    trunk = scene:entity()
    trunk.position=vec3(0,0,0)
    trunk:add(craft.renderer, myTreeTrunkMesh)
    trunk.model = myTreeTrunkMesh
    trunk.material = craft.material(asset.builtin.Materials.Standard)
    trunk.material.map = readImage(asset.sandbutton)
    
    -- create twig entity
    twig = scene:entity()
    twig.position=vec3(0,0,0)
    twig:add(craft.renderer, myTreeTwigMesh)
    twig.material = craft.material(asset.builtin.Materials.Standard)
    twig.material.map = readImage(asset.Leaves_Orange)
    twig.active = showTwig
end

function update(dt)
    scene:update(dt)
    twig.active = showTwig
    updateMeshData(myTreeTrunkMesh, myTreeTwigMesh)
end

function draw()
    if CodeaUnit then showCodeaUnitTests() end
    
    update(DeltaTime)    
    scene:draw()
end

function updateMeshData(myTreeTrunkMesh, myTreeTwigMesh)
    
    local v,n,uv,f,v1,n1,uv1,f1 = getMeshData()
    -- trunk mesh data
    myTreeTrunkMesh.positions = v
    myTreeTrunkMesh.normals = n
    myTreeTrunkMesh.uvs = uv
    myTreeTrunkMesh.indices = f
    
    -- twig mesh data
    myTreeTwigMesh.positions = v1
    myTreeTwigMesh.normals = n1
    myTreeTwigMesh.uvs = uv1
    myTreeTwigMesh.indices = f1
end

function getMeshData()
    if jsverts then
        local v,n,uv,f,v1,n1,uv1,f1;
    
        v,n,uv = convert(jsverts,jsnormals,jsUV)
        v1,n1,uv1 = convert(jsvertsTwig, jsnormalsTwig, jsUVTwig)
        f = convertFaces(jsfaces)
        f1 = convertFaces(jsfacesTwig)    
        
        return v,n,uv,f,v1,n1,uv1,f1
    end
end

function convert(verts, normals, UV)
    local v,n,uv = {},{},{}
    for i=1,#verts do
        local x,y,z =verts[i][1], verts[i][2], verts[i][3]
        local n1,n2,n3 = normals[i][1], normals[i][2], normals[i][3]
        local u1,v1 = UV[i][1], UV[i][2]      
        table.insert(v, vec3(x,y,z))
        table.insert(n, vec3(n1,n2,n3))
        table.insert(uv, vec2(u1,v1))
    end
    return v,n,uv
end

function convertFaces(faces)
    local f = {}
    for i=1,#faces do
        local x1,y1,z1 = faces[i][1]+1, faces[i][2]+1, faces[i][3]+1
        table.insert(f,z1)
        table.insert(f,y1)
        table.insert(f,x1)
    end
    return f
end

