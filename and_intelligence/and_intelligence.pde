PGraphics pg;

PImage intelBanner;
PImage intelSeed;
PShader intelShader;
PShader intelBG;

boolean saving = true;
float frameRateDesired = 60;
float frameLoopLength  = 6;    // seconds

float lastMouseX = 902;
float lastMouseY = 147;

Butt[] flies;
float[] flyHSV;
float[] flyRGB;

Butt MakeButt()
{
  Butt b = new Butt();
  
  b.size = random(20, 100);
  b.shape = random(1);
  
  b.pos.x = butt_loopDistance*randomGaussian();
  b.pos.y = butt_loopDistance*(randomGaussian()*0.3 + 0.2);
  b.pos.z = butt_loopDistance*(randomGaussian()     - 0.0);
  
  b.offsetPath = random(1.0);
  b.offsetFlap = random(butt_wingPeriod);
  
  float pinkening = randomGaussian();
  flyHSV[0] = (340 + pinkening*10)/360;
  flyHSV[1] = 0.7 - pinkening*0.2;  
  for (int i = 0; i < 3; i++)
  {
    flyHSV[2] = 0.8 - 0.1 * i;
    HSV2RGB(flyHSV, flyRGB);
    
    b.col[i].r = flyRGB[0] * 255;
    b.col[i].g = flyRGB[1] * 255;
    b.col[i].b = flyRGB[2] * 255;
    b.col[i].a = 255;
  }
  
  return b;
}

int nButts = 360;

void Init()
{  
  flyHSV = new float[3];
  flyRGB = new float[3];
  
  flies = new Butt[nButts];
  for (int index = 0; index < nButts; index++)
  {
    flies[index] = MakeButt();
  }
}


void setup()
{  
  frameRate(frameRateDesired);
  size(1280, 960, P3D);
  //smooth(8);
    
  intelBanner = loadImage("andintel-B2.png");
  intelSeed = loadImage("perlin-A3.png");
  
  intelBG = loadShader("backdrop.glsl");
  intelBG.set("seedTex", intelSeed);
  intelShader = loadShader("prettify.glsl");
  
  pg = createGraphics(1280, 960, P3D);
  
  Init();
}


void draw()
{
  float ll = frameLoopLength * frameRateDesired;
  float t = float(frameCount) / ll;
  
  if (false) //(mousing)
  {    
    lastMouseX = mouseX;
    lastMouseY = mouseY;
  }
  
  pg.beginDraw();
  
  pg.clear();
  pg.background(0, 0, 0, 255);
  intelBG.set("time", t);
  pg.filter(intelBG);
    
    
  float[] hsv = new float[3];
  float[] rgb = new float[3];
    
  pg.translate(width/2, height/2);
  
  pg.pushMatrix();
    pg.scale(1, -1, 1);
    pg.rotateY(PI * -0.250);
    pg.rotateX(PI * -0.300);
    for (int i = 0; i < nButts; i++)
    {
      flies[i].Draw(pg, t);
    }
  pg.popMatrix();
  
  pg.pushMatrix();
    pg.scale(0.8);
    //pg.rotateY(PI *  0.010 * sin(2*PI*t));
    //pg.rotateX(PI *  0.020 * cos(2*PI*t));
    
    pg.beginShape();
    pg.textureMode(NORMAL);
    pg.texture(intelBanner);
    pg.vertex(-418, -164, 0, 0);
    pg.vertex( 418, -164, 1, 0);
    pg.vertex( 418,  164, 1, 1);
    pg.vertex(-418,  164, 0, 1);
    pg.endShape(CLOSE);
  pg.popMatrix();
  
  //pg.rect(100, 100, 300, 500);
  intelShader.set("time", t);
  pg.filter(intelShader);
  
  pg.endDraw();
  
      
  image(pg, 0, 0);
    
  if (saving)
  {
    pg.save(String.format("intel-b/%06d.png", frameCount));
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
    //Init();
    mousing = true;
  }
}
void mouseReleased()
{
  mousing = false;
  print(String.format("x = %9.5f, y = %9.5f\n", lastMouseX/width - 0.5, lastMouseY/height - 0.5));
  print(String.format("mx = %6f, my = %6f\n", lastMouseX, lastMouseY));
}
