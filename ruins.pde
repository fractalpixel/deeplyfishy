
class Ruins {

  ArrayList<RuinGroup> groups = new ArrayList();

  void init() {
    int num = 100;
    for (int i = 0; i < num; i++) {
      RuinGroup group = new RuinGroup();
      groups.add(group);
    }
  }
  
  void render(float deltaTime) {
    for (RuinGroup group: groups) {
      group.render(deltaTime);
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
  
  void render(float deltaTime) {
    for (Ruin ruin: ruins) {
      ruin.render(deltaTime);
    }
  }
}


class Ruin {
  PVector pos = new PVector();
  float angleX = 0;
  float angleY = 0;
  float angleZ = 0;
  float size = 10;
  
  Ruin (RuinGroup group) {
    pos.set(group.pos.x + random(-10, 10),
            group.pos.y, 
            group.pos.z + random(-10, 10));
    angleX = random(-10, 10);        
    angleY = random(-10, 10);        
    angleZ = random(-10, 10);
    size = random(1, 5);
  }
  
  void render(float deltaTime) {
    pushStyle();
    pushMatrix();

    // Position
    translate(-pos.x, -pos.y, -pos.z);
    rotateX(angleX);
    rotateY(angleY);
    rotateZ(angleZ);
    
    // Render
    fill(220, 180, 120);
    box(size, size, size);
    
    popMatrix();
    popStyle();
  }
}
