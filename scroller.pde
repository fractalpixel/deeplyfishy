
String credits = 
  "Terrain & Camera:\n"+
  "FractalPixel\n"+
  "\n"+
  "Fishes & Fish AI\n"+
  "Shiera\n"+
  "\n"+
  "Music:\n"+
  "'Final Battle of the Dark Wizards' \nby Kevin MacLeod (incompetech.com)\n"+
  "Licensed under Creative Commons: \nBy Attribution 3.0 License\n"+
  "\n";
  
class Scroller {
  
  float yPos = 1000;
  PFont font;
  
  Scroller() {
    String fontName = "Cinzel-Regular.ttf";    
    font = createFont(fontName,128);
    textFont(font);
  }
  
  void render(float time, float deltaTime) {
    
    yPos -= deltaTime*200f;
    
    fill(255, 255, 255);
    textAlign(CENTER, TOP);
    pushMatrix();
    scale(0.01f);
    blendMode(LIGHTEST);
    text(credits, 0, yPos,0);
    popMatrix();
    blendMode(REPLACE);
  }
}
