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

float grey(color c)
{
  return 0.299 * float(c & 0xFF0000) / float(0xFF0000) +    // red
         0.587 * float(c & 0x00FF00) / float(0x00FF00) +    // green
         0.114 * float(c & 0x0000FF) / float(0x0000FF);     // blue
}

int find_closest_color(color p[], color c, float w, boolean dither_active)
{
  // w = grey vs. hue weighting
  // 0.0 = all grey
  // 1.0 = all hue
  // return index of closest color
  
  int palette_size = p.length;
  int i_nearest = -1;
  float f_nearest = -1;
  int i_next_nearest = -1;
  float f_next_nearest = -1;
  
  float h = hue(c) / 256.0;    // [0.0, 1.0) but keep in mind it's circular
  float g = grey(c);           // [0.0, 1.0)
  
  for (int i = 0; i < palette_size; i++)
  {
    float h_comp = hue(p[i]) / 255.0;
    float g_comp = grey(p[i]);
    
    float gvh = abs(g - g_comp) * (1.0 - w) +
                abs((1.0 + h - h_comp) % 1.0) * w;
                
    //print(String.format("g = %5.3f, h = %5.3f vs. g = %5.3f, h = %5.3f\n", g, h, g_comp, h_comp));
    
    if ((i_nearest == -1 || f_nearest == -1) || (f_nearest > gvh))
    {
      i_next_nearest = i_nearest;
      f_next_nearest = f_nearest;
      i_nearest = i;
      f_nearest = gvh;
    } 
    else if ((i_next_nearest == -1 || f_next_nearest == -1) || (f_next_nearest > gvh))
    {
      i_next_nearest = i;
      f_next_nearest = gvh;
    }   
  }
  
  if (dither_active)
  {
    return i_next_nearest;
  }
  else
  {
    return i_nearest;
  }
}
