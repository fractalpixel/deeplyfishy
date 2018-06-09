import damkjer.ocd.*;

//import queasycam.*;
import moonlander.library.*;
import java.util.logging.*;


// Minim is needed for the music playback
// (even when using Moonlander)
import ddf.minim.*;

// These control how big the opened window is.
// Before you release your demo, set these to 
// full HD resolution (1920x1080).
int CANVAS_WIDTH = 1400;// 1920; //480;
int CANVAS_HEIGHT = 800;//1080; // 360;

int fps = 60;

// For syncing with music etc
Moonlander moonlander;

// Ocean shaders
PShader ocean;
PShader oceanLight;

// Camera
//QueasyCam cam;
Camera camera;

float worblePos = 0f;

Ruins ruins;
Terrain terrain;

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
  randomSeed(872219);
  
  rectMode(CENTER);
  
  translate(width /2, height/2);
  scale(height / 1000.0);
  
  // Setup camera
  camera = new Camera(this, -20, 0, 0);
  camera.aim(0,0,0);
  camera.feed();
//  camera(0, 10, -80, 0,0,0, 0,1,0);
/*  
  cam = new QueasyCam(this);
  cam.controllable = false;
  cam.speed = 1.1f;
  cam.sensitivity = 1f;
  cam.friction = 0.3f;
  cam.position.set(-20, 0, 0);
  cam.position.x = -5;
  cam.position.y = 0;
  cam.position.z = 0;
*/

  setupfishes();
  
  frameRate(fps);

  // Load shader
  ocean = loadShader("ocean_frag.glsl", "ocean_vert.glsl");
  // ocean.set("fraction", 1.0);
  oceanLight = loadShader("ocean_light_frag.glsl", "ocean_light_vert.glsl");
  

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
  //moonlander.start("localhost", 9001, "syncfile");
  moonlander.start();
  
  terrain = new Terrain(100, 100);
  terrain.init();

  ruins = new Ruins();
  ruins.init(terrain);
  
}


/*
 * Processing's drawing method
 */
void draw() {
  background(128);
  fill(255);

  // Handles communication with Rocket
  moonlander.update();

  // Seconds since start
  float time = (float) moonlander.getCurrentTime();
  //float time = millis() / 1000.0;
  float deltaTime = 1f / fps; 

  // Position camera
  // TODO
  camera.jump(-10,0,0);
  camera.aim(0,0,0);
  camera.feed();

  // Get values from Rocket using 
  // moonlander.getValue("track_name") or
  // moonlander.getIntValue("track_name")
  
  
  // Debug lines
  noStroke();
 // stroke(0,255, 0);
   

  //lights();

  // Sunlight
  float sunWorbleAmount = (float) moonlander.getValue("sunWorbleAmount") * 100;
  float sunWorbleSpeed = (float) moonlander.getValue("sunWorbleSpeed") / 10;
  worblePos += deltaTime*sunWorbleSpeed;
  directionalLight(255, 255, 255, sin(worblePos)*sunWorbleAmount, 10, cos(worblePos)*sunWorbleAmount);
  
  // Ocean background
  shader(ocean);
  //fill(200, 50, 50);
  pushMatrix();
  resetMatrix();
  // Center background on camera
  translate(camera.position()[0], camera.position()[1], camera.position()[2]);
  sphere(200);
  popMatrix();

  // Things in ocean
  shader(oceanLight);

  // Terrain
  terrain.render();

  // Ruins 
  ruins.render(deltaTime);

  // Fish
  fill(100, 200, 255);
  drawfishes(deltaTime);
  noStroke();

  // DEBUG: Red blob at origo
  fill(255, 100, 100);
  
  sphere(1);

}
