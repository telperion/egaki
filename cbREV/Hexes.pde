class Hex
{
  int x;
  int y;
  
  float tweenOffset;
  float colorIndex;
  
  Hex(int x, int y)
  {
    this.x = x;
    this.y = y;
    this.tweenOffset = random(1.0);
    this.colorIndex  = random(1.0);
  }
  
  Hex() {this(0, 0);}
}

class Rule
{
  float[] hsvA  = {0.75, 1.00, 0.05};
  float[] hsvB1 = {0.80, 0.80, 0.70};
  float[] hsvB2 = {0.60, 0.50, 0.60};
  
  float[] hsvPick;
  float[] hsvTell;
  
  float sw = 960;
  float sh = 540;
  float ss = 20;    // radius (not apothem)
  
  float zFwd = 0.1;
  
  Rule()
  {
    hsvPick = new float[3];
    hsvTell = new float[3];
  }
  
  
  int countHorz()
  {
    return ceil(sw/(1.5*ss)) + 1;
  }  
  int countVert()
  {
    return ceil(sh/(sqrt(3)*ss)) + 1;
  }
  
  int recommendedCount()
  {
    return countHorz() * countVert();
  }
  
  void Position(float[] pos, Hex info, float t)
  {
    if (pos == null)
    {
      pos = new float[2];
    }
    
    float alt = float((info.x + 1573) % 2)/2.0;
    pos[0] = sw/2 + ss * (info.x +            0 ) * 1.5;
    pos[1] = sh/2 + ss * (info.y +          alt ) * sqrt(3);
  }
  
  float InnerRadius(Hex info, float t)
  {
    t = (t + info.tweenOffset) % 1.0;
    return ss * (0.2 + 0.6 * 4.0*t*(1-t));
  }
  float OuterRadius(Hex info, float t)
  {
    t = (t + info.tweenOffset) % 1.0;
    return ss * (0.5 + 0.5 * 4.0*t*(1-t));
  }
  
  float ColorTweener(float t)
  {
    float a = 15;     // should be 3 (mod 4) b/c sinusoid period reasons
    float b = 80; //20;     // higher numbers scrunch the flickers
    float c = 0.754;  // move flickers earlier/later
                      // these values have been fine-tuned in desmos to approach (1, 0)
    
    float f = atan(exp(b * (t - c)));
    float g = (1 + sin(a * f))/2;
    float h = t*(2-t);//4 * t * (1 - t);
    float j = t;
    
    return j * g + (1 - j) * h;    
  }
  
  
  void Color(float[] rgb, Hex info, float t, int ringIndex, int segIndex)
  {
    t = (t + info.tweenOffset) % 1.0;
    
    if (rgb == null)
    {
      rgb = new float[3];
    }
    
    float tt = ColorTweener(t);
    
    for (int i = 0; i < 3; i++)
    {
      hsvPick[i] = hsvB1[i] * info.colorIndex + hsvB2[i] * (1 - info.colorIndex);
    }
    
    for (int i = 0; i < 3; i++)
    {
      hsvTell[i] = hsvA[i] * (1 - tt) + hsvPick[i] * tt;
    }
    
    if (ringIndex == 0)
    {
      // Outer only
      hsvTell[2] *= 0.9;
    }
    
    if (segIndex == 3)
    {
      hsvTell[0] -= 0.01;
    }
    else if (segIndex == 1)
    {
      hsvTell[0] += 0.01;
    }
    
    HSV2RGB(hsvTell, rgb);
  }
  
  
  void Draw(PGraphics pg, Hex info, float t)
  {
    float[] rgb = new float[3];
    float[] pos = new float[2];
    Position(pos, info, t);
    float outer = OuterRadius(info, t);
    float inner = InnerRadius(info, t);
    
    pg.noStroke();
    
    // Outer
    pg.pushMatrix();
      pg.translate(pos[0], pos[1]);
      pg.scale(outer);
      
      Color(rgb, info, t, 0, 0);  rgbFill(pg, rgb);
      
      pg.beginShape(TRIANGLES);
      for (int i = 0; i < 6; i++)
      {
        Color(rgb, info, t, 0, i);  rgbFill(pg, rgb);
        pg.vertex(               0,                     0,       0);
        pg.vertex( cos(TWO_PI* i   /6.0), sin(TWO_PI* i   /6.0), 0);
        pg.vertex( cos(TWO_PI*(i+1)/6.0), sin(TWO_PI*(i+1)/6.0), 0);
      }
      pg.endShape();
    pg.popMatrix();
    
    // Inner
    pg.pushMatrix();
      pg.translate(pos[0], pos[1]);
      pg.scale(inner);
      
      Color(rgb, info, t, 1, 0);
      pg.fill(int(rgb[0]*255), int(rgb[1]*255), int(rgb[2]*255));
      
      pg.beginShape(TRIANGLES);
      for (int i = 0; i < 6; i++)
      {
        Color(rgb, info, t, 1, i);  rgbFill(pg, rgb);
        pg.vertex(               0,                     0,       zFwd);
        pg.vertex( cos(TWO_PI* i   /6.0), sin(TWO_PI* i   /6.0), zFwd);
        pg.vertex( cos(TWO_PI*(i+1)/6.0), sin(TWO_PI*(i+1)/6.0), zFwd);
      }
      pg.endShape();
    pg.popMatrix();
    
    //print(String.format("(%3d, %3d): (%7.3f, %7.3f), %7.3f, %7.3f, 0x%06X\n", info.x, info.y, pos[0], pos[1], outer, inner, colorToInt(rgb)));
  }
}
