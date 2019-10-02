PGraphics pg_draw;
PGraphics pg_disp;
PGraphics pg_save;
PImage img_test;
PImage img_ref;
PImage img_tfr;
int n_frames = 32;
int downscale = 16;
int bit_depth = 4;
float gvh_weight = 0.2;
boolean dither = false;

int n_circles = 64;
int n_circles_as_if = 64;

color palette[];

void setup() {
  size(816, 816);  // Locked size (full pad placement * 16)
  
  // Locked sizes (full pad placement, SMX format constraint)
  pg_draw = createGraphics(51, 51);
  pg_disp = createGraphics(51, 51);
  pg_save = createGraphics(23, 24);
  
  img_test = loadImage("test.png");              // Load the test image into the program
  img_ref = loadImage("template-full-pad.png");  // Load the reference layout image into the program
  
  // Fill the palette.
  float[] hsv = new float[3];
  float[] rgb = new float[3];
  palette = new color[bit_depth * bit_depth + 2];
  for (int rr = 0; rr < bit_depth; rr++)
  {
    for (int gg = 0; gg < bit_depth; gg++)
    {
      hsv[0] = (rr / float(bit_depth-1) * 1.0 + 3.5) / 6.0;
      hsv[1] =  1.0; 
      hsv[2] =  0.1 + gg / float(bit_depth-1) * 0.8;
      HSV2RGB(hsv, rgb);
      palette[rr * bit_depth + gg] = color(
        255*rgb[0],
        255*rgb[1],
        255*rgb[2]
      );
    }
  }
  palette[bit_depth * bit_depth + 0] = color(  0,   0,   0, 255);
  palette[bit_depth * bit_depth + 1] = color(255, 255, 255, 255);
}

void draw() {
  // Move the mouse to control how stuff is drawn.
  // X position = transparency of reference layout
  // Y position = palette matching by grey (top) vs. hue (bottom)
  
  
  pg_draw.beginDraw();
  // Draw ya shit.
  pg_draw.fill(0);
  pg_draw.noStroke();
  pg_draw.rect(0, 0, pg_draw.width, pg_draw.height);
  float diag = sqrt(pg_draw.width*pg_draw.width + 4*pg_draw.height*pg_draw.height);
  
  for (int i = 0; i < n_circles; i++)
  { 
    float t = (float(i)/n_circles_as_if + frameCount / float(n_frames)) % 1.0;
    pg_draw.fill(int(255 * (1 - t)*(1 - t)));
    float r = float(n_circles-i) / n_circles;
    float radius = diag * sqrt(r);
    pg_draw.circle(0.5*pg_draw.width, 0, radius);
  }
  
  for (int y = 0; y < pg_draw.height; y++)
  {
    for (int x = 0; x < pg_draw.width; x++)
    {
      /*
      color c = img_test.get(
        int(x * img_test.width /pg_draw.width ),
        int(y * img_test.height/pg_draw.height)
        );
      */
      color c = pg_draw.get(x, y);      
      
      int i_pal = find_closest_color(palette, c, gvh_weight, dither && ((x+y) % 2 == 1)); // mouseY/float(height)
      c = palette[i_pal];      
      
      pg_draw.set(x, y, c);
    }
  }
  // <Draw stuff here>
  pg_draw.endDraw();
  
  img_tfr = pg_draw.get();
  
  // Reduce to the portion of the full pad that is actually lights.
  pg_save.beginDraw();
  pg_save.fill(0);
  pg_save.noStroke();
  pg_save.rect(0, 0, pg_save.width, pg_save.width);  // intentional
  for (int r = 0; r < 3; r++)
  {
    for (int c = 0; c < 3; c++)
    {
      pg_save.copy(img_tfr, r*16 + 6, c*16 + 6, 7, 7, r*8, c*8, 7, 7);
    }
  }
  pg_save.endDraw();
  
  // Draw for user.
  // Overlay the full pad template lightly onto the actual image.
  pg_disp.beginDraw();
  pg_disp.image(img_ref, 0, 0);
  pg_disp.tint(255, 255*mouseX/width);
  pg_disp.image(img_tfr, 0, 0);  
  pg_disp.endDraw();
  
  for (int y = 0; y < height; y++)
  {
    for (int x = 0; x < width; x++)
    {
      set(x, y, pg_disp.get(x / downscale, y / downscale));
    }
  }
  
  if (frameCount <= n_frames)
  {
    String frameName = String.format("frames/%02d (100ms) (replace).png", n_frames - frameCount);
    pg_save.save(frameName);
    print("Saved frame " + frameName + "\n");
  }
}
