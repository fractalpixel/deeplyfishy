
String credits = 
  "Terrain & Camera:\n"+
  "FractalPixel\n"+
  "\n"+
  "Fishes & Fish AI:\n"+
  "Shiera\n"+
  "\n"+
  "Music:\n"+
  "\"Final Battle of the Dark Wizards\" \nby Kevin MacLeod (incompetech.com)\n"+
  "Licensed under Creative Commons: \nBy Attribution 3.0 License\n"+
  "\n";
  
class Scroller {
  
  float yPos = 1000;
  PFont font;
  float creditsTime = 3f * 60f;
  
  Scroller() {
    String fontName = "Cinzel-Regular.ttf";    
    font = createFont(fontName,128);
    textFont(font);
    textMode(SHAPE);
  }
  
  void render(float time, float deltaTime) {
    if (time > creditsTime) {
      yPos -= deltaTime*200f;
      fill(255, 255, 255);
      textAlign(CENTER, TOP);
      pushMatrix();
      scale(0.01f);
      text(credits, 0, yPos,0);
      popMatrix();
    }
  }
}
