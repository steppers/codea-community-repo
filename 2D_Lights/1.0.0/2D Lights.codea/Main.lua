-- 2D Lights
-- Every mesh needs its own lights since they are on a shader
-- so to simulate lights on multiple objects
-- create the same light on both meshes and then
-- make sure it is set to relevance false 
-- keep the position and size the same

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  local esi = math.floor(num * mult + 0.5) / mult
  return esi
end
   
-- shader()
function setup()
  print("Hello 2D Lights!")
  parameter.boolean("relativeLight", true)
  parameter.number('lightX', 0, 1, 0.5)
  parameter.number('lightY', 0, 1, 0.5)
  parameter.number('lightZ', -1, 1.5, 0.075)
  parameter.number('lightCutoff', 0, 1, 0)  
  parameter.number('buddahX', 0, WIDTH, WIDTH/2)
  parameter.number('buddahY', 0, HEIGHT, HEIGHT/2)
  parameter.number('camX', -999, 999, 0)
  parameter.number('camY', -999, 999, 0)
  parameter.number('camZoom', -100, 1000, 0)
  parameter.number('falloffX', -5, 5, 0.4)
  parameter.number('falloffY', -5, 5, 3)
  parameter.number('falloffZ', -50, 50, 20)
  parameter.number('lightSize', -1, 10, 1)
  parameter.number('colorR', 0, 20, 1)
  parameter.number('colorG', 0, 20, 0.8)
  parameter.number('colorB', 0, 20, 0.6)
  parameter.number('colorA', -5, 15, 2)
  
  buddah = mesh()
  local tex = asset.buddah
  buddah.texture = tex
  local buddahN = asset.buddahN
  w, h = spriteSize(tex)
  buddah:addRect(WIDTH/2, HEIGHT/2, w*.5, h*.5, 0)
  buddah.shader = shader(Light.v, Light.f)
  buddah.shader.normal = buddahN
  buddah.shader.res = vec2(WIDTH, HEIGHT)-- vec2(w*.5, h*.5)
  buddah.shader.aspect = w/h
  print (w/h)
  buddah.shader.ambientColor = vec4(0.6, 0.6, 1, 0.2) -- ambient RGBA -- alpha is intensity 

  
  rocks = mesh()  
  rocks.texture = asset.rocks
  rocksN = asset.rocksN
  w, h = spriteSize(asset.rocks)
   print (w/h) 
  rocks:addRect(WIDTH / 2, HEIGHT / 2, WIDTH, HEIGHT, 0)   
  rocks.shader = shader(Light.v, Light.f)
  rocks.shader.aspect = w/h
  rocks.shader.normal = rocksN
  rocks.shader.res = vec2(WIDTH, HEIGHT)
  rocks.shader.size = vec2()
  rocks.shader.ambientColor = vec4(0.6, 0.6, 1, 0.2) -- ambient RGBA -- alpha is intensity 

  
  updateShaders()  
end

function draw()
  background(0)
  ortho(camX - camZoom, camX + WIDTH + camZoom, camY - camZoom, camY + HEIGHT + camZoom)  
  
  w, h = spriteSize(asset.buddah)
  buddah:setRect(1, buddahX, buddahY, w*.5, h*.5)  
  updateShaders()
  rocks:draw()
  buddah:draw()
  -- print(' draw')
end

function updateShaders()

  local plusCamX = 0
  if not relativeLight then
   plusCamX = -(camX/WIDTH)
  end 
  
  --[[
    Lights properties work like lists/arrays so you need to provide the number
    of lights in those arrays via LightsCount, then each index in the other
    properties will be the settings for that light
   
  ]]
  
  buddah.shader.LightsCount = 1 
  buddah.shader.LightsPos = { vec3(lightX + plusCamX, lightY, lightZ) } -- light position, normalized
  buddah.shader.LightsColor = { vec4(colorR, colorG, colorB, colorA) } -- light RGBA -- alpha is intensity,
  buddah.shader.LightsFalloff = { vec3(falloffX, falloffY, falloffZ) }-- attenuation coefficients
  buddah.shader.LightsSize = { lightSize } -- additional intensity and size
  buddah.shader.LightsCutoff = { lightCutoff } -- circular spotlight cutoff
  buddah.shader.LightsRelative = { relativeLight } -- attach the light to the camera or the mesh (relative true is mesh)
  
  rocks.shader.LightsCount = 1
  rocks.shader.LightsSize = { lightSize  }
  rocks.shader.LightsPos = { vec3(lightX + plusCamX, lightY , lightZ) } 
  rocks.shader.LightsColor = { vec4(colorR, colorG, colorB, colorA) } 
  rocks.shader.LightsFalloff = { vec3(falloffX, falloffY, falloffZ) } 
  rocks.shader.LightsCutoff = { lightCutoff }
  rocks.shader.LightsRelative = { relativeLight }
end

function touched(touch)
  if touch.state == BEGAN then
    local tex = asset.dragon
    w, h = spriteSize(tex)
    buddah:setRect(1, buddahX, buddahY, w*.5, h*.5)
    
    buddah.texture = asset.dragon
    buddah.shader.normal = asset.dragonN
  end
  if touch.state == ENDED then
    local tex = asset.buddah
    w, h = spriteSize(tex)
    buddah:setRect(1, buddahX, buddahY, w*.5, h*.5)
    buddah.texture = asset.buddah
    buddah.shader.normal = asset.buddahN
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
    uniform vec2 res;           //resolution of screen
    uniform float aspect;    // aspect ration of texture
    uniform int LightsCount;     //number of lights added so far
    uniform vec3 LightsPos[MAX_LIGHTS];   //light position, normalized
    uniform vec4 LightsColor[MAX_LIGHTS]; //light RGBA -- alpha is intensity
    uniform float LightsSize[MAX_LIGHTS]; 
    uniform bool LightsRelative[MAX_LIGHTS]; // attached to mesh or screen
    uniform float LightsCutoff[MAX_LIGHTS]; //"spotlight"
    uniform vec3 LightsFalloff[MAX_LIGHTS]; //attenuation coefficients
    uniform vec4 ambientColor;    //ambient RGBA -- alpha is intensity 

    vec3 getFinalColor(vec4 diffuse, vec3 normal, vec3 pos, vec4 color, float size, bool relative, vec3 falloff, float cutoff) {
      vec2 coord = vTexCoord;
      float lAspect = aspect;
      if (!relative) {
        pos.x *= 2.0;
        pos.y *= 2.0;
        coord = gl_FragCoord.xy / res.xy;
        lAspect = res.x / res.y;
      }
      vec3 lightDir = vec3(pos.xy - (coord), pos.z);
      lightDir.x *= res.x / res.y;
      float D = size * length(lightDir);
      vec3 N = normalize(normal * 2.0 - 1.0);
      vec3 L = normalize(lightDir);
      vec3 diffuseMax = (color.rgb * color.a) * max(dot(N, L), 0.0);
      vec3 ambient = ambientColor.rgb * ambientColor.a;
	  float attenuation = 1.0 / (falloff.x + (falloff.y*D) + (falloff.z*D*D));
      vec3 intensity = ambient + diffuseMax  * attenuation;
      vec3 finalColor = diffuse.rgb * intensity;
      if (cutoff > 0.0) {     
         float rad = sqrt((((coord.x-pos.x)*(coord.x-pos.x))*lAspect)+((coord.y-pos.y)*(coord.y-pos.y))/lAspect);
         if (rad > cutoff) {
            finalColor = diffuse.rgb * ambient;
         }
      }
      return finalColor;
    }
  
    void main() {
      vec3 sum = vec3(0.0, 0.0, 0.0);
      vec4 diffuseColor = texture2D(texture, vTexCoord);
      vec3 normalMap = texture2D(normal, vTexCoord).rgb;
      for (int i = 0; i < LightsCount; i++) {
        vec3 lPos = LightsPos[i];
        vec4 lColor = LightsColor[i];
        float lSize = LightsSize[i];
        bool lRelative = LightsRelative[i];
        vec3 lFalloff = LightsFalloff[i];
        float lCutoff = LightsCutoff[i];
        vec3 finalColor = getFinalColor(diffuseColor, normalMap, lPos, lColor, lSize, lRelative, lFalloff, lCutoff);
        sum += finalColor;
      }
	  gl_FragColor = vColor * vec4(sum, diffuseColor.a);
    }
  ]]
}








