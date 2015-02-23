/**
 * Draws a set of lines with drips.
 */

class DripsScreen {

  protected GeneralPath draw_path;
  protected float[] current_point = new float[2];
  protected float[] previous_point = new float[2];
    protected float[] previous_point1 = new float[2];

  protected ArrayList drips;
  protected int colour;
  protected int estilos;
  protected float randomk;
  protected boolean puedechorrear=true;
  
  protected int segundos=1;
  public DripsScreen(int colour,int estilos,boolean puedechorrear){
    clear();
    this.colour = colour;
    this.estilos=estilos;
    this.puedechorrear=puedechorrear;
    this.segundos=segundos;

 
 
 

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
    float z = -50.0;
    float zo = z;
    float az = 0.0;
    float[] old = new float[2];
    float[] p = new float[2];
    boolean wasLineSegment = false;
    while(!i.isDone()){

      segment_type = i.currentSegment(p);
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

      zo = z;
      z += 1.5;
      old[0] = p[0];
      old[1] = p[1];
      
      i.next();
    }
    
    if(wasLineSegment){
      endShape();
      wasLineSegment = false;
    }
    
    popMatrix();
  }
  public float devolverlimite(float inicial,float finals){
    
    float retorno=0;
  if(inicial>=finals){
   retorno=finals;
  }
  
  if(inicial<=finals){
       retorno=inicial;

  }
  return retorno;
  
  }
  
  
  void devolverlinea(float c1, float c2, float p1,float p2, int anchoss,int separacion,double vecf1,double vecf2){
   beginShape();
            vertex((float)(p1+vecf1*anchoss)+separacion, (float)(p2+vecf2*anchoss)+separacion);
            vertex((float)(c1+vecf1*anchoss)+separacion, (float)(c2+vecf2*anchoss)+separacion);
            vertex((float)(c1-vecf1*anchoss)+separacion, (float)(c2-vecf2*anchoss)+separacion);
            vertex((float)(p1-vecf1*anchoss)+separacion, (float)(p2-vecf2*anchoss)+separacion);
            endShape();
  }
  void brushpint (float x,float y) {
  int width1=200; // that be the width of your brush
  //
  float radx;   // Radius
  float rady;
  float angle1; // angle

  //
  for (int i=0; i < 50; i++) {
    radx=random(width1);
    rady=random(width1);
    angle1= random(359);
    //
    x=(radx*cos(radians(angle1)))+x;
    y=(radx*sin(radians(angle1)))+y;
    //
    point(x, y);
    
    print(x);
  }
 }
   void star(float x, float y, float radius1, float radius2, int npoints) {

    float angle = TWO_PI / npoints;
    float halfAngle = angle/2.0;
    beginShape();
    for (float a = 0; a < TWO_PI; a += angle) {
      float sx = x + cos(a) * radius2;
      float sy = y + sin(a) * radius2;
      vertex(sx, sy);
      sx = x + cos(a+halfAngle) * radius1;
      sy = y + sin(a+halfAngle) * radius1;
      vertex(sx, sy);
    }
    endShape(CLOSE);
  }
        Generarbrush   brush5= new Generarbrush();

  public void draw(){
    //all done in update() for increased performance
    noFill();
    stroke(colour);
    fill(colour);
    strokeWeight(1);
    
    Vector2d vec;
    Vector2d vec2;
    float xdiff;
    float ydiff;
    double[] vecf = new double[2];
    double[] vec2f = new double[2];
    ///float[] current_point = new float[2];
    //float[] previous_point = new float[2];
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
               noStroke();
          //  ellipse(current_point[0], current_point[1], brush_width*2, brush_width*2);
          }
          else{
            vec = new Vector2d(-ydiff, xdiff); //swap x & y for normal vector
            vec.normalize();
            vec.get(vecf);

            vec2 = new Vector2d(xdiff, ydiff); //direction of our stroke
            vec2.normalize();
            vec2.get(vec2f);
            
             fill(colour);
             
            
            if(estilos==1){
              
/*

if(current_point[0]<255)
{
  
   colorselec=current_point[0];
}*/


             fill(colour);


    noStroke();
            
            
                        beginShape();
            vertex((float)(previous_point[0]+vecf[0]*(brush_width)+15), (float)(previous_point[1]+vecf[1]*(brush_width))+15);
            vertex((float)(current_point[0]+vecf[0]*(brush_width)+15), (float)(current_point[1]+vecf[1]*(brush_width))+15);
            vertex((float)(current_point[0]-vecf[0]*(brush_width)+15), (float)(current_point[1]-vecf[1]*(brush_width))+15);
            vertex((float)(previous_point[0]-vecf[0]*(brush_width)+15), (float)(previous_point[1]-vecf[1]*(brush_width))+15);
            endShape();
                          ellipse(current_point[0]+15, current_point[1]+15, (brush_width)*2, (brush_width)*2);
noFill();

              
            }
            
            if(estilos==2){
              
                 noStroke();
            
            
                        beginShape();
            vertex((float)(previous_point[0]+vecf[0]*(brush_width)+15), (float)(previous_point[1]+vecf[1]*(brush_width))+15);
            vertex((float)(current_point[0]+vecf[0]*(brush_width)+15), (float)(current_point[1]+vecf[1]*(brush_width))+15);
            vertex((float)(current_point[0]-vecf[0]*(brush_width)+15), (float)(current_point[1]-vecf[1]*(brush_width))+15);
            vertex((float)(previous_point[0]-vecf[0]*(brush_width)+15), (float)(previous_point[1]-vecf[1]*(brush_width))+15);
            endShape();
                          ellipse(current_point[0]+15, current_point[1]+15, (brush_width)*2, (brush_width)*2);
noFill();

            }
              if(estilos==3){
                
                /*int anchoss=0;
                int separacion=0;
                float p1=0;
                float p2=0;
                float c1=0;
                float c2=0;
                double vecf1=0;
                double vecf2=0;

p1=previous_point[0];
p2=previous_point[1];
c1=current_point[0];
c2=current_point[1];
vecf1=vecf[0];
vecf2=vecf[1];

devolverlinea( c1,  c2,  p1, p2,  5, -4, vecf1, vecf2);

devolverlinea( c1,  c2,  p1, p2,  3, 0, vecf1, vecf2);
            ///devolverlinea( c1,  c2,  p1, p2,  anchoss, separacion, vecf1, vecf2);

devolverlinea( c1+10,  c2,  p1+10, p2,  4, 4, vecf1, vecf2);
devolverlinea( c1,  c2,  p1, p2,  5, 17, vecf1, vecf2);
smooth();
 

/*

devolverlinea( c1,  c2,  p1, p2,  5, -4, vecf1, vecf2);

devolverlinea( c1,  c2,  p1, p2,  3, 0, vecf1, vecf2);
            ///devolverlinea( c1,  c2,  p1, p2,  anchoss, separacion, vecf1, vecf2);

devolverlinea( c1+10,  c2,  p1+10, p2,  4, 4, vecf1, vecf2);
devolverlinea( c1,  c2,  p1, p2,  5, 17, vecf1, vecf2);
smooth();

*/
            /*
                 noStroke();
            beginShape();
            vertex((float)(previous_point[0]+vecf[0]*brush_width), (float)(previous_point[1]+vecf[1]*brush_width));
            vertex((float)(current_point[0]+vecf[0]*brush_width), (float)(current_point[1]+vecf[1]*brush_width));
            vertex((float)(current_point[0]-vecf[0]*brush_width), (float)(current_point[1]-vecf[1]*brush_width));
            vertex((float)(previous_point[0]-vecf[0]*brush_width), (float)(previous_point[1]-vecf[1]*brush_width));
            endShape();
                noStroke();
               pushMatrix();
              translate(current_point[0]+10, current_point[1]);
              star(0, 0, (brush_width/2)+2, 40, 40); 
              popMatrix(); 
              
           
               ellipse(current_point[0], current_point[1], brush_width*2, brush_width*2);
*/


 


            }
              if(estilos==4){
                 




 noStroke();
            
            
                        beginShape();
            vertex((float)(previous_point[0]+vecf[0]*(brush_width)+15), (float)(previous_point[1]+vecf[1]*(brush_width))+15);
            vertex((float)(current_point[0]+vecf[0]*(brush_width)+15), (float)(current_point[1]+vecf[1]*(brush_width))+15);
            vertex((float)(current_point[0]-vecf[0]*(brush_width)+15), (float)(current_point[1]-vecf[1]*(brush_width))+15);
            vertex((float)(previous_point[0]-vecf[0]*(brush_width)+15), (float)(previous_point[1]-vecf[1]*(brush_width))+15);
            endShape();
                          ellipse(current_point[0]+15, current_point[1]+15, (brush_width)*2, (brush_width)*2);
noFill();


            }
             if(estilos==5){
                    
                
            ///    fill(255,255,255,40);
                  
      noStroke();
   
             noFill();
                
                fill(colour,140);
            
            beginShape();
            vertex((float)(previous_point[0]+vecf[0]*(brush_width+2)), (float)(previous_point[1]+vecf[1]*(brush_width+2)));
            vertex((float)(current_point[0]+vecf[0]*(brush_width+2)), (float)(current_point[1]+vecf[1]*(brush_width+2)));
            vertex((float)(current_point[0]-vecf[0]*(brush_width+2)), (float)(current_point[1]-vecf[1]*(brush_width+2)));
            vertex((float)(previous_point[0]-vecf[0]*(brush_width+2)), (float)(previous_point[1]-vecf[1]*(brush_width+2)));
            endShape();
             noFill();
                
                fill(255,255,255,40);
            
            //ellipse(current_point[0], current_point[1], (brush_width)*2, (brush_width)*2);


                noFill();
                
                fill(colour);
              noStroke();
            beginShape();
            vertex((float)(previous_point[0]+vecf[0]*(brush_width-7)), (float)(previous_point[1]+vecf[1]*(brush_width-7)));
            vertex((float)(current_point[0]+vecf[0]*(brush_width-7)), (float)(current_point[1]+vecf[1]*(brush_width-7)));
            vertex((float)(current_point[0]-vecf[0]*(brush_width-7)), (float)(current_point[1]-vecf[1]*(brush_width-7)));
            vertex((float)(previous_point[0]-vecf[0]*(brush_width-7)), (float)(previous_point[1]-vecf[1]*(brush_width-7)));
            endShape();
            ellipse(current_point[0], current_point[1], (brush_width-7)*2, (brush_width-7)*2);
            }
                  if(estilos==6){
       diam = abs(current_point[1] - height/2)*.18; // constantly recalculate diameter as a distance from the mouse to the center, and make it 10% of that
                     noStroke();
            ellipse(current_point[0], current_point[1], diam*2, diam*2);
            beginShape();
            vertex((float)(previous_point[0]+vecf[0]*diam), (float)(previous_point[1]+vecf[1]*diam));
            vertex((float)(current_point[0]+vecf[0]*diam), (float)(current_point[1]+vecf[1]*diam));
            vertex((float)(current_point[0]-vecf[0]*diam), (float)(current_point[1]-vecf[1]*diam));
            vertex((float)(previous_point[0]-vecf[0]*diam), (float)(previous_point[1]-vecf[1]*diam));
            endShape();
            ellipse(current_point[0], current_point[1], diam*2, diam*2);

            
            
            
            }
            
            
            if(estilos==7){
                noFill();
    stroke(colour);
               beginShape();
          vertex(previous_point[0]+brush_width, previous_point[1]+brush_width);
          vertex(current_point[0]+brush_width, current_point[1]+brush_width);
          vertex(current_point[0]-brush_width, current_point[1]-brush_width);
          vertex(previous_point[0]-brush_width, previous_point[1]-brush_width);
          endShape();
            }
            
            //println(" x "+current_point[0]+"y"+current_point[1]+" ancho "+brush_width);
            
          //  ellipse(rojo.getx(),rojo.gety() , rojo.getalto(), rojo.getancho());
          
            colaidernaranja=collaider( current_point[0],  current_point[1], brush_width, brush_width, naranja.getx()-70, naranja.gety(), naranja.getalto(), naranja.getancho());

           colaiderrojo=collaider( current_point[0],  current_point[1], brush_width, brush_width, rojo.getx(), rojo.gety(), rojo.getalto(), rojo.getancho());
           colaiderazul=collaider( current_point[0],  current_point[1], brush_width, brush_width,azul.getx()-70, azul.gety(), azul.getalto(), azul.getancho());
           colaiderverde=collaider( current_point[0],  current_point[1], brush_width, brush_width,verde.getx()-70, verde.gety(), verde.getalto(), verde.getancho());
           colaidernegro=collaider( current_point[0],  current_point[1], brush_width, brush_width,negro.getx()-70, negro.gety(), negro.getalto(), negro.getancho());
           colaiderslide=collaider( current_point[0],  current_point[1], brush_width, brush_width,0 ,0, 267,768);


          }
        }
        else{
          // Interestingly, if you try to draw with trianglestrips here,
          // it gets awfully slow, around 8 fps
          beginShape();
          vertex(previous_point[0]+brush_width, previous_point[1]+brush_width);
   
          vertex(current_point[0]+brush_width, current_point[1]+brush_width);
          vertex(current_point[0]-brush_width, current_point[1]-brush_width);
          vertex(previous_point[0]-brush_width, previous_point[1]-brush_width);
          endShape();
          
          
        }
      }
 noStroke();
      previous_point[0] = current_point[0];
      previous_point[1] = current_point[1];
       previous_point1[0] = previous_point[0];
      previous_point1[1] = previous_point[1];
      pi.next();
    }
    
    if(puedechorrear){
      Iterator i = drips.iterator();
      Drip d;
      while(i.hasNext()){
        d = (Drip)i.next();
        d.draw();
      }
    }
  }
  
  
  class Generarbrush{
  protected float  prev1=0;
  protected float prev2=0;
  protected float act1=0;
  protected float act2=0;
  protected double vectf1=0;
   protected double vectf2=0;
      protected float tamano=0;

   boolean probando=true;
   
float randomunitario=0;
  public Generarbrush(float prev1,float prev2,float act1, float act2, double vectf1, double vectf2,float random){
  
  this.prev1=prev1;
    this.prev2=prev2;

  this.act1=act1;

  this.act2=act2;
  this.vectf1=vectf1;
  this.vectf2=vectf2;
  this.randomunitario=random ;

  }  
  
  public Generarbrush(){
  
  }
  public Generarbrush(float prev1,float prev2,float act1, float act2, double vectf1, double vectf2,float random,int tamano){
  
  this.prev1=prev1;
    this.prev2=prev2;

  this.act1=act1;

  this.act2=act2;
  this.vectf1=vectf1;
  this.vectf2=vectf2;
  this.randomunitario=random ;
this.tamano=tamano;
  }
  
  
  public void tamano(float tamano){
    this.tamano=tamano;
  }
  
  public void generarsvg(){
  
                    pushMatrix();
            //  shape(pincel1, current_point[0], current_point[1], 80, 80);
            pincelsvg.setFill(colour);
            //   rotate(10);
         shape(pincelsvg, current_point[0]-50,  current_point[1]-50,30, 30);

              popMatrix();
  }
  public void retornarbrush(){
    
  

       diam = abs(act1 - height/6)*.05; // constantly recalculate diameter as a distance from the mouse to the center, and make it 10% of that
 noStroke();
            beginShape();
            vertex((float)(prev1+vectf1*tamano), (float)(prev2+vectf2*tamano));
            vertex((float)(act1+vectf1*tamano), (float)(act2+vectf2*tamano));
            vertex((float)(act1-vectf1*tamano), (float)(act2-vectf2*tamano));
            vertex((float)(prev1-vectf1*tamano), (float)(prev2-vectf2*tamano));
            endShape();
            ellipse(act1, act2, tamano*2, tamano*2);
             ellipse(prev1, prev2, tamano*2, tamano*2);
  
  
              
                 
    
  }
    public void retornarbrushlaser(){
    
   noStroke();
            
            
                        beginShape();
           
            
             vertex((float)(prev1+vectf1*tamano)+15, (float)(prev2+vectf2*tamano)+15);
            vertex((float)(act1+vectf1*tamano)+15, (float)(act2+vectf2*tamano)+15);
            vertex((float)(act1-vectf1*tamano)+15, (float)(act2-vectf2*tamano)+15);
            vertex((float)(prev1-vectf1*tamano)+15, (float)(prev2-vectf2*tamano)+15);
            
            endShape();
                          ellipse(act1+15, act2+15, (tamano)*2, (tamano)*2);
noFill();
fill(3,17,163);

 noStroke();
         beginShape();
          
            
             vertex((float)(prev1+vectf1*(tamano-10)), (float)(prev2+vectf2*(tamano-10)));
            vertex((float)(act1+vectf1*(tamano-10)), (float)(act2+vectf2*(tamano-10)));
            vertex((float)(act1-vectf1*(tamano-10)), (float)(act2-vectf2*(tamano-10)));
            vertex((float)(prev1-vectf1*(tamano-10)), (float)(prev2-vectf2*(tamano-10)));
            endShape();
               ellipse(act1, act2, (tamano-10)*2, (tamano-10)*2);

            

      
      
  
              
                 
    
  }
  
  public void crearpunto(float distancia, PShape pathlocal){
       float    tamanootro = abs(distancia - height/6); // constantly recalculate diameter as a distance from the mouse to the center, and make it 10% of that

     // ellipse(prev1+distancia,prev2+distancia, tamano*2, tamano*2);
       pathlocal.setFill(colour);
        shape(pathlocal,prev1+distancia,prev2+distancia, (tamano*2)+distancia, (tamano*2)+distancia);

  }
  
    public void crearpuntoimagen(float distancia){
 //  pincelpersonalizado1( prev1+distancia, prev2+distancia,(tamano*2)+distancia,(tamano*2)+distancia);
//shape(pincelpersonalizado1(),);
      pincelfinal.setFill(colour);

       shape(pincelfinal,prev1+distancia,prev2+distancia, (tamano*2)+distancia, (tamano*2)+distancia);
 //shape(pincelfinal);

  }
  
  
  
  
  
  }
    
  public void update(int x, int y, boolean line){
    previous_point[1] = current_point[1];
    previous_point1[1]=  previous_point[1];
       // previous_point1[0]=  previous_point[0];

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


  class CrearImagen{
      
       float x=0;
       float y =0;
      int contador=0;

      public CrearImagen(float x,float y){
         
      this.x=x;
      this.y=y;
      }
      public void setx(float x){
this.x=x;
}

  public int  getcotador(){
return contador;
}
public void sety(float y){
this.y=y;
}
  public void devolver(int random){
      image(brushpruebas[random],this.x,this.y);

    }
    
    }

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
     
    rectMode(CENTER);
    if (!should_draw_left) {
      quad(x-drip_width/2, y-drip_width/2,
          x+drip_width/2, y+drip_width/2,
          x+drip_width/2, y+(ttl_start-ttl),
          x-drip_width/2, y+(ttl_start-ttl));
      rect(x, y+(ttl_start-ttl), drip_width-2, drip_width-2);
    } else {
      quad(x-drip_width/2, y-drip_width/2,
          x+(ttl_start-ttl), y-drip_width/2,
          x+(ttl_start-ttl), y+drip_width/2,
          x+drip_width/2, y+drip_width/2);
      rect(x+(ttl_start-ttl), y, drip_width-2, drip_width-2);
    };
    rectMode(CORNER);
    
    if(!is_dead())
      ttl -= 1;
  }
  
  public boolean is_dead(){
    return ttl < 0;
  }
}
