-- Yojimbo2000Mesh

--# Main
-- 2D Mesh Profiling

function setup()
    shapePrototypes()
    methods = {Box, Tri, Pent, Box2, Box3}
    parameter.integer("number",200,5000,1000)
    parameter.integer("method", 1,3,2)
    parameter.action("INITIALISE", initialise)
    parameter.action("Count cache size", traverseCache) --counts size of pentagon cache (check cache is wirking)
    profiler.init(true)
    for i=1,#methods do
        print("Method "..i..": "..methods[i].doc)
    end
    initialise()
end

function draw()
    background(40, 40, 50)
    for i=1, #object do
        object[i]:draw()
    end
    Box.mesh:draw() --just one draw operation with rectangle method
    profiler.draw()
    
end

function initialise()
    object={}
    Box.mesh:clear()
    collectgarbage()
    for i=1,number do
        object[i]=methods[method]()
    end
end

profiler={}

function profiler.init(monitor)    
    profiler.del=0
    profiler.c=0
    profiler.fps=0
    profiler.mem=0
    if monitor then
        parameter.watch("profiler.fps")
        parameter.watch("profiler.mem")
    end
end

function profiler.draw()
    profiler.del = profiler.del +  DeltaTime
    profiler.c = profiler.c + 1
    if profiler.c==10 then
        profiler.fps=profiler.c/profiler.del
        profiler.del=0
        profiler.c=0
        profiler.mem=collectgarbage("count", 2)
    end
end

function math.round(number, places) --use -ve places to round to tens, hundreds etc
    local mult = 10^(places or 0)
    return math.floor(number * mult + 0.5) / mult
end
--# Box
Box = class()
Box.doc = "The objects are drawn as rectangles on a single mesh using setRect. No translation used"

local size=20
Box.mesh=mesh()
Box.mesh.texture=readImage("Platformer Art:Block Brick")

function Box:init()
    self.pos = vec2(math.random(WIDTH),math.random(HEIGHT))
    self.angle = math.random()*360
    self.vel = vec2(math.random(11)-6,math.random(11)-6)
    self.angleVel=(math.random()-0.5)
    self.col=color(math.random(255), math.random(255), math.random(255))
    self:add(self.pos, self.angle)   
end

function Box:draw() --nb no need for translate or rotate
    self:move()
    self.mesh:setRect(self.rect, self.pos.x, self.pos.y, size, size, math.rad(self.angle))
end

function Box:move()
    self.pos = self.pos + self.vel
    if self.pos.x > WIDTH + size then self.pos.x = - size
    elseif self.pos.x < - size then self.pos.x = WIDTH + size
    end
    if self.pos.y > HEIGHT + size then self.pos.y = - size
    elseif self.pos.y < - size then self.pos.y = HEIGHT + size
    end
    self.angle = self.angle + self.angleVel
end

function Box:add(pos,ang)
    self.rect=self.mesh:addRect(pos.x,pos.y,size,size,math.rad(ang))
    self.mesh:setRectTex(self.rect,0,0,1,1)
    self.mesh:setRectColor(self.rect, self.col)
end

--# Tri
Tri = class(Box) --inherits methods from Box
Tri.doc = "The objects are drawn as triangles on a single mesh using setTri. No translation used"

local size=10
local size2=20

function Tri:draw() 
    self:move()
    setTri(self.rect, Box.mesh, self.pos.x, self.pos.y, size, size2, self.angle)
end

function Tri:add(pos,ang)
    self.rect=addTri(Box.mesh, pos.x,pos.y,size,size2,ang, self.col)
end

--# Pent
Pent = class(Box) --inherits methods from Box
Pent.doc = "The objects are drawn as pentagons on a single mesh using setShape. No translation used"

local size=14

function Pent:draw() 
    self:move()
    setShape(self.rect, Box.mesh, pentagon, self.pos.x, self.pos.y, size, size, self.angle)
end

function Pent:add(pos,ang)
    self.rect=addShape(Box.mesh, pentagon, pos.x,pos.y,size,size,ang, self.col)
end

--# AddShape
--ADD SHAPE
--Pack a large number of shapes onto a single mesh. Similar syntax to addRect and setRect.
local triangle={}
triangle.cache = {} --caches same shaped/sized triangles. 

--Add tri, set tri (slightly redundant, see shape commands below)

function addTri(m,x,y,w,h,r,col) --mesh, x, y, width, height, [rotation(in radians), color]
    local id=#m.vertices
    m:resize(id+3)
    local col = col or color(255)
    local d = math.ceil((r%360)*2) --cached in half-degree increments
    if triangle.cache[d] then --if cached
        for i=1,3 do
            m:vertex(id+i, triangle.cache[d][i].x+x, triangle.cache[d][i].y+y) --use cache
            m:texCoord(id+i, triangle.texCoords[i])
            m:color(id+i, col)
        end
    else
        local mat = rotMat(w,h,r) --generate a matrix for this transform
        triangle.cache[d]={}
        for i=1, 3 do
            --  local pos = vec2(triangle.vertices[i].x*w, triangle.vertices[i].y*h) --:rotate(r)
            --  m:vertex(id+i, pos.x+x, pos.y+y)
            local rx, ry = vecMat(triangle.vertices[i], mat)
            triangle.cache[d][i]={x=rx, y=ry} --cache the rotation
            m:vertex(id+i, rx+x, ry+y)
            m:texCoord(id+i, triangle.texCoords[i])
            m:color(id+i, col)
        end
    end
    return id --returns shape id number
end

function setTri(id,m,x,y,w,h,r) --shape id number, mesh, x, y, width, height, [rotation(in radians)]
    local d = math.ceil((r%360)*2)
    if triangle.cache[d] then
        for i=1, 3 do
            m:vertex(id+i, triangle.cache[d][i].x+x, triangle.cache[d][i].y+y)
        end
    else
        local mat = rotMat(w,h,r)
        triangle.cache[d]={}
        for i=1, 3 do
            --local pos = vec2(triangle.vertices[i].x*w, triangle.vertices[i].y*h):rotate(r)
            --  m:vertex(id+i, pos.x+x, pos.y+y)
            local rx, ry = vecMat(triangle.vertices[i], mat)
            m:vertex(id+i, rx+x, ry+y)
            triangle.cache[d][i]={x=rx, y=ry}
        end
    end
end

function vecMat(vec, mat) --rotate vector by current transform. 
    return mat[1]*vec.x + mat[3]*vec.y, mat[2]*vec.x + mat[4]*vec.y
end

function rotMat(w,h,r) --returns a 3x2 matrix, rotated by r, scaled by w,h
    local d = math.rad(r)
    local rx, ry =  math.cos(d), math.sin(d) --cosLUT[r], sinLUT[r] 
    return {rx*w,ry*w,
    -ry*h,rx*h}
end

--GENERIC SHAPE FUNCTIONS. nb requires that the shape prototype tables (triangle etc) be exposed as global variables

function addShape(m,sh,x,y,w,h,r,col) --mesh, shapePrototype table, x, y, width, height, [rotation(radians), color]
    local id=#m.vertices
    local n=#sh.vertices
    m:resize(id+n)
    local col = col or color(255)
    local d = math.ceil((r%360)*2)
    if sh.cache[d] then
        for i=1, n do
            m:vertex(id+i, sh.cache[d][i].x+x, sh.cache[d][i].y+y)
            m:texCoord(id+i, sh.texCoords[i])
            m:color(id+i, col)
        end
    else
        local mat = rotMat(w,h,r)
        sh.cache[d]={}
        
        for i=1, n do       
            -- local pos = vec2(sh.vertices[i].x*w, sh.vertices[i].y*h):rotate(r)
            local rx, ry = vecMat(sh.vertices[i], mat)
            m:vertex(id+i, rx+x, ry+y)
            sh.cache[d][i]={x=rx, y=ry}
            --  m:vertex(id+i, vecMat(sh.vertices[i], mat))
            m:texCoord(id+i, sh.texCoords[i])
            m:color(id+i, col)
        end
    end
    return id --returns shape id number
end

function setShape(id,m,sh,x,y,w,h,r) --shapeIdNumber, mesh, shapePrototype table, x, y, width, height, [rotation(radians)]
    local n=#sh.vertices
    local d = math.ceil((r%360)*2)
    if sh.cache[d] then
        for i=1, n do
            m:vertex(id+i, sh.cache[d][i].x+x, sh.cache[d][i].y+y)
        end
    else
        local mat = rotMat(w,h,r)
        sh.cache[d]={}
        for i=1, n do
            -- local pos = vec2(sh.vertices[i].x*w, sh.vertices[i].y*h):rotate(r)
            --  m:vertex(id+i, pos.x+x, pos.y+y)
            local rx, ry = vecMat(sh.vertices[i], mat)
            m:vertex(id+i, rx+x, ry+y)
            sh.cache[d][i]={x=rx, y=ry}
            --  m:texCoords(id+i, sh.texCoords[i])
            -- m:color(id+i, col)
        end
    end
end

-- Generate verts, texCoords for triangle

function shapePoints(s)
    local ang = (math.pi*2)/s
    local p={} --unique points
    local t={} --unique texCoords
    for i=1,s do
        p[i]=vec2(math.sin(ang*i), math.cos(ang*i))
        t[i]=(p[i]*0.5)+vec2(0.5,0.5)
    end
    return p,t
end

triangle.vertices, triangle.texCoords = shapePoints(3)

function triangulatePoints(p,t) --takes a set of unique points and texCoords, returns triangulated points and texCoords
    local u={} --table of unique points, indexed by x and y
    for i,v in ipairs(p) do
        local x = math.round(v.x,6) --round the coords to ensure consistency with look-up
        local y = math.round(v.y,6)
        if not u[x] then u[x]={} end
        u[x][y]=t[i] --index texCoords by their rounded x and y
    end
    local verts = triangulate(p)
    local texCoords = {}
    for i,v in ipairs(verts) do
        local x = math.round(v.x,6)
        local y = math.round(v.y,6)
        texCoords[i]=u[x][y] --look up texCoords by their triangulated position
    end
    return verts, texCoords
end

function shapePrototypes()
    pentagon = {}
    pentagon.vertices, pentagon.texCoords = triangulatePoints(shapePoints(5))
    pentagon.cache = {}
end

function traverseCache()
    local count = 0
    for k,_ in pairs(pentagon.cache) do
        count = count + 1
    end
    print (count)
end