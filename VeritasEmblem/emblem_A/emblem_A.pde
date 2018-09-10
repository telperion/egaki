PShape emblem;

void setup()
{
  size(480, 480, P3D);
  background(0);
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
  background(0);
  stroke(color(255, 127, 0, 25));
  fill(color(#FFE600));
  
  translate(width/2, height/2, 0);
  scale(3, 3, 1);
  rotateX(0.1 * PI);
  
  float sp = (1 + 9*mouseX/width);
  float s1 = sigmata(((frameCount +  0)%60)/60.0f, sp);
  float s2 = sigmata(((frameCount + 30)%60)/60.0f, sp);
  
  pushMatrix();
  rotateY(PI * s1);
  
    pushMatrix();
    //rotateZ(0.5 * PI);
    
      pushMatrix();  translate(  0,  41, 0);  box(4, 38, 6);  popMatrix(); 
      pushMatrix();  translate(  0, -41, 0);  box(4, 38, 6);  popMatrix();
      pushMatrix();  translate(-29,   0, 0);  box(14, 4, 6);  popMatrix(); 
      pushMatrix();  translate( 29,   0, 0);  box(14, 4, 6);  popMatrix();
      
      pushMatrix();  translate(  0,  12, 0);  box(44, 4, 6);  popMatrix(); 
      pushMatrix();  translate(  0, -12, 0);  box(44, 4, 6);  popMatrix();
      pushMatrix();  translate(-20,   0, 0);  box(4, 28, 6);  popMatrix(); 
      pushMatrix();  translate( 20,   0, 0);  box(4, 28, 6);  popMatrix();
      
      pushMatrix();  translate(  0,  20, 0);  box(28, 4, 6);  popMatrix(); 
      pushMatrix();  translate(  0, -20, 0);  box(28, 4, 6);  popMatrix();
      pushMatrix();  translate(-12,  18, 0);  box(4,  8, 6);  popMatrix(); 
      pushMatrix();  translate( 12,  18, 0);  box(4,  8, 6);  popMatrix(); 
      pushMatrix();  translate( 12, -18, 0);  box(4,  8, 6);  popMatrix(); 
      pushMatrix();  translate(-12, -18, 0);  box(4,  8, 6);  popMatrix();
    
    popMatrix();
    
  popMatrix();
  
  
  
    
  
  pushMatrix();
  rotateY(-PI * s2);
  
    pushMatrix();
    //rotateZ(0.5 * PI);
  
      pushMatrix();  translate(-46,  20, 0);  box(4, 20, 6);  popMatrix();
      pushMatrix();  translate( 46,  20, 0);  box(4, 20, 6);  popMatrix();
      pushMatrix();  translate( 46, -20, 0);  box(4, 20, 6);  popMatrix();
      pushMatrix();  translate(-46, -20, 0);  box(4, 20, 6);  popMatrix();   
      pushMatrix();  translate(-29,  28, 0);  box(38, 4, 6);  popMatrix(); 
      pushMatrix();  translate( 29,  28, 0);  box(38, 4, 6);  popMatrix(); 
      pushMatrix();  translate( 29, -28, 0);  box(38, 4, 6);  popMatrix(); 
      pushMatrix();  translate(-29, -28, 0);  box(38, 4, 6);  popMatrix();
    
    popMatrix();
    
  popMatrix();
  
  
  //saveFrame("frames/####.png");
}
