#version 150

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform float time;
uniform sampler2D texture;
uniform sampler2D warpTex;
uniform vec2 resolution;

varying vec4 vertColor;
varying vec4 vertTexCoord;

uniform float t_loop = 0.5;
uniform float t_samples = 5.0;
uniform float fish_aspect_sq = 16.0/9.0;        // iResolution.x/iResolution.y
uniform float fish_offset = 1.0;
uniform float fish_strength = 1.2;
uniform float warp_sharpness = 0.01;
uniform float warp_max_shift = 0.15;
uniform float warp_clamp = 0.99;

const vec4 greyscaler = vec4(0.299, 0.587, 0.114, 0);

float grey(vec3 col)
{
    return dot(greyscaler.rgb, col);
}

float length2(vec2 uv)
{
    return sqrt(uv.y*uv.y + uv.x*uv.x * fish_aspect_sq) + fish_offset;
}

vec2 fisheye(vec2 uv)
{
    vec2 pq = uv - 0.5;
    
    float n = 2.0*length2(pq);
    float m = 2.0*length2(vec2(0.5, 0.5));
    float l = pow(n/m, fish_strength);
    return l*pq + 0.5;
}

float tznBase(float t, float p1, float p2)
{
    return atan((t-p2)/p1);
}
float tzn(float t, float p1, float p2)
{
    return (tznBase( t ,p1,p2) - tznBase(0.0,p1,p2))
         / (tznBase(1.0,p1,p2) - tznBase(0.0,p1,p2));
}

void main()
{
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = vertTexCoord.st;
    
    float t = mod(time / t_loop, 1.0);
    
    vec2 uvWarp = fisheye(uv);
    
    vec4 texWarp = texture2D(warpTex, vec2(uvWarp.x, mod((floor(time / t_loop)+0.5)/t_samples, 1.0)));
    float warpParam = (0.5 - warp_max_shift) + grey(texWarp.rgb) * warp_max_shift * 2.0;
    float warp = tzn(t, warp_sharpness, warpParam);
    
    vec4 texBase = texture2D(texture, mod(uvWarp + vec2(1.0, warp), 1.0));

    // Output to screen
    gl_FragColor = vec4(texBase.rgb, 1.0);
}