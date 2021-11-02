--OBJ library

OBJ=class()
OBJ.DataPrefix="cfg_"
OBJ.imgPrefix="Documents:z3D"
OBJ.modelPrefix="mesh_"

function OBJ:init(name,url,material)    
    self.name=name
    self.mtl=material
    self.data=readGlobalData(OBJ.DataPrefix..name)
    if self.data then
        self.state="hasData"
    else
        http.request(url,function(d) self:DownloadData(d) end)
    end  
end

function OBJ:DownloadData(data)    
    if data~=nil and (string.find(data,"OBJ File") or string.find(data,"ply") ) then
        saveGlobalData(OBJ.DataPrefix..self.name,data)
        self.data=data
        self.state="hasData" --can't process it until we have the mtl file
    else print("Error loading data for "..self.name..i) return end
end

function OBJ:ProcessData()
    print ("processing"..self.name)
    local p, v, tx, t, np, n, c={},{},{},{},{},{},{} --new: c for vertex colors (set by material)
    --data section
    local s=self.data
    local mtl=self.mtl.mtl
    local mname

    for line in s:gmatch("[^\r\n]+") do

    local code=string.sub(line,1,2)
    if string.find(line,"usemtl") then mname=OBJ.GetValue(line) end --new: keep each material on same mesh
    
    if code=="v " then --point position
        p[#p+1]=OBJ.GetVec3(line)
    elseif code=="vn" then --point normal
        np[#np+1]=OBJ.GetVec3(line)
    elseif code=="vt" then --texture co-ord
        tx[#tx+1]=OBJ.GetVec2(line)
    elseif code=="f " then --vertex
        local pts,ptex,pnorm=OBJ.GetList(line)
        if #pts==3 then
            for i=1,3 do
                v[#v+1]=p[tonumber(pts[i])]
                if mname then c[#c+1]=mtl[mname].Kd end --new: set vertex color according to diffuse component of current material
            end
            if ptex then for i=1,3 do t[#t+1]=tx[tonumber(ptex[i])] end end
            if pnorm then for i=1,3 do n[#n+1]=np[tonumber(pnorm[i])] end end
        else
            alert("add a triangulate modifier to the mesh and re-export", "non-triangular face detected") --new: insist on triangular faces
            return            
        end
    end
    end
    
     if #n==0 then n=CalculateAverageNormals(v) end
    self.v = v
    self.t = t
    self.c = c 
    self.n = n
--    self.mesh = {v=v, t=t, c=c, n=n}
    print (self.name..": "..#v.." vertices processed")
    self.data=nil
    self.state = "processed"
   -- print("processed")
end

function OBJ:DeleteData()
    saveGlobalData(OBJ.DataPrefix..self.name,nil)
end

function OBJ.GetColor(s)
  local s1=string.find(s," ")
  local s2=string.find(s," ",s1+1)
  local s3=string.find(s," ",s2+1)
  return color(string.sub(s,s1+1,s2-1)*255,string.sub(s,s2+1,s3-1)*255,string.sub(s,s3+1,string.len(s))*255)
end

function OBJ.GetVec3(s)
  local s1=string.find(s," ")
  local s2=string.find(s," ",s1+1)
  local s3=string.find(s," ",s2+1)
  return vec3(math.floor(string.sub(s,s1+1,s2-1)*100)/100,
    math.floor(string.sub(s,s2+1,s3-1)*100)/100,
    math.floor(string.sub(s,s3+1,string.len(s))*100)/100)
end

function OBJ.GetVec2(s)
  local s1=string.find(s," ")
  local s2=string.find(s," ",s1+1)
  local s3=string.find(s," ",s2+1)
  if s3 then
      return vec3(math.floor(string.sub(s,s1+1,s2-1)*100)/100,
            math.floor(string.sub(s,s2+1,s3-1)*100)/100)
  else
      return vec2(math.floor(string.sub(s,s1+1,s2-1)*100)/100,
            math.floor(string.sub(s,s2+1,string.len(s))*100)/100)
  end
end

function OBJ.GetValue(s)
  return string.sub(s,string.find(s," ")+1,string.len(s))
 end
 
function OBJ.trim(s)
  while string.find(s,"  ") do s = string.gsub(s,"  "," ") end
  return s:match'^()%s*$' and '' or s:match'^%s*(.*%S)'
end

function OBJ.split(s,sep)
  sep=sep or "/"
  local p={}
  local pattern = string.format("([^%s]+)", sep)
  string.gsub(s,pattern, function(c) p[#p+1] = c end)
  return p
end

function OBJ.GetList(s)
   local p,t,n={},{},{}
   --for word in s:gmatch("%w+") do table.insert(p, word) end
   p=OBJ.split(s," ")
   table.remove(p,1)
   for i=1,#p do
      local a=OBJ.split(p[i])
      if #a==1 then
        p[i]=math.abs(a[1])
      elseif #a==2 then
        p[i]=math.abs(a[1])
        t[i]=math.abs(a[2])
      elseif #a==3 then
        p[i]=math.abs(a[1])
        t[i]=math.abs(a[2])
        n[i]=math.abs(a[3])
      end
   end
   return p,t,n
end

function CalculateNormals(vertices)
    --this assumes flat surfaces, and hard edges between triangles
    local norm = {}
    for i=1, #vertices,3 do --calculate normal for each set of 3 vertices
        local n = ((vertices[i+1] - vertices[i]):cross(vertices[i+2] - vertices[i])):normalize()
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

