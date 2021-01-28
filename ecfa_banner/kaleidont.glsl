#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PI_ONE (3.14159265)
#define PI_TWO (6.28318521)

uniform sampler2D texture;

varying vec4 vertColor;
varying vec4 vertTexCoord;

uniform vec2 resolution = vec2(640.0, 360.0);
uniform float kaleido_speed = 0.1;
uniform float kaleido_rot_all = -0.1;
uniform int kaleido_n = 7;

uniform float t = 0.0;

void main()
{   
    float to_corner = length(resolution);

    vec2 fragCoord = vertTexCoord.st * resolution.xy;
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/resolution.xy;
    vec2 pq = (fragCoord - (resolution.xy * 0.5)) / resolution.y;
    
    // vec4 tex = texture2D(texture, uv);
    
    // Only forward slice is sampled directly.
    float slice = PI_TWO / float(kaleido_n);
    float theta = atan(pq.y, pq.x);
    float alpha = PI_TWO * t * kaleido_speed;
    float slice_diff = abs(mod((PI_TWO + alpha - theta)/slice + 0.5, 1.0) - 0.5);
    
    // Reconstruct corresponding point to sample at.
    float beta = PI_TWO * t * kaleido_rot_all;
    float phi = alpha + slice * slice_diff + beta;
    vec2 mn = vec2(cos(phi), sin(phi)) * length(pq) * resolution.y/to_corner;
    vec2 uv1 = (mn * resolution.x)/resolution.xy + 0.5;
    // Reconstruct corresponding point to sample at.
    beta = PI_TWO * t * kaleido_rot_all;
    phi = alpha + slice * (0.5 - slice_diff) + beta;
    mn = vec2(cos(phi), sin(phi)) * length(pq) * resolution.y/to_corner;
    vec2 uv2 = (mn * resolution.y)/resolution.xy + 0.5;
    
    vec4 tex1 = texture2D(texture, uv1);
    vec4 tex2 = texture2D(texture, uv2);

    // Time varying pixel color
    // vec3 col = 0.5 + 0.5*cos(t+uv.xyx+vec3(0,2,4));
    float double_sample = slice_diff * 1.0;
    vec4 col = tex1.rgba * abs(2.0 * double_sample) + tex2.rgba * abs(1.0 - 2.0 * double_sample);

    // Output to screen
    gl_FragColor = col * vertColor;
}