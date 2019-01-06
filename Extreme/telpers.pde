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
  
  rgb[0] = hsv[2] + (rgbTemp[0]-hsv[2]) * hsv[1];
  rgb[1] = hsv[2] + (rgbTemp[1]-hsv[2]) * hsv[1];
  rgb[2] = hsv[2] + (rgbTemp[2]-hsv[2]) * hsv[1];  
}
