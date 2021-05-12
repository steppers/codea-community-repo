--OBJ library

OBJ={}

function OBJ.load(data) --obj , mtl, normals = function to calculate normals, defaults to average normals, shade = shader, defaults to DiffuseShader
   -- local name = data.name
    local mtl = OBJ.parseMtl(data.mtl)  --the mtl material file
    local normals = data.normals or CalculateAverageNormals --the function that will be used to calculate the normals
    local obj = OBJ.parse(data.obj, mtl, normals) --the object file
    
    --create mesh
    local m=mesh()   
    --set vertices, texCoords, normals, and colours
    m.vertices=obj.v    
    if #obj.t>0 then m.texCoords=obj.t end
    if #obj.n>0 then m.normals=obj.n end
    if #obj.c>0 then m.colors=obj.c 
    else m:setColors(color(255))
    end 
    
    --texture and shader
    local shade = data.shade or DiffuseShader
    if data.texture then

        m.texture=data.texture

    end    
    m.shader=shade
    m.shader.shininess = data.shininess or 1.2 --settings for specular shader
    m.shader.specularPower = data.specularPower or 32
    return m
end

function OBJ.parse(data,material, normals)
    
    local p, v, tx, t, np, n, c={},{},{},{},{},{},{} 
    
    local mtl=material.mtl
    local mname
    
    for code, v1,v2,v3 in data:gmatch("(%a+) ([%w%p]+) *([%d%p]*) *([%d%p]*)[\r\n]") do --one code and between one and three number values (that might be negative and have decimal points, hence %p punctuation)
        -- print(code, v1, v2, v3)
        if code == "usemtl" then mname = v1
        elseif code=="v" then --point position
            p[#p+1]=vec3(v1,v2,v3) 
        elseif code=="vn" then --point normal
            np[#np+1]=vec3(v1,v2,v3) 
        elseif code=="vt" then --texture co-ord
            tx[#tx+1]=vec2(v1,v2) 
        elseif code=="f" then --vertex
            local pts,ptex,pnorm=OBJ.GetList(v1,v2,v3)
            if #pts==3 then
                for i=1,3 do
                    v[#v+1]=p[tonumber(pts[i])]
                    if mname then c[#c+1]=mtl[mname].Kd end --set vertex color according to diffuse component of current material
                end
                if ptex then for i=1,3 do t[#t+1]=tx[tonumber(ptex[i])] end end
                if pnorm then for i=1,3 do n[#n+1]=np[tonumber(pnorm[i])] end end
            else
                alert("add a triangulate modifier to the mesh and re-export", "non-triangular face detected") --insist on triangular faces
                return
            end
        end
    end
    if #n<#v then n=normals(v, data.inverseNormals) end
    print (#v.." vertices processed") --name..": "..
    return {v=v, t=t, c=c, n=n}
end

function OBJ.parseMtl(data)
    local mtl={}
    local mname, map, path
    
    for code, v1,v2,v3 in data:gmatch("([%a_]+) ([%w%p]+) *([%d%p]*) *([%d%p]*)[\r\n]") do --one code and between one and three number values (that might be negative and have decimal points, hence %p punctuation)
        --   print(code, v1, v2, v3)
        if code=="newmtl" then
            mname=v1
            mtl[mname]={}
        elseif code=="Ka" then --ambient
            mtl[mname].Ka=color(v1,v2,v3) * 255 
        elseif code=="Kd" then --diffuse
            mtl[mname].Kd=color(v1,v2,v3) * 255 --this is the important one
        elseif code=="Ks" then --specular
            mtl[mname].Ks=color(v1,v2,v3) * 255 
        elseif code=="Ns" then --specular exponent
            mtl[mname].Ns=v1 
        elseif code=="illum" then --illumination code
            mtl[mname].illum=v1 
        elseif code=="map_Kd" then --texture map name. New: only 1 texture per model
            map = v1:match("([%w_]+)%.") --remove extension
        end
    end
    
    return {mtl=mtl, texture=map} 
end

function OBJ.GetList(...)
    local p,t,n={},{},{}
    
    local inkey={...}
    
    for i=1,#inkey do
        for v1,v2,v3 in inkey[i]:gmatch("(%d+)/?(%d*)/?(%d*)") do
            if v2~="" and v3~="" then
                p[i]=math.abs(v1)
                t[i]=math.abs(v2)
                n[i]=math.abs(v3)
            elseif v2~="" then
                p[i]=math.abs(v1)
                t[i]=math.abs(v2)
            else
                p[i]=math.abs(v1)
                
            end
        end
    end
    return p,t,n
end

function CalculateNormals(vertices, invert)
    local invert = invert or 1
    --this assumes flat surfaces, and hard edges between triangles
    local norm = {}
    for i=1, #vertices,3 do --calculate normal for each set of 3 vertices
        local n = ((vertices[i+1] - vertices[i]):cross(vertices[i+2] - vertices[i])):normalize() * invert
        norm[i] = n --then apply it to all 3
        norm[i+1] = n
        norm[i+2] = n
    end
    return norm
end   

function CalculateAverageNormals(vertices)
    --average normals at each vertex
    --first get a list of unique vertices, concatenate the x,y,z values as a key
    local norm,unique= {},{}
    for i=1, #vertices do
        unique[vertices[i].x ..vertices[i].y..vertices[i].z]=vec3(0,0,0)
    end
    --calculate normals, add them up for each vertex and keep count
    for i=1, #vertices,3 do --calculate normal for each set of 3 vertices
        local n = (vertices[i+1] - vertices[i]):cross(vertices[i+2] - vertices[i]) 
        for j=0,2 do
            local v=vertices[i+j].x ..vertices[i+j].y..vertices[i+j].z
            unique[v]=unique[v]+n  
        end
    end
    --calculate average for each unique vertex
    for i=1,#unique do
        unique[i] = unique[i]:normalize()
    end
    --now apply averages to list of vertices
    for i=1, #vertices,3 do --calculate average
        local n = (vertices[i+1] - vertices[i]):cross(vertices[i+2] - vertices[i]) 
        for j=0,2 do
            norm[i+j] = unique[vertices[i+j].x ..vertices[i+j].y..vertices[i+j].z]
        end
    end
    return norm 
end 
