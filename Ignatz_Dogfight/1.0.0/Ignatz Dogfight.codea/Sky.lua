
displayMode(FULLSCREEN)
supportedOrientations(LANDSCAPE_ANY)
  
function SetupSky()
    img1=readImage(asset.SkyDome1)
    img2=image(img1.width,img1.width/2)
    setContext(img2)
    spriteMode(CORNER)
    sprite(img1,0,img2.height-img1.height)
    sprite(img1,0,img2.height-img1.height-img1.height)
    setContext()

    local color1 = color(255, 255, 255, 255)
    --this sphere code comes from Jmv38, see bottom
    planet1 = Sphere({  
                    nx = 40, ny = 20 ,            -- mesh definition
                    meshOptimize = true,           -- optimize mesh for sphere
                    c1 = color1 , c2 = color1 ,    -- mesh colors
                    cx=0, cy=0, cz=0  ,         -- sphere center    
                    r = 1500   ,         -- radius of the sphere
                    rotTime1 = 20 ,   -- rotation time in s              
                    hflip = true,    -- to flip image horozontally
                  })
    cam = vec3(0, 50, 300)
    planet1.ms.texture=img2
    --parameter.number("FPS",0,60,60)
end

--the code below comes from Jmv38, who explains it here
--http://jmv38.comze.com/CODEAbis/server.php (look for 3D tutorial)

Sphere = class()

function Sphere:init(input)
    -- spatial position of sphere
    self.cx = input.cx or 0
    self.cy = input.cy or 0
    self.cz = input.cz or 0
    -- angular position of sphere, defined by angles around x,y,z axis
    self.ax = 0
    self.ay = 0
    self.az = 0
    -- sphere radius and rotation
    self.radius = input.r
    self.tRot = input.rotTime1
    -- sphere rotation 2
    self.tRot2 = input.rotTime2
    self.cx2 = input.cx2 or 0   -- center of rotation 2
    self.cy2 = input.cy2 or 0
    self.cz2 = input.cz2 or 0
    self.ax2 = input.ax2 or 0   -- axis of rotation 2
    self.ay2 = input.ay2 or 1
    self.az2 = input.az2 or 0
    -- mesh definition
    self.nx = input.nx    -- number of triangles in x
    self.ny = input.ny    -- and in y
    self.c1 = input.c1    -- 2 color() objects, to see the triangles
    self.c2 = input.c2
    self.optimized = input.meshOptimize    -- boolean
    -- sphere decoration
    self.url = input.url    -- texture as a url (text)
    self.hflip = input.hflip    -- to flip image horizontally
    if input.lightDir then
        self.lightDir = input.lightDir:normalize()   -- a vec3 pointing to the sun
    end
    self.shadowRatio = input.shadowRatio or 1.05   -- close to 1.05
    
    -- create mesh and colors
    local vertices,colors,tc = {},{},{}
    if self.optimized then
        vertices,colors,tc = self:optimMesh({ nx=self.nx, ny=self.ny, c1=self.c1, c2=self.c2 })
    else
        vertices,colors,tc = self:simpleMesh({ nx=self.nx, ny=self.ny, c1=self.c1, c2=self.c2 })
    end

    -- if a radius is given, warp to a sphere
    if self.radius then 
    vertices = self:warpVertices({
            verts=vertices, 
            xangle=180, 
            yangle=180 
        }) end

    -- create the mesh itself
    self.ms = mesh()
    self.ms.vertices = vertices
    self.ms.colors = colors
    
    -- add the texture from internet
    --if self.url then 
    --    self:load( self.url ) -- this will not be instantaneous!
    --end
    self.ms.texture = self.url
    self.ms.texCoords = tc
    
    -- add some shadows
    if self.lightDir then self:shadows() end

end

function Sphere:shadows()
        self.ms2 = mesh()
        local dir = self.lightDir
        local vertices2,colors2 = {},{}
        local d = 0
        for i,v in ipairs(self.ms.vertices) do
            vertices2[i] = v
            d = v:dot(dir)
            d = 128 - 4*(d-0.1)*128
            if d<0 then d=0 end
            if d>255 then d=255 end
            colors2[i] = color(0,0,0,d)
        end
        self.ms2.vertices = vertices2
        self.ms2.colors = colors2
end

function Sphere:simpleMesh(input)
    -- create the mesh tables
    local vertices = {}
    local colors = {}
    local texCoords = {}
    --local w,h = img.width/10, img.height/10
    local k = 0
    local s = 1
    -- create a rectangular set of triangles
    local x,y
    local nx,ny = input.nx,input.ny
    local opt = input.opt
    local sx, sy = 1/ny, 1/ny
    local color1 = input.c1
    local color2 = input.c2
    local center = vec3(1,0.5,0)
    for y=0,ny-1 do
      for x=0,nx-1 do
        vertices[k+1] = vec3( sx*x    , sy*y    , 1) - center
        vertices[k+2] = vec3( sx*(x+1), sy*y    , 1) - center
        vertices[k+3] = vec3( sx*(x+1), sy*(y+1), 1) - center 
        vertices[k+4] = vec3( sx*x    , sy*y    , 1) - center 
        vertices[k+5] = vec3( sx*x    , sy*(y+1), 1) - center 
        vertices[k+6] = vec3( sx*(x+1), sy*(y+1), 1) - center 
        colors[k+1] = color1 
        colors[k+2] = color1 
        colors[k+3] = color1 
        colors[k+4] = color2 
        colors[k+5] = color2 
        colors[k+6] = color2 
        k = k + 6    
      end
    end   
    return vertices,colors
end

function Sphere:optimMesh(input)
    -- create the mesh tables
    local vertices = {}
    local colors = {}
    local texCoords = {}
    --local w,h = img.width/10, img.height/10
    local k = 0
    local s = 1
    -- create a set of triangles with approx constant surface on a sphere
    local x,y
    local x1,x2 = {},{}
    local i1,i2 = 0,0
    local nx,ny = input.nx,input.ny
    local sx, sy = nx/ny, 1/ny
    local color1 = input.c1
    local color2 = input.c2
    local center = vec3(1,0.5,0)
    local m1,m2,c
    local flip = 1
    if self.hflip then flip=-1 end
    for y=0,ny-1 do -- for each horizontal band
        -- number of points on each side of the band
        local nx1 = math.floor( nx * math.abs(math.cos(    ( y*sy-0.5)*2 * math.pi/2)) )
        if nx1<6 then nx1=6 end
        local nx2 = math.floor( nx * math.abs(math.cos( ((y+1)*sy-0.5)*2 * math.pi/2)) ) 
        if nx2<6 then nx2=6 end
        -- points on each side of the band
        x1,x2 = {},{}
        for i1 = 1,nx1 do x1[i1] = (i1-1)/(nx1-1)*sx end
        for i2 = 1,nx2 do x2[i2] = (i2-1)/(nx2-1)*sx end
        x1[nx1+1] = x1[nx1] -- just a trick to manage last triangle without thinking
        x2[nx2+1] = x2[nx2]
        -- start on the left
        local i1,i2 = 1,1
        c = 1    -- starting color
        local continue = true
        local n,nMax = 0,0
        nMax = nx*2+1
        while continue do
            -- center of the 2 current segments
            m1 = (x1[i1]+x1[i1+1])/2
            m2 = (x2[i2]+x2[i2+1])/2
            if m1<=m2 then -- the less advanced base makes the triangle
        vertices[k+1] = vec3(   x1[i1], sy*y    , 1)  - center
        vertices[k+2] = vec3( x1[i1+1], sy*y    , 1)  - center
        vertices[k+3] = vec3(   x2[i2], sy*(y+1), 1)  - center
        texCoords[k+1] = vec2(   x1[i1]/2*flip, sy*y    ) 
        texCoords[k+2] = vec2( x1[i1+1]/2*flip, sy*y    )
        texCoords[k+3] = vec2(   x2[i2]/2*flip, sy*(y+1))
        if i1<nx1 then i1 = i1 +1 end
            else
        vertices[k+1] = vec3(   x1[i1], sy*y    , 1) - center
        vertices[k+2] = vec3(   x2[i2], sy*(y+1), 1) - center
        vertices[k+3] = vec3( x2[i2+1], sy*(y+1), 1) - center
        texCoords[k+1] = vec2(   x1[i1]/2*flip, sy*y    )
        texCoords[k+2] = vec2(   x2[i2]/2*flip, sy*(y+1))
        texCoords[k+3] = vec2( x2[i2+1]/2*flip, sy*(y+1))
        if i2<nx2 then i2 = i2 +1 end        
            end
            -- set the triangle color
            if c==1 then col=color1 else col=color2 end
        colors[k+1] = col
        colors[k+2] = col
        colors[k+3] = col
            if c==1 then c=2 else c=1 end
            if i1==nx1 and i2==nx2 then continue=false end
        -- increment index for next triangle
        k = k + 3
        n = n + 1
        if n>nMax then continue=false  end -- just in case of infinite loop
        end
    end   
    return vertices,colors,texCoords
end


function Sphere:warpVertices(input)
    -- move each vector to its position on sphere
    local verts = input.verts
    local xangle = input.xangle
    local yangle = input.yangle
    local s = self.radius
    local m = matrix(0,0,0,0, 0,0,0,0, 1,0,0,0, 0,0,0,0) -- empty matrix
    local vx,vy,vz,vm        
    for i,v in ipairs(verts) do
        vx,vy = v[1], v[2]
        vm = m:rotate(xangle*vy,1,0,0):rotate(yangle*vx,0,1,0)
        vx,vy,vz = vm[1],vm[5],vm[9]
        verts[i] = vec3(vx,vy,vz)
    end    
    return verts
end

function Sphere:draw(cx)
    pushMatrix()
    --translate(self.cx,self.cy,self.cz)
    if self.radius then s = self.radius else s = 100 end
    scale(s,s,s)
    self.ms:draw()  
    popMatrix()    
end
