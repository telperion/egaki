#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform float time;
uniform sampler2D texture;

varying vec4 vertColor;
varying vec4 vertTexCoord;

const vec4 greyscaler = vec4(0.299, 0.587, 0.114, 0);

vec3 HueToBasis(float h)
{
    h = mod(6.0*h, 6.0);
    float v = mod(h, 1.0);
    
    if (h < 1.0)
    {
        return vec3(  1.0,   v, 0.0);
    }
    else if (h < 2.0)
    {
        return vec3(1.0-v, 1.0, 0.0);
    }
    else if (h < 3.0)
    {
        return vec3(0.0,   1.0,   v);
    }
    else if (h < 4.0)
    {
        return vec3(0.0, 1.0-v, 1.0);
    }
    else if (h < 5.0)
    {
        return vec3(  v, 0.0,   1.0);
    }
    else
    {
        return vec3(1.0, 0.0, 1.0-v);
    }
}

void main() {
  vec4 color = texture2D(texture, vertTexCoord.st);
  float grey = dot(color, greyscaler);

  gl_FragColor = vec4(grey * HueToBasis(time + grey*0.5), 1.0);
  /*
  if (
    (vertTexCoord.s > 0.2 && vertTexCoord.s < 0.7) &&
    (vertTexCoord.t > vertTexCoord.s) &&
    (vertTexCoord.t < vertTexCoord.s + 0.1)
    )
  {
    gl_FragColor = vec4(vec3(0.7), 1.0);
  }
  else if (
    (vertTexCoord.s > 0.3 && vertTexCoord.s < 0.8) &&
    (vertTexCoord.t > vertTexCoord.s - 0.1) &&
    (vertTexCoord.t < vertTexCoord.s)
    )
  {
    gl_FragColor = vec4(vec3(0.3), 1.0);
  }
  else
  {
    gl_FragColor = vec4(vec3(0.5), 1.0);
  }
  */
}