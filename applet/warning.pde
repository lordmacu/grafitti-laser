import processing.opengl.*;

int colour = 0;
int cspeed = 7;
boolean colour_direction = true;
int times = 0;

void warning_intro() {
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
