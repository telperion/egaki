#version 150

#define PI (3.14159265)

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform float time;
uniform sampler2D texture;
uniform sampler2D seedTex;
uniform vec2 resolution;

varying vec4 vertColor;
varying vec4 vertTexCoord;

float asp = 836.0/328.0;

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

    vec4 seeding = texture2D(seedTex, mod(uv / vec2(1.0, asp) + vec2(0.0, t), 1.0));
    float sf = 1 - grey(seeding.rgb);

    vec2 pq = pow(2*uv-1, vec2(2.0));
    
    vec4 color = vec4(
        0.0 + length(pq * vec2(2.0, 1.0))*0.30*sf,
        0.0,
        0.0 + length(pq * vec2(3.0, 1.0))*0.15*sf,
        0.0
        );

    // Output to screen
    gl_FragColor = vec4(color.rgb, 1.0);
}