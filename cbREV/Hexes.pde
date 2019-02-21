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
  float[] hsvA  = {0.67, 0.60, 0.00};
  float[] hsvB1 = {0.78, 0.72, 0.86};
  float[] hsvB2 = {0.60, 0.50, 0.50};
  
  float[] hsvPick;
  float[] hsvTell;
  
  float sw = 1280;
  float sh = 720;
  float ss = 30;    // radius (not apothem)
  
  float zFwd = 0.2;
  
  Rule()
  {
    hsvPick = new float[3];
    hsvTell = new float[3];
  }
  
  
  int countHorz()
  {
    return ceil(sw/(1.5*ss));
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
    return ss * (0.2 + 0.5 * 4.0*t*(1-t));
  }
  float OuterRadius(Hex info, float t)
  {
    t = (t + info.tweenOffset) % 1.0;
    return ss * (0.7 + 0.2 * 4.0*t*(1-t));
  }
  
  float ColorTweener(float t)
  {
    float a = 19;     // should be 3 (mod 4) b/c sinusoid period reasons
    float b = 80; //20;     // higher numbers scrunch the flickers
    float c = 0.754;  // move flickers earlier/later
                      // these values have been fine-tuned in desmos to approach (1, 0)
    
    float f = atan(exp(b * (t - c)));
    float g = (1 + sin(a * f))/2;
    float h = 4 * t * (1 - t);
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
      hsvTell[2] *= 0.5;
    }
    
    if (segIndex == 2)
    {
      hsvTell[0] -= 0.05;
    }
    else if (segIndex == 3)
    {
      hsvTell[0] += 0.05;
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
      
      pg.beginShape(TRIANGLE_FAN);      
      Color(rgb, info, t, 0, 0);  rgbFill(pg, rgb);  pg.vertex( 0,              0,   0);
      Color(rgb, info, t, 0, 0);  rgbFill(pg, rgb);  pg.vertex( 1.0,            0,   0);
      Color(rgb, info, t, 0, 1);  rgbFill(pg, rgb);  pg.vertex( 0.5,  sqrt(3) * 0.5, 0);
      Color(rgb, info, t, 0, 2);  rgbFill(pg, rgb);  pg.vertex(-0.5,  sqrt(3) * 0.5, 0);
      Color(rgb, info, t, 0, 3);  rgbFill(pg, rgb);  pg.vertex(-1.0,            0,   0);
      Color(rgb, info, t, 0, 4);  rgbFill(pg, rgb);  pg.vertex(-0.5, -sqrt(3) * 0.5, 0);
      Color(rgb, info, t, 0, 5);  rgbFill(pg, rgb);  pg.vertex( 0.5, -sqrt(3) * 0.5, 0);
      Color(rgb, info, t, 0, 0);  rgbFill(pg, rgb);  pg.vertex( 1.0,            0,   0);
      pg.endShape();
    pg.popMatrix();
    
    // Inner
    pg.pushMatrix();
      pg.translate(pos[0], pos[1]);
      pg.scale(inner);
      
      Color(rgb, info, t, 1, 0);
      pg.fill(int(rgb[0]*255), int(rgb[1]*255), int(rgb[2]*255));
      
      pg.beginShape(TRIANGLE_FAN);
      Color(rgb, info, t, 1, 0);  rgbFill(pg, rgb);  pg.vertex( 0,              0,   zFwd);
      Color(rgb, info, t, 1, 0);  rgbFill(pg, rgb);  pg.vertex( 1.0,            0,   zFwd);
      Color(rgb, info, t, 1, 1);  rgbFill(pg, rgb);  pg.vertex( 0.5,  sqrt(3) * 0.5, zFwd);
      Color(rgb, info, t, 1, 2);  rgbFill(pg, rgb);  pg.vertex(-0.5,  sqrt(3) * 0.5, zFwd);
      Color(rgb, info, t, 1, 3);  rgbFill(pg, rgb);  pg.vertex(-1.0,            0,   zFwd);
      Color(rgb, info, t, 1, 4);  rgbFill(pg, rgb);  pg.vertex(-0.5, -sqrt(3) * 0.5, zFwd);
      Color(rgb, info, t, 1, 5);  rgbFill(pg, rgb);  pg.vertex( 0.5, -sqrt(3) * 0.5, zFwd);
      Color(rgb, info, t, 1, 0);  rgbFill(pg, rgb);  pg.vertex( 1.0,            0,   zFwd);
      pg.endShape();
    pg.popMatrix();
    
    //print(String.format("(%3d, %3d): (%7.3f, %7.3f), %7.3f, %7.3f, 0x%06X\n", info.x, info.y, pos[0], pos[1], outer, inner, colorToInt(rgb)));
  }
}
