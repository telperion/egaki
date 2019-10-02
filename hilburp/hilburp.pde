/*
 * [-x, +x] = left, right
 * [-y, +y] = down, up
 * [-z, +z] = away, toward
 */

int[][] base = {
  {-2,  1,  1},
  {-1, -2,  1},
  {-1, -1, -2},
  {-1,  2, -1},
  { 2,  1, -1},
  { 1, -2, -1},
  { 1, -1,  2},
  { 1,  2,  1}
};

int frame_test = 100;
float scalar = 120;
float[][] base_scaled;


float find_flattener(float[] v, int r_dim, int t_dim)
{
  // flatten in t_dim by rotating around the r_dim axis
  // if the dot product gives the contained angle between the vector and the t_dim axis,
  // acos(dot/magn) - 90 deg is the angle to flatten wrt the t_dim axis
  int d0 = r_dim;
  int d1 = t_dim;
  int d2 = 3 - r_dim - t_dim;
  
  float ang = -atan2(v[d1], v[d2]);
  
  if (frameCount == frame_test)
  {
    println(String.format("{%8.3f, %8.3f, %8.3f} rot %d against %d: %6.3f", v[0], v[1], v[2], r_dim, t_dim, ang));
  }
  
  return ang;
}

void rotate_by(float[] v, float[] w, int r_dim, float ang)
{
  int d0 = r_dim;
  int d1 = (r_dim + 1) % 3;
  int d2 = (r_dim + 2) % 3;
  float rc = cos(ang);
  float rs = sin(ang);
  
  if (frameCount == frame_test)
  {
    print(String.format("{%8.3f, %8.3f, %8.3f}", v[0], v[1], v[2]));
  }
  
  w[d0] = v[d0];
  float w_d1_temp = v[d1]*rc - v[d2]*rs;
  float w_d2_temp = v[d1]*rs + v[d2]*rc;
  w[d1] = w_d1_temp;
  w[d2] = w_d2_temp;
  
  if (frameCount == frame_test)
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
  if (frameCount == frame_test)
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

void setup()
{
  size(1280, 720, P3D);
  colorMode(HSB, 1.0);
  
  base_scaled = new float[base.length][];
  for (int i = 0; i < base.length; i++)
  {
    base_scaled[i] = new float[3];
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
    box(240);
    
    pushMatrix();
      translate(120, 120, 120);
      box(60);
    popMatrix();
    
    
    for (int i = 0; i < base.length; i++)
    {
      for (int j = 0; j < 3; j++)
      {
        base_scaled[i][j] = scalar * (base[i][j] + 0.7*sin((7*i + 3*j - 11)*frameCount*PI/3000));
      }
    }
    
    for (int i = 0; i < 7; i++)
    {
      stroke(i/7.0, 1.0, 1.0, 1.0);
      fill(  i/7.0, 1.0, 1.0, 0.5);
      
      cx(base_scaled[i], base_scaled[i+1], base_scaled[(i+2)%8], 20);
    }
  popMatrix();
  
  if (frameCount == 1000)
  {
    save("lol.png");
  }
}
