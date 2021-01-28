#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PI   (3.14159265358979)
#define PI2  (6.28318530717959)
#define PI4 (12.56637061435917)

uniform sampler2D texture;

varying vec4 vertColor;
varying vec4 vertTexCoord;

uniform vec2 grid1 = vec2(6.0, 2.0);
uniform vec2 grid2 = vec2(5.0, 3.5);
uniform vec2 grid3 = vec2(4.0, 5.0);

uniform vec2 resolution = vec2(1024.0, 400.0);

uniform float travSpeed = 0.2;
uniform float travOffset = 0.0;
uniform vec2 pseudo = vec2(1069.0, 3169.0);
uniform vec2 traveler = vec2(10069.0, 30169.0)/10000.0;

uniform bool init = false;
uniform int splits = 3;
uniform float splitter = 1.3; // pow(2.0, 1.0 / float(splits));
uniform float scaler = 4.0; // PI4 / float(splits);

uniform float colorSpeed = 0.1;
uniform float colorRange = 0.8;

uniform float time = 0.0;
uniform float alpha = 1.0;

vec2 smoother(vec2 s, vec2 p, float t)
{
    // input:
    //		s, independent 2D variable
    //		t, independent time variable
    //		p, randomizer parameter
    // intermediate:
    //		q, arg to sin/cos to determine noise2d gradient
    //			(0 to 720deg)
    // output:
    //		v, unit-length vector in direction given by q
        
    float q = 0.0;
    vec2 p1 = p;
    vec2 p2 = p * sqrt(splitter);
    for (int i = 0; i < splits; i++)
    {
    	q += sin(p1.x*s.x+p2.x+t);
    	q += sin(p1.y*s.y+p2.y+t);
        p1 *= splitter;
        p2 *= splitter;
    }
    q *= scaler;
    
    return vec2(cos(q), sin(q));
}

vec2 smoother2(vec2 s, vec2 p, float t)
{
    return vec2(0.6, 0.8);
}

float ease(float p)
{
    return ((6.0*p - 15.0)*p + 10.0)*p*p*p;
}

float conv(vec2 whole, vec2 frack, float t)
{
    float a, b, c, d;
    
    a = dot(smoother(whole + vec2(0.0, 0.0), pseudo, t), frack);
    b = dot(smoother(whole + vec2(0.0, 1.0), pseudo, t), vec2(frack.x, frack.y-1.0));
    c = dot(smoother(whole + vec2(1.0, 0.0), pseudo, t), vec2(frack.x-1.0, frack.y));
    d = dot(smoother(whole + vec2(1.0, 1.0), pseudo, t), vec2(frack.x, frack.y)-1.0);

    float u, v;
    u = mix(a, b, ease(frack.y));
    v = mix(c, d, ease(frack.y));
    return mix(u, v, ease(frack.x));
}

float pass(vec2 uv, vec2 grid, const int tIndex)
{    
    vec2 pq = floor(uv*grid);
    vec2 mn = mod(uv*grid, 1.0);
    if (tIndex == 1)
    {
    	return 0.5 + 0.5*conv(pq, mn, time*traveler.x*travSpeed);
    }
    else
    {
        return 0.5 + 0.5*conv(pq, mn, time*traveler.y*travSpeed);
    }
}

void main()
{    
    vec2 fragCoord = vertTexCoord.st * resolution.xy;
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/resolution.xy;
    
    vec2 perlA = vec2(pass(   uv, grid1, 1), pass(   uv, grid1, 2));
    vec2 perlB = vec2(pass(perlA, grid2, 2), pass(perlA, grid2, 1));
    vec2 perlC = vec2(pass(perlB, grid3, 1), pass(perlB, grid3, 2)) + vec2(travOffset, 0.0);
        
    // Time varying pixel color
    vec3 col = 0.5 + 0.5*cos(perlC.xyx*PI2*colorRange + time*PI2*colorSpeed + uv.xyx + vec3(0,2,4));
	
	col = vec3(0.8, 0.0, 0.6) * col.z;
	
    vec4 tex = texture2D(texture, uv);
	
    // Output to screen
    gl_FragColor = vec4(col.rgb * alpha + tex.rgb * (1.0-alpha), 1.0);
}