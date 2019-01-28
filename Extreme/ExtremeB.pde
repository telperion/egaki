// Stinger variant

final int STING_SM = 0;   // Indicates subreaders
final int STING_LG = 1;   // Indicates leaders

final int PHASE_NOP = 0;  // Nothing is happening
final int PHASE_LG1 = 1;  // Leaders appearing
final int PHASE_SM1 = 2;  // Subreaders appearing
final int PHASE_LG2 = 3;  // Leaders filling 
final int PHASE_SM2 = 4;  // Subreaders filling, leaders clearing
final int PHASE_OUT = 5;  // Subreaders clearing
final int PHASE_MAX = 6;

final int POS_X   = 0;
final int POS_Y   = 1;
final int POS_S1  = 2;
final int POS_S2  = 3;
final int POS_RZ  = 4;
final int POS_MAX = 5;

final int frameRateDesired = 60;
final int sw = 960;
final int sh = 540;
final int ss = 20;
final float sp = 0.7;
final float spt = 0.4;     // Subreaders spawn in this much time; last subreader starts to spawn at 1-spt
final float ssOverage = 1.001;  // Overdraw squares just a bit to make sure there are no spoopy gaps

final int fw = sw/ss;
final int fh = sh/ss;

final float[] c0 = {0.300, 0.500, 0.400};  // HSV of lower bound color
final float[] c1 = {0.200, 1.000, 0.700};  // HSV of upper bound color
final float leaderCol = 0.5;               // The nearest that leaders get to the lower bound color
final float bgStrength = 0.1;

final float[] plDefaults = {2.0, 2.0, 3.0, 4.0, 2.0, 2.0};
final float plLoop = 12.0;

final float scrollSpeed = 0.75;             // squares per second 
  
  

// t: time, [0, 1]
// p: point of maximum displacement, 0.7 or [0.5, 1] recommended
float outBack(float t, float p)
{
  return (2*t*t*t - 3*(1+p)*t*t + 6*p*t)/(3*p - 1);
}

// t: time, [0, 1]
// p: point of direction change, 0.3 or [0, 1] recommended (cut in half)
float turnabout(float t, float p)
{
  t = 2*t - 1;
  p = 3*p*p;
  return t*(t*t-p)/(1-p);
}

final float strokeStrength = 0.8;
void SetColor(PGraphics pg, float[] col)
{   
  // Fill color
  pg.fill(
    int(255*col[0]),
    int(255*col[1]),
    int(255*col[2]),
    int(255*col[3])
    );
  
  // Stroke color - lighter ver. of fill color
  for (int i = 0; i < 3; i++)
  {
    //rgb[i] = 1.0 - (1.0 - rgb[i])*strokeStrength;
    col[i] = col[i]*strokeStrength;
  }
  pg.stroke(
    int(255*col[0]),
    int(255*col[1]),
    int(255*col[2]),
    int(255*(1.0 - (1.0 - col[3])*strokeStrength))
    );
}

void GetTweenTime(SQ sq, float t, float[] tweenInfo)
{  
  // tweenInfo[0] = tween phase
  // tweenInfo[1] = tween progress
  
  float tEnd = 0;
  float endTimes[] = new float[PHASE_MAX+1]; 
  endTimes[0] = 0;
  for (int i = 1; i <= PHASE_MAX; i++)
  {
    tEnd += plDefaults[i-1]; 
    endTimes[i] = tEnd;
  }
  t = (t + 0) % endTimes[PHASE_MAX];
  for (int i = 1; i <= PHASE_MAX; i++)
  {
    if (t < endTimes[i])
    {      
      tweenInfo[0] = i-1;
      tweenInfo[1] = (t - endTimes[i-1])/(endTimes[i] - endTimes[i-1]);
      break;
    }
  }
  
}




class SQ
{
  public float x;     // Center location X in pixels
  public float y;     // Center location Y in pixels
  public float type;  // Leader or subreader?
  public float ccO;   // Color selection for outer square, [0, 1] (used for leaders)
  public float ccI;   // Color selection for inner square, [0, 1] (used for leaders)
  public float spOff; // Spawn offset (used for subreaders)
    
  SQ()
  {
    x = 0.0;
    y = 0.0;
    type = STING_SM;
    ccI = leaderCol + random(1 - leaderCol);
    ccO = ccI / 2;
    spOff = random(1);
  }
  
  SQ(float xx, float yy)
  {
    x = xx;
    y = yy;
    type = STING_SM;
    ccI = leaderCol + random(1 - leaderCol);
    ccO = ccI / 2;
    spOff = random(1);
  }

  // col: storage for two RGBA colors, outer and inner
  // phase: phase of transition happening now
  // tt: time within phase - [0, 1)
  void SQColor(float[] hsvO, float[] hsvI, int phase, float tt)
  {
    for (int i = 0; i < 3; i++)
    {
      if (type == STING_LG)
      {
        hsvO[i] = c0[i]*(1.0 - ccO) + c1[i]*(ccO);
        hsvI[i] = c0[i]*(1.0 - ccI) + c1[i]*(ccI);        
      }
      else
      {
        hsvO[i] = c0[i];
        hsvI[i] = c0[i];
      }
    }
    hsvO[3] = 0;
    hsvI[3] = 0;
    hsvO[2] *= 0.7;
    
    switch (phase)
    {
      case PHASE_NOP:
        // Do nothing.
      break;
      case PHASE_LG1:
        if (type == STING_LG)
        {
          hsvO[3] = tt;
        }
      break;
      case PHASE_SM1:
        if (type == STING_SM)
        {
          hsvO[3] = tt;
        }
        else
        {
          hsvO[3] = 1;
        }
      break;
      case PHASE_LG2:
        if (type == STING_LG)
        {
          hsvO[3] = 1;
          hsvI[3] = (2-tt)*tt;
        }
        else
        {
          hsvO[3] = 1;
        }
      break;
      case PHASE_SM2:
        if (type == STING_SM)
        {
          hsvO[3] = 1;
          hsvI[3] = (2-tt)*tt;
        }
        else
        {
          hsvO[3] = 1-tt*0.5;
          hsvI[3] = 1-tt*0.5;
        }
      break;
      case PHASE_OUT:
        if (type == STING_SM)
        {
          hsvO[3] = 1-tt;
          hsvI[3] = 1-tt;
        }
        else
        {
          hsvO[3] = 0.5*(1-tt);
          hsvI[3] = 0.5*(1-tt);
        }
      break;
    }
  }
  
  // pos: storage for (X, Y, S1, S2, R) coordinates - (x, y), scale primary, scale secondary, rotation in Z
  // sq: square to derive position for
  // phase: phase of transition happening now
  // tt: time within phase - [0, 1)
  void SQPosition(float[] pos, int phase, float tt)
  {
    pos[POS_X ] = x;
    pos[POS_Y ] = y;
    pos[POS_S1] = 0;
    pos[POS_S2] = 0;
    pos[POS_RZ] = 0;
        
    switch (phase)
    {
      case PHASE_NOP:
        // Do nothing.
      break;
      case PHASE_LG1:
        if (type == STING_LG)
        {
          pos[POS_Y ] = y + ss*(1-outBack(tt, 0.5));
          pos[POS_S1] = tt*(2-tt);
        }
        // Subreaders do nothing here
      break;
      case PHASE_SM1:
        if (type == STING_SM)
        {
          float tOff = (tt - (1-spt)*spOff)/spt;
          tOff = (tOff > 1) ? 1 : (tOff < 0) ? 0 : tOff;
          pos[POS_Y ] = y + ss*(1-outBack(tOff, 0.5));
          pos[POS_S1] = tOff*(2-tOff);
        }
        else
        {
          pos[POS_S1] = 1;
        }
      break;
      case PHASE_LG2:
        if (type == STING_LG)
        {
          pos[POS_S1] = 1;
          pos[POS_S2] = tt*(2-tt);
        }
        else
        {
          pos[POS_S1] = 1;
        }
      break;
      case PHASE_SM2:
        if (type == STING_SM)
        {
          pos[POS_S1] = 1;
          pos[POS_S2] = tt*(2-tt);
        }
        else
        {
          pos[POS_S1] = 1;
          pos[POS_S2] = 1;
        }
      break;
      case PHASE_OUT:
        float tOff = (tt - (1-spt)*spOff)/spt;
        tOff = (tOff > 1) ? 1 : (tOff < 0) ? 0 : tOff;
        pos[POS_Y ] = y - ss*tOff;
        pos[POS_S1] = 1-tOff;
        pos[POS_S2] = 1-tOff;
        // Leaders do nothing here
      break;
    }
  }
  
  
  void Draw(PGraphics pg, float t)
  {
    float tweenInfo[] = new float[2];
    GetTweenTime(this, t, tweenInfo);
    //print(String.format("sq (x = %8.3f, y = %8.3f): phase = %2.1f, time = %8.3f\n", x, y, tweenInfo[0], tweenInfo[1]));
    
    float[] hsvO = new float[4];
    float[] hsvI = new float[4];
    float[] pos  = new float[5];
    float[] col  = new float[4];
    
    SQColor(hsvO, hsvI, int(tweenInfo[0]), tweenInfo[1]);
    SQPosition(pos, int(tweenInfo[0]), tweenInfo[1]);
    /*
    print(String.format("sq (x = %8.3f, y = %8.3f): phase = %2.1f, time = %8.3f, O(%5.3f, %5.3f, %5.3f, %5.3f) @ (%4.1f, %4.1f, %3.1f, %3.1f, %4.1f)\n", 
      x, y, tweenInfo[0], tweenInfo[1],
      hsvO[0], hsvO[1], hsvO[2], hsvO[3],
      pos[0], pos[1], pos[2], pos[3], pos[4]
      ));
    */
    
    float szO = ss * pos[POS_S1] * ssOverage;
    float szI = ss * pos[POS_S2] * ssOverage;
    
    HSV2RGB(hsvO, col);
    col[3] = hsvO[3];
    SetColor(pg, col);
    pg.rect(pos[POS_X] - szO*0.5, pos[POS_Y] - szO*0.5, szO, szO);
    
    HSV2RGB(hsvI, col);
    col[3] = hsvI[3];
    SetColor(pg, col);
    pg.rect(pos[POS_X] - szI*0.5, pos[POS_Y] - szI*0.5, szI, szI);
  }

};

SQ bq[];



void Init()
{
  bq = new SQ[fw*fh];
  
  for (int yy = 0; yy < fh; yy++)
  {
    for (int xx = 0; xx < fw; xx++)
    {
      int index = yy*fw+xx;
      bq[index] = new SQ((xx+0.5)*ss, (yy+0.5)*ss);
      
      if (index % 13 == 0)
      {
        bq[index].type = STING_LG;
      }
    }
  }
}
