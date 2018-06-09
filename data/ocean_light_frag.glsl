#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

// uniform float fraction;

varying vec4 vertColor;
varying vec3 vertNormal;
varying vec3 vertLightDir;

void main() {
  float intensity;
  vec4 color;
  intensity = max(0.0, dot(vertLightDir, vertNormal));

  vec3 ambientLight = vec3(0.05, 0.1, 0.2);


  float distanceToCamera = gl_FragCoord.z / gl_FragCoord.w;

  vec3 atten = vec3(min(1.0, 1.0 / (distanceToCamera*0.1)), 
                    min(1.0, 1.0 / (distanceToCamera*0.01)), 
                    min(1.0, 1.0 / (distanceToCamera*0.001)));

  vec4 oceanLight = vec4(0, 0.04, 0.1, 0);
  color = vec4(ambientLight + atten * intensity, 1.0) * vertColor + oceanLight;


  gl_FragColor = color;
}

