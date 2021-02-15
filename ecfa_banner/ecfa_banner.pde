PImage img;
PShader blubA;
PShader blubB;
PGraphics pg_text;

int block = 14;

int fc = 0;
int f_skip = 0;
float t_ofs = 3.0;
float nominal_rate = 5;
float t_start = 0;
float t_finish = 1;
float bpm = 136;

int splits = 3;
int glints = 0;

void star(PGraphics pg, float x, float y, float radius1, float radius2, int npoints) {
  float angle = TWO_PI / npoints;
  float halfAngle = angle/2.0;
  pg.beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius2;
    float sy = y + sin(a) * radius2;
    pg.vertex(sx, sy);
    sx = x + cos(a+halfAngle) * radius1;
    sy = y + sin(a+halfAngle) * radius1;
    pg.vertex(sx, sy);
  }
  pg.endShape(CLOSE);
}

float ease3(float p)
{
  return (3.0 - 2.0*p)*p*p;
}
float ease5(float p)
{
  return ((6.0*p - 15.0)*p + 10.0)*p*p*p;
}


// The statements in the setup() function 
// execute once when the program begins
void setup() {
  size(1280, 960, P2D);  // Size must be the first statement
  smooth(2);
  pg_text = createGraphics(1280, 960);
  pg_text.smooth(2);
  frameRate(60);
  
  img = loadImage("assets/ECFA2021-darkmode-2.png");
  
  t_ofs = block*0.5;
  
  blubA = loadShader("perlin.glsl");
  blubA.set("resolution", float(width), float(height));
  blubA.set("splitter", pow(2.0, 1.0 / float(splits)));
  blubA.set("scaler", 4.0 * PI / float(splits));
  
  blubB = loadShader("perlin.glsl");
  blubB.set("resolution", float(width), float(height));
  blubB.set("splitter", pow(2.0, 1.0 / float(splits)));
  blubB.set("scaler", 4.0 * PI / float(splits));
  //blub.set("kaleido_n", 5);
  
  
  background(0);   // Clear the screen with a black background
}

// The statements in draw() are executed until the 
// program is stopped. Each statement is executed in 
// sequence and after the last line is read, the first 
// line is executed again.
void draw() {  
  float t = float(frameCount-1) / nominal_rate;
  
  if (frameCount >= nominal_rate * t_start)
  {
    
    blubA.set("time", t_ofs + t/t_finish);
    blubB.set("time", t_ofs + t/t_finish - 1.0);
    //blubA.set("alpha", 1.0 - ease3(t/t_finish % 1.0));
    blubB.set("alpha", ease3(t/t_finish));
    
    //tint(255, 51);
    fill(0, 255);
    rect(0, 0, width, height);
    
    pushMatrix();
    background(0, 0);
    // translate(width/2, height/2);
    // image(img, -img.width/2, -img.height/2, img.width, img.height);
    popMatrix();
    filter(blubA);
    filter(blubB);
    
    
    fill(0, 286 - block*8);            // Reveal more BG based on block rating
    noStroke();
    rect(0, 0, width, height);
    
    
    blend(img, 0, 0, width, height, 0, 0, width, height, BLEND);
    
    
    pg_text.beginDraw();
    pg_text.background(0, 0);
    
    pg_text.pushMatrix();
    pg_text.translate(960, 1920);
    pg_text.rotate(2*PI * ease5(t/t_finish % 1.0) / float(glints) + 1.18*PI);
    pg_text.noStroke();
    pg_text.fill(255, 153, 230, 102);
    star(pg_text, 0, 0, 2400, 48, glints);    
    pg_text.popMatrix();
    pg_text.filter(BLUR, 6);
    
    pg_text.pushMatrix();
    pg_text.translate(960, 1920);
    pg_text.rotate(2*PI * ease3(t/t_finish % 1.0) / float(glints) + 1.18*PI);
    pg_text.noStroke();
    pg_text.fill(255, 153, 230, 255);
    star(pg_text, 0, 0, 2400, 24, glints);    
    pg_text.popMatrix();
    
    pg_text.endDraw();
    
    pg_text.mask(img);
    blend(pg_text, 0, 0, width, height, 0, 0, width, height, SCREEN);
    
    
    
    
    saveFrame(String.format("frames/%02d/######.png", block));
  }
  
  println(String.format("[%13.6f sec.] %6d: %5.3f, %d", float(millis()) / 1000, frameCount-1, ease3(t/t_finish), f_skip));
  
  if (frameCount > nominal_rate * t_finish)
  {
    exit();
  }
}

//
