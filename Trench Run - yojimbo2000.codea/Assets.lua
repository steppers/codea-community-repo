function checkAssets()
    shaders()
    Models = {

    {name = "XWing", shade = SpecularShader, shininess = .5, specularPower = 6 },
    {name = "TieFighter", texture = "TieFighter.jpg", shade = DiffuseTexShader, shininess = .5, specularPower = 6 },
    {name = "trench", texture = "TieFighter.jpg", shade = shader(DiffuseTex.vert, DiffuseTex.frag), normals = CalculateNormals, inverseNormals = -1}, --trench_1_texture0.png --vertInst
    }
    
    local missing, missingArray = {}, {} --first pass use key-value to catch duplicate file names
    
    local function checkTextAsset(name, suffix)
  --      if not readText(asset.documents.Dropbox..name.."_"..suffix) then
        if not readText(asset..name.."_"..suffix) then
            missing[name.."."..suffix] = true
        end
    end
    
    local function checkImageAsset(name)
        if name then
            local trim = name:match("(.-)%..-$")
  --          if not readImage(asset.documents.Dropbox..trim) then
            if not readImage(asset..trim) then
                missing[name] = true
            end
        end
    end
    
    for i,v in ipairs(Models) do
        checkTextAsset(v.name, "obj")
        checkTextAsset(v.name, "mtl")
        checkImageAsset(v.texture)
    end
    checkImageAsset("explosion.png")
    
    for k,_ in pairs(missing) do --convert to array
        table.insert(missingArray, k)
    end
    
    if #missingArray > 0 then
        print("Requesting remote files:", table.concat(missingArray, "; "))
        http.requestMany{url = "https://raw.githubusercontent.com/Utsira/Codea-OBJ-Importer/master/models/", 
        names = missingArray, onFinal = saveAssets, onEach = function() progress = progress + 1 end}
    else
        progress = 9
        loading = coroutine.create(buildAssets)
    end
end

function saveAssets(assetData)
    for name, data in pairs(assetData) do
        local file, ext = name:match("(.-)%.(.-)$")
        if ext == "mtl" or ext == "obj" then --obj mtl extension not supported so becomes name_obj.txt
            saveText(asset..file.."_"..ext, data)
            print("Saving text:", file.."_"..ext)
        elseif ext == "jpg" or ext=="png" then
            saveImage(asset..file, data)
            print("Saving image:", file.."."..ext)
        end
    end
    loading = coroutine.create(buildAssets)
end

function buildAssets()  
    print("buildAssets starting")
    for i,v in ipairs(Models) do
        loadModel(v)
        coroutine.yield(i)
    end
    print("buildAssets done loading models")
    model.playerBolt = bolt(
    color(237, 100, 255, 255),  color(19, 15, 20, 255))
    model.enemyBolt = bolt(
    color(136, 255, 130, 255),  color(15, 20, 14, 255))
    print("bolts", model.playerBolt, model.enemyBolt)
    explosionAssets()
    print("buildAssets at end")
end

function loadModel(v)
    v.obj = readText(asset..v.name.."_obj.txt")
    v.mtl = readText(asset..v.name.."_mtl.txt")
    if v.texture then 
        local trim = v.texture:match("(.-)%..-$")
        v.texture = readImage(asset..trim)
    end
    model[v.name] = OBJ.load(v)
end

function tetrahedron(l,l2, c1, c2)
    print("making a tetrahedron", "l", l, "l2", l2, "c1", c1, "c2", c2)
    local l2 = l2 or l
    print("l2", l2)
    local z = 1/math.sqrt(2)
    print("z", z)
    local p = {vec3(1,0,z)*l, vec3(-1,0,z)*l, vec3(0,1,-z)*l, vec3(0,-1,-z)*l2}
    print("p", p)
    local cp = {c1, c1, c1, c2}
    print("cp", cp)
    local v,c = {}, {}
    print("v, c", v, c)
    local m = matrix():rotate(180,0,0,1):rotate(55, 1,0,0)
    print("m", m)
    
    for i = 0,3 do
        local j,k = (i+1)%4, (i+2)%4
        v[#v+1] = m * p[i+1]
        v[#v+1] = m * p[j+1]
        v[#v+1] = m * p[k+1]
        c[#c+1] = cp[i+1]
        c[#c+1] = cp[j+1]
        c[#c+1] = cp[k+1]
    end
    return v,c
end

function bolt(c1, c2)
    print("making a bolt")
    local m = mesh() --single sheet for all bullets
    local v, c= tetrahedron(0.2,1.5, 
    c1, c2) --color(65, 30, 71, 255)
    print("tetrahedron results", v, c)
    local n = CalculateNormals(v)
  --  local c = color(209, 59, 237, 255)
    m.vertices = v
    m.normals = n
    m.colors = c
 --   m:setColors(c)
    m.shader = shader(shDefault.vert, shDefault.frag) --DiffuseShader -- 
    return m
end

function shaders()
    DiffuseShader = shader(Diffuse.vert, Diffuse.frag)
    DiffuseTexShader = shader(DiffuseTex.vert, DiffuseTex.frag)
  --  DiffuseTexTileShader = shader(DiffuseTex.vert, DiffuseTexTile.frag)
    SpecularShader = shader(DiffuseSpecular.vert, DiffuseSpecular.frag)
    SpecularTexShader = shader(DiffuseSpecularTex.vert, DiffuseSpecularTex.frag)
end

DiffuseTex = { 
vert = [[

uniform mat4 modelViewProjection;
uniform mat4 modelMatrix;
uniform float flash;

attribute vec4 position;
attribute vec4 color;
attribute vec2 texCoord;
attribute vec3 normal;

varying lowp vec4 vNormal;
varying mediump vec4 vColor;
varying highp vec2 vTexCoord;
varying lowp vec4 vPosition;

void main()
{
    vNormal = normalize(modelMatrix * vec4( normal, 0.0 ));
    vPosition = modelMatrix * position;
    //vColor = color * flash;
     float dist = clamp((vPosition.z * 0.004), 0.0, 1.1);
      vColor = mix(color, vec4(0.,0.,0.,1.), dist) * flash;
    vTexCoord = texCoord;
    gl_Position = modelViewProjection * position;
}

]],

vertInst = [[
#extension GL_EXT_draw_instanced: enable

uniform mat4 modelViewProjection;
uniform mat4 modelMatrix;

attribute vec4 position;
attribute vec4 color;
attribute vec2 texCoord;
attribute vec3 normal;

varying lowp vec4 vNormal;
varying mediump vec4 vColor;
varying highp vec2 vTexCoord;
varying lowp vec4 vPosition;

void main()
{
    vNormal = normalize(modelMatrix * vec4( normal, 0.0 ));
    lowp vec4 pos = position;
    pos.z += float(gl_InstanceIDEXT) * 12.6;
   // pos.x *= (mod(float(gl_InstanceIDEXT), 2.) * 2.) - 1.;
    vPosition = modelMatrix * pos;
    float dist = clamp((vPosition.z * 0.004), 0.0, 1.1);
    vColor = mix(color, vec4(0.,0.,0.,1.), dist);
    vTexCoord = texCoord;
    gl_Position = modelViewProjection * pos;
}

]],

frag = [[

precision highp float;

uniform lowp sampler2D texture;
uniform float ambient; // --strength of ambient light 0-1
uniform vec4 light; //--directional light direction (x,y,z,0), 
uniform vec4 lightColor; //--directional light colour

varying lowp vec4 vNormal;
varying mediump vec4 vColor;
varying highp vec2 vTexCoord;
varying lowp vec4 vPosition;

void main()
{
    lowp vec4 pixel= texture2D( texture, vTexCoord ) * vColor; 
    lowp vec4 ambientLight = pixel * ambient;
    lowp vec4 norm = normalize(vNormal);
   // lowp vec4 lightDirection = normalize (light - vPosition * light.w);
    lowp vec4 diffuse = pixel * lightColor * max( 0.0, dot( norm, light ));
    vec4 totalColor = ambientLight + diffuse;
    totalColor.a=vColor.a;
    gl_FragColor=totalColor;
}

]]}

DiffuseTexTile = { 

frag = [[

precision highp float;

uniform lowp sampler2D texture;
uniform float ambient; // --strength of ambient light 0-1
uniform vec4 light; //--directional light direction (x,y,z,0)
uniform vec4 lightColor; //--directional light colour

varying lowp vec4 vNormal;
varying mediump vec4 vColor;
varying highp vec2 vTexCoord;
varying lowp vec4 vPosition;

void main()
{
    lowp vec4 pixel= texture2D( texture, fract(vTexCoord) ) * vColor; 
    lowp vec4 ambientLight = pixel * ambient;
    lowp vec4 norm = normalize(vNormal);
    lowp vec4 lightDirection = normalize (light - vPosition * light.w);
    lowp vec4 diffuse = pixel * lightColor * max( 0.0, dot( norm, lightDirection ));
    vec4 totalColor = ambientLight + diffuse;
    totalColor.a=vColor.a;
    gl_FragColor=totalColor;
}

]]}

Diffuse={ --no texture
vert = [[

uniform mat4 modelViewProjection;
uniform mat4 modelMatrix;

attribute vec4 position;
attribute vec4 color;
attribute vec3 normal;

varying lowp vec4 vNormal;
varying mediump vec4 vColor;
varying lowp vec4 vPosition;

void main()
{
    vNormal = normalize(modelMatrix * vec4( normal, 0.0 ));
    vColor = color;
    vPosition = modelMatrix * position;
    gl_Position = modelViewProjection * position;
}

]],

frag = [[

precision highp float;

uniform float ambient; // --strength of ambient light 0-1
uniform vec4 light; //--directional light direction (x,y,z,0)
uniform vec4 lightColor; //--directional light colour

varying lowp vec4 vNormal;
varying mediump vec4 vColor;
varying lowp vec4 vPosition;

void main()
{

    lowp vec4 ambientLight = vColor * ambient;
    lowp vec4 norm = normalize(vNormal);
    lowp vec4 lightDirection = normalize(light - vPosition * light.w);
    lowp vec4 diffuse = vColor * lightColor * max( 0.0, dot( norm, lightDirection ));
    vec4 totalColor = ambientLight + diffuse;
    totalColor.a=vColor.a;
    gl_FragColor=totalColor;
}

]]
}

DiffuseSpecular={
vert = [[

uniform mat4 modelViewProjection;
uniform mat4 modelMatrix;
uniform float flash;

attribute vec4 position;
attribute vec4 color;
attribute vec3 normal;

varying lowp vec4 vNormal;
varying lowp vec4 vPosition;
varying lowp vec4 vColor;

void main()
{
    vNormal = normalize(modelMatrix * vec4( normal, 0.0 ));
    vPosition = modelMatrix * position;
    vColor = color * flash;
    gl_Position = modelViewProjection * position;
}

]],

frag = [[

precision highp float;

uniform float ambient; // --strength of ambient light 0-1
uniform vec4 light; //--directional light direction (x,y,z,0)
uniform vec4 lightColor; //--directional light colour
uniform vec4 eye; // -- position of camera (x,y,z,1)
uniform float specularPower; //higher number = smaller, harder highlight
uniform float shininess;

varying lowp vec4 vNormal;
varying lowp vec4 vPosition;
varying lowp vec4 vColor;

void main()
{

    lowp vec4 ambientLight = vColor * ambient;
    lowp vec4 norm = normalize(vNormal);
  //  lowp vec4 lightDirection = normalize(light - vPosition * light.w);
    lowp vec4 diffuse = vColor * lightColor * max( 0.0, dot( norm, light ));

    //specular blinn-phong
    vec4 cameraDirection = normalize( eye - vPosition );
    vec4 halfAngle = normalize( cameraDirection + light );
    float spec = pow( max( 0.0, dot( norm, halfAngle)), specularPower );
    lowp vec4 specular = lightColor  * spec * shininess; 

    vec4 totalColor = ambientLight + diffuse + specular;
    totalColor.a=vColor.a;
    gl_FragColor=totalColor;
}

]]
}

DiffuseSpecularTex={
vert = [[

uniform mat4 modelViewProjection;
uniform mat4 modelMatrix;

attribute vec4 position;
attribute vec4 color;
attribute vec3 normal;
attribute vec2 texCoord;

varying highp vec2 vTexCoord;
varying lowp vec4 vNormal;
varying lowp vec4 vPosition;
varying lowp vec4 vColor;

void main()
{
    vNormal = normalize(modelMatrix * vec4( normal, 0.0 ));
    vPosition = modelMatrix * position;
    vColor = color;
    vTexCoord = texCoord;
    gl_Position = modelViewProjection * position;
}

]],

frag = [[

precision highp float;

uniform lowp sampler2D texture;
uniform float ambient; // --strength of ambient light 0-1
uniform vec4 light; //--directional light direction (x,y,z,0)
uniform vec4 lightColor; //--directional light colour
uniform vec4 eye; // -- position of camera (x,y,z,1)
uniform float specularPower; //higher number = smaller highlight
uniform float shininess;

varying lowp vec4 vNormal;
varying lowp vec4 vPosition;
varying lowp vec4 vColor;
varying highp vec2 vTexCoord;

void main()
{
    lowp vec4 pixel= texture2D( texture, vec2( fract(vTexCoord.x), fract(vTexCoord.y) ) ) * vColor; 
    lowp vec4 ambientLight = pixel * ambient;
    lowp vec4 norm = normalize(vNormal);
    lowp vec4 lightDirection = normalize(light - vPosition * light.w);
    lowp vec4 diffuse = pixel * lightColor * max( 0.0, dot( norm, lightDirection ));

    //specular blinn-phong
    vec4 cameraDirection = normalize( eye - vPosition );
    vec4 halfAngle = normalize( cameraDirection + lightDirection );
    float spec = pow( max( 0.0, dot( norm, halfAngle)), specularPower );
    lowp vec4 specular = lightColor  * spec * shininess; 

    vec4 totalColor = ambientLight + diffuse + specular;
    totalColor.a=vColor.a;
    gl_FragColor=totalColor;
}

]]
}

shDefault={
vert=[[
uniform mat4 modelViewProjection;

attribute vec4 position;
attribute vec4 color;
//attribute vec2 texCoord;

varying lowp vec4 vColor;
//varying highp vec2 vTexCoord;

void main()
{
    vColor = color;
   // vTexCoord = texCoord;
    
    gl_Position = modelViewProjection * position;
}
]],
frag=[[
precision highp float;

//uniform lowp sampler2D texture;

varying lowp vec4 vColor;
//varying highp vec2 vTexCoord;

void main()
{
   // lowp vec4 col = texture2D( texture, vTexCoord ) * vColor;

    gl_FragColor = vColor; //col;
}
]]
}

