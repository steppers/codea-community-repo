LightChef = {
Vertex = [[
uniform mat4 modelViewProjection;

attribute vec4 position;
attribute vec2 texCoord;

varying highp vec2 vTexCoord;

void main()
{
    vTexCoord = texCoord;
    
    gl_Position = modelViewProjection * position;
}
]],
Fragment = [[
precision highp float;

uniform lowp sampler2D texture;
uniform float heightSampleScale;
uniform float resStep;

uniform float sunAngle;

varying highp vec2 vTexCoord;

void main()
{
    highp vec4 heightSample = texture2D( texture, vTexCoord );
    highp float mid = (heightSample.r * 25.0 + heightSample.g * 10.0 + heightSample.b) * heightSampleScale;
    heightSample = texture2D( texture, vTexCoord + vec2(-resStep,0) );
    highp float left = (heightSample.r * 25.0 + heightSample.g * 10.0 + heightSample.b) * heightSampleScale;
    heightSample = texture2D( texture, vTexCoord + vec2(resStep,0) );
    highp float right = (heightSample.r * 25.0 + heightSample.g * 10.0 + heightSample.b) * heightSampleScale;
    heightSample = texture2D( texture, vTexCoord + vec2(0,-resStep) );
    highp float up = (heightSample.r * 25.0 + heightSample.g * 10.0 + heightSample.b) * heightSampleScale;
    heightSample = texture2D( texture, vTexCoord + vec2(0,resStep) );
    highp float down = (heightSample.r * 25.0 + heightSample.g * 10.0 + heightSample.b) * heightSampleScale;
    
    vec3 va = normalize( vec3(resStep, ((left+mid)-(right+mid))/2.0, 0.0) );
    vec3 vb = normalize( vec3(0.0, ((down+mid)-(up+mid))/2.0, -resStep) );

    vec3 normal = normalize( cross(va, vb) );
    
    highp vec4 col = vec4(0.0,0.0,0.0,0.0);
    
    //snow is stronger at altitude
    col.r = pow(mid / (36.0 * heightSampleScale),2.0) * 4.0;

    //stone on steep bits
    col.g = (1.0 - normal.y) *3.0;    

    //grass what's left
    col.b = 1.0 - col.r - col.g;

    
    
    //light first
    col.a = dot(normal, normalize(vec3(resStep, sunAngle, 0.0)));
    
    heightSample = texture2D( texture, vTexCoord );
    highp float height = (heightSample.r * 25.0 + heightSample.g * 10.0 + heightSample.b) * heightSampleScale;
    highp float leftHeight;
    
    for (highp int i=1; i< 200; i=i+5) {
        heightSample = texture2D(texture, vTexCoord + vec2(-resStep*float(i),0));
        leftHeight = (heightSample.r * 25.0 + heightSample.g * 10.0 + heightSample.b) * heightSampleScale;
        if (leftHeight > height + sunAngle * float(i) && vTexCoord.x - resStep*float(i) > 0.0) {
            col.a = 0.0;
        }
    }
    col.a = col.a + 0.2;
    gl_FragColor = col;
}
]]}


