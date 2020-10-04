
import processing.video.*;
Capture cam;
PImage webcamCropped;
PImage webcamCroppedEffect ;
int webcamX = 320;   //using 320 x 240  ,default is 1920
int webcamY = 240;   //using 320 x 240  ,default is 1080
int webcamCroppedSizeX = 200;
int webcamCroppedSizeY = 170;
//for slit scan parameters



int screenSizeX = 128;
int screenSizeY = 48;
int panelSizeX =32;
int panelSizeY = 16;
// Timer 
int timer; 
int timer2;
int timer3;
int timerWebcamMode;
int drawlineCounter;

int leftScreenResetCounter = 0;
int rightScreenResetCounter = 0;
int dotDisplayintervalLeftScreen = 7031;   //7031ms per pixels x 512 pixels = 3600 seconds , 
int dotDisplayintervalRightScreen = 1000;



// WORM mode dot cell on Screen 1
// Array of cells
int cellSize = 1;
int[][] cells = new int[panelSizeX/cellSize][panelSizeY/cellSize];
int[][] cells2 = new int[panelSizeX/cellSize][panelSizeY/cellSize];
// Buffer to record the state of the cells and use this while changing the others in the interations
int[][] cellsBuffer;  
// take refeence to https://processing.org/examples/gameoflife.html 
int cellsOrder = 0; 
int LeftScreenCellDrawingCountX=0;
int LeftScreenCellDrawingCountY=0;
int LeftScreenCellDrawingCounter=0;

int RightScreenCellDrawingCountX=0;
int RightScreenCellDrawingCountY=0;
int RightScreenCellDrawingCounter=0;

int cellDrawingCountX=0;
int cellDrawingCountY=0;
// END WORM MODE dot cell on Screen 1


//Screen Initialization
int LeftScreenPositionX=96;
int LeftScreenPositionY=0;

int RightScreenPositionX=96;
int RightScreenPositionY=32;

int MidScreenPositionX=64;
int MidScreenPositionY=16;

color BgLeftScreen = color(0);
color BgRightScreen = color(255, 0, 0, 255);   //Red
int resetStepDrawPixelArrayInOrderRightScreen=0;

//Webcam Mode on middle screen
boolean webcamMode = true ; 
boolean webcamTHreshold = false;
boolean lineMode = false ; 
float threshold = 150;
color thresholdColor = color(255, 180, 105);
int webcamModeCounter = 0;

void setup() {

  //fullScreen();
  size(640, 480);  //must hardcode to set the screen size
  background(0);
  noSmooth();
  surface.setResizable(false);
  surface.setTitle("P07 LED Clock!");
  surface.setLocation(-3, 566); //sketch screen location
  noCursor();
  frameRate(60);


  /* ==== WEBCAM initialization  ==== */
  WebcamInit();

  //Initialize the background
  SetBackground();



  // Cells Instantiate arrays 

  //cellsBuffer = new int[panelSizeX/cellSize][panelSizeY/cellSize];


  for (int x=0; x<panelSizeX/cellSize; x++) {
    for (int y=0; y<panelSizeY/cellSize; y++) {
      cells[x][y] = cellsOrder++; // Save state of each cell
      cells2[x][y] = cells[x][y]; // Save state of each cell
      //println("cell",'[',x,']','[',y,']','=',cells[x][y]);
    }
  }

  // shuffle the order of cell array 1 and 2
  shuffleArray(cells);
  shuffleArray(cells2);
}



void draw() { 

  PressToClearAllBlack();  //Clear screen function
  PressToClearLeftToBlack(); // Clear Left Screen to Black Color;

  //webcam refresh
  if (cam.available() == true) {
    cam.read();
    // cam.loadPixels();
    //webcamCropped = cam.get(32,0,64,16); //how much to crop the webcam
    webcamCropped = cam.get(50, 0, webcamCroppedSizeX, webcamCroppedSizeY);
    //webcamCrop.copy(0,0,640,160,0,0,64,16);
    //updatePixels();
  }

  PressToWebcamOnOff(); //webcam dhow
  PressToShuffleArray(); //press '1' to sor tthe array
  //Temp test  array
  // shuffleArray(cells);



  //LEFT SCREEN DISPLAY    
  DrawPixelArrayInOrderLeftScreen(cells, dotDisplayintervalLeftScreen, LeftScreenPositionX, LeftScreenPositionY, 512);   //dotDisplayinterval1 -512 steps= 1hour to fill up the panel

  //RIGHT SCREEN DISPLAY 
  DrawPixelArrayInOrderRightScreen(cells2, dotDisplayintervalRightScreen, RightScreenPositionX, RightScreenPositionY, 300);//dotDisplayinterval1  300 steps = 300s =5mins

  //MIDDLE SCREEN DISPLAY
  if (millis() - timerWebcamMode >= 900000) { //switch every 900000ms = 15mins
    //clear the background first
    fill(0);
    noStroke();
    rect(MidScreenPositionX, MidScreenPositionY, panelSizeX*2, panelSizeY);
    // run the switch mode function
    switchWebcamMode();
    timerWebcamMode=millis();
  }

  if (webcamMode) {
    //image(cam, 32,0,64,16); //display full webcam
    image(webcamCropped, MidScreenPositionX, MidScreenPositionY, 64, 16); //display cropped webcam
    webcamDisplay(); //normal webcam display
    if (webcamTHreshold) { 


      // We are going to look at both image's pixels
      webcamCropped.loadPixels();
      webcamCroppedEffect= createImage(webcamCroppedSizeX, webcamCroppedSizeY, RGB);
      webcamCroppedEffect.loadPixels();

      for (int x = 0; x < webcamCroppedSizeX; x++) {
        for (int y = 0; y < webcamCroppedSizeY; y++ ) {
          int loc = x + y*webcamCroppedSizeX;
          // Test the brightness against the threshold
          if (brightness(webcamCropped.pixels[loc]) > threshold) {
            webcamCroppedEffect.pixels[loc]  =thresholdColor;  // RED
          } else {
            webcamCroppedEffect.pixels[loc]  = color(0);    // Black
          }
        }
      }

      // We changed the pixels in destination
      webcamCroppedEffect.updatePixels();
      // Display the destination
      image(webcamCroppedEffect, MidScreenPositionX, MidScreenPositionY, 64, 16);

      if (keyPressed) {
        if (key == 'o' ) {
          threshold ++ ;
          if (threshold >= 255 ) {
            threshold = 255 ;
          }
        } else {
          if (key =='p') { 
            threshold -- ;
            if (threshold <= 0 ) {
              threshold = 0 ;
            }
          }
        }
      }
    }
  }

  if (lineMode) {
    drawLine();
  }

  //filter(THRESHOLD, 0.9);


  //Screen 3 - middle panel 64x16 
  //image(cam, 32,0,64,16); //display the webcam
}

void SetBackground() {
  /* ==== Screen Set up ====== */

  /* ===Screen 1 === LEFT screen set up ==== */
  //Screen 1 - RIGHT panel 32x16

  fill(BgRightScreen);
  noStroke();
  rect(RightScreenPositionX, RightScreenPositionY, panelSizeX, panelSizeY);

  /* ===  RIGHT screen set up   END  ==== */

  /* ===  LEF screen set up     ==== */
  fill(BgLeftScreen);
  noStroke();
  rect(LeftScreenPositionX, LeftScreenPositionY, panelSizeX, panelSizeY);

  /* === ===Screen 2 ===  LEF  screen set up   END  ==== */


  //Screen 3 Set up -  MID side
  fill(0);
  noStroke();
  rect(MidScreenPositionX, MidScreenPositionY, panelSizeX*2, panelSizeY);
}

void DrawPixelArrayInOrderRightScreen(int [][] cellArray, int timeInterval, int drawPositionX, int drawPositionY, int resetStep) { 

  if (millis() - timer >= timeInterval) { // 1000 = 1000ms  //7031
    //fill(255);
    strokeWeight(1);
    //stroke(255);

    if (RightScreenCellDrawingCountY < panelSizeY-1) { 
      RightScreenCellDrawingCountY++; 
      RightScreenCellDrawingCounter++;
    } else {
      RightScreenCellDrawingCountY = 0;
      RightScreenCellDrawingCountX ++ ; 
      RightScreenCellDrawingCounter ++;
    };
    print("Right Screen Cell Drawing Counter X: ", RightScreenCellDrawingCountX);
    print(" | Right Screen Cell Drawing Counter Y: ", RightScreenCellDrawingCountY);
    print(" || Right Screen Cell Drawing Counter: ", RightScreenCellDrawingCounter);
    println(" /// ", RightScreenCellDrawingCounter * timeInterval, "ms");
    //when it reach a set reset limit
    if (RightScreenCellDrawingCounter == resetStep) { 
      RightScreenCellDrawingCountX = 0;
      RightScreenCellDrawingCountY = 0; 
      RightScreenCellDrawingCounter = 0;

      //change color
      rightScreenResetCounter++;
      if (rightScreenResetCounter %2 ==0) { 
        fill(BgRightScreen);
        noStroke(); 
        rect(drawPositionX, drawPositionY, panelSizeX, panelSizeY);
        stroke(255);
      } else { 
        fill(0);
        noStroke(); 
        rect(drawPositionX, drawPositionY, panelSizeX, panelSizeY);
        stroke(255, 0, 0);
      }
      println("right Screen Reset") ;
      shuffleArray(cellArray);
    };
    //when fill up the screen
    if (RightScreenCellDrawingCountY == panelSizeX) { 
      println("Right Panel Pixel full");
      RightScreenCellDrawingCountX = 0;
      RightScreenCellDrawingCountY = 0; 
      fill(BgRightScreen);
      noStroke(); 
      rect(drawPositionX, drawPositionY, panelSizeX, panelSizeY);
      shuffleArray(cellArray);
    }

    int printXPosition = cellArray[RightScreenCellDrawingCountX][RightScreenCellDrawingCountY]/16; 
    int printYPosition = cellArray[RightScreenCellDrawingCountX][RightScreenCellDrawingCountY]%16; 
    point(printXPosition + drawPositionX, printYPosition + drawPositionY);
    //println("Cell",'[',cellDrawingCountX,']','[',cellDrawingCountY,']','=','(',printXPosition,',', printYPosition,')');

    // and better do a clear screen

    timer = millis();
  }
}



void DrawPixelArrayInOrderLeftScreen(int [][] cellArray, int timeInterval, int drawPositionX, int drawPositionY, int resetStep) { 

  if (millis() - timer2 >= timeInterval) { // 1000 = 1000ms  //7031
    //fill(255);


    if (LeftScreenCellDrawingCountY < panelSizeY-1) { 
      LeftScreenCellDrawingCountY++; 
      LeftScreenCellDrawingCounter++;
    } else {
      LeftScreenCellDrawingCountY = 0;
      LeftScreenCellDrawingCountX ++ ; 
      LeftScreenCellDrawingCounter++;
    }
    print("Left Screen Cell Drawing Counter = ", LeftScreenCellDrawingCounter);
    println(" //// ", LeftScreenCellDrawingCounter * timeInterval, "ms");
    // when i is 60 steps (60seconds) 
    if (LeftScreenCellDrawingCounter == resetStep) { 
      LeftScreenCellDrawingCountX = 0;
      LeftScreenCellDrawingCountY = 0; 
      LeftScreenCellDrawingCounter =0;
      println("left Screen reset");
      fill(0);
      noStroke(); 
      rect(drawPositionX, drawPositionY, panelSizeX, panelSizeY);
    }



    if (LeftScreenCellDrawingCountX == panelSizeX) { 
      println("left Screen Pixel Full Reset");
      LeftScreenCellDrawingCountX = 0;
      LeftScreenCellDrawingCountY = 0; 
      fill(0);
      noStroke(); 
      rect(drawPositionX, drawPositionY, panelSizeX, panelSizeY);
      shuffleArray(cellArray);
    }

    int printXPosition = cellArray[LeftScreenCellDrawingCountX][LeftScreenCellDrawingCountY]/16; 
    int printYPosition = cellArray[LeftScreenCellDrawingCountX][LeftScreenCellDrawingCountY]%16; 
    strokeWeight(1);
    stroke(255);
    point(printXPosition + drawPositionX, printYPosition + drawPositionY);
   
    //println("Cell",'[',LeftScrrenCellDrawingCountX,']','[',LeftScreenCellDrawingCountY,']','=','(',printXPosition,',', printYPosition,')');

    // and better do a clear screen

    timer2 = millis();
  }
}

void drawLine() { 

  int pointAx = int(random(0, panelSizeX*2));
  int pointAy = int(random(0, panelSizeY));
  int pointBx = int(random(0, panelSizeX*2));
  int pointBy = int(random(0, panelSizeY));


  if (millis() - timer3 >= 3000) { //3000 for 3 secounds
    drawlineCounter ++; 
    stroke(255);
    line(pointAx+MidScreenPositionX, pointAy+MidScreenPositionY, pointBx+MidScreenPositionX, pointBy+MidScreenPositionY);

    timer3 = millis();
  }
  if (drawlineCounter>20) {  //clear afyter 20 lines 1mins
    fill(0);
    noStroke();
    rect(MidScreenPositionX, MidScreenPositionY, panelSizeX*2, panelSizeY);
    drawlineCounter=0;
  }
}


void shuffleArray(int[][] a) {
  int nbrCols = a.length;
  int nbrRows = a[0].length;
  for (int c = 0; c < nbrCols; c++) {
    for (int r = 0; r < nbrRows; r++) {
      int nc = (int)random(nbrCols);
      int nr = (int)random(nbrRows);
      int temp = a[c][r];
      a[c][r] = a[nc][nr];
      a[nc][nr] = temp;
    }
  }
}

void PressToShuffleArray() { 
  if (keyPressed) {
    if (key == '1' ) {
      shuffleArray(cells);
      shuffleArray(cells2);
      fill(0);
      noStroke();
      rect(0, 0, 32, 16); //screen 1 only
    }
  }
  // END - Clear up the screen
} 


void PressToClearAllBlack() {
  //clear up the screen
  if (keyPressed) {
    if (key == ' ' ) {
      //fill(BgRightScreen);
      //noStroke();
      //rect(96, 0, panelSizeX, panelSizeY);
      //fill(BgLeftScreen);
      //noStroke();
      //rect(0, 0, panelSizeX, panelSizeY);
      SetBackground();
    }
  }
  // END - Clear up the screen
}

void PressToClearLeftToBlack () {
  if (keyPressed) {
    if (key == '7' ) {
      fill(0);
      noStroke();
      rect(LeftScreenPositionX, LeftScreenPositionY, panelSizeX, panelSizeY);
    }
  }
}

void PressToClearRightToBlack () {
  if (keyPressed) {
    if (key == '8' ) {
      fill(0);
      noStroke();
      rect(RightScreenPositionX, RightScreenPositionY, panelSizeX, panelSizeY);
    }
  }
}

void switchWebcamMode() {



  webcamModeCounter++;
  println("Webcam mode counter:", webcamModeCounter);

  if (webcamModeCounter%3 ==0) {
    webcamMode = true;
    webcamTHreshold = false;
    lineMode = false;
  } 
  if  (webcamModeCounter%3 == 1) {
    webcamMode = true;
    webcamTHreshold = true;
    lineMode = false;
  }
  if  (webcamModeCounter%3 == 2) {
    webcamMode = false;
    webcamTHreshold = false;
    lineMode = true;
  }
}


void PressToWebcamOnOff() { 
  // if (keyPressed) {
  //  if (key == 'w' ) {
  //        //select webcam
  //    //image(cam, 32,0,64,16); //display the webcam 
  //  }
  //}

  //if (keyPressed) { 
  // if (key == 'q') { 
  //   cam.stop();
  // }
  //} else {
  //  if (key == 'e') { 
  //   cam.start(); 
  //  }
  //}
}

void WebcamInit() {
  /* ==== WEBCAM initialization  ==== */
  String[] cameras = Capture.list();

  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(i, "-", cameras[0]);   //select camera
    }

    // The camera can be initialized directly using an 
    // element from the array returned by list():
    //cam = new Capture(this, cameras[0]);
    cam = new Capture(this, webcamX, webcamY);
    cam.start();
  }
  webcamCropped = createImage(webcamCroppedSizeX, webcamCroppedSizeY, RGB);


  /* ==== WEBCAM initialization END ==== */
}

void webcamDisplay() {   
  image(cam, 200, 0, 400, 300); //display full webcam
} 
