PImage img;
PShader kale;
PFont font;
PGraphics pg_text;

int bg_total = 568;
int fc = 0;
int f_skip = 0;
int f_ofs = 60;
float nominal_rate = 60;
float t_start = 145;
float t_finish = 150;
float bpm = 136;

// The statements in the setup() function 
// execute once when the program begins
void setup() {
  size(1024, 1024, P2D);  // Size must be the first statement
  smooth(2);
  pg_text = createGraphics(1024, 1024);
  pg_text.smooth(2);
  frameRate(60);
  
  kale = loadShader("kaleidont.glsl");
  kale.set("resolution", float(width), float(height));
  kale.set("kaleido_speed", 0.03);
  kale.set("kaleido_rot_all", 0.02);
  kale.set("kaleido_n", 5);  
  
  font = createFont("Soloist", 216);
  
  background(0);   // Clear the screen with a black background
}

// The statements in draw() are executed until the 
// program is stopped. Each statement is executed in 
// sequence and after the last line is read, the first 
// line is executed again.
void draw() {
  int img_index = (frameCount + f_ofs) % (2*bg_total);
  if (img_index >= bg_total)
  {
    img_index = 2*bg_total - img_index - 1;
  }
  img_index++;
  
  if (frameCount >= nominal_rate * t_start)
  {
    img = loadImage(String.format("C:\\Users\\telpi\\OneDrive\\Paradise\\stock\\frames\\%06d.jpg", img_index));
    
    float t = float(frameCount) / nominal_rate;
    kale.set("t", t);
    
    //tint(255, 51);
    pushMatrix();
    background(0, 0);
    // translate(width/2, height/2);
    // image(img, -img.width/2, -img.height/2, img.width, img.height);
    image(img, 0, 0, width, height);
    popMatrix();
    filter(kale);
    fill(0, 51);
    noStroke();
    rect(0, 0, width, height);
    
    pg_text.beginDraw();
    pg_text.background(0, 0);
    pg_text.textFont(font);
    pg_text.textAlign(CENTER, CENTER);
    pg_text.translate(width/2 - 24, height/2 - 24);
    pg_text.scale(1.0 + 0.3*cos(0.25*PI*t * (bpm/60.0)));
    pg_text.fill(0, 85);
    pg_text.text("TEAM", 0, -96);
    pg_text.text("TEAM", 0, 96);
    pg_text.filter(BLUR, 12);
    pg_text.fill(0, 85);
    pg_text.text("TEAM", 0, -84 + 12);
    pg_text.text("TEAM", 0, 84 + 12);
    pg_text.fill(255, 255);
    pg_text.text("TEAM", 0, -84);
    pg_text.text("TEAM", 0, 84);
    pg_text.endDraw();
    image(pg_text, 0, 0);
    
    saveFrame("frames/kaleidont-######.jpg");
  }
  
  println(String.format("[%13.6f sec.] %6d: %d", float(millis()) / 1000, frameCount, f_skip));
  
  if (frameCount > nominal_rate * t_finish)
  {
    exit();
  }
}

//
