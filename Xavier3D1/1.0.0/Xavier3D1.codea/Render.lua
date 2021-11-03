-- Render Loop --
------------------------------------------------------
    
function draw()
    
    readParameters()
    
    background(0)
    
    local p = p
    
    local offsetX = WIDTH*.5
    local offsetY = HEIGHT*.5
    
    -- Apply z ordering every 20 frame
    local zOrder = cnt%20
    
    local v = mdl.vertices
    local f = mdl.faces
    local tris = mdl.tris
    local cols = mdl.cols
    local tex = mdl.tex
    
    local t
    local texture
    
    -- Select texture based on display mode
    if textured == 1 then
        t = mdl.colorTexCoords
        texture = colorTexture
    end
    if wireframe == 1 then
        t = mdl.detailTexCoords
        texture = detailTexture
    end
    
    local a, b, c, s
    local vfx, vfy, vfz, col
    
    -- refresh fps every 20 frames so its actually readable
    if zOrder == 0 then
        txt = ((1024/step)*(1024/step)).." polygons at "..(math.floor(1/DeltaTime*10)/10).." FPS"
    end
    
    text(txt, WIDTH - 250, HEIGHT - 50)
    local n = 1
    
    -- loop through every face in the model, each face contains the index of 3 vertices
    for i=1, #f do
        local fx = f[i].x
        local fy = f[i].y
        local fz = f[i].z
        -- extract the vertices that define the face
        vfx = v[fx]
        vfy = v[fy]
        vfz = v[fz]
        
        a = vfx.pt
        b = vfy.pt
        c = vfz.pt
        
        -- to speed things up, a vertex is only projected once
        -- the raw 3D to 2D screen space formula is x2D = x3D/z3D, y2D = y3D/z3D
        -- base color of each vertex is based on its height
        
        -- point A
        if not vfx.done then
            s = 600/(600 + vfx.y)
            a.x = vfx.x * s + offsetX
            a.y = vfx.z * s + offsetY
            if colored == 1 then
                col = 255 - vfx.y*.075
                vfx.col = color(col*Red, col*Green, col*Blue, 255)
            end
            vfx.done = true
        end
        
        -- point B
        if not vfy.done then
            s = 600/(600 + vfy.y)
            b.x = vfy.x * s + offsetX
            b.y = vfy.z * s + offsetY
            if colored == 1 then
                col = 255 - vfy.y*.075
                vfy.col = color(col*Red, col*Green, col*Blue, 255)
            end
            vfy.done = true
        end
        
        -- point C
        if not vfz.done then
            s = 600/(600 + vfz.y)
            c.x = vfz.x * s + offsetX
            c.y = vfz.z * s + offsetY
            if colored == 1 then
                col = 255 - vfz.y*.075
                vfz.col = color(col*Red, col*Green, col*Blue, 255)
            end
            vfz.done = true
        end 
        
        -- getting distance from center of polygon to camera(0,0,0) to use painter's algorithm
        -- this doesn't need to be that precise, so can easily be simplified
        if zOrder == 0 then
            midx = (vfx.x + vfy.x + vfz.x)
            midy = (vfx.y + vfy.y + vfz.y)
            midz = (vfx.z + vfy.z + vfz.z)
            
            f[i].dist = (midx*midx+ midy*midy+ midz*midz)
        else
            local nA = n
            local nB = n+1
            local nC = n+2
            -- add vertices
            tris[nA] = a
            tris[nB] = b
            tris[nC] = c
            
            -- add wireframe texture UVs
            if textured == 1 or wireframe == 1 then
                tex[nA] = t[fx]
                tex[nB] = t[fy]
                tex[nC] = t[fz]
            end
            -- add colors
            if colored == 1 then
                cols[nA] = vfx.col
                cols[nB] = vfy.col
                cols[nC] = vfz.col
            end
            n = n + 3
        end
    end
    
    -- the painter's algorithm means drawings things closer to the camera last
    -- we sort the polygons based on distance to camera
    
    
    if (zOrder == 0) then
        table.sort(f, function (a,b) return a.dist>b.dist end)
        
        for i=1, #f do
            local fx = f[i].x
            local fy = f[i].y
            local fz = f[i].z
            
            vfx = v[fx]
            vfy = v[fy]
            vfz = v[fz]
            
            local nA = n
            local nB = n+1
            local nC = n+2
            
            -- add vertices
            tris[nA] = vfx.pt
            tris[nB] = vfy.pt
            tris[nC] = vfz.pt
            
            -- add wireframe texture UVs
            if textured == 1 or wireframe == 1 then
                tex[nA] = t[fx]
                tex[nB] = t[fy]
                tex[nC] = t[fz]
            end
            -- add colors
            if colored == 1 then
                cols[nA] = vfx.col
                cols[nB] = vfy.col
                cols[nC] = vfz.col
            end
            n = n + 3
            
        end
    end
    
    p.vertices = tris
    p.texture = nil
    p.texCoords = nil
    p.colors = nil
    
    
    if textured == 1 or wireframe == 1 then
        p.texture = texture
        p.texCoords = tex
        if colored == 0 then
            p:setColors(255, 255, 255, 255)
        end
    end
    
    if colored == 1 then
        p.colors = cols
    end
    
    p:draw()
    
    cnt = cnt + 1
end
    