boolean savingVideo;
boolean resettingInternals;
int frame;
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

double ProbablyNewton(double input, double target)
{
  // Pretend to take the inverse of [integral sqrt(1-x^2)].
  double funprime = Math.sqrt(1 - input*input);
  double function = 0.5 * (input * funprime + Math.asin(input));
  
  // Return the better approximated input.
  return input - (function - target)/funprime;  
}

void GenerateInternals(int shapeCount)
{
  internals = new ArrayList<Viol>();
  
  for (int i = 0; i < shapeCount; i++)
  {
    double nBase = 0; // (Math.random() - 0.5) * PI/3;
    double vBase = 0; // (Math.random() - 0.5) * 2*PI;
    double rBase = 0; //  Math.random()        * radius;
  
    Viol s = new Viol();
    
    s.p = new double[2];
    s.p[0] = Math.random();
    s.p[1] = Math.random();
      fill(204, (int)(s.p[1] * 255), 102, (int)(s.p[0] * 255));
    stroke(204, (int)(s.p[1] * 255), 102, (int)(s.p[0] * 102) + 153);
    System.out.println(String.format("hmm. %d: %01.6f, %01.6f", i, s.p[0], s.p[1]));
    
    s.tri = createShape();
    s.tri.beginShape();
    for (int j = 0; j < 3; j++)
    {
      double nAdd = (Math.random() - 0.5) * PI/2;
      double vAdd = (Math.random() - 0.5) * PI*2;
      double rAdd =  Math.random()        * radius;
      
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
  majorAxis = max(width, height);
  minorAxis = min(width, height);
  size(600, 600, P3D);
//  noLoop();
  savingVideo = true;
  resettingInternals = false;
  frame = 0;
  reroll = 0;
  nInternals = 30;
  radius = minorAxis/2;
  
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
  background(0, 0, 0, 0);
  camera(width/2, height/2, minorAxis/2, width/2, height/2, 0, 0, 1, 0);
  pointLight(width/3, height/3, mouseY, width/2, height/2, mouseX);
  
  
  
  pushMatrix();
  translate(width/2, height/2, -majorAxis/2);
  rotateX(PI / 6);
  
  fill(204, 255*mouseX/width, 102, 54);
  noStroke();
  //sphere(minorAxis/3);
   
  popMatrix();
  
  
  pushMatrix();
  translate(width/2, height/2, -majorAxis/2);
  rotateY(PI   * mouseX/width);
  rotateX(PI/2 * mouseY/width);
  
  for (int i = 0; i < internals.size(); i++)
  {
    Viol s = internals.get(i);
    shape(s.tri);
  }
  
  popMatrix();
  
  
  if (savingVideo)
  {
    save(String.format("wow-%02d-%03d.png", reroll, frame));
    frame++;
  }
}