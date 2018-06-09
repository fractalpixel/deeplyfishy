
class Ruins {

  ArrayList<RuinGroup> groups = new ArrayList();
  Terrain terrain;

  void init(Terrain terrain) {
    this.terrain = terrain;
    int num = 100;
    for (int i = 0; i < num; i++) {
      RuinGroup group = new RuinGroup();
      groups.add(group);
    }
  }
  
  void render(float time, float deltaTime) {
    for (RuinGroup group: groups) {
      group.render(time, deltaTime);
    }
  }
}


class RuinGroup {
  PVector pos = new PVector();
  ArrayList<Ruin> ruins = new ArrayList();

  RuinGroup() {
    int num = (int) random(2, 20);
    pos.set(random(-100, 100), random(-20, -4),random(-100, 100));
    for (int i = 0; i < num; i++) {
      Ruin ruin = new Ruin(this);
      ruins.add(ruin);
    }
  }
  
  void render(float time, float deltaTime) {
    for (Ruin ruin: ruins) {
      ruin.render(time, deltaTime);
    }
  }
}


class Ruin {
  PVector pos = new PVector();
  float angleX = 0;
  float angleY = 0;
  float angleZ = 0;
  float size = 10;
  float seed;
  
  Ruin (RuinGroup group) {
    float x = group.pos.x + random(-10, 10);
    float z = group.pos.z + random(-10, 10);
    float y = terrain.heightAt(x,z);
    pos.set(x,y,z);
    float ra = TURN*0.05;
    float ya = TURN/2;
    angleX = random(-ra, ra);        
    angleY = random(-ya, ya);        
    angleZ = random(-ra, ra);
    size = random(0.1, 4);
    seed = random(0, 100);
  }
  
  void render(float time, float deltaTime) {
    float ruinDance = (float) moonlander.getValue("ruinDanceFreq");
    float ruinDanceAmpl = (float) moonlander.getValue("ruinDanceAmpl");
    
    pushStyle();
    pushMatrix();

    // Position
    float freq =100;
    float angleFreq = 0.2*freq;
    float bassAmount = ruinDanceAmpl*0.3;
    float discantAmount = ruinDanceAmpl*0.02;
    translate(pos.x + 0.3*ruinDance * shakyNoise(time, freq, bassAmount, discantAmount, 1234.213*seed), 
              pos.y + ruinDance * shakyNoise(time, freq, bassAmount, discantAmount, 8734.234*seed), 
              pos.z + 0.3*ruinDance * shakyNoise(time, freq, bassAmount, discantAmount, 7313.173*seed));
    rotateX(angleX + ruinDance * shakyNoise(time, angleFreq, bassAmount, discantAmount, 896.45*seed));
    rotateY(angleY + ruinDance * shakyNoise(time, angleFreq, bassAmount, discantAmount, 1534.3*seed));
    rotateZ(angleZ + ruinDance * shakyNoise(time, angleFreq, bassAmount, discantAmount, 312.312*seed));
    
    // Render
    fill(220, 180, 120);
    box(size, size, size);
    
    popMatrix();
    popStyle();
  }
}
