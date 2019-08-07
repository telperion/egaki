PGraphics pg[];
PGraphics blank;
PImage ref;
int layers = 2;

int fps_desired = 60;
int fpl = 300;
int loops = 4;

float image_wander = 0.01;

Tri board[][];

void Init()
{
  board = new Tri[2][_tri_W * _tri_H];
  for (int b = 0; b < 2; b++)
  {
    for (int i = 0; i < _tri_W * _tri_H; i++)
    {
      board[b][i] = new Tri();
      board[b][i].sz0 =  1.0;
      board[b][i].sz1 =  0.5; // (1.0 + randomGaussian() * 0.3);
      for (int j = 0; j < 3; j++)
      {
        board[b][i].tl[j] = randomGaussian() * 0.3;
      }
      board[b][i].rot = PI * (1 - 2*b) / 60.0;
      board[b][i].Get(i % _tri_H, i / _tri_H);
    }
  }
}

void setup()
{
  frameRate(fps_desired);
  size(960, 540, P3D);
  
  ref = loadImage("res/logo3.png");
  image(ref, 0, 0, width, height);  
  
  pg = new PGraphics[layers];
  for (int li = 0; li < layers; li++)
  {
    pg[li] = createGraphics(960, 540, P3D);
  }
  blank = createGraphics(960, 540, P3D);
  
  Init();
}

void draw()
{
  float tx = cos(2 * PI * frameCount / float(fpl)); tx = tx*tx;
  float t = (frameCount / float(fpl)) % 1;
  int layer_active = (t >= 0.5) ? 1 : 0;
  
  image(ref, cos(2*PI*t)*min(width, height)*image_wander, sin(2*PI*t)*min(width, height)*image_wander, width, height);
  loadPixels();
  background(0);
  
  blank.beginDraw();
  blank.background(0);
  blank.endDraw();
  
  for (int li = 0; li < layers; li++)
  {
    pg[li].beginDraw();    
    
    pg[li].clear();
    //pg[li].background(0, 0, 0, 0);
    
    pg[li].translate(width/2, height/2);
    
    /*
    if (frameCount < 5)
    {
        print(String.format("%3d, %3d\n", _tri_W, _tri_H));
    }
    */
    
    pg[li].strokeJoin(BEVEL);
    pg[li].strokeWeight(0.02);
    
    pg[li].pushMatrix();
    
    float tb = (t * 2) % 1 * ((li == layer_active) ? 1 : 0);
    pg[li].translate(0, 0, _tri_zu*_tri_spacing*(1 + 2*li));
    pg[li].scale(1.0 + 0.4 * tb*tb);
    
    for (int ix = 0; ix < _tri_W; ix++)
    {
      for (int iy = 0; iy < _tri_H; iy++)
      {
        int ii = ix*_tri_H + iy;
        
        board[li][ii].Get(ix, iy);
        board[li][ii].Draw(
          pg[li],
          ix - _tri_W/2, iy - _tri_H/2,
          (li == layer_active) ? (1-tb)*tb*4 : 1, 1-(1-tb)*(1-tb), tb*tb, 0
        );
      }
    }
      
    pg[li].popMatrix();
    //pg[li].triangle(0, 0, 100, 100, 200, 0);
    
    if (li == layer_active)
    {
     // pg[li].filter(BLUR, tb*tb * 10);
    }
    
    pg[li].endDraw(); 
  }
  
  image(blank, 0, 0);
  image(pg[1 - layer_active], 0, 0);
  blend(pg[    layer_active],
    0, 0, width, height,
    0, 0, width, height,
    DODGE);
  
  //print(String.format("%5d\n", frameCount));
}
