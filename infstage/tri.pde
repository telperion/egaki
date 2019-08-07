int w = 960;
int h = 540;

float sq3d2 = sqrt(3.0) / 2.0;
int _tri_W = 41;  // should be an odd number
float _tri_spacing = 2.0 * w / float(_tri_W);    // center-to-center horizontally
float _tri_border = 0.2;                         // inner triangle from outer triangle
float _tri_zu = 0.01;
int _tri_H = ceil(float(h) / (_tri_spacing * sq3d2) * 0.5) * 2 + 1;

class Tri
{
  float sz0;     // side length, units (tween at 0)
  float sz1;     // side length, units (tween at 1) 
  float tl[];    // translation, 3D units (tween at 1)
  float rot;     // rotation (single axis), radians (tween at 1)
  color col;     // color storage
  boolean join;  // a joined triangle (idk?)      
  
  Tri()
  {
    sz0 = 1;
    sz1 = 0;
    tl = new float[3];
    for (int i = 0; i < 3; i++)
    {
      tl[i] = 0;
    }
    rot = 0;
    col = color(0, 0, 0);
    join = false;
  }
  
  Tri(Tri o)
  {
    sz0 = o.sz0;
    sz1 = o.sz1;
    tl = new float[3];
    for (int i = 0; i < 3; i++)
    {
      tl[i] = o.tl[i];
    }
    rot = o.rot;
    col = o.col;
    join = o.join;
  }
  
  void Get(int ix, int iy)
  {
    float s = 1 - 2 * ((ix + iy) % 2);
    
    col = get(
      int( width*0.5 + _tri_spacing*(ix                          - _tri_W/2)*0.5),
      int(height*0.5 + _tri_spacing*(sq3d2*iy + s * sq3d2 / -6.0 - _tri_H/2 + 1))
    );
    //col = color(hue(col), saturation(col), 100*sigtanh(brightness(col)*0.01, 2, 0.7));
  }
  
  void Draw(PGraphics pg, int ix, int iy, float alpha, float tween_rot, float tween_sz, float tween_tl)  
  {
    // (0, 0) is a triangle pointing up at (width/2, height/2)
    float sz = sz0 + (sz1 - sz0) * tween_sz;
    float sz_b = sz - _tri_border; sz_b = (sz_b < 0) ? 0 : sz_b;
    color col_b = col;
    col = color(hue(col), 100 - 0.45*(100 - saturation(col)), 15+0.2*brightness(col));
    
    //pg.strokeWeight(1.0 / _tri_spacing);
        
    pg.pushMatrix();
      if ((ix + iy) % 2 != 0)
      {
        pg.rotateZ(rot*tween_rot);
        pg.scale(_tri_spacing);
        pg.translate(
          tl[0]*tween_tl + ix*0.5,
          tl[1]*tween_tl + (sq3d2*iy + sq3d2 / -6.0),
          tl[2]*tween_tl
        );
        pg.fill(col, 255 * alpha);     
        pg.stroke(col, 128 * alpha);
        pg.scale(sz);
        pg.triangle(
          -0.5, sq3d2 / -3.0,
           0.5, sq3d2 / -3.0,
           0.0, sq3d2 /  1.5
        );
        
        pg.translate(0, 0, _tri_zu);
        pg.fill(col_b, 255 * alpha);     
        pg.stroke(col_b, 128 * alpha);
        pg.scale(sz_b);
        pg.triangle(
          -0.5, sq3d2 / -3.0,
           0.5, sq3d2 / -3.0,
           0.0, sq3d2 /  1.5
        );
      }
      else
      {
        pg.rotateZ(rot*tween_rot);
        pg.scale(_tri_spacing);
        pg.translate(
          tl[0]*tween_tl + ix*0.5,
          tl[1]*tween_tl + (sq3d2*iy + sq3d2 /  6.0),
          tl[2]*tween_tl
        );
        pg.fill(col, 255 * alpha);     
        pg.stroke(col, 128 * alpha);
        pg.scale(sz);
        pg.triangle(
          -0.5, sq3d2 /  3.0,
           0.5, sq3d2 /  3.0,
           0.0, sq3d2 / -1.5
        );
        
        pg.translate(0, 0, _tri_zu);
        pg.fill(col_b, 255 * alpha);     
        pg.stroke(col_b, 128 * alpha);
        pg.scale(sz_b);
        pg.triangle(
          -0.5, sq3d2 /  3.0,
           0.5, sq3d2 /  3.0,
           0.0, sq3d2 / -1.5
        );
      }
    pg.popMatrix();
  }
}
