float s = 100;
float b = s*2;
float a = s*2*(1 - sqrt(0.5));



float clasp(float t, float t0, float t1)
{
  if (t1 > t0)
  {
    return t < t0 ? 0 : t > t1 ? 1 : (t - t0)/(t1 - t0);
  }  
  else
  {
    float swap = t0; t0 = t1; t1 = swap;
    return 1 - (t < t0 ? 0 : t > t1 ? 1 : (t - t0)/(t1 - t0));
  }
}

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
      Point v1 = new Point(
        (p[1].x - p[0].x), 
        (p[1].y - p[0].y), 
        (p[1].z - p[0].z) 
      );
      Point v2 = new Point(
        (p[2].x - p[0].x), 
        (p[2].y - p[0].y), 
        (p[2].z - p[0].z) 
      );
      Point n = new Point(
        (v1.y*v2.z - v1.z*v2.y),
        (v1.z*v2.x - v1.x*v2.z),
        (v1.x*v2.y - v1.y*v2.x)
      );
      
      if (frameCount <= 1)
      {
        print("center: (", q.x, ", ", q.y, ", ", q.z, ")\n");
        print("normal: (", n.x, ", ", n.y, ", ", n.z, ")\n");
      }
      
      float l = sqrt(n.x*n.x + n.z*n.z);
      float phi = atan2(n.y, l);
      float theta = atan2(n.x, n.z);
      
      if (frameCount <= 1)
      {
        print("phi   = ", phi   * 180 / PI, " deg\n");
        print("theta = ", theta * 180 / PI, " deg\n");
      }
      
      for (int i = 0; i < 3; i++)
      {
        p[i].x -= q.x;
        p[i].y -= q.y;
        p[i].z -= q.z;
        
        
        if (frameCount <= 1)
        {
          print("(", p[i].x, ", ", p[i].y, ", ", p[i].z, ")\n");
        }
        p[i].RotateY(-theta);
        if (frameCount <= 1)
        {
          print("(", p[i].x, ", ", p[i].y, ", ", p[i].z, ")\n");
        }
        p[i].RotateX(phi);
        if (frameCount <= 1)
        {
          print("(", p[i].x, ", ", p[i].y, ", ", p[i].z, ")\n");
        }
      }
      
      
        if (frameCount <= 1)
        {
          print("n (", n.x, ", ", n.y, ", ", n.z, ")\n");
        }
        n.RotateY(-theta);
        if (frameCount <= 1)
        {
          print("n (", n.x, ", ", n.y, ", ", n.z, ")\n");
        }
        n.RotateX(phi);
        if (frameCount <= 1)
        {
          print("n (", n.x, ", ", n.y, ", ", n.z, ")\n");
        }
        
      
      pushMatrix();
        translate(q.x, q.y, q.z);
        rotateY(theta);
        rotateX(-phi);
        
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
    t.p[0] = new Point(s*f2*0.1, s*f1*0.1, s*f0);
    t.p[1] = new Point(s*f2*0.1, s*f1, s*f0*0.1);
    t.p[2] = new Point(s*f2, s*f1*0.1, s*f0*0.1);
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
    rotateY(0.001 * PI * frameCount);
    rotateX(0.1 * PI);
    
    //box(20, 50, 100);
    
    DrawXI();
    DrawTest();
  popMatrix();
  
  if (frameCount % 10 == 0)
  {
    saveFrame("frames/####.png");
  }
}
