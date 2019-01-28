PGraphics pg;

PImage bgImageA;
PImage bgImageB;

boolean saving = false;

void setup()
{
  Init();
  
  frameRate(frameRateDesired);
  size(960, 540, P3D);
  //smooth(8);
  
  pg = createGraphics(960, 540, P3D);
  
  bgImageA = loadImage("bgA.png");
  bgImageB = loadImage("bgB.png");
}



void draw()
{
  pg.beginDraw();
  
  pg.clear();
  pg.background(0, 0, 0, 0);
  
  float[] hsv = new float[3];
  float[] rgb = new float[3];
  
  
  for (int yy = 0; yy < fh; yy++)
  {
    for (int xx = 0; xx < fw; xx++)
    {
      int index = (yy%fh)*fw+(xx%fw);
      bq[index].Draw(pg, float(frameCount)/float(frameRateDesired));
    }
  }
  
  pg.endDraw();
  
  
  /*
  for (int i = 0; i < 3; i++)
  {
    hsv[i] = c0[i]*(1.0 - bgStrength) + c1[i]*(bgStrength);
  }
  HSV2RGB(hsv, rgb);
  background(
    int(255*rgb[0]),
    int(255*rgb[1]),
    int(255*rgb[2])
    );
  */
  beginShape();
  textureMode(NORMAL);
  float ll = plLoop * frameRateDesired;
  float currentPoint = (frameCount % (2*ll)) / (2*ll);
  if (currentPoint > 0.4 && currentPoint < 0.9)
  {
    texture(bgImageA);
  }
  else
  {
    texture(bgImageB);
  }
  vertex( 0,  0, 0, 0);
  vertex( 0, sh, 0, 1);
  vertex(sw, sh, 1, 1);
  vertex(sw,  0, 1, 0);
  endShape();
    
  image(pg, 0, 0);
  
  //fill(105);
  //rect(100, 200, 300, 400);
  
  if (saving)
  {
    pg.save(String.format("frames/%06d.png", frameCount));
    if (frameCount >= plLoop*frameRateDesired * 3.0)
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
