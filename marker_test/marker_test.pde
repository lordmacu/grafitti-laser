import processing.opengl.*;
import java.awt.geom.*;

boolean pressedInPreviousFrame = false;
GeneralPath draw_path;
ArrayList drips;
int flare = 1;
int mw = 12-2;
float crap = 0.0;
boolean wannarotate = false;
float[] old = new float[2];
float zo = 0.0;
boolean drawd = false;

class Drip {
  int ttl_start;
  int ttl;
  int x;
  int y;

  public Drip(int x, int y, int ttl){
    this.x = x;
    this.y = y;
    this.ttl = ttl;
    this.ttl_start = ttl;
  }
  
  public void draw(){
    fill(255);
    noStroke();
    quad(x-(mw+9),y-(mw+9),x+(mw+9),y+(mw+9),x+(mw+7),y+(mw+7),x-(mw+7),y-(mw+7));
    quad(x-5,y-5,x+5,y+5,x+5,y+(ttl_start-ttl),x-5,y+(ttl_start-ttl));
    //beginShape();
    //vertex(x, y-8+(ttl_start-ttl));
    //vertex(x+1, y+(ttl_start-ttl));
    //vertex(x+2, y+2+(ttl_start-ttl));
    //vertex(x, y+8+(ttl_start-ttl));
    //vertex(x-2, y+(ttl_start-ttl));
    //vertex(x-1, y+2+(ttl_start-ttl));
    //endShape();
    //line(x,y,x,y+(ttl_start-ttl));
          ellipse(x, y+(ttl_start-ttl), 4, 4); 

    if(!is_dead()) {
      ttl -= 1;
      //ellipse(x, y+(ttl_start-ttl)-2, 6, 6);
    } else {

    }
    
  }
  
  public boolean is_dead(){
    return ttl < 0;
  }
}


void setup() {
  size(1024, 768, OPENGL);

  draw_path = new GeneralPath();
  draw_path.moveTo(0,0);
  drips = new ArrayList();
  //frameRate(1);
};

boolean new_drip() {
////  if (pmouseX != mouseX) {
    if((int)random(0,10) == 0) {
      return true;
    } else {
      return false;
//  } else {
//      return false;
//  }
    }
//return false;
}

void draw() {
  background(0);
  ortho(0,width, 0,height, -5000,5000);
  translate((width/2), (-height/2));
  if (!wannarotate) {
    //ortho(0,width, 0,height, -1200,1200);
    //translate((width/2), (-height/2));
  } else {
    //perspective();
    crap += 0.01;
    translate(width/2, height/2);
    //pointLight(255, 255, 255, 35, 40, 36);
    //rotateY(crap);
    //rotateX(crap);
    //spotLight(255, 255, 255, 80, 20, 40, -1, 0, 0, PI/crap, 2);
    rotateY(crap);
    //rotateZ(crap);
    //rotateY(PI/mouseY-(width/2)*5);
    //rotateX(PI/mouseX-(width/2)*5);
  }


  fill(255);
  stroke(255);
  //noStroke();
  strokeWeight(1);
      
  PathIterator i = draw_path.getPathIterator(new AffineTransform());
  int segment_type;
  float z = -50.0;
  float zo = z;
  float az = 0.0;
  float[] p = new float[2];
  int crappyi = 0;
  boolean wasLineSegment = false;
  while(!i.isDone() && wannarotate){
    
    segment_type = i.currentSegment(p);
     //crap += 0.1;
     //noFill();
     //box(200);
     //fill(255);
    //rotateX(crap);
    //rotateY(crap);
    if(segment_type == PathIterator.SEG_LINETO && !wasLineSegment) {
      beginShape(TRIANGLE_STRIP);
      wasLineSegment = true;
    }
    if(segment_type == PathIterator.SEG_MOVETO && wasLineSegment) {
      endShape();
      wasLineSegment = false;
    }
    if(segment_type == PathIterator.SEG_LINETO) {
    if (wannarotate) {
        p[0] = p[0]-(width/2);
        p[1] = p[1]-(height/2);
    }

        vertex(p[0]+mw, p[1]+mw, z); // A
        vertex(p[0]-mw, p[1]-mw, z); // D
    }
   
   //if (old_segment_type != PathIterator.SEG_MOVETO) {
    zo = z;
    z += 4;
    //if (old[0] != p[0] && old[1] != p[1]) {
    //println(old[0]);
    old[0] = p[0];
    old[1] = p[1];
    // }
    //}
    
    //old_segment_type = segment_type;
    
    i.next();
  }
  
    while(!i.isDone() && !wannarotate){
    
    segment_type = i.currentSegment(p);
     //crap += 0.1;
     //noFill();
     //box(200);
     //fill(255);
    //rotateX(crap);
    //rotateY(crap);
    if(segment_type == PathIterator.SEG_LINETO) {
            beginShape();
        vertex(old[0]+mw, old[1]+mw, zo); // A
        vertex(p[0]+mw, p[1]+mw, z); // B
        vertex(p[0]-mw, p[1]-mw, z); // C
        vertex(old[0]-mw, old[1]-mw, zo); // D
        vertex(old[0]+mw, old[1]+mw, zo); // A
        endShape();
    }
   
   //if (old_segment_type != PathIterator.SEG_MOVETO) {
    zo = z;
    z += 3.5;
    //if (old[0] != p[0] && old[1] != p[1]) {
    //println(old[0]);
    old[0] = p[0];
    old[1] = p[1];
    // }
    //}
    
    //old_segment_type = segment_type;
    
    i.next();
  }
      
  if (mousePressed && !wannarotate) {
    if(pressedInPreviousFrame) {
      draw_path.lineTo(mouseX, mouseY);
      //println(zwrong);
      if(new_drip()) {
        for (int fi=0; fi<flare; fi++) {
          //drips.add(new Drip(mouseX+(int)random(-30,30), mouseY+(int)random(-30,30), (int)random(1,4)));
          drips.add(new Drip((int)old[0], (int)old[1], (int)random(0, height/5)));
        }
      }
    } 
  }else {
      draw_path.moveTo(mouseX,mouseY);
    }
  if (drawd) {
  Iterator drip = drips.iterator();
  Drip d;
  while(drip.hasNext()){
    d = (Drip)drip.next();
    d.draw();
  }
  }
 
      
  pressedInPreviousFrame = mousePressed;
};

void keyPressed() {
  if(key == 'c'){
    clear_draw_area();
    wannarotate = false;
    rotateX(0);
    rotateY(0);
    crap = 0.0;
  }
  if(key == '3') {
    wannarotate = !wannarotate;    
    drawd = false;
    rotateX(0);
    rotateY(0);
    crap = 0.0;
  }
  if(key == 'd') {
    drawd = !drawd;
  }
}

void clear_draw_area() {
  drips = new ArrayList();
  draw_path = new GeneralPath();
  draw_path.moveTo(0, 0);
}

