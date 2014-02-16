import processing.serial.*;
//feedback loop
//Minim Audio
import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
//Sound Vars
Minim minim;
AudioOutput AUDIO_OUT;
SquareWave WAVE;

//Var for our Arduino Board
//Arduino arduino;
int SPEAKER_PIN = 7;            //Pin Location of the Speaker
int LIGHT_SENSOR_PIN = 20;      // Light Sensor Pin

//Serial Reading
Serial PORT;
String PORT_NAME = "/dev/tty.usbserial-A10135GY";

//Output image Vars
PImage OUTPUT_IMAGE;
int OUTPUT_WIDTH = 20; //255 max
int OUTPUT_HEIGHT = 20; //255 max

int[] ANALOG_VALUES;
int AV_SIZE = OUTPUT_WIDTH*OUTPUT_HEIGHT;
int AV_PLACE = 0;

//Output image 
ArrayList<String> IMAGE_FILES = new ArrayList<String>();

//Collection Vars
boolean hasData = false;
boolean hasPrintedArray = false;

//MODE
int APP_MODE = 0;
// 0 -> data collection
// 1 -> Play saved image (does nothing if no image is saved)

//Hashmap for mapping pixel coordinates to unique image locations
HashMap PixelLocations = new HashMap();
boolean isFirstPixel = true;
//Key: string for pixelLocation  str(pixelCoord);
//Value: 0 if no pixel has been placed || 1 if a pixel has been placed


//+Setup to record light sensor data
void setup() {
  //Init audio
  initAudio();
  
  resetImageData();
  size(OUTPUT_WIDTH, OUTPUT_HEIGHT, P2D);
  //Initialize Serial
  //println(Serial.list()); //Serial.list()[5]
  PORT = new Serial(this, PORT_NAME, 9600);   
}

//+ On App close, stop PORT reading
void stop() {
 //Close reading on the port
 PORT.stop(); 
}

//+Key Listeners
void keyPressed() {
  switch(key) {
   case ' ':
     //Toggle Data Collection
     toggleDataCollection();
     break;
  case 's':
     //Save Image
     saveImage();
     break;
  case 'r':  
    //Reset Image/Data
    resetImageData(); 
    break; 
  case 'p':
    togglePlayImageMode();
    break;
  default: 
    //Do Nothing
    break;
  }
}
//+=
void draw() {
 boolean hasSavedPixel = saveLightFromSerial();
 //println("Printed: " + hasPrintedArray + " savedPixel: " + hasSavedPixel + "AV_Place:" + AV_PLACE + "AV_SIZE: " + AV_SIZE); 
 if(APP_MODE == 0  && !hasPrintedArray && !hasSavedPixel && AV_PLACE == AV_SIZE-1) {
      printAllAnalogValues();
     // print("\nTHERE");
  }
  if (APP_MODE == 1) {
    if (!hasInitializedPlay) {
      //Initialize the play image image  
      initPlayImage();
    }
    else {
      playImageIndex();
    }
  } 
}


//+Prints all of the analog array data
void printAllAnalogValues() {
     hasPrintedArray = true;
     //println(ANALOG_VALUES);
     println(PixelLocations.size());
}

//+Gets an analog light reading and saves in the image
boolean saveLightFromSerial() {
    if (PORT.available() > 0 && AV_PLACE < AV_SIZE-1 && hasData) {
      //println("HERE: " + AV_PLACE);
      int analogValue = PORT.read();
      if (analogValue > 0) {
        //println(analogValue);
        //Add value to our array
        ANALOG_VALUES[AV_PLACE] = analogValue;
        int currPixelIndex = nextPixIndex;
        Point nextLocation = getNextPixelLocation();
        updatePixel(currPixelIndex, nextLocation, analogValue);
        //Increment our place in the array
        AV_PLACE++;
        //println("PORT with value: " + value);
        return true;
      }
    }
    return false;
}


//Vars for pixel locations
Integer ZERO = new Integer(0);
int nextPixIndex = 0;
Point nextPixCoords;
int pixCount = 0;

int getRandomX() {
  return int(random(0, OUTPUT_HEIGHT)); 
  
}
int getRandomY(){
  return int(random(0, OUTPUT_WIDTH));
}

//+Get the Next Valid pixel location to store in our array
Point getNextPixelLocation() {
  //Confirm that we've update the last pix valuedd
  int currPixIndex = nextPixIndex;
  PixelLocations.put(str(currPixIndex), new Integer(1));
  int x, y;
  String pixKey;
  do {
     x = getRandomX();
     y = getRandomY();
     nextPixIndex = getPixelIndexFromXY(x,y);
     pixKey = str(nextPixIndex);     
  } while (PixelLocations.get(pixKey) != null && PixelLocations.get(pixKey ) !=  ZERO);
 nextPixCoords = new Point(x, y);
 return nextPixCoords;
 //return nextPixIndex;
}
  
//+Updates a pixel value using our algorithm
void updatePixel(int index, Point nextPixel, int value) {
  OUTPUT_IMAGE.loadPixels();
  //int opacity =  int(random(0,256));
  OUTPUT_IMAGE.pixels[index] = color(value*3, nextPixel.x, nextPixel.y); // opacity);
  OUTPUT_IMAGE.updatePixels();
  if (index == 0) {
   checkArray = new int[] {value*3, nextPixel.x, nextPixel.y};
  }
  image(OUTPUT_IMAGE, 0, 0); 
  
  
  pixCount++; 
}

int[] checkArray;


//+Creates an image using all of the analog light values
//void createImageFromAnalogValues() {
//  //If we didn't get enough values do nothing;
//  if (AV_PLACE != AV_SIZE) return;
//  //Make an image from out analog values 
//  OUTPUT_IMAGE.loadPixels();
//  for (int i = 0; i < OUTPUT_IMAGE.pixels.length; i++) {
//    int value = ANALOG_VALUES[i];
//    OUTPUT_IMAGE.pixels[i] = color(value*7, nextPixel.x, 0);
//  }
//  OUTPUT_IMAGE.updatePixels();  
//}

/*+Save the current image being shown and save 
 * its filename in the files array 
 */
void saveImage() {
  if (AV_PLACE > 0) {
    PImage out = OUTPUT_IMAGE.get();
    //out.save("output.jpg");
    String fileName = "output-"+str(round((random(970471))))+".png";
    saveFrame(fileName);
    println("Saved " + fileName + " in Sketch Folder.");
    //IMAGE_FILES.add(fileName);
    IMAGE_FILES.add(0, fileName); 
  }
  else {
    println("Image is empty");
  }
}


//+Resets the image collection
void resetImageData() {
  //Init array for holding analog values
  ANALOG_VALUES = new int[AV_SIZE];
  //Output Display Image
  OUTPUT_IMAGE = new PImage(OUTPUT_WIDTH, OUTPUT_HEIGHT, RGB);
  //Show the image (black at start)
  image(OUTPUT_IMAGE, 0, 0);
  //Place in Analog_Values array - where we store the next 'light' value
  AV_PLACE = 0;
  //Tells us not to collect data until the user presses the the spacebar
  hasData = false;
  hasPrintedArray = false;
  //image(OUTPUT_IMAGE,0,0);
  
  PixelLocations = new HashMap();
  isFirstPixel = true;
  nextPixIndex = 0;
  //Clear out pixels
   OUTPUT_IMAGE.loadPixels();
   for (int i = 0; i < OUTPUT_WIDTH*OUTPUT_HEIGHT; i++) {
     OUTPUT_IMAGE.pixels[i] = color(0,0,0,0);
   }
   OUTPUT_IMAGE.updatePixels();
  
  
  
}

//+Toggle Data collection in the image making process
void toggleDataCollection() {
    hasData = !hasData;
    println("Data Collection: " + hasData);
}



///////IMAGE READING for Playing Sounds
PImage PLAYING_IMAGE; 
int playingIndex;
boolean hasInitializedPlay = false;
int MAX_PLAY_COUNT;
int PLAY_COUNT;
color[] PLAY_COLORS;
int[] loadLight = new int[OUTPUT_WIDTH*OUTPUT_HEIGHT];

//+ Start Playback of an image
void initPlayImage() {
 if (IMAGE_FILES.size() == 0) return; 
   //println(IMAGE_FILES);
   //println(IMAGE_FILES.size());
   //Initialize Audio
   
   //Get first image
   PLAYING_IMAGE = loadImage(IMAGE_FILES.get(0));
   playingIndex = 0;
   hasInitializedPlay = true;
   MAX_PLAY_COUNT = PLAYING_IMAGE.width * PLAYING_IMAGE.height;
   PLAY_COUNT = 0;
   //println("MAX_PC: "+MAX_PLAY_COUNT);
   //Load pixel colors
   PLAYING_IMAGE.loadPixels();
   PLAY_COLORS = PLAYING_IMAGE.pixels; 
   PLAYING_IMAGE.updatePixels();
 //println(PixelLocations);
}

//+Play a pixel as sound in an image 
void playImageIndex() {
 if (PLAY_COUNT >= MAX_PLAY_COUNT) { 
    //while(true);
    //Verify Values
    for (int i =0; i < loadLight.length; i++) {
      if (loadLight[i] != 3*ANALOG_VALUES[i]) {
       println("Loaded:" + loadLight[i] + " != "+ANALOG_VALUES[i]);
      }
    }
    println("FINISHED Reading back");
    togglePlayImageMode();
    return;
 } else {
   PLAYING_IMAGE.loadPixels();
   //Access components for encoded data
    float f = red(PLAY_COLORS[playingIndex]);          //Frequency
    float x = green(PLAY_COLORS[playingIndex]);        //Next Pixel X
    float y =blue(PLAY_COLORS[playingIndex]);          //Next Pixel Y
    
    //Store in Loaded Light Array for comparison
    loadLight[PLAY_COUNT] = int(f);
    //Increment Play Count
    PLAY_COUNT++;
    //Set up to play the next tone 
    playingIndex = int(x) + int(y)*OUTPUT_WIDTH; 
    
    //Play the frequency tone using minim
     updateFrequency(int(f));
     delay(1);
     //Test for first number working
//    if (PLAY_COUNT == 0) {
//      println(checkArray);
//      println("f: " + f+ " x:" +x + " y:" + y + " a:"+a);
//    }
 }
}
//+Toggles whether or not to playback an image
void togglePlayImageMode() {
  APP_MODE = abs(APP_MODE-1);
  if (APP_MODE == 0) {
    hasInitializedPlay = false;
  }
  println("PlayMode: "+APP_MODE);
}

void initAudio() {
  minim = new Minim(this);
  AUDIO_OUT = minim.getLineOut();
  
  // create a SquareWave with a frequency of 440 Hz, 
  // an amplitude of 1 and the same sample rate as out
  WAVE = new SquareWave(0, 1, 9600);
  AUDIO_OUT.addSignal(WAVE);
}

void updateFrequency(int f) {
   WAVE.setFreq(f); 
}

//Private Inner Class for passing points around
private class Point {
  public int x;
  public int y;
  
  Point(int xCoord, int yCoord) {
    x = xCoord;
    y = yCoord;
  }
  public int getIndex() {
    //+Returns the 1D arry mapping for a pixel location in a two 2D array
    return x + y*OUTPUT_WIDTH;
  }
}

//------ 2D-to-1D Mapping functions -----//
//+Returns the 1D arry mapping for a pixel location in a two 2D array
int getPixelIndexFromXY(int x, int y) {
  return x + y*OUTPUT_WIDTH;
}

//+Gets an X-coordinate from a pixel Index
int getPixelXFromIndex(int index) {
  return index%OUTPUT_WIDTH;
}

//+Gets a Y-coordinate from a pixel Index
int getPixelYFromIndex(int index) {
  int pixelX = getPixelXFromIndex(index);
  return (index-pixelX)/OUTPUT_WIDTH;
}
