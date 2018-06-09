ArrayList<Fish> fishes = new ArrayList<Fish>();
 
void setup() {
  size(1500, 500, P3D);
  for (int i = 0; i < 100; i++) {
    fishes.add(new Fish());
  }
 
  noStroke();
}
 
void draw() {
 
  background(0);
  lights();
 
  for (Fish f : fishes) {
    f.render();
    f.step();
  }
}
 
class Fish {
  PVector position = new PVector(random(width), random(height), random(height));
  PVector velocition = new PVector(random(-10, 10), random(-10, 10), random(-10, 10));
 
  void render() {
    pushMatrix();
    translate(position.x, position.y, position.z);
    sphere(5);
    popMatrix();
  }
 
  void step() {
    PVector center = new PVector();
    PVector avoid = new PVector();
    PVector toward = new PVector();
    for (Fish f : fishes){
        center = findMass(f);
        //avoid = avoidFriends(f);
        toward = tovardPosition(f,new PVector(0,0,0));
        f.velocition.add(center);
        f.velocition.add(avoid);
        //f.velocition.add(toward);
        f.velocition.div(100);
        f.position.add(f.velocition);
      
    } 
 

  }
  
  
  PVector findMass(Fish thisFish){
    PVector centerOfMass = new PVector();
    int num = 0;
    for (Fish f : fishes){
      if (f != thisFish){
         centerOfMass.add(f.position);
         num ++;
      }
    }  
    if (num != 0){
      centerOfMass.div(num);
    }
    centerOfMass.sub(thisFish.position).normalize();
    return centerOfMass;
  }  


  PVector avoidFriends(Fish thisFish){
    PVector avoidance = new PVector();
    for (Fish f : fishes){
      if (f != thisFish && f.position.dist(thisFish.position) < 10) {
        avoidance.sub(f.position).add(thisFish.position);
      }
    }
    return avoidance;
  }  
  
  PVector tovardPosition(Fish thisFish, PVector pos){
    PVector towardPos = new PVector();
    towardPos.add(pos).sub(thisFish.position).div(100);
    return towardPos;
  }
/*
  PROCEDURE tend_to_place(Boid b)
    Vector place

    RETURN (place - b.position) / 100
  END PROCEDURE
*/
  
  
  
}
