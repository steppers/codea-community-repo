Light=class()

--Funktioner-pointlights(utan skuggor/med), spotlight(inget indirekt ljus/ med)

function Light:init(RES)
    self.map=image(RES.x,RES.y)
    self.PLights={}
    self.SLights={}
    self.Shadows={}
    self.MP=Create:Sphere(vec3(0,0,0),1,16)
    self.MP.shader=shader(SPV,SPF)
    self.MP.shader.FA=vec2(math.tan(math.rad(70/2)),RES.x/RES.y)
    self.MS=Create:Cyl(vec3(0,0,0),1,1,16,0)
    local verts=Create:Cyl(vec3(0,0,1),1,0,16,0).vertices
    for i=1,#verts,3 do
        vind=verts[i]
        verts[i]=verts[i+2] verts[i+2]=vind
    end
    self.MS.vertices=sm({self.MS.vertices,verts})
    self.MS.shader=shader(SSPOTV,SSPOTF)
    self.MS.shader.FA=vec2(math.tan(math.rad(70/2)),RES.x/RES.y)
end

function Light:pointlight(p,r,c)
    table.insert(self.PLights,{p,r,c})
    return #self.PLights
end

function Light:spotlight(p,r,c,dir,spot,w)
    N=-(dir-p):normalize()
    local angley=math.deg(math.atan(-N.x,-N.z))
    local anglex=math.deg(math.atan(N.y,vec2(N.z,N.x):len()))
    table.insert(self.SLights,{p,r,c,N,cos(rad(spot/2)),r*math.tan(rad(spot/2)),angley,anglex,spot,dir})
    table.insert(self.Shadows,{image(w,w),matrix()})
    self:Shadow(#self.Shadows)
    return #self.SLights
end

function Light:updatespotlight(i,pos,dir)
if pos~=self.SLights[i][1] or dir~=self.SLights[i][10] then
    local N=-(dir-pos):normalize()
    self.SLights[i][7]=math.deg(math.atan(-N.x,-N.z))
    self.SLights[i][8]=math.deg(math.atan2(N.y,vec2(N.z,N.x):len()))
    self.SLights[i][1]=pos self.SLights[i][4]=N self.SLights[i][10]=dir
    self:Shadow(i)
end
end

function Light:Shadow(i)
    resetMatrix()
    setContext(self.Shadows[i][1],true)
    setCamera(self.SLights[i][1],self.SLights[i][10],self.SLights[i][9],1,0.1,self.SLights[i][2])
    drawScene(self.SLights[i][2])
    self.Shadows[i][2]=viewMatrix()*projectionMatrix()
    setContext()
    resetMatrix()
end

function Light:draw(pos,eye)
    setContext(self.map)
    blendMode(ADDITIVE)
    background(0, 0, 0, 255)
    perspective(70,RES.x/RES.y,0.1,50)
    camera(pos.x,pos.y,pos.z,eye.x,eye.y,eye.z,0,1,0)
    for i=1,#self.PLights do
        pushMatrix()
        translate(self.PLights[i][1].x,self.PLights[i][1].y,self.PLights[i][1].z)
        scale(self.PLights[i][2])
        self.MP.shader.lp=self.PLights[i][1]
        self.MP.shader.lr=self.PLights[i][2]
        self.MP.shader.lc=self.PLights[i][3]
        self.MP.shader.depth=NormDepth
        self.MP.shader.iView=IVIEW
        self.MP.shader.viewproj=VP
        self.MP:draw()
        popMatrix()
    end
    for i=1,#self.SLights do
        pushMatrix()
        translate(self.SLights[i][1].x,self.SLights[i][1].y,self.SLights[i][1].z)
        rotate(self.SLights[i][7],0,1,0)
        rotate(self.SLights[i][8],1,0,0)
        scale(self.SLights[i][6],self.SLights[i][6],self.SLights[i][2])
        self.MS.shader.lp=self.SLights[i][1]
        self.MS.shader.lr=self.SLights[i][2]
        self.MS.shader.lc=self.SLights[i][3]
        self.MS.shader.dir=self.SLights[i][4]
        self.MS.shader.spot=self.SLights[i][5]
        self.MS.shader.lmat=self.Shadows[i][2]
        self.MS.shader.shadow=self.Shadows[i][1]
        self.MS.shader.depth=NormDepth
        self.MS.shader.iView=IVIEW
        self.MS:draw()
        popMatrix()
    end
    setContext()
    blendMode(NORMAL)
    resetMatrix()
end

