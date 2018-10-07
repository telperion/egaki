float s = 180;
float b = s*2;
float a = s*0.4;//2*(1 - sqrt(0.5));
float crossRatio = (s-a/2)/s;
float m = a*crossRatio;
float h = s*2*(s-a)/(s-a/2);
float w = (s-a)*(h-s)/s;
float nx1 = (2*s-h)*crossRatio;

float xrot;
float yrot;

Point XIPts[];
Tri   XITri[];
Point IOPts[];
Tri   IOTri[];
Point ONPts[];
Tri   ONTri[];
Point NXPts[];
Tri   NXTri[];

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
  void Scale(float s)
  {
    x *= s;
    y *= s;
    z *= s;
  }
}

class Tri
{
  Point p[];
  Tri()
  {
    p = new Point[3];
  }
  Tri(Point p0, Point p1, Point p2)
  {
    p = new Point[6];
    p[0] = p0;
    p[1] = p1;
    p[2] = p2;
  }
  void Draw()
  {
    if (
      p[0] != null &&
      p[1] != null &&
      p[2] != null
      )
    {
      p[3] = new Point(p[0].x, p[0].y, p[0].z);
      p[4] = new Point(p[1].x, p[1].y, p[1].z);
      p[5] = new Point(p[2].x, p[2].y, p[2].z);
      
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
        p[i+3].x -= q.x;
        p[i+3].y -= q.y;
        p[i+3].z -= q.z;
                
        p[i+3].RotateY(-theta);
        p[i+3].RotateX(phi);
      }
      n.RotateY(-theta);
      n.RotateX(phi);
        
      
      pushMatrix();
        translate(q.x, q.y, q.z);
        rotateY(theta);
        rotateX(-phi);
        
        triangle(
          p[3].x, p[3].y,
          p[4].x, p[4].y,
          p[5].x, p[5].y
          );        
      popMatrix();
    }
  }
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

void SetupXI()
{  
  if (XIPts == null || XITri == null)
  {
    XIPts = new Point[60];
    
    int p = 0;
    
    // top rite flat
    XIPts[p++] = new Point( s,    s,    s);          // 00
    XIPts[p++] = new Point( s-a,  s,    s);          // 01
    XIPts[p++] = new Point( s-a,  s,   -s);          // 02
    XIPts[p++] = new Point( s,    s,   -s);          // 03
    // top left flat
    XIPts[p++] = new Point(-s,    s,    s);          // 04
    XIPts[p++] = new Point(-s+a,  s,    s);          // 05
    XIPts[p++] = new Point(-s+a,  s,   -s);          // 06
    XIPts[p++] = new Point(-s,    s,   -s);          // 07
    // btm rite flat
    XIPts[p++] = new Point( s,   -s,    s);          // 08
    XIPts[p++] = new Point( s-a, -s,    s);          // 09
    XIPts[p++] = new Point( s-a, -s,   -s);          // 10
    XIPts[p++] = new Point( s,   -s,   -s);          // 11
    // btm left flat
    XIPts[p++] = new Point(-s,   -s,    s);          // 12
    XIPts[p++] = new Point(-s+a, -s,    s);          // 13
    XIPts[p++] = new Point(-s+a, -s,   -s);          // 14
    XIPts[p++] = new Point(-s,   -s,   -s);          // 15
    
    // fwd top rite bar end
    XIPts[p++] = new Point( s-m,    s-a,  s);      // 16
    XIPts[p++] = new Point( s-m-a,  s-a,  s);      // 17
    // fwd top left bar end
    XIPts[p++] = new Point(-s+m,    s-a,  s);      // 18
    XIPts[p++] = new Point(-s+m+a,  s-a,  s);      // 19
    // fwd btm rite bar end
    XIPts[p++] = new Point( s-m,   -s+a,  s);      // 20
    XIPts[p++] = new Point( s-m-a, -s+a,  s);      // 21
    // fwd btm left bar end
    XIPts[p++] = new Point(-s+m,   -s+a,  s);      // 22
    XIPts[p++] = new Point(-s+m+a, -s+a,  s);      // 23
    // aft top rite bar end
    XIPts[p++] = new Point( s-m,    s-a, -s);      // 24
    XIPts[p++] = new Point( s-m-a,  s-a, -s);      // 25
    // aft top left bar end
    XIPts[p++] = new Point(-s+m,    s-a, -s);      // 26
    XIPts[p++] = new Point(-s+m+a,  s-a, -s);      // 27
    // aft btm rite bar end
    XIPts[p++] = new Point( s-m,   -s+a, -s);      // 28
    XIPts[p++] = new Point( s-m-a, -s+a, -s);      // 29
    // aft btm left bar end
    XIPts[p++] = new Point(-s+m,   -s+a, -s);      // 30
    XIPts[p++] = new Point(-s+m+a, -s+a, -s);      // 31
    
    // fwd top rite stem inset
    XIPts[p++] = new Point( s-m,    s-a,  a/2);    // 32
    XIPts[p++] = new Point( s-m-a,  s-a,  a/2);    // 33
    // fwd top left stem inset
    XIPts[p++] = new Point(-s+m,    s-a,  a/2);    // 34
    XIPts[p++] = new Point(-s+m+a,  s-a,  a/2);    // 35
    // fwd btm rite stem inset
    XIPts[p++] = new Point( s-m,   -s+a,  a/2);    // 36
    XIPts[p++] = new Point( s-m-a, -s+a,  a/2);    // 37
    // fwd btm left stem inset
    XIPts[p++] = new Point(-s+m,   -s+a,  a/2);    // 38
    XIPts[p++] = new Point(-s+m+a, -s+a,  a/2);    // 39
    // aft top rite stem inset
    XIPts[p++] = new Point( s-m,    s-a, -a/2);    // 40
    XIPts[p++] = new Point( s-m-a,  s-a, -a/2);    // 41
    // aft top left stem inset
    XIPts[p++] = new Point(-s+m,    s-a, -a/2);    // 42
    XIPts[p++] = new Point(-s+m+a,  s-a, -a/2);    // 43
    // aft btm rite stem inset
    XIPts[p++] = new Point( s-m,   -s+a, -a/2);    // 44
    XIPts[p++] = new Point( s-m-a, -s+a, -a/2);    // 45
    // aft btm left stem inset
    XIPts[p++] = new Point(-s+m,   -s+a, -a/2);    // 46
    XIPts[p++] = new Point(-s+m+a, -s+a, -a/2);    // 47
    
    
    // top left crossbar unjoin
    XIPts[p++] = new Point(-s+2*m,  s-2*a,  a/2);  // 48
    XIPts[p++] = new Point(-s+2*m,  s-2*a, -a/2);  // 49
    // btm rite crossbar unjoin
    XIPts[p++] = new Point( s-2*m, -s+2*a,  a/2);  // 50
    XIPts[p++] = new Point( s-2*m, -s+2*a, -a/2);  // 51
    
    
    
    XITri = new Tri[100];
    
    int i = 0;
        
    
    // top rite flat
    XITri[i++] = new Tri(XIPts[ 0], XIPts[ 1], XIPts[ 2]);
    XITri[i++] = new Tri(XIPts[ 0], XIPts[ 2], XIPts[ 3]);
    // top left flat
    XITri[i++] = new Tri(XIPts[ 4], XIPts[ 5], XIPts[ 6]);
    XITri[i++] = new Tri(XIPts[ 4], XIPts[ 6], XIPts[ 7]);
    // btm rite flat
    XITri[i++] = new Tri(XIPts[ 8], XIPts[ 9], XIPts[10]);
    XITri[i++] = new Tri(XIPts[ 8], XIPts[10], XIPts[11]);
    // btm left flat
    XITri[i++] = new Tri(XIPts[12], XIPts[13], XIPts[14]);
    XITri[i++] = new Tri(XIPts[12], XIPts[14], XIPts[15]);
    
    // top rite far
    XITri[i++] = new Tri(XIPts[ 2], XIPts[ 3], XIPts[24]);
    XITri[i++] = new Tri(XIPts[ 2], XIPts[24], XIPts[25]);
    // top left far
    XITri[i++] = new Tri(XIPts[ 6], XIPts[ 7], XIPts[26]);
    XITri[i++] = new Tri(XIPts[ 6], XIPts[26], XIPts[27]);
    // btm rite far
    XITri[i++] = new Tri(XIPts[10], XIPts[11], XIPts[28]);
    XITri[i++] = new Tri(XIPts[10], XIPts[28], XIPts[29]);
    // btm left far
    XITri[i++] = new Tri(XIPts[14], XIPts[15], XIPts[30]);
    XITri[i++] = new Tri(XIPts[14], XIPts[30], XIPts[31]);
    
    // top rite near
    XITri[i++] = new Tri(XIPts[ 0], XIPts[ 1], XIPts[17]);
    XITri[i++] = new Tri(XIPts[ 0], XIPts[16], XIPts[17]);
    // top left near
    XITri[i++] = new Tri(XIPts[ 4], XIPts[ 5], XIPts[19]);
    XITri[i++] = new Tri(XIPts[ 4], XIPts[18], XIPts[19]);
    // btm rite near
    XITri[i++] = new Tri(XIPts[ 8], XIPts[ 9], XIPts[21]);
    XITri[i++] = new Tri(XIPts[ 8], XIPts[20], XIPts[21]);
    // btm left near
    XITri[i++] = new Tri(XIPts[12], XIPts[13], XIPts[23]);
    XITri[i++] = new Tri(XIPts[12], XIPts[22], XIPts[23]);
    
    // top rite outer
    XITri[i++] = new Tri(XIPts[ 0], XIPts[ 3], XIPts[24]);
    XITri[i++] = new Tri(XIPts[ 0], XIPts[16], XIPts[24]);
    // top left outer
    XITri[i++] = new Tri(XIPts[ 4], XIPts[ 7], XIPts[26]);
    XITri[i++] = new Tri(XIPts[ 4], XIPts[18], XIPts[26]);
    // btm rite outer
    XITri[i++] = new Tri(XIPts[ 8], XIPts[11], XIPts[28]);
    XITri[i++] = new Tri(XIPts[ 8], XIPts[20], XIPts[28]);
    // btm left outer
    XITri[i++] = new Tri(XIPts[12], XIPts[15], XIPts[30]);
    XITri[i++] = new Tri(XIPts[12], XIPts[22], XIPts[30]);
    
    // top rite inner
    XITri[i++] = new Tri(XIPts[ 1], XIPts[ 2], XIPts[25]);
    XITri[i++] = new Tri(XIPts[ 1], XIPts[17], XIPts[25]);
    // top left inner
    XITri[i++] = new Tri(XIPts[ 5], XIPts[ 6], XIPts[27]);
    XITri[i++] = new Tri(XIPts[ 5], XIPts[19], XIPts[27]);
    // btm rite inner
    XITri[i++] = new Tri(XIPts[ 9], XIPts[10], XIPts[29]);
    XITri[i++] = new Tri(XIPts[ 9], XIPts[21], XIPts[29]);
    // btm left inner
    XITri[i++] = new Tri(XIPts[13], XIPts[14], XIPts[31]);
    XITri[i++] = new Tri(XIPts[13], XIPts[23], XIPts[31]);
    
    // fwd top rite inner flat
    XITri[i++] = new Tri(XIPts[16], XIPts[17], XIPts[32]);
    XITri[i++] = new Tri(XIPts[17], XIPts[32], XIPts[33]);
    // fwd top left inner flat
    XITri[i++] = new Tri(XIPts[18], XIPts[19], XIPts[34]);
    XITri[i++] = new Tri(XIPts[19], XIPts[34], XIPts[35]);
    // fwd btm rite inner flat
    XITri[i++] = new Tri(XIPts[20], XIPts[21], XIPts[36]);
    XITri[i++] = new Tri(XIPts[21], XIPts[36], XIPts[37]);
    // fwd btm left inner flat
    XITri[i++] = new Tri(XIPts[22], XIPts[23], XIPts[38]);
    XITri[i++] = new Tri(XIPts[23], XIPts[38], XIPts[39]);
    // aft top rite inner flat
    XITri[i++] = new Tri(XIPts[24], XIPts[25], XIPts[40]);
    XITri[i++] = new Tri(XIPts[25], XIPts[40], XIPts[41]);
    // aft top left inner flat
    XITri[i++] = new Tri(XIPts[26], XIPts[27], XIPts[42]);
    XITri[i++] = new Tri(XIPts[27], XIPts[42], XIPts[43]);
    // aft btm rite inner flat
    XITri[i++] = new Tri(XIPts[28], XIPts[29], XIPts[44]);
    XITri[i++] = new Tri(XIPts[29], XIPts[44], XIPts[45]);
    // aft btm left inner flat
    XITri[i++] = new Tri(XIPts[30], XIPts[31], XIPts[46]);
    XITri[i++] = new Tri(XIPts[31], XIPts[46], XIPts[47]);
    
    // fwd  TR/BL crossbar 
    XITri[i++] = new Tri(XIPts[32], XIPts[33], XIPts[38]);
    XITri[i++] = new Tri(XIPts[32], XIPts[38], XIPts[39]);
    // aft  TR/BL crossbar
    XITri[i++] = new Tri(XIPts[40], XIPts[41], XIPts[46]);
    XITri[i++] = new Tri(XIPts[40], XIPts[46], XIPts[47]);
    // rite TR/BL crossbar
    XITri[i++] = new Tri(XIPts[32], XIPts[40], XIPts[47]);
    XITri[i++] = new Tri(XIPts[32], XIPts[39], XIPts[47]);
    // left TR/BL crossbar
    XITri[i++] = new Tri(XIPts[33], XIPts[41], XIPts[46]);
    XITri[i++] = new Tri(XIPts[33], XIPts[38], XIPts[46]);
        
    // fwd  TL crossbar unjoin
    XITri[i++] = new Tri(XIPts[34], XIPts[35], XIPts[48]);
    // aft  TL crossbar unjoin
    XITri[i++] = new Tri(XIPts[42], XIPts[43], XIPts[49]);
    // rite TL crossbar unjoin
    XITri[i++] = new Tri(XIPts[35], XIPts[43], XIPts[48]);
    XITri[i++] = new Tri(XIPts[43], XIPts[48], XIPts[49]);
    // left TL crossbar unjoin
    XITri[i++] = new Tri(XIPts[34], XIPts[42], XIPts[48]);
    XITri[i++] = new Tri(XIPts[42], XIPts[48], XIPts[49]);
        
    // fwd  BR crossbar unjoin
    XITri[i++] = new Tri(XIPts[36], XIPts[37], XIPts[50]);
    // aft  BR crossbar unjoin
    XITri[i++] = new Tri(XIPts[44], XIPts[45], XIPts[51]);
    // rite BR crossbar unjoin
    XITri[i++] = new Tri(XIPts[36], XIPts[44], XIPts[50]);
    XITri[i++] = new Tri(XIPts[44], XIPts[50], XIPts[51]);
    // left BR crossbar unjoin
    XITri[i++] = new Tri(XIPts[37], XIPts[45], XIPts[50]);
    XITri[i++] = new Tri(XIPts[45], XIPts[50], XIPts[51]);
  }
}


void DrawXI()
{  
  for (int i = 0; i < 76; i++)
  {
    if (XITri[i] != null)
    {
      XITri[i].Draw();
    }
  }
}


void SetupIO()
{
  
  if (IOPts == null || IOTri == null)
  {
    IOPts = new Point[60];
    
    int p = 0;
    
    // top flat
    IOPts[p++] = new Point( s,  s,  a/2);          // 00
    IOPts[p++] = new Point( s,  s, -a/2);          // 01
    IOPts[p++] = new Point(-s,  s, -a/2);          // 02
    IOPts[p++] = new Point(-s,  s,  a/2);          // 03
    // btm flat
    IOPts[p++] = new Point( s, -s,  a/2);          // 04
    IOPts[p++] = new Point( s, -s, -a/2);          // 05
    IOPts[p++] = new Point(-s, -s, -a/2);          // 06
    IOPts[p++] = new Point(-s, -s,  a/2);          // 07
    
    // top bar end
    IOPts[p++] = new Point( s,  s-a,  a/2+m);      // 08
    IOPts[p++] = new Point( s,  s-a, -a/2-m);      // 09
    IOPts[p++] = new Point(-s,  s-a, -a/2-m);      // 10
    IOPts[p++] = new Point(-s,  s-a,  a/2+m);      // 11
    // btm bar end
    IOPts[p++] = new Point( s, -s+a,  a/2+m);      // 12
    IOPts[p++] = new Point( s, -s+a, -a/2-m);      // 13
    IOPts[p++] = new Point(-s, -s+a, -a/2-m);      // 14
    IOPts[p++] = new Point(-s, -s+a,  a/2+m);      // 15
        
    // top inset outers
    IOPts[p++] = new Point( a/2,  s-a,  a/2+m);    // 16
    IOPts[p++] = new Point( a/2,  s-a, -a/2-m);    // 17
    IOPts[p++] = new Point(-a/2,  s-a, -a/2-m);    // 18
    IOPts[p++] = new Point(-a/2,  s-a,  a/2+m);    // 19
    // btm inset outers
    IOPts[p++] = new Point( a/2, -s+a,  a/2+m);    // 20
    IOPts[p++] = new Point( a/2, -s+a, -a/2-m);    // 21
    IOPts[p++] = new Point(-a/2, -s+a, -a/2-m);    // 22
    IOPts[p++] = new Point(-a/2, -s+a,  a/2+m);    // 23    
    
    // fwd elbow
    IOPts[p++] = new Point( a/2,  0,  s);          // 24
    IOPts[p++] = new Point(-a/2,  0,  s);          // 25
    IOPts[p++] = new Point(-a/2,  0,  s-a);        // 26
    IOPts[p++] = new Point( a/2,  0,  s-a);        // 27
    // aft elbow
    IOPts[p++] = new Point( a/2,  0, -s);          // 28
    IOPts[p++] = new Point(-a/2,  0, -s);          // 29
    IOPts[p++] = new Point(-a/2,  0, -s+a);        // 30
    IOPts[p++] = new Point( a/2,  0, -s+a);        // 31    
    
    // top inset center
    IOPts[p++] = new Point( a/2,  s-a, 0);         // 32
    IOPts[p++] = new Point(-a/2,  s-a, 0);         // 33    
    // btm inset center
    IOPts[p++] = new Point( a/2, -s+a, 0);         // 34
    IOPts[p++] = new Point(-a/2, -s+a, 0);         // 35
             
    
    IOTri = new Tri[100];
    
    int i = 0;        
        
    // top flat
    IOTri[i++] = new Tri(IOPts[ 0], IOPts[ 1], IOPts[ 2]);
    IOTri[i++] = new Tri(IOPts[ 0], IOPts[ 2], IOPts[ 3]);
    // btm flat
    IOTri[i++] = new Tri(IOPts[ 4], IOPts[ 5], IOPts[ 6]);
    IOTri[i++] = new Tri(IOPts[ 4], IOPts[ 6], IOPts[ 7]);
    
    // top rite bar end
    IOTri[i++] = new Tri(IOPts[ 0], IOPts[ 1], IOPts[ 8]);
    IOTri[i++] = new Tri(IOPts[ 1], IOPts[ 8], IOPts[ 9]);
    // top left bar end
    IOTri[i++] = new Tri(IOPts[ 2], IOPts[ 3], IOPts[10]);
    IOTri[i++] = new Tri(IOPts[ 3], IOPts[10], IOPts[11]);
    // btm rite bar end
    IOTri[i++] = new Tri(IOPts[ 4], IOPts[ 5], IOPts[12]);
    IOTri[i++] = new Tri(IOPts[ 5], IOPts[12], IOPts[13]);
    // btm left bar end
    IOTri[i++] = new Tri(IOPts[ 6], IOPts[ 7], IOPts[14]);
    IOTri[i++] = new Tri(IOPts[ 7], IOPts[14], IOPts[15]);
    
    // fwd top bar
    IOTri[i++] = new Tri(IOPts[ 0], IOPts[ 3], IOPts[ 8]);
    IOTri[i++] = new Tri(IOPts[ 3], IOPts[ 8], IOPts[11]);
    // aft top bar
    IOTri[i++] = new Tri(IOPts[ 1], IOPts[ 2], IOPts[ 9]);
    IOTri[i++] = new Tri(IOPts[ 2], IOPts[ 9], IOPts[10]);
    // fwd btm bar
    IOTri[i++] = new Tri(IOPts[ 4], IOPts[ 7], IOPts[12]);
    IOTri[i++] = new Tri(IOPts[ 7], IOPts[12], IOPts[15]);
    // aft btm bar
    IOTri[i++] = new Tri(IOPts[ 5], IOPts[ 6], IOPts[13]);
    IOTri[i++] = new Tri(IOPts[ 6], IOPts[13], IOPts[14]);
    
    // rite top bar unders
    IOTri[i++] = new Tri(IOPts[ 8], IOPts[ 9], IOPts[16]);
    IOTri[i++] = new Tri(IOPts[ 9], IOPts[16], IOPts[17]);
    // left top bar unders
    IOTri[i++] = new Tri(IOPts[10], IOPts[11], IOPts[18]);
    IOTri[i++] = new Tri(IOPts[11], IOPts[18], IOPts[19]);
    // rite btm bar unders
    IOTri[i++] = new Tri(IOPts[12], IOPts[13], IOPts[20]);
    IOTri[i++] = new Tri(IOPts[13], IOPts[20], IOPts[21]);
    // left btm bar unders
    IOTri[i++] = new Tri(IOPts[14], IOPts[15], IOPts[22]);
    IOTri[i++] = new Tri(IOPts[15], IOPts[22], IOPts[23]);
        
    // fwd rite top elbow
    IOTri[i++] = new Tri(IOPts[16], IOPts[32], IOPts[27]);
    IOTri[i++] = new Tri(IOPts[16], IOPts[27], IOPts[24]);
    // aft rite top elbow
    IOTri[i++] = new Tri(IOPts[17], IOPts[32], IOPts[31]);
    IOTri[i++] = new Tri(IOPts[17], IOPts[31], IOPts[28]);
    // fwd left top elbow
    IOTri[i++] = new Tri(IOPts[19], IOPts[33], IOPts[25]);
    IOTri[i++] = new Tri(IOPts[33], IOPts[25], IOPts[26]);
    // aft left top elbow
    IOTri[i++] = new Tri(IOPts[18], IOPts[33], IOPts[29]);
    IOTri[i++] = new Tri(IOPts[33], IOPts[29], IOPts[30]);
    // fwd rite btm elbow
    IOTri[i++] = new Tri(IOPts[20], IOPts[34], IOPts[27]);
    IOTri[i++] = new Tri(IOPts[20], IOPts[27], IOPts[24]);
    // aft rite btm elbow
    IOTri[i++] = new Tri(IOPts[21], IOPts[34], IOPts[31]);
    IOTri[i++] = new Tri(IOPts[21], IOPts[31], IOPts[28]);
    // fwd left btm elbow
    IOTri[i++] = new Tri(IOPts[23], IOPts[35], IOPts[25]);
    IOTri[i++] = new Tri(IOPts[35], IOPts[25], IOPts[26]);
    // aft left btm elbow
    IOTri[i++] = new Tri(IOPts[22], IOPts[35], IOPts[29]);
    IOTri[i++] = new Tri(IOPts[35], IOPts[29], IOPts[30]);
    
    // fwd top outer elbow
    IOTri[i++] = new Tri(IOPts[16], IOPts[19], IOPts[24]);
    IOTri[i++] = new Tri(IOPts[19], IOPts[24], IOPts[25]);
    // aft top outer elbow    
    IOTri[i++] = new Tri(IOPts[17], IOPts[18], IOPts[28]);
    IOTri[i++] = new Tri(IOPts[18], IOPts[28], IOPts[29]);
    // fwd btm outer elbow
    IOTri[i++] = new Tri(IOPts[20], IOPts[23], IOPts[24]);
    IOTri[i++] = new Tri(IOPts[23], IOPts[24], IOPts[25]);
    // aft btm outer elbow
    IOTri[i++] = new Tri(IOPts[21], IOPts[22], IOPts[28]);
    IOTri[i++] = new Tri(IOPts[22], IOPts[28], IOPts[29]);
    // fwd top inner elbow
    IOTri[i++] = new Tri(IOPts[32], IOPts[33], IOPts[26]);
    IOTri[i++] = new Tri(IOPts[32], IOPts[26], IOPts[27]);
    // aft top inner elbow    
    IOTri[i++] = new Tri(IOPts[32], IOPts[33], IOPts[30]);
    IOTri[i++] = new Tri(IOPts[32], IOPts[30], IOPts[31]);
    // fwd btm inner elbow
    IOTri[i++] = new Tri(IOPts[34], IOPts[35], IOPts[26]);
    IOTri[i++] = new Tri(IOPts[34], IOPts[26], IOPts[27]);
    // aft btm inner elbow
    IOTri[i++] = new Tri(IOPts[34], IOPts[35], IOPts[30]);
    IOTri[i++] = new Tri(IOPts[34], IOPts[30], IOPts[31]);
  }
}

void DrawIO()
{  
  for (int i = 0; i < 60; i++)
  {
    if (IOTri[i] != null)
    {
      IOTri[i].Draw();
    }
  }
}


void SetupON()
{
  
  if (ONPts == null || ONTri == null)
  {
    ONPts = new Point[56];
    
    int p = 0;
        
    // top fwd flat
    ONPts[p++] = new Point(-a,  s,  s);          // 00
    ONPts[p++] = new Point(-a,  s,  s-a);        // 00
    ONPts[p++] = new Point( a,  s,  s-a);        // 00
    ONPts[p++] = new Point( a,  s,  s);          // 00
    // top aft flat
    ONPts[p++] = new Point(-a,  s, -s);          // 00
    ONPts[p++] = new Point(-a,  s, -s+a);        // 00
    ONPts[p++] = new Point( a,  s, -s+a);        // 00
    ONPts[p++] = new Point( a,  s, -s);          // 00
    // btm fwd flat
    ONPts[p++] = new Point(-a, -s,  s);          // 00
    ONPts[p++] = new Point(-a, -s,  s-a);        // 00
    ONPts[p++] = new Point( a, -s,  s-a);        // 00
    ONPts[p++] = new Point( a, -s,  s);          // 00
    // btm aft flat
    ONPts[p++] = new Point(-a, -s, -s);          // 00
    ONPts[p++] = new Point(-a, -s, -s+a);        // 00
    ONPts[p++] = new Point( a, -s, -s+a);        // 00
    ONPts[p++] = new Point( a, -s, -s);          // 00
    
    // rite outer O-elbows
    ONPts[p++] = new Point( s,  0,  s);          // 00
    ONPts[p++] = new Point( s,  0,  s-a);        // 00
    ONPts[p++] = new Point( s,  0, -s+a);        // 00
    ONPts[p++] = new Point( s,  0, -s);          // 00
    // left outer O-elbows
    ONPts[p++] = new Point(-s,  0,  s);          // 00
    ONPts[p++] = new Point(-s,  0,  s-a);        // 00
    ONPts[p++] = new Point(-s,  0, -s+a);        // 00
    ONPts[p++] = new Point(-s,  0, -s);          // 00
    // rite inner O-elbows
    ONPts[p++] = new Point( s-a,  0,  s);        // 00
    ONPts[p++] = new Point( s-a,  0,  s-a);      // 00
    ONPts[p++] = new Point( s-a,  0, -s+a);      // 00
    ONPts[p++] = new Point( s-a,  0, -s);        // 00
    // left inner O-elbows
    ONPts[p++] = new Point(-s+a,  0,  s);        // 00
    ONPts[p++] = new Point(-s+a,  0,  s-a);      // 00
    ONPts[p++] = new Point(-s+a,  0, -s+a);      // 00
    ONPts[p++] = new Point(-s+a,  0, -s);        // 00
    
    // rite outer N-crossbend
    ONPts[p++] = new Point( s-w,  h-s,  s-a);    // 00
    ONPts[p++] = new Point( s-w, -h+s, -s+a);    // 00
    // left outer N-crossbend
    ONPts[p++] = new Point(-s+w,  h-s,  s-a);    // 00
    ONPts[p++] = new Point(-s+w, -h+s, -s+a);    // 00
    // rite inner N-crossbend
    ONPts[p++] = new Point( s-w-a,  h-s,  s-a);  // 00
    ONPts[p++] = new Point( s-w-a, -h+s, -s+a);  // 00
    // left inner N-crossbend
    ONPts[p++] = new Point(-s+w+a,  h-s,  s-a);  // 00
    ONPts[p++] = new Point(-s+w+a, -h+s, -s+a);  // 00
    
    // rite N-elbows
    ONPts[p++] = new Point( s,    0,  s-a);      // 00
    ONPts[p++] = new Point( s-a,  0,  s-a);      // 00
    ONPts[p++] = new Point( s-a,  0, -s+a);      // 00
    ONPts[p++] = new Point( s,    0, -s+a);      // 00
    // left N-elbows
    ONPts[p++] = new Point(-s,    0,  s-a);      // 00
    ONPts[p++] = new Point(-s+a,  0,  s-a);      // 00
    ONPts[p++] = new Point(-s+a,  0, -s+a);      // 00
    ONPts[p++] = new Point(-s,    0, -s+a);      // 00
    
    // top fwd O-point
    ONPts[p++] = new Point(0,  s-a,  s);         // 00
    ONPts[p++] = new Point(0,  s-a,  s-a);       // 00
    // top aft O-point
    ONPts[p++] = new Point(0,  s-a, -s);         // 00
    ONPts[p++] = new Point(0,  s-a, -s+a);       // 00
    // btm fwd O-point
    ONPts[p++] = new Point(0, -s+a,  s);         // 00
    ONPts[p++] = new Point(0, -s+a,  s-a);       // 00
    // btm aft O-point
    ONPts[p++] = new Point(0, -s+a, -s);         // 00
    ONPts[p++] = new Point(0, -s+a, -s+a);       // 00
    
    
    
    ONTri = new Tri[100];
    
    int i = 0;        
    
    // top rite flat
    ONTri[i++] = new Tri(ONPts[ 0], ONPts[ 1], ONPts[ 2]);
  }
}

void DrawON()
{  
  for (int i = 0; i < 56; i++)
  {
    if (ONPts[i] != null)
    {
      pushMatrix();
      translate(ONPts[i].x, ONPts[i].y, ONPts[i].z);
      rotateY(-yrot);
            
      fill(color(170, 255, 255, 170));
      text(i, 0.0, 0.0, 0.0);
      popMatrix();
      
      //ONTri[i].Draw();
    }
  }
}



void SetupNX()
{
  
  if (NXPts == null || NXTri == null)
  {
    NXPts = new Point[64];
    
    int p = 0;
    
    // top rite fwd flat
    NXPts[p++] = new Point( s,    s,    s);          // 00 
    NXPts[p++] = new Point( s,    s,    s-a);        // 01
    NXPts[p++] = new Point( s-a,  s,    s-a);        // 02 
    NXPts[p++] = new Point( s-a,  s,    s);          // 03 
    // top rite aft flat
    NXPts[p++] = new Point( s,    s,   -s);          // 04 
    NXPts[p++] = new Point( s,    s,   -s+a);        // 05 
    NXPts[p++] = new Point( s-a,  s,   -s+a);        // 06 
    NXPts[p++] = new Point( s-a,  s,   -s);          // 07 
    // top left fwd flat
    NXPts[p++] = new Point(-s,    s,    s);          // 08 
    NXPts[p++] = new Point(-s,    s,    s-a);        // 09 
    NXPts[p++] = new Point(-s+a,  s,    s-a);        // 10 
    NXPts[p++] = new Point(-s+a,  s,    s);          // 11 
    // top left aft flat
    NXPts[p++] = new Point(-s,    s,   -s);          // 12 
    NXPts[p++] = new Point(-s,    s,   -s+a);        // 13 
    NXPts[p++] = new Point(-s+a,  s,   -s+a);        // 14 
    NXPts[p++] = new Point(-s+a,  s,   -s);          // 15 
    // btm rite fwd flat
    NXPts[p++] = new Point( s,   -s,    s);          // 16 
    NXPts[p++] = new Point( s,   -s,    s-a);        // 17 
    NXPts[p++] = new Point( s-a, -s,    s-a);        // 18 
    NXPts[p++] = new Point( s-a, -s,    s);          // 19 
    // btm rite aft flat
    NXPts[p++] = new Point( s,   -s,   -s);          // 20 
    NXPts[p++] = new Point( s,   -s,   -s+a);        // 21 
    NXPts[p++] = new Point( s-a, -s,   -s+a);        // 22 
    NXPts[p++] = new Point( s-a, -s,   -s);          // 23 
    // btm left fwd flat
    NXPts[p++] = new Point(-s,   -s,    s);          // 24 
    NXPts[p++] = new Point(-s,   -s,    s-a);        // 25 
    NXPts[p++] = new Point(-s+a, -s,    s-a);        // 26 
    NXPts[p++] = new Point(-s+a, -s,    s);          // 27 
    // btm left aft flat
    NXPts[p++] = new Point(-s,   -s,   -s);          // 28
    NXPts[p++] = new Point(-s,   -s,   -s+a);        // 29 
    NXPts[p++] = new Point(-s+a, -s,   -s+a);        // 30 
    NXPts[p++] = new Point(-s+a, -s,   -s);          // 31 
    // fwd rite chopside
    NXPts[p++] = new Point( s,    s-a,    s-m-a);    // 32 
    NXPts[p++] = new Point( s-a,  s-a,    s-m-a);    // 33 
    NXPts[p++] = new Point( s-a,  s-2*a,  s-2*m);    // 34 
    NXPts[p++] = new Point( s,    s-2*a,  s-2*m);    // 35 
    // aft rite chopside
    NXPts[p++] = new Point( s,   -s+a,   -s+m+a);    // 36 
    NXPts[p++] = new Point( s-a, -s+a,   -s+m+a);    // 37 
    NXPts[p++] = new Point( s-a, -s+2*a, -s+2*m);    // 38 
    NXPts[p++] = new Point( s,   -s+2*a, -s+2*m);    // 39
    // fwd left chopside
    NXPts[p++] = new Point(-s,    s-a,    s-m-a);    // 40
    NXPts[p++] = new Point(-s+a,  s-a,    s-m-a);    // 41 
    NXPts[p++] = new Point(-s+a,  s-2*a,  s-2*m);    // 42 
    NXPts[p++] = new Point(-s,    s-2*a,  s-2*m);    // 43 
    // aft left chopside
    NXPts[p++] = new Point(-s,   -s+a,   -s+m+a);    // 44 
    NXPts[p++] = new Point(-s+a, -s+a,   -s+m+a);    // 45 
    NXPts[p++] = new Point(-s+a, -s+2*a, -s+2*m);    // 46 
    NXPts[p++] = new Point(-s,   -s+2*a, -s+2*m);    // 47
    // top fwd N-elbow
    NXPts[p++] = new Point(-s+a,  h-s,  s-nx1);      // 48 
    NXPts[p++] = new Point(-s+a,  h-s,  s-nx1-a);    // 49 
    // top aft N-elbow
    NXPts[p++] = new Point(-s+a,  h-s, -s+nx1);      // 50 
    NXPts[p++] = new Point(-s+a,  h-s, -s+nx1+a);    // 51 
    // btm fwd N-elbow
    NXPts[p++] = new Point( s-a, -h+s,  s-nx1);      // 52 
    NXPts[p++] = new Point( s-a, -h+s,  s-nx1-a);    // 53 
    // btm aft N-elbow
    NXPts[p++] = new Point( s-a, -h+s, -s+nx1);      // 54 
    NXPts[p++] = new Point( s-a, -h+s, -s+nx1+a);    // 55 
    // fwd chopcross
    NXPts[p++] = new Point( a/2,  s-2*a,  s-2*m);    // 56 
    NXPts[p++] = new Point(-a/2,  s-2*a,  s-2*m);    // 57
    NXPts[p++] = new Point(-a/2+m,  s-a,    s-m);    // 58 
    NXPts[p++] = new Point( a/2-m,  s-a,    s-m);    // 59
    // aft chopcross
    NXPts[p++] = new Point( a/2, -s+2*a, -s+2*m);    // 60
    NXPts[p++] = new Point(-a/2, -s+2*a, -s+2*m);    // 61
    NXPts[p++] = new Point(-a/2+m, -s+a,   -s+m);    // 62 
    NXPts[p++] = new Point( a/2-m, -s+a,   -s+m);    // 63
    
    
    NXTri = new Tri[100];
    
    int i = 0;        
    
    // top rite flat
    NXTri[i++] = new Tri(NXPts[ 0], NXPts[ 1], NXPts[ 2]);
  }
}

void DrawNX()
{  
  for (int i = 0; i < 64; i++)
  {
    int j = (i >= 32) ? i + 0 : i;
    if (NXPts[j] != null)
    {
      pushMatrix();
      translate(NXPts[j].x, NXPts[j].y, NXPts[j].z);
      rotateY(-yrot);
            
      fill(color(170, 255, 255, 170));
      text(j, 0.0, 0.0, 0.0);
      popMatrix();
      
      //ONTri[i].Draw();
    }
  }
}



void setup()
{  
  size(1200, 1200, P3D);
  
  textSize(12);
  textAlign(CENTER, CENTER);
  
  SetupXI();
  SetupIO();
  SetupON();
  SetupNX();
}

void draw()
{
  xrot = 0.2 * PI * (float(mouseY)/height - 0.5);
  yrot = -0.5 * PI * float(mouseX)/width;
  
  background(0);
  
  fill(color(170, 255, 255, 85));
  stroke(color(0, 255, 255, 51));
  
  translate(width/2, height/2, 0);
  
  pushMatrix();
    translate(0, 0, -30);
    scale(2);
    rotateY(yrot);
    rotateX(xrot);
    
    //box(20, 50, 100);
    
    //DrawXI();
    //DrawIO();
    //DrawON();
    DrawNX();
    //DrawTest();
  popMatrix();
  
  if (frameCount % 10 == 0)
  {
    //saveFrame("frames/####.png");
  }
}
