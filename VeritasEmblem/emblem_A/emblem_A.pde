PShape emblem;
int FP1 = int( 60 * sqrt( 7));
int FP2 = int( 60 * sqrt( 2));
int FP3 = int( 60 * sqrt( 3));
int FP4 = int( 60 * sqrt( 5));
int FP5 = int(120 * sqrt( 1));
int FPGCD = 120+1;

int sortPass = 32;
int decimate = 4; 

PShader colorShader; 
PShader sortShader;

void setup()
{
  size(480, 480, P3D);
    
  colorShader = loadShader("emblem_A-frag.glsl");
  sortShader  = loadShader("emblem_A-sort.frag");
  
  sortShader.set("nativeDimension", 480.0);
}

float sigmata(float x, float p)
{
  // Tailor f(x) = tanh(px) - mx to transition tighter or looser.
  // p is a stretching parameter - higher p, tighter transition.
  // p -> 0   approaches a cubic transition.
  // p -> inf approaches a  step transition.
  x = 2*x-1;
  p = 1/p;
  
  float d = sqrt(1+p);
  float denom = d*d*d;
  float q = p/denom;
    
  float f_defAsOddFunc = denom * (x/sqrt(x*x+p) - q*x);
  //System.out.println(String.format("%.6f, %.6f", f_defAsOddFunc, f_scale));
  return f_defAsOddFunc*0.5f + 0.5f;  
}

void draw()
{  
  int fc = frameCount / sortPass;
  
  float mx = 0.1; // mouseX/width;
  float my = 0.9; // mouseY/height;
  // Tween control parameters.
  float iraOffset = 0.2;
  float iraExtent = 0.5;
  float ira = 0.5 + 0.5*sin((fc / (float)FP3 + iraOffset) * 2*PI);
  
  float brkOffset = 0.4;
  float brkExtent = 0.2;
  float brk = 0.5 + 0.5*sin((fc / (float)FP4 + brkOffset) * 2*PI);  
  
  float sp = (0.2 + 19.8*mx);
  float s1 = sigmata(((fc +     0)%FP1)/(float)FP1, sp);
  float s2 = sigmata(((fc +    30)%FP2)/(float)FP2, sp);
  float si = sigmata(ira, sp);
  float sb = sigmata(brk, sp);
  
  float inRectArg = (45 + 45 * (2*si-1) * iraExtent) * PI/180;
  float inH = 23 * cos(inRectArg);    // 40^2 + 24^2 is about 46^2
  float inW = 23 * sin(inRectArg);    // 40^2 + 24^2 is about 46^2
  float inC = max(inH, inW);          // rectangle's cross-dimension
  float inE = min(inH, inW);          // rectangle's   end-dimension
  
  float brkArg    = (45 + 45 * (2*sb-1) * brkExtent) * PI/180;
  float brkH = 56 * cos(brkArg);      // 96^2 + 60^2 is about 112^2
  float brkW = 56 * sin(brkArg);      // 96^2 + 60^2 is about 112^2
  float brkI = 12;                    // bracket gap
  
  if (frameCount % sortPass == 0)
  {
    background(color(#4C4C4C));
    
    stroke(color(255, 127, 0, 25));
    fill(color(#FFE600));
    
    translate(width/2, height/2, 0);
    scale(3, 3, 1);
    
    pointLight(
      255, 204, 51,
      0, 120 * my - 60, 120
      );
      
    rotateX(0.1 * PI);
    
    
    pushMatrix();
    rotateY(PI * s1);
    
      pushMatrix();
      //rotateZ(0.5 * PI);
      
        // vertical pole (±60 to edge of inner box)
        pushMatrix();  translate( 0,  (60+inC+2)/2, 0);  box(4, 60-inC-2, 6);  popMatrix(); 
        pushMatrix();  translate( 0, -(60+inC+2)/2, 0);  box(4, 60-inC-2, 6);  popMatrix();
        // horizontal pole (±36 to edge of inner box)
        pushMatrix();  translate( (36+inC+2)/2,  0, 0);  box(36-inC-2, 4, 6);  popMatrix(); 
        pushMatrix();  translate(-(36+inC+2)/2,  0, 0);  box(36-inC-2, 4, 6);  popMatrix();
        
        // Inner box 1 ("foreground") / the peephole
        pushMatrix();  translate(  0,  inH, 0);  box(2*inW+4, 4, 6);  popMatrix(); 
        pushMatrix();  translate(  0, -inH, 0);  box(2*inW+4, 4, 6);  popMatrix();
        pushMatrix();  translate(-inW,   0, 0);  box(4, 2*inH+4, 6);  popMatrix(); 
        pushMatrix();  translate( inW,   0, 0);  box(4, 2*inH+4, 6);  popMatrix();
        
        // Inner box 2 ("background") / the bracketer
        if (inH > inW)
        {
          pushMatrix();
          rotateZ(0.5 * PI);
          //applyMatrix(
          //  0.0, 1.0, 0.0, 0.0,
          //  1.0, 0.0, 0.0, 0.0,
          //  0.0, 0.0, 1.0, 0.0,
          //  0.0, 0.0, 0.0, 1.0
          //);
        }
        pushMatrix();  translate(   0,   inC         , 0);  box(2*inE+4, 4, 6);  popMatrix(); 
        pushMatrix();  translate(   0,  -inC         , 0);  box(2*inE+4, 4, 6);  popMatrix();
        pushMatrix();  translate(-inE,  (inC+inE+4)/2, 0);  box(4, inC-inE, 6);  popMatrix(); 
        pushMatrix();  translate( inE,  (inC+inE+4)/2, 0);  box(4, inC-inE, 6);  popMatrix(); 
        pushMatrix();  translate( inE, -(inC+inE+4)/2, 0);  box(4, inC-inE, 6);  popMatrix(); 
        pushMatrix();  translate(-inE, -(inC+inE+4)/2, 0);  box(4, inC-inE, 6);  popMatrix();
        if (inH > inW)
        {
          popMatrix();
        }
      
      popMatrix();
      
    popMatrix();
    
    
    
      
    
    pushMatrix();
    rotateY(-PI * s2);
    
      pushMatrix();
      //rotateZ(0.5 * PI);
    
        pushMatrix();  translate(-(brkW-2),  (brkH+brkI)/2, 0);  box(4, brkH-brkI, 6);  popMatrix();
        pushMatrix();  translate( (brkW-2),  (brkH+brkI)/2, 0);  box(4, brkH-brkI, 6);  popMatrix();
        pushMatrix();  translate( (brkW-2), -(brkH+brkI)/2, 0);  box(4, brkH-brkI, 6);  popMatrix();
        pushMatrix();  translate(-(brkW-2), -(brkH+brkI)/2, 0);  box(4, brkH-brkI, 6);  popMatrix();   
        pushMatrix();  translate(-(brkW+brkI)/2,  (brkH-2), 0);  box(brkW-brkI, 4, 6);  popMatrix(); 
        pushMatrix();  translate( (brkW+brkI)/2,  (brkH-2), 0);  box(brkW-brkI, 4, 6);  popMatrix(); 
        pushMatrix();  translate( (brkW+brkI)/2, -(brkH-2), 0);  box(brkW-brkI, 4, 6);  popMatrix(); 
        pushMatrix();  translate(-(brkW+brkI)/2, -(brkH-2), 0);  box(brkW-brkI, 4, 6);  popMatrix();
      
      popMatrix();
      
    popMatrix();
    
    colorShader.set("time", (float)fc / (float)FP5);
    filter(colorShader);
  }
  
  //sortShader.set("jumpSize",  frameCount % sortPass  + 0); 
  sortShader.set("jumpSize", (sortPass - (frameCount % sortPass)) / decimate + (decimate - frameCount % decimate));
  sortShader.set("oddLines", (frameCount % sortPass) % 2);
  filter(sortShader);
  
  //saveFrame("frames/######.png");
  
  if (frameCount % sortPass == 4*decimate)
  {
    saveFrame("frames/######.png");
  }
    
  if ((frameCount+1) / sortPass >= FPGCD)
  {
    exit();
  }
}
