#version 150

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform float time;
uniform sampler2D texture;
uniform vec2 resolution;

varying vec4 vertColor;
varying vec4 vertTexCoord;

uniform float t_loop = 1.0;

const vec4 greyscaler = vec4(0.299, 0.587, 0.114, 0);

float grey(vec3 col)
{
    return dot(greyscaler.rgb, col);
} 

void main()
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = vertTexCoord.st;
    
    float t = mod(time / t_loop, 1.0);
    
    vec4 tint = vec4(
        1.0,
        1.0 - uv.x*uv.x*0.8,
        1.0 - uv.y*uv.y*0.4,
        1.0
        );
    vec4 texBase = texture2D(texture, uv);

    // Output to screen
    gl_FragColor = vec4(texBase.rgb * tint.rgb, 1.0);
}