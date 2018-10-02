float s = 100;
float b = s*2;
float a = s*2*(1 - sqrt(0.5));


class Point
{
  float x;
  float y;
  float z;
  Point()
  {
    x = 0.0;
    y = 0.0;
    z = 0.0;
  }
  Point(float ix, float iy, float iz)
  {
    x = ix;
    y = iy;
    z = iz;
  }
  
  void RotateX(float arg)
  {
    float iy = y;
    float iz = z;
    y = iy * cos(arg) - iz * sin(arg);
    z = iy * sin(arg) + iz * cos(arg);
  }
  void RotateY(float arg)
  {
    float iz = z;
    float ix = x;
    z = iz * cos(arg) - ix * sin(arg);
    x = iz * sin(arg) + ix * cos(arg);
  }
  void RotateZ(float arg)
  {
    float ix = x;
    float iy = y;
    x = ix * cos(arg) - iy * sin(arg);
    y = ix * sin(arg) + iy * cos(arg);
  }
}

class Tri
{
  Point p[];
  Tri()
  {
    p = new Point[3];
  }
  void Draw()
  {
    if (
      p[0] != null &&
      p[1] != null &&
      p[2] != null
      )
    {
      Point q = new Point(
        (p[0].x + p[1].x + p[2].x) / 3,
        (p[0].y + p[1].y + p[2].y) / 3,
        (p[0].z + p[1].z + p[2].z) / 3
      );
      
      float r = sqrt(q.x*q.x + q.y*q.y + q.z*q.z);
      float l = sqrt(q.x*q.x + q.z*q.z);
      float phi = asin(q.y / r);
      float theta = asin(q.x / (r * cos(phi)));
      
      if (frameCount <= 1)
      {
        print("phi   = ", phi   * 180 / PI, " deg\n");
        print("theta = ", theta * 180 / PI, " deg\n");
      }
      
      for (int i = 0; i < 3; i++)
      {
        if (frameCount <= 1)
        {
          print("(", p[i].x, ", ", p[i].y, ", ", p[i].z, ")\n");
        }
        p[i].RotateY(-theta);
        p[i].RotateZ(-phi);
        if (frameCount <= 1)
        {
          print("(", p[i].x, ", ", p[i].y, ", ", p[i].z, ")\n");
        }
      }
      
      pushMatrix();
        translate(0, 0, r);
        rotateZ(phi);
        rotateY(theta);
        
        triangle(
          p[0].x, p[0].y,
          p[1].x, p[1].y,
          p[2].x, p[2].y
          );        
      popMatrix();
    }
  }
}


void DrawXI()
{
  pushMatrix();
    rotateX(0.5*PI);
    translate(0, 0, s);
    quad(
      -s,    s,
      -s,   -s,
      -s+a, -s,
      -s+a,  s
      );
    quad(
       s,    s,
       s,   -s,
       s-a, -s,
       s-a,  s
      );
  popMatrix();
  
  pushMatrix();
    rotateX(-0.5*PI);
    translate(0, 0, s);
    quad(
      -s,    s,
      -s,   -s,
      -s+a, -s,
      -s+a,  s
      );
    quad(
       s,    s,
       s,   -s,
       s-a, -s,
       s-a,  s
      );
  popMatrix();
  
}

void DrawTest()
{
  int f0 = -1;
  int f1 = -1;
  int f2 = -1;
  for (int i = 0; i < 8; i++)
  {
                     f0 *= -1;
    if (i % 2 == 0) {f1 *= -1;}
    if (i % 4 == 0) {f2 *= -1;}
    
    Tri t = new Tri();
    t.p[0] = new Point(s*f2*0.2, s*f1*0.2, s*f0);
    t.p[1] = new Point(s*f2*0.2, s*f1, s*f0*0.2);
    t.p[2] = new Point(s*f2, s*f1*0.2, s*f0*0.2);
    t.Draw();
  }
}


void setup()
{  
  size(720, 720, P3D);
}

void draw()
{
  background(0);
  
  fill(color(0, 255, 0, 85));
  stroke(color(255, 255, 0, 170));
  
  translate(width/2, height/2, 0);
  
  pushMatrix();
    translate(0, 0, -30);
    scale(2);
    rotateY(0.01 * PI * frameCount);
    rotateX(0.1 * PI);
    
    //box(20, 50, 100);
    
    DrawXI();
    DrawTest();
  popMatrix();
}
