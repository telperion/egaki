PGraphics pg;
PImage ref;

int fps_desired = 60;
int fpl = 600;
int loops = 4;

Tri board[];

void Init()
{
  board = new Tri[_tri_W * _tri_H];
  for (int i = 0; i < _tri_W * _tri_H; i++)
  {
    board[i] = new Tri();
    board[i].sz0 = _tri_spacing *  0.9;
    board[i].sz1 = _tri_spacing * (1.0 + randomGaussian() * 0.3);
    for (int j = 0; j < 3; j++)
    {
      board[i].tl[j] = randomGaussian() * _tri_spacing * 0.3;
    }
    board[i].rot = PI / 6.0;
    board[i].col = board[i].Get(i % _tri_H, i / _tri_H);
  }
}

void setup()
{
  frameRate(fps_desired);
  size(960, 540, P3D);
  
  ref = loadImage("res/test.png");
  image(ref, 0, 0, width, height);  
  
  pg = createGraphics(960, 540, P3D);
  
  Init();
}

void draw()
{
  float t = cos(2 * PI * frameCount / float(fpl)); t = t*t; // t = 1.3*t-0.3; t = (t > 0) ? t : 0;
  
  
  
  pg.beginDraw();
  
  
  pg.clear();  
  pg.background(0, 0, 0, 255 * (1 - t) * (1 - t));
  
  pg.translate(width/2, height/2);
  
  /*
  if (frameCount < 5)
  {
      print(String.format("%3d, %3d\n", _tri_W, _tri_H));
  }
  */
  
  pg.strokeJoin(BEVEL);
  pg.strokeWeight(_tri_spacing * 0.08);
  for (int ix = 0; ix < _tri_W; ix++)
  {
    for (int iy = 0; iy < _tri_H; iy++)
    {
      int ii = ix*_tri_H + iy;
      color c = board[ii].Get(ix, iy);
      
      pg.fill(c, 255 * (1 - t*t));     
      pg.stroke(c, 128 * (1 - t*t));
      board[ii].Draw(
        pg,
        ix - _tri_W/2, iy - _tri_H/2,
        t*t, t*t, t*t
      );
    }
  }
  //pg.triangle(0, 0, 100, 100, 200, 0);
  
  pg.endDraw();
  
  image(ref, 0, 0, width, height); 
  image(pg, 0, 0);
}
