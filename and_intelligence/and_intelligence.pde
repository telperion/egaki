PGraphics pg;

PImage warpImageA;
PImage warpImageB;
PShader warpShader;

boolean saving = true;
float frameRateDesired = 60;
float frameLoopLength  = 15;    // seconds

float lastMouseX = 902;
float lastMouseY = 147;

Butt[] flies;

Butt MakeButt()
{
  Butt b = new Butt();
  
  b.size = random(10, 60);
  b.shape = random(1);
  
  b.pos.x = randomGaussian()*butt_loopDistance;
  b.pos.y = randomGaussian()*butt_loopDistance*0.1;
  b.pos.z = randomGaussian()*butt_loopDistance;
  
  b.offsetPath = random(0.8);
  b.offsetFlap = random(butt_wingPeriod);
  
  return b;
}

int nButts = 360;

void Init()
{  
  flies = new Butt[nButts];
  for (int index = 0; index < nButts; index++)
  {
    flies[index] = MakeButt();
  }
}


void setup()
{  
  frameRate(frameRateDesired);
  size(720, 480, P3D);
  //smooth(8);
    
  //warpImageA = loadImage("pickwarp-A2.jpg");
  //warpImageB = loadImage("pickwarp-B.jpg");
  
  //warpShader = loadShader("fishwarp.glsl");
  //warpShader.set("warpTex", warpImageA);
  
  pg = createGraphics(720, 480, P3D);
  
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
    
    
  float[] hsv = new float[3];
  float[] rgb = new float[3];
    
  pg.translate(width/2, height/2);
  pg.scale(1, -1, 1);
  pg.pushMatrix();
    pg.rotateY(PI *  0.200);
    pg.rotateX(PI * -0.300);
    for (int i = 0; i < nButts; i++)
    {
      flies[i].Draw(pg, t);
    }
  pg.popMatrix();
  
  //pg.rect(100, 100, 300, 500);
  //warpShader.set("time", t);
  //pg.filter(warpShader);
  
  pg.endDraw();
  
      
  image(pg, 0, 0);
    
  if (saving)
  {
    pg.save(String.format("intel/%06d.png", frameCount));
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
