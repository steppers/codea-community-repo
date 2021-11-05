--Object class
O={}

function O.LoadModel(p)
    local mod={}
    for i=1,#p do
        mod[i]=OBJ(p[i][1],p[i][2],p[i][3])
    end
    return mod
end

--OBJ library

OBJ=class()
OBJ.DataPrefix="cfg_"
OBJ.imgPrefix="Project:"

function OBJ:init(name,url,scale)
    self.name=name
    self.callback=callback
    self.scale=scale or 1
    self.centre=vec3(0,0,0)
    self.data=readGlobalData(OBJ.DataPrefix..name)
    if self.data then self:ProcessData()
    else http.request(url,function(d) self:DownloadData(d) end) end
end

function OBJ:DownloadData(data)    
    if data~=nil and string.find(data,"[obj]") then
        saveGlobalData(OBJ.DataPrefix..self.name,data)
        self.data=data
        self:ProcessData()
    else print("Error loading data for "..self.name) return end
end

function OBJ:ProcessData()
    self.mtl={}
    self.m={}
    local p, v, tx, t, np, n={},{},{},{},{},{}
    local s=self.data
    local mname
    local section="mtl"
    for line in s:gmatch("[^\r\n]+") do
        line=OBJ.trim(line)
        if string.find(line,"%[obj%]")~=nil then section="obj" mname=nil end                  
        --material definition section
        if section=="mtl" then
            if string.find(line,"newmtl") then 
              mname=OBJ.GetValue(line)
              --print(mname)
              self.mtl[mname]={}
            else
              local code=string.sub(line,1,2)
              if code=="Ka" then --ambient
                  self.mtl[mname].Ka=OBJ.GetColor(line)
                  --print(mname,"Ka",OBJ.mtl[mname].Ka[1],OBJ.mtl[mname].Ka[2],OBJ.mtl[mname].Ka[3])
              elseif code=="Kd" then --diffuse
                  self.mtl[mname].Kd=OBJ.GetColor(line)
                  --print(mname,"Kd",OBJ.mtl[mname].Kd[1],OBJ.mtl[mname].Kd[2],OBJ.mtl[mname].Kd[3])
              elseif code=="Ks" then --specular
                  self.mtl[mname].Ks=OBJ.GetColor(line)
                  --print(mname,"Ks",OBJ.mtl[mname].Ks[1],OBJ.mtl[mname].Ks[2],OBJ.mtl[mname].Ks[3])
              elseif code=="Ns" then --specular exponent
                  self.mtl[mname].Ns=OBJ.GetValue(line)
                  --print(mname,"Ns",OBJ.mtl[mname].Ns)
              elseif code=="ill" then --illumination code
                  self.mtl[mname].illum=OBJ.GetValue(line)
                  --print(mname,"illum",OBJ.mtl[mname].illum)
              elseif code=="ma" then --texture map name
                  local u=OBJ.split(OBJ.GetValue(line)," ")
                  if string.find(u[1],"%.") then
                      self.mtl[mname].map=string.sub(u[1],1,string.find(u[1],"%.")-1)
                  else
                      self.mtl[mname].map=u[1]
                  end
                  self.mtl[mname].path=u[2]
                  --print(mname,line,"\n",OBJ.mtl[mname].map,"\n",OBJ.mtl[mname].path)  
              end
            end
         
        --data section
        elseif section=="obj" then
      
          --read in groups of data into separate meshes
            local code=string.sub(line,1,2)
            --look for material settings, a separate mesh is used for each
            if string.find(line,"usemtl") then
                if mname then
                    local m=mesh()
                    if self.scale~=1 then for i=1,#v do v[i]=v[i]*self.scale end end
                    m.vertices=v
                    if #t>0 then m.texCoords=t end
                    if #n>0 then m.normals=n end
                    if self.mtl[mname] then m.settings=self.mtl[mname] end
                    m.name=mname
                    self.m[#self.m+1]=m
                end
                mname=OBJ.GetValue(line)
                v,t,n={},{},{}
                --print(mname)
            end
            if code=="v " then --point position
              p[#p+1]=OBJ.GetVec3(line)
            elseif code=="vn" then --point normal
              np[#np+1]=OBJ.GetVec3(line)    
            elseif code=="vt" then --texture co-ord
              tx[#tx+1]=OBJ.GetVec2(line)
            elseif code=="f " then --vertex
              local pts,ptex,pnorm=OBJ.GetList(line)
              if #pts==3 then
                for i=1,3 do v[#v+1]=p[tonumber(pts[i])] end
                if ptex then for i=1,3 do t[#t+1]=tx[tonumber(ptex[i])] end end
                if pnorm then for i=1,3 do n[#n+1]=np[tonumber(pnorm[i])] end end
              elseif #pts==4 then
                for i=1,3 do v[#v+1]=p[tonumber(pts[i])] end
                if ptex then for i=1,3 do t[#t+1]=tx[tonumber(ptex[i])] end end
                if pnorm then for i=1,3 do n[#n+1]=np[tonumber(pnorm[i])] end end
                v[#v+1]=p[tonumber(pts[3])]
                if ptex then t[#t+1]=tx[tonumber(ptex[3])] end
                if pnorm then n[#n+1]=np[tonumber(pnorm[3])] end
                v[#v+1]=p[tonumber(pts[4])]
                if ptex then t[#t+1]=tx[tonumber(ptex[4])] end
                if pnorm then n[#n+1]=np[tonumber(pnorm[4])] end
                v[#v+1]=p[tonumber(pts[1])]
                if ptex then t[#t+1]=tx[tonumber(ptex[1])] end
                if pnorm then n[#n+1]=np[tonumber(pnorm[1])] end
              elseif #pts>4 then
                local cx,cy,cz=0,0,0
                local ttx,tty=0,0
                local nx,ny,nz=0,0,0
                for i=1,#pts do
                    local u=p[tonumber(pts[i])] cx,cy,cz=cx+u.x,cy+u.y,cz+u.z
                    if ptex then local u=tx[tonumber(ptex[i])] ttx,tty=ttx+u.x,tty+u.y end
                    --if pnorm then local u=p[tonumber(pnorm[i])] nx,ny,nz=nx+u.x,ny+u.y,nz+u.z end
                end
                local cp=vec3(cx/#pts,cy/#pts,cz/#pts)
                if ptex then ct=vec2(ttx/#pts,tty/#pts) end
                --if pnorm then cn=vec3(nx/#pts,ny/#pts,nz/#pts):normalize() end
                local j
                for i=1,#pts do
                    if i<#pts then j=i+1 else j=1 end
                    v[#v+1]=p[tonumber(pts[i])]
                    if ptex then t[#t+1]=tx[tonumber(ptex[i])] end
                    --if pnorm then n[#n+1]=np[tonumber(pnorm[i])] end
                    v[#v+1]=p[tonumber(pts[j])]
                    if ptex then t[#t+1]=tx[tonumber(ptex[j])] end
                    --if pnorm then n[#n+1]=np[tonumber(pnorm[j])] end
                    v[#v+1]=cp
                    if ptex then t[#t+1]=ct end
                    --if pnorm then n[#n+1]=np[tonumber(cn)] end
                end
              end
            end
        end  
    end
    local m=mesh()
    if self.scale~=1 then for i=1,#v do v[i]=v[i]*self.scale end end
    m.vertices=v
    if #t>0 then m.texCoords=t end
    if #n>0 then m.normals=n end
    m.settings=self.mtl[mname]
    m.name=mname
    self.m[#self.m+1]=m 
    self:GetStats()
    --download images if not stored locally
    self.MissingImages={}
    for i,O in pairs(self.mtl) do
        if O.map then
            local y=readImage("Project:"..O.map)
            if not y then 
            self.MissingImages[#self.MissingImages+1]={O.map,O.path} 
            end
        end
    end
    if #self.MissingImages>0 then self:LoadImages() end
    propAngle=0 --propellor
end

function OBJ:LoadImages()
    --print("downloading"..self.MissingImages[1][1])
    http.request(self.MissingImages[1][2],function(d) self:StoreImage(d) end)
end

function OBJ:StoreImage(d)
    --print("saving"..self.MissingImages[1][1])
    saveImage("Project:"..self.MissingImages[1][1],d)
    table.remove(self.MissingImages,1)
    if #self.MissingImages~=0 then self:LoadImages() end
end

function OBJ:DeleteData()
    saveGlobalData(OBJ.DataPrefix..self.name,nil)
    for i,O in pairs(self.mtl) do
        if O.map then
            ---print("deleting "..OBJ.imgPrefix..O.map)
            local y=saveImage(OBJ.imgPrefix..O.map,nil)
        end
    end
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

function OBJ:draw(e,v)
    for i=1,#self.m do
        if v=="All" or (v and string.find(v,self.m[i].name)) then
            self.m[i].shader.mModel=modelMatrix() --part of lighting
            self.m[i]:draw()
        end
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

function OBJ:GetStats()
    local x,y,z,n=0,0,0,0
    local minx,maxx,miny,maxy,minz,maxz=999,-999,999,-999,999,-999
    for i=1,#self.m do
        local vv=self.m[i].vertices
        for j=1,#vv do
            local v=vv[i]
            if v==nil then print (i,#self.m,j,#vv) end
            x,y,z=x+v.x,y+v.y,z+v.z 
            if v.x<minx then minx=v.x end
            if v.x>maxx then maxx=v.x end
            if v.y<miny then miny=v.y end
            if v.y>maxy then maxy=v.y end
            if v.z<minz then minz=v.z end
            if v.z>maxz then maxz=v.z end
        end
        n=n+#vv
    end
    self.centre=vec3(x/n,y/n,z/n)
    self.minvert=vec3(minx,miny,minz)
    self.maxvert=vec3(maxx,maxy,maxz)
    self.size=vec3(maxx-minx,maxy-miny,maxz-minz)
    --print(self.centre,self.size)
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

function CalculateAverageNormals(vertices,f)
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

