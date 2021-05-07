wireframe = {}

function wireframe.set(m)
    local cc = {}
    for i = 1, m.size/3 do
        table.insert(cc, vec3(1,0,0))
        table.insert(cc, vec3(0,1,0))
        table.insert(cc, vec3(0,0,1))
    end
    m.normals = cc
    m.shader = shader(wireframe.vert, wireframe.frag)
    m.shader.flash = 1
    m.shader.strokeWidth = strokeWidth()
end

wireframe.vert = [[
uniform mat4 modelViewProjection;
uniform float flash;

attribute vec4 position;
attribute vec4 color;
attribute vec3 normal;

varying highp vec4 vColor;
varying highp vec3 vNormal;

void main(void) {
    vColor = color * flash;
    vNormal = normal;
    gl_Position = modelViewProjection * position;
}]]

wireframe.vertInst = [[
#extension GL_EXT_draw_instanced: enable
uniform mat4 modelViewProjection;

attribute vec4 position;
attribute vec4 color;
attribute vec3 normal;

varying highp vec4 vColor;
varying highp vec3 vNormal;

void main(void) {
    vColor = color;
    vNormal = normal;
    lowp vec4 pos = position;
    pos.z += float(gl_InstanceIDEXT) * 12.6;
    float dist = clamp((pos.z * 0.004), 0.0, 1.1);
    vColor = mix(color, vec4(0.,0.,0.,1.), dist);
    gl_Position = modelViewProjection * pos;
}]]

wireframe.frag = [[
#extension GL_OES_standard_derivatives : enable

uniform highp float strokeWidth;

varying highp vec4 vColor;
varying highp vec3 vNormal;

void main(void) {
    highp vec4 col = vColor;
    if (!gl_FrontFacing) col.rgb *= 0.5; //darken rear-facing struts
    highp vec3 d = fwidth(vNormal);    
    highp vec3 tdist = smoothstep(vec3(0.0), d * strokeWidth, vNormal); 

    //2 methods: 1. discard method: best way of ensuring back facing struts show through
    if (min(min(tdist.x, tdist.y), tdist.z) > 0.5) discard; 
    else gl_FragColor = mix(col, vec4(col.rgb, 0.), -0.5 + 2. * min(min(tdist.x, tdist.y), tdist.z)); // anti-aliasing
    
    //2. alpha method means some rear faces wont show. Would be good for a "solid" mode though
    //gl_FragColor = mix(col, vec4(0.), min(min(tdist.x, tdist.y), tdist.z)); 
}]]