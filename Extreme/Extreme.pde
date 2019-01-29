PGraphics pg;

PImage bgImageA;
PImage bgImageB;

PImage logos[];

boolean saving = true;

void setup()
{
  Init();
  
  frameRate(frameRateDesired);
  size(960, 540, P3D);
  //smooth(8);
  
  pg = createGraphics(960, 540, P3D);
  
  bgImageA = loadImage("bgA.png");
  bgImageB = loadImage("bgB.png");
  
  logos = new PImage[3];
  logos[0] = loadImage("G6-logo.png");
  logos[1] = loadImage("sfe-logo.png");
  logos[2] = loadImage("fst-logo.png");
}


void draw()
{
  pg.beginDraw();
  
  pg.clear();
  pg.background(0, 0, 0, 0);
  
  
  // MOVE THIS OUT OF THE GRAPHICS CONTEXT EVENTUALLY
  pg.beginShape();
  pg.textureMode(NORMAL);
  float ll = plLoop * frameRateDesired;
  float currentPoint = (frameCount % (2*ll)) / (2*ll);
  if (currentPoint > 0.3 && currentPoint < 0.8)
  {
    pg.texture(bgImageA);
  }
  else
  {
    pg.texture(bgImageB);
  }
  pg.vertex( 0,  0, 0, 0);
  pg.vertex( 0, sh, 0, 1);
  pg.vertex(sw, sh, 1, 1);
  pg.vertex(sw,  0, 1, 0);
  pg.endShape();
  // MOVE THIS OUT OF THE GRAPHICS CONTEXT EVENTUALLY
  
  
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
  
  float logoDropOffset = 0.2;
  float logoDropTime = plLoop - logoDropOffset*2;
  float t = (float(frameCount)/float(frameRateDesired)) % plLoop;
  float tt = (t-0.1) / (2.5-0.1);
  tt = (tt > 1) ? 1 : ((tt < 0) ? 0 : tt);
  
  float logoApothem  = sh * 0.15;
  float rotateCenter = (tt-0.5) * PI/12;
  float rotateInward = 4*(1-tt)*tt * PI/6;
  float distToCenter = sh * 0.25 * (0.7 + 1.2*(1-tt)*tt);
  float centerDisplc = turnabout(tt, 0.2) * (sh + distToCenter + logoApothem) * 0.6 + sh*0.03;
  
  pg.noStroke();
  for (int i = 0; i < 3; i++)
  {
    pg.pushMatrix();
      pg.translate(sw/2, sh/2 + centerDisplc, distToCenter * 0.2);
      pg.rotateX(PI/24);
      pg.rotateZ(2*PI/3*i + rotateCenter - PI/2);
      pg.rotateY(-rotateInward);
      pg.translate(distToCenter, 0);
      pg.rotateZ(-(2+(i+1)%3)*PI/2);
          
      pg.beginShape();
      pg.textureMode(NORMAL);
      pg.texture(logos[i]);
      pg.vertex(-logoApothem, -logoApothem, 0, 0);
      pg.vertex(-logoApothem,  logoApothem, 0, 1);
      pg.vertex( logoApothem,  logoApothem, 1, 1);
      pg.vertex( logoApothem, -logoApothem, 1, 0);
      pg.endShape();
    pg.popMatrix();
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
    
  image(pg, 0, 0);
  
  //fill(105);
  //rect(100, 200, 300, 400);
  
  if (saving)
  {
    pg.save(String.format("stinger-20190129/%06d.png", frameCount));
    if (frameCount >= ll * 2.0)
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
