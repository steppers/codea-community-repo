Voxel=class()

--/////FIXA
--Upsample 1/2|1/3|1/4 upplösning

--/////Lägga till
--Fixed cone directions 360 grader. Använd endast om inom hemisfär
    --Lagra far-delen för koner genom att trace från voxeln och lagra
    --Desamma för anisotropic texture-lookup
--SDF för enklare voxelisering/oändlig detalj/re(fra/fle)ktioner/mindre minne/kollisioner med roterade objekt

--/////Optimeringar
--Pos och Dir är i texture-Space
--Voxelisering constant/dynamic
--Skippa onödiga ljus-kalkylationer med ljus-volymer

function Voxel:initialize(res)
    self.RES=res
    self.IRES=vec3(1/res.x,1/res.y,1/res.z) self.HIR=vec2(1/(res.x*res.z),self.IRES.y/6)
    self.light=image((res.x*res.z)*0.5,res.y*0.5*6)
    self.colors=image(self.light.width,res.y*0.5)
--MipMaps
    self.mipmap={image(self.light.width/4,self.light.height/2),
                 image(self.light.width/16,self.light.height/4),
                 image(self.light.width/64,self.light.height/8)}
    
    self.mpBT={{vec4(self.IRES.z,0,0,self.HIR.y),vec4(self.IRES.z,0,self.HIR.x,0),vec4(self.HIR.x,0,0,self.HIR.y)},
    {vec4(self.IRES.z*2,0,0,self.HIR.y*2),vec4(self.IRES.z*2,0,self.HIR.x*2,0),vec4(self.HIR.x*2,0,0,self.HIR.y*2)}
    ,{vec4(self.IRES.z*4,0,0,self.HIR.y*4),vec4(self.IRES.z*4,0,self.HIR.x*4,0),vec4(self.HIR.x*4,0,0,self.HIR.y*4)}}
    
    self.mpOF={{
        vec4(-self.HIR.x,0,self.HIR.x*0.5,-self.HIR.y*0.5),vec4(self.HIR.x,0,-self.HIR.x*0.5,-self.HIR.y*0.5),
        vec4(0,-self.HIR.y,-self.HIR.x*0.5,self.HIR.y*0.5),vec4(0,self.HIR.y,-self.HIR.x*0.5,-self.HIR.y*0.5),
        vec4(-self.IRES.z,0,self.IRES.z-self.HIR.x*0.5,-self.HIR.y*0.5),vec4(self.IRES.z,0,-self.HIR.x*0.5,-self.HIR.y*0.5)},
        {
        vec4(-self.HIR.x*2,0,self.HIR.x,-self.HIR.y),vec4(self.HIR.x*2,0,-self.HIR.x,-self.HIR.y),
        vec4(0,-self.HIR.y*2,-self.HIR.x,self.HIR.y),vec4(0,self.HIR.y*2,-self.HIR.x,-self.HIR.y),
        vec4(-self.IRES.z*2,0,self.IRES.z*2-self.HIR.x,-self.HIR.y),vec4(self.IRES.z*2,0,-self.HIR.x,-self.HIR.y)}
        ,{
        vec4(-self.HIR.x*4,0,self.HIR.x*2,-self.HIR.y*2),vec4(self.HIR.x*4,0,-self.HIR.x*2,-self.HIR.y*2),
        vec4(0,-self.HIR.y*4,-self.HIR.x*2,self.HIR.y*2),vec4(0,self.HIR.y*4,-self.HIR.x*2,-self.HIR.y*2),
        vec4(-self.IRES.z*4,0,self.IRES.z*4-self.HIR.x*2,-self.HIR.y*2),vec4(self.IRES.z*4,0,-self.HIR.x*2,-self.HIR.y*2)}}
    
--Mesh INJECT LIGHT
    self.IL=mesh()
    self.IL.vertices={vec2(0,0),vec2(self.light.width,0),vec2(self.light.width,self.light.height),
    vec2(self.light.width,self.light.height),vec2(0,self.light.height),vec2(0,0)}
    self.IL.texCoords={vec2(0,0),vec2(1,0),vec2(1,1),vec2(1,1),vec2(0,1),vec2(0,0)}
    self.IL.shader=shader(SILV,SILF)
    self.IL.shader.GI=self.RES
    self.IL.shader.IGI=self.IRES
    self.IL.shader.normals={vec3(1,0,0),vec3(-1,0,0),vec3(0,1,0),vec3(0,-1,0),vec3(0,0,1),vec3(0,0,-1)}
--Mesh MIPMAP
    self.MIP=mesh()
    self.MIP.vertices={vec2(0,0),vec2(1,0),vec2(1,1),vec2(1,1),vec2(0,1),vec2(0,0)}
    self.MIP.texCoords={vec2(0,0),vec2(1,0),vec2(1,1),vec2(1,1),vec2(0,1),vec2(0,0)}
    self.MIP.shader=shader(SMIPV,SMIPF)
--First bounce
    self.FB=mesh()
    self.FB.vertices={vec2(0,0),vec2(self.light.width,0),vec2(self.light.width,self.light.height),
    vec2(self.light.width,self.light.height),vec2(0,self.light.height),vec2(0,0)}
    self.FB.texCoords={vec2(0,0),vec2(1,0),vec2(1,1),vec2(1,1),vec2(0,1),vec2(0,0)}
    self.FB.shader=shader(SSBV,SSBF)
    self.FB.shader.normals={vec3(1,0,0),vec3(-1,0,0),vec3(0,1,0),vec3(0,-1,0),vec3(0,0,1),vec3(0,0,-1)}
    self.FB.shader.tangents={vec3(0,0,1),vec3(0,0,1),vec3(1,0,0),vec3(1,0,0),vec3(1,0,0),vec3(1,0,0)}
    self.FB.shader.binormals={vec3(0,1,0),vec3(0,1,0),vec3(0,0,1),vec3(0,0,1),vec3(0,1,0),vec3(0,1,0)}
    self.FB.shader.FAR=vec4(math.tan(math.rad(70/2)),RES.x/RES.y,RES.x*4,RES.y*2)
    self.FB.shader.GI=self.RES
    self.FB.shader.IGI=self.IRES
end

function Voxel:Voxelize(s)
collectgarbage()
setContext(self.colors) background(255,255,255,0) setContext()
setContext(self.light) background(0,0,0,0) setContext()
    for i=1,#s do
        m=s[i]
        if m.dim~=nil then
            for x=1,m.dim.x do
                XX=m.pos.x+x
                for z=1,m.dim.z do
                    ZZ=m.pos.z*self.RES.x+(z-1)*self.RES.x
                    for y=1,m.dim.y do
                        --if math.random(1,10)>9 then mcol=color(m.col.r,m.col.g,m.col.b,250) else mcol=m.col end
                        self.colors:rawSet(ZZ+XX,m.pos.y+y,m.col)
                    end
                end
            end
        end
        if m.sphere~=nil then
            for x=-m.radius+1,m.radius do
                for z=-m.radius+1,m.radius do
                    for y=-m.radius+1,m.radius do
                        --if (vec3(x,y,z)):len()<m.radius+0.25 then
self.colors:rawSet(floor(m.pos.x+x+m.pos.z*self.RES.x+(z-1)*self.RES.x),m.pos.y+y,color(255,252))
                        --end
                    end
                end
            end
        end
        --[[
    if m.plupp==nil then
        for x=1,m.dim.x/4 do
            XX=m.pos.x*4+(x-1)*4+1
            for z=1,m.dim.z/4 do
                ZZ=m.pos.z*4*self.RES.z+(z-1)*4*self.RES.z+self.RES.z
                vt=vec2(XX+ZZ,m.pos.y+m.dim.y+1)
                self.colors:rawSet(vt.x+1,vt.y,m.col) self.colors:rawSet(vt.x+2,vt.y,m.col)
                self.colors:rawSet(vt.x+1+self.RES.z,vt.y,m.col) self.colors:rawSet(vt.x+2+self.RES.z,vt.y,m.col)
        
        --Alpha weighted
                --self.colors:rawSet(vt.x,vt.y,m.col) self.colors:rawSet(vt.x+self.RES.z,vt.y,m.col)
                --self.colors:rawSet(vt.x+3,vt.y,m.col) self.colors:rawSet(vt.x+3+self.RES.z,vt.y,m.col)
                --self.colors:rawSet(vt.x-self.RES.z+1,vt.y,m.col) self.colors:rawSet(vt.x-self.RES.z+2,vt.y,m.col)
                --self.colors:rawSet(vt.x+self.RES.z*2+1,vt.y,m.col) self.colors:rawSet(vt.x+self.RES.z*2+2,vt.y,m.col)
            end
        end
    end--]]
end
end

function Voxel:InjectLight()
    resetMatrix()
    ortho()
    viewMatrix(matrix())
    setContext(self.light)
    background(0, 0, 0, 0)
if FirstBounce then
    self.IL.shader.colors=self.colors
    self.IL.shader.lp=Light.SLights[1][1]
    self.IL.shader.lr=Light.SLights[1][2]
    self.IL.shader.lc=Light.SLights[1][3]
    self.IL.shader.ld=Light.SLights[1][4]
    self.IL.shader.spot=Light.SLights[1][5]
    self.IL.shader.lmat=Light.Shadows[1][2]
    self.IL.shader.shadow=Light.Shadows[1][1]
    self.IL:draw()
end
    setContext()
    setContext(self.mipmap[1])
    background(0, 0, 0, 0)
    scale(self.mipmap[1].width,self.mipmap[1].height)
    self.MIP.shader.vlight=self.light
    self.MIP.shader.vg=self.mpBT[1]
    self.MIP.shader.vgoffset=self.mpOF[1]
    self.MIP.shader.GI=self.RES/2
    self.MIP.shader.IGI=self.IRES*2
    self.MIP:draw()
    setContext()
    resetMatrix()
    setContext(self.mipmap[2])
    background(0, 0, 0, 0)
    scale(self.mipmap[2].width,self.mipmap[2].height)
    self.MIP.shader.vlight=self.mipmap[1]
    self.MIP.shader.vg=self.mpBT[2]
    self.MIP.shader.vgoffset=self.mpOF[2]
    self.MIP.shader.GI=self.RES/4
    self.MIP.shader.IGI=self.IRES*4
    self.MIP:draw()
    setContext()
    resetMatrix()
    setContext(self.mipmap[3])
    background(0, 0, 0, 0)
    scale(self.mipmap[3].width,self.mipmap[3].height)
    self.MIP.shader.vlight=self.mipmap[2]
    self.MIP.shader.vg=self.mpBT[3]
    self.MIP.shader.vgoffset=self.mpOF[3]
    self.MIP.shader.GI=self.RES/8
    self.MIP.shader.IGI=self.IRES*8
    self.MIP:draw()
    setContext()
    resetMatrix()
if SecondBounce then
    self.FB.shader.vlight=self.light
    smooth()
    setContext(self.light)
    --background(0, 0, 0, 0)
    self.FB.shader.vcol=self.colors
    self.FB.shader.vmipmap1=self.mipmap[1]
    self.FB.shader.vmipmap2=self.mipmap[2]
    self.FB.shader.vmipmap3=self.mipmap[3]
    self.FB:draw()
    setContext()
    noSmooth()
    setContext(self.mipmap[1])
    background(0, 0, 0, 0)
    scale(self.mipmap[1].width,self.mipmap[1].height)
    self.MIP.shader.vlight=self.light
    self.MIP.shader.vg=self.mpBT[1]
    self.MIP.shader.vgoffset=self.mpOF[1]
    self.MIP.shader.GI=self.RES/2
    self.MIP.shader.IGI=self.IRES*2
    self.MIP:draw()
    setContext()
    resetMatrix()
    setContext(self.mipmap[2])
    background(0, 0, 0, 0)
    scale(self.mipmap[2].width,self.mipmap[2].height)
    self.MIP.shader.vlight=self.mipmap[1]
    self.MIP.shader.vg=self.mpBT[2]
    self.MIP.shader.vgoffset=self.mpOF[2]
    self.MIP.shader.GI=self.RES/4
    self.MIP.shader.IGI=self.IRES*4
    self.MIP:draw()
    setContext()
    resetMatrix()
    setContext(self.mipmap[3])
    background(0, 0, 0, 0)
    scale(self.mipmap[3].width,self.mipmap[3].height)
    self.MIP.shader.vlight=self.mipmap[2]
    self.MIP.shader.vg=self.mpBT[3]
    self.MIP.shader.vgoffset=self.mpOF[3]
    self.MIP.shader.GI=self.RES/8
    self.MIP.shader.IGI=self.IRES*8
    self.MIP:draw()
    setContext()
    resetMatrix()
end
end

