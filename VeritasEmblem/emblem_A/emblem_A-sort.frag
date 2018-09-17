#version 150

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform float nativeDimension;
uniform int jumpSize;
uniform int oddLines;
uniform vec2 resolution;
uniform sampler2D texture;

varying vec4 vertColor;
varying vec4 vertTexCoord;

const vec4 greyscaler = vec4(0.299, 0.587, 0.114, 0);

void main() {
  int lineHeight = 1;
  for (int i = 0; i < jumpSize; i++)
  {
    lineHeight *= 2;
  }
  int swapWindow = lineHeight * 2;
  
  /*
  float wOrigP = gl_FragCoord.y / swapWindow + float(oddLines) * 0.5;
  float wIndex;
  float wFloat;
  float wAlias;
  float wRecon;
  wFloat = mod(wOrigP, 1.0);
  wIndex = wOrigP - wFloat;

  if (wFloat < 0.5)
  */
  float wAlias;
  float wRecon;
  int pTruer = int(gl_FragCoord.y);
  int pIndex = pTruer / swapWindow;
  int pFloat = pTruer % swapWindow;

  if (pFloat < lineHeight)
  {
    wAlias = gl_FragCoord.y + float(lineHeight * (2*oddLines - 1));
    wRecon = gl_FragCoord.y;
  }
  else
  {
    wAlias = gl_FragCoord.y - float(lineHeight * (2*oddLines - 1));
    wRecon = gl_FragCoord.y;
  }

  vec4 color = textureLod(texture, vec2(gl_FragCoord.x / resolution.x, (wRecon+0.0) / resolution.y), 0);
  vec4 compr = textureLod(texture, vec2(gl_FragCoord.x / resolution.x, (wAlias+0.0) / resolution.y), 0);
  float grey0 = dot(color, greyscaler);
  float grey1 = dot(compr, greyscaler);
  vec4 choice;

  // Sort lowest to highest.
  if (wAlias < 0 || wAlias > resolution.y)
  {
    choice = color;
  }
  else if ((grey0 < grey1) == (wAlias < wRecon))
  {
    choice = compr;
  }
  else
  {
    choice = color;
  }

  gl_FragColor = choice;
}