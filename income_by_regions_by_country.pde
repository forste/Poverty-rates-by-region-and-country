/**
 * income by regions (densly, immediate and thinly populated) by country in the EU
 * 
 * 
 */
 import processing.pdf.*;


String[] rows;
int index = 0;
float radius = 45;
float radius_extension_1 = 30;
float radius_extension_2 = 20;

class Sector {
  String country;
  double dense, immediate, thin, minimum, maximum;
  float alpha;
  Sector(String country, double dense, double immediate, double thin, float alpha) {
    this.country = country;
    this.dense = dense;
    this.immediate = immediate;
    this.thin = thin;
    this.alpha = alpha;
  }
  
  int getColorCode(double percentage) {
    double intervalLength = (this.maximum - this.minimum) / 7;
    float x = (float) ((percentage - this.minimum) / intervalLength);
    int colorCode = floor(x);
    println(this.country+": colorCode " +colorCode);
    if(colorCode == 7) {      
      colorCode = 6;          
    }
    return colorCode;    
  }
  
  float[] display() {    
    int colors[][] = new int[][] {
      new int[] { 255, 0, 0 }, //red thinest 4mm
      new int[] { 0, 255, 0 }, //green 5mm
      new int[] { 255, 255, 0 }, //yellow 6mm
      new int[] { 0, 0, 255 }, //blue 7mm
      new int[] { 255, 0, 255 }, //magenta 8mm
      new int[] { 0, 255, 255 }, //cyan 9mm
      new int[] { 255, 255, 255 } //white - widest
    };
    
    float ankathete = radius * cos(alpha);
    float gegenkathete = radius * sin(alpha);
    float startX = 0;
    float startY = 0;
    float midX = startX + radius;
    float midY = startY;
    float endX = startX + radius - ankathete;
    float endY = startY + gegenkathete;       
    
    float hypothenuse2 = radius+radius_extension_1; 
    float ankathete2 = hypothenuse2 * cos(alpha);
    float gegenkathete2 = hypothenuse2 * sin(alpha);
    float quad_1_right_bottom_X = startX - (ankathete2 - radius);
    float quad_1_right_bottom_Y = startY + gegenkathete2;
    float quad_1_left_up_X = startX-radius_extension_1;
    float quad_1_left_up_Y = midY;
    
    
    float hypothenuse3 = radius+radius_extension_1+radius_extension_2; 
    float ankathete3 = hypothenuse3 * cos(alpha);
    float gegenkathete3 = hypothenuse3 * sin(alpha);
    float quad_2_right_bottom_X = startX - (ankathete3 - radius);
    float quad_2_right_bottom_Y = startY + gegenkathete3;
    float quad_2_left_up_X = startX-radius_extension_1-radius_extension_2;
    float quad_2_left_up_Y = midY;
    
    //triangle
    int [] colorCode = colors[this.getColorCode(this.thin)];    
    fill(colorCode[0], colorCode[1], colorCode[2]);
    stroke(colorCode[0], colorCode[1], colorCode[2]);
    beginShape(TRIANGLES);
    vertex(startX, startY);
    vertex(midX, midY);
    vertex(endX, endY);    
    endShape();
   
    //first polygon
    colorCode = colors[this.getColorCode(this.immediate)];    
    fill(colorCode[0], colorCode[1], colorCode[2]);
    stroke(colorCode[0], colorCode[1], colorCode[2]);
    beginShape(QUADS);    
    vertex(startX, startY);
    vertex(endX, endY);
    vertex(quad_1_right_bottom_X, quad_1_right_bottom_Y);
    vertex(quad_1_left_up_X, quad_1_left_up_Y);    
    endShape();
    
    //second polygon
    colorCode = colors[this.getColorCode(this.dense)];    
    fill(colorCode[0], colorCode[1], colorCode[2]);
    stroke(colorCode[0], colorCode[1], colorCode[2]);
    beginShape(QUADS);    
    vertex(quad_1_left_up_X, quad_1_left_up_Y);
    vertex(quad_1_right_bottom_X, quad_1_right_bottom_Y);
    vertex(quad_2_right_bottom_X, quad_2_right_bottom_Y);
    vertex(quad_2_left_up_X, quad_2_left_up_Y);
    endShape();
    
    //fill(0);
    //text(country, startX, endX);
    
    return new float[] { endX, endY };
  }
}


float alpha;
ArrayList<Sector> sectors = new ArrayList<Sector>();
void setup() {
  size(600, 600);
  background(200);  
  //stroke(255);
  frameRate(12);
  rows = loadStrings("income_by_regions_by_country.csv");
  
  int iterations = rows.length; //rows.length
  alpha =  2*PI/(iterations - 1);
  
  double minimum = 9999;
  double maximum = -1;
 
  for(int i = 1; i<iterations; i++) {
    Sector sector = createSector(rows[i], alpha);    
    sectors.add(sector);
    if(sector.dense < minimum) {
      minimum = sector.dense;
    }
    if(sector.immediate < minimum) {
      minimum = sector.immediate;      
    }
    if(sector.thin < minimum) {
      minimum = sector.thin;
    }
    if(sector.dense > maximum) {
      maximum = sector.dense;
    }
    if(sector.immediate > maximum) {
      maximum = sector.immediate;      
    }
    if(sector.thin > maximum) {
      maximum = sector.thin;
    }
  }  
  
  println("minimum " + minimum);
  println("maximum "+ maximum);
  
  beginRecord(PDF, "povertyRates.pdf");     
  translate(200, 200); //place first triangle
  for(Sector sector : sectors) {
    sector.minimum = minimum;
    sector.maximum = maximum;
    
    float [] endVector = sector.display();  
    translate(endVector[0], endVector[1]);
    rotate(-alpha);
  }
  
  
  endRecord();  
}

Sector createSector(String row, float alpha) {

  String[] columns = split(row, ';');
  //println("columns.length:"+columns.length);
  String country = columns[0];
  println("country:"+country);
  double dense = Double.parseDouble(columns[1]);
  double immediate = Double.parseDouble(columns[2]);
  double thin = Double.parseDouble(columns[3]);
  
  Sector sector = new Sector(country, dense, immediate, thin, alpha);
  return sector;
}

void draw() {    
  
  
}
