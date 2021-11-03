Lego=class()

function Lego:block(p,pp,col,plupp)
    col=col or color(255,255,255,255)
    m=mesh()
    verts={Create:Box(vec3(p.x,p.y*0.25,p.z)+vec3(0.01,0.01,0.01),vec3(pp.x,pp.y*0.25,pp.z)-vec3(0.02,0.02,0.02)).vertices}
    --verts={Create:Box(vec3(p.x,p.y*0.25,p.z),vec3(pp.x,pp.y*0.25,pp.z)).vertices}
    --[[
if plupp==nil then
    for x=0,pp.x-1 do
        for z=0,pp.z-1 do
            table.insert(verts,Create:Cyl(vec3(p.x+x+0.5,p.y*0.25+pp.y*0.25-0.02,p.z+z+0.5),0.3,0.2,20,1,1).vertices)
            table.insert(verts,Create:Cyl(vec3(p.x+x+0.5,p.y*0.25+pp.y*0.25+0.2-0.02,p.z+z+0.5),0.3,0,20,0,1).vertices)
        end
    end
end --]]
    m.vertices=sm(verts)
    m.dim=vec3(pp.x*4,pp.y,pp.z*4) m.pos=vec3(p.x*4,p.y,p.z*4) m.col=color(col.x,col.y,col.z,col.w) m.plupp=plupp
    m.shader=shader(SDV,SDF)
    m.shader.far=FAR
    return m
end

