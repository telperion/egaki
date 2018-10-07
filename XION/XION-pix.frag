#version 150

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform float pixSize;
uniform vec2 resolution;
uniform sampler2D texture;

varying vec4 vertColor;
varying vec4 vertTexCoord;

const vec4 greyscaler = vec4(0.299, 0.587, 0.114, 0);

void main() 
{
  vec4 color = textureLod(texture, 
    vec2(
    floor(gl_FragCoord.x / pixSize) * pixSize / resolution.x, 
    floor(gl_FragCoord.y / pixSize) * pixSize / resolution.y
    ), 
    0);

  gl_FragColor = color;
}