int nPts = 30;
class Point
{
  public float x;
  public float y;
  public float p;
  public float m;
  public boolean s;
}
class Tri
{
  public Point points[];
}
Point pts[];
Point ptsSort[];
Tri basicConnections[];

void setup()
{
  size(1280, 720, P3D);
  
  pts = new Point[nPts];
  ptsSort = new Point[nPts];
  basicConnections = new Tri[nPts-2];    // oh silt loam
  pts[1].x = 3;
  for (int i = 0; i < nPts; i++)
  {
    pts[i].x = random(-1, 1);
    pts[i].y = random(-1, 1);
    pts[i].p = atan2(pts[i].y, pts[i].x);
    pts[i].m = sqrt(pts[i].x * pts[i].x + pts[i].y * pts[i].y);
    pts[i].s = false;
  }
  
  for (int i = 0; i < nPts; i++)
  {
    float mm = 0;
    int ind = 0;
    for (int j = i; j < nPts; j++)
    {
      if (!pts[i].s)
      {
        if (pts[i].m > mm)
        {
          ind = i;
          mm = pts[i].m;
        }
      }
    }
    
    ptsSort[i] = pts[ind];
    pts[ind].s = true;
  }
  
  int nTris = 0;
  basicConnections[0].points = new Point[3];
  basicConnections[0].points[0] = ptsSort[nPts-1];
  basicConnections[0].points[1] = ptsSort[nPts-2];
  basicConnections[0].points[2] = ptsSort[nPts-3];
  for (int i = nPts-3; i >= 0; i--)
  {
    // Nearest args to the newest point
    float d1 = 2*PI;
    float d2 = 2*PI;
    int ind1 = 0;
    int ind2 = 0;
    
    
  }
}


void draw()
{
  background(0);
  
  color cf = 0x55AA0055;
  color cs = 0xAAFF55AA;
  color ct = 0x55FF0055;
  fill(cf);  
  stroke(cs);
  
  translate(width/2, height/2, 0);
  
  pushMatrix();
  translate(0.0, 0.0, -300.0);
  rotateY(0.2 * PI * sin(0.01 * PI * frameCount));
  rotateX(0.1 * PI);
  scale(1);
  
  
  box(1600.0, 900.0, 1.0);
  
    fill(ct);
    float tsz = 30 + 10*cos(0.01 * PI * frameCount);
    for (int i = 0; i < nPts; i++)
    {
      translate(0.0, 0.0, 1.0);
      triangle(
        pts[i].x * 800 + 0.5 * tsz, pts[1].y * 450 - sqrt(3)/4*tsz,
        pts[i].x * 800 - 0.5 * tsz, pts[i].y * 450 - sqrt(3)/4*tsz,
        pts[i].x * 800,             pts[i].y * 450 + sqrt(3)/2*tsz
        );
    }
  
  popMatrix();
}
