import java.util.Arrays;

JSONObject jsonWRs;
JSONObject jsonSeconds;
JSONObject datesJSON;
ArrayList<String> dates;
HashMap<String, String[]> wrs;
HashMap<String, Float[]> wrsSeconds;

int limit;
float x, y;
ArrayList<Float[]> points;

int day;
ArrayList<Float> dayTimes;

PFont f;
float diffSecs; // used for the time text on the side

float scaler; // used to scale the data
float pixelsForDay;

void setup() {
  size(1280, 720);
  //background(0, 255, 0);
 
  loadData();
  //println(wrsSeconds.get("2008-04-12"));
  diffSecs = 0;
  points = new ArrayList();
  day = 0;
  dayTimes = new ArrayList<Float>(Arrays.asList(wrsSeconds.get(dates.get(day))));
  f = createFont("Arial", 36, true);
  
  scaler = 1;
  pixelsForDay = 100;
}
// TODO: sort out horizontal intervals, theyre not consistent with days
// this will be a problem when trying to draw vertical lines
void draw() {
  // DO COOL PANOUT AT END POG
  background(0, 255, 0);
  
  drawAxes();
  
  stroke(2, 174, 238); // mkwii light blue
  strokeWeight(15);
  
  //println(dayTimes.get(0));
  y = dayTimes.get(0) * scaler;
  points.add(new Float[]{(float) day, y}); // raw curr point
  point(width/2, height/2);
  
  strokeWeight(6);
  
  if (points.size() > 1) {
    // value to know how much to move up previous days data points
    diffSecs += points.get(points.size()-2)[1] - points.get(points.size()-1)[1];
    
    // always plot current at centre
    float currX = width/2;
    float currY = height/2;
    
    // move previous one left by however many pixels we want to represent a day
    float prevX;
    
    // if they're on the same day
    if (points.get(points.size()-2)[0] == points.get(points.size()-1)[0]) {
      prevX = width/2 - (pixelsForDay / points.size());
    } else { // if they're on different days
      prevX = width/2 - pixelsForDay;
    }
    
    // calc how far to move previous one up
    float prevY = currY - (points.get(points.size()-2)[1] - points.get(points.size()-1)[1]);
    
    line(prevX, prevY, currX, currY);
    
    // gonna use that when moving it back
    float j = pixelsForDay;
    // now can not care about plotting at centre
    for (int i=points.size()-2; i > 0; i--) {
        
      prevX = width/2 - j - pixelsForDay;
      prevY = prevY - (points.get(i-1)[1] - points.get(i)[1]);
      currX = width/2 - j;
      currY = currY - (points.get(i)[1] - points.get(i+1)[1]);
        
      //if ((points.get(i+1)[1] - floor(points.get(i+1)[1])) < .005) {
      //  text(floor(points.get(i+1)[1]), 20, currY);
      //}
        
        
      line(prevX, prevY, currX, currY);
      j += pixelsForDay;
    }
  }
  
  //println(points.get(0)[1]);
  // 3714.051
  // day 1: 1:01:54.051

  // show date
  textFont(f);
  fill(0);
  String date = dates.get(day);
  text(date, 20, 50);
  
  if (dayTimes.size() > 1) {
    dayTimes.remove(0);
  } else {
    day++;
    dayTimes = new ArrayList<Float>(Arrays.asList(wrsSeconds.get(dates.get(day))));
  }
  
  delay(500);
}

void drawAxes() {
  // stroke settings
  stroke(128);
  strokeWeight(1);
  
  // first cumulative time, right at the top baybee
  text("61'54\"051", 20, height/2 - diffSecs);
  line(0, height/2 - diffSecs, width, height/2 - diffSecs);
  
  int firstTime = 3660; // 3714.051 secs
  int interval = 120; // the gaps between the lines on the axis
  
  // need to move all lines up every frame
  // could make more efficient by only moving the ones on/near the screen but w/e
  // 100 for one hundred lines baybee
  for (int i=0; i<100; i++) {
    int time = firstTime - (interval*i); // this is just to display the time as text
    
    // yLine is actually the y-pos value
    // move up by diffSecs, adding the intervals
    // and adding the offset to round numbers (offset from the first cumulative time)
    float yLine = height/2 - diffSecs + (54.051*scaler) + (interval*scaler*i);
    
    // display text and draw line
    text(String.format("%d'%d\"000", floor(time/60), time % 60),
          20, yLine);
    line(0, yLine, width, yLine);
  }
}


void loadData() {
  jsonWRs = loadJSONObject("wrs.json"); // load in json
  jsonSeconds = loadJSONObject("wrs_secs.json");
  datesJSON = loadJSONObject("dates.json");
  dates = new ArrayList<String>();
  wrs = new HashMap<String, String[]>();
  wrsSeconds = new HashMap<String, Float[]>();
  
  for (int i = 0; i < datesJSON.size(); i++) {
    String iStr = Integer.toString(i);
    String currDate = datesJSON.getString(iStr);
    dates.add(currDate); // why
    
    JSONArray currTimesJSON = jsonWRs.getJSONArray(currDate);
    String[] currTimes = currTimesJSON.getStringArray();
    wrs.put(currDate, currTimes);
    
    currTimesJSON = jsonSeconds.getJSONArray(currDate);
    String[] secsStrs = currTimesJSON.getStringArray();
    Float[] secsFloats = new Float[secsStrs.length];
    for (int j = 0; j < secsStrs.length; j++) {
      secsFloats[j] = Float.parseFloat(secsStrs[j]);
    }
    
    wrsSeconds.put(currDate, secsFloats);
  }
}
