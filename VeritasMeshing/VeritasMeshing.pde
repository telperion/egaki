int nPts = 100;
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
  t.ns = skipFirst;
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
//  print("Adding triangle ", nTris, " (", ptsArray[ind1].i, ", ", ptsArray[i].i, ", ", ptsArray[ind2].i, ")\n");
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
}

void AddTriangle(Point[] ptsArray)
{
//  print("Adding triangle ", nTris, " (", ptsArray[0].i, ", ", ptsArray[1].i, ", ", ptsArray[2].i, ")\n");
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
}

void AddTriangle(Point newTip, Seg oldSeg)
{
//  print("Adding triangle ", nTris, " (", newTip.i, " ^ ", oldSeg.p[0].i, " _ ", oldSeg.p[1].i, ")\n");
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
}

void AddTriangle(Seg s0, Seg s1)
{
  int i0 = -1 + int(s0.p[0] == s1.p[0]) + int(s0.p[0] == s1.p[1]) + 2*int(s0.p[1] == s1.p[0]) + 2*int(s0.p[1] == s1.p[1]);
  int i1 = -1 + int(s1.p[0] == s0.p[0]) + int(s1.p[0] == s0.p[1]) + 2*int(s1.p[1] == s0.p[0]) + 2*int(s1.p[1] == s0.p[1]);
  if (i0 == -1 || i1 == -1) {return;}
  if (i0 >=  2 || i1 >=  2) {return;}
  
//  print("Adding triangle ", nTris, " (", s0.p[0].i, ", ", s0.p[1].i, ") v (", s1.p[0].i, ", ", s1.p[1].i, ")\n");
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
//    print(segsSort[i].m, "\n");
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
  if (p1 == p2 || p3 == p4)
  {
    return false;
  }
  if (p1 == p3 || p1 == p4 || p2 == p3 || p2 == p4)
  {
    return false;
  }
  
  float parametricIntersectionWithSegment = 
    ((p3.y - p1.y)*(p2.x - p1.x) - (p3.x - p1.x)*(p2.y - p1.y)) /
    ((p4.x - p3.x)*(p2.y - p1.y) - (p4.y - p3.y)*(p2.x - p1.x));
    
  //print("(", p1.i, ", ", p2.i, ") crossing (", p3.i, ", ", p4.i, ")? parint = ", parametricIntersectionWithSegment, "\n");
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

int FillBorderOnce()
{
  int startTris = nTris;
  
  // Draw extra border triangles.  
  Point borderPts[] = new Point[nPts+1];
  int nBP = 0;
  borderPts[0] = ptsSort[0];
  Seg lastSeg = borderPts[0].s[0];
  Seg nextSeg = borderPts[0].s[1];
  
  for (nBP = 1; nBP <= nPts; nBP++)
  {    
    // Which other segment joined to this point has only one triangle?
    int nextTraveler = -1;
    for (int j = 0; j < borderPts[nBP-1].ns; j++)
    {
      nextSeg = borderPts[nBP-1].s[j];
//      print("--- Segment ", nextSeg.i, " (", nextSeg.p[0].i, " -> ", nextSeg.p[1].i, ") w/ ", nextSeg.nt, " tris\n");
      Point nextPt;
      if (nextSeg.p[0] == borderPts[nBP-1])
      {
        nextPt = nextSeg.p[1];
      }
      else
      {
        nextPt = nextSeg.p[0];
      }
      
      if (nBP > 1 && nextPt == borderPts[nBP-2])
      {
//        print("+++ No backtracking!\n");
      }
      else if (nextSeg.nt < 2)
      {
//        print("vvv Move on Segment ", nextSeg.i, "\n");        
//        print("--- Move from point ", borderPts[nBP-1].i, " to ", nextPt.i, " along Segment ", nextSeg.i, "\n");
        nextTraveler = j;
        borderPts[nBP] = nextPt;
        break;
      }
    }
    
    if (borderPts[nBP] == borderPts[0])
    {
//      print("### Returned to start! (border)\n");
      break;
    }
    
    if (nextTraveler == -1)
    {
      print("### dude idek what hape (border)\n");
      break;
    }
  }
  
  int trail = nBP-2;
  int pivot = nBP-1;
  int scout = 0;
  while (scout < nBP)
  {    
    if (borderPts[pivot].nt == 1)
    {
//      print("+++ Point ", borderPts[pivot].i, " is already the apex of a single triangle; must turn the corner\n"); 
      // Proceed and leave the farthest border point behind.
      trail = pivot;
      pivot = scout;
      scout++;
      continue;
    }
    
    // Does anything else on the border cross us?
    boolean cutsThrough = false; 
    for (int i = 0; i < nSegs; i++)
    {     
      if (Intersects(borderPts[trail], borderPts[scout],
                         segs[i].p[0], segs[i].p[1]) &&
          Intersects(    segs[i].p[0], segs[i].p[1],
                     borderPts[trail], borderPts[scout]))
      {
//        print("+++ Points ", borderPts[trail].i, " and ", borderPts[scout].i, " cut by (", segs[i].p[0].i, " -> ", segs[i].p[1].i, ")\n"); 
        cutsThrough = true;
        break;
      }
    }

    
    if (cutsThrough)
    {
      // Proceed and leave the farthest border point behind.
      trail = pivot;
      pivot = scout;
      scout++;
    }
    else
    {
      // Make a new triangle with the two segments.      
      for (int j = 0; j < borderPts[pivot].ns; j++)
      {
        if (borderPts[pivot].s[j].p[0] == borderPts[trail] ||
            borderPts[pivot].s[j].p[1] == borderPts[trail])
        {
          lastSeg = borderPts[pivot].s[j];
        }
        else if (borderPts[pivot].s[j].p[0] == borderPts[scout] ||
                 borderPts[pivot].s[j].p[1] == borderPts[scout])
        {
          nextSeg = borderPts[pivot].s[j];
        }
      }
//      print(">>> Points ", borderPts[trail].i, " and ", borderPts[scout].i, " can be joined, completing triangle from segments ", lastSeg.i, " and ", nextSeg.i, "\n");
      
      try   {AddTriangle(lastSeg, nextSeg); nTris++;}
      catch (Exception e) {basicConnections[nTris] = null;}      
      
      // The point contained by both segments is no longer part of the border.
      pivot = scout;
      scout++;
    }
  }
  
  return nTris - startTris;
}



void setup()
{
  size(720, 720, P3D);
  
  pts = new Point[nPts];
  ptsSort = new Point[nPts];
  basicConnections = new Tri[3*nPts-1];   // oh silt loam
  segs = new Seg[6*nPts+3];               // oh CLAY loam
  segsSort = new Seg[6*nPts+3];
  
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
  try   {AddTriangle(ptsSort, nPts-1, nPts-2, nPts-3); nTris++;}
  catch (Exception e) {basicConnections[nTris] = null;}      
  
  // "Broken glass" meshification.  
  for (int i = nPts-4; i >= 0; i--)
  {
    Seg segNear = SelectNearestSeg(ptsSort[i]);
    if (segNear != null)
    {
      float dist = P2SDistance(ptsSort[i], segNear);
//      print(">>> Point ", ptsSort[i].i, " matched with Segment ", segNear.i, " (dist ", dist, ")\n");

      try   {AddTriangle(ptsSort[i], segNear); nTris++;}
      catch (Exception e) {basicConnections[nTris] = null;}
    }
    else
    {
      print("### dude idek what hape (glassy)\n");
      break;
    }
  }
  nBasicTris = nTris;
  
  // Border up.
  for (int i = 0; i < sqrt(nPts); i++)
  {
    print("XXX Filling border (iteration ",i,")\n");
    int trisAdded = FillBorderOnce();
    if (3*trisAdded < sqrt(nPts))
    {
      break;
    }
  }
}


void draw()
{
  float propShattering = 2.0;
  float tween = max(frameCount % (propShattering*nTris) - nTris, 0) / ((propShattering-1)*nTris);
  float tEaseOut = pow(tween,0.25);
  float tEaseIn  = pow(tween,5);
  
  background(0);
  blendMode(ADD);
  
  color cf = 0x2200FF55;
  color cs = 0xAA55FFAA;
  fill(cf); 
  noStroke();
  
  translate(width/2, height/2, 0);
  
  pushMatrix();
  translate(0.0, 0.0, -450.0);
  rotateY(0.2 * PI * sin(0.7 * PI * tEaseOut));
  rotateX(0.1 * PI * tEaseOut);
  scale(1 + 0.5 * tEaseOut);
  
  textSize(24);
  textAlign(CENTER, CENTER);
  
  
  //box(750.0 * 1.2, 450.0 * 1.2, 1.0);
  //box(450.0 * 1.2, 750.0 * 1.2, 0.9);
  
  stroke(color(170, 85, 255, 170 * (1.0-tEaseOut)));
  pushMatrix();
    translate(0.0, 0.0, 1.0 - 300 * tEaseOut);
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
      fill(color(255, 255 * float(i)/float(nPts), 255, 255 * (1.0-tEaseOut)));
      text(ptsSort[i].i, 0.0, -2*tsz, 0.1);
      popMatrix();
    }
  popMatrix();
    
  pushMatrix();
    translate(0.0, 0.0, 3.0 - 300 * tEaseOut);
    for (int i = 0; i < min(frameCount % (propShattering*nTris), nTris); i++)
    {
      /*
      print("Drawing triangle ", basicConnections[i].i, "\n");
      print(">>> (", 
        basicConnections[i].points[0].i, ", ",
        basicConnections[i].points[1].i, ", ",
        basicConnections[i].points[2].i,
        ")\n");
      */
      float tIndex = 1000 * ((i*tEaseIn) % 0.001); 
      float tAlpha = 20 * (1.0 - tEaseIn) -
                     15 * tIndex +
                     0.2 * sin(0.0002 * PI * frameCount);
      tAlpha = (tAlpha > 1.0) ? 1.0 : (tAlpha < 0.0) ? 0.0 : tAlpha;
      
  
      float prop = float(nTris-i)/nTris;
      
      if (i >= nBasicTris)
      {
        fill(color(0, 255 * prop, 255, 85*tAlpha));
      }
      else
      {
        fill(color(0, 255 * prop, 255, 85*tAlpha));
      }
      stroke(color(255, 255 * prop, 255, 170*prop*tAlpha));
      pushMatrix();
        translate(0.0, 0.0, 1200 * (1000 * (prop % 0.001)) * pow(prop, 0.3) * tEaseOut );
        triangle(
          basicConnections[i].p[0].x * 450, basicConnections[i].p[0].y * 450,
          basicConnections[i].p[1].x * 450, basicConnections[i].p[1].y * 450,
          basicConnections[i].p[2].x * 450, basicConnections[i].p[2].y * 450
          );
      popMatrix();
    }
  popMatrix();
    
  
  popMatrix();
  
  if (frameCount < propShattering*nTris)
  {
    saveFrame("frames/test-####.png");
  }
}
