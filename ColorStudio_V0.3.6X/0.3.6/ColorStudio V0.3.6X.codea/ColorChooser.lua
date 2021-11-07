colorChooser = class()

function colorChooser:init(pos, size, mode)
    
    self.pos = pos
    self.mode = mode
    
    self.color = {current=vec3(255, 0, 0)}
    self.color.previous = self.color.current
    
    if self.mode == "WHEEL" then
        
        self.size = size/2
        self.angle = {current=0.0}
        self.angle.previous = self.angle.current
        
        self.saturation_and_brightness = {
            current=vec2(100.0, 100.0),
            area=self.size/(31/17),
            disc=mesh()
        }
        self.saturation_and_brightness.previous = self.saturation_and_brightness.current
        
    elseif self.mode == "BOX" then
        
        self.size = size
        
    end
    
    self.cT = self.pos + vec2(0.0, self.size)
    
    self.picker = {hue=Picker(self.size * 0.3, self.size * 0.5), saturation_and_brightness=Picker(self.size * 0.2, self.size * 0.6)}
    
end

function colorChooser:draw()
    
    pushMatrix()
    pushStyle()
    
    if self.mode == "WHEEL" then
        
        translate(self.pos:unpack())
        
        noFill()
        strokeWidth(self.size/25)
        
        pushMatrix()
        lineCapMode(SQUARE)
        for h = 0.0, 359.0 do
            
            rotate(1)
            
            local sv = 100.0
            local col = ColorConverter:hsb2rgb(vec3(h+90.0, sv, sv))
            
            stroke(col:unpack())
            line(0, self.size/(31/21), 0, self.size)
            
        end
        popMatrix()
        
        if self.picker.hue.held then
            self.angle.current = Math:yaw(self.pos, self.cT.pos)+270
            self.angle.previous = self.angle.current
        else
            self.angle.current = self.angle.previous
        end
        self.angle.current = math.fmod(self.angle.current, 360.0)
        
        local col = ColorConverter:hsb2rgb(vec3(self.angle.current, 100.0, 100.0))
        self.picker.hue:draw(Math:circularMotion(self.angle.current, self.size/(31/26)), color(col:unpack()))
        
        local SnB_DiscVertices = {}
        local sides = 64
        for i = 1, sides do
            table.insert(SnB_DiscVertices, vec2(0.0, 0.0))
            table.insert(SnB_DiscVertices, vec2(-math.tan(math.pi/sides), -1))
            table.insert(SnB_DiscVertices, vec2(math.tan(math.pi/sides), -1))
        end
        
        self.saturation_and_brightness.disc.vertices = SnB_DiscVertices
        
        for i, v in ipairs(self.saturation_and_brightness.disc.vertices) do
            self.saturation_and_brightness.disc:vertex(i, v:rotate(math.rad(180+180/sides+360/sides * math.ceil(i/3))) * self.saturation_and_brightness.area)
        end
        
        local graphic = shader(self:vrtx(), self:fgmt())
        graphic.reso = vec2(2, 2) * self.saturation_and_brightness.area
        graphic.pos = self.pos
        graphic.hue = self.angle.current/360.0
        
        self.saturation_and_brightness.disc.shader = graphic
        
        self.saturation_and_brightness.disc:draw()
        
        if self.picker.saturation_and_brightness.held then
            local current_SnB = vec2(0, 0)
            if Collision.point:circle(self.cT.pos, self.pos, self.saturation_and_brightness.area/0.5) then
                current_SnB = (self.cT.pos-self.pos)/self.saturation_and_brightness.area
            else
                current_SnB = Math:circularMotion(Math:yaw(self.pos, self.cT.pos)-90, self.saturation_and_brightness.area)/self.saturation_and_brightness.area
            end
            local u, v = current_SnB:unpack()
            local u2 = u^2
            local v2 = v^2
            local twosqrt2 = 2.0 * 2.0^0.5
            local subtermx = 2.0 + u2 - v2
            local subtermy = 2.0 - u2 + v2
            local termx1 = subtermx + u * twosqrt2
            local termx2 = subtermx - u * twosqrt2
            local termy1 = subtermy + v * twosqrt2
            local termy2 = subtermy - v * twosqrt2
            local cSV = vec2(0.0, 0.0)
            cSV.x = termx1^0.5/2.0-termx2^0.5/2.0
            cSV.y = termy1^0.5/2.0-termy2^0.5/2.0
            cSV = cSV * 50 + vec2(50, 50)
            self.saturation_and_brightness.current = Math:abs2(cSV)
        else
            self.saturation_and_brightness.previous = self.saturation_and_brightness.current
        end
        
        local x, y = (self.saturation_and_brightness.current/50-vec2(1, 1)):unpack()
        local SVp = vec2(0.0, 0.0)
        SVp.x = x * (1.0 - y^2/2.0)^0.5
        SVp.y = y * (1.0 - x^2/2.0)^0.5
        SVp = SVp * self.saturation_and_brightness.area
        
        self.color.current = ColorConverter:hsb2rgb(vec3(self.angle.current, self.saturation_and_brightness.current:unpack()))
        self.picker.saturation_and_brightness:draw(SVp, color(self.color.current:unpack()))
        
        if not self.picker.saturation_and_brightness.held then
            self.color.previous = self.color.current
        end
        
    else
        
        
        
    end
    
    popStyle()
    popMatrix()
    
end

function colorChooser:touched(touch)
    
    self.cT = touch
    
    if self.mode == "WHEEL" then
        
        self.picker.hue:touched(touch,
            Collision.point:circle(touch.pos, self.pos, self.size/0.5) and not
            Collision.point:circle(touch.pos, self.pos, (self.saturation_and_brightness.area+15)/0.5)
        )
        self.picker.saturation_and_brightness:touched(touch, Collision.point:circle(touch.pos, self.pos, self.saturation_and_brightness.area/0.5))
        
    else
        
        
        
    end
    
end

function colorChooser:vrtx()
    return
[[
uniform mat4 modelViewProjection;

attribute vec4 position;
attribute vec4 color;
attribute vec2 texCoord;

varying lowp vec4 vColor;
varying highp vec2 vTexCoord;

void main()
{
    vColor = color;
    vTexCoord = texCoord;
    
    gl_Position = modelViewProjection * position;
}
  
]]
end

function colorChooser:fgmt()
    return
[[

precision highp float;

uniform mediump sampler2D texture;
uniform vec2 reso;
uniform vec2 pos;
uniform float hue;

varying lowp vec4 vColor;
varying highp vec2 vTexCoord;

#define nsin(n) sin(n)*0.5+0.5
#define ncos(n) cos(n)*0.5+0.5
#define ntan(n) tan(n)*0.5+0.5

#define TWO_PI 6.28318530718

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
    vec2 uv = gl_FragCoord.xy/reso-1.0;
    vec2 ps = pos/reso/0.5-1.0;
    float ratio = reso.x > reso.y
        ? max(reso.x, reso.y)/min(reso.x, reso.y)
        : min(reso.x, reso.y)/max(reso.x, reso.y);
    uv.x *= ratio;
    ps.x *= ratio;
    
    vec4 col = vec4(1.0);
    
    uv -= ps;
    float u2 = uv.x * uv.x;
    float v2 = uv.y * uv.y;
    float twosqrt2 = 2.0 * sqrt(2.0);
    float subtermx = 2.0 + u2 - v2;
    float subtermy = 2.0 - u2 + v2;
    float termx1 = subtermx + uv.x * twosqrt2;
    float termx2 = subtermx - uv.x * twosqrt2;
    float termy1 = subtermy + uv.y * twosqrt2;
    float termy2 = subtermy - uv.y * twosqrt2;
    vec2 sv = vec2(0.0);
    sv.x = 0.5 * sqrt(termx1) - 0.5 * sqrt(termx2);
    sv.y = 0.5 * sqrt(termy1) - 0.5 * sqrt(termy2);
    col.rgb = hsb2rgb(vec3(hue, sv * 0.5 + 0.5));
    
    //vec2 toCenter = 0.5-(uv+0.5);
    //float angle = atan(toCenter.y, toCenter.x);
    //float radius = length(toCenter);
    //col.rgb = hsb2rgb(vec3((angle/TWO_PI)+0.5, radius, 1.0));
    
    gl_FragColor = col;
}

]]
end