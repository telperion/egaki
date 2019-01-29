// Stinger variant

final int STING_SM = 0;   // Indicates subreaders
final int STING_LG = 1;   // Indicates leaders

final int PHASE_NOP = 0;  // Nothing is happening
final int PHASE_LAP = 1;  // Leaders appearing
final int PHASE_SRP = 2;  // Leaders filling, Subreaders appearing
final int PHASE_SFC = 3;  // Subreaders filling, leaders clearing
final int PHASE_OUT = 4;  // Subreaders clearing
final int PHASE_MAX = 5;

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
final float spt = 0.15;     // Subreaders spawn in this much time; last subreader starts to spawn at 1-spt
final float ssOverage = 1.001;  // Overdraw squares just a bit to make sure there are no spoopy gaps

final int fw = sw/ss;
final int fh = sh/ss;

final float[] c0 = {0.350, 0.300, 0.100};  // HSV of lower bound color
final float[] c1 = {0.180, 1.000, 0.700};  // HSV of upper bound color
final float leaderCol = 0.3;               // The nearest that leaders get to the lower bound color
final float subreaderCol = 0.7;            // The nearest that leaders get to the upper bound color
final float bgStrength = 0.1;

final float[] plDefaults = {0.0, 0.3, 1.1, 0.7, 1.4};
final float plLoop = 3.5;

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
  public int spLink;  // Spawn parent (used for subreaders; not needed/implemented yet)
    
  SQ()
  {
    x = 0.0;
    y = 0.0;
    type = STING_SM;
    ccI = leaderCol + random(1 - leaderCol);
    ccO = ccI / 2;
    spOff = random(1);
    spLink = -1;
  }
  
  SQ(float xx, float yy)
  {
    x = xx;
    y = yy;
    type = STING_SM;
    ccI = leaderCol + random(1 - leaderCol);
    ccO = ccI / 2;
    spOff = random(1);
    spLink = -1;
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
        hsvO[i] = c0[i]*(1.0 - ccO*subreaderCol) + c1[i]*(ccO*subreaderCol);
        hsvI[i] = c0[i]*(1.0 - ccI*subreaderCol) + c1[i]*(ccI*subreaderCol);
      }
    }
    hsvO[3] = 0;
    hsvI[3] = 0;
    if (type == STING_SM)
    {
      hsvO[1] *= 0.5;
      hsvO[2] *= 0.5;
      hsvI[1] *= 1.0;
      hsvI[2] *= 0.7;
    }
        
    float tOff = (tt - (1-spt)*spOff)/spt;
    tOff = (tOff > 1) ? 1 : (tOff < 0) ? 0 : tOff;
    
    switch (phase)
    {
      case PHASE_NOP:
        // Do nothing.
      break;
      case PHASE_LAP:
        if (type == STING_LG)
        {
          hsvO[3] = tt;
        }
      break;
      case PHASE_SRP:
        if (type == STING_LG)
        {
          hsvO[3] = 1;
          hsvI[3] = (2-tt)*tt;
        }
        else
        {
          hsvO[3] = tOff;
        }
      break;
      case PHASE_SFC:
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
        
    float tOff = (tt - (1-spt)*spOff)/spt;
    tOff = (tOff > 1) ? 1 : (tOff < 0) ? 0 : tOff;
    float tOff2 = (tt - (1-spt*2)*spOff)/(spt*2);
    tOff2 = (tOff2 > 1) ? 1 : (tOff2 < 0) ? 0 : tOff2;
          
    switch (phase)
    {
      case PHASE_NOP:
        // Do nothing.
      break;
      case PHASE_LAP:
        if (type == STING_LG)
        {
          pos[POS_Y ] = y; //+ ss*(1-outBack(tt, 0.5));
          pos[POS_S1] = outBack(tt, 0.5);
        }
        // Subreaders do nothing here
      break;
      case PHASE_SRP:
        if (type == STING_LG)
        {
          pos[POS_S1] = 1;
          pos[POS_S2] = tt*tt;
        }
        else
        {
          pos[POS_Y ] = y - 2*ss*(1-outBack(tOff2, 0.7));
          pos[POS_S1] = tOff*(2-tOff);
        }
      break;
      case PHASE_SFC:
        if (type == STING_SM)
        {
          pos[POS_S1] = 1;
          pos[POS_S2] = tOff*tOff;
        }
        else
        {
          pos[POS_S1] = 1;
          pos[POS_S2] = 1;
        }
      break;
      case PHASE_OUT:
        pos[POS_Y ] = y + 2*ss*(1-outBack(1-tOff2, 0.7));
        pos[POS_S1] = (tOff-1)*(tOff-1);
        pos[POS_S2] = (tOff-1)*(tOff-1);
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


final float leaderRate = sqrt(fw*fh)/2;
final float minLeadRate = 0.3;

void Init()
{
  bq = new SQ[fw*fh];
  
  for (int yy = 0; yy < fh; yy++)
  {
    for (int xx = 0; xx < fw; xx++)
    {
      int index = yy*fw+xx;
      bq[index] = new SQ((xx+0.5)*ss, (yy+0.5)*ss);
      bq[index].spOff = 1;
    }
  }
  
  int indLead = int(leaderRate * (minLeadRate + random(1-minLeadRate)));
  while (indLead < fw*fh)
  {
    bq[indLead].type = STING_LG;
    
    int ri = indLead / fw;
    int ci = indLead % fw; 
    for (int trackback = 0; trackback < fw; trackback++)
    {
      float newSpawn = float(trackback)/leaderRate;
      if (ci-trackback >= 0)
      {
        int indRev = ri*fw + ci-trackback;
        bq[indRev].spOff = (bq[indRev].spOff > newSpawn) ? newSpawn: bq[indRev].spOff;
      }
      if (ci+trackback < fw)
      {
        int indRev = ri*fw + ci+trackback;
        bq[indRev].spOff = (bq[indRev].spOff > newSpawn) ? newSpawn: bq[indRev].spOff;
      }
    }
    
    indLead += int(leaderRate * (minLeadRate + random(1-minLeadRate)));
  }
}
