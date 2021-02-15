PShader fog_quads;
PShader fog_lines;
PShape scroller;

float t_ofs = 3.0;
float nominal_rate = 30;
float t_start = 0;
float t_finish = 10;

float sc = 100;

int GRID_X = 60;
int GRID_Z = 60;
float x_extend = 2.0;
float[] v;

void pick_vertices()
{
  v = new float[(GRID_X+1) * (GRID_Z+1)];
  for (int i = 0; i <= GRID_Z; i++)
  {
    for (int j = 0; j <= GRID_X; j++)
    {
      float x = 2.0*float(j - GRID_X/2)/float(GRID_X)*x_extend + random(-0.05, 0.05);
      float z = 2.0*float(i - GRID_Z/2)/float(GRID_Z);
      int index = i*GRID_X + j;
      v[index] = 
        -2.61034 * x*x*x*x +
         0.70881 * x*x*x   +
         2.41285 * x*x     +
        -0.70881 * x       +
         0.19749;
      v[index] = (abs(x) > 1.0) ? 0.1 : v[index];
      v[index] *= random( 0.90, 1.00);
      v[index] += random(-0.05, 0.05);
    }
  }
}

// The statements in the setup() function 
// execute once when the program begins
void setup()
{
  size(1280, 960, P3D);  // Size must be the first statement
  smooth(2);
  frameRate(60);
  hint(ENABLE_STROKE_PERSPECTIVE);
  hint(DISABLE_OPTIMIZED_STROKE);
  noiseDetail(4, 0.6);
  
  sc = min(width, height)*0.2;
  
  fog_quads = loadShader("fog.glsl");
  fog_quads.set("minDepth", sc*1);
  fog_quads.set("maxDepth", sc*2);
  fog_lines = loadShader("fog2.glsl");
  fog_lines.set("minDepth", sc*-0.5);
  fog_lines.set("maxDepth", sc*1.5);
  
  randomSeed(20210212);
  pick_vertices();
  
  scroller = createShape();
  
  scroller.beginShape(QUADS);
  scroller.fill(0, 51);
  scroller.stroke(255, 255);
  scroller.strokeWeight(3);
  
  float dx = 2.0/float(GRID_X);
  float dz = 2.0/float(GRID_Z);
  for (int i = 0; i < 3*GRID_Z; i++)
  {
    int ii =  i      % GRID_Z;
    int im = (i + 1) % GRID_Z;
    for (int j = 0; j < GRID_X; j++)
    {
      float x1 = -1.0 +  j   *dx;
      float x2 = -1.0 + (j+1)*dx;
      float z1 = -1.0 +  i   *dz;
      float z2 = -1.0 + (i+1)*dz;
      scroller.vertex(x1, v[ii*GRID_X + j  ], z1);
      scroller.vertex(x2, v[ii*GRID_X + j+1], z1);
      scroller.vertex(x2, v[im*GRID_X + j+1], z2);
      scroller.vertex(x1, v[im*GRID_X + j  ], z2);
    }
  }
  scroller.endShape();
}

void draw_vertex(float x, float y, float z)
{
  float c = constrain(sqrt(y > 0.2 ? y-0.2 : 0), 0, 1);
  float cc = cos(c*PI/2);
  float ss = sin(c*PI/2);
  stroke(102, 102+153*ss, 102+153*cc, 255);
  fill(0, 255*ss, 255*cc, 204);
  vertex(x + noise(x, z)*0.1, y * constrain(1.0*pow(z<4.0 ? 4.0-z : 0, 0.25), 0, 1), z);
}

// The statements in draw() are executed until the 
// program is stopped. Each statement is executed in 
// sequence and after the last line is read, the first 
// line is executed again.
void draw()
{  
  float t = float(frameCount-1) / nominal_rate;
  
  shader(fog_quads, TRIANGLES);
  shader(fog_lines, LINES);
  background(153);   // Clear the screen with a black background
  
  if (frameCount >= nominal_rate * t_start)
  {
    pushMatrix();
    translate(0.65*width, 0.51*height, 0.0);
    scale(sc, -sc, sc);
    rotateX(PI/30.0);
    rotateY(-PI/10.0);
    //shape(scroller);    
    //box(1);
    
    float tl = (2.0*t/(t_finish-t_start)) % 2.0;
    
    
    float dx = 2.0/float(GRID_X)*x_extend;
    float dz = 2.0/float(GRID_Z);
    for (int i = 0; i < 3*GRID_Z; i++)
    {
      int ii = (i    ) % GRID_Z;
      int im = (i + 1) % GRID_Z;
      for (int j = 0; j < GRID_X; j++)
      {
        float x1 = -1.0*x_extend +  j   *dx;
        float x2 = -1.0*x_extend + (j+1)*dx;
        float z1 = -1.0          +  i   *dz;
        float z2 = -1.0          + (i+1)*dz;        
        beginShape(QUADS);
        strokeWeight(0.003);
        strokeCap(ROUND);
        strokeJoin(ROUND);
        
        draw_vertex(x1, v[ii*GRID_X + j  ], z1 + tl);
        draw_vertex(x2, v[ii*GRID_X + j+1], z1 + tl);
        draw_vertex(x2, v[im*GRID_X + j+1], z2 + tl);
        draw_vertex(x1, v[im*GRID_X + j  ], z2 + tl);
        endShape();
      }
    }
    
    
    popMatrix();
    
    saveFrame("frames/######.png");
  }
  
  // println(String.format("[%13.6f sec.] %6d: %5.3f, %d", float(millis()) / 1000, frameCount-1, ease3(t/t_finish), f_skip));
  
  if (frameCount > nominal_rate * t_finish)
  {
    exit();
  }
}

//
