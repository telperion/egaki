int nPts = 300;
int nTris = 0;
class Point
{
  public float x;
  public float y;
  public float p;
  public float m;
  public boolean s;
};
class Tri
{
  public Point points[];
};
Point pts[];
Point ptsSort[];
Tri basicConnections[];

void setup()
{
  size(1280, 1280, P3D);
  
  pts = new Point[nPts];
  ptsSort = new Point[nPts];
  basicConnections = new Tri[nPts-1];    // oh silt loam
  
  for (int i = 0; i < nPts; i++)
  {
    pts[i] = new Point();
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
    for (int j = 0; j < nPts; j++)
    {
      if (!pts[j].s)
      {
        if (pts[j].m > mm)
        {
          ind = j;
          mm = pts[j].m;
        }
      }
    }
    
    ptsSort[i] = pts[ind];
    pts[ind].s = true;
    //print(ptsSort[i].m, "\n");
  }
  
  nTris = 1;
  basicConnections[0] = new Tri();
  basicConnections[0].points = new Point[3];
  basicConnections[0].points[0] = ptsSort[nPts-1];
  basicConnections[0].points[1] = ptsSort[nPts-2];
  basicConnections[0].points[2] = ptsSort[nPts-3];
  for (int i = nPts-4; i >= 0; i--)
  {
    // Nearest args to the newest point
    float d1 = -2*PI;
    float d2 =  2*PI;
    float d1alt = -2*PI;
    float d2alt =  2*PI;
    int ind1 = -1;
    int ind2 = -1;
    int ind1alt = -1;
    int ind2alt = -1;
    
    for (int j = i+1; j < nPts; j++)
    {
      float diffArg = ptsSort[i].p - ptsSort[j].p;
      diffArg = (diffArg >  PI) ? diffArg - 2*PI : diffArg;
      diffArg = (diffArg < -PI) ? diffArg + 2*PI : diffArg;
      if (diffArg < 0)
      {
        if (diffArg > d1)
        {
          d1 = diffArg;
          ind1 = j;          
        }
        else if (diffArg < d2alt)
        {
          d2alt = diffArg;
          ind2alt = j;
        }
      }
      else if (diffArg > 0)
      {
        if (diffArg < d2)
        {
          d2 = diffArg;
          ind2 = j;
        }
        else if (diffArg > d1alt)
        {
          d1alt = diffArg;
          ind1alt = j;
        }
      }
      // print(diffArg, ":\t", d1, "\t", d2, "\tvs.\t", d1alt, "\t", d2alt, "\n");
    }
    
    ind1 = (ind1 >= 0) ? ind1 : ind1alt;
    ind2 = (ind2 >= 0) ? ind2 : ind2alt;
    
    ind1 = (ind1 >= 0) ? ind1 : i;
    ind2 = (ind2 >= 0) ? ind2 : i;
    
    basicConnections[nTris] = new Tri();
    basicConnections[nTris].points = new Point[3];
    basicConnections[nTris].points[0] = ptsSort[ind1];
    basicConnections[nTris].points[1] = ptsSort[i];
    basicConnections[nTris].points[2] = ptsSort[ind2];
    nTris++;
  }
}


void draw()
{
  background(0);
  
  color cf = 0x2200FF55;
  color cs = 0xAA55FFAA;
  fill(cf); 
  noStroke();
  
  translate(width/2, height/2, 0);
  
  pushMatrix();
  translate(0.0, 0.0, 0.0);
  rotateY(0.2 * PI * sin(0.001 * PI * frameCount));
  rotateX(0.1 * PI);
  scale(1);
  
  
  box(750.0 * 1.2, 450.0 * 1.2, 1.0);
  box(450.0 * 1.2, 750.0 * 1.2, 0.9);
  
  stroke(cs);
  pushMatrix();
    translate(0.0, 0.0, 1.0);
    float tsz = 12 + 3*cos(0.01 * PI * frameCount);
    for (int i = 0; i < nPts; i++)
    {
      fill(color(0, 255 * float(i)/float(nPts), 255, 85));
      pushMatrix();
      translate(ptsSort[i].x * 600, ptsSort[i].y * 600);
      rotateZ(ptsSort[i].p + PI*0.5);
      triangle(
         0.5 * tsz, -sqrt(3)/6*tsz,
        -0.5 * tsz, -sqrt(3)/6*tsz,
         0.0,        sqrt(3)/3*tsz
        );
      popMatrix();
    }
  popMatrix();
    
  pushMatrix();
    translate(0.0, 0.0, 3.0);
    for (int i = 0; i < nTris; i++)
    {
      fill(  color(0, 255 * float(i)/float(nPts), 255, 85));
      stroke(color(85, 255, 170, 170 * float(nPts-i)/float(nPts)));
      translate(0.0, 0.0, (300.0 + 300.0*cos(0.003 * PI * frameCount)) / nTris);
      triangle(
        basicConnections[i].points[0].x * 600, basicConnections[i].points[0].y * 600,
        basicConnections[i].points[1].x * 600, basicConnections[i].points[1].y * 600,
        basicConnections[i].points[2].x * 600, basicConnections[i].points[2].y * 600
        );
    }
  popMatrix();
    
  
  popMatrix();
}
