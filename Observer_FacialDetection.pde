import processing.video.*;
import gab.opencv.*;
import java.awt.Rectangle;

OpenCV opencv;
Capture cam;

// Array of faces found
Rectangle[] faces;

int scale = 5;
int faceCaptureCount = 0; 
int imagePointer = 0;

final static int NUM_OF_DISPLAY_FACES = 12;
PImage[] faceImages = new PImage[NUM_OF_DISPLAY_FACES];

PImage smaller;
int lastFaceCount = 0;
Boolean imagesLoaded = false;

void setup() {
  size(960, 720);

  String[] cameras = Capture.list();
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    } 
    cam = new Capture(this, 960, 540, cameras[2]);
    // For Logitech c 615
    // the 16th one is 1920 x 1080 at 15fps
    // the 20th one is 960 x 540 at 15fps
    // the 22th one is 480 x 270 at 15fps
    // the 25th one is 240 x 135 at 15fps
    cam.start();
  }

  // Create the OpenCV object
  opencv = new OpenCV(this, cam.width/scale, cam.height/scale);

  // Which "cascade" are we going to use?
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE); 

  // Make scaled down image
  smaller = createImage(opencv.width, opencv.height, RGB);
}

// New images from camera
void captureEvent(Capture cam) {
  cam.read();

  // Make smaller image
  smaller.copy(cam, 0, 0, cam.width, cam.height, 0, 0, smaller.width, smaller.height);
  //smaller.updatePixels();
}

void draw() {
  if (faceCaptureCount >= NUM_OF_DISPLAY_FACES && frameCount % 50 == 0) {
    for (int i = 0; i < faceImages.length; i++) {
      if (random(100) > 25 || imagesLoaded == false) {
        int currentImage = imagePointer + i;
        String whichImage = "data/faces/faceCapture" + currentImage + ".jpg";
        faceImages[i] = loadImage(whichImage);
      }
    }
    
    imagesLoaded = true;
    imagePointer += NUM_OF_DISPLAY_FACES;
    
    if ((imagePointer + NUM_OF_DISPLAY_FACES) > faceCaptureCount) {
      imagePointer = 0;
    }
  }

  background(255);
  opencv.loadImage(smaller);
  faces = opencv.detect();

  //standard image tag: image(img, 0, 0);
  if(imagesLoaded == true) {
    image(faceImages[0], 0, 0); 
    image(faceImages[1], 240, 0); 
    image(faceImages[2], 480, 0); 
    image(faceImages[3], 720, 0); 
    image(faceImages[4], 0, 240); 
    image(faceImages[5], 240, 240); 
    image(faceImages[6], 480, 240);
    image(faceImages[7], 720, 240); 
    image(faceImages[8], 0, 480); 
    image(faceImages[9], 240, 480); 
    image(faceImages[10], 480, 480);
    image(faceImages[11], 720, 480);
  }

  // If we find faces, draw them!
  if (faces != null) {
    for (int i = 0; i < faces.length; i++) {
      // draw boxes around the faces
      //strokeWeight(2);
      //stroke(255, 0, 0);
      //noFill();
      //rect(faces[0].x * scale, faces[0].y * scale, faces[0].width * scale, faces[0].height * scale);

      //if(faces.length != lastFaceCount) {
        // crop out the faces and save them
        PImage cropped = createImage(faces[0].width * scale, faces[0].height * scale, RGB);
        cropped.copy(cam, faces[0].x * scale, faces[0].y * scale, faces[0].width * scale, faces[0].height * scale, 0, 0, faces[0].width * scale, faces[0].height * scale);
        cropped.resize(240, 0);
        cropped.updatePixels(); 
        cropped.save(dataPath("faces/faceCapture" + faceCaptureCount + ".jpg"));
        faceCaptureCount++;
        
        lastFaceCount = faces.length; 
      //}
    }
  }

  //delay(250); 
  //// since the frame rate default is 60 frames and there are 1000 miliseocnds per second
  //// but we only want 15 frames, so we delay it by 250 miliseconds. 

  //Add the white grid
  fill(0);
  noStroke();
  for (int gx = 0; gx < 5; gx++) {
    for (int gy = 0; gy < 4; gy++) {
      rect(gx * 240 - 5, 0, 10, 720);
      rect(0, gy * 240 - 5, 960, 10);
    }
  }
}