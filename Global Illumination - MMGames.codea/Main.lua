
function setup()
    pi,cos,sin,rad,ti,max,min,floor,abs=math.pi,math.cos,math.sin,math.rad,table.insert,math.max,math.min,math.floor,math.abs
    spriteMode(CORNER)
    noSmooth()
    parameter.watch("1/DeltaTime")
    parameter.watch("math.floor(collectgarbage('count')*0.1)*10")
    parameter.number("X",-15,15,2.5)
    parameter.number("Y",-5,15,2)
    parameter.number("Z",-15,15,8)
    parameter.number("ROT",0,360,200)
    parameter.color("LC",color(255))
    parameter.number("CR",0,60,0)
    parameter.integer("Lod",0,3,0)
--Inställningar
    FAR=20
    RES_DIV=5
--Initiering
    RES=vec2(math.floor(WIDTH/RES_DIV),math.floor(HEIGHT/RES_DIV))
    INV_RES=vec2(0.5/RES.x,0.5/RES.y)
    Pos=vec3(X,Y,Z)
    Eye=vec3(2,2,4) EyeR=vec2(0,-1.57)
--Klasser
    Voxel:initialize(vec3(32,16,32))
    Light:init(RES)
--Bilder
    Depth=image(RES.x,RES.y)
    NormDepth=image(RES.x*2,RES.y)
    Screen=image(RES.x,RES.y)
    M=mesh()
    M.vertices={vec2(0,0),vec2(Screen.width,0),vec2(Screen.width,Screen.height),
    vec2(Screen.width,Screen.height),vec2(0,Screen.height),vec2(0,0)}
    M.texCoords={vec2(0,0),vec2(1,0),vec2(1,1),vec2(1,1),vec2(0,1),vec2(0,0)}
    M.shader=shader(SFLV,SFLF)
    M.shader.FAR=vec4(math.tan(math.rad(70/2)),RES.x/RES.y,RES.x*4,RES.y*2)
    NM=mesh()
    NM.vertices={vec2(0,0),vec2(Depth.width,0),vec2(Depth.width,Depth.height),
    vec2(Depth.width,Depth.height),vec2(0,Depth.height),vec2(0,0)}
    NM.texCoords={vec2(0,0),vec2(1,0),vec2(1,1),vec2(1,1),vec2(0,1),vec2(0,0)}
    NM.shader=shader(SCNV,SCNF)
    NM.shader.vg=INV_RES NM.shader.FA=vec2(math.tan(math.rad(70/2)),RES.x/RES.y)
--Scen
    Scene={
    Lego:block(vec3(0,0,0),vec3(8,2,8))--Floor
    ,Lego:block(vec3(0,12,0),vec3(4,2,4))--Ceiling
    ,Lego:block(vec3(0,2,1),vec3(1,10,3),color(255,0,0,255),1)--Red wall
    ,Lego:block(vec3(3,2,1),vec3(1,10,3),color(255,255,0,255),1)--Green wall
    ,Lego:block(vec3(0,2,0),vec3(4,10,1))--Wall back
,Create:Sphere(vec3(2,1,2),0.5,150)
    ,Lego:block(vec3(1,12,1.5),vec3(2,2,1),color(255,250))--Emissive
}
    Voxel:Voxelize(Scene)
--Ljus
    Light:spotlight(vec3(5000,0,0),20,vec3(2,2,0),vec3(0,1,0),75,500)
--Annat
    t=1 LROT=0 LLC=color(0) LLY=0
    M.shader.GI=Voxel.RES M.shader.IGI=Voxel.IRES M.shader.vcol=Voxel.colors
    parameter.boolean("FirstBounce",true,function() SecondBounce=false Voxel:InjectLight() end)
    parameter.boolean("SecondBounce",true,function() Voxel:InjectLight() end)
end

function draw()
    t=t+1
--Pos=vec3(X,Y,Z)
---[[
    EyeR.y=EyeR.y-RotationRate.y*0.1 EyeR.x=EyeR.x+RotationRate.x*0.1
    if CurrentTouch.state==BEGAN or CurrentTouch.state==MOVING then Pos=Pos+vec3(cos(EyeR.y),EyeR.x,sin(EyeR.y))*0.08 end
    Eye=Pos+vec3(cos(EyeR.y),EyeR.x,sin(EyeR.y))
--]]
    Light.SLights[1][3]=vec3(LC.r,LC.g,LC.b)/127
    Light:updatespotlight(1,vec3(4+cos(rad(-ROT))*6,4,4+sin(rad(-ROT))*6),vec3(4,0,4))
    --lpp=vec3(4+cos(rad(-ROT))*2,2,4+sin(rad(-ROT))*2) Light:updatespotlight(1,lpp,lpp+vec3(lpp.x*0.25-1,-1,lpp.z*0.25-1))
    if LROT~=ROT or LLC~=LC or LY~=LLY then Voxel:InjectLight() LROT=ROT LLC=LC LLY=LY end
    if math.fmod(t,4)==0 then collectgarbage() end
--Rendering
    setContext(Depth,true)
    background(255, 255, 255, 255)
    setCamera(Pos,Eye,70,RES.x/RES.y,0.1,FAR)
    drawScene(FAR)
    IVIEW=viewMatrix():inverse() VP=viewMatrix()*projectionMatrix()
    setContext()
resetMatrix()
ortho()
viewMatrix(matrix())
--NORMALER
    setContext(NormDepth)
    background(255, 255, 255, 255)
    sprite(Depth,Depth.width,0,Depth.width,Depth.height)
    NM.shader.depth=Depth
    NM.shader.iView=IVIEW
    NM:draw()
    setContext()
--LJUS
    Light:draw(Pos,Eye)
resetMatrix()
ortho()
viewMatrix(matrix())
--FinalLight
    smooth()
    setContext(Screen)
    background(0, 0, 0, 255)
    M.shader.depth=NormDepth
    M.shader.light=Light.map
    M.shader.vlight=Voxel.light
    M.shader.vmipmap1=Voxel.mipmap[1]
    M.shader.vmipmap2=Voxel.mipmap[2]
    M.shader.vmipmap3=Voxel.mipmap[3]
    M.shader.iView=IVIEW
    M.shader.Lod=Lod
    M.shader.Time=ElapsedTime
    M.shader.Player=Pos
    M.shader.CR=sin(rad(CR*0.5))/(1-sin(rad(CR*0.5)))
    M:draw()
    setContext()
    noSmooth()
    sprite(Screen,WIDTH/8,HEIGHT/4,WIDTH-WIDTH/4,HEIGHT-HEIGHT/4)
    --sprite(Voxel.colors,0,0,WIDTH,Voxel.colors.height*(WIDTH/Voxel.colors.width))
    --sprite(Voxel.light,0,0,WIDTH,Voxel.light.height*(WIDTH/Voxel.light.width))
    --sprite(Voxel.mipmap[1],0,0,WIDTH,Voxel.mipmap[1].height*(WIDTH/Voxel.mipmap[1].width))
    --sprite(Voxel.mipmap[2],0,0,WIDTH,Voxel.mipmap[2].height*(WIDTH/Voxel.mipmap[2].width))
end

function setCamera(pos,eye,fov,aspect,n,f) perspective(fov,aspect,n,f) camera(pos.x,pos.y,pos.z,eye.x,eye.y,eye.z) end

function drawScene(far)
    for i=1,#Scene do
        Scene[i].shader.far=far
        Scene[i]:draw()
    end
end

function sm(v) local s={} for i,j in ipairs(v) do for h,g in ipairs(j) do table.insert(s,g) end end return s end

function normals(m) --Aint using this one
    local normal={}
    local v=m.vertices
    for i=1,#v,3 do
        local n=(v[i+1]-v[i]):cross(v[i+2]-v[i]):normalize()
        normal[i]=n normal[i+1]=n normal[i+2]=n
    end
    return normal
end

SDV=[[
uniform mat4 modelViewProjection;
attribute vec4 position;
attribute vec2 texCoord;
varying vec4 Pos;
varying vec2 vt;
void main() {
    Pos=modelViewProjection*position;
    vt=texCoord;
    gl_Position=Pos;
}
]]

SDF=[[
precision highp float;
varying vec4 Pos;
varying vec2 vt;
uniform float far;

vec3 encodeDepth(float d) {
    vec3 enc=vec3(1.,255.,65025.)*d;
    enc=fract(enc);
    enc-=vec3(enc.y,enc.z,enc.z)*vec3(1./255.,1./255.,1./255.);
    return enc;
}

void main() {
    if (!gl_FrontFacing) discard;
    gl_FragColor=vec4(encodeDepth(Pos.w/far),1.);
}
]]

SFLV=[[
#version 300 es
uniform mat4 modelViewProjection;
in vec4 position;
in vec2 texCoord;
out highp vec2 vt;
void main() {
    vt=texCoord;
    gl_Position=modelViewProjection*position;
}
]]

SFLF=[[
#version 300 es
precision highp float;
uniform sampler2D depth;
uniform sampler2D light;
uniform sampler2D vlight;
uniform sampler2D vcol;
uniform sampler2D vmipmap1;
uniform sampler2D vmipmap2;
uniform sampler2D vmipmap3;
uniform mat4 iView;
uniform vec4 FAR;
uniform vec3 GI;
uniform vec3 IGI;
uniform float Lod;
uniform float Time;
uniform vec3 Player;
uniform float CR;
in highp vec2 vt;
out vec4 FinalColor;
#define far 20.
#define DIM vec3(GI.x*0.25,GI.y*0.25,GI.z*0.25)
#define IDIM vec3(1./DIM.x,1./DIM.y,1./DIM.z)
#define sixth 1./6.
#define sixth2 2./6.
#define sixth3 3./6.
#define sixth4 4./6.
#define sixth5 5./6.
#define upperLimit GI.y*IGI.x
//MipMaps
#define GI2 vec3(GI.x*0.5,GI.y*0.5,GI.z*0.5)
#define IGI2 vec3(IGI.x*2.,IGI.y*2.,IGI.z*2.)
#define GI3 vec3(GI.x*0.25,GI.y*0.25,GI.z*0.25)
#define IGI3 vec3(IGI.x*4.,IGI.y*4.,IGI.z*4.)
#define GI4 vec3(GI.x*0.125,GI.y*0.125,GI.z*0.125)
#define IGI4 vec3(IGI.x*8.,IGI.y*8.,IGI.z*8.)
const highp vec2 Values=vec2(1./255.,1./65025.);

vec2 seed=vt*vec2(Time*34.69467);
float noise() {
    seed+=vec2(-1.,1.);
    return fract(sin(dot(seed.xy,vec2(12.9898,78.233)))*43758.5453);
}

float decodeDepth(vec3 c) { return dot(c,vec3(1.,Values.x,Values.y)); }

mat3 TBN(vec3 N) {
    vec3 Nt,Nb; 
    Nt=(abs(N.x)>abs(N.y)-0.02)?(vec3(N.z,0.,-N.x)/sqrt(N.x*N.x+N.z*N.z)):
    (vec3(0.,-N.z,N.y)/sqrt(N.y*N.y+N.z*N.z));
    Nb=normalize(cross(N,Nt));
    Nt=normalize(cross(N,Nb));
    return mat3(Nt.x,Nb.x,N.x,Nt.y,Nb.y,N.y,Nt.z,Nb.z,N.z);
}

vec4 MIX(vec3 vP, vec2 bvt, vec2 frek, sampler2D img) {
    float f=fract(vP.z*frek.x);
vec4 rvc=(f>0.5)?
mix(texture(img,bvt),texture(img,((bvt+vec2(frek.y,0.)).x>1.)?bvt:bvt+vec2(frek.y,0.)),f-0.5)
:mix(texture(img,((bvt-vec2(frek.y,0.)).x<0.)?bvt:bvt-vec2(frek.y,0.)),
texture(img,bvt),f+0.5);
    return rvc;
}

vec4 VoxelFetch(vec2 pvt, vec3 vP, vec3 vD, vec2 frek, sampler2D img, vec3 bgi, vec3 ibgi) {
    vec2 Min=vec2(floor(pvt.x*bgi.z)*ibgi.z+0.5*ibgi.z*ibgi.x,
        floor(pvt.y*6.)*sixth+0.5*ibgi.y*sixth);
    vec2 Max=vec2(Min.x+ibgi.z-ibgi.z*ibgi.x,
        Min.y+sixth-ibgi.y*sixth);
    pvt=clamp(pvt,Min,Max);
    
    vec3 vDS=vD.xyz*vD.xyz; vec4 xC,yC,zC;
    xC=(vD.x>0.)?MIX(vP,pvt+vec2(0,sixth),frek,img):
    MIX(vP,pvt,frek,img);
    if (xC.w==0.) return vec4(0.);
    yC=(vD.y>0.)?MIX(vP,pvt+vec2(0,sixth3),frek,img):
    MIX(vP,pvt+vec2(0,sixth2),frek,img);
    zC=(vD.z>0.)?MIX(vP,pvt+vec2(0,sixth5),frek,img):
    MIX(vP,pvt+vec2(0,sixth4),frek,img);
    return xC*vDS.x+yC*vDS.y+zC*vDS.z;
}

vec4 GetVoxelI(vec3 vP, vec3 vD, float lod) {
    if (lod<1.) {
        float zf=floor(vP.z*4.)*IGI.z;
        vec2 pvt=vec2(vP.x*IDIM.x*IGI.z+zf,vP.y*IDIM.y*sixth);
        zf=floor(vP.z*2.)*IGI2.z;
        vec2 pvt2=vec2(vP.x*IDIM.x*IGI2.z+zf,vP.y*IDIM.y*sixth);
        return mix(
            VoxelFetch(pvt,vP,vD,vec2(4.,IGI.z),vlight,GI,IGI),
        VoxelFetch(pvt2,vP,vD,vec2(2.,IGI2.z),vmipmap1,GI2,IGI2),lod);
    } else if (lod<2.) {
        float zf=floor(vP.z*2.)*IGI2.z;
        vec2 pvt=vec2(vP.x*IDIM.x*IGI2.z+zf,vP.y*IDIM.y*sixth);
        zf=floor(vP.z)*IGI3.z;
        vec2 pvt2=vec2(vP.x*IDIM.x*IGI3.z+zf,vP.y*IDIM.y*sixth);
        return mix(VoxelFetch(pvt,vP,vD,vec2(2.,IGI2.z),vmipmap1,GI2,IGI2),
        VoxelFetch(pvt2,vP,vD,vec2(1.,IGI3.z),vmipmap2,GI3,IGI3),lod-1.);
    } else {
        float zf=floor(vP.z)*IGI3.z;
        vec2 pvt=vec2(vP.x*IDIM.x*IGI3.z+zf,vP.y*IDIM.y*sixth);
        zf=floor(vP.z*0.5)*IGI4.z;
        vec2 pvt2=vec2(vP.x*IDIM.x*IGI4.z+zf,vP.y*IDIM.y*sixth);
        return mix(VoxelFetch(pvt,vP,vD,vec2(1.,IGI3.z),vmipmap2,GI3,IGI3),
        VoxelFetch(pvt2,vP,vD,vec2(0.5,IGI4.z),vmipmap3,GI4,IGI4),min(1.,lod-2.));
    }
}

vec4 Trace(vec3 vP, vec3 vD, float ConeRatio, float MaxD) {
    vec4 fc=vec4(0.); float sL,sW,sD; vec4 sC; vec3 sP;
    vec3 origin=vP*IDIM.x;
    float dist=IGI.x+(fract(sin(dot(vt,vec2(12.9898, 78.233)))*43758.5453))*IGI.x*2.;
    float sI=max(dist,dist*ConeRatio); float mD=IGI.x;
    while (dist<MaxD && fc.w<0.9) {
        sD=max(mD,dist*ConeRatio);
        sP=origin+vD*dist;
        if (sP.x<0. || sP.y<0. || sP.z<0. || sP.x>1. || sP.y>upperLimit || sP.z>1.) break;
        sL=log2(sD*32.);
        sC=GetVoxelI(sP*DIM.x,vD,sL);
        sW=1.-fc.w;
        fc+=sC*sW;
        dist+=sD;
    }
    return fc;
}

vec3 ToPos(vec2 vt,float f) {
    vec2 uv=vt*2.-1.;
    highp float Z=f*far;
    highp float X=uv.x*FAR.x*FAR.y*Z;
    highp float Y=uv.y*FAR.x*Z;
    highp vec4 fPos=iView*vec4(X,Y,-Z,1.);
    return fPos.xyz/fPos.w;
}

void main() {
    ivec2 ivt=ivec2(vt.x*FAR.z*0.5,vt.y*FAR.w);
    float D=decodeDepth(texelFetch(depth,ivec2(ivt.x+int(FAR.z*0.5),ivt.y),0).xyz);
    if (D>0.99) discard;
//Pos,Normal,bvt
    vec3 P=ToPos(vt,D);
    vec3 N=texelFetch(depth,ivt,0).xyz; N=normalize(N*2.-1.); mat3 NM=TBN(N);
    P=P-N*0.05; float zf=floor(P.z*4.)*IGI.z; vec2 atvt=vec2(P.x*IDIM.x*IGI.z+zf,P.y*IDIM.y);
//Attributer
    vec3 DirectL=texture(light,vt).xyz;
    vec4 Albedo=texelFetch(vcol,ivec2(atvt.x*GI.x*GI.z,atvt.y*GI.y),0);
//Strålföljning
//*
    if (Albedo.w*255.==250.)
        FinalColor=vec4(Albedo.xyz,1.); //EMISSIVE
    else {
        P=P+N*0.25;
        float j=0.8+(fract(sin(dot(vt,vec2(12.9898, 78.233)))*43758.5453))*0.4;
        FinalColor=vec4((
            (Trace(P,N,1.,1.5)
            +Trace(P,normalize(vec3(j,0.,1.)*NM),1.,1.5)
            +Trace(P,normalize(vec3(-j,0.,1.)*NM),1.,1.5)
            +Trace(P,normalize(vec3(0.,j,1.)*NM),1.,1.5)
            +Trace(P,normalize(vec3(0.,-j,1.)*NM),1.,1.5)*0.7).xyz*0.5
+((Albedo.w*255.==252.)?Trace(P,reflect(normalize(P-Player),-N),CR,1.5).xyz:vec3(0.))
        +DirectL)*Albedo.xyz,1.);
    }
//*/
    
//FinalColor=vec4(GetVoxelI(P-N*0.125,-N,Lod).xyz,1.); //Voxel
//P+=N*0.05;FinalColor=vec4(vec3(reflect(normalize(P-Player),-N).y),1.);
    
//Shadows
//P+=N*0.05; FinalColor=vec4(Trace(Player,normalize(P-Player),CR,1.5).xyz,1.);
} 
]]

SCNV=[[
uniform mat4 modelViewProjection;
attribute vec4 position;
attribute vec2 texCoord;
varying vec2 vt;
void main() {
    vt=texCoord;
    gl_Position=modelViewProjection*position;
}
]]

SCNF=[[
precision highp float;
varying vec2 vt;
uniform sampler2D depth;
uniform vec2 FA;
uniform vec2 vg;
uniform mat4 iView;
#define far 20.
#define normh 0.1
const highp vec2 Values=vec2(1./255.,1./65025.);

float decodeDepth(vec3 c) { return dot(c,vec3(1.,Values.x,Values.y)); }

vec3 ToPos(vec2 vt,float f) {
    vec2 uv=vt*2.-1.;
    highp float Z=f*far;
    highp float X=uv.x*FA.x*FA.y*Z;
    highp float Y=uv.y*FA.x*Z;
    highp vec4 fPos=iView*vec4(X,Y,-Z,1.);
    return fPos.xyz/fPos.w;
}

vec3 ToNorm(vec2 vt, float D, vec3 P) {
    vec2 vt1=vt+vec2(vg.x,0.);
    float d1=decodeDepth(texture2D(depth,vt1).xyz);
    float d11=decodeDepth(texture2D(depth,vt-vec2(vg.x,0.)).xyz);
    if (abs(d1-D)*far>normh) { d1=(D-d11)+D; }
    vec2 vt2=vt+vec2(0.,vg.y);
    float d2=decodeDepth(texture2D(depth,vt2).xyz);
    float d22=decodeDepth(texture2D(depth,vt-vec2(0.,vg.y)).xyz);
    if (abs(d2-D)*far>normh) { d2=(D-d22)+D;}
    vec3 p1=ToPos(vt1,d1);
    vec3 p2=ToPos(vt2,d2);
    vec3 norm=normalize(cross(p1-P,p2-P));
    return norm;
}

void main() {
    float D=decodeDepth(texture2D(depth,vt).xyz);
    if (D>0.99) discard;
    vec3 ppos=ToPos(vt,D);
    highp vec3 norm=ToNorm(vt,D,ppos);
    gl_FragColor=vec4(norm*0.5+0.5,1.);
}
]]

SMIPV=[[
uniform mat4 modelViewProjection;
attribute vec4 position;
attribute vec2 texCoord;
varying vec2 vt;
void main() {
    vt=texCoord;
    gl_Position=modelViewProjection*position;
}
]]

SMIPF=[[
precision highp float;
uniform vec4 vg[3];
uniform vec4 vgoffset[6];
uniform vec3 GI;
uniform vec3 IGI;
uniform sampler2D vlight;
varying vec2 vt;

void main() {
    vec4 ivg=vg[int(floor(vt.y*3.))]; vec2 cvt;
    vec4 vgoff=vgoffset[int(floor(vt.y*6.))];
vec2 pvt=vec2(floor(vt.x*GI.z)*IGI.z+fract(vt.x*GI.z)*IGI.z*0.5,vt.y)+vgoff.zw;

    vec4 tex=texture2D(vlight,pvt);
    vec4 col=(tex.w>0.)?tex:texture2D(vlight,pvt+vgoff.xy);
    cvt=pvt+ivg.xy; tex=texture2D(vlight,cvt);
    col+=(tex.w>0.)?tex:texture2D(vlight,cvt+vgoff.xy);
    cvt=pvt+ivg.zw; tex=texture2D(vlight,cvt);
    col+=(tex.w>0.)?tex:texture2D(vlight,cvt+vgoff.xy);
    cvt=pvt+ivg.xy+ivg.zw; tex=texture2D(vlight,cvt);
    col+=(tex.w>0.)?tex:texture2D(vlight,cvt+vgoff.xy);
    gl_FragColor=col*0.25;
    //gl_FragColor=vec4(col.xyz/col.w,col.w*0.25);
}
]]

SILV=[[
uniform mat4 modelViewProjection;
attribute vec4 position;
attribute vec2 texCoord;
varying vec2 vt;
void main() {
    vt=texCoord;
    gl_Position=modelViewProjection*position;
}
]]

SILF=[[
precision highp float;
uniform vec3 GI;
uniform vec3 IGI;
uniform vec3 normals[6];
uniform sampler2D colors;
uniform sampler2D shadow;
uniform vec3 lp;
uniform vec3 ld;
uniform vec3 lc;
uniform float lr;
uniform float spot;
uniform mat4 lmat;
varying vec2 vt;
#define DIM vec3(GI.x*0.25,GI.y*0.25,GI.z*0.25)
#define IDIM vec3(1./DIM.x,1./DIM.y,1./DIM.z)
const highp vec2 Values=vec2(1./255.,1./65025.);

float decodeDepth(vec3 c) { return dot(c,vec3(1.,Values.x,Values.y)); }

float Shadows(vec3 p) {
    vec4 lppos=lmat*vec4(p,1.);
    vec2 lvt=lppos.xy/lppos.w*0.5+0.5;
    float lD=decodeDepth(texture2D(shadow,lvt).xyz);
    return (lppos.z>lD*lr+0.02)?0.:1.;
}

void main() {
    vec2 VT=vec2(vt.x,fract(vt.y*6.));
    vec4 C=texture2D(colors,VT);
    if (C.w==0.) {
        gl_FragColor=vec4(0.);
    } else if (C.w*255.==250.) {
        gl_FragColor=vec4(C.xyz,1.);//ceil(C.w);
    } else {
        vec3 N=normals[int(floor(vt.y*6.))];
        vec3 Pos=vec3(fract(VT.x*GI.z)*DIM.x,VT.y*DIM.y,floor(VT.x*GI.x)*IGI.x*DIM.z)+vec3(0.,0.,0.125);
        vec3 vP=Pos+N*0.25;
        float zf=floor(vP.z*4.)*IGI.z;
        vec2 pvt=vec2(vP.x*IDIM.x*IGI.z+zf,vP.y*IDIM.y);
    if (texture2D(colors,pvt).w==0.) {
        //LIGHT
        vec3 ltp=normalize(lp-Pos);
        float dota=dot(ld,ltp);
        float cosa=max(0.,1.-(1.-dota)/(1.-spot));
        vec3 col=lc*C.xyz*max(dot(N,ltp),0.)*max(0.,1.-length(lp-Pos)/lr)*cosa
        *Shadows(Pos+N.xyz*0.125);
        gl_FragColor=vec4(col,1.);
    } else gl_FragColor=vec4(0.,0.,0.,1.);
    }
}
]]

SSBV=[[
#version 300 es
uniform mat4 modelViewProjection;
in vec4 position;
in vec2 texCoord;
out vec2 vt;
void main() {
    vt=texCoord;
    gl_Position=modelViewProjection*position;
}
]]

SSBF=[[
#version 300 es
precision highp float;
uniform sampler2D vlight;
uniform sampler2D vcol;
uniform sampler2D vmipmap1;
uniform sampler2D vmipmap2;
uniform sampler2D vmipmap3;
uniform vec3 normals[6];
uniform vec3 tangents[6];
uniform vec3 binormals[6];
uniform vec4 FAR;
uniform vec3 GI;
uniform vec3 IGI;
in vec2 vt;
out vec4 FinalColor;
#define far 20.
#define DIM vec3(GI.x*0.25,GI.y*0.25,GI.z*0.25)
#define IDIM vec3(1./DIM.x,1./DIM.y,1./DIM.z)
#define sixth 1./6.
#define sixth2 2./6.
#define sixth3 3./6.
#define sixth4 4./6.
#define sixth5 5./6.
//MipMaps
#define GI2 vec3(GI.x*0.5,GI.y*0.5,GI.z*0.5)
#define IGI2 vec3(IGI.x*2.,IGI.y*2.,IGI.z*2.)
#define GI3 vec3(GI.x*0.25,GI.y*0.25,GI.z*0.25)
#define IGI3 vec3(IGI.x*4.,IGI.y*4.,IGI.z*4.)
#define GI4 vec3(GI.x*0.125,GI.y*0.125,GI.z*0.125)
#define IGI4 vec3(IGI.x*8.,IGI.y*8.,IGI.z*8.)
const highp vec2 Values=vec2(1./255.,1./65025.);

float decodeDepth(vec3 c) { return dot(c,vec3(1.,Values.x,Values.y)); }

mat3 TBN(vec3 N, int Ni) {
    vec3 Nt=tangents[Ni];
    vec3 Nb=binormals[Ni];
    return mat3(Nt.x,Nb.x,N.x,Nt.y,Nb.y,N.y,Nt.z,Nb.z,N.z);
}
/*
vec4 MIX(vec3 vP, vec2 bvt, vec2 frek, sampler2D img) {
    float f=fract(vP.z*frek.x);
    vec4 rvc=(f>0.5)?mix(texture(img,bvt),texture(img,bvt+vec2(frek.y,0.)),f-0.5)
    :mix(texture(img,bvt-vec2(frek.y,0.)),texture(img,bvt),f+0.5);
    return rvc;
}*/

vec4 MIX(vec3 vP, vec2 bvt, vec2 frek, sampler2D img) {
    float f=fract(vP.z*frek.x);
vec4 rvc=(f>0.5)?
mix(texture(img,bvt),texture(img,((bvt+vec2(frek.y,0.)).x>1.)?bvt:bvt+vec2(frek.y,0.)),f-0.5)
:mix(texture(img,((bvt-vec2(frek.y,0.)).x<0.)?bvt:bvt-vec2(frek.y,0.)),
texture(img,bvt),f+0.5);
    return rvc;
}

vec4 VoxelFetch(vec2 pvt, vec3 vP, vec3 vD, vec2 frek, sampler2D img, vec3 bgi, vec3 ibgi) {
    vec2 Min=vec2(floor(pvt.x*bgi.z)*ibgi.z+0.5*ibgi.z*ibgi.x,
        floor(pvt.y*6.)*sixth+0.5*ibgi.y*sixth);
    vec2 Max=vec2(Min.x+ibgi.z-ibgi.z*ibgi.x,
        Min.y+sixth-ibgi.y*sixth);
    pvt=clamp(pvt,Min,Max);
    
    vec3 vDS=vD.xyz*vD.xyz; vec4 xC,yC,zC;
    xC=(vD.x>0.)?MIX(vP,pvt+vec2(0,sixth),frek,img):
    MIX(vP,pvt,frek,img);
    if (xC.w==0.) return vec4(0.);
    yC=(vD.y>0.)?MIX(vP,pvt+vec2(0,sixth3),frek,img):
    MIX(vP,pvt+vec2(0,sixth2),frek,img);
    zC=(vD.z>0.)?MIX(vP,pvt+vec2(0,sixth5),frek,img):
    MIX(vP,pvt+vec2(0,sixth4),frek,img);
    return xC*vDS.x+yC*vDS.y+zC*vDS.z;
}

vec4 GetVoxel(vec3 vP, vec3 vD, float lod) {
    if (lod<1.) {
        float zf=floor(vP.z*4.)*IGI.z;
        vec2 pvt=vec2(vP.x*IDIM.x*IGI.z+zf,vP.y*IDIM.y*sixth);
        return VoxelFetch(pvt,vP,vD,vec2(4.,IGI.z),vlight,GI,IGI);
    } else if (lod<2.) {
        float zf=floor(vP.z*2.)*IGI2.z;
        vec2 pvt=vec2(vP.x*IDIM.x*IGI2.z+zf,vP.y*IDIM.y*sixth);
        return VoxelFetch(pvt,vP,vD,vec2(2.,IGI2.z),vmipmap1,GI2,IGI2);
    } else if (lod<3.) {
        float zf=floor(vP.z)*IGI3.z;
        vec2 pvt=vec2(vP.x*IDIM.x*IGI3.z+zf,vP.y*IDIM.y*sixth);
        return VoxelFetch(pvt,vP,vD,vec2(1.,IGI3.z),vmipmap2,GI3,IGI3);
    } else {
        float zf=floor(vP.z*0.5)*IGI4.z;
        vec2 pvt=vec2(vP.x*IDIM.x*IGI4.z+zf,vP.y*IDIM.y*sixth);
        return VoxelFetch(pvt,vP,vD,vec2(0.5,IGI4.z),vmipmap3,GI4,IGI4);
    }
}

vec4 Trace60(vec3 vP, vec3 vD) {
    vec4 sC,fc=vec4(0.); float sL=0.; vec3 sP; float vdist=0.25;
    while (vdist<10. && fc.w<0.95) {
        sP=vP+vD*vdist;
        if (sP.x<0. || sP.y<0. || sP.z<0. || sP.x>DIM.x || sP.y>DIM.y || sP.z>DIM.z) break;
        sC=GetVoxel(sP,vD,sL);
        fc=fc+sC*(1.-fc.w);
        sL=sL+1.;
        vdist=min(vdist+1.,vdist*2.);
    }
    return fc;
}

void main() {
    ivec2 ivt=ivec2(vt.x*GI.x*GI.z,fract(vt.y*6.)*GI.y);
    vec4 Albedo=texelFetch(vcol,ivt,0);
    if (Albedo.w==0.) discard;
    int Ni=int(floor(vt.y*6.)); vec3 N=normals[Ni]; mat3 NM=TBN(N,Ni);
    vec2 VT=vec2(vt.x,fract(vt.y*6.));
vec3 P=vec3(fract(VT.x*GI.z)*DIM.x,VT.y*DIM.y,floor(VT.x*GI.x)*IGI.x*DIM.z);
    //Attributer
    vec3 DirectL=texture(vlight,vt).xyz;
    //Strålföljning
    if (Albedo.w*255.==250.)
        FinalColor=vec4(Albedo.xyz,1.); //EMISSIVE
    else {
        P=P+N*0.35;
        FinalColor=vec4((Trace60(P,N)+Trace60(P,vec3(-0.866,0.,0.5)*NM)+
        Trace60(P,vec3(0.866,0.,0.5)*NM)+Trace60(P,vec3(0.,0.886,0.5)*NM)+
        Trace60(P,vec3(0.,-0.866,0.5)*NM)).xyz*0.32
        *Albedo.xyz+DirectL,1.);
    }
} 
]]

SSPOTV=[[
uniform mat4 modelViewProjection;
attribute vec4 position;
attribute vec2 texCoord;
varying vec4 pos;
void main(){
    pos=modelViewProjection*position;
    gl_Position=modelViewProjection*position;
}
]]

SSPOTF=[[
precision highp float;
varying vec4 pos;
uniform sampler2D shadow;
uniform sampler2D depth;
uniform vec3 lp;
uniform vec3 lc;
uniform float lr;
uniform vec3 dir;
uniform float spot;
uniform vec2 FA;
uniform mat4 iView;
#define far 20.
const highp vec2 Values=vec2(1./255.,1./65025.);
uniform mat4 lmat;

float decodeDepth(vec3 c) { return dot(c,vec3(1.,Values.x,Values.y)); }

vec3 ToPos(vec2 vt,float f) {
    vec2 uv=vt*2.-1.;
    highp float Z=f*far;
    highp float X=uv.x*FA.x*FA.y*Z;
    highp float Y=uv.y*FA.x*Z;
    highp vec4 fPos=iView*vec4(X,Y,-Z,1.);
    return fPos.xyz/fPos.w;
}

void main() {
    if (!gl_FrontFacing) discard;
    vec2 vt=pos.xy/pos.w*0.5+0.5;
    float D=decodeDepth(texture2D(depth,vec2(vt.x*0.5+0.5,vt.y)).xyz);
    if (D>0.99) discard;
    //Shadow
    vec3 ppos=ToPos(vt,D);
    vec4 lppos=lmat*vec4(ppos,1.);
    vec2 lvt=lppos.xy/lppos.w*0.5+0.5;
    float lD=decodeDepth(texture2D(shadow,lvt).xyz);
    if (lppos.z>lD*lr+0.02) discard;
    //Light
    vec3 norm=texture2D(depth,vec2(vt.x*0.5,vt.y)).xyz; norm=norm*2.-1.;
    vec3 ltp=normalize(lp-ppos);
    float dota=dot(dir,ltp);
    float cosa=max(0.,1.-(1.-dota)/(1.-spot));
    vec3 col=lc*max(0.,dot(norm,ltp))*cosa*max(0.,1.-length(lp-ppos)/lr);
    gl_FragColor=vec4(col,1.);
}
]]

SPV=[[
uniform mat4 modelViewProjection;
attribute vec4 position;
varying highp vec4 pos;
varying vec4 plp;
uniform vec3 lp;
uniform mat4 viewproj;
void main(){
    plp=viewproj*vec4(lp,1.); plp.xy=(plp.xy/plp.w)*0.5+0.5;
    pos=modelViewProjection*position;
    gl_Position=pos;
}
]]

SPF=[[
precision highp float;
varying vec4 pos;
varying vec4 plp;
uniform sampler2D depth;
uniform vec3 lp;
uniform vec3 lc;
uniform float lr;
uniform vec2 FA;
uniform mat4 iView;
#define far 20.
#define normh far*0.002
const highp vec2 Values=vec2(1./255.,1./65025.);

float decodeDepth(vec3 c) { return dot(c,vec3(1.,Values.x,Values.y)); }

vec3 ToPos(vec2 vt,float f) {
    vec2 uv=vt*2.-1.;
    highp float Z=f*far;
    highp float X=uv.x*FA.x*FA.y*Z;
    highp float Y=uv.y*FA.x*Z;
    highp vec4 fPos=iView*vec4(X,Y,-Z,1.);
    return fPos.xyz/fPos.w;
}

void main() {
    if (gl_FrontFacing) discard;
    vec2 vt=(pos.xy/pos.w)*0.5+0.5;
    float D=decodeDepth(texture2D(depth,vec2(vt.x*0.5+0.5,vt.y)).xyz);
    if (D>0.99) discard;
    float light=1.;
    /*Shadows
    float vpz=-(D*far);
    float steps=35.;//ceil(length((vt-plp.xy)*vec2(124.,128.)));
    float iste=1./steps;
    vec2 dvt=(plp.xy-vt)*iste;
    float dz=(plp.z+vpz)*iste;
    vec2 cvt=vt; float cz=-vpz-0.01;
    for (int i=0; i<int(steps)-2; i++) {
        cvt=cvt+dvt; cz=cz+dz;
        light*=cz>decodeDepth(texture2D(depth,vec2(cvt.x*0.5+0.5,cvt.y)).xyz)*far?0.:1.;
    }
    //*/
    vec3 ppos=ToPos(vt,D);
    vec3 norm=texture2D(depth,vec2(vt.x*0.5,vt.y)).xyz; norm=norm*2.-1.;
    vec3 col=lc*max(0.,dot(norm,normalize(lp-ppos)))*max(0.,1.-length(lp-ppos)/lr);
    gl_FragColor=vec4(col*light,1.);
}
]]

