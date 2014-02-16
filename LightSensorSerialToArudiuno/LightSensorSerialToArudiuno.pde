//Minim Audio
import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

//Arduino
import cc.arduino.*;

//Var for our Arduino Board
Arduino arduino;
int SPEAKER_PIN = 7;            //Pin Location of the Speaker
int LIGHT_SENSOR_PIN = 206;      // Light Sensor Pin

//Serial Reading
import processing.serial.*;
Serial PORT;

String PORT_NAME = "/dev/cu.usbserial-A10135GY";
int[] ANALOG_VALUES;
int AV_SIZE = 100;
int AV_PLACE = 0;


//Sound Vars
Minim minim;


//Output image Vars
String imageName = "output.jpeg";
PImage OUTPUT_IMAGE;
int OUTPUT_WIDTH = 10;
int OUTPUT_HEIGHT = 10;


//Initialize serial
//Intialize output image w/ size widthxheight
//for i: 0->widthxheight
 /* lightValue <- read from serial
  * pixelColor <- map the value to pixel colors
  * store Pixel colors in image
  */
//Show Image when finished;

//Write algorithm to decode image file
  /* read image
   * for each pixel in image
   **play sound from pixel colors
   */
   //stop.



void setup() {
//  Init arduino Connection
//  println("COM Ports");
    println(Arduino.list());
//  println("=========");
  
  arduino = new Arduino(this, Arduino.list()[5], 9600);

  arduino.pinMode(LIGHT_SENSOR_PIN, Arduino.INPUT);
  
  //Initialize Serial
  //PORT = new Serial(this, PORT_NAME, 9600); 
  ANALOG_VALUES = new int[AV_SIZE];
  
  //Create Output Image
  OUTPUT_IMAGE = new PImage(OUTPUT_WIDTH, OUTPUT_HEIGHT, RGB);
  
  //Size of image view window
  size(OUTPUT_WIDTH, OUTPUT_HEIGHT, P3D);
}

void stop() {
 //Close reading on the port
 PORT.stop(); 
}


boolean hasPrintedArray = false;

void draw() {
  //Is our port available for reading? & do we have storage space for it
 /* if (AV_PLACE < AV_SIZE) {
    int analogValue = arduino.analogRead(LIGHT_SENSOR_PIN);
    println(analogValue);
    ANALOG_VALUES[AV_PLACE] = analogValue;
    AV_PLACE++;
  }
  */

  if (PORT.available() > 0 && AV_PLACE < AV_SIZE) {
    int analogValue = PORT.read();
    
    //Add value to our array
    ANALOG_VALUES[AV_PLACE] = analogValue;
    
    //Increment our place in the array
    AV_PLACE++;
    //println("PORT with value: " + value);
  }
  
  else {
    //Print out all values in the array 
   if (AV_PLACE == AV_SIZE && !hasPrintedArray) {
     println(ANALOG_VALUES);
     hasPrintedArray = true;
   }
   createImageFromAnalogValues();
   image(OUTPUT_IMAGE, 0, 0);
  }   
}


void createImageFromAnalogValues() {
  //If we didn't get enough values do nothing;
  if (AV_PLACE != AV_SIZE) 
    return;
 
  //Else make an image from out analog values 
  OUTPUT_IMAGE.loadPixels();
   for (int i = 0; i < OUTPUT_IMAGE.pixels.length; i++) {
     int value = ANALOG_VALUES[i];
     OUTPUT_IMAGE.pixels[i] = color(value*7, 50, 0);
   }
   OUTPUT_IMAGE.updatePixels();  
}






/*
//--Global Variables------------------------------
//Playback Conditions
boolean isPaused = false;
int playDelay = 195;
int playID = 0;
//Image Information
PImage image;
//String imageName = "charlie.jpg"; 
String imageName = "zebra.jpg"; 
int WIDTH;
int HEIGHT;
int[] pixColor;

//Sound Information
String soundDir = "audio/harp/";
int numSounds = 34;//
AudioSample[] sounds = new AudioSample[numSounds];
int startSound = 18;

//-------------------------------------------------
void setup()
{
  if (imageName.equals("charlie.jpg")){
    WIDTH = 300;
    HEIGHT = 363;
  }
  else if (imageName.equals("zebra.jpg")) {
    WIDTH = 300;
    HEIGHT = 181;
  }
  size(WIDTH, HEIGHT, P3D);
  minim = new Minim(this);
  
  //Load Image
   initImage();
   initSounds();
}

void draw()
{
  background(0);
  stroke(255);
  image(image,0,0,WIDTH,HEIGHT);
  //Play our sounds
  if (!isPaused) {
    playImageSound();
  }
}



//Initialize Image
void initImage() {  
  image = loadImage(imageName);
  loadPixels();
  image.loadPixels();
  //Set up sound to intensity index array 
  pixColor = new int[image.pixels.length];
  for (int i = 0; i < image.pixels.length; i++) {
    color c = image.pixels[i];
    pixColor[i] = round(hue(c)+saturation(c)+brightness(c)+3)%30;
  }
 // println("HERE");
  
}

//Initialize sounds
void initSounds() {
  for (int i = 0; i < numSounds; i++) {
    String soundLoc;
    if (startSound < 10) {
     soundLoc = soundDir+"harp_0"+startSound+".mp3";
    }
    else { 
      soundLoc = soundDir+"harp_"+startSound+".mp3"; 
    }
    //Load sound
    sounds[i] = minim.loadSample(soundLoc, 512);
    if (sounds[i] == null) println("Didn't get the "+i+"th sound!");
    startSound++;
  }
}

void playImageSound() {
  sounds[pixColor[playID]].trigger();
  playID++;
  if(playID >= pixColor.length) {
    playID = 0;
  }
  delay(playDelay);
}

//Key Listeners
void keyPressed() 
{
  if (key == 'p') isPaused = !isPaused;
  if (key == 'r') playID = 0;
}


  // An AudioSample will spawn its own audio processing Thread, 
  // and since audio processing works by generating one buffer 
  // of samples at a time, we can specify how big we want that
  // buffer to be in the call to loadSample. 
  // above, we requested a buffer size of 512 because 
  // this will make the triggering of the samples sound more responsive.
  // on some systems, this might be too small and the audio 
  // will sound corrupted, in that case, you can just increase
  // the buffer size                                                                                                                                                                                                                                                                                                                                                                              
*/
