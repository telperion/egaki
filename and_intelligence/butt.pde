class D3
{
  float x;
  float y;
  float z;
  
  D3()
  {
    x = y = z = 0;
  }
  
  D3(D3 o)
  {
    x = o.x;
    y = o.y;
    z = o.z;
  }
}

class C4
{
  float r;
  float g;
  float b;
  float a;
  
  C4()
  {
    r = g = b = 0;
    a = 1;
  }
  
  C4(C4 o)
  {
    r = o.r;
    g = o.g;
    b = o.b;
    a = o.a;    
  }
}

float butt_wingRotateMin = -20;    // degrees
float butt_wingRotateMax =  70;    // degrees
float butt_wingPeriod = 6;        // time units
float butt_wingFlaps = 4.5;          // wing flap cycles
float butt_wingTravel = 1.5;       // effect of flapping on apparent speed
float butt_loopDistance = 1000;    // from -LD/2 to +LD/2 in one T
float butt_upward = 0.2;           // z change vs. y

float TweenLoop(float t)
{
  // t -> t
  return sin(2*PI*t/butt_wingPeriod) / (2*PI/butt_wingPeriod);
}

float TweenWingRotate(float t)
{
  float c = acos(2 * -butt_wingRotateMin / (butt_wingRotateMax - butt_wingRotateMin) - 1);
  float osc = cos(1 / (t*t + 1/(2*PI*butt_wingFlaps*0.5 - c)) + c);
  
  return (0.5*osc + 0.5) * (butt_wingRotateMax - butt_wingRotateMin) + butt_wingRotateMin;
}
  
class Butt
{
  D3 pos;                          // seeding value, perhaps
  float shape;                     // body-to-wing proportion
  float size;
  float offsetPath;
  float offsetFlap;
  C4[] col;
  
  Butt()
  {
    pos = new D3();
    col = new C4[3];
    for (int i = 0; i < 3; i++)
    {
      col[i] = new C4();
    }
  }
  
  Butt(Butt b)
  {
    size       = b.size;
    shape      = b.shape;
    pos        = b.pos;
    offsetPath = b.offsetPath;
    offsetFlap = b.offsetFlap;
    col        = new C4[3];
    for (int i = 0; i < 3; i++)
    {
      col[i] = new C4(b.col[i]);
    }
  }
  
  
  void Draw(PGraphics pg, float t)
  {
    float ttl = TweenLoop(t * butt_wingPeriod + offsetFlap);
    float rot = TweenWingRotate(ttl) * PI/180;
    float pth = ((t + 0.5*ttl*ttl*butt_wingTravel/butt_wingPeriod + offsetPath) % 1.0);
    float ppp = (t + offsetPath) % 1.0;
    float alpha = 1 - pow(2*pth-1, 6);
    
    //pg.noStroke();
    //pg.stroke(255, 153 + 102*pos.z/butt_loopDistance, 255 - 153*pth, 170 * alpha);
    //pg.fill(204, 102 + 51*pos.z/butt_loopDistance, 204 - 153*pth, 85 * alpha);
    
    pg.stroke(
      col[0].r + (col[2].r - col[0].r) * pth,
      col[0].g + (col[2].g - col[0].g) * pth,
      col[0].b + (col[2].b - col[0].b) * pth,
      170 * alpha
      );
    pg.fill(
      col[1].r + (col[2].r - col[1].r) * pth,
      col[1].g + (col[2].g - col[1].g) * pth,
      col[1].b + (col[2].b - col[1].b) * pth,
      85 * alpha
      );
    pg.strokeWeight(0.06);
    pg.strokeJoin(BEVEL);
    
    pg.pushMatrix();
      pg.translate(pos.x, pos.y + 2 * butt_loopDistance * (pth-0.5), pos.z + 2 * butt_loopDistance * (pth-0.5) * butt_upward);
      pg.scale(size);
    
      
      for (int w = -1; w <= 1; w += 2)
      {
        pg.pushMatrix();
          pg.rotateY(-rot*w);
          pg.scale(w, 1.0, 1.0);
          
          pg.beginShape();
          pg.vertex(1.778,  1.000);
          pg.vertex(0.593,  0.556 - 0.333*shape);
          pg.vertex(0.148,  0.111 - 0.333*shape);
          pg.vertex(0.148, -0.556);
          pg.vertex(0.593, -1.000);
          pg.vertex(1.185, -0.778);
          pg.endShape(CLOSE);
        pg.popMatrix();
      }
      
      // Head
      pg.beginShape();
      pg.vertex(-0.074,  0.630 - 0.333*shape);
      pg.vertex( 0,      0.778 - 0.333*shape);
      pg.vertex( 0.074,  0.630 - 0.333*shape);
      pg.vertex( 0,      0.481 - 0.333*shape);
      pg.endShape(CLOSE);
      
      // Body
      pg.beginShape();
      pg.vertex(-0.074,  0.407 - 0.333*shape);
      pg.vertex( 0.074,  0.407 - 0.333*shape);
      pg.vertex( 0.074, -0.852);
      pg.vertex(-0.074, -0.852);
      pg.endShape(CLOSE);
    pg.popMatrix();
  }
}
