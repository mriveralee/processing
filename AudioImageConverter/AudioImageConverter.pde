import processing.serial.*;
import java.*;

//Serial Reading
//Serial PORT;
//String PORT_NAME = "/dev/cu.usbserial-A10135GY";


//The WAV File to hide in an image
String INPUT_WAV_NAME = "input-wav/hello-16.wav";
String OUTPUT_WAV_NAME = "output-wav/hello-new.wav";
//WAV File Reader (Conversion to Image File)
PImage IMG_FROM_WAV;
BufferedReader WAV_READER;
int OUTPUT_WIDTH = 10; //255 max
int OUTPUT_HEIGHT = 10; //255 max
String OUTPUT_IMG_FILE;
//
String WAV_FILE_HEADER = "5249464624ec030057415645666d7420"
                        +"1000000001000100007d000000fa0000" 
                        +"020010006461746100ec0300";

//IMG File Reader
PrintWriter WAV_WRITER; //= createWriter("test.wav");
String IMG_OUTPUT_FILE = "wav2img/output.png";


//+Setup to record light sensor data
void setup() {
  size(OUTPUT_WIDTH, OUTPUT_HEIGHT, P2D);
   
   //Read Wav File and convert it to an image
   createImageFromWav(INPUT_WAV_NAME);

  //Writing a wav file from an image
  //WAV_WRITER = createWriter(IMG_OUTPUT_FILE);
  //createWAVFromImage();
  // IMG_WRITER = createWriter(IMG_OUTPUT_FILE);
}

void draw() {
  //Loop
}


  
//+Updates a pixel value using our algorithm
void updatePixel(int index, int value) {
  IMG_FROM_WAV.loadPixels();
  //int opacity =  int(random(0,256));
  IMG_FROM_WAV.pixels[index] = color(value*3, 1,1); // opacity);
  IMG_FROM_WAV.updatePixels();
  image(IMG_FROM_WAV, 0, 0);
}

/*+Save the current image being shown and save 
 * its filename in the files array 
 */
void saveImage() {
    PImage out = IMG_FROM_WAV.get();
    //out.save("output.jpg");
    String fileName = "output-"+str(round((random(970471))))+".png";
    saveFrame(fileName);
    println("Saved " + fileName + " in Sketch Folder.");
    //IMAGE_FILES.add(fileName);
   // IMAGE_FILES.add(0, fileName); 

//    println("Image is empty");
}


///////IMAGE READING for Playing Sounds
PImage PLAYING_IMAGE; 

//+Play a pixel as sound in an image 
void playImageIndex() {
   PLAYING_IMAGE.loadPixels();
   color[] PIX = PLAYING_IMAGE.pixels;
   //Access components for encoded data
    float f = red(PIX[1]);         //Frequency
    float x = green(PIX[1]);    //Next Pixel X
    float y = blue(PIX[1]);     //Next Pixel Y
    PLAYING_IMAGE.updatePixels();
    //Play the frequency tone using minim
     delay(1);
}


/*
WAVE-FILE Header
5249 4646 24ec 0300 5741 5645 666d 7420
1000 0000 0100 0100 007d 0000 00fa 0000
0200 1000 6461 7461 00ec 0300
*/

void readFile(String file) {
   String[] contents = loadStrings(file);
   String[] numbers = split(contents[0],' ');
   int[] data = int(numbers);
   //println(numbers);
   //println(convertToHexString(11) + convertToHexString(2));
   //println(convert8BitToHex(254));
   //println(convert8BitToHex(10));
   //println(convert16BitToHex(4692));
   //println(convert16BitToHex(20039));
   
   //Remove Wave header
   
   /*Take byte data -
  * Read hexNumber
  */
}
/// Create a image from a wav file
void createImageFromWav(String wavFile) {  
  ArrayList<String> hexChars = new ArrayList<String>();
   WAV_READER = createReader(wavFile);
  int count = 0;
  String c;
  try {

    do {
      c = WAV_READER.readLine();
      hexChars.add(c);
      //println(c);
      count++;
    } while (c != null);
  }
  catch (IOException e) {
    e.printStackTrace();
  }
  print(hexChars);
} 



///// READ IMAGE - CONVERT TO WAV
void createWAVFromImage() {
  println("WRITE FILE!");
  
    WAV_READER = createReader(INPUT_WAV_NAME);
  //ADD Wave HEADER

   //WAV_WRITER.print(0xFFF1);
   //WAV_WRITER.println("TEST APP");
  /*For each pixel[i], W/ RGB VALUES
   *R << 8 + G = 16bit number
   *Read 2 pixel values and get RG1, RG2
   *waveNum = (RG1 << 8) RG2 values
   *write(WaveNum + " ");
   */ 
   WAV_WRITER.flush();
   WAV_WRITER.close();
}




void makeImageFromWav(String wavFile) {
  String IMG_OUTPUT_FILE = "img2wav/output.png";
  //Wav REader;
  
  
  //= createWriter("test.wav");
  
  
  
//  //If we didn't get enough values do nothing;
//  if (AV_PLACE != AV_SIZE) return;
//  //Make an image from out analog values 
//  IMG_FROM_WAV.loadPixels();
//  for (int i = 0; i < IMG_FROM_WAV.pixels.length; i++) {
//    int value = ANALOG_VALUES[i];
//    IMG_FROM_WAV.pixels[i] = color(value*7, nextPixel.x, 0);
//  }
//  IMG_FROM_WAV.updatePixels();  
//}'
}




//+Takes a 16-bit int and converts it to a HEX string
String convert16BitToHex(int num) {
  if (0 > num || num >65535) return "";
  //Isolate first 4-bits (shift 
  String firstNum = convert8BitToHex((num & 0xFF00) >> 8);
  //Isolate second 4-bits
  String secondNum = convert8BitToHex(num & 0x00FF);
  //Result string is our firstNum appended w/ secondNum
  return firstNum + secondNum;
  
}

//+Takes a 8-bit int and converts it to a HEX string
String convert8BitToHex(int num) {
   if (0 > num || num > 255) return "";
  //Isolate first 4-bits (shift 
  String firstNum = convert4BitToHexString((num & 0xF0) >> 4);
  //Isolate second 4-bits
  String secondNum = convert4BitToHexString (num & 0x0F);
  
  //Result string is our firstNum appended w/ secondNum
  return firstNum + secondNum; 
}

//+Takes a 4-bit int and converts it to a HEX string
String convert4BitToHexString (int num) {
  if (0 > num || num > 15) return "";
  if (0 <= num && num < 10) return str(num);
  switch (num) {
    case 10: 
      return "a"; 
    case 11: 
      return "b"; 
    case 12: 
      return "c"; 
    case 13: 
      return "d"; 
    case 14: 
      return "e"; 
    case 15: 
      return "f"; 
    default:
      return "0";
  } 
}

//+Key Listeners
void keyPressed() {
  switch(key) {
   case ' ':
     //Do Nothing
     break;
  default: 
    //Do Nothing
    break;
  }
}
