-- Loopspace

Model = class()

function Model:init(
    quality, 
    n, 
    dist, 
    wrapping, 
    str,
    Red,
    Green,
    Blue,
    wireframe,
    texture
    )
    self.quality = quality
    self.nPower = n
    self.dist = dist
    self.wrapping = wrapping
    self.str = str
    self.Red = Red
    self.Green = Green
    self.Blue = Blue
    self.wireframe = wireframe
    self.texture = texture
    self.x = 0
    self.y = 0
    self.mesh = mesh()
    self:create()
    self:generate()
    self:colour()
    self:setwireframe()
end

function Model:update(
    quality, 
    n, 
    dist, 
    wrapping, 
    str,
    Red,
    Green,
    Blue,
    wireframe
    )
    local recreate, regenerate, recolour, rewire
    if quality ~= self.quality then
        recreate = true
        regenerate = true
        recolour = true
        rewire = true
    end
    if n ~= self.nPower
    or dist ~= self.dist
    or wrapping ~= self.wrapping
    or str ~= self.str
    then
        regenerate = true
        recolour = true
    end
    if Red ~= self.Red
    or Green ~= self.Green
    or Blue ~= self.Blur
    then
        recolour = true
    end
    if wireframe ~= self.wireframe then
        rewire = true
    end
    self.quality = quality or self.quality
    self.nPower = n or self.nPower
    self.dist = dist or self.dist
    self.wrapping = wrapping or self.wrapping
    self.str = str or self.str
    self.Red = Red or self.Red
    self.Green = Green or self.Green
    self.Blue = Blue or self.Blue
    self.wireframe = wireframe or self.wireframe
    if recreate then
        self:create()
    end
    if regenerate then
        self:generate()
    end
    if recolour then
        self:colour()
    end
    if rewire then
        self:setwireframe()
    end
end

function Model:create()
    local numSteps = math.pow(2,6-self.quality)
    
    local t = {}
    local hn = (numSteps)/2
    for i = 1,numSteps do
        for j = 1,numSteps do
            table.insert(t,{(i-hn)^2 + (j-hn)^2,i,j})
        end
    end
    table.sort(t,function(a,b) return a[1] > b[1] end)
    self.grid = t
    self.numSteps = numSteps
end

function Model:generate()
    local n = self.nPower
    local dist = self.dist
    local wrapping = self.wrapping
    local str = self.str
    local f = {}
    local ver = {}
    local vv,x,y,z,s,col,ix,iy
    local g = self.grid
    local numSteps = self.numSteps
    local gridSize = 512/numSteps
    local hn = numSteps*gridSize/2
    local sx = self.x or 0
    local sy = self.y or 0
    local isx = math.floor(sx/gridSize)*gridSize
    local isy = math.floor(sy/gridSize)*gridSize
    local offsetX = WIDTH*.5
    local offsetY = HEIGHT*.5
    for i = 0,numSteps do
        vv = {}
        ix = i*gridSize - isx
        for j = 0,numSteps do
            iz = j*gridSize - isy
            x = (ix - hn + sx)*wrapping
            z = (iz - hn + sy)*wrapping
            y = dist - noise(ix/n, iz/n)*str
            y = math.max(y,100)
            y = y + (x * x + z * z)*0.001
            s = 600/(600 + y)
            col = 255 - y*.075
            table.insert(vv,{
                vec2(x * s + offsetX,z * s + offsetY),
                col
            })
        end
        table.insert(ver,vv)
    end
    local meshver = {}
    local meshtex = {}
    local numver = 0
    local tri = {
        {
            {0,0},
            {1,0},
            {1,1},
            {0,0},
            {0,1},
            {1,1}
        },
        {
            {0,0},
            {0,1},
            {1,1},
            {0,0},
            {1,0},
            {1,1}
        }
    }
    local i
    for k,v in ipairs(g) do
        if v[2] > v[1] then
            i = 2
        else
            i = 1
        end
        for l,u in ipairs(tri[i]) do
            table.insert(meshver,ver[v[2]+u[1]][v[3]+u[2]][1])
            table.insert(meshtex,vec2(u[1],u[2]))
            numver = numver + 1
        end
    end
    self.numver = numver
    self.vertices = ver
    self.mesh.vertices = meshver
    
    self.mesh.texCoords = meshtex
end

function Model:setwireframe()
    if self.wireframe == 1 then
        self.mesh.texture = self.texture
    else
        self.mesh.texture = nil
    end
end

function Model:colour()
    local Red = self.Red
    local Green = self.Green
    local Blue = self.Blue
    local g = self.grid
    local ver = self.vertices
    local meshcol = {}
    local col
    local a = 0
    local tri = {
        {
            {0,0},
            {1,0},
            {1,1},
            {0,0},
            {0,1},
            {1,1}
        },
        {
            {0,0},
            {0,1},
            {1,1},
            {0,0},
            {1,0},
            {1,1}
        }
    }
    local i
    for k,v in ipairs(g) do
        if v[2] > v[1] then
            i = 2
        else
            i = 1
        end
        for l,u in ipairs(tri[i]) do
            col = ver[v[2]+u[1]][v[3]+u[2]][2]*a/self.numver
            a = a + 1
            table.insert(meshcol,color(col*Red,col*Green,col*Blue,255))
        end
    end
    self.mesh.colors = meshcol
end

function Model:shift(x,y)
    self.x = self.x + x/self.wrapping
    self.y = self.y + y/self.wrapping
    
    self:generate(self.nPower, self.dist, self.wrapping, self.str)
    self:colour(self.Red,self.Green,self.Blue)
end

function Model:draw()
    self.mesh:draw()
end


function setup()
    
    
    
    parameter.integer("quality", 1, 4, 3)
    
    
    parameter.integer("str", 0, 2048, 512)
    
    
    parameter.integer("nPower", 10, 200, 100)
    
    
    parameter.number("wrapping", 1, 20, 4)
    
    -- distance from camera
    parameter.integer("dist", 256, 2048, 512)
    
    parameter.integer("wireframe", 0, 1, 0)
    
    
    parameter.number("Red", 0, 1, 1)
    parameter.number("Green", 0, 1, 0.3)
    parameter.number("Blue", 0, 1, 0.2)
    local w = 64
    wire = image(w,w)
    setContext(wire)
    pushStyle()
    resetStyle()
    strokeWidth(2)
    noSmooth()
    stroke(255, 255, 255, 255)
    fill(255, 204, 0, 134)
    rect(1,1,w,w)
    strokeWidth(4)
    line(1,1,w,w)
    popStyle()
    setContext()
    model = Model(
    quality, 
    nPower, 
    dist, 
    wrapping, 
    str,
    Red,
    Green,
    Blue,
    wireframe,
    wire
    )
    fps = {}
    fpsn = 100
    for i = 1,fpsn do
        fps[i] = 60
    end
    fpsi = 1
end

function draw()
    background(0, 0, 0, 255)
    fps[fpsi] = 1/DeltaTime
    local tfps = 0
    for i = 1,fpsn do
        tfps = tfps + fps[i]
    end
    fpsi = fpsi%fpsn + 1
    textMode(CORNER)
    text("FPS: "..math.floor(1/DeltaTime*10)/10, WIDTH - 200, HEIGHT - 30)
    text("FPS: "..math.floor(tfps/fpsn*10)/10, WIDTH - 200, HEIGHT - 60)
    text("Vertices: "..model.numver, WIDTH - 200, HEIGHT - 90)
    text("Double tap for Fullscreen", WIDTH/2, 30)
    
    model:update(
    quality, 
    nPower, 
    dist, 
    wrapping, 
    str,
    Red,
    Green,
    Blue,
    wireframe
    )
    
    model:draw()
end

function touched(touch)
    
    if touch.state == BEGAN and touch.tapCount == 2 then
        if fullscreen then
            displayMode(STANDARD)
            fullscreen = false
        else
            displayMode(FULLSCREEN)
            fullscreen = true
        end
        model:update()
    else
        model:shift(touch.deltaX,touch.deltaY)
    end
    
end

