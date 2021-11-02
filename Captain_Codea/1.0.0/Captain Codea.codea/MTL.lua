MTL = class(OBJ)

function MTL:init(name,url) 
    self.name=name
    self.data=readGlobalData(OBJ.DataPrefix..name)
    if self.data then
        self:ProcessData()
    else
        http.request(url,function(d) self:DownloadData(d) end)
    end
end

function MTL:DownloadData(data)  
    sound(SOUND_JUMP, 16452)
    if data~=nil and string.find(data,"MTL File") then
        saveGlobalData(OBJ.DataPrefix..self.name,data)
        self.data=data
        self:ProcessData()
    else print("Error loading data for "..self.name..i) return end
end

function MTL:ProcessData()
    self.mtl={}
    
    local s=self.data
    local mname

    for line in s:gmatch("[^\r\n]+") do
        line=OBJ.trim(line)
     
        --material definition section

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
            elseif code=="ma" then --texture map name. New: only 1 texture per model
                local u=OBJ.split(OBJ.GetValue(line)," ")
                if string.find(u[1],"%.") then
                    self.map=string.sub(u[1],1,string.find(u[1],"%.")-1) --self.mtl[mname]
                else
                    self.map=u[1]
                end
                self.path=u[2]
                --print(mname,line,"\n",OBJ.mtl[mname].map,"\n",OBJ.mtl[mname].path)
            end
        end
    end
    self.state="processed"
    print ("material processed")
        --download images if not stored locally
   -- self.MissingImages={}
   -- for i,O in pairs(self.mtl) do
        if self.map then
            local y=readImage(OBJ.imgPrefix..self.map)
            if not y then 
              --  self:LoadImages() 
                LoadImages(self.path, OBJ.imgPrefix..self.map, function() self.ready=true end)
            else
                self.ready=true
            end
            --self.MissingImages[#self.MissingImages+1]={O.map,O.path} end
        else
            self.ready=true
        end
 --   end
   -- if #self.MissingImages>0 then self:LoadImages() 
   -- else self.ready=true end
end

function MTL:DeleteData()
    if self.map then saveImage(OBJ.imgPrefix..self.map,nil) end
    --[[
    for i,O in pairs(self.mtl) do
        if O.map then
            ---print("deleting "..OBJ.imgPrefix..O.map)
            local y=saveImage(OBJ.imgPrefix..O.map,nil)
        end
    end
      ]]
end

function MTL:LoadImages()
    --print("downloading"..self.MissingImages[1][1])
    http.request(self.path,function(d) self:StoreImage(d) end) --self.MissingImages[1][2]
end

function MTL:StoreImage(d)
    --print("saving"..self.MissingImages[1][1])
    saveImage(OBJ.imgPrefix..self.map,d) --self.MissingImages[1][1]
  --  table.remove(self.MissingImages,1)
   -- if #self.MissingImages==0 then self.ready=true else self:LoadImages() end
    self.ready=true
end

function LoadImages(path, name, callback)
    --print("downloading"..self.MissingImages[1][1])
    http.request(path, function(d) StoreImage(d, name, callback) end) --self.MissingImages[1][2]
end

function StoreImage(d, name, callback)
    --print("saving"..self.MissingImages[1][1])
    saveImage(name,d) --self.MissingImages[1][1]
  --  table.remove(self.MissingImages,1)
   -- if #self.MissingImages==0 then self.ready=true else self:LoadImages() end
    callback()
end

function GetColor(n)
    local b=math.fmod(n,256)
    local a=(n-b)/255
    return color(a,b,0)
end
