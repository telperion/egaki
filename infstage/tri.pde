int w = 1080;
int h = 720;

float sq3d2 = sqrt(3.0) / 2.0;
int _tri_W = 37;  // should be an odd number
float _tri_spacing = 2.0 * w / float(_tri_W);    // center-to-center horizontally
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
    sz0 = _tri_spacing;
    sz1 = 0;
    tl = new float[3];
    for (int i = 0; i < 3; i++)
    {
      tl[i] = 0;
    }
    rot = 0;
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
    join = o.join;
  }
  
  color Get(int ix, int iy)
  {
    color res;
    float s = 1 - 2 * ((ix + iy) % 2);
    
    res = get(
      int( width*0.5 + _tri_spacing*(ix                         - _tri_W/2)*0.5),
      int(height*0.5 + _tri_spacing*(sq3d2*iy + s * sq3d2 / 6.0 - _tri_H/2 + 1))
    );
    return res;
  }
  
  void Draw(PGraphics pg, int ix, int iy, float tween_tl, float tween_rot, float tween_sz)  
  {
    // (0, 0) is a triangle pointing up at (width/2, height/2)
    float sz = sz0 + (sz1 - sz0) * tween_sz;
    
    pg.pushMatrix();
      if ((ix + iy) % 2 != 0)
      {
        pg.translate(
          tl[0]*tween_tl + _tri_spacing*ix*0.5,
          tl[1]*tween_tl + _tri_spacing*(sq3d2*iy + sq3d2 / -6.0),
          tl[2]*tween_tl
        );
        pg.rotateZ(rot*tween_rot);
        pg.triangle(
          sz * -0.5, sz * sq3d2 / -3.0,
          sz *  0.5, sz * sq3d2 / -3.0,
                0.0, sz * sq3d2 /  1.5
        );
      }
      else
      {
        pg.translate(
          tl[0]*tween_tl + _tri_spacing*ix*0.5,
          tl[1]*tween_tl + _tri_spacing*(sq3d2*iy + sq3d2 /  6.0),
          tl[2]*tween_tl
        );
        pg.rotateZ(rot*tween_rot);
        pg.triangle(
          sz * -0.5, sz * sq3d2 /  3.0,
          sz *  0.5, sz * sq3d2 /  3.0,
                0.0, sz * sq3d2 / -1.5
        );
      }
    pg.popMatrix();
  }
}
