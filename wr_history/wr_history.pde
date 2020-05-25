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

PFont f;

void setup() {
  size(1280, 720);
  //background(0, 255, 0);
 
  loadData();
  //println(wrsSeconds.get("2008-04-12"));
  
  points = new ArrayList();
  day = 0;
  f = createFont("Arial", 36, true);
}

void draw() {
  background(0, 255, 0);
  stroke(128);
  strokeWeight(1);
  line(0, height/2, width, height/2);
  line(width/2, 0, width/2, height);
  
  strokeWeight(5);
  stroke(2, 174, 238); // mkwii light blue
  
  // need to actually have it go down multiple times a day
  y = wrsSeconds.get(dates.get(day))[0] / 5;
  points.add(new Float[]{(float) width/2, (height-y)*3});
  
  int j = points.size();
  for (int i = 0; i < points.size()-2; i++) {
    line(points.get(i)[0]-j-1, points.get(i)[1], 
         points.get(i+1)[0]-j, points.get(i+1)[1]);
    j--;
  }
  
  strokeWeight(10);
  point(points.get(points.size()-1)[0], points.get(points.size()-1)[1]);

  // show date
  textFont(f);
  fill(0);
  text(dates.get(day), 20, 50);

  day++;
  
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
