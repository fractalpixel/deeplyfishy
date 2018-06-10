
class Ruins {

  ArrayList<RuinGroup> groups = new ArrayList();
  Terrain terrain;

  void init(Terrain terrain) {
    this.terrain = terrain;
    int num = 30;
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
    int num = (int) random(2, 10);
    pos.set(random(-80, 80), random(-20, -4),random(-80, 80));
    for (int i = 0; i < num; i++) {
      float size = random(0.2, 1.7)*random(0.3, 2);
      float x = pos.x + random(-12, 12);
      float z = pos.z + random(-12, 12);
      float a = random(-PI, PI);
      int levels = (int)(random(1, 3)*random(1, 3));
      for (int level = 0; level < levels+2; level++) {
        Ruin ruin = new Ruin(this, size, x, level, z, levels, a);
        ruins.add(ruin);
      }
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
    float blockColorR;
    float blockColorG;
    float blockColorB;
    int blockColor;
    int levels;
  
  Ruin (RuinGroup group, float size, float x, float dy, float z, int levels, float ya) {
    this.levels = levels;
    float y = terrain.heightAt(x,z) + dy * size;
    pos.set(x,y,z);
    float ra = TURN*0.01;
    angleX = random(-ra, ra);        
    angleY = ya + random(-ra, ra);        
    angleZ = random(-ra, ra);
    this.size = size;
    seed = random(0, 100);
    blockColorR = 220 + random(-20, 20);
    blockColorG = 180 + random(-15, 15);
    blockColorB = 120 + random(-10, 10);
    blockColor = color(blockColorR, blockColorG, blockColorB);
  }
  
  void render(float time, float deltaTime) {
    float ruinDance = (float) moonlander.getValue("ruinDanceFreq");
    float ruinDanceAmpl = (float) moonlander.getValue("ruinDanceAmpl");
    float ruinRaise = (float) moonlander.getValue("ruinRaise");
    float ruinExtend = (float) moonlander.getValue("ruinExtend");
    
    float ruinDeltaY = -ruinRaise * levels * size;
    
    pushStyle();
    pushMatrix();

    // Position
    float freq =100;
    float angleFreq = 0.7*freq;
    float bassAmount = ruinDanceAmpl*0.06;
    float discantAmount = ruinDanceAmpl*0.002;
    translate(pos.x + 0.2*ruinDance * shakyNoise(time, freq, bassAmount, discantAmount, 1234.213*seed), 
              pos.y + ruinDance * shakyNoise(time, freq, bassAmount, discantAmount, 8734.234*seed) + ruinDeltaY, 
              pos.z + 0.2*ruinDance * shakyNoise(time, freq, bassAmount, discantAmount, 7313.173*seed));
    rotateX(angleX + ruinDance * shakyNoise(time, angleFreq, bassAmount, discantAmount, 896.45*seed));
    rotateY(angleY + ruinDance * shakyNoise(time, angleFreq, bassAmount, discantAmount, 1534.3*seed));
    rotateZ(angleZ + ruinDance * shakyNoise(time, angleFreq, bassAmount, discantAmount, 312.312*seed));
    
    // Render
    fill(blockColor);
    box(size, size, size);

    // Sub-blocks
    randomSeed((long)(seed*100));
    if (random(0,1) < 0.8) {
      int count = (int) (random(2, 3)*random(1, 4));
      for (int i = 0; i < count; i++) {
        randomSeed((long)(seed*100+i));
        pushMatrix();
        float r = blockColorR + random(-10, 10);
        float g = blockColorG + random(-10, 10);
        float b = blockColorB + random(-10, 10);
        blockColor = color(r, g, b);
        fill(blockColor);
        float p = 2;
        float ms =size/(1.5*p);
        float extendX = 0 + random(0,1) < 0.3 ? random(-1, 1) * ruinExtend * ms : 0;
        float extendZ = 0 + random(0,1) < 0.3 ? random(-1, 1) * ruinExtend * ms : 0;
        translate(size*(int)random(-p, p)/(p*1.5) + extendX,
                  size*(int)random(-p, p)/(p*1.5), //-size*0.5*random(0,1),
                  size*(int)random(-p, p)/(p*1.5) + extendZ);
        float ra = 0.1;          
        rotateX(random(-ra, ra));          
        rotateY(random(-ra, ra));          
        rotateZ(random(-ra, ra));   
        float rs = size*0.07;
        box(ms+random(-rs,rs), ms+random(-rs,rs), ms+random(-rs,rs));
        popMatrix();
      }
    }
    popMatrix();
    popStyle();
  }
}
