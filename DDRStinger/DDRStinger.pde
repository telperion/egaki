PGraphics pg;

PImage img;

float desiredFPS = 60.0;
int texDelay = 5;
float rotSpeed = 3.0;

void setup()
{
  size(360, 360, P3D);
  pg = createGraphics(360, 360, P3D);
  
  img = loadImage("note.png");
}

void draw()
{
  pg.beginDraw();
  
  pg.clear();
  pg.background(0, 0, 0, 0);
  
  int texIndex = frameCount/texDelay;
  int texHorz =  texIndex % 4;
  int texVert = (texIndex / 4) % 4;
  pg.noStroke();
  
  pg.pushMatrix();
    pg.translate(width/2, height/2);
    pg.pushMatrix();
      pg.rotateZ((frameCount / desiredFPS) * 2 * PI / rotSpeed);
      pg.translate(96, 0);
      pg.beginShape();
      pg.textureMode(NORMAL);  
      pg.texture(img);  
      pg.vertex(-64, -64, (texHorz+0) * 0.25, (texVert+0) * 0.25);
      pg.vertex(-64,  64, (texHorz+0) * 0.25, (texVert+1) * 0.25);
      pg.vertex( 64,  64, (texHorz+1) * 0.25, (texVert+1) * 0.25);
      pg.vertex( 64, -64, (texHorz+1) * 0.25, (texVert+0) * 0.25);
      pg.endShape();
    pg.popMatrix();
  pg.popMatrix();
    
  pg.endDraw();
  
  image(pg, 0, 0);
  
  if (frameCount <= desiredFPS * rotSpeed * 2)
  {
    pg.save(String.format("frames/%06d.png", frameCount));
  }  
}