PGraphics pg[];
PGraphics blank;
PImage ref;
int layers = 2;
boolean saving = true;

int fps_desired = 60;
int fpl = 14400;
int loops = 4;
int whoosh_reps = 3;

boolean enable_blur = true;
float layer_swell = 1.0;
float image_wander = 0.03;
float max_blur_radius = 0.01;
float sigmoid_str = 4.0;
float sigmoid_center = 0.7;

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
      board[b][i].sz1 =  1.15; // (1.0 + randomGaussian() * 0.3);
      for (int j = 0; j < 3; j++)
      {
        board[b][i].tl[j] = randomGaussian() * 0.3;
      }
      board[b][i].rot = PI * (1 - 2*b) / 20.0;
      board[b][i].Get(i % _tri_H, i / _tri_H);
    }
  }
}

void setup()
{
  frameRate(fps_desired);
  size(1280, 720, P3D);
  smooth(3);
  
  ref = loadImage("res/blue-B2.png");
  image(ref, 0, 0, width, height);  
  
  pg = new PGraphics[layers];
  for (int li = 0; li < layers; li++)
  {
    pg[li] = createGraphics(1280, 720, P3D);
  }
  blank = createGraphics(1280, 720, P3D);
  
  colorMode(HSB);
  
  Init();
}

void draw()
{    
  float tx = cos(2 * PI * frameCount / float(fpl)); tx = tx*tx;
  float t = (frameCount / float(fpl)) % 1;
  int layer_active = ((whoosh_reps*t) % 1 >= 0.5) ? 1 : 0;
  
  float ofs_x = sin(PI*(4*t-0))*width*image_wander;
  float ofs_y = t*height; //sin(PI*(2*t-0.25))*height*image_wander;
  float ofs_x_mod = (ofs_x + width) % width;
  float ofs_y_mod = (ofs_y + height) % height;
  
  image(ref, ofs_x_mod - width, ofs_y_mod - height, width, height);
  image(ref, ofs_x_mod        , ofs_y_mod - height, width, height);
  image(ref, ofs_x_mod - width, ofs_y_mod         , width, height);
  image(ref, ofs_x_mod        , ofs_y_mod         , width, height);
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
    pg[li].strokeWeight(0.05);
    
    pg[li].pushMatrix();
    
    float tb = (2*whoosh_reps*t) % 1 * ((li == layer_active) ? 1 : 0);
    float tt = sigtanh(tb, sigmoid_str, sigmoid_center);
    pg[li].scale(1.0 + layer_swell * tt);
    
    for (int ix = 0; ix < _tri_W; ix++)
    {
      for (int iy = 0; iy < _tri_H; iy++)
      {
        int ii = ix*_tri_H + iy;
        
        board[li][ii].Get(ix, iy);
        board[li][ii].Draw(
          pg[li],
          ix - _tri_W/2, iy - _tri_H/2,
          (li == layer_active) ? pow((1-tb)*tb*4,3) : 1, tt, tt, 0
        );
      }
    }
      
    pg[li].popMatrix();
    //pg[li].triangle(0, 0, 100, 100, 200, 0);
    
    if (enable_blur && (li == layer_active))
    {
      pg[li].filter(BLUR, tt * max_blur_radius * min(width, height));
    }
    
    pg[li].endDraw(); 
  }
  
  image(blank, 0, 0);
  image(pg[1 - layer_active], 0, 0);
  blend(pg[    layer_active],
    0, 0, width, height,
    0, 0, width, height,
    DODGE);
    
  if (saving && (frameCount <= fpl))
  {
    saveFrame("frames-720p-multi/infstage-######.png");
    print(String.format("Saved frame %6d of %6d\n", frameCount, fpl));
  }  
}
