class TP {  
  public int from;      // Which node from?
  public float ph;      // Angle of latitude from last (as measured from tree rooted vector)
  public float th;      // Angle of longitude from last (as measured from tree rooted vector)
  public float ll;      // Distance from last
  public boolean leaf;  // am I a leaf??
  
  TP(int inFrom, float inPh, float inTh, float inLL)
  {
    from = inFrom;
    ph = inPh;
    th = inTh;
    ll = inLL;
    leaf = true;
  }
  
  TP FullCoord(TP[] a)
  {
    if (from < 0)
    {
      return new TP(-1, 0, 0, 0);
    }
    else
    {
      TP ref = a[from].FullCoord(a);
      float rcp = cos(ref.ph);
      float rsp = sin(ref.ph);
      float rct = cos(ref.th);
      float rst = sin(ref.th);
      float bcp = cos(ref.ph + ph);
      float bsp = sin(ref.ph + ph);
      float bct = cos(ref.th + th);
      float bst = sin(ref.th + th);
      float rll = ref.ll;
      float bll = ll;
      
      // Recall that phi is measured from apex downward to horizon.
      float x = rll*rsp*rct + bll*bsp*bct;
      float y = rll*rcp     + bll*bcp;
      float z = rll*rsp*rst + bll*bsp*bst;
      
      ref.th = atan2(z, x);
      ref.ph = atan2(sqrt(x*x + z*z), y);
      ref.ll = sqrt(x*x + y*y + z*z);
      return ref;      
    }
  }
  
  void ToCartesian(float[] c)
  {
    c[0] = ll*sin(ph)*cos(th);
    c[1] = ll*cos(ph);
    c[2] = ll*sin(ph)*sin(th);
  }
  
  float FullDist(TP[] a)
  {
    if (from < 0)
    {
      return 0;
    }
    else
    {
      return FullCoord(a).ll;
    }
  }
}

int nice[];
int colorizer[];

TP bitch[];
int lastBitch = 0;
int maxBitch = 300;
int maxGen = 6;


// The replicator and its control functions.
float fullScale = 300.0;
float leafSize = fullScale*0.05;
float trunkThk = fullScale*0.01;

int pdfBud(float zo, float gp)
{
  //return 5;
  zo *= gp;
  
       if (zo < 0.01) return 1;
  else if (zo < 0.30) return 3;
  else if (zo < 0.70) return 5;
  else                return 0;
}
float pdfThe(float zo, int buds, int budIndex)
{
  return (zo + budIndex) * 2 * PI / float(buds);
}
float pdfPhi(float zo)
{
  return PI/18 + (zo*zo) * PI/6;
  //return PI/6;
}
float pdfLen(float zo, float fullDist)
{
  return 0.3 * (0.5 + 3.0*zo*zo - 2.0*zo*zo*zo) * (fullScale - fullDist);
  //return 0.5 * (fullScale - fullDist);
}

void Growth(int gen)
{
  int x = lastBitch;
  for (int i = 0; i < x; i++)
  {
    float parBud = random(1);
    float parThe = random(1);
    float parPhi = random(1);
    float parLen = random(1);
    
    if (bitch[i].leaf)
    {
      int buds = pdfBud(parBud, float(gen+1)/float(maxGen));
      for (int j = 0; j < buds; j++)
      {        
         bitch[lastBitch++] = new TP(
           i,
           pdfPhi(parPhi),
           pdfThe(parThe, buds, j),
           pdfLen(parLen, bitch[i].FullDist(bitch))
           );
         System.out.println(String.format("%4d: origin = %4d, bud = %1d, phi = %.3f deg, theta = %.3f deg, len = %.3f, total len = %.3f", 
           lastBitch-1,
           i,
           j,
           bitch[lastBitch-1].ph * 180/PI,
           bitch[lastBitch-1].th * 180/PI,
           bitch[lastBitch-1].ll,
           bitch[lastBitch-1].FullDist(bitch)
           ));
           
         
         if (lastBitch >= maxBitch)
         {
           System.out.println(String.format("%4d: early stop!", i));
           break;
         }
      }
      if (buds > 0)
      {
        bitch[i].leaf = false;
        System.out.println(String.format("%4d: no longer a leaf", i));
      }
    }
    
    if (lastBitch >= maxBitch)
    {
      System.out.println(String.format("%4d: early stop!", i));
      break;
    }
  }
}

void setup()
{
  // Nice.
  nice = new int[3];
  nice[0] =  69;
  nice[1] = 169;
  nice[2] = 269;
  colorizer = new int[3];
  
  
  bitch = new TP[maxBitch];
  
  // Initialization of tree.
  bitch[0] = new TP(-1, 0, 0, 0);
  lastBitch = 1;
  for (int i = 0; i < maxGen; i++)
  {
    System.out.println(String.format("Growth Period %2d: Begin", i));
    Growth(i);
    System.out.println(String.format("Growth Period %2d: End", i));
  }
  
  size(854, 480, P3D);
}


void DrawBitch()
{  
  {
    fill(
      255,
      255,
      255,
      255
      ); 
    
    pushMatrix();
    translate(0, 0-fullScale*0.5, 0);
    //rotateY(bHere.th);
    //rotateX(bHere.ph);
    box(trunkThk, trunkThk, trunkThk);
    popMatrix();
  }
        
      
  for(int i = 1; i < min(maxBitch, lastBitch); i++)
  {
    for (int j = 0; j < 3; j++)
    {
      colorizer[j] = (colorizer[j] * nice[j]) % 256;
    }
    //System.out.println(String.format("c: %3d, %3d, %3d", colorizer[0], colorizer[1], colorizer[2]));
    
    TP bHere = bitch[      i      ].FullCoord(bitch);
    TP bFrom = bitch[bitch[i].from].FullCoord(bitch);
    bHere.ToCartesian(ccHere);
    bFrom.ToCartesian(ccFrom);
    if (frameCount == 1)
    {
      System.out.println(String.format("%4d here coords: %.3f, %.3f, %.3f", i, ccHere[0], ccHere[1], ccHere[2]));
      System.out.println(String.format("%4d from coords: %.3f, %.3f, %.3f (%d)", i, ccFrom[0], ccFrom[1], ccFrom[2], bitch[i].from));
    }
    
    if (bitch[i].leaf)
    {    
      fill(
        colorizer[0],
        255,
        colorizer[2],
        204
        ); 
      stroke(
        colorizer[0],
        255,
        colorizer[2],
        204
        ); 
      //fill(
      //  int(255*0.0 + colorizer[0] * 0.8),
      //  int(255*0.6 + colorizer[1] * 0.4),
      //  int(255*0.0 + colorizer[2] * 0.8)
      //  );
        
      pushMatrix();
      translate(ccHere[0], ccHere[1]-fullScale*0.5, ccHere[2]);
      scale(sqrt(2.0/3.0), 0.5, 1.0);
      rotateZ(PI/4);
      rotateY(frameCount * leafSpeed * 2*PI);
      box(leafSize, leafSize, leafSize);
      popMatrix();
    }
    
    {
      float xc = (ccFrom[0]+ccHere[0])*0.5;
      float yc = (ccFrom[1]+ccHere[1])*0.5;
      float zc = (ccFrom[2]+ccHere[2])*0.5;
      
      float xdd = ccFrom[0]-ccHere[0];
      float ydd = ccFrom[1]-ccHere[1];
      float zdd = ccFrom[2]-ccHere[2];
      
      float rdd = sqrt(xdd*xdd + ydd*ydd + zdd*zdd);
      
      fill(
        colorizer[0],
        128,
        0,
        51
        ); 
      stroke(
        colorizer[0],
        128,
        0,
        51
        ); 
      //fill(
      //  int(255*0.2 + colorizer[0] * 0.5),
      //  int(255*0.2 + colorizer[1] * 0.3),
      //  int(255*0.0 + colorizer[2] * 0.2),
      //  64
      //  );
        
      pushMatrix();
      translate(xc, yc-fullScale*0.5, zc);
      rotateY(-bFrom.th-bitch[i].th);
      rotateZ(-bFrom.ph-bitch[i].ph);
      box(trunkThk, rdd, trunkThk);
      popMatrix();
    }
  }
}



int FPS = 60;
int totalSecs = 24;
int totalRots = 3;
float[] ccHere = new float[3];
float[] ccFrom = new float[3];
float treeSpeed =  2.0/float(totalSecs*FPS)*float(totalRots);
float leafSpeed = -3.0/float(totalSecs*FPS)*float(totalRots);
void draw()
{
  colorizer[0] = 1;
  colorizer[1] = 1;
  colorizer[2] = 1;
  
  background(0);
   
  ambient(153);
  lights();
   
   
   
  pushMatrix();
  translate(width*0.2, height*0.8, -fullScale*0.4);
  //scale(1.0, -1.0, 1.0);  // LAZY
  rotateY( frameCount * treeSpeed * 2*PI);
  rotateZ(PI);
  DrawBitch();
  popMatrix();
  
  pushMatrix();
  translate(width*0.8, height*0.8, -fullScale*0.4);
  //scale(1.0, -1.0, 1.0);  // LAZY
  rotateY(-frameCount * treeSpeed * 2*PI);
  rotateZ(PI);
  DrawBitch();
  popMatrix();
  
  pushMatrix();
  translate(width*0.5, height*0.5, fullScale*0.4);
  //scale(1.0, -1.0, 1.0);  // LAZY
  rotateY(-frameCount * treeSpeed * 2*PI / float(totalRots));
  rotateZ(PI);
  DrawBitch();
  popMatrix();

  
  if (frameCount < FPS*totalSecs)
  {
    // saveFrame("frames/######.png");
  }
  
  //quad(-20, -20, -20, 20, 20, 20, 20, -20);
}
