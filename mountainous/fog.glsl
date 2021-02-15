#define PROCESSING_COLOR_SHADER

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform float maxDepth;
uniform float minDepth;

varying vec4 vertColor;
varying vec3 vertNormal;
varying vec3 vertLightDir;
 
void main() {
  float depth = gl_FragCoord.z / gl_FragCoord.w;
  gl_FragColor = vec4(vertColor.rgb, vertColor.a * clamp(1.0 - (depth-minDepth)/(maxDepth-minDepth), 0.0, 1.0));
}