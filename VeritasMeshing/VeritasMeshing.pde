int nPts = 60;
int nTris = 0;
int nBasicTris = 0;
int maxTrisPerPt = 120;
class Point
{
  public float x;
  public float y;
  public float p;
  public float m;
  public boolean s;
  public Tri a[];
  public int n;
  public int i;
};
class Tri
{
  public Point points[];
  public boolean s;
  public int i;
};
Point pts[];
Point ptsSort[];
Tri basicConnections[];


void AddTriangle(Point[] ptsArray, int ind1, int i, int ind2)
{
  print("Adding triangle ", nTris, " (", ptsArray[ind1].i, ", ", ptsArray[i].i, ", ", ptsArray[ind2].i, ")\n");
  basicConnections[nTris] = new Tri();
  basicConnections[nTris].s = false;
  basicConnections[nTris].i = nTris;
  basicConnections[nTris].points = new Point[3];
  basicConnections[nTris].points[0] = ptsArray[ind1];
  basicConnections[nTris].points[1] = ptsArray[i];
  basicConnections[nTris].points[2] = ptsArray[ind2];
  ptsArray[ind1].a[ptsArray[ind1].n++] = basicConnections[nTris];
  ptsArray[i   ].a[ptsArray[i   ].n++] = basicConnections[nTris];
  ptsArray[ind2].a[ptsArray[ind2].n++] = basicConnections[nTris];
  nTris++;
}

void AddTriangle(Point[] ptsArray)
{
  print("Adding triangle ", nTris, " (", ptsArray[0].i, ", ", ptsArray[1].i, ", ", ptsArray[2].i, ")\n");
  basicConnections[nTris] = new Tri();
  basicConnections[nTris].s = false;
  basicConnections[nTris].i = nTris;
  basicConnections[nTris].points = new Point[3];
  basicConnections[nTris].points[0] = ptsArray[0];
  basicConnections[nTris].points[1] = ptsArray[1];
  basicConnections[nTris].points[2] = ptsArray[2];
  ptsArray[0].a[ptsArray[0].n++] = basicConnections[nTris];
  ptsArray[1].a[ptsArray[1].n++] = basicConnections[nTris];
  ptsArray[2].a[ptsArray[2].n++] = basicConnections[nTris];
  nTris++;
}

int NextCCW(Point[] triPts, int i)
{
  float d1 = triPts[(i+1)%3].p - triPts[i].p;
  float d2 = triPts[(i+2)%3].p - triPts[i].p;
  
  d1 -= 2*PI;  while (d1 < 0) {d1 += 2*PI;}
  d2 -= 2*PI;  while (d2 < 0) {d2 += 2*PI;}
  
  return (d1 < d2) ? (i+1)%3 : (i+2)%3;
}

boolean CCW(Point less, Point more)
{
  float pp = more.p - less.p;
  pp -= 2*PI;  while (pp < 0) {pp += 2*PI;}
  return (pp < PI);
}

int IdenTri(Tri t, Point p)
{
  for (int i = 0; i < 3; i++)
  {
    if (t.points[i] == p)
    {
      return i;
    }
  }
  return -1;
}

void setup()
{
  size(720, 720, P3D);
  
  pts = new Point[nPts];
  ptsSort = new Point[nPts];
  basicConnections = new Tri[2*nPts-1];   // oh silt loam
                                          // (nPts-1 will cover basic triangles but
                                          // idk how many are required for rim. not more tho)
  
  for (int i = 0; i < nPts; i++)
  {
    pts[i] = new Point();
    pts[i].x = random(-1, 1);
    pts[i].y = random(-1, 1);
    pts[i].p = atan2(pts[i].y, pts[i].x);
    pts[i].m = sqrt(pts[i].x * pts[i].x + pts[i].y * pts[i].y);
    pts[i].s = false;
    pts[i].a = new Tri[maxTrisPerPt];
    pts[i].n = 0;
    pts[i].i = i;
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
  
  nTris = 0;
  AddTriangle(ptsSort, nPts-1, nPts-2, nPts-3);
  
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
    
    AddTriangle(ptsSort, ind1, i, ind2);
  }
  nBasicTris = nTris;
  
  Point startPt = ptsSort[0];
  Point edgePts[] = new Point[3];
  Tri lastTri = basicConnections[nTris-2];
  Tri traverse = lastTri;
  lastTri.s = true;
  edgePts[0] = lastTri.points[1];          // Spike
  int pivot  = NextCCW(lastTri.points, 1); // Pivot
  edgePts[1] = lastTri.points[pivot];
  edgePts[2] = lastTri.points[2 - pivot];  // proto-Scout
    
  for (int i = 0; i < nPts; i++)
  {
    // The third edge point (Scout) is discovered by finding an external edge shared with the pivot
    // by sweeping through connected triangles until there is no meeting on the venture side.
    // -  If the third and first edge points are lower in magnitude than the pivot,
    //    move along: pivot becomes spike, scout becomes pivot, and a new scout is chosen.
    // -  If the pivot is outside the line drawn between spike and scout,
    //    move along: pivot becomes spike, scout becomes pivot, and a new scout is chosen.
    //        TODO: field this case better so spikes don't remain spiky lmao
    int j = 0;
    while(j < edgePts[1].n)
    {
      Tri t = edgePts[1].a[j];
      int idScout = IdenTri(t, edgePts[2]);
      print("Test triangle ", t.i, " (", 
        t.points[0].i, ", ",
        t.points[1].i, ", ",
        t.points[2].i,
        "): ", t.s ? "visited" : "lonely!", " w/ scout @ ", idScout, "\n");
      if (!t.s && idScout >= 0)
      {
        print(">>> Pivot\n"); 
        int idPivot = IdenTri(t, edgePts[1]);
        if (idPivot == idScout)
        {
          print("!!! What is this triangle doing !!! (Doubled point)\n");
          break;
        }
        else if (idPivot < 0)
        {
          print("!!! What is this triangle doing !!! (Emancipated pivot)\n");
          break;
        }
        edgePts[2] = t.points[3 - idScout - idPivot];
        traverse = t;
        t.s = true;
        j = 0;
      }
      else
      {
        j++;
      }
    }
    for (j = 0; j < edgePts[1].n; j++)
    {
      edgePts[1].a[j].s = false;
    }
    
    if (edgePts[2] == startPt)
    {
      print("!!! Once around!\n");
      //break;
    }
    if ((edgePts[1].m - edgePts[0].m)/(edgePts[1].p - edgePts[0].p) >
        (edgePts[2].m - edgePts[0].m)/(edgePts[2].p - edgePts[0].p))
    {
      print("### Pivot outside\n");
      edgePts[0] = edgePts[1];
      edgePts[1] = edgePts[2];
      edgePts[2] = traverse.points[3 - IdenTri(traverse, edgePts[0]) - IdenTri(traverse, edgePts[1])];
    }
    else
    {
      AddTriangle(edgePts);
      Point swap = edgePts[1];
      edgePts[1] = edgePts[2];
      edgePts[2] = swap;
    }
    
    if (nTris - nBasicTris > 2)
    {
      //print("Cutting off triangle production early!\n");
      //break;
    }
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
  translate(0.0, 0.0, -300.0);
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
      translate(ptsSort[i].x * 450, ptsSort[i].y * 450);
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
    for (int i = 0; i < nBasicTris + (frameCount/60) % (nTris-nBasicTris); i++)
    {
      /*
      print("Drawing triangle ", basicConnections[i].i, "\n");
      print(">>> (", 
        basicConnections[i].points[0].i, ", ",
        basicConnections[i].points[1].i, ", ",
        basicConnections[i].points[2].i,
        ")\n");
      */
      if (i >= nBasicTris)
      {
        fill(color(255, 255 * float(i)/float(nTris), 0, 170));
      }
      else
      {
        fill(color(0, 255 * float(i)/float(nTris), 255, 85));
      }
      stroke(color(85, 255, 170, 170 * float(nPts-i)/float(nTris)));
      //translate(0.0, 0.0, (225.0 + 225.0*cos(0.003 * PI * frameCount)) / nTris);
      triangle(
        basicConnections[i].points[0].x * 450, basicConnections[i].points[0].y * 450,
        basicConnections[i].points[1].x * 450, basicConnections[i].points[1].y * 450,
        basicConnections[i].points[2].x * 450, basicConnections[i].points[2].y * 450
        );
    }
  popMatrix();
    
  
  popMatrix();
  
  //saveFrame("test-####.png");
}
