boolean savingVideo;
boolean resettingInternals;
int frame;
int totalFrames;
int inflection;
float tween;
int majorAxis;
int minorAxis;

class Viol
{
  PShape tri;
  double p[];
};

double radius;
int reroll;
int nInternals;
ArrayList<Viol> internals;
ArrayList<PShape> fakeSphere;

float Smoother(float input)
{
  // smooth(x) = -2x^3 + 3x^2, defined on [0, 1]
  return input*input*(3 - 2*input);
}

double ProbablyNewton(double input, double target)
{
  // Pretend to take the inverse of [integral sqrt(1-x^2)].
  double funprime = Math.sqrt(1 - input*input);
  double function = 0.5 * (input * funprime + Math.asin(input));
  
  // Return the better approximated input.
  return input - (function - target)/funprime;  
}

void GenerateFakeSphere(float radius, int detail)
{
  fakeSphere = new ArrayList<PShape>();
  float uStep = PI*2 / detail;
  float vStep = PI   / detail;
  
  // uv-style
  for (int u = 0; u < detail; u++)
  {
    PShape s = createShape();
    s.beginShape(TRIANGLE_STRIP);
    for (int v = 0; v < detail; v++)
    {
      s.vertex(
        (float)(Math.cos((u+0) * uStep) * Math.sin(v * vStep) * radius),
        (float)(                          Math.cos(v * vStep) * radius),
        (float)(Math.sin((u+0) * uStep) * Math.sin(v * vStep) * radius)
        );
      s.vertex(
        (float)(Math.cos((u+1) * uStep) * Math.sin(v * vStep) * radius),
        (float)(                          Math.cos(v * vStep) * radius),
        (float)(Math.sin((u+1) * uStep) * Math.sin(v * vStep) * radius)
        );
    System.out.println(String.format("uhh, (%d, %d)", u, v));
    }
    s.endShape();
    fakeSphere.add(s);
  }
}

void GenerateInternals(int shapeCount)
{
  internals = new ArrayList<Viol>();
  
  emissive(0, 0, 34);
  shininess(10.0);
  specular(0, 204, 255);
  
  for (int i = 0; i < shapeCount; i++)
  {
    double nBase = 0; // (Math.random() - 0.5) * PI/3;
    double vBase = 0; // (Math.random() - 0.5) * 2*PI;
    double rBase = Math.random() * radius * 0.5;
  
    Viol s = new Viol();
    
    s.p = new double[2];
    s.p[0] = Math.random();
    s.p[1] = Math.random();
      fill(
        (int)(s.p[1] * 170) + 16,
        (int)(s.p[1] * 85), 
        (int)(s.p[1] * 255), 
        (int)(s.p[0] * 255)
        );
      stroke(
        (int)(s.p[1] * 170) + 16,
        (int)(s.p[1] * 85), 
        (int)(s.p[1] * 255), 
        (int)(s.p[0] * 153) + 102
        );
      strokeWeight(3);
      strokeCap(ROUND);
    System.out.println(String.format("hmm. %d: %01.6f, %01.6f", i, s.p[0], s.p[1]));
    
    s.tri = createShape();
    s.tri.beginShape();
    for (int j = 0; j < 3; j++)
    {
      double nAdd = (Math.random() - 0.5) * PI/2;
      double vAdd = (Math.random() - 0.5) * PI*2;
      double rAdd =  Math.random()        * radius * 0.8;
      
      double n = Math.max(Math.min(PI/4  , nBase + nAdd), -PI/4);
      double v = Math.max(Math.min(PI    , vBase + vAdd), -PI);
      double r = Math.max(Math.min(radius, rBase + rAdd), 0);
      double u = n;
      
      for (int k = 0; k < 4; k++)
      {
        // System.out.println(String.format("    yo! %d, %d, %d, %01.6f: %01.6f", i, j, k, n, u));
        u = ProbablyNewton(u, n);
      }      
      double latitudinal = Math.sqrt(1 - u*u);
      
      System.out.println(String.format("hey! %d, %d: (%01.6f, %01.6f, %01.6f)", i, j, u, v, r));
      
      s.tri.vertex(
        (float)(r * latitudinal * Math.cos(v)),
        (float)(r * u),
        (float)(r * latitudinal * Math.sin(v))
        );
    }
    s.tri.endShape(CLOSE);
    
    internals.add(s);
  }
}




void setup() 
{
  size(1800, 1200, P3D);
  majorAxis = max(width, height);
  minorAxis = min(width, height);
//  noLoop();
  savingVideo = true;
  resettingInternals = false;
  frame = 0;
  totalFrames = 112;
  inflection = 28;
  tween = 0;
  reroll = 0;
  nInternals = 30;
  radius = minorAxis * 0.8;
  
  GenerateInternals(nInternals);
}

void mousePressed()
{
  if (!resettingInternals)
  {
    reroll++;
    internals.clear();
    GenerateInternals(nInternals);
  }
  resettingInternals = true;
}

void mouseReleased()
{
  resettingInternals = false;
}

void draw()
{
  tween = (float)frame / (float)totalFrames;
  background(0, 0, 0, 0);
  // hint(DISABLE_DEPTH_MASK);
  camera(width/2, height/2, minorAxis/2, width/2, height/2, 0, 0, 1, 0);
  pointLight(204, 51, 255, width/2, height/2, majorAxis/2);
  
    
  pushMatrix();
  translate(width/2, height/2, -majorAxis/2);
  
  rotateX(PI/6);
  rotateY(PI * 2 * Smoother(tween));
    
  fill(102, 0, 255, 31);
  noStroke();
  sphere(minorAxis * 1.5);
  
  for (int i = 0; i < internals.size(); i++)
  {
    Viol s = internals.get(i);
    shape(s.tri);
  }
  
  popMatrix();
  
  ///////////////////////////////////////////////////////////////////////////////////
  // Update operations
  
  if (savingVideo)
  {
    save(String.format("frames/wow-%02d-%03d.png", reroll, frame));
  }
  
  if (frame % inflection == inflection-1)
  {
    if (!resettingInternals)
    {
      reroll++;
      internals.clear();
      GenerateInternals(nInternals);
    }
  }
  
  
  frame++;  
  if (frame > totalFrames)
  {
    frame = 0;
  }
}