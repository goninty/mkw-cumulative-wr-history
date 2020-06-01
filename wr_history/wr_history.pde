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
}

void draw() {
  // DO COOL PANOUT AT END POG
  background(0, 255, 0);
  stroke(128);
  strokeWeight(1);
  //line(0, height/2, width, height/2);
  //line(width/2, 0, width/2, height);
  
  int firstTime = 3660; // 3714.051 secs
  int interval = 120;
  for (int i=0; i<100; i++) {
    int time = firstTime - (interval*i);
    float yLine = height/2 - diffSecs + 54.051 + (interval*i);
    text(String.format("%d'%d\"000", floor(time/60), time % 60),
          20, yLine);
    line(0, yLine, width, yLine);
  }
  text("61'54\"051", 20, height/2 - diffSecs);
  line(0, height/2 - diffSecs, width, height/2 - diffSecs);
  
  stroke(2, 174, 238); // mkwii light blue
  strokeWeight(15);
  
  // need to actually have it go down multiple times a day
  
  //println(dayTimes.get(0));
  y = dayTimes.get(0);
  points.add(new Float[]{(float) day, y}); // raw curr point
  point(width/2, height/2);
  
  strokeWeight(6);
  
  if (day == 0) {
    point(width/2, height/2);
  } else {
    float currX = width/2;
    float currY = height/2;
    float prevX = width/2 - 1;
    float prevY = currY - (points.get(points.size()-2)[1] - points.get(points.size()-1)[1]);
    diffSecs += points.get(points.size()-2)[1] - points.get(points.size()-1)[1];
    
    line(prevX, prevY, currX, currY);
    
    // gonna use that when moving it back
    int j = 0;
    // now can not care about plotting at centre
    for (int i=points.size()-2; i > 0; i--) {
      
      prevX = width/2 - j - 1;
      prevY = prevY - (points.get(i-1)[1] - points.get(i)[1]);
      currX = width/2 - j;
      currY = currY - (points.get(i)[1] - points.get(i+1)[1]);
      
      //if ((points.get(i+1)[1] - floor(points.get(i+1)[1])) < .005) {
      //  text(floor(points.get(i+1)[1]), 20, currY);
      //}
      
      
      line(prevX, prevY, currX, currY);
      j++;
    }
  }
  println(points.get(0)[1]);
  // 3714.051
  // day 1: 1:01:54.051

  // show date
  textFont(f);
  fill(0);
  String date = dates.get(day);
  text(date, 20, 50);
  //text(wrsSeconds.get(dates.get(0))[0] - diffSecs, 40, 100);
  //text(wrs.get(date)[0], 20, height/2);
  
  if (dayTimes.size() > 1) {
    dayTimes.remove(0);
  } else {
    day++;
    dayTimes = new ArrayList<Float>(Arrays.asList(wrsSeconds.get(dates.get(day))));
  }
  //delay(50);
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
