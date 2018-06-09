Scool smallScool;
 
void setupfishes() {

 
  smallScool = new Scool(100);
}
 
void drawfishes() {
  smallScool.drawScool();
 
 
  
  
}

class Scool {
  ArrayList<Fish> fishes = new ArrayList<Fish>();
  int scoolsize;
  
  Scool(int amount){
    scoolsize = amount;
    for (int i = 0; i < amount; i++) {
      fishes.add(new Fish());
    }
  }
  
  void drawScool(){
    for (Fish f : fishes) {
      f.render();
      //f.step(fishes);
    } 
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
 
  void step(ArrayList<Fish> fishes) {
    PVector center = new PVector();
    PVector avoid = new PVector();
    PVector toward = new PVector();
    for (Fish f : fishes){
        center = findMass(f, fishes);
        //avoid = avoidFriends(f);
        toward = tovardPosition(f,new PVector(0,0,0));
        f.velocition.add(center);
        f.velocition.add(avoid);
        f.velocition.add(toward);
        f.velocition.div(100);
        f.position.add(f.velocition);
      
    } 
 

  }
  
  
  PVector findMass(Fish thisFish, ArrayList<Fish> fishes){
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


  PVector avoidFriends(Fish thisFish, ArrayList<Fish> fishes){
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
