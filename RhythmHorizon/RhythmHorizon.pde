PGraphics pg;

PImage horizonSourceA;
PImage horizonSourceFG1;
PImage horizonSourceFG2;
PShader horizonShader;

boolean saving = true;
float frameRateDesired = 60;
float frameLoopLength  = 30;    // seconds

float hex_center_x = 0.0;
float hex_center_y = 0.0;
float hex_radius = 90.0;
float hex_apothem = 0.5*sqrt(3.0)*hex_radius;
float hex_minipothem = hex_radius/sqrt(3.0);

void Init()
{ 
}


void setup()
{  
  frameRate(frameRateDesired);
  size(960, 540, P3D);
  //smooth(8);
    
  horizonSourceA = loadImage("assets/perlin-A3.png");
  horizonSourceFG1 = loadImage("assets/bigstock-W-C.png");
  horizonSourceFG2 = loadImage("assets/bigstock-W-B.png");
  
  horizonShader = loadShader("assets/horizonA.glsl");
  horizonShader.set("horizon_src_tex", horizonSourceA);
  horizonShader.set("horizon_fg1_tex", horizonSourceFG1);
  horizonShader.set("horizon_fg2_tex", horizonSourceFG2);
  horizonShader.set("resolution", 960, 540);
  horizonShader.set("lightener", 0.07);
  
  pg = createGraphics(960, 540, P3D);
  
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
  
  pg.stroke(127);
  DrawHexInternals(pg);
  pg.stroke(255);
  DrawHexSpurs(pg);
  
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
