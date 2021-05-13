-- Terrain

--[[
I started a project on terrains with the idea of small triangles near the camera, and then bigger triangles further away where less detail was required and driving the terrain from a heightfield.
It got very messy...

So I restarted heavily influenced by:
http://galfar.vevb.net/wp/2013/android-terrain-rendering-vertex-texture-fetch-part-1/
In fact I got my shaders from there (although they've been modified a little since).
Once I had the shader I proved I could draw a mesh and heightField texture it.

Then I found http://www.shamusyoung.com/twentysidedtale/?p=146 which talked about precooking lighting into a texture from a heightfield.  So I did that.

So I got it drawing a big layer of quads (all the same size at the mo) with the above texturing and it was good, but very slow.

So I looked on the web and found frustum culling, got that code and did sphere based culling, it was better, but still slow.
http://www.flipcode.com/archives/Frustum_Culling.shtml
http://zach.in.tu-clausthal.de/teaching/cg1_0607/literatur/lighthouse3d_view_frustum_culling/index.html

Then I figured out the quad thing
http://www.gamedev.net/page/resources/_/technical/graphics-programming-and-theory/quadtrees-r1303

It was now culling quick, but still using my smallest quads across the board.  Added distance based lod (level of detail) so it did small quads close and bigger quads far away.  Performance was now good, but the terrain ended up with holes on the edges where lod was different between quads.

Went back to the original android terrain article, (and the shader already had the meat of this) and sorted out adjustments for the shader to fix the boudaries.  The C++ implementation for the article performed bad in lua so adjusted it a bit.
]]

--at the moment we just draw it all... 
    --step one frustrum culling... probably take a simple bounding sphere
    --http://www.flipcode.com/archives/Frustum_Culling.shtml
    --http://zach.in.tu-clausthal.de/teaching/cg1_0607/literatur/lighthouse3d_view_frustum_culling/index.html
    
    --for the future quad tree for frustrum culling 
    --http://www.gamedev.net/page/resources/_/technical/graphics-programming-and-theory/quadtrees-r1303
    --and dynamic lodding thing from http://galfar.vevb.net/wp/2013/android-terrain-rendering-vertex-texture-fetch-part-1/
    --tile bounding sphere info... the tileRadius and position adjustment could be pre calced for a given size



-- Use this function to perform your initial setup
function setup()
    displayMode(FULLSCREEN)
    
 --   heights = readImage("Dropbox:terrain_map6")
    heights = readImage(asset.builtin.Surfaces.Desert_Cliff_Height)
    --cook a lighting / colouring map from the heights, inspired by http://www.shamusyoung.com/twentysidedtale/?p=147
    
    m2=mesh()
    m2:addRect(512,512,1024,1024)
    
    m2.texture = heights
    m2.shader = shader(LightChef.Vertex, LightChef.Fragment)
    m2.shader.heightSampleScale = 0.05/8
    m2.shader.resStep = 1/1024
    m2.shader.sunAngle = .2/1024
    lightMap = image(1024,1024)
    
    setContext(lightMap)
    m2:draw()
    
    setContext()
    m2 = nil
    collectgarbage()
    
    --build up a mesh for my terrain tiles
    m = mesh()
    v = {}
    --the coordinate space by default of the mesh
    coordSize = 4
    --tileSize is number of squares to break the mesh into... higher number is smoother but slower
    tileSize = 8
    lodFactor = tileSize / 4
    
    tileWidth = coordSize / tileSize
    
    for x=0, tileSize-1 do
        for y=0, tileSize-1 do
            
            buildTriangles(v, x * tileWidth, y * tileWidth, tileWidth)
        end
    end
    
    m.vertices = v
    
    --colors are only used if running it in show wireframes mode by uncommenting #define DRAW_EDGES in te vertex and fragment shader in TerrainShader tab
    set_wireframe_colors(m)
        
    --setup the main shader
    m.shader = shader(TerrainShader.vertex, TerrainShader.fragment)
    
    m.shader.tileSize = coordSize
    m.shader.nodeScale = 1   --scales the x/z size against coordinates
    m.shader.nodePos = vec2(0,0) --offset the position of this tile
    m.shader.heightSampleScale = .05 --how much to scale heights against
    m.shader.lodScales = vec4(.5,1,2,4) --whether the adjcent tiles are the same scale
    m.shader.terrainSize = 8
    m.shader.texHeight = heights --heightmap
   
    m.shader.texLight = lightMap --light and color map
    
    --clear out the images we loaded to clear some memory
    heights = nil
    lightMap = nil
    collectgarbage()
    
    --for metrics
    elapsedTimeMem = ElapsedTime
    FPS = 0
    elapsedTimeFPS = ElapsedTime
    memory = 0
    msg = ""
    
    
    --set up a quad for culling
    --1, 2, 4, 8, 16, 32, 64, 128, 256 --8 levels
    --lodLookup is an array to find the neighbouring quad when fixing boundaries at different scales
    lodLookup={}
    
    --it'll keep breaking quads into 4 (halving scale) until starting scale (256) reaches maxDepth
    maxDepth = 1
    --newQuad works recursively, this is the top quad covering the full scale*coordsize area (256*4) with an initial model coordinate (-128.5*4) and a notional quad coordinate of 1,1
    terrainQuad = newQuad(vec2(1,1), vec2(-128.5*4,-128.5*4) , 256)
    
    --for the camera
    camPos = vec2(4,0)
    lookDir = vec2(0,4)
    --not used at current, idea was to lean the camera into turns
    sideLean = 0
    
    --initialise extra metrics
    drawn = 0
    frusChecks = 0
end

--recursive function for building up our quad tree for efficient culling and lod
function newQuad(quadCoord, pos, scale)
    --create this quad, it needs a quad coordinate for lodding, a model coordinate for drawing, a mid point and radius for sphere based frustum culling, the scale, and a used flag for runtime 
    local thisQuad = {coord = quadCoord, loc = pos, mid = vec3(pos.x + (coordSize * scale/2), (36 * .05/2), pos.y + (coordSize * scale/2)), radius = math.sqrt(((coordSize * scale / 2)^2*2) + (36 * .05/2)^2), scale = scale, used = false }
    --if we haven't reached the "bottom" then recurse in the 4 sub quads and make the current quad their parent
    if scale > maxDepth then
        thisQuad.subQuads = {}
        thisQuad.subQuads[1] = newQuad(quadCoord, vec2(pos.x, pos.y), scale/2)
        thisQuad.subQuads[1].parent = thisQuad
        thisQuad.subQuads[2] = newQuad(quadCoord+vec2(scale/2,0), vec2(pos.x+(coordSize*scale/2), pos.y), scale/2)
        thisQuad.subQuads[2].parent = thisQuad
        thisQuad.subQuads[3] = newQuad(quadCoord+vec2(0,scale/2), vec2(pos.x, pos.y+(coordSize*scale/2)), scale/2)
        thisQuad.subQuads[3].parent = thisQuad
        thisQuad.subQuads[4] = newQuad(quadCoord+vec2(scale/2,scale/2), vec2(pos.x+(coordSize*scale/2), pos.y+(coordSize*scale/2)), scale/2)
        thisQuad.subQuads[4].parent = thisQuad
    end
    --we also need to add the current quad to our lodLookup for lod neighbour checking, extra ifs to make sure the data structure is initialised at each step
    if lodLookup[scale] == nil then
        lodLookup[scale] = {}
    end
    if lodLookup[scale][quadCoord.x] == nil then
        lodLookup[scale][quadCoord.x] = {}
    end
    lodLookup[scale][quadCoord.x][quadCoord.y] = thisQuad
    return thisQuad
end

--adds a square divided into 8 triangles to a mesh
function buildTriangles(v, x, z, w)
    table.insert(v, vec3(x,0,z))
    table.insert(v, vec3(x+w/2,0,z))
    table.insert(v, vec3(x+w/2,0,z+w/2))  
        
    table.insert(v, vec3(x+w/2,0,z))
    table.insert(v, vec3(x+w,0,z))
    table.insert(v, vec3(x+w/2,0,z+w/2))  
    
    table.insert(v, vec3(x+w,0,z))
    table.insert(v, vec3(x+w,0,z+w/2))
    table.insert(v, vec3(x+w/2,0,z+w/2))  
        
    table.insert(v, vec3(x+w,0,z+w/2))
    table.insert(v, vec3(x+w,0,z+w))
    table.insert(v, vec3(x+w/2,0,z+w/2))  
    
    table.insert(v, vec3(x+w,0,z+w))
    table.insert(v, vec3(x+w/2,0,z+w))
    table.insert(v, vec3(x+w/2,0,z+w/2))  
        
    table.insert(v, vec3(x+w/2,0,z+w))
    table.insert(v, vec3(x,0,z+w))
    table.insert(v, vec3(x+w/2,0,z+w/2))  
    
    table.insert(v, vec3(x,0,z+w))
    table.insert(v, vec3(x,0,z+w/2))
    table.insert(v, vec3(x+w/2,0,z+w/2))  
        
    table.insert(v, vec3(x,0,z+w/2))
    table.insert(v, vec3(x,0,z))
    table.insert(v, vec3(x+w/2,0,z+w/2))  
    
end

-- This function gets called once every frame
function draw()
    --some rough touch handling so we can drive around the terrain based on touch near the centre of the screen
    if CurrentTouch.state < 2 then
        dir = vec2(WIDTH/2-CurrentTouch.x, HEIGHT/2-CurrentTouch.y)
        --touch to the side of middle rotates the view
        lookDir = lookDir:rotate(-0.05 * dir.x/(WIDTH/2)*DeltaTime*60)
        --touch up or down of middle moves forwards/backwards
        camPos = camPos - lookDir *.02 * dir.y/(HEIGHT/2) *DeltaTime*60
        --attempt to do leaning, but disabled as I couldn't make the camera work right
        sideLean = sideLean + 0.00002 * dir.x
    end
    
    background(40, 40, 50)
    --display some metrics (FPS, memory, quads drawn and frustum checks performed)
    metrics()
    
    perspective()
    camera(camPos.x,1.5,camPos.y,camPos.x+lookDir.x,0,camPos.y+lookDir.y,0,1,0)
    --switching in the following camera gives a top down view useful for checking lodding in wireframe more
    --camera(coordSize/2 ,20,coordSize/2,coordSize/2,0,coordSize/2)
    
    --create our variables to express the frustum planes
    setupFrustum()
    --clear the metrics
    drawn = 0
    frusChecks = 0
    
    --create an empty queue for the drawing cycle
    quadQueue = {}
    
    --evaluate the quads from the top level, this is a recursive function
    --it will perform culling and lod calculations and populate the quadqueue with the quads to be drawn
    evaluateQuad(terrainQuad)

    --process the quadqueue and draw each one.  this has to be done after the full evaluation so lod adjustments work
    for k,v in pairs(quadQueue) do
        --we need a lods array to feed to the shader.  basically .5 means neighbour is same scale
        --1 is double scale, 2 4x etc
        --in the shader this messes with the triangles on the edge so the edge is lower red and you don't get gaps
        lods = vec4(.5,.5,.5,.5)
        lods.y = checkNeighbourLod(v.coord.x, v.coord.y-v.scale, v.scale)
        lods.x = checkNeighbourLod(v.coord.x-v.scale, v.coord.y, v.scale)
        lods.w = checkNeighbourLod(v.coord.x, v.coord.y+v.scale, v.scale)
        lods.z = checkNeighbourLod(v.coord.x+v.scale, v.coord.y, v.scale)
        --actually draw it
        drawTile(v.scale, v.loc, lods)
    end
    
    --flatten side lean over time. unused
    sideLean = sideLean * 0.9
end

--This will determine what scaling the neighbouring quads are
--the initial approach (off the web) was a massive array, but array performance in lua is bad
--so it now does a lookup for the neighbouring tile, then uses the quad tree
function checkNeighbourLod(x,y, scale)
    if x > 0 and y > 0 and x < 257 and y < 257 then
        base = .5
        --get the neighbouring quad at the current scale
        cquad = lodLookup[scale][x][y]
        while (cquad.parent ~= nil) do
            --now step up the quad tree and if it's used, that's the one
            --it could be used at multiple levels from previous frames, but the highest
            --up the heirarchy will be the one from this frame
            cquad = cquad.parent
            if cquad.used == true then
                base = cquad.scale/scale/2
            end
        end
        return base
    end
    return .5
end

--this evaluates the quad recursively to see if it needs to be drawn
function evaluateQuad(quad)
    --if the quad isn't in the view frustum based on a sphere around it, then we are done
    if isSphereInFrustum(quad.mid, quad.radius) then
        --we are in view, get the distance from the camera to the middle of the quad
        dist = quad.mid - vec3(camPos.x, 1.5, camPos.y)
        --now if we are the bottom of our quad tree, or the quad is far from the camera then use it
        --the distance from camera piece says basically use a large one if it's far away to save on drawing, as it's far away and you won't see extra triangles anyway
        if quad.scale > maxDepth and quad.scale/(dist:len()+quad.radius/1.7) > 0.13 then 
            --it's big or too close for it's scale, so go down the next level
            quad.used = false
            evaluateQuad(quad.subQuads[1])
            evaluateQuad(quad.subQuads[2])
            evaluateQuad(quad.subQuads[3])
            evaluateQuad(quad.subQuads[4])
        else
            --we are going to draw this one
            --record we used it for lod lookups
            quad.used = true
            --put it in our drawing queue
            table.insert(quadQueue, quad)
            --increment our metric for number of quads drawn
            drawn=drawn+1
        end
    end
end

--this creates a set of variables representing the planes surrounding the frustum
--it bases it off the modelViewProjection matrix, and the rest of it I found on the web
function setupFrustum()
   clip = modelMatrix() * viewMatrix() * projectionMatrix()
   frustum = {}
    --/* Extract the numbers for the RIGHT plane */
   frustum[0] = {}
   frustum[0][0] = clip[ 4] - clip[ 1]
   frustum[0][1] = clip[ 8] - clip[ 5]
   frustum[0][2] = clip[12] - clip[ 9]
   frustum[0][3] = clip[16] - clip[13]
 --/* Normalize the result */
   t = math.sqrt( frustum[0][0] * frustum[0][0] + frustum[0][1] * frustum[0][1] + frustum[0][2]    * frustum[0][2] )
   frustum[0][0] = frustum[0][0] / t
   frustum[0][1] = frustum[0][1] / t
   frustum[0][2] = frustum[0][2] / t
   frustum[0][3] = frustum[0][3] / t
 --/* Extract the numbers for the LEFT plane */
   frustum[1] = {}
   frustum[1][0] = clip[ 4] + clip[ 1]
   frustum[1][1] = clip[ 8] + clip[ 5]
   frustum[1][2] = clip[12] + clip[ 9]
   frustum[1][3] = clip[16] + clip[13]
 --/* Normalize the result */
   t = math.sqrt( frustum[1][0] * frustum[1][0] + frustum[1][1] * frustum[1][1] + frustum[1][2]    * frustum[1][2] )
   frustum[1][0] = frustum[1][0] / t
   frustum[1][1] = frustum[1][1] / t
   frustum[1][2] = frustum[1][2] / t
   frustum[1][3] = frustum[1][3] / t
 --/* Extract the BOTTOM plane */
   frustum[2] = {}
   frustum[2][0] = clip[ 4] + clip[ 2];
   frustum[2][1] = clip[ 8] + clip[ 6];
   frustum[2][2] = clip[12] + clip[ 10];
   frustum[2][3] = clip[16] + clip[14];
 --/* Normalize the result */
   t = math.sqrt( frustum[2][0] * frustum[2][0] + frustum[2][1] * frustum[2][1] + frustum[2][2]    * frustum[2][2] )
   frustum[2][0] = frustum[2][0] / t
   frustum[2][1] = frustum[2][1] / t
   frustum[2][2] = frustum[2][2] / t
   frustum[2][3] = frustum[2][3] / t
 --/* Extract the TOP plane */
   frustum[3] = {}
   frustum[3][0] = clip[ 4] - clip[ 2];
   frustum[3][1] = clip[ 8] - clip[ 6];
   frustum[3][2] = clip[12] - clip[ 10];
   frustum[3][3] = clip[16] - clip[14];
 --/* Normalize the result */
   t = math.sqrt( frustum[3][0] * frustum[3][0] + frustum[3][1] * frustum[3][1] + frustum[3][2]    * frustum[3][2] )
   frustum[3][0] = frustum[3][0] / t
   frustum[3][1] = frustum[3][1] / t
   frustum[3][2] = frustum[3][2] / t
   frustum[3][3] = frustum[3][3] / t
 --/* Extract the FAR plane */
   frustum[4] = {}
   frustum[4][0] = clip[ 4] - clip[ 3];
   frustum[4][1] = clip[ 8] - clip[ 7];
   frustum[4][2] = clip[12] - clip[11];
   frustum[4][3] = clip[16] - clip[15];
 --/* Normalize the result */
 t = math.sqrt( frustum[4][0] * frustum[4][0] + frustum[4][1] * frustum[4][1] + frustum[4][2]    * frustum[4][2] )
   frustum[4][0] = frustum[4][0] / t
   frustum[4][1] = frustum[4][1] / t
   frustum[4][2] = frustum[4][2] / t
   frustum[4][3] = frustum[4][3] / t
 --/* Extract the NEAR plane */
   frustum[5] = {}
   frustum[5][0] = clip[ 4] + clip[ 3];
   frustum[5][1] = clip[ 8] + clip[ 7];
   frustum[5][2] = clip[12] + clip[11];
   frustum[5][3] = clip[16] + clip[15];
 --/* Normalize the result */
   t = math.sqrt( frustum[5][0] * frustum[5][0] + frustum[5][1] * frustum[5][1] + frustum[5][2]    * frustum[5][2] )
   frustum[5][0] = frustum[5][0] / t
   frustum[5][1] = frustum[5][1] / t
   frustum[5][2] = frustum[5][2] / t
   frustum[5][3] = frustum[5][3] / t 
end

--this function checks whether a sphere at loc with a radius falls even partially in the view frustum
function isSphereInFrustum(loc, radius)
    frusChecks = frusChecks + 1
    for p = 0,5 do
        if ( frustum[p][0] * loc.x + frustum[p][1] * loc.y + frustum[p][2] * loc.z + frustum[p][3]    <= -radius ) then
            return false
        end
    end
    
    return true
end

--get the shader to draw a single quad
function drawTile(tileSize, pos, scales)
    m.shader.nodeScale = tileSize
    m.shader.nodePos = pos
    m.shader.lodScales = scales / lodFactor
    m:draw()
end

--only used if wireframing is turned on
function set_wireframe_colors(m)
    local cc={}
    for i = 1, m.size/3 do
        table.insert(cc, color(255,0,0))
        table.insert(cc, color(0,255,0))
        table.insert(cc, color(0,0,255))
    end
    m.colors = cc
end

--print some metrics
function metrics()

    if (ElapsedTime - elapsedTimeMem > 5) then
        memory = collectgarbage("count") / 1024
        elapsedTimeMem = ElapsedTime
    end

    pushMatrix()
    resetMatrix()
    pushStyle()
    fill(color(255))
    font("Georgia")
    fontSize(20)
    --fontSize(DefaultStyle.fontSize)
    --foregroundColor(color(255))
    FPS = FPS * 0.9 + 0.1 / DeltaTime
    if (ElapsedTime - elapsedTimeFPS > 0.25) then
        msg = string.format("%.0fFPS %.1fMB %.0fTs %.0fFCs", FPS, memory, drawn, frusChecks)
        elapsedTimeFPS = ElapsedTime
    end
    text(msg, WIDTH - 130, 64)
    popStyle()
    popMatrix()
end


