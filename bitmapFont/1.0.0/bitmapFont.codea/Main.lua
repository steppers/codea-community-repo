-- bitmap font
-- by Sem Karaman
local stringbyte, stringchar, stringsub, stringgsub, stringgmatch = string.byte, string.char, string.sub, string.gsub, string.gmatch

local vamp = asset
local vampfontmap = {
  ["!"] = 1, ['"'] = 2, ["$"] = 3, ["%"] = 4, ["&"] = 5, ["'"] = 6, ["("] = 7, [")"] = 8, ["*"] = 9, ["+"] = 10, 
  [","] = 11, ["-"] = 12, ["."] = 13, ["0"] = 14, ["1"] = 15, ["2"] = 16, ["3"] = 17, ["4"] = 18, ["5"] = 19, ["6"] = 20,
  ["7"] = 21, ["8"] = 22, ["9"] = 23, [":"] = 24, [";"] = 25, ["<"] = 26, ["="] = 27, [">"] = 28, ["?"] = 29, ["@"] = 30,
  ["A"] = 31, ["B"] = 32, ["C"] = 33, ["D"] = 34, ["E"] = 35, ["F"] = 36, ["G"] = 37, ["H"] = 38, ["I"] = 39, ["J"] = 40, 
  ["K"] = 41, ["L"] = 42, ["M"] = 43, ["N"] = 44, ["O"] = 45, ["P"] = 46, ["Q"] = 47, ["R"] = 48, ["S"] = 49, ["T"] = 50,
  ["U"] = 51, ["V"] = 52, ["W"] = 53, ["X"] = 54, ["Y"] = 55, ["Z"] = 56, ["["] = 57, ["]"] = 58, ["'"] = 59, ["a"] = 60,
  ["b"] = 61, ["c"] = 62, ["d"] = 63, ["e"] = 64, ["f"] = 65, ["g"] = 66, ["h"] = 67, ["i"] = 68, ["j"] = 69, ["k"] = 70,
  ["l"] = 71, ["m"] = 72, ["n"] = 73, ["o"] = 74, ["p"] = 75, ["q"] = 76, ["r"] = 77, ["s"] = 78, ["t"] = 79, ["u"] = 80,
  ["v"] = 81, ["w"] = 82, ["x"] = 83, ["y"] = 84, ["z"] = 85, ["{"] = 86, ["}"] = 87, [" "] = 0, ["\n"] = -1
}
local vampoffset = {
  ["."] = { y = -1}, [","] = { y = -1.5 }
}

function setup()
  testString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-:;()$&@.,?!'[]{}%*+=<>\""
  parameter.text("input", "Hello Codea")
  parameter.number("size", 0, 100, 48)
  parameter.number("x", 0, WIDTH, 390)
  parameter.number("y", 0, HEIGHT, 490)
  parameter.number("xlight", -WIDTH, WIDTH, -50)
  parameter.number("ylight", -HEIGHT, HEIGHT, -45)  
  BF = BitMapFont({ font = vamp, map = vampfontmap, offsets = vampoffset })
end

function draw()
  background(0)
  smooth()
  BF:draw({ size = size, str = input, x = x, y = y })
  collectgarbage()
end

function colorToVec4(col)
  return vec4(col.r/255, col.g/255, col.b/255, col.a/255)
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  local res = math.floor(num * mult + 0.5) / mult
  --print(res)
  return res
end

function setShader(shdr, msh)
  if shdr == "Light" then
    msh.shader = shader(Light.v, Light.f)
    msh.shader.normal = o.normal
    msh.shader.res = vec2(WIDTH, HEIGHT)
    msh.shader.ambientColor = colorToVec4(color(26, 38, 47)) -- ambient RGBA -- alpha is intensity 
    msh.shader.falloff = vec3(0.4, 3, 20) -- attenuation coefficients
    msh.shader.lightsCount = 1
    msh.shader.lightSize = { 5 }
    msh.shader.lightPos = { 
      vec3((self.x + xlight) / (WIDTH / 2), (self.y + ylight) / (HEIGHT / 2), 0.1),
    }
    msh.shader.lightColor = {
      colorToVec4(color(255, 168, 0))
    }
  end
  if shdr == "FluidCircles" then
    msh.shader = shader(FluidCircles.v, FluidCircles.f)
    msh.shader.res = vec2(10, 10)
    msh.shader.speed = 0.1
    msh.shader.baseRadius = 0.4
    msh.shader.colorVariation = 0.6
    msh.shader.brightnessVariation = 0
    msh.shader.backgroundColor = vec3(0.1, 0.1, 0.1)
    msh.shader.variation = 8
    msh.shader.time = 1  
  end
end



BitMapFont = class()
function BitMapFont:init(o)
  self.font = o.font
  self.map = o.map
  self.offsets = o.offsets
  self.queuedChars = {}
  self.queuedOptions = {}
end

function BitMapFont:draw(o)
  if #self.queuedChars == 0 then
    self:generate(o)
  elseif self.queuedOptions.str ~= o.str or self.queuedOptions.size ~= o.size or
    self.queuedOptions.x ~= o.x or self.queuedOptions.y ~= o.y  
  then
    self:generate(o)
  else
    for z = 1, #self.queuedChars do
      if self.queuedChars[z].mesh then
        self.queuedChars[z].mesh.shader.lightPos = { 
          vec3((self.queuedChars[z].x - xlight) / (WIDTH / 2), (self.queuedChars[z].y + ylight) / (HEIGHT / 2), 0.3),
        }
        self.queuedChars[z].mesh.shader.time = ElapsedTime
        self.queuedChars[z].mesh:draw()
      end
    end
  end
end

function BitMapFont:generate(o)
  self.queuedChars = {}
  self.queuedOptions = o
  local tbl = {stringbyte(self.queuedOptions.str, 1, #self.queuedOptions.str)}
  local width, height = 0, 0
  for i = 1, #tbl do
    local char = stringchar(tbl[i])
    --print (char)
    local mappedchar = self.map[char]
    --print(mappedchar)
    if mappedchar == 0 then -- space
      self.queuedChars[i] = {}
      width = width + (3 * self.queuedOptions.size)
    elseif mappedchar == -1 then -- return
      self.queuedChars[i] = {}
      height = height - (4 * self.queuedOptions.size)
      width = 0
    elseif mappedchar == nil then --missing char
      self.queuedChars[i] = {}
      width = width + (3 * self.queuedOptions.size)
    else
      if width ~= 0 then
        local w = spriteSize(self.font[""..(mappedchar)..".png"])
        width = width + (((w * 0.01) * self.queuedOptions.size)/2)
        if self.queuedOptions.x + width > WIDTH then
          height = height - (4 * self.queuedOptions.size)
          width = 0
        end
        --print(width)
      end
      self.queuedChars[i] = BitMapChar({
        x = self.queuedOptions.x + width + ((self.offsets[char] and (self.offsets[char].x and (self.offsets[char].x * self.queuedOptions.size))) or 0),
        y = self.queuedOptions.y + height + ((self.offsets[char] and (self.offsets[char].y * self.queuedOptions.size)) or 0), 
        size = self.queuedOptions.size,
        src = self.font[""..(mappedchar)..".png"],
        normal = self.font[""..(mappedchar).."n.png"],
        shader = "FluidCircles"
      })
      --print(width)
      width = width + (self.queuedChars[i].width/2)
      --print(width, self.queuedChars[i].width)

    end
  end
end
 

BitMapChar = class() 
function BitMapChar:init(o)
  self.mesh = mesh()
  self.mesh.texture = o.src
  local w, h = spriteSize(o.src)
  self.size = o.size
  self.width = w * 0.01 * self.size --600 * 0.01 = 6 = size1
  self.height = h * 0.01 * self.size
  self.x = o.x 
  self.y = o.y

  --print (self.width, self.size)
  self.mesh:addRect(self.x, self.y, self.width, self.height, 0)
  if o.normal then
    setShader(o.shader, self.mesh)
  end
end



Light = {
  v = [[
    uniform mat4 modelViewProjection;
    attribute vec4 position;
    attribute vec2 texCoord;
    attribute vec4 color; 
    varying lowp vec4 vColor;
    varying highp vec2 vTexCoord;
    void main() {
      vTexCoord = texCoord;
      vColor = color;
      gl_Position = modelViewProjection * position;
      gl_Position.z = -gl_Position.z;
    }
  ]],
  f = [[
    #define MAX_LIGHTS 100
    precision highp float;
    precision highp int;
    varying vec4 vColor;
    varying vec2 vTexCoord;
    uniform sampler2D texture;   //diffuse map
    uniform sampler2D normal;   //normal map
    uniform vec2 res;            //resolution of screen
    uniform int lightsCount;     //number of lights added so far
    uniform vec3 lightPos[MAX_LIGHTS];   //light position, normalized
    uniform vec4 lightColor[MAX_LIGHTS]; //light RGBA -- alpha is intensity
    uniform float lightSize[MAX_LIGHTS]; 
    uniform vec4 ambientColor;    //ambient RGBA -- alpha is intensity 
    uniform vec3 falloff;         //attenuation coefficients
    uniform float modAlpha;

    vec3 getFinalColor(vec3 lPos, float size, vec4 lColor, vec4 dColor, vec3 nMap) {
      vec3 lightDir = vec3(lPos.xy - (gl_FragCoord.xy / res.xy), lPos.z);
      lightDir.x *= res.x / res.y;
      float D = length(lightDir);
      vec3 N = normalize(nMap * 2.0 - 1.0);
      vec3 L = normalize(lightDir);
      vec3 diffuse = (lColor.rgb * lColor.a) * max(dot(N, L), 0.0);
      vec3 ambient = ambientColor.rgb * ambientColor.a;
	  float attenuation = 1.0 / (falloff.x + (falloff.y*D) + (falloff.z*D*D));
      vec3 intensity = ambient + (diffuse * size) * attenuation;
      vec3 finalColor = dColor.rgb * intensity;
      return finalColor;
    }
  
    void main() {
      vec3 sum = vec3(0.0, 0.0, 0.0);
      vec4 diffuseColor = texture2D(texture, vTexCoord);
      vec3 normalMap = texture2D(normal, vTexCoord).rgb;
      for (int i = 0; i < lightsCount; i++) {
        vec3 lPos = lightPos[i];
        vec4 lColor = lightColor[i];
        float lSize = lightSize[i];
        vec3 finalColor = getFinalColor(lPos, lSize, lColor, diffuseColor, normalMap);
        sum += finalColor;
      }
	  gl_FragColor = vColor * vec4(sum.x, sum.y, sum.z, diffuseColor.a);
      gl_FragColor.a = 0.0;
    }
  ]]
}

FluidCircles = {
  v = [[
    precision highp float;
    precision highp int;
    uniform mat4 modelViewProjection;
    attribute vec4 position;
    attribute vec2 texCoord;
    varying highp vec2 vUv;
    void main() {
      vUv = texCoord;
      gl_Position = modelViewProjection * position;
    }
  ]],
  f = [[
    precision highp float;
    precision highp int;
    uniform float time;
    uniform sampler2D texture;   //diffuse map 
    uniform vec2 res;
    uniform float speed;
    uniform float baseRadius;
    uniform float colorVariation;
    uniform float brightnessVariation;
    uniform vec3 backgroundColor;
    uniform float variation;
    varying vec2 vUv;
    vec3 n(vec2 x, float t) {
      vec3 v = floor(vec3(x, t));
      vec3 u = vec3(mod(v.xy, variation), v.z);
      vec3 c = fract( u.xyz * (
        vec3(0.16462, 0.84787, 0.98273) +
        u.xyz * vec3(0.24808, 0.75905, 0.13898) +
        u.yzx * vec3(0.31517, 0.62703, 0.26063) +
        u.zxy * vec3(0.47127, 0.58568, 0.37244)
      ) + u.yzx * (
        vec3(0.35425, 0.65187, 0.12423) +
        u.yzx * vec3(0.95238, 0.93187, 0.95213) +
        u.zxy * vec3(0.31526, 0.62512, 0.71837)
      ) + u.zxy * (
        vec3(0.95213, 0.13841, 0.16479) +
        u.zxy * vec3(0.47626, 0.69257, 0.19738)
      ));
      return v + c;
    }
    // Generate a predictably random color based on an input coord
    vec3 col(vec2 x, float t) {
      return vec3(
        0.5 + max( brightnessVariation * cos( x.y * x.x ), 0.0 )
      ) + clamp(
        colorVariation * cos(fract(vec3(x, t)) * 371.0241),
        vec3( -0.4 ),
        vec3( 1.0 )
      );
    }
    vec2 idx(vec2 x) {
      return floor(fract(x * 29.0) * 3.0) - vec2(1.0);
    }
    float circle(vec2 x, vec2 c, float r) {
      return max(0.0, 1.0 - dot(x - c, x - c) / (r * r));
    }
    void main() {
      vec4 diffuseColor = texture2D(texture, vUv);
      if (diffuseColor.a < 0.5) discard;
      vec2 x = vUv * res;
      float t = time * speed;
      vec4 c = vec4(vec3(0.0), 0.1);
      for (int N = 0; N < 3; N++) {
        for (int k = -1; k <= 0; k++) {
          for (int i = -1; i <= 1; i++) {
            for (int j = -1; j <= 1; j++) {
              vec2 X = x + vec2(j, i);
              float t = t + float(N) * 38.0;
              float T = t + float(k);
              vec3 a = n(X, T);
              vec2 o = idx(a.xy);
              vec3 b = n(X + o, T + 1.0);
              vec2 m = mix(a.xy, b.xy, (t - a.z) / (b.z - a.z));
              float r = baseRadius * sin(3.1415927 * clamp((t - a.z) / (b.z - a.z), 0.0, 1.0));
              if (length(a.xy - b.xy) / (b.z - a.z) > 2.0) { r = 0.0; }
              c += vec4(col(a.xy, a.z), 1.0) * circle(x, m, r);
            }
          }
        }
      }
      gl_FragColor = vec4(c.rgb / max(1e-5, c.w) + backgroundColor, diffuseColor.a);
    }
  ]]
}























