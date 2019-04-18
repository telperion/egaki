#version 150

#define M_PI (3.14159265359)

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform float time;
uniform sampler2D texture;
uniform sampler2D horizon_src_tex;
uniform sampler2D horizon_fg1_tex;
uniform sampler2D horizon_fg2_tex;
uniform vec2 resolution = vec2(1280.0, 720.0);

varying vec4 vertColor;
varying vec4 vertTexCoord;

uniform float t_loop = 0.5;
uniform float t_samples = 5.0;

vec2 pix_size = vec2(12.0, 1.0);
uniform float aspect_sq = 16.0/9.0;        // iResolution.x/iResolution.y
uniform float max_height = 1.2;
uniform float aurora_speed = 0.5;
uniform float aurora_submerge = -0.15;
uniform float aurora_dim = 2.0;
uniform float max_gamma = 3.0;
uniform float lightener = 0.2;
uniform float treelight = 0.3;

uniform vec2 hex_center = vec2(0.0, 0.0);
uniform float hex_radius = 0.2;
uniform float hex_thk = 0.01;
uniform float hex_strength = 0.02;

const vec4 greyscaler = vec4(0.299, 0.587, 0.114, 0);

vec3 HSV2RGB(vec3 hsv)
{
    vec3 rgb = vec3(0.0);
    
    float spread = hsv.y * ((hsv.z > 0.5) ? (1.0 - hsv.z) : hsv.z) * 2.0;
    float center = hsv.z;
    float phase  = mod(hsv.x * 6.0, 2.0);
    float strong = hsv.x * 6.0;
    
    vec3 mmm = vec3(center + spread * 0.5, center, center - spread * 0.5);
    if (phase < 1.0)
    {
        mmm.y = center + spread * (phase - 0.5);
    }
    else
    {
        mmm.y = center + spread * (1.5 - phase);
    }
    
         if (strong < 1.0) {rgb.rgb = mmm.xyz;}
    else if (strong < 2.0) {rgb.rgb = mmm.yxz;}
    else if (strong < 3.0) {rgb.rgb = mmm.zxy;}
    else if (strong < 4.0) {rgb.rgb = mmm.zyx;}
    else if (strong < 5.0) {rgb.rgb = mmm.yzx;}
    else                   {rgb.rgb = mmm.xzy;}
    
    return rgb;
}

vec3 RGB2HSV(vec3 rgb)
{
    vec3 hsv = vec3(0.0);
    
    if (rgb.r == rgb.g && rgb.g == rgb.b)
    {
        return vec3(0.0, 0.0, rgb.g);
    }
    
    float maxCh = max(max(rgb.r, rgb.g), rgb.b);
    float minCh = min(min(rgb.r, rgb.g), rgb.b);
    
    float spread = maxCh - minCh;
    vec3 dd = (rgb-minCh)/spread;
        
         if ((rgb.r >  rgb.g) && (rgb.g >= rgb.b))
    {
        hsv.x = dd.g;
        hsv.y = dd.g;
    }
    else if ((rgb.g >= rgb.r) && (rgb.r >  rgb.b))
    {
        hsv.x = 2.0 - dd.r;
        hsv.y = dd.r;
    }
    else if ((rgb.g >  rgb.b) && (rgb.b >= rgb.r))
    {
        hsv.x = 2.0 + dd.b;
        hsv.y = dd.b;
    }
    else if ((rgb.b >= rgb.g) && (rgb.g >  rgb.r))
    {
        hsv.x = 4.0 - dd.g;
        hsv.y = dd.g;
    }
    else if ((rgb.b >  rgb.r) && (rgb.r >= rgb.g))
    {
        hsv.x = 4.0 + dd.r;
        hsv.y = dd.r;
    }
    else // if ((rgb.r >= rgb.b) && (rgb.b > rgb.g))
    {
        hsv.x = 6.0 - dd.b;
        hsv.y = dd.b;
    }
    
    hsv.x /= 6.0;
    hsv.z = (maxCh + minCh) * 0.5;    
    
    return hsv;
}

float sigmoid2(float t)
{
    return atan(t) * 2.0 / M_PI;
}



vec4 PalettePick(float t, bool hsv_blend)
{
    t = clamp(t, 0.0, 1.0);
    float tt = 0.0;
    vec4 a = vec4(0.0);
    vec4 b = vec4(0.0);
    vec4 result = vec4(0.0);
    
         if (t < 0.2)
    {
        a = vec4(0.469, 0.848, 0.254, 1.000);
        b = vec4(0.121, 0.457, 0.598, 1.000);
        tt = (t - 0.0)/(0.2 - 0.0);
    }
    else if (t < 0.3)
    {
        a = vec4(0.121, 0.457, 0.598, 1.000);
        b = vec4(0.414, 0.121, 0.730, 1.000);
        tt = (t - 0.2)/(0.3 - 0.2);
    }
    else if (t < 0.5)
    {
        a = vec4(0.414, 0.121, 0.730, 1.000);
        b = vec4(0.414, 0.121, 0.730, 0.700);
        tt = (t - 0.3)/(0.5 - 0.3);
    }
    else //if (t < 1.0)
    {
        a = vec4(0.414, 0.121, 0.730, 0.700);
        b = vec4(0.002, 0.001, 0.003, 0.000);
        tt = (t - 0.5)/(1.0 - 0.5);
    }
    
    if (hsv_blend)
    {
        vec4 a_hsv = vec4(RGB2HSV(a.rgb), a.a);
        vec4 b_hsv = vec4(RGB2HSV(b.rgb), b.a);
        vec4 res_hsv = a_hsv*(1.0 - tt) + b_hsv*tt;
        return vec4(HSV2RGB(res_hsv.rgb), res_hsv.a);
    }
    else
    {    
        return a * (1.0 - tt) + b * tt;
    }
}


float grey(vec3 col)
{
    return dot(greyscaler.rgb, col);
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
    vec2 uv = pix_size*floor(vertTexCoord.st * resolution.xy / pix_size)/resolution.xy;
    vec2 pq = vertTexCoord.st;

    float t = time;
    
    float gamma = 1.0; //(iMouse.x < iResolution.x * 0.5) ? 1.0 : (max_gamma * iMouse.y / iResolution.y);
    bool hsv_blend = false; //(uv.x-0.5) * (10.0*iMouse.y/iResolution.y) < (uv.y-0.5);

    // Time varying pixel color
    // vec3 col = 0.5 + 0.5*cos(iTime+uv.xyx+vec3(0,2,4));
    vec4 texH = texture2D(horizon_src_tex, vec2(uv.x, mod(aurora_speed * t, 1.0)));
    vec4 texV = texture2D(horizon_src_tex, vec2(mod(aurora_speed * t, 1.0), uv.x));
    vec4 texG = texture2D(texture, pq);

    gamma = 1.0 - lightener * grey(texG.rgb);
    
    vec4 pal = PalettePick((0.5 * (uv.y + aurora_submerge) / grey(texH.rgb) + grey(texV.rgb)) / max_height, hsv_blend);
    pal.rgb *= 1.0 - aurora_dim*grey(texV.rgb) * (1.0 + clamp(aurora_submerge + uv.y, -1.0, 0.0));
    vec4 col = vec4(vec3(0.0), 1.0); //texture(iChannel1, pq);
    
    vec4 color_sum = vec4(pal.rgb * pal.a + col.rgb * (1.0 - pal.a) + texG.rgb * hex_strength, clamp(col.a + pal.a + grey(texG.rgb)*hex_strength, 0.0, 1.0));
    
    // Output to screen
    vec4 almost = vec4(pow(color_sum.rgb, vec3(gamma)), color_sum.a);
    vec4 tex_fg1 = texture2D(horizon_fg1_tex, vec2(pq.x, 1.0-pq.y));
    vec4 tex_fg2 = texture2D(horizon_fg2_tex, vec2(1.0-pq.x, 1.0-pq.y));
    float alight = treelight + (1.0-treelight) * pow(grey(almost.rgb), 0.5);

    gl_FragColor = vec4(
        almost.rgb * (1.0 - tex_fg1.a) * (1.0 - tex_fg2.a) * color_sum.a
        + pow(tex_fg1.rgb, vec3(2.0)) * tex_fg1.a * (1.0 - tex_fg2.a) * (0.5 + 0.5*almost.rgb) * treelight
        + pow(tex_fg2.rgb, vec3(2.0)) * tex_fg2.a * alight,
        1.0);
}