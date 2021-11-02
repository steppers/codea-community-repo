--Shaders
FrameBlendNoTex = { --models with no texture image
    splineVert= --vertex shader with catmull rom spline interpolation of key frames
    [[   
    uniform mat4 modelViewProjection;
    uniform mat4 modelMatrix;
    uniform float ambient; // --strength of ambient light 0-1
    uniform vec4 eye; // -- position of camera (x,y,z,1)
    uniform vec4 light; //--directional light direction (x,y,z,0)
    uniform vec4 lightColor;

    uniform int frames[4]; //contains indexes to 4 frames needed for CatmullRom
    uniform float frameBlend; // how much to blend by
    float frameBlend2 = frameBlend * frameBlend; //pre calculated squared and cubed for Catmull Rom
    float frameBlend3 = frameBlend * frameBlend2;
    
    attribute vec4 color;

    attribute vec3 position;
    attribute vec3 position1;
    attribute vec3 position2; //not possible for attributes to be arrays in Gl Es2.0 
    attribute vec3 position3;
    attribute vec3 position4;
    
    attribute vec3 normal;
    attribute vec3 normal1;
    attribute vec3 normal2;
    attribute vec3 normal3;
    attribute vec3 normal4;
    
    vec3 getPos(int no) //home-made hash, ho hum.  
    {
        if (no==0) return position;
        if (no==1) return position1;
        if (no==2) return position2;
        if (no==3) return position3;
        if (no==4) return position4;
    }
    
    vec3 getNorm(int no)
    {
        if (no==0) return normal;
        if (no==1) return normal1;
        if (no==2) return normal2;
        if (no==3) return normal3;
        if (no==4) return normal4;
    }
          
    varying lowp vec4 vAmbient;
    varying lowp vec4 vColor;
    varying vec4 vDirectDiffuse;
    
    vec3 CatmullRom(float u, float u2, float u3, vec3 x0, vec3 x1, vec3 x2, vec3 x3 ) //returns value between x1 and x2
    {
    return ((2. * x1) + 
           (-x0 + x2) * u + 
           (2.*x0 - 5.*x1 + 4.*x2 - x3) * u2 + 
           (-x0 + 3.*x1 - 3.*x2 + x3) * u3) * 0.5;
    }
    
    void main()
    {       
        vec3 framePos = CatmullRom(frameBlend, frameBlend2, frameBlend3, getPos(frames[0]), getPos(frames[1]), getPos(frames[2]), getPos(frames[3]) );
       vec3 frameNorm = CatmullRom(frameBlend, frameBlend2, frameBlend3, getNorm(frames[0]), getNorm(frames[1]), getNorm(frames[2]), getNorm(frames[3]) );
    
        vec4 norm = normalize(modelMatrix * vec4( frameNorm, 0.0 ));

        vDirectDiffuse = lightColor * max( 0.0, dot( norm, light )); // direct color  vec4(1.0,1.0,1.0,1.0) 
        vAmbient = color * ambient;
        vAmbient.a = 1.; 
        vColor = color; 

        gl_Position = modelViewProjection * vec4(framePos, 1.);
    }
    
    ]],

    linearVert= --vertex shader with linear interpolation of key frames
    [[
    
    uniform mat4 modelViewProjection;
    uniform mat4 modelMatrix;
    uniform float ambient; // --strength of ambient light 0-1
    uniform vec4 eye; // -- position of camera (x,y,z,1)
    uniform vec4 light; //--directional light direction (x,y,z,0)
    uniform vec4 lightColor;
    
    uniform int frames[4]; //linear interpolation only uses the middle 2 values of this array. i wanted interface to be the same as the splineShader
    uniform float frameBlend; // how much to blend by
 
    attribute vec4 color;

    attribute vec3 position;
    attribute vec3 position2; //not possible for attributes to be arrays in Gl Es2.0 
    attribute vec3 position3;
    attribute vec3 position4;
    
    attribute vec3 normal;
    attribute vec3 normal2;
    attribute vec3 normal3;
    attribute vec3 normal4;
    
    vec3 getPos(int no) //home-made hash, ho hum.  
    {
        if (no==1) return position;
        if (no==2) return position2;
        if (no==3) return position3;
        if (no==4) return position4;
    }
    
    vec3 getNorm(int no)
    {
        if (no==1) return normal;
        if (no==2) return normal2;
        if (no==3) return normal3;
        if (no==4) return normal4;
    }
    
    varying lowp vec4 vAmbient;
    varying lowp vec4 vColor;
    varying vec4 vDirectDiffuse;
    
    void main()
    {
        vec3 framePos = mix(getPos(frames[2]), getPos(frames[3]), frameBlend);
        vec3 frameNorm = mix(getNorm(frames[2]), getNorm(frames[3]), frameBlend);
       
        vec4 norm = normalize(modelMatrix * vec4( frameNorm, 0.0 ));
        vDirectDiffuse = lightColor * max( 0.0, dot( norm, light )); // direct color    
    
        vAmbient = color * ambient;
        vAmbient.a = 1.; 
        vColor = color; 
        gl_Position = modelViewProjection * vec4(framePos, 1.);
    }
    
    ]],
    
    frag = [[
    precision highp float;

    varying lowp vec4 vColor;
    varying lowp vec4 vAmbient;  
    varying vec4 vDirectDiffuse;
    
    void main()
    {
        gl_FragColor=vAmbient + vColor * vDirectDiffuse; //
    }
    
    ]]
    }
    
    FrameBlendTex = { --models with a texture image
    splineVert=
    [[
    
    uniform mat4 modelViewProjection;
    uniform mat4 modelMatrix;
    uniform float ambient; // --strength of ambient light 0-1
    uniform vec4 eye; // -- position of camera (x,y,z,1)
    uniform vec4 light; //--directional light direction (x,y,z,0)
    uniform vec4 lightColor;

    uniform int frames[4]; //contains indexes to 4 frames needed for CatmullRom
    uniform float frameBlend; // how much to blend by
    float frameBlend2 = frameBlend * frameBlend; //pre-calculated squared and cubed for Catmull Rom
    float frameBlend3 = frameBlend * frameBlend2;
    
    attribute vec4 color;
    attribute vec2 texCoord;
    
    attribute vec3 position;
    attribute vec3 position2; //not possible for attributes to be arrays in Gl Es2.0 
    attribute vec3 position3;
    attribute vec3 position4;
    
    attribute vec3 normal;
    attribute vec3 normal2;
    attribute vec3 normal3;
    attribute vec3 normal4;
    
    vec3 getPos(int no) //home-made hash, ho hum.  
    {
        if (no==1) return position;
        if (no==2) return position2;
        if (no==3) return position3;
        if (no==4) return position4;
    }
    
    vec3 getNorm(int no)
    {
        if (no==1) return normal;
        if (no==2) return normal2;
        if (no==3) return normal3;
        if (no==4) return normal4;
    }
          
    varying lowp vec4 vAmbient;
    varying lowp vec4 vColor;
    varying highp vec2 vTexCoord;
    varying vec4 vDirectDiffuse;
    
    vec3 CatmullRom(float u, float u2, float u3, vec3 x0, vec3 x1, vec3 x2, vec3 x3 ) //returns value between x1 and x2
    {
    return ((2. * x1) + 
           (-x0 + x2) * u + 
           (2.*x0 - 5.*x1 + 4.*x2 - x3) * u2 + 
           (-x0 + 3.*x1 - 3.*x2 + x3) * u3) * 0.5;
    }
    
    void main()
    {       
        vec3 framePos = CatmullRom(frameBlend, frameBlend2, frameBlend3, getPos(frames[0]), getPos(frames[1]), getPos(frames[2]), getPos(frames[3]) );
       vec3 frameNorm = CatmullRom(frameBlend, frameBlend2, frameBlend3, getNorm(frames[0]), getNorm(frames[1]), getNorm(frames[2]), getNorm(frames[3]) );
    
        vec4 norm = normalize(modelMatrix * vec4( frameNorm, 0.0 ));
        vDirectDiffuse = lightColor * max( 0.0, dot( norm, light )); // direct color  vec4(1.0,1.0,1.0,1.0)
    
        vAmbient = color * ambient;
        vAmbient.a = 1.; 
        vColor = color; 
        vTexCoord = texCoord;
        gl_Position = modelViewProjection * vec4(framePos, 1.);
    }
    
    ]],

    linearVert=
    [[  
    uniform mat4 modelViewProjection;
    uniform mat4 modelMatrix;
    uniform float ambient; // --strength of ambient light 0-1
    uniform vec4 eye; // -- position of camera (x,y,z,1)
    uniform vec4 light; //--directional light direction (x,y,z,0)
    uniform vec4 lightColor;
    
    uniform int frames[4]; //linear interpolation only uses the middle 2 values of this array. i wanted interface to be the same as the splineShader
    uniform float frameBlend; // how much to blend by
 
    attribute vec4 color;
    attribute vec2 texCoord;   
    
    attribute vec3 position;
    attribute vec3 position2; //not possible for attributes to be arrays in Gl Es2.0 
    attribute vec3 position3;
    attribute vec3 position4;
    
    attribute vec3 normal;
    attribute vec3 normal2;
    attribute vec3 normal3;
    attribute vec3 normal4;
    
    vec3 getPos(int no) //home-made hash, ho hum.  
    {
        if (no==1) return position;
        if (no==2) return position2;
        if (no==3) return position3;
        if (no==4) return position4;
    }
    
    vec3 getNorm(int no)
    {
        if (no==1) return normal;
        if (no==2) return normal2;
        if (no==3) return normal3;
        if (no==4) return normal4;
    }
    
    varying lowp vec4 vAmbient;
    varying lowp vec4 vColor;
    varying highp vec2 vTexCoord;
    varying vec4 vDirectDiffuse;
    
    void main()
    {
        vec3 framePos = mix(getPos(frames[2]), getPos(frames[3]), frameBlend);
        vec3 frameNorm = mix(getNorm(frames[2]), getNorm(frames[3]), frameBlend);
       
        vec4 norm = normalize(modelMatrix * vec4( frameNorm, 0.0 ));

        vDirectDiffuse = lightColor * max( 0.0, dot( norm, light )); // direct color    
        vAmbient = color * ambient;
        vAmbient.a = 1.; 
        vColor = color; 
        vTexCoord = texCoord;

        gl_Position = modelViewProjection * vec4(framePos, 1.);
    }
    
    ]],
    
    frag = [[
    
    precision highp float;
    
    uniform lowp sampler2D texture;

    varying lowp vec4 vColor;
    varying highp vec2 vTexCoord;
    varying lowp vec4 vAmbient;   
    varying vec4 vDirectDiffuse;
    
    void main()
    {
        vec4 pixel= texture2D( texture, vTexCoord ); // * vColor nb color already included in ambient
        vec4 ambient = pixel * vAmbient;

        gl_FragColor=ambient + pixel * vDirectDiffuse; 
    }
    
    ]]
}

