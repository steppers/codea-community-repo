function fragment()
    return
[[

precision highp float;

uniform mediump sampler2D texture;
uniform vec2 reso;
uniform vec2 camSize;
uniform vec2 touch;
uniform float time;
uniform float T;
uniform float S;
uniform vec3 ctr;
uniform vec3 rcl;

varying lowp vec4 vColor;
varying highp vec2 vTexCoord;

#define nsin(n) sin(n)*0.5+0.5
#define ncos(n) cos(n)*0.5+0.5
#define ntan(n) tan(n)*0.5+0.5

float rect(vec2 pos, vec2 scale, float radius){
    vec2 d = abs(pos)-vec2(scale-radius*min(scale.x, scale.y));
    float shape = length(max(d, vec2(0.0)))+min(max(d.x, d.y), 0.0);
    return step(radius*min(scale.x, scale.y), shape);
}

vec2 texScale(vec2 position, vec2 size){
    float ratio = min(size.x, size.y)/max(size.x, size.y);
    return position*(size.x < size.y
        ? mat2(1.0, 0.0, 0.0, ratio)
        : mat2(ratio, 0.0, 0.0, 1.0))
        + 0.5;
}

#define uRGB(r, g, b) vec3(r, g, b)/255.0

vec3 rgb2hsb(vec3 c)
{
    vec4 K = vec4(0.0, -1.0/3.0, 2.0/3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z+(q.w-q.y)/(6.0 * d+e)), d/(q.x+e), q.x);
}

#define uHSB(h, s, b) vec3(h/360.0, s/100.0, b/100.0)

vec3 hsb2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0/3.0, 1.0/3.0, 3.0);
    vec3 p = abs(fract(c.xxx+K.xyz) * 6.0-K.www);
    return c.z * mix(K.xxx, clamp(p-K.xxx, 0.0, 1.0), c.y);
}

void main()
{
    vec2 mouse = touch/reso/0.5-1.0;
    vec2 uv = gl_FragCoord.xy/reso-1.0;
    vec2 UV = uv;
    float ratio = reso.x > reso.y
        ? max(reso.x, reso.y)/min(reso.x, reso.y)
        : min(reso.x, reso.y)/max(reso.x, reso.y);
    uv.x *= ratio;
    mouse.x *= ratio;
    
    float camRatio = floor(max(camSize.x, camSize.y)/min(camSize.x, camSize.y)+0.5);
    float screenRatio = floor(max(reso.x, reso.y)/min(reso.x, reso.y)+0.5);
    
    vec4 col = vec4(1.0);
    //vec4 cam = texture2D(texture, texScale(uv, camSize)) * vColor;
    
    vec2 offset = (screenRatio == camRatio ? vec2(1.0) : vec2(max(reso.x, reso.y)/min(reso.x, reso.y), 1.0));
    vec4 cam = texture2D(texture, (UV/(reso.x > reso.y ? offset.xy : offset.yx)*0.5+0.5)) * vColor;
    
    float maskY = 0.2989 * ctr.r + 0.5866 * ctr.g + 0.1145 * ctr.b;
    float maskCr = 0.7132 * (ctr.r - maskY);
    float maskCb = 0.5647 * (ctr.b - maskY);
    
    float Y = 0.2989 * cam.r + 0.5866 * cam.g + 0.1145 * cam.b;
    float Cr = 0.7132 * (cam.r - Y);
    float Cb = 0.5647 * (cam.b - Y);
    
    float Tx = pow(T, 6.0);
    float blendValue = smoothstep(Tx, Tx+pow(S, 8.0), distance(vec2(Cr, Cb), vec2(maskCr, maskCb)));
    
    //float lm = (ctr.r > ctr.g ? ctr.r > ctr.b ? cam.r : cam.b : ctr.g > ctr.b ? cam.g : cam.b)/length(cam.rgb);
    //lm = max(1.0-pow(lm, 2.0), blendValue);
    
    vec3 recolor = rgb2hsb(rcl);
    vec3 camFX = rgb2hsb(cam.rgb);
    camFX.x = recolor.x;
    camFX.y = mix(0.0, recolor.y, recolor.z);
    camFX.z = mix(camFX.z/3.2, camFX.z/0.8, recolor.z);
    camFX = hsb2rgb(camFX);
    
    cam.rgb = mix(cam.rgb, camFX, 1.0-blendValue);
    //
    //cam.rgb = rcl;
    
    gl_FragColor = cam;
}

]]
end