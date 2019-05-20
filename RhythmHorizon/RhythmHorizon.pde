int MAX_STARS = 300;
float MAX_STAR_SIZE = 0.01;
float MAX_STAR_WANDER = 0.02;

PGraphics pg;

PImage horizonSourceA;
PImage horizonSourceFG1;
PImage horizonSourceFG2;
PShader horizonShader;

boolean saving = true;
float frameRateDesired = 60;
float frameLoopLength  = 120;    // seconds

float star_loop = 0.2;

float hex_center_x = 0.0;
float hex_center_y = 0.0;
float hex_radius = 128.0;
float hex_apothem = 0.5*sqrt(3.0)*hex_radius;
float hex_minipothem = hex_radius/sqrt(3.0);

class Star
{
  public float x;           // pixels
  public float y;           // pixels
  public float size;        // pixels
  public float scp;         // [0, 1] - scaling parameter in proportion of `size`
  public float shift_arg;   // [0, 2*pi) - shifting direction
  public float shift_magn;  // pixels
  public float shp;         // [-0.5, 0.5] - shifting parameter in proportion of `shift_magn`
  
  public Star()
  {
    float wh = sqrt(width*height);
    
    x = random(1)*width;
    y = random(1)*height;
    size = random(wh*MAX_STAR_SIZE * 0.2, wh*MAX_STAR_SIZE);
    shift_arg = random(TWO_PI);
    shift_magn = random(wh*MAX_STAR_WANDER * 0.2, wh*MAX_STAR_WANDER);
    
    scp = random(1);
    shp = random(1);
  }
  
  public void PrepareDraw(PGraphics context)
  {
    context.stroke(0, 85, 0);
    context.fill(0, 255, 0);
    context.strokeWeight(1);
    context.blendMode(ADD);
  }
  
  public void Draw(PGraphics context, float t)
  {
    float sct =(sin((scp + t) * TWO_PI) - 0.8) / 0.2;
    float sht = sin((shp + t) * TWO_PI) * shift_magn;
    
    sct = (sct < 0.0) ? 0.0 : sct;
    
    float b = size * (sct*sct) * (1.0 - y/height);
    float h = size * sqrt(sct) * (1.0 - y/height);
        
    context.pushMatrix();
      context.translate(x + sht*cos(shift_arg), y + sht*sin(shift_arg), 0);
      context.triangle( 0.5*b,  0, -0.5*b,  0,  0,  h);
      context.triangle( 0, -0.5*b,  0,  0.5*b, -h,  0);
      context.triangle(-0.5*b,  0,  0.5*b,  0,  0, -h);
      context.triangle( 0,  0.5*b,  0, -0.5*b,  h,  0);
    context.popMatrix();
  }
}
Star stars[];

void Init()
{ 
  stars = new Star[MAX_STARS];
  for (int i = 0; i < MAX_STARS; i++)
  {
    stars[i] = new Star();
  }
}


void setup()
{  
  frameRate(frameRateDesired);
  size(1440, 810, P3D);
  //smooth(8);
    
  horizonSourceA = loadImage("assets/perlin-A3.png");
  horizonSourceFG1 = loadImage("assets/bigstock-W-C.png");
  horizonSourceFG2 = loadImage("assets/bigstock-W-B.png");
  
  horizonShader = loadShader("assets/horizonA.glsl");
  horizonShader.set("horizon_src_tex", horizonSourceA);
  horizonShader.set("horizon_fg1_tex", horizonSourceFG1);
  horizonShader.set("horizon_fg2_tex", horizonSourceFG2);
  horizonShader.set("resolution", width, height);
  horizonShader.set("lightener", 0.07);
  
  pg = createGraphics(width, height, P3D);
  
  Init();
}

void DrawHexSpurs(PGraphics context)
{
  float max_extent = 2*width;
  int max_lines = int(max_extent/hex_radius) + 1;
  
  for (float th = 0; th < 1.9*PI; th += 2*PI/3)
  {
    float offset_x =  hex_apothem*sin(th);
    float offset_y = -hex_apothem*cos(th);
    for (int i = -max_lines; i <= max_lines; i++)
    {
      context.line(
        -max_extent*cos(th) + i*offset_x + hex_center_x,
        -max_extent*sin(th) + i*offset_y + hex_center_y,
         max_extent*cos(th) + i*offset_x + hex_center_x,
         max_extent*sin(th) + i*offset_y + hex_center_y
        );
    }
  }
}

void DrawHexInternals(PGraphics context)
{
  float max_extent = 2*width;
  int max_lines = int(max_extent/hex_radius) + 1;
  
  for (float th = PI/6; th < 2.5*PI; th += 2*PI/3)
  {
    float offset_x =  hex_radius*sin(th);
    float offset_y = -hex_radius*cos(th);
    for (int i = -max_lines; i <= max_lines; i++)
    {
      for (int j = -max_lines+((i+1)%2); j <= max_lines; j += 2)
      {
        context.line(
          (j*hex_apothem - hex_minipothem)*cos(th) + 0.5*i*offset_x + hex_center_x,
          (j*hex_apothem - hex_minipothem)*sin(th) + 0.5*i*offset_y + hex_center_y,
          (j*hex_apothem + hex_minipothem)*cos(th) + 0.5*i*offset_x + hex_center_x,
          (j*hex_apothem + hex_minipothem)*sin(th) + 0.5*i*offset_y + hex_center_y
          );
      }
    }
  }
}


void draw()
{
  float ll = frameLoopLength * frameRateDesired;
  float t = float(frameCount) / ll;
  
  //hex_center_x = hex_radius * cos(2*PI*t) * 0.5;
  //hex_center_y = hex_radius * sin(2*PI*t) * 0.5;
  hex_center_y = -(t % 1.0) * hex_apothem * 2;

  pg.beginDraw();
  
  pg.clear();
  pg.background(0, 0, 0, 255);
  
  pg.strokeWeight(4);
  pg.strokeJoin(ROUND);
  pg.strokeCap(ROUND);
  
  pg.stroke(51, 0, 0);
  DrawHexInternals(pg);
  pg.stroke(153, 0, 0);
  DrawHexSpurs(pg);
    
  stars[0].PrepareDraw(pg);
  for (int i = 0; i < MAX_STARS; i++)
  {
    stars[i].Draw(pg, (t/star_loop) % 1.0);
  }
  
  horizonShader.set("time", t);
  pg.filter(horizonShader);
  
  pg.endDraw();
  
      
  image(pg, 0, 0);
    
  if (saving)
  {
    pg.save(String.format("RhythmHorizon/%06d.png", frameCount));
    if (frameCount > ll)
    {
      exit();
    }
  }
}
