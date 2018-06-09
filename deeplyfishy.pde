import queasycam.*;
import moonlander.library.*;
import java.util.logging.*;

// Minim is needed for the music playback
// (even when using Moonlander)
import ddf.minim.*;

// These control how big the opened window is.
// Before you release your demo, set these to 
// full HD resolution (1920x1080).
int CANVAS_WIDTH = 1000; //1920; //480;
int CANVAS_HEIGHT = 600; //1080; // 360;

// For syncing with music etc
Moonlander moonlander;

// Camera
QueasyCam cam;

/*
 * settings() must be used when calling size with variable height and width
 */
void settings() {
  // Set up the drawing area size and renderer (P2D / P3D).
  size(CANVAS_WIDTH, CANVAS_HEIGHT, P3D);
}

/*
 * Processing's setup method.
 *
 * Do all your one-time setup routines in here.
 */
void setup() {
  rectMode(CENTER);
  
  translate(width /2, height/2);
  scale(height / 1000.0);
  
  cam = new QueasyCam(this);
  cam.speed = 10.1f;
  cam.sensitivity = 1f;
  cam.friction = 0.3f;

  setupfishes();

  frameRate(60);


  // Parameters: 
  // - PApplet
  // - soundtrack filename (relative to sketch's folder)
  // - beats per minute in the song
  // - how many rows in Rocket correspond to one beat
  moonlander = Moonlander.initWithSoundtrack(this, "tekno_127bpm.mp3", 127, 8);
//  moonlander.changeLogLevel(Level.FINEST);

  // Last thing in setup; start Moonlander. This either
  // connects to Rocket (development mode) or loads data 
  // from 'syncdata.rocket' (player mode).
  // Also, in player mode the music playback starts immediately.
//  moonlander.start("localhost", 9001, "syncfile");
  moonlander.start();
}


/*
 * Processing's drawing method
 */
void draw() {
    background(22, 66, 120);

  // Handles communication with Rocket
  moonlander.update();

  // Seconds since start
  float time = millis() / 1000.0;


  // Get values from Rocket using 
  // moonlander.getValue("track_name") or
  // moonlander.getIntValue("track_name")
  
  fill(255);
  
  
  // Draw the ground plane
  
  pushMatrix();
  // Rotate the plane by 90 degrees so it's laying on the ground 
  // instead of facing the camera. Try to use `secs` instead and 
  // see what happens :)
  rotateX(PI/2);
  scale(6.0);
  // Draw the plane
  rect(0, 0, 100, 100);
  popMatrix();


    
  // Fish
  fill(100, 200, 255);
  drawfishes();
  
  fill(255, 0, 0);
  sphere(10);

}
