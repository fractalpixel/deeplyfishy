Scool smallScool;
 
void setupfishes() {

 
  smallScool = new Scool(100);
  noStroke();
}
 
void drawfishes(float deltaTime) {
  
 
  background(0);
  lights();
  smallScool.drawScool(deltaTime);
 
  
  
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
  
  void drawScool(float deltaTime){
    PVector target=  new PVector(0,2,0);
    PVector avoid = new PVector(0,0,0);
    ArrayList<PVector> avoidThese = new ArrayList<PVector>(); 
    avoidThese.add(avoid);
    for (Fish f : fishes) {
      f.render();
    //  //println("rendering fish");
      
      f.step(fishes, deltaTime, target, avoidThese, 3);
      
    } 
  }
}  


 
class Fish {
  PVector position = new PVector(random(10, 15), random(-20, -15), random(-10, -5));
  PVector velocition = new PVector(random(-0.5, 0.5), random(-0.5, 0.5), random(-0.5, 0.5));
  float maxVelocity = random(4, 8);
  float minVelosity = random(0.001, 0.01);
  float maxVelocityChange = random(0.01, 0.05);
  float searchDist = random(4, 7);
  float contentDist = random(2, 4); 
  float crowdedDist = random(0.5, 2);
  float size = random(0.05, 0.2);
 
  void render() {
    /*pushMatrix();
    translate(position.x, position.y, position.z);
    
    sphere(size);
    popMatrix();*/
    
    fill(48, 138,206,63);
stroke(48,138,206,191);
pushMatrix();
float r = size;

 translate(position.x, position.y, position.z);
beginShape();
vertex(r*15.0, r*17.0, r); //Left wing tip
vertex(r*25.0, r*10.0); //Left wing top point
vertex(r*30.0, r*13.0, r*10.0); //middle
vertex(r*35.0, r*10.0 ); //right wing top point
vertex(r*45.0, r*17.0, r); //right wing tip
vertex(r*30.0, r*13.0); //underpart
endShape();
popMatrix();
   // println(position.toString());
  }
 
  void step(ArrayList<Fish> fishes, float deltaTime, PVector target, ArrayList<PVector> avoidThese, float avoidDist) {
    PVector center = new PVector();
    PVector avoid = new PVector();
    PVector toward = new PVector();
    PVector match = new PVector();
    PVector avoidObj = new PVector();
    PVector velocityChange = new PVector();

    center = findMass(this, fishes, searchDist, contentDist);
    avoid = avoidFriends(this, fishes);
    toward = tovardPosition(this,target).mult(100);
    match = matchSpeed(this,fishes);
    avoidObj = avoidObjects(avoidThese,this,avoidDist).mult(100000);
    velocityChange.add(center).add(avoid).add(toward).add(match).add(avoidObj);
    velocityChange.mult(deltaTime);
    if (velocityChange.mag() > maxVelocityChange){
      velocityChange.normalize().mult(maxVelocityChange);  
    }
    velocition.add(velocityChange);

    if (velocition.mag() > maxVelocity){
       velocition.normalize().mult(maxVelocity); 
    }
    else if (velocition.mag() < minVelosity){
      velocition.normalize().mult(minVelosity);
    }  
    PVector temp = velocition.copy().mult(deltaTime);
     position.add(temp);
      
     
 

  }
  
  
  PVector findMass(Fish thisFish, ArrayList<Fish> fishes, float searchDist, float contentDist){
    PVector centerOfMass = new PVector();
    int num = 0;
    for (Fish f : fishes){
      float dist = f.position.dist(thisFish.position);
      if (f != thisFish &&  dist < searchDist){
         centerOfMass.add(f.position);
         num ++;
      }
    }  
    if (num != 0){
      centerOfMass.div(num);
      centerOfMass.sub(thisFish.position);
      float dist = thisFish.position.dist(centerOfMass);
      float distFromContent = dist-contentDist;
      if (distFromContent < 0){
        distFromContent = 0;
      }  
      float magnitude = distFromContent/(searchDist-contentDist);
      centerOfMass.normalize().mult(magnitude);
    }
    
     
    return centerOfMass;
  }  


  PVector avoidFriends(Fish thisFish, ArrayList<Fish> fishes){
    PVector avoidance = new PVector();
    float avoidDist = 1f;
    int num = 0;
    PVector temp = new PVector();
    for (Fish f : fishes){
      float dist = f.position.dist(thisFish.position); 
      if (f != thisFish && dist < avoidDist) {
        num ++;
        temp = f.position.copy().sub(thisFish.position).div(avoidDist);
        float magn = avoidDist - temp.mag();
        temp.normalize().mult(magn);
        avoidance.sub(temp);
      }

    }
    if (num > 0){
        avoidance.div(num);
     }  
   //println(avoidance.mag());
    return avoidance;
  }  
  
  PVector tovardPosition(Fish thisFish, PVector pos){
    PVector towardPos = new PVector();
    towardPos.add(pos).sub(thisFish.position).div(100);
    return towardPos;
  }
  
  
  PVector matchSpeed(Fish thisFish, ArrayList<Fish> fishes){
    PVector avgSpeed = new PVector();
    int num = 0;
    for (Fish f : fishes){
      float dist = f.position.dist(thisFish.position);
      if (f != thisFish &&  dist < 3){
         avgSpeed.add(f.position);
         num ++;
      }
    } 
    if (num > 0){
      avgSpeed.div(num);
      
    }  
    return avgSpeed.mult(0.005);
  } 
  
  PVector avoidObjects(ArrayList<PVector> objects, Fish thisFish, float distToAvoid){
    PVector avoidDirection = new PVector();
    PVector distToObjectVec = new PVector();
    for (PVector object : objects){
         distToObjectVec = object.copy().sub(thisFish.position);
         float dot = distToObjectVec.dot(thisFish.velocition);
         if (distToObjectVec.mag() < distToAvoid*2 && dot > 0){
             PVector distChange = distToObjectVec.copy().normalize().mult(-dot);
             avoidDirection.sub(distChange).normalize();
             float avoidSpeed = ((distToAvoid*2) - distToObjectVec.mag())/distToAvoid*2;
             avoidDirection.mult(-avoidSpeed);
             //println(avoidDirection.mag());
         }
    }
    return avoidDirection;
  }


  
  
  
}
