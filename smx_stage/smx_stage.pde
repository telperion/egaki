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
boolean dither = true;

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
  palette = new color[bit_depth * bit_depth * bit_depth];
  for (int rr = 0; rr < bit_depth; rr++)
  {
    for (int gg = 0; gg < bit_depth; gg++)
    {
      for (int bb = 0; bb < bit_depth; bb++)
      {
        palette[((bb * bit_depth + gg) * bit_depth + rr)] = color(255*rr / (bit_depth-1), 255*gg / (bit_depth-1), 255*bb / (bit_depth-1));
      }
    }
  }  
}

void draw() {
  // Move the mouse to control how stuff is drawn.
  // X position = transparency of reference layout
  // Y position = palette matching by grey (top) vs. hue (bottom)
  
  
  // Draw ya shit.
  pg_draw.beginDraw();
  for (int y = 0; y < pg_draw.height; y++)
  {
    for (int x = 0; x < pg_draw.width; x++)
    {
      color c = img_test.get(
        int(x * img_test.width /pg_draw.width ),
        int(y * img_test.height/pg_draw.height)
        );
      int i_pal = find_closest_color(palette, c, mouseY/float(height), (x+y) % 2 == 1);
      pg_draw.set(x, y, palette[i_pal]);
    }
  }
  // <Draw stuff here>
  pg_draw.endDraw();
  
  img_tfr = pg_draw.get();
  
  // Reduce to the portion of the full pad that is actually lights.
  pg_save.beginDraw();
  pg_save.fill(0);
  pg_save.noStroke();
  pg_save.rect(0, 0, pg_save.width, pg_save.width);
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
    String frameName = String.format("frames/%02d (30ms) (replace).png", frameCount);
    pg_save.save(frameName);
    print("Saved frame " + frameName + "\n");
  }
}
