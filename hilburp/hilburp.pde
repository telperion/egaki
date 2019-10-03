/*
 * [-x, +x] = left, right
 * [-y, +y] = down, up
 * [-z, +z] = away, toward
 */

int[][] base = {
  {-1,  1,  1},
  {-1, -1,  1},
  {-1, -1, -1},
  {-1,  1, -1},
  { 1,  1, -1},
  { 1, -1, -1},
  { 1, -1,  1},
  { 1,  1,  1}
};

int[][] rot90s = {
  // x, then y, then z.
  {1, 0, -1},
  {0, 1, 1},
  {0, 0, 0},
  {1, 1, 0},
  {1, -1, 0},
  {0, 0, 0},
  {0, -1, -1},
  {1, 0, 1}
};

int iterations = 5;
int frame_test = -1;
int frame_test_backup = -1;
float scalar = 360;
float[][] base_scaled;

float[][] pt;


float find_flattener(float[] v, int r_dim, int t_dim)
{
  // flatten in t_dim by rotating around the r_dim axis
  // if the dot product gives the contained angle between the vector and the t_dim axis,
  // acos(dot/magn) - 90 deg is the angle to flatten wrt the t_dim axis
  int d0 = r_dim;
  int d1 = t_dim;
  int d2 = 3 - r_dim - t_dim;
  
  float ang = -atan2(v[d1], v[d2]);
  
  if (frameCount == frame_test_backup)
  {
    println(String.format("{%8.3f, %8.3f, %8.3f} rot %d against %d: %6.3f", v[0], v[1], v[2], r_dim, t_dim, ang));
  }
  
  return ang;
}

void scale_by(float[] t, float s)
{
  for (int i = 0; i < 3; i++)
  {
    t[i] *= s;
  }
}

void rotate_by(float[] v, float[] w, int r_dim, float ang)
{
  int d0 = r_dim;
  int d1 = (r_dim + 1) % 3;
  int d2 = (r_dim + 2) % 3;
  float rc = cos(ang);
  float rs = sin(ang);
  
  if (frameCount == frame_test_backup)
  {
    print(String.format("{%8.3f, %8.3f, %8.3f}", v[0], v[1], v[2]));
  }
  
  w[d0] = v[d0];
  float w_d1_temp = v[d1]*rc - v[d2]*rs;
  float w_d2_temp = v[d1]*rs + v[d2]*rc;
  w[d1] = w_d1_temp;
  w[d2] = w_d2_temp;
  
  if (frameCount == frame_test_backup)
  {
    println(String.format(": %d rot %6.3f -> {%8.3f, %8.3f, %8.3f}", r_dim, ang, w[0], w[1], w[2]));
  }
}

void cx(float[] a, float[] b, float[] p, float thk)
{
  float[] c = new float[3];
  float[] d = new float[3];
  float[] q = new float[3];
  float   l = 0;
  
  for (int i = 0; i < 3; i++) {
    c[i] = (b[i] + a[i]) * 0.5;
    d[i] = b[i] - a[i];
    q[i] = p[i] - b[i];
    l += d[i]*d[i];
  }
  l = sqrt(l);
  
  // Turn so that a->b points toward and b->p points right.
  float[] d_rotating = new float[3];
  float[] q_rotating = new float[3];
  
  float rot_x = -find_flattener(d, 0, 1);
  rotate_by(d, d_rotating, 0, rot_x);
  rotate_by(q, q_rotating, 0, rot_x);
  
  float rot_y = find_flattener(d_rotating, 1, 0);
  rotate_by(d_rotating, d_rotating, 1, rot_y);
  rotate_by(q_rotating, q_rotating, 1, rot_y);
  
  float rot_z = find_flattener(q_rotating, 2, 1);
  // No need to actually turn this one.
  if (frameCount == frame_test_backup)
  {
    println("");
  }
  
  pushMatrix();
    translate(c[0], c[1], c[2]);
    rotateX(-rot_x);
    rotateY(-rot_y);
    rotateZ(-rot_z);
    
    box(thk, thk, l);
  popMatrix();  
}


/*
 * consider index 2.5.6
 * within the top level there are 8 replications in order around the tracing path
 * so this item is in rep 6 (3rd level nesting) of rep 5 (2nd level) of rep 2 (1st) 
 * store in zero-indexed octal, i.e. 0o145
 */

float scale_iter = 0.5;
void hilburp(int level, int indexing, float t[])
{
  if (level == 0)
  {
    for (int i = 0; i < 3; i++)
    {
      t[i] = 0;
    }
    if (frameCount == frame_test)
    {
      println(String.format("0x%04X: Initializing", indexing));
    }
    return;
  }
  
  hilburp(level - 1, indexing, t);
  
  int rep = (indexing >> 3*(level - 1)) % 8;  
  for (int i = 0; i < 3; i++)
  {
    t[i] *= scale_iter;
  }
  for (int i = 0; i < 3; i++)
  {
    rotate_by(t, t, i, rot90s[rep][i] * HALF_PI);
  }
  for (int i = 0; i < 3; i++)
  {
    t[i] += base[rep][i];
  }
  
  if (frameCount == frame_test)
  {
    println(String.format("0x%04X: Level %d: {%6.3f, %6.3f, %6.3f}", indexing, level, t[0], t[1], t[2]));
  }
}



void setup()
{
  size(720, 720, P3D);
  colorMode(HSB, 1.0);
  
  base_scaled = new float[base.length][];
  for (int i = 0; i < base.length; i++)
  {
    base_scaled[i] = new float[3];
  }
  
  pt = new float[3][];
  for (int i = 0; i < 3; i++)
  {
    pt[i] = new float[3];
  }
}

void draw()
{
  background(0);
  
  pushMatrix();
    translate(width/2, height/2, 0);
    rotateX(0.5 * (mouseY - height/2) * PI / height);
    rotateY(     -(mouseX -  width/2) * PI / width);
    
    stroke(1.0, 0.0, 1.0, 0.5);
    fill(  1.0, 0.0, 1.0, 0.2);
    box(60);
    
    pushMatrix();
      translate(120, 120, 120);
      box(30);
    popMatrix();
    
    int seg_count = 1;
    for (int i = 0; i < iterations; i++)
    {
      seg_count <<= 3;
    }
    
    for (int index = 0; index < seg_count - 1; index++)
    {
      float h = (pow(2.0, iterations) * float(index) / float(seg_count - 1)) % 1.0;
      stroke(h, 1.0, 1.0, 1.0);
      fill(  h, 1.0, 1.0, 0.8);
      
      hilburp(iterations,  index,                pt[0]);
      hilburp(iterations,  index+1,              pt[1]);
      hilburp(iterations, (index+2) % seg_count, pt[2]);
      for (int i = 0; i < 3; i++)
      {
        scale_by(pt[i], scalar);
      }
      cx(pt[0], pt[1], pt[2], 4);
    }
  popMatrix();
}

void mouseClicked()
{
  save(String.format("lol-%04d%02d%02d-%02d%02d%02d.png", year(), month(), day(), hour(), minute(), second()));
}
