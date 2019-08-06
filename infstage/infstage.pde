PGraphics pg;
PImage ref;

int fps_desired = 60;
int fpl = 300;
int loops = 4;

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
  
  pg = createGraphics(960, 540, P3D);
  
  Init();
}

void draw()
{
  float tx = cos(2 * PI * frameCount / float(fpl)); tx = tx*tx;
  float t = (frameCount / float(fpl)) % 1;
  
  
  
  pg.beginDraw();
  
  
  pg.clear();  
  pg.background(30, 0, 0, 255);
  //pg.background(0, 0, 0, 255 * (1 - t) * (1 - t));
  
  pg.translate(width/2, height/2);
  
  /*
  if (frameCount < 5)
  {
      print(String.format("%3d, %3d\n", _tri_W, _tri_H));
  }
  */
  
  pg.strokeJoin(BEVEL);
  pg.strokeWeight(0.02);
  int layer_active = (t >= 0.5) ? 1 : 0;
  for (int b = 0; b < 2; b++)
  {
    pg.pushMatrix();
    
    float tb = (t * 2) % 1 * ((b == 1) ? 1 : 0);
    pg.translate(0, 0, _tri_zu*_tri_spacing*(1 + 2*b));
    pg.scale(1.0 + 0.4 * tb*tb);
    
    // Annoyingly, we have to draw the topmost layer last, no matter what
    int b_draw = 1-b;
    if (b == layer_active)
    {     
      b_draw = b;
    }
    
    for (int ix = 0; ix < _tri_W; ix++)
    {
      for (int iy = 0; iy < _tri_H; iy++)
      {
        int ii = ix*_tri_H + iy;
        
        board[b_draw][ii].Get(ix, iy);
        board[b_draw][ii].Draw(
          pg,
          ix - _tri_W/2, iy - _tri_H/2,
          (1-tb)*(1-tb), tb*tb, tb*tb, 0
        );
      }
    }
    
    pg.popMatrix();
  }
  //pg.triangle(0, 0, 100, 100, 200, 0);
  
  pg.endDraw();
  //image(ref, tx*200, tx*200, width, height); 
  image(pg, 0, 0);
}
