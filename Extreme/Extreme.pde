void setup()
{
  Init();
  
  frameRate(frameRateDesired);
  size(960, 540, P3D);
  //smooth(8);
}

boolean saving = false;
void draw()
{
  float[] hsv = new float[3];
  float[] rgb = new float[3];
  
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
  
  
  
  for (int yy = 0; yy < 2*fh; yy++)
  {
    for (int xx = 0; xx < fw; xx++)
    {
      int index = (yy%fh)*fw+(xx%fw);
      DrawSQ(bq[index], float(frameCount)/float(frameRateDesired), yy/fh);
    }
  }
  
  //fill(105);
  //rect(100, 200, 300, 400);
  
  if (saving)
  {
    saveFrame("frames-B2/extreme-######.png");
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
