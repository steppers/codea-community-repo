--shader
diffuseShader={
vertexShader=[[

uniform mat4 modelViewProjection;
uniform mat4 mModel;
uniform vec4 directColor;
uniform vec4 directDirection;

attribute vec4 position;
attribute vec4 color;
attribute vec2 texCoord;
attribute vec3 normal;

varying lowp vec4 vColor;
varying highp vec2 vTexCoord;
varying vec4 vDirectDiffuse;

void main()
{
    vColor = color;
    gl_Position = modelViewProjection * position;
    vTexCoord = texCoord;
    vec4 norm = normalize(mModel * vec4( normal, 0.0 ));
    vDirectDiffuse = directColor * max( 0.0, dot( norm, directDirection ));
}

]],

fragmentShader=[[

precision highp float;
uniform vec4 ambientColor;
uniform lowp sampler2D texture;
uniform float reflect;
uniform bool hasTexture;

uniform vec4 directColor;
uniform float directStrength;
uniform vec4 directDirection;

varying lowp vec4 vColor;
varying highp vec2 vTexCoord;
varying vec4 vDirectDiffuse;

void main()
{
    lowp vec4 ambient=vec4(0.,0.,0.,0.);
    lowp vec4 diffuse=vec4(0.,0.,0.,0.);
    lowp vec4 pixel;
    if (hasTexture) pixel = texture2D( texture, vTexCoord);
    else pixel = vColor;
    ambient = pixel * ambientColor;
    diffuse = diffuse + pixel * vDirectDiffuse;
    vec4 totalColor = clamp( reflect * (ambient + diffuse),0.,1.);   
    totalColor.a=1.;
    gl_FragColor=totalColor;
}
]]
}
