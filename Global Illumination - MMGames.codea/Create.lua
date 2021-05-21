Create=class()

function Create:Cyl(pos,width,length,poly,open,y)
    local cyl=mesh()
    local fc={}
    local ac={}
    local cs=cs or 360
    local angle=cs/poly
if y==nil then
for i=1,poly+1 do
    ti(fc,vec3(pos.x+open*width*cos(rad(angle*i)),pos.y+open*width*sin(rad(angle*i)),pos.z))
    ti(ac,vec3(pos.x+width*cos(rad(angle*(i))),pos.y+width*sin(rad(angle*(i))),pos.z+length))
end
else
for i=1,poly+1 do
    ti(fc,vec3(pos.x+width*cos(rad(angle*i)),pos.y,pos.z+width*sin(rad(angle*i))))
    ti(ac,vec3(pos.x+open*width*cos(rad(angle*(i))),pos.y+length,pos.z+open*width*sin(rad(angle*(i)))))
end
end
    local v={}
    for k=1,poly do
        ti(v,fc[k]) ti(v,ac[k]) ti(v,ac[k+1])
        ti(v,ac[k+1]) ti(v,fc[k+1]) ti(v,fc[k])
    end
    cyl.vertices=v
    cyl.shader=shader(SDV,SDF)
    cyl.shader.far=FAR
    cyl.dim=vec3(0,0,0)
    return cyl
end

function Create:Sphere(pos,r,N)
    local tab={}
    for n=0,N-1 do
        for m=0,N-1 do
            x=pos.x+r*sin(pi*m/N)*cos(2*pi*n/N)
            y=pos.y+r*sin(pi*m/N)*sin(2*pi*n/N)
            z=pos.z+r*cos(pi*m/N)
            x1=pos.x+r*sin(pi*m/N)*cos(2*pi*(n+1)/N)
            y1=pos.y+r*sin(pi*m/N)*sin(2*pi*(n+1)/N)
            z1=pos.z+r*cos(pi*m/N)
            x2=pos.x+r*sin(pi*(m+1)/N)*cos(2*pi*(n+1)/N)
            y2=pos.y+r*sin(pi*(m+1)/N)*sin(2*pi*(n+1)/N)
            z2=pos.z+r*cos(pi*(m+1)/N)
            x3=pos.x+r*sin(pi*(m+1)/N)*cos(2*pi*n/N)
            y3=pos.y+r*sin(pi*(m+1)/N)*sin(2*pi*n/N)
            z3=pos.z+r*cos(pi*(m+1)/N)
            ti(tab,vec3(x1,y1,z1)) ti(tab,vec3(x,y,z)) ti(tab,vec3(x2,y2,z2))
            ti(tab,vec3(x2,y2,z2)) ti(tab,vec3(x,y,z)) ti(tab,vec3(x3,y3,z3))
        end
    end
    local sph=mesh()
    sph.vertices=tab
    sph.shader=shader(SDV,SDF)
    sph.shader.far=FAR
    sph.dim=vec3(0,0,0)
    sph.sphere=1 sph.radius=r*4 sph.pos=pos*4
    return sph
end

function Create:Box(p,pp)
    local y=2
    v={
    vec3(p.x,p.y+pp.y,p.z),vec3(p.x,p.y+pp.y,p.z+pp.z),vec3(p.x+pp.x,p.y+pp.y,p.z+pp.z),
    vec3(p.x+pp.x,p.y+pp.y,p.z+pp.z),vec3(p.x+pp.x,p.y+pp.y,p.z),vec3(p.x,p.y+pp.y,p.z),
    vec3(p.x,p.y,p.z),vec3(p.x+pp.x,p.y,p.z+pp.z),vec3(p.x,p.y,p.z+pp.z),
    vec3(p.x+pp.x,p.y,p.z+pp.z),vec3(p.x,p.y,p.z),vec3(p.x+pp.x,p.y,p.z),
    
    vec3(p.x,p.y,p.z),vec3(p.x,p.y+pp.y,p.z),vec3(p.x+pp.x,p.y+pp.y,p.z),
    vec3(p.x+pp.x,p.y+pp.y,p.z),vec3(p.x+pp.x,p.y,p.z),vec3(p.x,p.y,p.z),
    vec3(p.x,p.y,p.z+pp.z),vec3(p.x+pp.x,p.y,p.z+pp.z),vec3(p.x+pp.x,p.y+pp.y,p.z+pp.z),
    vec3(p.x+pp.x,p.y+pp.y,p.z+pp.z),vec3(p.x,p.y+pp.y,p.z+pp.z),vec3(p.x,p.y,p.z+pp.z),
    vec3(p.x,p.y,p.z),vec3(p.x,p.y,p.z+pp.z),vec3(p.x,p.y+pp.y,p.z+pp.z),
    vec3(p.x,p.y+pp.y,p.z+pp.z),vec3(p.x,p.y+pp.y,p.z),vec3(p.x,p.y,p.z),
    vec3(p.x+pp.x,p.y,p.z),vec3(p.x+pp.x,p.y+pp.y,p.z),vec3(p.x+pp.x,p.y+pp.y,p.z+pp.z),
    vec3(p.x+pp.x,p.y+pp.y,p.z+pp.z),vec3(p.x+pp.x,p.y,p.z+pp.z),vec3(p.x+pp.x,p.y,p.z)}
    tex={
    vec2(0,0),vec2(1,0),vec2(1,y),vec2(1,1),vec2(0,1),vec2(0,0),
    vec2(0,0),vec2(1,1),vec2(1,0),vec2(1,1),vec2(0,0),vec2(0,1),
    vec2(0,0),vec2(0,y),vec2(1,y),vec2(1,y),vec2(1,0),vec2(0,0),
    vec2(0,0),vec2(1,0),vec2(1,y),vec2(1,y),vec2(0,y),vec2(0,0),
    vec2(0,0),vec2(1,0),vec2(1,y),vec2(1,y),vec2(0,y),vec2(0,0),
    vec2(0,0),vec2(0,y),vec2(1,y),vec2(1,y),vec2(1,0),vec2(0,0)}
    local m=mesh()
    m.vertices=v
    m.texCoords=tex
    --Shader
    m.shader=shader(SDV,SDF)
    m.shader.far=FAR
    return m
end

