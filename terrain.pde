class Terrain {
  int sizeX;
  int sizeZ;
  float frequency = 30;
  float amplitude = 15;
  
  float cellSize = 0.2f;
  
  PShape terrainShape;

  private PVector tempNormal = new PVector();

  Terrain(int sizeX, int sizeZ) {
    this.sizeX = sizeX;
    this.sizeZ = sizeZ;
  }
  
  void render() {
    shape(terrainShape);
  }
  
  float sign(float x){
    if (x < 0) return -1;
    else return 1;
  }
  
  float cellPos(float x) {
    return sign(x) * pow(abs(x), 1.2) * cellSize;
  }
  
  void init() {
    fill(220, 160, 120);
    terrainShape = createShape();
    terrainShape.beginShape(TRIANGLE);
    // terrainShape.stroke(0,255, 0);

    for (int z = -sizeZ; z < sizeZ; z++) {
      for (int x = -sizeX; x < sizeX; x++) {
        float x1 = cellPos(x);
        float x2 = cellPos(x+1);
        float z1 = cellPos(z);
        float z2 = cellPos(z+1);
        
        addVertex(x1, z1);
        addVertex(x1, z2);
        addVertex(x2, z1);

        addVertex(x2, z1);
        addVertex(x2, z2);
        addVertex(x1, z2);
        
      }
    }
    
    terrainShape.endShape();
  }
  
  void addVertex(float x, float z) {
    normalAt(x, z, tempNormal);
    float y = heightAt(x, z);
    terrainShape.normal(tempNormal.x, tempNormal.y, tempNormal.z);
    terrainShape.vertex(x, y, z);
  }
  
  float heightAt(float x, float z) {
    float h = 2;
    
    float a = 3.0;
    float s = 0.01;
    float sx = noise(s*x+39.123, s*z+1311.1) * a * 0.5 + x;
    float sz = noise(s*x+113.13, s*z+13.83) * a * 0.5 + z;

    float scale = 5; 
    h += noise(sx/frequency+32.123, sz/frequency+7657.234) * amplitude;
    h += noise(123.321 + sx/(frequency*scale), 7321.321 + sz/(frequency*scale)) * amplitude * 0.2;
    
    h += (x*x + z*z) * 0.01 - 4;
    
    return h;
  }

  void normalAt(float x, float z, PVector normal) {
    // Based on: https://stackoverflow.com/questions/13983189/opengl-how-to-calculate-normals-in-a-terrain-height-grid
    float d = cellSize;
    float hL = heightAt(x-d, z);
    float hR = heightAt(x+d, z);
    float hD = heightAt(x, z-d);
    float hU = heightAt(x, z+d);
    normal.x = -(hL - hR);
    normal.z = -(hD - hU);
    normal.y = -d;
    normal.normalize();
  }
  
  
}
