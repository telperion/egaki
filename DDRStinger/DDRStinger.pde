PGraphics pg;

PImage img;

boolean saveFrames = false;
float desiredFPS = 60.0;
int texDelay = 5;
int texHorz = 4;
int texVert = 4;
int texFrames = texHorz * texVert;
boolean texRowM = true;
int N_ARROWS = 30;

float FOV = PI/3.0;

class Arrow
{
  float x;
  // y is the direction of travel
  float z;
  float scale;
  float pos_spd;
  float pos_ofs;
  float tex_spd;
  float tex_ofs;
  
  Arrow()
  {
    this.x = 0.0;
    this.z = 0.0;
    this.scale = 1.0;
    this.pos_spd = 100.0;    // units/sec. +y = down? ??
    this.pos_ofs = 0.0;
    this.tex_spd = 0.25;     // loops/sec
    this.tex_ofs = 0;
  }
  
  void Randomize()
  {
    this.x = random(-600, 600);
    this.z = random(-100, 0);
    this.scale = random(64.0, 256.0);
    this.pos_spd = random(50.0, 200.0);
    this.pos_ofs = random(0.0, 10.0);
    this.tex_spd = random(0.05, 0.25);
    this.tex_ofs = random(0.0, 10.0);
  }
  
  float OutOfFrame()
  {
    // y coordinate that puts the whole arrow out of frame
    
    // i.e., a vertical coordinate of (center - scale) hits
    // the lower edge of the window at the given z distance
    return height - 2.0 * (this.z - this.scale) * tan(FOV / 2.0);    
  }
  
  void Draw(PGraphics pp, float t)
  {
    // Position
    float y = (t - this.pos_ofs) * this.pos_spd;
    float y_max = this.OutOfFrame();
    y = ((y / y_max + 0.5) % 1 - 0.5) * y_max;
    
    /*
    if (frameCount == 1)
    {
      print(String.format("y_max = %8.3f\n", y_max));
    }
    */
    
    float tex_t = (t - this.tex_ofs) * this.tex_spd;
    int tex_ind = floor(tex_t * texFrames) % texFrames;
    tex_ind += int(tex_ind < 0) * texFrames; 
    
    int tex_ix = texRowM ? (tex_ind % texHorz) : ((tex_ind / texVert) % texHorz);
    int tex_iy = texRowM ? ((tex_ind / texHorz) % texVert) : (tex_ind % texVert);
    
    pp.pushMatrix();
      pp.translate(this.x, y, this.z);
      pp.scale(this.scale);
      
      pp.beginShape();
      pp.textureMode(NORMAL);  
      pp.texture(img);  
      pp.vertex(-0.5, -0.5, (tex_ix+0) * 0.25, (tex_iy+0) * 0.25);
      pp.vertex(-0.5,  0.5, (tex_ix+0) * 0.25, (tex_iy+1) * 0.25);
      pp.vertex( 0.5,  0.5, (tex_ix+1) * 0.25, (tex_iy+1) * 0.25);
      pp.vertex( 0.5, -0.5, (tex_ix+1) * 0.25, (tex_iy+0) * 0.25);
      pp.endShape();
    pp.popMatrix();
  }
}

Arrow arrows[];

void sort_arrows()
{
  for (int i = 0; i < N_ARROWS; i++)
  {
    float z_self = arrows[i].z;
    float z_far = z_self;
    int i_far = i;
    
    for (int j = i; j < N_ARROWS; j++)
    {
      if (arrows[j].z < z_far)
      {
        i_far = j;
        z_far = arrows[j].z;
      }
    }
    
    if (i_far != i)
    {
      Arrow swap = arrows[i_far];
      arrows[i_far] = arrows[i];
      arrows[i] = swap;
    }
  }
}


void setup()
{
  size(854, 480, P3D);
  pg = createGraphics(854, 480, P3D);
  
  img = loadImage("note.png");

  randomSeed(4649);
  arrows = new Arrow[N_ARROWS];
  for (int i = 0; i < N_ARROWS; i++)
  {
    arrows[i] = new Arrow();
    arrows[i].Randomize();
  }
  sort_arrows();
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
    for (int i = 0; i < N_ARROWS; i++)
    {
      arrows[i].Draw(pg, frameCount / desiredFPS);
    }
  pg.popMatrix();
    
  pg.endDraw();
  
  fill(51, 5);
  rect(0, 0, width, height);
  image(pg, 0, 0);
  
  if (saveFrames)
  {
    pg.save(String.format("frames/%06d.png", frameCount));
  }  
}
