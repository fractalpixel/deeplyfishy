Scool smallScool;
Scool averageScool;
Scool bigScool;
 
void setupfishes() {
  smallScool = new Scool(100, new PVector(12.5, -17.5, -7.5), 2.5, 0.05, 0.2);
  averageScool = new Scool(50, new PVector(-12.5, -17.5, -7.5), 2.5, 0.25, 1);
  bigScool = new Scool(3, new PVector(-22.5, -17.5, -7.5), 10, 2, 5);
  smallScool.predators = bigScool;
  averageScool.predators = bigScool;
  noStroke();
}
 
void drawfishes(float deltaTime) {
  smallScool.drawScool(deltaTime);
  averageScool.drawScool(deltaTime);
  bigScool.drawScool(deltaTime);
}

class Scool {
  ArrayList<Fish> fishes = new ArrayList<Fish>();
  int scoolsize;
  PVector target=  new PVector(0,-2,0);
  ArrayList<PVector> avoidThese = new ArrayList<PVector>(); 
  Scool predators; 

  
  Scool(int amount,PVector averageStartPosition, float positionSpread, float minsize, float maxSize ){
    scoolsize = amount;
    for (int i = 0; i < amount; i++) {
      fishes.add(new Fish(averageStartPosition, positionSpread,  minsize,  maxSize));
        
    }
    
    


    
  }
  
  
  
  void drawScool(float deltaTime){
    
    
    for (Fish f : fishes) {
      f.render(deltaTime);
    //  //println("rendering fish");
    
      f.step(fishes, deltaTime, target, avoidThese, 3, predators);
      
    } 

 
    
  }
}  


 
class Fish {
  PVector position = new PVector(random(10, 15), random(-20, -15), random(-10, -5));
  PVector velocition = new PVector(random(-0.5, 0.5), random(-0.5, 0.5), random(-0.5, 0.5));
  float maxVelocity = random(4, 8);
  float minVelosity = random(0.005, 0.05);
  float maxVelocityChange = random(0.01, 0.05);
  float searchDist = random(4, 7);
  float contentDist = random(2, 4); 
  float crowdedDist = random(0.5, 2);
  float size = random(0.05, 0.2);
  float tailPos = random(0, 1);
  float tailSpeed = random(25, 40);
  float maxMouthUp = random(0.1, 1);
  float moutPos = random(0, 1);
  float moutSpeed = random(5, 10);
  color fishColor = color(random(0, 175), random(100, 255), 255);
  color finColor = color(random(0, 100), random(200, 255), random(100, 255));
  float minDistToBottom = size*4;
  //0 = calm , 5= terrified,
  int terror = 0;
  
  Fish(PVector averageStartPosition, float positionSpread, float minsize, float maxSize){
        position = new PVector(random(averageStartPosition.x-positionSpread, averageStartPosition.x+positionSpread), random(averageStartPosition.y-positionSpread, averageStartPosition.y+positionSpread), random(averageStartPosition.z-positionSpread, averageStartPosition.z+positionSpread));
        size = random(minsize, maxSize);
  }  
 

 
  void step(ArrayList<Fish> fishes, float deltaTime, PVector target, ArrayList<PVector> avoidThese, float avoidDist, Scool predators) {
    PVector center = new PVector();
    PVector avoid = new PVector();
    PVector toward = new PVector();
    PVector match = new PVector();
    PVector avoidObj = new PVector();
    PVector velocityChange = new PVector();
    
    float relativeMaxYVelocity = 0.5;

    center = findMass(this, fishes, searchDist, contentDist);
    avoid = avoidFriends(this, fishes);
    toward = tovardPosition(this,target).mult(100);
    match = matchSpeed(this,fishes);
    avoidObj = avoidObjects(avoidThese,this,avoidDist).mult(100000);
    velocityChange.add(center).add(avoid).add(toward).add(match).add(avoidObj);
    velocityChange.mult(deltaTime);
    
    // Reduce y velocity change, slower for fishes
    velocityChange.y = velocityChange.y * relativeMaxYVelocity;    
    if (velocityChange.mag() > maxVelocityChange){
      velocityChange.normalize().mult(maxVelocityChange);  
    }
    //do normal swimming if not terrified
    if (terror <= 2){
      velocition.add(velocityChange);
    }
    //check for predators
    float distToPredator = 0;
    if (predators != null){
    for (Fish predator : predators.fishes){
         distToPredator = predator.position.dist(position);
         if (distToPredator < 2){
           terror = 5;
           
           PVector direction = position.copy().sub(predator.position).normalize();
           velocition = direction.mult(maxVelocity);
           break;
         }
    }
    }
    //to not collide in bottom
    float bottomY = -terrain.roughHeightAt(position.x,position.y);
    float bottomDist = abs(position.y-bottomY);
    if (velocition.y < 0 && bottomDist < minDistToBottom){
      velocition.y += maxVelocityChange;
    } 
    if (bottomDist < size*2){
      velocition.y = maxVelocityChange;
    }  
    // Clamp y velocity
    if (abs(velocition.y) > maxVelocity * relativeMaxYVelocity *(terror+1)) {
      float sign = 1;
      if (velocition.y < 0) sign = -1;
      velocition.y = sign * maxVelocity * relativeMaxYVelocity *(terror+1);
    }
    //if terrified
    if (terror >= 1){
      if (velocition.mag() > maxVelocity*terror){
         velocition.normalize().mult(maxVelocity); 
      }
      else if (velocition.mag() < minVelosity*terror){
        velocition.normalize().mult(minVelosity);
       
      }
    terror --;  
  }  
    else{
      if (velocition.mag() > maxVelocity){
         velocition.normalize().mult(maxVelocity); 
      }
      else if (velocition.mag() < minVelosity){
        velocition.normalize().mult(minVelosity);      
    }
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
    void render(float deltaTime) {
    tailPos += deltaTime;
    moutPos += deltaTime;
    
    
    pushMatrix();
    
    //rotate(velocition);
    translate(position.x, position.y, position.z);
    scale(size/5.5);

    // Determine xz direction
    float x = velocition.x;
    float z = velocition.z;
    // Rotate around y
    float angle = atan2(-z, x);
    rotateY(angle);
    
    //rotateY(radians(90));
    rotateX(radians(180));
    translate(0, 0.4, 0);
    fill(220, 190, 100);
    sphereDetail(10);
    sphere(0.3);
    translate(0.05, 0.1, 0.2);
    fill(0,0,0);
    sphere(0.1);
    translate(0, 0, -0.4);
    sphere(0.1);
    translate(-0.05, -0.5, 0.2);
    beginShape(TRIANGLE); 
    fill(fishColor);

    
    //tail
    fill(finColor);    
    float tailz = sin(tailPos*tailSpeed)*(0.5);
    vertex(-3, 0,0);
    vertex(-4.5, 1, tailz);
    vertex(-4, 0, tailz);
    
    vertex(-3, 0,0);
    vertex(-4.5, -1, tailz);
    vertex(-4, 0, tailz);
    
    //headfin
    vertex(0,1,0);
    vertex(-0.5, 1.5, -tailz*0.3);
    vertex(-1,1, 0);
    
    vertex(-1,1, 0);
    vertex(-0.5, 1.5, -tailz*0.3);
    vertex(-1.5, 1.5, -tailz*0.3);
    
    //sidefin
    float sidez = (sin(tailPos*tailSpeed)+1.5)/2.5;
    vertex(0,0,0.5);
    vertex(-1, -1, sidez);
    vertex(-1, -0.5, sidez);
    
    vertex(0,0,-0.5);
    vertex(-1, -1, -sidez);
    vertex(-1, -0.5, -sidez);
    
    
    
    //head
    //shape.stroke(0,0,255);
    float mouty = ((sin(moutPos*moutSpeed)-1)*0.5)*(maxMouthUp);
    fill(fishColor);
    normal(0, 0, -1);
    vertex(0,0,-0.5);
    normal(0, -1, 0);
    vertex(0,-1,0);
    normal(1, 0, 0);
    vertex(1, mouty,0);
    
    normal(0, 0, -1);
    vertex(0,0,-0.5);
    normal(1, 0, 0);
    vertex(1, -0.5*mouty,0);
    normal(0, 1, 0);
    vertex(0, 1,0);
     
    normal(1, 0, 0);
    vertex(1, -0.5*mouty,0);
    normal(0, 1, 0);
    vertex(0, 1,0);
    normal(0, 0, 1);
    vertex(0,0,0.5);
    
    normal(1, 0, 0);
    vertex(1, mouty,0);
    normal(0, 0, 1);
    vertex(0,0,0.5);
    normal(0, -1, 0);
    vertex(0,-1,0);
    
    //moutIn
    //down
    fill(160, 30, 30);
    normal(0, 1, 0);
    vertex(1, mouty, 0);
    vertex(0, 0, 0.5);
    fill(0,0,0);
    vertex(0, 0, 0);
    fill(160, 30, 30);
    
    vertex(1, mouty, 0);
    vertex(0, 0, -0.5);
    fill(0,0,0);
    vertex(0, 0, 0);
    
    //up
    fill(160, 30, 30);
    normal(0, -1, 0);
    vertex(1, -mouty*0.5, 0);
    vertex(0, 0, 0.5);
    fill(0,0,0);
    vertex(0, 0, 0);
    fill(160, 30, 30);
    
    vertex(1, -mouty*0.5, 0);
    vertex(0, 0, -0.5);
    fill(0,0,0);
    vertex(0, 0, 0);
    
    
    fill(fishColor);
    //Body front
    normal(0, 0, -1);
    vertex(0,0,-0.5);
    normal(0, 1, 0);
    vertex(0,1,0);
    normal(0, 0, -1);
    vertex(-1, 0, -0.5);
    
    normal(0, 0, -1);
    vertex(-1, 0, -0.5);
     normal(0, 1, 0);
    vertex(0,1,0);
     normal(0, 1, 0);
    vertex(-1, 1, 0);
    
    normal(0, 0, 1);
    vertex(0,0,0.5);
    normal(0, 1, 0);
    vertex(0,1,0);
    normal(0, 0, 1);
    vertex(-1, 0, 0.5);
    
    normal(0, 0, 1);
    vertex(-1, 0, 0.5);
    normal(0, 1, 0);
    vertex(0,1,0);
    normal(0, 1, 0);
    vertex(-1, 1, 0);
    
     normal(0, 0, -1);
    vertex(0,0,-0.5);
      normal(0, -1, 0);
    vertex(0,-1,0);
     normal(0, 0, -1);
    vertex(-1, 0, -0.5);
    
     normal(0, 0, -1);
    vertex(-1, 0, -0.5);
      normal(0, -1, 0);
    vertex(0,-1,0);
      normal(0, -1, 0);
    vertex(-1, -1, 0);
    
     normal(0, 0, 1);
    vertex(0,0,0.5);
       normal(0, -1, 0);
    vertex(0,-1,0);
    normal(0, 0, 1);
    vertex(-1, 0, 0.5);
    
    normal(0, 0, 1);
    vertex(-1, 0, 0.5);
       normal(0, -1, 0);
    vertex(0,-1,0);
       normal(0, -1, 0);
    vertex(-1, -1, 0);
    
    
    
    
    
    //body back
    normal(0, 1, 0);
    vertex(-1,1,0);
    normal(0, 0, -1);
    vertex(-1, 0, -0.5);
    normal(0, 0, -1);
    vertex(-3, 0,0);
    
    normal(0, 0, 1);
    vertex(-1,0, 0.5);
    normal(0, 1, 0);
    vertex(-1,1,0);
    normal(0, 0, 1);
    vertex(-3, 0,0);
    
    normal(0, -1, 0);
    vertex(-1, -1, 0);
    normal(0, 0, -1);
    vertex(-1, 0, -0.5);
    normal(0, 0, -1);
    vertex(-3, 0,0);
    
    normal(0, -1, 0);
    vertex(-1, -1, 0);
    normal(0, 0, 1);
    vertex(-1,0, 0.5);
    normal(0, 0, 1);
    vertex(-3, 0, 0);
    

    
    
    
    
    endShape();
    //sphere(size);
   
    popMatrix();
    
    
 
   // println(position.toString());
  }


  
  
  
}
