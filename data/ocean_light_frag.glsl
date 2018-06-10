#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform float fade;

varying vec4 vertColor;
varying vec3 vertNormal;
varying vec3 vertLightDir;

void main() {
  float intensity;
  vec4 color;
  intensity = max(0.0, dot(vertLightDir, vertNormal));

  vec3 ambientLight = vec3(0.002, 0.05, 0.1);


  float distanceToCamera = gl_FragCoord.z / gl_FragCoord.w;

  vec3 atten = vec3(min(1.0, 1.0 / (distanceToCamera*0.8)), 
                    min(1.0, 1.0 / (distanceToCamera*0.08)), 
                    min(1.0, 1.0 / (distanceToCamera*0.008)));

  vec4 oceanLight = vec4(vec3(0, 0.01, 0.03) * min(1.0,fade), 0.0);
  color = vec4((ambientLight + atten * intensity) * min(1.0,fade), 1.0) * vertColor + oceanLight;


  gl_FragColor = color;
}

