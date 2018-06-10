#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform float fade;
uniform float ruins;
uniform float ruinsExpanded;

varying vec4 vertColor;
varying vec3 vertNormal;
varying vec3 vertLightDir;
varying vec4 vertTexCoord;

float random(vec2 seed) {
    return fract(sin(dot(seed.xy, vec2(12.9898,78.233))) * 43758.5453);
}

float round(float v) {
  return float(int(v));
}


void main() {
  float intensity;
  vec4 color;
  intensity = max(0.0, dot(vertLightDir, vertNormal));

  vec3 ambientLight = vec3(0.002, 0.05, 0.1);

  vec2 ruinPos = vec2(round(vertTexCoord.x * 8), round(vertTexCoord.y * 8));
  float a = random(vec2(float(ruinPos.x)*12.21+float(ruinPos.y)*0.21 *ruins*0.1278, 120*ruins+0.1278));
  float b = random(vec2(float(ruinPos.y)*13.331+float(ruinPos.x)*1.7161*(0.212+ruins)*0.98278, 131.1* ruins + 1.8372));
    
  float ruinPattern = max(a,b) * 0.4 + 0.8;
  float ruinMultiplier = ruins * ruinPattern + (1-ruins) * 1;

  float distanceToCamera = gl_FragCoord.z / gl_FragCoord.w;

  float a2 = random(vec2(float(ruinPos.x)*1.721+float(ruinPos.y)*10.71*(ruins+0.761)*0.71278*(ruinsExpanded-0.786), 0.82*ruins+2.278*(ruinsExpanded+0.12786)));
  float b2 = random(vec2(float(ruinPos.y)*7.331+float(ruinPos.x)*3.961*ruins*(ruinsExpanded-0.186), 8.1* ruins + 1.372*(ruinsExpanded-0.1126)));
  float ruinExpandedPattern = min(1, max(0,min(a2-0.7, b2-0.7)) * 10);
  vec3 ruinsExpandColor = vec3(0.6, 0.4, 0.2) * ruinsExpanded * ruinExpandedPattern * ruinExpandedPattern;

  vec3 atten = vec3(min(1.0, 1.0 / (distanceToCamera*0.8)), 
                    min(1.0, 1.0 / (distanceToCamera*0.08)), 
                    min(1.0, 1.0 / (distanceToCamera*0.008)));

  vec4 oceanLight = vec4(vec3(0, 0.01, 0.03) * min(1.0,fade), 0.0);
  color = vec4((ruinsExpandColor + ambientLight + ruinMultiplier * atten * intensity) * min(1.0,fade), 1.0) * vertColor + oceanLight;


  gl_FragColor = color;
}

