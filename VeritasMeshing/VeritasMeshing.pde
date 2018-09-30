int nPts = 30;
int nSegs = 0;
int nTris = 0;
int nBasicTris = 0;
int maxTrisPerPt = 120;
int maxSegsPerPt = 60;
class Point
{
  public float x;
  public float y;
  public float m;
  public boolean v;
  public Tri t[];
  public Seg s[];
  public int nt;
  public int ns;
  public int i;
};
class Seg
{
  public Point p[];
  public Tri t[];
  public int np;
  public int nt;
  public float m;
  public boolean v;
  public int i;
};
class Tri
{
  public Point p[];
  public Seg s[];
  public int np;
  public int ns;
  public boolean v;
  public int i;
};
Point pts[];
Point ptsSort[];
Seg segs[];
Seg segsSort[];
Tri basicConnections[];
Point falseCenter;


float P2PDistance(Point p1, Point p2)
{
  return sqrt((p2.x-p1.x)*(p2.x-p1.x) + (p2.y-p1.y)*(p2.y-p1.y));
}

float P2SDistance(Point p, Seg s)
{
  float xmid = (s.p[0].x + s.p[1].x) * 0.5;
  float ymid = (s.p[0].y + s.p[1].y) * 0.5;
  
  float xofs = p.x - xmid;
  float yofs = p.y - ymid;
  
  return sqrt(xofs*xofs + yofs*yofs);
}

void AddSegsFromTri(Tri t, int skipFirst)
{
  for (int k = 0 + skipFirst; k < 3; k++)
  {
    segs[nSegs] = new Seg();
    segs[nSegs].v = false;
    segs[nSegs].i = nSegs;
    
    Point p0 = t.p[ k   %3];
    Point p1 = t.p[(k+1)%3];
    segs[nSegs].p = new Point[2];
    segs[nSegs].p[0] = p0;
    segs[nSegs].p[1] = p1;
    p0.s[p0.ns++] = segs[nSegs];
    p1.s[p1.ns++] = segs[nSegs];    
    
    segs[nSegs].t = new Tri[2];
    segs[nSegs].t[segs[nSegs].nt++] = t;
    t.s[t.ns++] = segs[nSegs];
    
    nSegs++;
  }  
}


void AddTriangle(Point[] ptsArray, int ind1, int i, int ind2)
{
  print("Adding triangle ", nTris, " (", ptsArray[ind1].i, ", ", ptsArray[i].i, ", ", ptsArray[ind2].i, ")\n");
  basicConnections[nTris] = new Tri();
  basicConnections[nTris].v = false;
  basicConnections[nTris].i = nTris;
  
  basicConnections[nTris].p = new Point[3];
  basicConnections[nTris].p[0] = ptsArray[ind1];
  basicConnections[nTris].p[1] = ptsArray[i];
  basicConnections[nTris].p[2] = ptsArray[ind2];
  ptsArray[ind1].t[ptsArray[ind1].nt++] = basicConnections[nTris];
  ptsArray[i   ].t[ptsArray[i   ].nt++] = basicConnections[nTris];
  ptsArray[ind2].t[ptsArray[ind2].nt++] = basicConnections[nTris];
  
  basicConnections[nTris].s = new Seg[3];
  AddSegsFromTri(basicConnections[nTris], 0);
  
  nTris++;
}

void AddTriangle(Point[] ptsArray)
{
  print("Adding triangle ", nTris, " (", ptsArray[0].i, ", ", ptsArray[1].i, ", ", ptsArray[2].i, ")\n");
  basicConnections[nTris] = new Tri();
  basicConnections[nTris].v = false;
  basicConnections[nTris].i = nTris;
  
  basicConnections[nTris].p = new Point[3];
  basicConnections[nTris].p[0] = ptsArray[0];
  basicConnections[nTris].p[1] = ptsArray[1];
  basicConnections[nTris].p[2] = ptsArray[2];
  ptsArray[0].t[ptsArray[0].nt++] = basicConnections[nTris];
  ptsArray[1].t[ptsArray[1].nt++] = basicConnections[nTris];
  ptsArray[2].t[ptsArray[2].nt++] = basicConnections[nTris];  
  
  basicConnections[nTris].s = new Seg[3];
  AddSegsFromTri(basicConnections[nTris], 0);
  
  nTris++;
}

void AddTriangle(Point newTip, Seg oldSeg)
{
  print("Adding triangle ", nTris, " (", newTip.i, " ^ ", oldSeg.p[0].i, " _ ", oldSeg.p[1].i, ")\n");
  basicConnections[nTris] = new Tri();
  basicConnections[nTris].v = false;
  basicConnections[nTris].i = nTris;
  
  basicConnections[nTris].p = new Point[3];
  basicConnections[nTris].p[0] = oldSeg.p[0];
  basicConnections[nTris].p[1] = oldSeg.p[1];
  basicConnections[nTris].p[2] = newTip;
  oldSeg.p[0].t[oldSeg.p[0].nt++] = basicConnections[nTris];
  oldSeg.p[1].t[oldSeg.p[1].nt++] = basicConnections[nTris];
       newTip.t[     newTip.nt++] = basicConnections[nTris];    
  
  basicConnections[nTris].s = new Seg[3];
  basicConnections[nTris].s[0] = oldSeg;
  oldSeg.t[oldSeg.nt++] = basicConnections[nTris];
  AddSegsFromTri(basicConnections[nTris], 1);
  
  nTris++;
}

void AddTriangle(Seg s0, Seg s1)
{
  int i0 = -1 + int(s0.p[0] == s1.p[0]) + int(s0.p[0] == s1.p[1]) + 2*int(s0.p[1] == s1.p[0]) + 2*int(s0.p[1] == s1.p[1]);
  int i1 = -1 + int(s1.p[0] == s0.p[0]) + int(s1.p[0] == s0.p[1]) + 2*int(s1.p[1] == s0.p[0]) + 2*int(s1.p[1] == s0.p[1]);
  if (i0 == -1 || i1 == -1) {return;}
  if (i0 >=  2 || i1 >=  2) {return;}
  
  print("Adding triangle ", nTris, " (", s0.p[0].i, ", ", s0.p[1].i, ") v (", s1.p[0].i, ", ", s1.p[1].i, ")\n");
  basicConnections[nTris] = new Tri();
  basicConnections[nTris].v = false;
  basicConnections[nTris].i = nTris;
  
  basicConnections[nTris].p = new Point[3];
  basicConnections[nTris].p[0] = s0.p[1-i0];
  basicConnections[nTris].p[1] = s0.p[  i0];  // == s1.p[i1]
  basicConnections[nTris].p[2] = s1.p[1-i1];
  s0.p[1-i0].t[s0.p[1-i0].nt++] = basicConnections[nTris];
  s0.p[  i0].t[s0.p[  i0].nt++] = basicConnections[nTris];
  s1.p[1-i1].t[s1.p[1-i1].nt++] = basicConnections[nTris];    
  
  basicConnections[nTris].s = new Seg[3];
  basicConnections[nTris].s[0] = s0;
  basicConnections[nTris].s[1] = s1;
  s0.t[s0.nt++] = basicConnections[nTris];
  s1.t[s1.nt++] = basicConnections[nTris];
  AddSegsFromTri(basicConnections[nTris], 2);
  
  nTris++;
}


int IdenTri(Tri t, Point p)
{
  for (int i = 0; i < 3; i++)
  {
    if (t.p[i] == p)
    {
      return i;
    }
  }
  return -1;
}

void SortPts()
{ 
  for (int i = 0; i < nPts; i++)
  {
    float mm = 0;
    int ind = 0;
    for (int j = 0; j < nPts; j++)
    {
      if (!pts[j].v)
      {
        if (pts[j].m > mm)
        {
          ind = j;
          mm = pts[j].m;
        }
      }
    }
    
    ptsSort[i] = pts[ind];
    pts[ind].v = true;
    //print(ptsSort[i].m, "\n");
  }
}

void SortSegs(Point p)
{ 
  for (int i = 0; i < nSegs; i++)
  {
    float mm = 0;
    int ind = 0;
    for (int j = 0; j < nSegs; j++)
    {
      if (!segs[j].v)
      {
        segs[j].m = P2SDistance(p, segs[j]);
        if (segs[j].m > mm)
        {
          ind = j;
          mm = segs[j].m;
        }
      }
    }
    
    segs[ind].v = true;
    segsSort[i] = segs[ind];
    print(segsSort[i].m, "\n");
  }
  for (int i = 0; i < nSegs; i++)
  {
    segs[i].v = false;
  }
}


// Does the line (p1, p2) cross the segment (p3, p4)?
// Has to be done twice reflexively to check two segments.
boolean Intersects(Point p1, Point p2, Point p3, Point p4)
{  
  float parametricIntersectionWithSegment = 
    ((p3.y - p1.y)*(p2.x - p1.x) - (p3.x - p1.x)*(p2.y - p1.y)) /
    ((p4.x - p3.x)*(p2.y - p1.y) - (p4.y - p3.y)*(p2.x - p1.x));
    
  print("(", p1.i, ", ", p2.i, ") crossing (", p3.i, ", ", p4.i, ")? parint = ", parametricIntersectionWithSegment, "\n");
  return (parametricIntersectionWithSegment > 0.0 &&
          parametricIntersectionWithSegment < 1.0);      
}

Seg SelectNearestSeg(Point p)
{ 
  // Just compare to the midpoint of the segment
  // No compare to both endpoints to make sure it doesn't cross
  // I don't know!!
  //
  if (nSegs <= 0)
  {
    return null;
  }
  
  SortSegs(p);
  
  int ind = -1;
  for (int i = nSegs-1; i >= 0; i--)
  {
    // The nearest segment that doesn't cut through any other segments
    // is the one we definitely want to use >_>
    boolean cutsThrough = false;
    // Ugh!
    for (int j = nSegs-1; j >= 0; j--)
    {
      // Skip dupes
      if (j == i)
      {
        continue;          
      }
      
      
      if (segsSort[i].p[0] != segsSort[j].p[0] && 
          segsSort[i].p[0] != segsSort[j].p[1])
      {
        if (Intersects(               p, segsSort[i].p[0],
                       segsSort[j].p[0], segsSort[j].p[1]) &&
            Intersects(segsSort[j].p[0], segsSort[j].p[1],
                                      p, segsSort[i].p[0]))
        {
          cutsThrough = true;
          break;
        }
      }
      
      if (segsSort[i].p[1] != segsSort[j].p[0] && 
          segsSort[i].p[1] != segsSort[j].p[1])
      {
        if (Intersects(               p, segsSort[i].p[1],
                       segsSort[j].p[0], segsSort[j].p[1]) &&
            Intersects(segsSort[j].p[0], segsSort[j].p[1],
                                      p, segsSort[i].p[1]))
        {
          cutsThrough = true;
          break;
        }
      }
    }
    if (!cutsThrough)
    {
      ind = i;
      break;
    }
  }
  
  return segsSort[ind];
}

void setup()
{
  size(720, 720, P3D);
  
  pts = new Point[nPts];
  ptsSort = new Point[nPts];
  basicConnections = new Tri[2*nPts-1];   // oh silt loam
                                          // (nPts-1 will cover basic triangles but
                                          // idk how many are required for rim. not more tho)
  segs = new Seg[2*nPts+3];               // oh silt loam
  segsSort = new Seg[2*nPts+3];
  
  for (int i = 0; i < nPts; i++)
  {
    pts[i] = new Point();
    pts[i].x = random(-1, 1);
    pts[i].y = random(-1, 1);
    pts[i].m = sqrt(pts[i].x * pts[i].x + pts[i].y * pts[i].y);
    pts[i].v = false;
    
    pts[i].t = new Tri[maxTrisPerPt];
    pts[i].nt = 0;
    pts[i].s = new Seg[maxSegsPerPt];
    pts[i].ns = 0;
    
    pts[i].i = i;
  }
  
  SortPts();
  
  nTris = 0;
  
  // Draw the first triangle.
  AddTriangle(ptsSort, nPts-1, nPts-2, nPts-3);
  
  // "Broken glass" meshification.  
  for (int i = nPts-4; i >= 0; i--)
  {
    Seg segNear = SelectNearestSeg(ptsSort[i]);
    if (segNear != null)
    {
      float dist = P2SDistance(ptsSort[i], segNear);
      print(">>> Point ", ptsSort[i].i, " matched with Segment ", segNear.i, " (dist ", dist, ")\n");
      AddTriangle(ptsSort[i], segNear);
    }
    else
    {
      print("### dude idek what hape (glassy)\n");
      break;
    }
  }
  nBasicTris = nTris;
  
  // Draw extra border triangles.  
  // First, identify all border points.
  Point borderPts[] = new Point[nPts];
  int nBP = 0;
  borderPts[0] = ptsSort[0];
  
  for (int i = 1; i < nPts; i++)
  {    
    // Which other segment joined to this point has only one triangle?
    int nextTraveler = -1;
    for (int j = 0; j < borderPts[i-1].ns; j++)
    {
      Seg potentialSeg = borderPts[i-1].s[j];
      print("--- Segment ", potentialSeg.i, " (", potentialSeg.p[0].i, " -> ", potentialSeg.p[1].i, ") w/ ", potentialSeg.nt, " tris\n");
      Point nextPt;
      if (potentialSeg.p[0] == borderPts[i-1])
      {
        nextPt = potentialSeg.p[1];
      }
      else
      {
        nextPt = potentialSeg.p[0];
      }
      
      if (i > 1 && nextPt == borderPts[i-2])
      {
        print("+++ No backtracking!\n");
      }
      else if (potentialSeg.nt < 2)
      {
        print("vvv Move on Segment ", potentialSeg.i, "\n");        
        print("--- Move from point ", borderPts[i-1].i, " to ", nextPt.i, " along Segment ", potentialSeg.i, "\n");
        nextTraveler = j;
        borderPts[i] = nextPt;
        break;
      }
    }
    nBP = i+1;
    
    if (borderPts[i] == borderPts[0])
    {
      print("### Returned to start! (border)\n");
      break;
    }
    
    if (nextTraveler == -1)
    {
      print("### dude idek what hape (border)\n");
      break;
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
  //rotateY(0.2 * PI * sin(0.001 * PI * frameCount));
  //rotateX(0.1 * PI);
  scale(1);
  
  textSize(18);
  textAlign(CENTER, CENTER);
  
  
  //box(750.0 * 1.2, 450.0 * 1.2, 1.0);
  //box(450.0 * 1.2, 750.0 * 1.2, 0.9);
  
  stroke(cs);
  pushMatrix();
    translate(0.0, 0.0, 1.0);
    float tsz = 12 + 3*cos(0.01 * PI * frameCount);
    for (int i = 0; i < nPts; i++)
    {
      fill(color(0, 255 * float(i)/float(nPts), 255, 85));
      pushMatrix();
      translate(ptsSort[i].x * 450, ptsSort[i].y * 450);
      pushMatrix();
      rotateZ(atan2(ptsSort[i].y, ptsSort[i].x) + PI*0.5);
      triangle(
         0.5 * tsz, -sqrt(3)/6*tsz,
        -0.5 * tsz, -sqrt(3)/6*tsz,
         0.0,        sqrt(3)/3*tsz
        );
      popMatrix();
      fill(color(255, 255 * float(i)/float(nPts), 255, 255));
      text(ptsSort[i].i, 0.0, -2*tsz, 0.1);
      popMatrix();
    }
  popMatrix();
    
  pushMatrix();
    translate(0.0, 0.0, 3.0);
    for (int i = 0; i < nBasicTris /*+ (frameCount/60) % (nTris-nBasicTris)*/; i++)
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
        basicConnections[i].p[0].x * 450, basicConnections[i].p[0].y * 450,
        basicConnections[i].p[1].x * 450, basicConnections[i].p[1].y * 450,
        basicConnections[i].p[2].x * 450, basicConnections[i].p[2].y * 450
        );
    }
  popMatrix();
    
  
  popMatrix();
  
  if (frameCount == 0)
  {
    saveFrame("test-####.png");
  }
}
