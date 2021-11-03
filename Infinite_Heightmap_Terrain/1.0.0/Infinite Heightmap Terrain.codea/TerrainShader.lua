TerrainShader = {
vertex = [[
//#define DRAW_EDGES

attribute vec4 position;
attribute vec3 color;

uniform float terrainSize;
uniform float tileSize;
uniform float nodeScale;
uniform vec2 nodePos;
uniform mat4 modelViewProjection;
//uniform vec3 cameraPos;

uniform float heightSampleScale;
uniform vec4 lodScales;

uniform sampler2D texHeight;

varying vec2 groundTexCoords;

#ifdef DRAW_EDGES
varying vec3 baryCoords;
varying vec2 nodeCoords;
#endif

const float detailScale = 100.0;
const float eps = 0.001;

float moveEdgeCoord(float edgeCoord, float lodScale) {
  float m = mod(edgeCoord, lodScale);
  return step(0.5, m / lodScale) * lodScale + (edgeCoord - m);
}

void main() {
#ifdef DRAW_EDGES    
    baryCoords = color;
    nodeCoords = position.xz / tileSize;
#endif

    vec2 p = vec2(position.x, position.z);

    if (p.x < eps) {
        p.y = moveEdgeCoord(p.y, lodScales[0]);
    } else if (p.x > tileSize - eps) {
        p.y = moveEdgeCoord(p.y, lodScales[2]);           
    }   
    if (p.y < eps) {
        p.x = moveEdgeCoord(p.x, lodScales[1]);        
    } else if (p.y > tileSize - eps) {
        p.x = moveEdgeCoord(p.x, lodScales[3]);
    }
            
    vec3 pos = vec3(p.x * nodeScale + nodePos.x, 0.0, p.y * nodeScale + nodePos.y);    
    groundTexCoords = vec2(pos.x / terrainSize, pos.z / terrainSize);
    
    vec3 heightSample = texture2D(texHeight, groundTexCoords).rgb;
    pos.y = (heightSample.r * 25.0 + heightSample.g * 10.0 + heightSample.b) * heightSampleScale;    

    gl_Position = modelViewProjection * vec4(pos, 1.0);
}

]]
,
fragment = [[
//#define DRAW_EDGES

#ifdef DRAW_EDGES
#extension GL_OES_standard_derivatives : enable
#endif

precision mediump float;

uniform sampler2D texLight;

varying vec2 groundTexCoords;

#ifdef DRAW_EDGES
varying vec3 baryCoords;
varying vec2 nodeCoords;

const vec3 colorTriEdge = vec3(0.5, 0.7, 0.9);
const vec3 colorNodeEdge = vec3(1.0, 0.0, 0.0);
const float triEdgeWidth = 2.0;
const float nodeEdgeWidth = 5.0;

float calcTriEdgeFactor() {
    vec3 d = fwidth(baryCoords);
    vec3 a3 = smoothstep(vec3(0.0), d * triEdgeWidth, baryCoords);
    return min(min(a3.x, a3.y), a3.z);    
}

float calcNodeEdgeFactor() {    
    vec2 d = fwidth(nodeCoords);    
    vec2 a1 = smoothstep(vec2(0.0), d * nodeEdgeWidth, nodeCoords);
    vec2 a2 = smoothstep(vec2(0.0), d * nodeEdgeWidth, 1.0 - nodeCoords);    
    return min(min(a1.x, a1.y), min(a2.x, a2.y));  
}
#endif

void main() {
    vec4 lightLookup = texture2D(texLight, groundTexCoords);
    vec3 color = vec3(0.29, 0.66, 0.03);
    color = mix(color, vec3(1.0,1.0,1.0), lightLookup.r); 
    color = mix(color, vec3(0.30, 0.20, 0.0),lightLookup.g);

    //apply lightmap
    color = color * lightLookup.a;

#ifdef DRAW_EDGES    
    float triFactor = calcTriEdgeFactor();
    float nodeFactor = calcNodeEdgeFactor();
    
    if (nodeFactor < 0.4)
        triFactor = 1.0;
    
    vec3 triEdgeColor = mix(colorTriEdge, vec3(0.0), triFactor);
    vec3 nodeEdgeColor = mix(colorNodeEdge, vec3(0.0), nodeFactor);
    color = color * clamp(nodeFactor + triFactor, 0.0, 1.0) + nodeEdgeColor + triEdgeColor;
#endif
    gl_FragColor.rgb = color; 
    gl_FragColor.a = 1.0;
}
]] }
