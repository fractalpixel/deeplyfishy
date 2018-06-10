import damkjer.ocd.*;

//import queasycam.*;
import moonlander.library.*;
import java.util.logging.*;


// Minim is needed for the music playback
// (even when using Moonlander)
import ddf.minim.*;

float TURN = PI*2;

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
Scroller scroller;

PVector camPos = new PVector();
PVector focusPos = new PVector();

float sinNoise(float t, float x) {
  return 0.5*sin(t * x) + 0.5*cos(t * 0.31232 * x) + 0.5*sin( (t * 0.123 + cos(t * 0.001351)) * 0.871 * x);
}

float shakyNoise(float time, float freq, float bass, float discant, float seed) {
  return (noise(time * 0.2*freq, seed * 123.321) * 2 - 1) * bass +
         (noise(time * 1*freq, seed * 887.213) * 2 - 1) * discant; 
}

void calcTargetPos(PVector pos, float time, float speed, float mag, float yScale, float yDelta) {
  pos.x = sinNoise(time + 782.213, speed) * mag;
  pos.y = sinNoise(time + 3712.321, speed * yScale) * mag + yDelta;
  pos.z = sinNoise(time + 12.876, speed) * mag;
}

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
  noSmooth();
  
  randomSeed(8719);
  
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
  ocean.set("fade", 1.0);
  oceanLight = loadShader("ocean_light_frag.glsl", "ocean_light_vert.glsl");
  oceanLight.set("fade", 1.0);
  

  // Parameters: 
  // - PApplet
  // - soundtrack filename (relative to sketch's folder)
  // - beats per minute in the song
  // - how many rows in Rocket correspond to one beat
  moonlander = Moonlander.initWithSoundtrack(this, "Final Battle of the Dark Wizards.mp3", 112, 8);
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
  
  scroller = new Scroller();
  
}

/*
 * Processing's drawing method
 */
void draw() {
  background(0);
  fill(255);
  resetShader();

  // Handles communication with Rocket
  moonlander.update();

  // Seconds since start
  float time = (float) moonlander.getCurrentTime();
  //float time = millis() / 1000.0;
  float deltaTime = 1f / fps; 

  // Render credits etc
  scroller.render(time, deltaTime);

  // Fading
  float fade = (float) moonlander.getValue("fade");
  ocean.set("fade", fade);
  oceanLight.set("fade", fade);

  // Update fish speed
  float predatorSpeed = (float) moonlander.getValue("predatorSpeed");
  bigScool1.scoolSpeedMod = predatorSpeed;
  bigScool2.scoolSpeedMod = predatorSpeed;
  float mediumSpeed = (float) moonlander.getValue("mediumFishSpeed");
  averageScool.scoolSpeedMod = mediumSpeed;

  // Update fish targets
  float fishTargetSpeed = 0.05;
  float fishTargetDist = 5;
  calcTargetPos(smallScool.target, time+31.32, fishTargetSpeed, fishTargetDist*0.8, 0.5, 2); 
  calcTargetPos(averageScool.target, time + 9823.3, fishTargetSpeed*0.7, fishTargetDist*1.1, 0.6, -1); 

  // Position camera
  int cameraMode = moonlander.getIntValue("cameraMode");
  float baseCamMoveSpeed = (float) moonlander.getValue("camMoveSpeed");
  float baseCamMoveDist = (float) moonlander.getValue("camMoveDist");
  float targetY = (float) moonlander.getValue("targetY");
  float cameraY = (float) moonlander.getValue("camY");
  if (cameraMode == 1 && bigScool1.fishes.size() > 0) {
    // Chase fish
    Fish fish = bigScool1.fishes.get(0);
    float blend = 0.4f;
    focusPos.set(bigScool1.scoolCenter);
    //focusPos.set(fish.position);
    camPos.lerp(camPos,focusPos,blend);
  }
  else if (cameraMode == 2) {
    // Slow rotate
    float camMoveSpeed = 0.01 * baseCamMoveSpeed;
    float camMoveDist = 20 * baseCamMoveDist;
    focusPos.set(0,targetY, 0);
    camPos.set(-cos(time*camMoveSpeed*TURN) * camMoveDist, 0, sin(time*camMoveSpeed*TURN) * camMoveDist);
  }
  else if (cameraMode == 3) {
    // Credit cam
    float camMoveSpeed = 0.03 * baseCamMoveSpeed;
    float camMoveDist = 20 * baseCamMoveDist;
    focusPos.set(0,targetY, 0);
    camPos.set(-cos(time*camMoveSpeed*TURN) * camMoveDist, 3, sin(time*camMoveSpeed*TURN) * camMoveDist*0.4+camMoveDist*0.8);
  }
  else {
    float camMoveSpeed = 0.1 * baseCamMoveSpeed;
    float camMoveSpeedY = camMoveSpeed * 0.2;
    float camMoveDist = 50 * baseCamMoveDist;
  
    float focusPosSpeed = 0.89 * baseCamMoveSpeed;
    float focusPosDist = 20 * baseCamMoveDist;
  
    calcTargetPos(camPos, time, camMoveSpeed, camMoveDist, 0.2, 0);
    calcTargetPos(focusPos, time + 3125.342, focusPosSpeed, focusPosDist, 0.5, targetY);
  }
  
  camera.jump(camPos.x, camPos.y + cameraY, camPos.z);
  camera.aim(focusPos.x, focusPos.y, focusPos.z);
  camera.feed();

  // Get values from Rocket using 
  // moonlander.getValue("track_name") or
  // moonlander.getIntValue("track_name")
  
  
  // Debug lines
  noStroke();
 // stroke(0,255, 0);
   

  //lights();

  // Ocean background
  shader(ocean);
  //fill(200, 50, 50);
  pushMatrix();
  // Center background on camera
  translate(camPos.x, camPos.y, camPos.z);
  sphere(160);
  popMatrix();

  // Sunlight
  float sunWorbleAmount = (float) moonlander.getValue("sunWorbleAmount");
  float sunWorbleSpeed = (float) moonlander.getValue("sunWorbleSpeed");
  worblePos += deltaTime*sunWorbleSpeed;
  directionalLight(255, 255, 255, sin(worblePos)*sunWorbleAmount, 10, cos(worblePos)*sunWorbleAmount);
  
  // Things in ocean
  shader(oceanLight);

  // Terrain
  terrain.render();

  // Ruins 
  ruins.render(time, deltaTime);

  // Fish
  fill(100, 200, 255);
  drawfishes(deltaTime);
  noStroke();

  // DEBUG: Red blob at origo
  // fill(255, 100, 100);
  // sphere(1);

}
