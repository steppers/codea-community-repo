Rig = class() --load and concatenate all the obj and mtl files into a single mesh, and animate it

function Rig:init(name, mtl, actions)
    self.mtl = MTL(name.."mtl", mtl)  --the mtl material file
    self.obj = {}
    local total = 1
    for action,urls in pairs(actions) do
        self.obj[action]={}
        for i=1,#urls do
            self.obj[action][i]=OBJ(name..action..i, urls[i], self.mtl) --the obj files (nb pass them the material file)
            total = total + 1
        end
        print (#urls.." frames: "..action)
    end
    self.frames={0}
    
    self.loader=coroutine.create(function()
        local c=1
        local finished=false
        while not finished do
            local loaded = true
            for _,action in pairs(self.obj) do
                for i,v in ipairs(action) do
                    if self.mtl.state=="processed" and v.state=="hasData" then --if mtl file has processed and obj file loaded, then ...
                        v:ProcessData() --can start processing obj files
                    end
                    if v.state=="processed" then
                        c = c + 1
                    else
                        loaded=false
                    end
                    coroutine.yield(c, total)
                end
            end
            if self.mtl.ready and loaded then --if all files have processed and images have loaded then can build mesh
                self:BuildMesh()
                c = c + 1
                finished=true
                
            end
        end
        coroutine.yield(c, total)
    end)
end

function Rig:draw(e)
    self.mesh.shader.modelMatrix=modelMatrix() --part of lighting
    self.mesh.shader.eye=e
    self.mesh:draw()
end

local sixtieth = 1/60

function Rig:cueAnim(actionId, frames, speed)
    local action = self.obj[actionId]
    
    self.frames = frames
    self.speed = speed or 0.05
    self.frame = 0
    
    if self.frames[1]==0 then --tween strips away leading 0 after second frame is reached
        tween.delay(sixtieth/self.speed, function() 
            table.remove(self.frames, 1)
            self.frame = self.frame - 1 
        end)
    end

    --add frames   
    local m = self.mesh 
    local pos={m:buffer("position1"), m:buffer("position2"), m:buffer("position3"), m:buffer("position4"), m:buffer("position5")}
    local norm = {m:buffer("normal1"), m:buffer("normal2"), m:buffer("normal3"), m:buffer("normal4"), m:buffer("normal5")}

    for i=1, #action do
        local frame=action[i]
        
        for j=1,#frame.v do
           local v = frame.v[j]
            pos[i][j]=vec3(v.x,v.y,v.z) --nb must make an independent copy of the vector
            local n = frame.n[j]
            norm[i][j]=vec3(n.x,n.y,n.z)
        end

    end
end

function Rig:endAnim()
    local start, frac = math.modf(self.frame)
    local current = self.frames[start+1]
    local n = start+2
    if n>#self.frames then n=1 end
    local next = self.frames[n]
    self.frames={current,current,next,0,0}
    self.frame=1+frac
end

function Rig:anim(offset)
    if #self.frames==1 then return end
    local len=#self.frames
    self.frame = self.frame + self.speed
    if self.frame >= len then
        self.frame = self.frame - len
    end
    local offset = offset or 0
    local start, frac = math.modf(self.frame +offset) --find the start frame (indexed to 0 for modulation) and the frameBlend fraction  
    
    self.mesh.shader.frameBlend = frac --set frame interpolation fraction

    local fr={}
    for i=0, 3, 1 do --walk through 4 frames needed fir catmull-rom spline: (0=start-1, 1=start frame, 2=start+1, 3=start+2)
        local j = (start + (i - 1))%len --work out where in self.frames to point, use mod to wrap, index 0 because of mod
        local v = self.frames[j+1] 
        fr[i+1]= v
    end    
    
    if start == len-2 and self.frames[len]==0 and self.frames[len-1]==0 then
        self.frames={0} --if last 2 frames are 0
        self.frame=0     --bring animation to a halt
    end
    
    self.mesh.shader.frames={fr[1],fr[2],fr[3],fr[4]} --pass frame pointers to shader
end

function Rig:BuildMesh() --concatenate files into mesh
    print("buildingMesh")
    local m=mesh()
    local mtl=self.mtl
    local obj=self.obj.default[1] --first obj file is the master
    obj.state="building" --prevent repeat build calls in case load is still running
     print (#obj.v.." vertices")
    m.vertices=obj.v
   
    if #obj.t>0 then m.texCoords=obj.t end
    if #obj.n>0 then m.normals=obj.n end
    if #obj.c>0 then m.colors=obj.c end -- new: set vertex colors
    
    m.shader=splineShader -- linearShader 
    local l=vec3(-100,800,400):normalize()  
    m.shader.light=vec4(l.x,l.y,l.z,0)
    m.shader.lightColor = color(234, 232, 223, 255)
    
    m.shader.ambient=0.3
    if mtl.map then
        local tex=OBJ.imgPrefix..mtl.map
        print("texture:"..tex)
        m.texture=tex
    end
    
    self.mesh=m
    -- self.obj, self.mtl=nil,nil --delete files
    --collectgarbage()  
    self.ready = true
end

function Rig:DeleteData()
    for key,action in pairs(self.obj) do
        for i,v in ipairs(action) do
            v:DeleteData()
        end
    end
    self.mtl:DeleteData()
end

