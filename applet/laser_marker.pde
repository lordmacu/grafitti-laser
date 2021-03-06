/**
 * Laserguided Graffiti System 2.0
 * by Michael Zeltner & Florian Hufsky // Graffiti Research Lab Vienna
 */

/*
NEXT
  * save previous calibration (for when we change code and restart)

TODO
  * !maybe! smooth laser position (use blob nearest to old position, interpolate blob position -> no jittering?)
  * speed optimize calibration/coorinate transformation: caluclate stuff that only changes on calibration only on calibration. 

  * make the values settable (sensitivity etc)

  * !maybe! bezier curves for increased curve smoothness
  * variable output resolution
  
  * intro screen: laser graffiti
  ** please press space to start calibration etc. step out of the image
*/

import processing.video.*;
import processing.opengl.*;
import java.awt.geom.*;
import javax.vecmath.Vector2d;
import JMyron.*;

//settings
int color_threshold = 160;
int brush_width = 18-2;
int drips_probability = 20;

//jmyron camera laser tracking
JMyron jmyron;
PImage cam_image;
int cam_width = 320;
int cam_height = 240;

//the four edges where the beamer is located int he camera picture
//top, right, bottom, left (like shorthands in CSS)
int[][] beamer_coordinates = new int[4][2];
int[][] cleararea_coordinates = new int[4][2];
int[][] draw_restriction_coordinates = new int[4][2];



int current_color = 0;
int[] colors = {#ffffff, #ff0000, #ffff00, #0000ff};

boolean pointer_on_screen;
boolean pointer_is_moving;
boolean pointer_is_visible;
int[] pointer = new int[2];
int[] pointer_old = new int[2];
int[] laser_coordinates = new int[2];
int[] pointer_camera_coordinates = new int[2];

//used for the actual drawing
ArrayList drips = new ArrayList();
int drips_position;

//helpers for calibration
int calibration_point; //used for running through the four edges during calibration
int cleararea_calibration_point; //used for running through the four edges during calibration
Point2D[] a_quad = new Point2D[4];

boolean should_draw_menu = true;
boolean should_draw_outline = false;
boolean should_draw_framerate = false;
boolean should_draw_fatmarker = true;
boolean should_draw_drips = true;
boolean should_use_mouse = false;
boolean should_draw_left = false;

//rotation
boolean wannarotate = false;
float crap = 0.0;


Point2D.Double intersection;

void setup() {
  size(1024, 768, OPENGL);
  noCursor();

  //smooth();
  
  jmyron = new JMyron();//make a new instance of the object

  jmyron.start(cam_width, cam_height);//start a capture at 320x240
  jmyron.trackColor(0,255,0,color_threshold); //R, G, B, and range of similarity

  jmyron.minDensity(20); //minimum pixels in the glob required to result in a box

  cam_image = new PImage(cam_width, cam_height);
  
  a_quad[0] = new Point2D.Float(0.0,0.0);
  a_quad[1] = new Point2D.Float(1.0,0.0);
  a_quad[2] = new Point2D.Float(1.0,1.0);
  a_quad[3] = new Point2D.Float(0.0,1.0);
    
  //top left
  beamer_coordinates[0][0] = 50;
  beamer_coordinates[0][1] = 10;
  //top right
  beamer_coordinates[1][0] = cam_width-50;
  beamer_coordinates[1][1] = 65;
  //bottom left
  beamer_coordinates[2][0] = cam_width-30;
  beamer_coordinates[2][1] = cam_height-40;
  //bottom right
  beamer_coordinates[3][0] = 5;
  beamer_coordinates[3][1] = cam_height-15;
  
  draw_restriction_reset();
  
  pointer_on_screen = false;
  pointer_is_moving = false;
  
  PFont f = loadFont("Univers66.vlw.gz");
  textFont(f, 16);
    
  calibration_point = 4;
  cleararea_calibration_point = 4;

  drips_position = -1;
  current_color = 0;
  change_color(colors[0]);
}

void change_color(int new_color){
  drips.add(new DripsScreen(new_color));
  drips_position += 1;
}

void clear_draw_area(){
  wannarotate = false;
  drips.clear(); //delete all colors
  drips.add(new DripsScreen(colors[current_color]));
  drips_position = 0;
}

void draw() {
  background(0);
  ortho(0, width, 0, height, -5000, 5000);
  translate((width/2), (-height/2));
  
  smooth();

  //compute tasks
  //repositionRectangleByMouse();
  if(should_use_mouse)
    track_mouse_as_laser();
  else
    track_laser();

  update_laser_position();
  handle_cleararea();
  //draw the lines & drips
  if(wannarotate) {
    crap += 0.01;
    Iterator i = drips.iterator();
    while(i.hasNext()) {
      DripsScreen d = (DripsScreen)i.next();
      d.draw_rotate();
    }
    
  }
  else{
    Iterator i = drips.iterator();
    while(i.hasNext()){
      DripsScreen d = (DripsScreen)i.next();
      d.draw();
    }
  }
  
  strokeWeight(1);
  noStroke();
  fill(0,0,0);
  beginShape();
  vertex(0, 0, 5000);
  vertex(width, 0, 5000);
  vertex(width, height, 5000);
  vertex(0, height, 5000);
  vertex(0, draw_restriction_coordinates[3][1], 5000);
  vertex(draw_restriction_coordinates[3][0], draw_restriction_coordinates[3][1], 5000);
  vertex(draw_restriction_coordinates[2][0], draw_restriction_coordinates[2][1], 5000);
  vertex(draw_restriction_coordinates[1][0], draw_restriction_coordinates[1][1], 5000);
  vertex(draw_restriction_coordinates[0][0], draw_restriction_coordinates[0][1], 5000);
  vertex(draw_restriction_coordinates[3][0]-0.1, draw_restriction_coordinates[3][1]-0.1, 5000);
  vertex(0, draw_restriction_coordinates[3][1]-0.1, 5000);
  endShape(CLOSE);
  
  if(should_draw_menu){
    noStroke();
    fill(0,0,0,128);
    rect(0,0,width,height);
    draw_menu();
    
    pushMatrix();
    translate(0, height-cam_height);
    float half_screen = (width/2)/cam_width;
    scale(half_screen, half_screen);
    draw_tracking();
    popMatrix();
  }

  if(calibration_point != 4)
    draw_calibration();
  else if(cleararea_calibration_point != 4)
    draw_cleararea_calibration();
    
  if(should_draw_framerate){
    noStroke();
    fill(255,255,255);
    textAlign(LEFT);
    text(frameRate, 10, 20);
  }
  
  if(should_draw_outline){
    noFill();
    stroke(255,255,255,255);
    strokeWeight(4);
    beginShape();
    vertex(draw_restriction_coordinates[0][0], draw_restriction_coordinates[0][1]);
    vertex(draw_restriction_coordinates[1][0], draw_restriction_coordinates[1][1]);
    vertex(draw_restriction_coordinates[2][0], draw_restriction_coordinates[2][1]);
    vertex(draw_restriction_coordinates[3][0], draw_restriction_coordinates[3][1]);
    endShape(CLOSE);
    
    //rect(0,0,width,height);    
    //rect(0+1,0+1,width-2,height-2);    
    //rect(0+2,0+2,width-4,height-4);    
    //rect(0+3,0+3,width-6,height-6);    
  }
}


void draw_menu(){
  pushMatrix();
  translate(10, 20);
  fill(255,255,255);
  noStroke();
  int x = 0;
  int y = 0;
  
  textAlign(LEFT);
  //text("                         /// laser marker  ///", x, y);
  
  y += 15;
  
  ArrayList lines = new ArrayList();
  lines.add("color threshold " + color_threshold);
  lines.add("brush weight: " + brush_width);
  lines.add("drips probability: " + drips_probability);
  lines.add("");
  
  Iterator i = lines.iterator();
  String s;
  while(i.hasNext()){
    s = (String)i.next();
    y += 15;
    text(s, x, y);
  }
  
  
  textAlign(RIGHT);
  x = width-20;
  y = 0;
  
  lines = new ArrayList();
  lines.add("r - next calibration point");
  lines.add("x - next cleararea point");
  lines.add("l - use 3:4 aspect ratio");
  lines.add("c - clear draw area");
  lines.add("m - toggle menu");
  lines.add("f - toggle framerate");
  lines.add("o - toggle outline");
  lines.add("b - fat marker");
  lines.add("d - toggle drips");
  lines.add("0 (nr) - use mouse mode");
    
  i = lines.iterator();
  while(i.hasNext()){
    s = (String)i.next();
    y += 15;
    text(s, x, y);
  }

  popMatrix();
}

void draw_calibration(){
  noStroke();
  fill(0,0,0,200);
  rect(0,0,width,height);

  noStroke();
  fill(#ffffff);
  Point2D point = a_quad[calibration_point];
  
  int c_size = width/15; //calibration cicrlce with
  int c_x = (int)(point.getX()*width);
  int c_y = (int)(point.getY()*height);
  
  if (mousePressed) {
    ellipse(mouseX, mouseY, c_size, c_size);
    draw_restriction_coordinates[calibration_point][0] = mouseX;
    draw_restriction_coordinates[calibration_point][1] = mouseY;
  } else {
    ellipse(c_x, c_y, c_size, c_size);
  }
  
  if (pointer_is_visible && mousePressed) {
    beamer_coordinates[calibration_point][0] = pointer_camera_coordinates[0]-draw_restriction_coordinates[calibration_point][0];
    beamer_coordinates[calibration_point][1] = pointer_camera_coordinates[1]-draw_restriction_coordinates[calibration_point][1];
  } else if (pointer_is_visible) {
    beamer_coordinates[calibration_point][0] = pointer_camera_coordinates[0];
    beamer_coordinates[calibration_point][1] = pointer_camera_coordinates[1];
  }
}

void draw_cleararea_calibration(){
  noStroke();
  
  pushMatrix();
  
  scale((float)width/(float)cam_width, (float)height/(float)cam_height);
  draw_tracking(3);
  
  if(pointer_is_visible){
    cleararea_coordinates[cleararea_calibration_point][0] = pointer_camera_coordinates[0];
    cleararea_coordinates[cleararea_calibration_point][1] = pointer_camera_coordinates[1];
  }
  
  popMatrix();
}

void draw_tracking(){
  draw_tracking(1);
}

void draw_tracking(int strokeweight){
  //draw the normal image of the camera
  int[] img = jmyron.image();
  cam_image.loadPixels();
  arraycopy(img, cam_image.pixels);
  cam_image.updatePixels();
  image(cam_image, 0, 0);
  
  int[][] b = jmyron.globBoxes();

  //draw the boxes
  noFill();
  stroke(255,0,0);
  for(int i=0;i<b.length;i++){
    rect( b[i][0] , b[i][1] , b[i][2] , b[i][3] );
  }
  
  //draw the beamer
  noFill();
  stroke(255, 255, 255, 128);
  strokeWeight(strokeweight);
  //strokeCap(SQUARE);
  quad(beamer_coordinates[0][0], beamer_coordinates[0][1],
       beamer_coordinates[1][0], beamer_coordinates[1][1],
       beamer_coordinates[2][0], beamer_coordinates[2][1],
       beamer_coordinates[3][0], beamer_coordinates[3][1]
       );
  
  //draw the clear area
  stroke(255,0,0, 128);
  quad(cleararea_coordinates[0][0], cleararea_coordinates[0][1],
       cleararea_coordinates[1][0], cleararea_coordinates[1][1],
       cleararea_coordinates[2][0], cleararea_coordinates[2][1],
       cleararea_coordinates[3][0], cleararea_coordinates[3][1]
       );
  
  //draw mah lazer!!!
  if(pointer_is_visible){
    int e_size = cam_width/10;
    noStroke();
    fill(255,0,0,128);
    ellipse(pointer_camera_coordinates[0], pointer_camera_coordinates[1], e_size, e_size);
  }
}


void handle_cleararea(){
  if(pointer_is_visible){
    int[] xpoints = new int[4];
    int[] ypoints = new int[4];
    for(int i=0; i<4; i++){
      xpoints[i] = cleararea_coordinates[i][0];
      ypoints[i] = cleararea_coordinates[i][1];
    }
    Polygon clear_area = new Polygon(xpoints, ypoints, 4); //refactor me to use a polygon all the way
    
    if(clear_area.contains(pointer_camera_coordinates[0], pointer_camera_coordinates[1]))
      clear_draw_area();
  }
}


void keyPressed() {
  if(key == 'l') {
    should_draw_left = !should_draw_left;
  }
  if(key == 'a'){
    current_color += 1;
    if (current_color == colors.length)
      current_color = 0;
    change_color(colors[current_color]);
  }
  if(keyCode == DOWN){
    current_color = 0;
    change_color(colors[0]);
  }
  if(keyCode == LEFT){
    current_color = 1;
    change_color(colors[1]);
  }
  if(keyCode == RIGHT){
    current_color = 2;
    change_color(colors[2]);
  }
  if(keyCode == UP){
    current_color = 3;
    change_color(colors[3]);
  }
  if(key == '3' || key == ' '){
    wannarotate = !wannarotate;
    rotateX(0);
    rotateY(0);
    crap = 0.0;
  }
  if(key == 'm')
    should_draw_menu = !should_draw_menu;
  if(key == 'f')
    should_draw_framerate = !should_draw_framerate;
  if(key == 'o')
    should_draw_outline = !should_draw_outline;
  if(key == 'b' || keyCode == ENTER || keyCode == RETURN)
    should_draw_fatmarker = !should_draw_fatmarker;
  if(key == 'd')
    should_draw_drips = !should_draw_drips;
  if(key == '0')
    should_use_mouse = !should_use_mouse;
  if(key == 'c'){
    clear_draw_area();
  }
  if(key == 'r'){
    calibration_point += 1;
    if(calibration_point == 4){
      clear_draw_area(); //calibration finished - clear draw area
    }
    if(calibration_point == 5){
      calibration_point = 0;
    }
  }
  if(key == 'x'){
    cleararea_calibration_point += 1;
    if(cleararea_calibration_point == 4){
      clear_draw_area(); //calibration finished - clear draw area
    }
    if(cleararea_calibration_point == 5){
      cleararea_calibration_point = 0;
      draw_restriction_reset();
    }
  }
  if (key == '-') {
    brush_width -= 1;
  }
  if (key == '+') {
    brush_width += 1;
  }
  if (key == '.') {
     color_threshold += 20;
    jmyron.trackColor(0,255,0,color_threshold);
  }
  if (key == ',') {
    color_threshold -= 20;
    jmyron.trackColor(0,255,0,color_threshold);
  }
  if (key == 's') {
    
  }
}

void draw_restriction_reset() {
  draw_restriction_coordinates[0][0] = 0;
  draw_restriction_coordinates[0][1] = 0;
  draw_restriction_coordinates[1][0] = width;
  draw_restriction_coordinates[1][1] = 0;
  draw_restriction_coordinates[2][0] = width;
  draw_restriction_coordinates[2][1] = height;
  draw_restriction_coordinates[3][0] = 0;
  draw_restriction_coordinates[3][1] = height;
}
