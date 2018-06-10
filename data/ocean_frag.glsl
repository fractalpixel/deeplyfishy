#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform float fade;

varying vec4 vertColor;
varying vec3 vertNormal;
varying vec3 vertLightDir;

void main() {
  
  float upward = dot(vec3(0,1,0), vertNormal);

  vec3 upColor = vec3(0.2, 0.4, 0.8);
  vec3 midColor = vec3(0, 0.08, 0.15);
  vec3 downColor = vec3(0, 0.01, 0.05);

  vec3 color = vec3(0);  
  if (upward < 0)  {
    color = mix(midColor, upColor, pow(-upward, 2));
  }
  else {
    color = mix(midColor, downColor, pow(upward, 0.8));
  }
  


  gl_FragColor = vec4(color * fade,1);
}

