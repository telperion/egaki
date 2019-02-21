PGraphics pg;

PImage bgImageA;
PImage bgImageB;

PImage logos[];

boolean saving = true;
float frameRateDesired = 60;
float frameLoopLength  = 15;    // seconds

Hex[] field;
Rule ruler = new Rule();

void Init()
{  
  field = new Hex[ruler.recommendedCount()];
  int index = 0;
  
  int fw = ruler.countHorz();
  int fh = ruler.countVert();
  for (int j = 0; j < fh; j++)
  {
    for (int i = 0; i < fw; i++)
    {
      field[index++] = new Hex(i-fw/2, j-fh/2);
    }
  }
}


void setup()
{  
  frameRate(frameRateDesired);
  size(960, 540, P3D);
  //smooth(8);
  
  pg = createGraphics(960, 540, P3D);
  
  Init();
}


void draw()
{
  float ll = frameLoopLength * frameRateDesired;
  float t = float(frameCount) / ll;
  
  pg.beginDraw();
  
  pg.clear();
  pg.background(0, 0, 0, 255);
    
    
  float[] hsv = new float[3];
  float[] rgb = new float[3];
    
  int fw = ruler.countHorz();
  int fh = ruler.countVert();
  for (int j = 0; j < fh; j++)
  {
    for (int i = 0; i < fw; i++)
    {
      ruler.Draw(pg, field[j*fw+i], t);
      
      /*
      hsv[0] = float(i)/fw;
      hsv[1] = float(j)/fh;
      hsv[2] = t % 1.0;
      HSV2RGB(hsv, rgb);
      rgbFill(pg, rgb);
      pg.rect(
        (i+0)*(1280.0/fw),
        (j+0)*( 720.0/fh),
        (1280.0/fw),
        ( 720.0/fh)
      );
      */
    }
  }
  
  //pg.rect(100, 100, 300, 500);
  
  pg.endDraw();
  
      
  image(pg, 0, 0);
    
  if (saving)
  {
    pg.save(String.format("cbREV/%06d.png", frameCount));
    if (frameCount > ll)
    {
      exit();
    }
  }
}




boolean mousing = false;
void mousePressed()
{
  if (!mousing)
  {
    Init();
    mousing = true;
  }
}
void mouseReleased()
{
  mousing = false;
}
