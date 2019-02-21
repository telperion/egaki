void HSV2RGB(float[] hsv, float[] rgb)
{
  if (rgb == null)
  {
    rgb = new float[3];
  }
  
  float rgbTemp[] = new float[3];
  float hueScale = ((hsv[0] % 1.0)*6.0 + 6.0) % 6.0;
  switch (int(hueScale) % 6)
  {
    case 0:
      rgbTemp[0] = 1.0;
      rgbTemp[1] = hueScale % 1.0;
      rgbTemp[2] = 0.0;
    break;
    case 1:
      rgbTemp[0] = 1.0 - (hueScale % 1.0);
      rgbTemp[1] = 1.0;
      rgbTemp[2] = 0.0;
    break;
    case 2:
      rgbTemp[0] = 0.0;
      rgbTemp[1] = 1.0;
      rgbTemp[2] = hueScale % 1.0;
    break;
    case 3:
      rgbTemp[0] = 0.0;
      rgbTemp[1] = 1.0 - (hueScale % 1.0);
      rgbTemp[2] = 1.0;
    break;
    case 4:
      rgbTemp[0] = hueScale % 1.0;
      rgbTemp[1] = 0.0;
      rgbTemp[2] = 1.0;
    break;
    default:
      rgbTemp[0] = 1.0;
      rgbTemp[1] = 0.0;
      rgbTemp[2] = 1.0 - (hueScale % 1.0);
    break;
  }
  
  if (hsv[2] < 0.5)
  {
    rgbTemp[0] *= hsv[2] * 2.0;
    rgbTemp[1] *= hsv[2] * 2.0;
    rgbTemp[2] *= hsv[2] * 2.0;
  }
  else
  {
    rgbTemp[0] = 1.0 - (1.0 - rgbTemp[0]) * (1.0 - hsv[2]) * 2.0;
    rgbTemp[1] = 1.0 - (1.0 - rgbTemp[1]) * (1.0 - hsv[2]) * 2.0;
    rgbTemp[2] = 1.0 - (1.0 - rgbTemp[2]) * (1.0 - hsv[2]) * 2.0;
  }
  
  rgb[0] = hsv[2] + (rgbTemp[0]-hsv[2]) * hsv[1];
  rgb[1] = hsv[2] + (rgbTemp[1]-hsv[2]) * hsv[1];
  rgb[2] = hsv[2] + (rgbTemp[2]-hsv[2]) * hsv[1];  
}

int colorToInt(float[] col)
{
  int ret = 0;
  for (int i = 0; i < 3; i++)
  {
    int x = floor(col[i] * 255);
    ret = (ret << 8) + x;
  }
  return 0xFF0000; //ret;
}

void rgbFill(PGraphics pg, float[] rgb)
{
  pg.fill(int(rgb[0]*255), int(rgb[1]*255), int(rgb[2]*255));
}
void rgbStroke(PGraphics pg, float[] rgb)
{
  pg.fill(int(rgb[0]*255), int(rgb[1]*255), int(rgb[2]*255));
}
