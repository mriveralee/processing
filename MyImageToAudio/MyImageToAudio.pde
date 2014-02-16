import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

import ddf.minim.*;

Minim minim;
AudioSample kick;
AudioSample snare;

//--Global Variables------------------------------
//Playback Conditions
boolean isPaused = false;
int playDelay = 195;
int playID = 0;
//Image Information
PImage image;
String imageName = "charlie.jpg"; 
//String imageName = "zebra.jpg"; 
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
  if (playID % 200 == 0) println(playID);
  println(pixColor.length);
  if(playID >= pixColor.length) {
    playID = 0;
    exit();
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

