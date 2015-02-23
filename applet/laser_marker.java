import processing.core.*; import processing.video.*; import processing.opengl.*; import java.awt.geom.*; import javax.vecmath.Vector2d; import JMyron.*; import processing.opengl.*; import java.applet.*; import java.awt.*; import java.awt.image.*; import java.awt.event.*; import java.io.*; import java.net.*; import java.text.*; import java.util.*; import java.util.zip.*; public class laser_marker extends PApplet {/**
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
int[] colors = {0xffffffff, 0xffff0000, 0xffffff00, 0xff0000ff};

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
float crap = 0.0f;


Point2D.Double intersection;

public void setup() {
  size(1024, 768, OPENGL);
  noCursor();

  //smooth();
  
  jmyron = new JMyron();//make a new instance of the object

  jmyron.start(cam_width, cam_height);//start a capture at 320x240
  jmyron.trackColor(0,255,0,color_threshold); //R, G, B, and range of similarity

  jmyron.minDensity(20); //minimum pixels in the glob required to result in a box

  cam_image = new PImage(cam_width, cam_height);
  
  a_quad[0] = new Point2D.Float(0.0f,0.0f);
  a_quad[1] = new Point2D.Float(1.0f,0.0f);
  a_quad[2] = new Point2D.Float(1.0f,1.0f);
  a_quad[3] = new Point2D.Float(0.0f,1.0f);
    
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

public void change_color(int new_color){
  drips.add(new DripsScreen(new_color));
  drips_position += 1;
}

public void clear_draw_area(){
  wannarotate = false;
  drips.clear(); //delete all colors
  drips.add(new DripsScreen(colors[current_color]));
  drips_position = 0;
}

public void draw() {
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
    crap += 0.01f;
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
  vertex(draw_restriction_coordinates[3][0]-0.1f, draw_restriction_coordinates[3][1]-0.1f, 5000);
  vertex(0, draw_restriction_coordinates[3][1]-0.1f, 5000);
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


public void draw_menu(){
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

public void draw_calibration(){
  noStroke();
  fill(0,0,0,200);
  rect(0,0,width,height);

  noStroke();
  fill(0xffffffff);
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

public void draw_cleararea_calibration(){
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

public void draw_tracking(){
  draw_tracking(1);
}

public void draw_tracking(int strokeweight){
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


public void handle_cleararea(){
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


public void keyPressed() {
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
    crap = 0.0f;
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

public void draw_restriction_reset() {
  draw_restriction_coordinates[0][0] = 0;
  draw_restriction_coordinates[0][1] = 0;
  draw_restriction_coordinates[1][0] = width;
  draw_restriction_coordinates[1][1] = 0;
  draw_restriction_coordinates[2][0] = width;
  draw_restriction_coordinates[2][1] = height;
  draw_restriction_coordinates[3][0] = 0;
  draw_restriction_coordinates[3][1] = height;
}

/**
 * Draws a set of lines with drips.
 */

class DripsScreen {
  protected GeneralPath draw_path;
  protected float[] current_point = new float[2];
  protected float[] previous_point = new float[2];
  protected ArrayList drips;
  protected int colour;
  
  public DripsScreen(int colour){
    clear();
    this.colour = colour;
  }

  public void draw_rotate(){
    pushMatrix();
    translate(width/2, height/2);
    
    if (!should_draw_left) {
      rotateY(crap);
    } else {
      rotateX(-crap);
    };
    
    fill(colour);
    noStroke();    
    strokeWeight(1);
    
    PathIterator i = draw_path.getPathIterator(new AffineTransform());
    int segment_type;
    float z = -50.0f;
    float zo = z;
    float az = 0.0f;
    float[] old = new float[2];
    float[] p = new float[2];
    boolean wasLineSegment = false;
    while(!i.isDone()){

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

          vertex(p[0]+brush_width, p[1]+brush_width, z); // A
          vertex(p[0]-brush_width, p[1]-brush_width, z); // D
      }

     //if (old_segment_type != PathIterator.SEG_MOVETO) {
      zo = z;
      z += 1.5f;
      //if (old[0] != p[0] && old[1] != p[1]) {
      //println(old[0]);
      old[0] = p[0];
      old[1] = p[1];
      // }
      //}

      //old_segment_type = segment_type;

      i.next();
    }
    
    if(wasLineSegment){
      endShape();
      wasLineSegment = false;
    }
    
    popMatrix();
  }
  
  public void draw(){
    //all done in update() for increased performance    
    noFill();
    stroke(colour);
    fill(colour);
    strokeWeight(1);
    //strokeCap(ROUND);
    
    Vector2d vec;
    Vector2d vec2;
    float xdiff;
    float ydiff;
    double[] vecf = new double[2];
    double[] vec2f = new double[2];
    float[] current_point = new float[2];
    float[] previous_point = new float[2];
    int segment_type;
    PathIterator pi = draw_path.getPathIterator(new AffineTransform());
    while(!pi.isDone()){
      segment_type = pi.currentSegment(current_point);

      if(segment_type == PathIterator.SEG_LINETO){
        
        if(should_draw_fatmarker){

          //caluclate normal vector
          xdiff = previous_point[0] - current_point[0];
          ydiff = previous_point[1] - current_point[1];
          
          if(xdiff == 0 && ydiff == 0){
            ellipse(current_point[0], current_point[1], brush_width*2, brush_width*2);
          }
          else{
            vec = new Vector2d(-ydiff, xdiff); //swap x & y for normal vector
            vec.normalize();
            vec.get(vecf);

            vec2 = new Vector2d(xdiff, ydiff); //direction of our stroke
            vec2.normalize();
            vec2.get(vec2f);
            
            noStroke();
            fill(colour);
   //stroke(255);
//noFill();
            beginShape();
            vertex((float)(previous_point[0]+vecf[0]*brush_width), (float)(previous_point[1]+vecf[1]*brush_width));

            vertex((float)(current_point[0]+vecf[0]*brush_width), (float)(current_point[1]+vecf[1]*brush_width));
            vertex((float)(current_point[0]-vecf[0]*brush_width), (float)(current_point[1]-vecf[1]*brush_width));

            vertex((float)(previous_point[0]-vecf[0]*brush_width), (float)(previous_point[1]-vecf[1]*brush_width));

            //back to start (do we need this?)
            //vertex((float)(previous_point[0]+vecf[0]*brush_width), (float)(previous_point[1]+vecf[1]*brush_width)); //back to start point
            endShape();
            
            ellipse(current_point[0], current_point[1], brush_width*2, brush_width*2);
            ellipse(previous_point[0], previous_point[1], brush_width*2, brush_width*2);
          }
        }
        else{ //slant marker
          beginShape();
          vertex(previous_point[0]+brush_width, previous_point[1]+brush_width);
          vertex(current_point[0]+brush_width, current_point[1]+brush_width);
          vertex(current_point[0]-brush_width, current_point[1]-brush_width);
          vertex(previous_point[0]-brush_width, previous_point[1]-brush_width);
          //vertex(previous_point[0]+brush_width, previous_point[1]+brush_width); //back to start - needed?
          endShape();
        }
      }

      previous_point[0] = current_point[0];
      previous_point[1] = current_point[1];
      pi.next();
    }
    
    if(should_draw_drips){
      Iterator i = drips.iterator();
      Drip d;
      while(i.hasNext()){
        d = (Drip)i.next();
        d.draw();
      }
    }
  }
    
  public void update(int x, int y, boolean line){
    previous_point[0] = current_point[0];
    previous_point[1] = current_point[1];
    current_point[0] = x;
    current_point[1] = y;

    if(line){ 
      if(new_drip())
        drips.add(new Drip((int)current_point[0], (int)current_point[1], (int)random(0, height/3)));
    }
  }

  public boolean new_drip(){
    if((int)random(0,drips_probability) == 0)
      return true;
    else
      return false;
  }

  public void moveTo(int x, int y){
    draw_path.moveTo(x, y);
    update(x,y,false);
  }
  
  public void lineTo(int x, int y){
    draw_path.lineTo(x, y);
    update(x,y,true);
  }
  
  public void clear(){
    drips = new ArrayList();
    draw_path = new GeneralPath();
    draw_path.moveTo(0,0);
  }
}


class Drip {
  int ttl_start;
  int ttl;
  int x;
  int y;
  int drip_width;

  public Drip(int x, int y, int ttl){
    this.x = x;
    this.y = y;
    this.ttl = ttl;
    this.ttl_start = ttl;
    this.drip_width = (int)(brush_width/3);
  }
  
  public void draw(){
    if (!should_draw_left) {
      quad(x-drip_width/2, y-drip_width/2,
          x+drip_width/2, y+drip_width/2,
          x+drip_width/2, y+(ttl_start-ttl),
          x-drip_width/2, y+(ttl_start-ttl));
      ellipse(x, y+(ttl_start-ttl), drip_width-2, drip_width-2);
    } else {
      quad(x+drip_width/2, y-drip_width/2,
          x-(ttl_start-ttl), y-drip_width/2,
          x-(ttl_start-ttl), y+drip_width/2,
          x-drip_width/2, y+drip_width/2);
      ellipse(x-(ttl_start-ttl), y, drip_width-2, drip_width-2);
    };
    
    if(!is_dead())
      ttl -= 1;
  }
  
  public boolean is_dead(){
    return ttl < 0;
  }
}

public void update_laser_position(){
  if(pointer_on_screen){
    if(pointer_is_moving){
      ((DripsScreen)drips.get(drips_position)).lineTo(pointer[0], pointer[1]);
    }
    else{
      ((DripsScreen)drips.get(drips_position)).moveTo(pointer[0], pointer[1]);
    }
  }
}

public void track_laser(){
  noCursor();
  jmyron.update(); //update the camera view
  
  int brightestX = 0; // X-coordinate of the brightest video pixel
  int brightestY = 0; // Y-coordinate of the brightest video pixel

  int[][] blobs = jmyron.globCenters();//get the center points

  if(blobs.length > 1){
    // Draw a large, yellow circle at the brightest pixel
    pointer_is_visible = true;
    
    brightestX = blobs[1][0];
    brightestY = blobs[1][1];
        
    laser_coordinates[0] = brightestX;
    laser_coordinates[1] = brightestY;
    pointer_camera_coordinates[0] = brightestX;
    pointer_camera_coordinates[1] = brightestY;
 
    //if the brightest spot is inside the beamer area
    int[] xpoints = new int[4];
    int[] ypoints = new int[4];
    for(int i=0; i<4; i++){
      xpoints[i] = beamer_coordinates[i][0];
      ypoints[i] = beamer_coordinates[i][1];
    }
    Polygon beamer_area = new Polygon(xpoints, ypoints, 4); //refactor me to use a polygon all the way

    if(beamer_area.contains(brightestX, brightestY)){
      if (pointer_on_screen == true){
        pointer_old[0] = pointer[0];
        pointer_old[1] = pointer[1];
        pointer_is_moving = true;
      }
      else{
        pointer_is_moving = false;
      }
      pointer_on_screen = true;


      //transform camera coordinates to beamer (screen) coordinates
      
      //beamer_coordinates contains the calibrated area of the beamer 
      Point2D.Double a = new Point2D.Double((double)beamer_coordinates[0][0], (double)beamer_coordinates[0][1]);
      Point2D.Double b = new Point2D.Double((double)beamer_coordinates[1][0], (double)beamer_coordinates[1][1]);
      Point2D.Double c = new Point2D.Double((double)beamer_coordinates[2][0], (double)beamer_coordinates[2][1]);
      Point2D.Double d = new Point2D.Double((double)beamer_coordinates[3][0], (double)beamer_coordinates[3][1]);

      Line2D.Double a_b = new Line2D.Double(a, b);
      Line2D.Double d_c = new Line2D.Double(d, c);
      Line2D.Double d_a = new Line2D.Double(d, a);
      Line2D.Double c_b = new Line2D.Double(c, b);
      
      double l_a_b = line_length(a_b);
      double l_d_a = line_length(d_a);

      Point2D.Double flucht_y = new Point2D.Double();
      Point2D.Double flucht_x = new Point2D.Double();
      getLineLineIntersection(a_b, d_c, flucht_x);
      getLineLineIntersection(d_a, c_b, flucht_y);
      
      Point2D.Double pointer_on_webcam = new Point2D.Double((double)brightestX, (double)brightestY);
      
      Line2D.Double x_p = new Line2D.Double(flucht_x, pointer_on_webcam);
      Line2D.Double y_p = new Line2D.Double(flucht_y, pointer_on_webcam);
      
      Point2D.Double y_on_A = new Point2D.Double();
      Point2D.Double x_on_B = new Point2D.Double();

      getLineLineIntersection(x_p, d_a, y_on_A);
      getLineLineIntersection(y_p, a_b, x_on_B);
      
      double l_a_y_on_A = line_length(new Line2D.Double(a, y_on_A));
      double l_a_x_on_B = line_length(new Line2D.Double(a, x_on_B));
      
      intersection = y_on_A;

      //x coordinate between 0 and 1
      double the_y =  l_a_y_on_A / l_d_a;
      double the_x = l_a_x_on_B / l_a_b;

      pointer[0] = (int)(the_x * width);
      pointer[1] = (int)(the_y * height);      
    }
    else {
      pointer_on_screen = false;
    }
  }
  else{
    pointer_is_visible = false;
    pointer_on_screen = false;
  }
}

public void track_mouse_as_laser(){
  jmyron.update();
  int brightestX = 0; // X-coordinate of the brightest video pixel
  int brightestY = 0; // Y-coordinate of the brightest video pixel

  cursor(ARROW);
  if(mousePressed && (mouseButton == LEFT)){
    // Draw a large, yellow circle at the brightest pixel
    pointer_is_visible = true;
    
    brightestX = mouseX;
    brightestY = mouseY;
        
    laser_coordinates[0] = mouseX;
    laser_coordinates[1] = mouseX;
    pointer_camera_coordinates[0] = mouseX;
    pointer_camera_coordinates[1] = mouseX;

    if (pointer_on_screen == true){
      pointer_old[0] = pointer[0];
      pointer_old[1] = pointer[1];
      pointer_is_moving = true;
    }
    else{
      pointer_is_moving = false;
    }
    pointer_on_screen = true;

    pointer[0] = (int)(mouseX);
    pointer[1] = (int)(mouseY);      

  }
  else{
    pointer_is_visible = false;
    pointer_on_screen = false;
  }
}

public static boolean getLineLineIntersection(Line2D.Double l1,
                                       Line2D.Double l2,
                                       Point2D.Double intersection)
{
    //if (!l1.intersectsLine(l2))
    //    return false;
        
    double  x1 = l1.getX1(), y1 = l1.getY1(),
            x2 = l1.getX2(), y2 = l1.getY2(),
            x3 = l2.getX1(), y3 = l2.getY1(),
            x4 = l2.getX2(), y4 = l2.getY2();
    
    intersection.x = det(det(x1, y1, x2, y2), x1 - x2,
                         det(x3, y3, x4, y4), x3 - x4)/
                     det(x1 - x2, y1 - y2, x3 - x4, y3 - y4);
    intersection.y = det(det(x1, y1, x2, y2), y1 - y2,
                         det(x3, y3, x4, y4), y3 - y4)/
                     det(x1 - x2, y1 - y2, x3 - x4, y3 - y4);

    return true;
}

public static double det(double a, double b, double c, double d)
{
    return a * d - b * c;
}

public double line_length(Line2D.Double l){
  Point2D.Double p1 = (Point2D.Double)l.getP1();
  Point2D.Double p2 = (Point2D.Double)l.getP2();
  
  double x = (p1.getX() - p2.getX());
  double y = (p1.getY() - p2.getY());
  
  return (double)sqrt((float)(x*x+y*y));
}



int colour = 0;
int cspeed = 7;
boolean colour_direction = true;
int times = 0;

public void warning_intro() {
  PFont f = loadFont("Univers66.vlw.gz");
  textFont(f, 20);
  if (colour_direction && colour < 256) {
    colour += cspeed;
  }
  if (!colour_direction && colour > 0) {
    colour += -cspeed;
  }
  if (!colour_direction && colour <= 0) {
    colour_direction = true;
    times++;
  }
  if (colour_direction && colour > 255) {
    colour_direction = false;
    times++;
  }

  translate(height/2, width/2);
  textAlign(CENTER);

  if (colour > 255)
    colour = 255;
  else if (colour < 0)
    colour = 0;
  noStroke();
  if (times < 10) {
    fill(colour,0,0);
    text("WARNING", 0, 0);
  }
  else if (times < 20) {
    fill(colour);
    text("FUCKING LETHAL LASER", 0, 0);
  }
  translate(0, 0);
}

  static public void main(String args[]) {     PApplet.main(new String[] { "laser_marker" });  }}