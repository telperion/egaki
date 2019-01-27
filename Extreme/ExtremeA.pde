// Static background
final int TSTAT_NOP = 0;
final int TSTAT_APP = 1;
final int TSTAT_PPP = 2;
final int TSTAT_DAP = 3;
final int TSTAT_MAX = 4;

final int frameRateDesired = 60;
final int sw = 960;
final int sh = 540;
final int ss = 20;
final float sp = 0.7;

final float[] c0 = {0.700, 0.100, 0.100};  // HSV of lower bound color
final float[] c1 = {0.500, 0.800, 0.700};  // HSV of upper bound color
final float bgStrength = 0.1;

final float[] plDefaults = {1.0, 2.0, 4.0, 5.0};
final float plLoop = 12.0;

final float scrollSpeed = 0.75;             // squares per second 
  
class SQ
{
  public float x;     // Center location X in pixels
  public float y;     // Center location Y in pixels
  public float cc;    // Color selection for square, [0, 1] (not used yet)
  public float tf;    // Time offset forward through tween phases in seconds
  public float pl[];  // Tween phase lengths in seconds
  
  SQ()
  {
    x = 0.0;
    y = 0.0;
    cc = 0.0;
    tf = random(plLoop);
    pl = new float[TSTAT_MAX];
    for (int i = 0; i < TSTAT_MAX; i++)
    {
      pl[i] = plDefaults[i];
    }
  }
  
  SQ(float xx, float yy)
  {
    x = xx;
    y = yy;
    cc = 0.0;
    tf = random(plLoop);
    pl = new float[TSTAT_MAX];
    for (int i = 0; i < TSTAT_MAX; i++)
    {
      pl[i] = plDefaults[i];
    }
  }  
};

final int fw = sw/ss;
final int fh = sh/ss;

SQ bq[];


final float strokeStrength = 0.8;
void ChooseColor(SQ sq, float colorStrength, float alpha)
{
  float[] hsv = new float[3];
  float[] rgb = new float[3];
  
  for (int i = 0; i < 3; i++)
  {
    hsv[i] = c0[i]*(1.0 - colorStrength) + c1[i]*(colorStrength);
  }
  
  // Fill color
  HSV2RGB(hsv, rgb);  
  fill(
    int(255*rgb[0]),
    int(255*rgb[1]),
    int(255*rgb[2]),
    int(255*alpha)
    );
  
  // Stroke color - lighter ver. of fill color
  for (int i = 0; i < 3; i++)
  {
    //rgb[i] = 1.0 - (1.0 - rgb[i])*strokeStrength;
    rgb[i] = rgb[i]*strokeStrength;
  }
  stroke(
    int(255*rgb[0]),
    int(255*rgb[1]),
    int(255*rgb[2]),
    int(255*(1.0 - (1.0 - alpha)*strokeStrength))
    );
}

void Init()
{
  bq = new SQ[fw*fh];
  
  for (int yy = 0; yy < fh; yy++)
  {
    for (int xx = 0; xx < fw; xx++)
    {
      int index = yy*fw+xx;
      bq[index] = new SQ((xx+0.5)*ss, (yy+0.5)*ss);
    }
  }
}

void GetTweenTime(SQ sq, float t, float[] tweenInfo)
{  
  // tweenInfo[0] = tween phase
  // tweenInfo[1] = tween progress
  
  float tEnd = 0;
  float endTimes[] = new float[TSTAT_MAX+1]; 
  endTimes[0] = 0;
  for (int i = 1; i <= TSTAT_MAX; i++)
  {
    tEnd += sq.pl[i-1]; 
    endTimes[i] = tEnd;
  }
  t = (t + sq.tf) % endTimes[TSTAT_MAX];
  for (int i = 1; i <= TSTAT_MAX; i++)
  {
    if (t < endTimes[i])
    {      
      tweenInfo[0] = i-1;
      tweenInfo[1] = (t - endTimes[i-1])/(endTimes[i] - endTimes[i-1]);
      break;
    }
  }
  
}

void DrawSQ(SQ sq, float t, int extra)
{
  float tweenInfo[] = new float[2];
  GetTweenTime(sq, t, tweenInfo);
  //print(String.format("sq (x = %8.3f, y = %8.3f): phase = %2.1f, time = %8.3f\n", sq.x, sq.y, tweenInfo[0], tweenInfo[1]));
  
  float q0, q1, sz;
  
  float shiftX = sq.x;
  float shiftY = sh - ((sh*(1+extra) + sq.y + ss*scrollSpeed*t) % (2*sh) - sh*0.5);
  
  switch(int(tweenInfo[0]))
  {
    case TSTAT_NOP:
      // Do nothing.
    break;
    case TSTAT_APP:
      //print(String.format("sq (x = %8.3f, y = %8.3f): phase = APP\n", sq.x, sq.y));
      q0 = 1.0 - tweenInfo[1];
      q1 = 1.0 - q0*q0;
      sz = ss * q1 * sp;
      
      ChooseColor(sq, q1*(1.0-bgStrength) + bgStrength, q1); 
      rect(shiftX - sz*0.5, shiftY - sz*0.5, sz, sz);
    break;
    case TSTAT_PPP:
      //print(String.format("sq (x = %8.3f, y = %8.3f): phase = PPP\n", sq.x, sq.y));
      q0 = tweenInfo[1];
      q1 = q0*q0;
      sz = ss * sp;
      
      ChooseColor(sq, 1.0 - q0, 1.0); 
      rect(shiftX - sz*0.5, shiftY - sz*0.5, sz, sz);
    break;
    case TSTAT_DAP:
      //print(String.format("sq (x = %8.3f, y = %8.3f): phase = DAP\n", sq.x, sq.y));
      q0 = tweenInfo[1];
      q1 = 1.0 - q0*q0;
      sz = ss * (1.0 - q1 * (1.0-sp));
      
      ChooseColor(sq, (1.0-q1)*bgStrength, q1); 
      rect(shiftX - sz*0.5, shiftY - sz*0.5, sz, sz);
    break;
    default:
      // Do nothing.
  }
}
