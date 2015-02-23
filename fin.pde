

import processing.video.*;
import processing.opengl.*;
import java.awt.geom.*;
import javax.vecmath.Vector2d;
import JMyron.*;
import java.util.*; 
import java.awt.*;
float diam; // width of ellipse and weight of line
int contador=0;
float previus1=0;
float previus2=0;
float current1=0;
float current2=0;
float prueb;
int last = 0;
int m = 0;
PShape pincel1;
int xpaleta=0;
Menuhilo menuslide;

boolean contadorf=false;
int segundosparaesto=1;
PImage jpegs1;
PImage jpegs2;
float randompt;
PShape pincelsvg;

int numPixels=0;
//int color_threshold = 730;
int color_threshold = 765;

int color_nothreshold=0;
int brush_width = 26;
int drip_width = brush_width/2;
int drips_probability = 3;
int zcall = -50;
color currPixColor;
boolean stencil = false;

PImage img;
PImage primera1;
PImage primera;
PImage verdecarro;
PImage rojocarro;
PImage azulcarro;
PImage naranjacarro;
PImage header;



boolean colaiderrojo;
boolean colaiderazul;

boolean colaiderslide;
boolean colaiderverde;
boolean colaidernaranja;
boolean colaidernegro;

JMyron jmyron;
PImage cam_image;
PImage brush1;
PImage logos;

int cam_width = 320;
int cam_height = 240;

int[][] coordinates_projector = new int[4][2];
int[][] coordinates_cleararea = new int[4][2];

int current_color = 0;
int current_estilos=0;
int[] colors = { 
  #f40000, #00B4FF, #A7FF00, #FF9000
};
int[] estilos = { 
  1, 2, 3, 4, 5, 6, 7
};

int current_brush1=0;

boolean stylo;
boolean marcadorcolor=true;

boolean neon= false;
boolean pointer_on_screen;
boolean pointer_is_moving;
boolean pointer_is_visible;
int[] pointer = new int[2];
int[] pointer_old = new int[2];
int[] laser_coordinates = new int[2];
int[] pointer_camera_coordinates = new int[2];

PImage[] brushpruebas = new PImage[6];

//used for the actual drawing
ArrayList drips = new ArrayList();
ArrayList nnono = new ArrayList();

int drips_position;

//helpers for calibration
int calibration_point; //used for running through the four edges during calibration
int cleararea_calibration_point; //used for running through the four edges during calibration
Point2D[] a_quad = new Point2D[4];
int spry = 1;
PShape group, punto1, punto2, punto3, punto4;

boolean paleta = false;

boolean carrorojo = false;
boolean carroverde = false;
boolean carrozul = false;
boolean carronaranja = false;

boolean should_draw_menu = true;
boolean should_draw_outline = false;
boolean should_draw_framerate = false;
boolean should_draw_fatmarker = true;
boolean should_draw_drips = true;
boolean should_use_mouse = false;
boolean should_draw_left = false;
float colorselec;
//rotation
boolean wannarotate = false;
float crap = 0.0;

PShape path,path1,path2;
Point2D.Double intersection;
PShape pincelfinal;

  PShape[] shapes = new PShape[200];                       // An array of PShapes
PShape pincelpuntos;

int beat=0;


void setup() {

  primera1 = loadImage("spark.png");
  primera= loadImage("spark.png");
      logos =loadImage("logo.png");
verdecarro =loadImage("verdecarro.jpg");
rojocarro =loadImage("rojocarro.jpg");
azulcarro =loadImage("azulcarro.jpg");
naranjacarro =loadImage("naranjacarro.jpg");
header =loadImage("header.png");



  size(displayWidth, displayHeight, OPENGL);  
  
   
  
   menuslide = new Menuhilo("a");
  menuslide.start();
  
  jpegs1 = loadImage("marca.png");
print(colaiderslide);
  //////

   pincelfinal = createShape(GROUP);


 shapes[0] = createShape();
  shapes[0].setStroke(false);
 // group = createShape(GROUP);



  shapes[0].beginShape();
  for (float a = -PI; a < 3; a += 0.1) {
    float r = random(20, 30);
    shapes[0].vertex(r*cos(a), r*sin(a));
  }
  shapes[0].endShape();


 //shapes[0] = createShape(ELLIPSE,0,0,30,30);        // Two PShapes
   // shapes[0].setStroke(false);

 pincelfinal.addChild(shapes[0]);
 
 
 for(int i=1;i<20;i++){
   float aleatorix=random(100,200);
      float aleatoriy=random(100,200);
float tamano=random(9);
 shapes[i] = createShape(ELLIPSE,(0-100)+aleatorix,(0-100)+aleatoriy,tamano,tamano);        // Two PShapes

     shapes[i].setStroke(false);
 pincelfinal.addChild(shapes[i]);

 }




  path = createShape();
  path.setStroke(false);
 // group = createShape(GROUP);



  path.beginShape();
  for (float a = -PI; a < 3; a += 0.1) {
    float r = random(60, 90);
    path.vertex(r*cos(a), r*sin(a));
  }
  path.endShape();


  path1 = createShape();
  path1.setStroke(false);
  //group = createShape(GROUP);


  path1.beginShape();
  for (float a = -PI; a < 3; a += 0.1) {
    float r = random(60, 120);
    path1.vertex(r*cos(a), r*sin(a));
  }
  path1.endShape();



  


  jmyron = new JMyron();//make a new instance of the object

  jmyron.start(cam_width, cam_height);//start a capture at 320x240

  jmyron.trackColor(254, 254, 254, color_threshold); //R, G, B, and range of similarity

  jmyron.adaptivity(0.4);
  jmyron.minDensity(30);

  cam_image = new PImage(cam_width, cam_height);

  a_quad[0] = new Point2D.Float(0.0, 0.0);
  a_quad[1] = new Point2D.Float(1.0, 0.0);
  a_quad[2] = new Point2D.Float(1.0, 1.0);
  a_quad[3] = new Point2D.Float(0.0, 1.0);

  //top left
  coordinates_projector[0][0] = 50;
  coordinates_projector[0][1] = 10;
  //top right
  coordinates_projector[1][0] = cam_width-50;
  coordinates_projector[1][1] = 65;
  //bottom left
  coordinates_projector[2][0] = cam_width-30;
  coordinates_projector[2][1] = cam_height-40;
  //bottom right
  coordinates_projector[3][0] = 5;
  coordinates_projector[3][1] = cam_height-15;

  pointer_on_screen = false;
  pointer_is_moving = false;

  PFont f = loadFont("Univers66.vlw.gz");
  textFont(f, 16);

  calibration_point = 4;
  cleararea_calibration_point = 4;

  drips_position = -1;
  current_color = 0;
  change_color(colors[0]);
  
    for(int i=0;i<13;i++) {
    noFill();
    //stroke(255,0,0);         //red lines
    stroke(random(i*40));  //black lines
    strokeWeight(random(0,i*0.05));
    bezier(random(width,width*2),random(height,-height),random(width*2),random(height*2),random(0,-width),random(0,-height),random(0,-width),random(-height,height));
  }
  for(int i=0;i<700;i++) { 
    float rand=random(0,i%100);
     
    stroke(random(i*0.3%255,i*0.5%255),0,random(i*0.5%255),i*5%255);  //red heart
    //stroke(random(rand+10,rand*2+100),rand*2);  // B+W heart
    noFill();
    strokeWeight(abs(rand*0.0001));
 
    bezier(width/2+rand+beat,height*.266+random(i*0.6),width*0.25,0,width*0.25,width*0.266,width/2-rand+beat,height*0.53);
    bezier(width/2+rand-beat,height*.266,width*0.75,0,width*0.75,width*0.266,width/2-rand*0.5-beat,height*0.53+random(i*0.2));
  }
}

void change_color(int new_color) {
  drips.add(new DripsScreen(new_color, estilos[current_estilos], should_draw_drips));
  drips_position += 1;
}
void cambiarestilo(int stulos) {
  drips.add(new DripsScreen(colors[current_color], stulos, should_draw_drips));
  drips_position += 1;
}

void chorrear(boolean  puredechorrear) {
  drips.add(new DripsScreen(colors[current_color], estilos[current_estilos], puredechorrear));
  drips_position += 1;
}

void clear_draw_area() {
  wannarotate = false;
  drips.clear();

  drips.add(new DripsScreen(colors[current_color], estilos[current_estilos], should_draw_drips));
  drips_position = 0;
}



class Colores {
  float x =0;
  float y =0;
  int ancho=0;
  int alto=0;

  void setx(float x) {
    this.x =x;
  }
  void setancho(int ancho) {
    this.ancho =ancho;
  }
  void setalto(int alto) {
    this.alto =alto;
  }
  void sety(float y) {
    this.y =y;
  }


  public float getx() {
    return  this.x;
  }
  public int getancho() {
    return  this.ancho;
  }
  public  int getalto() {
    return this.alto;
  }
  public float gety() {
    return this.y ;
  }
}
Colores paletacolor = new Colores();
Colores logo = new Colores();

/*
void crearpaleta(int destino, int aumento) {
  //print(xpaleta);

  if (aumento==1) {
    if (xpaleta<destino) {



      paletacolor.setx(xpaleta-267);
      paletacolor.sety(0);
      paletacolor.setancho(267);
      paletacolor.setalto(768);
      xpaleta= xpaleta+10;
    }
  }else{
  if (xpaleta> 0) {



      paletacolor.setx(xpaleta-277);
      paletacolor.sety(0);
      paletacolor.setancho(267);
      paletacolor.setalto(768);
      xpaleta= xpaleta-10;
    }
  }


}

void crearpaletacolor(){
//  image(paletacolores, paletacolor.getx(), paletacolor.gety(), paletacolor.getancho(), paletacolor.getalto());

}

*/
Colores rojo = new Colores();

void crearrojo() {
  rojo.setx(0);
  rojo.sety(650);
  rojo.setancho(105);
  rojo.setalto(105);
  ellipse(rojo.getx(), rojo.gety()+100, rojo.getalto(), rojo.getancho());
}


Colores azul = new Colores();
void crearazul() {
  azul.setx(250);
  azul.sety(650);
  azul.setancho(80);
  azul.setalto(80);
  ellipse(azul.getx(), azul.gety(), azul.getalto(), azul.getancho());
}


Colores negro = new Colores();
void crearnegro() {
  negro.setx(350);
  negro.sety(650);
  negro.setancho(80);
  negro.setalto(80);
  ellipse(negro.getx(), negro.gety(), negro.getalto(), negro.getancho());
}


Colores verde = new Colores();
void crearverde() {
  verde.setx(450);
  verde.sety(650);
  verde.setancho(80);
  verde.setalto(80);
  ellipse(verde.getx(), verde.gety(), verde.getalto(), verde.getancho());
}


Colores naranja = new Colores();
void crearnaranja() {
  naranja.setx(550);
  naranja.sety(650);
  naranja.setancho(80);
  naranja.setalto(80);
  ellipse(naranja.getx(), naranja.gety(), naranja.getalto(), naranja.getancho());
}


public boolean collaider(float ax, float ay, int aancho, int alargo, float bx, float by, int bancho, int blargo) {

  boolean hit=false;
  if (bx + bancho >= ax && bx < ax + aancho) {
    if (by + blargo >= ay && by < ay + alargo) {
      hit=true;
    }
  }

  if (bx <= ax && bx+ bancho >= ax+aancho) {
    if (by<= ay && by +blargo >= ay +alargo) {
      hit=true;
    }
  }

  if (ax <= bx && ax+ aancho >= bx + bancho) {
    if (ay<= by && ay +alargo >= by +blargo) {
      hit=true;
    }
  }
  return hit;
}

void draw() {
  
  
  
  
  randompt= random(6);

  //  image(brushpruebas[(int)random(6)],100,200);

  background(255,255,255);
  
 

  ortho(0, width, 0, height, -5000, 5000);
  //translate((width/2), (-height/2));
  drip_width = brush_width/3;
  //  int[] colors = { #0040FF,#7B66C4,#F27B23, #FE3F7C, #FF7700, #8C898B, #0311A3,#038212,#EB0909,#000000,#000000};

  


  if (colaiderverde) {
    carroverde=true;
    carronaranja=false;
    carrozul=false;
    carrorojo=false;
    current_color = 2;
    change_color(colors[current_color]);
    ((DripsScreen)drips.get(drips_position)).moveTo(pointer[0], pointer[1]);
           menuslide.crearpaleta(0, 0);

  }

if(colaidernaranja){
  carroverde=false;
    carronaranja=true;
    carrozul=false;
    carrorojo=false;
  current_color = 3;
    change_color(colors[current_color]);
    ((DripsScreen)drips.get(drips_position)).moveTo(pointer[0], pointer[1]);
         menuslide.crearpaleta(0, 0);

}

  if (colaidernegro) {
    current_color =1;
  carroverde=false;
    carronaranja=false;
    carrozul=true;
    carrorojo=false;
    change_color(colors[current_color]);
        ((DripsScreen)drips.get(drips_position)).moveTo(pointer[0], pointer[1]);
       menuslide.crearpaleta(0, 0);

  }


  if (colaiderazul) {

    carroverde=false;
    carronaranja=false;
    carrozul=false;
    carrorojo=true;
    current_color = 0;
    change_color(colors[current_color]);
    ((DripsScreen)drips.get(drips_position)).moveTo(pointer[0], pointer[1]);
           menuslide.crearpaleta(0, 0);

  }

  //compute tasks

  if (should_use_mouse) {
    track_mouse_as_laser();
    current_brush1 += 1;
  }

  else {
    track_laser();
    ///print(contador++);
  }


  update_laser_position();
  handle_cleararea();
  //draw the lines & drips
  if (wannarotate) {
    crap += 0.01;
    Iterator i = drips.iterator();
    while (i.hasNext ()) {
      DripsScreen d = (DripsScreen)i.next();
      d.draw_rotate();
    }
  }
  else {
    Iterator i = drips.iterator();
    while (i.hasNext ()) {
      DripsScreen d = (DripsScreen)i.next();
      d.draw();
      // d.cambiarestado(spry);
      //cambiarestilo();
    }
  }

  if (!should_draw_menu) {
    zcall = 5000;
  } 
  else {
    zcall = -1;
  }

  if (stencil) {
    image(primera, 0, 0);
  }


  if (neon) {
    colorMode(HSB);   //set colors to Hue, Saturation, Brightness mode
  }
  else {
    colorMode(RGB);   //set colors to Hue, Saturation, Brightness mode
  }


  if (paleta) {

   // crearpaleta(267, 1);
    //paletacolor.setx(1000);



    ///image(paletacolores, 0, 0, 267, 768);
  }
  else {
   // crearpaleta(0, 0);
  }
  if (should_draw_menu) {



    repositionRectangleByMouse();
    noStroke();
    fill(0, 0, 0, 0);
    rect(0, 0, width, height);
    draw_menu();

    pushMatrix();

    draw_tracking();
    popMatrix();
  }

  if (calibration_point != 4)
    draw_calibration();
  else if (cleararea_calibration_point != 4)
    draw_cleararea_calibration();

  if (should_draw_framerate) {
    noStroke();
    fill(255, 255, 255);
    textAlign(LEFT);
    text(frameRate, 10, 20);
  }

  if (should_draw_outline) {
    noFill();
    stroke(255, 255, 255, 255);
    strokeWeight(4);
  }
  noStroke();
    noFill();

  crearrojo();


  if (colaiderrojo) {

    menuslide.crearpaleta(1024, 1);
  }

  menuslide.crearpaletacolor();
  //tint(255, 126);
  image(logos, 0, 590);
    //image(header, 0, 0);


if(!carrorojo){

    image(rojocarro, 200, 640);
      
}
if(!carroverde){
  image(verdecarro, 400, 640);
   
}
if(!carrozul){
  image(azulcarro, 300, 640);
   
}
if(!carronaranja){
  image(naranjacarro, 500, 640);
   
}


  crearazul();
  crearverde();
  crearnegro();
  crearnaranja();
  smooth();
}

void draw_menu() {
  pushMatrix();
  fill(255, 255, 255);
  noStroke();
  int x = 0;
  int y = 0;

  textAlign(LEFT);

  y += 735;

  ArrayList lines = new ArrayList();
  lines.add("color threshold " + color_threshold + " (./, to in/decrease"+color_nothreshold);
  lines.add("brush weight: " + brush_width + " (+/- to in/decrease)");
  lines.add("drips probability: " + drips_probability +" (h/g to in/decrease - lower = more likely))");
  lines.add("");

  Iterator i = lines.iterator();
  String s;
  while (i.hasNext ()) {
    s = (String)i.next();
    y += -15;
    text(s, x, y);
  }


  textAlign(RIGHT);
  x = width-20;
  y = 0;

  lines = new ArrayList();
  lines.add("r - Start/continue callibration");
  lines.add("x - Start/continue callibration");
  lines.add("l - Turn screen counterclockwise");
  lines.add("m - Toggle menu");
  lines.add("c - Clear screen");
  lines.add("d - Toggle drips");
  lines.add("f - Toggle framerate");
  lines.add("b - Toggle marker");
  lines.add("a - Next colour");
  lines.add("0 (nr) - use mouse mode");
  lines.add("3 - Effin' 3D effect");

  i = lines.iterator();
  while (i.hasNext ()) {
    s = (String)i.next();
    y += 15;
    text(s, x, y);
  }

  popMatrix();
}


void repositionRectangleByMouse() {
  // reposition scan rectangle
  if (should_draw_menu && should_use_mouse && mousePressed == true && mouseX < cam_width && mouseY < cam_height) {
    int nearest_distance = -1;
    int[] nearest = null;
    //find nearest beamer coordinate and set it to new point
    for (int i=0; i<4; i++) {
      int[] pt = coordinates_projector[i];
      int distance = (int)(pow(mouseX-pt[0], 2) + pow(mouseY-pt[1], 2)); //need no sqrt, because we're only comparing
      if (distance < nearest_distance || nearest_distance == -1) {
        nearest = pt;
        nearest_distance = distance;
      }
    }

    //move nearest point to mouse coordinates
    if (nearest != null) {
      nearest[0] = mouseX;
      nearest[1] = mouseY;
    }
  }
}

void draw_calibration() {
  noStroke();
  fill(0, 0, 0, 100);
  rect(0, 0, width, height);

  noStroke();
  fill(255, 255, 255);
  Point2D point = a_quad[calibration_point];

  int c_size = width/15; //calibration circle with
  int c_x = (int)(point.getX()*width);
  int c_y = (int)(point.getY()*height);

  ellipse(c_x, c_y, c_size, c_size);

  if (pointer_is_visible) {
    coordinates_projector[calibration_point][0] = pointer_camera_coordinates[0];
    coordinates_projector[calibration_point][1] = pointer_camera_coordinates[1];
  }
}

void draw_cleararea_calibration() {
  noStroke();

  pushMatrix();

  scale((float)width/(float)cam_width, (float)height/(float)cam_height);
  draw_tracking();

  if (pointer_is_visible) {
    coordinates_cleararea[cleararea_calibration_point][0] = pointer_camera_coordinates[0];
    coordinates_cleararea[cleararea_calibration_point][1] = pointer_camera_coordinates[1];
  }

  popMatrix();
}

void draw_tracking() {
  //draw the normal image of the camera
  int[] img = jmyron.image();
  cam_image.loadPixels();
  arraycopy(img, cam_image.pixels);
  if (should_draw_menu) {
    cam_image.updatePixels();
  };
  image(cam_image, 0, 0, 320, 240);

  // Draw glob Boxes
  // First box is always the red border around the video
  int[][] b = jmyron.globBoxes();
  noFill();
  stroke(255, 0, 0);
  for (int i=0;i<b.length;i++) {
    rect(b[i][0], b[i][1], b[i][2], b[i][3] );
  }

  //draw the beamer
  noFill();
  stroke(255, 255, 255);
  strokeWeight(1);
  quad(coordinates_projector[0][0], coordinates_projector[0][1], 
  coordinates_projector[1][0], coordinates_projector[1][1], 
  coordinates_projector[2][0], coordinates_projector[2][1], 
  coordinates_projector[3][0], coordinates_projector[3][1]
    );

  //draw the clear area
  stroke(255, 0, 0, 128);
  quad(coordinates_cleararea[0][0], coordinates_cleararea[0][1], 
  coordinates_cleararea[1][0], coordinates_cleararea[1][1], 
  coordinates_cleararea[2][0], coordinates_cleararea[2][1], 
  coordinates_cleararea[3][0], coordinates_cleararea[3][1]
    );

  //draw mah lazer!!!
  if (pointer_is_visible) {
    int e_size = cam_width/10;
    noStroke();
    fill(255, 0, 0, 128);
    ellipse(pointer_camera_coordinates[0], pointer_camera_coordinates[1], e_size, e_size);
  }
}


void handle_cleararea() {
  if (pointer_is_visible) {
    int[] xpoints = new int[4];
    int[] ypoints = new int[4];
    for (int i=0; i<4; i++) {
      xpoints[i] = coordinates_cleararea[i][0];
      ypoints[i] = coordinates_cleararea[i][1];
    }
    Polygon clear_area = new Polygon(xpoints, ypoints, 4); //refactor me to use a polygon all the way

    if (clear_area.contains(pointer_camera_coordinates[0], pointer_camera_coordinates[1]))
      clear_draw_area();
  }
}




void keyPressed() {
  if (key == 'l') {
    should_draw_left = !should_draw_left;
  }
  if (key == 'a') {
    current_color += 1;
    if (current_color == colors.length) {
      current_color = 0;
    }

    change_color(colors[current_color]);
  }
  if (key == '3') {
    wannarotate = !wannarotate;
    rotateX(0);
    rotateY(0);
    crap = 0.0;
  }
  if (key == 'm')
    should_draw_menu = !should_draw_menu;
  if (key == 'f')
    should_draw_framerate = !should_draw_framerate;
  if (key == 'o')
    should_draw_outline = !should_draw_outline;
  if (key == 'b')
    should_draw_fatmarker = !should_draw_fatmarker;
  if (key == 'd')
    should_draw_drips = !should_draw_drips;
  chorrear(should_draw_drips);
  if (key == '0')
    should_use_mouse = !should_use_mouse;
  if (key == 'c') {
    clear_draw_area();
  }
  if (key == 'r') {
    calibration_point += 1;
    if (calibration_point == 4) {
      clear_draw_area(); // Clear drawing area after callibration finished
    }
    if (calibration_point == 5) {
      calibration_point = 0;
    }
  }
  if (key == 'x') {
    cleararea_calibration_point += 1;
    if (cleararea_calibration_point == 4) {
      clear_draw_area(); // Once calibration is finished, clear drawing area
    }
    if (cleararea_calibration_point == 5) {
      cleararea_calibration_point = 0;
    }
  }
  if (key == '-') {
    brush_width -= 1;
  }
  if (key == '+') {
    brush_width += 1;
  }
  if (key == 'u') {


    //cambiar2stilo();
    // cambiarestilo();
  }
  if (key == 'i') {

    current_estilos += 1;
    if (current_estilos == estilos.length)
      current_estilos = 0;
    cambiarestilo(estilos[current_estilos]);
  }

  if (key == 'z') {
    color_nothreshold += 2;
    //jmyron.trackNotColor(0,231,228,color_nothreshold); //R, G, B, and range of similarity
    //jmyron.trackNotColor(255,255,255,color_nothreshold); //R, G, B, and range of similarity
  }

  if (key == '.') {
    color_threshold += 2;

    int pixR = (currPixColor >> 16) & 0xFF;
    int pixG = (currPixColor >> 8) & 0xFF;
    int pixB = currPixColor & 0xFF;
    jmyron.trackColor(pixR, pixG, pixB, color_threshold);
  }
  if (key == '6') {
    numPixels = cam_width * cam_height;

    currPixColor = cam_image.pixels[numPixels - (cam_width * 2) - 3];
    int pixR = (currPixColor >> 16) & 0xFF;
    int pixG = (currPixColor >> 8) & 0xFF;
    int pixB = currPixColor & 0xFF;
    //println(pixR+" "+pixG+" "+ pixG);
    //  change_color(currPixColor);
  }
  if (key == ',') {
    color_threshold -= 2;


    int pixR = (currPixColor >> 16) & 0xFF;
    int pixG = (currPixColor >> 8) & 0xFF;
    int pixB = currPixColor & 0xFF;
    jmyron.trackColor(pixR, pixG, pixB, color_threshold);
  }
  if (key == 'h') {
    drips_probability += 5;
  }
  if (key == 'g') {
    drips_probability -= 5;
  }
  if (key == 'y') {
    cam_image.updatePixels();
  }
  if (key == 'v') {
    stencil = !stencil;
  }

  if (key == '8') {
    paleta = !paleta;
  }

  if (key =='n') {
    neon = !neon;
  }
}





class Menuhilo extends Thread {
 
  boolean running;           // Is the thread running?  Yes or no?
  int wait;                  // How many milliseconds should we wait in between executions?
  String id;                 // Thread name
  int count;                 // counter
 PImage paletacolores;
 PImage logos;


  Menuhilo (String s) {
    running = false;
    id = s;
    count = 0;
      paletacolores =loadImage("menu.png");

  }
 
  int getCount() {
    return count;
  }

  void crearpaleta(int destino, int aumento) {
      if (aumento==1) {
        
        
        
      paletacolor.setx(destino-1024);
      paletacolor.sety(590);
      paletacolor.setancho(1024);
      paletacolor.setalto(143);
      }else{
               
      }
  
}
  
  void crearpaletacolor(){
 image(paletacolores, paletacolor.getx(), paletacolor.gety(), paletacolor.getancho(), paletacolor.getalto());


}

 
  void start () {
    super.start();
  }
 
   void run () {
crearpaletacolor();  
  }
 
  void quit() {
    running = false;  
    interrupt();
  }
}


