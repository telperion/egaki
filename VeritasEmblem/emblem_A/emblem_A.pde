PShape emblem;

void setup()
{
  size(480, 480, P3D);
  background(0);
}

void draw()
{
  background(0);
  stroke(color(255, 127, 0, 25));
  fill(color(#FFE600));
  
  translate(width/2, height/2, 0);
  scale(3, 3, 1);
  rotateX(0.1 * PI);
  
  pushMatrix();
  rotateY(0.01 * PI * frameCount);
  
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
  rotateY(-0.01 * PI * frameCount);
  
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
  
  
  saveFrame("frames/####.png");
}
