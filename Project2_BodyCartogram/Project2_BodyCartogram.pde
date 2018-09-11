/*IAT800 2015 Fall
 Author: Weina Jin  weinaj@sfu.ca
 Project 2: visualization pain trends data with human body cartogram
 
 ### Art explaination ###
 This project maps the pain search data to the human body. 
 It creates an embodied experience while interacting with the data.
 It also reveals the body image of the pain experience.
 
 ### References ###
 Body distorted map generator are based on the following algorithm to construct continuous area cartograms:
 Dougenik, J. A, N. R. Chrisman, and D. R. Niemeyer. 1985.
 "An algorithm to construct continuous cartograms."
 Professional Geographer 37:75-81
 http://lambert.nico.free.fr/tp/biblio/Dougeniketal1985.pdf
 Also refered to the js implenment of the same algorithm: Cartograms with d3 & TopoJSON
 http://prag.ma/code/d3-cartogram/cartogram.js
 */

import java.util.Arrays;
//GUI library 
import controlP5.*;
ControlP5 cp5;
RadioButton r1;
color[] colorSwitcher = { 
  #D6B2D5, #E8B5BF, #C3EBD8, #A5D5F2, #d9d9d9, #7a0177, #bd0026, #006837, #045a8d, #252525
};

int sliderYear = 30;
int sliderMonth = 30;
int width = 1000, height = 600;
Table data;
int rowCount;
int colCount = 17;
int currentRow;
boolean released = true, slide = false, reset = false, strokeOn = false;
float[] values = new float[colCount];
PFont pfont;
PImage textImage;
Cartogram carto;
int colorSelector = 0;
void setup() {
  size(width, height, P2D);
  smooth();
  //frameRate(10);
  textImage = loadImage("project2_text.png");
  data = loadTable("painData.csv", "header");
  rowCount = data.getRowCount();
  carto = new Cartogram(bodyData, values);
  pfont = createFont("Avenir-Roman-24", 24, true);
  ControlFont font = new ControlFont(pfont, 0);
  cp5 = new ControlP5(this);

  //year slider
  cp5.addSlider("sliderYear")
    .setPosition(450, 300)
      .setSize(480, 20)
        .setRange(2005, 2015) 
          .setValue(0)
            .setNumberOfTickMarks(11)
              .setSliderMode(Slider.FLEXIBLE)
                .setHandleSize(55)
                  .setLabel("year")
                    .setColorLabel(100) 
                      .setColorTickMark(0)
                        .setColorValueLabel(0)
                          ;
  cp5.getController("sliderYear")
    .getCaptionLabel()
      .setFont(font)
        .toUpperCase(false)
          .setSize(15)
            .align(ControlP5.LEFT, ControlP5.LEFT_OUTSIDE).setPaddingX(-40)
              ;
  cp5.getController("sliderYear")
    .getValueLabel() 
      .setFont(font)
        .toUpperCase(false)
          .setSize(18)
            .align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(-1)
              ;
  //month slider
  cp5.addSlider("sliderMonth")
    .setPosition(450, 355)
      .setSize(480, 20)
        .setRange(1, 12) 
          .setValue(0)
            .setNumberOfTickMarks(12)
              .setSliderMode(Slider.FLEXIBLE)
                .snapToTickMarks(true) 
                  .setHandleSize(55)
                    .setLabel("month")
                      .setColorLabel(100) 
                        .setColorTickMark(0)
                          .setColorValueLabel(0)
                            //.setDecimalPrecision(0) 
                            ;
  cp5.getController("sliderMonth")
    .getCaptionLabel()
      .setFont(font)
        .toUpperCase(false)
          .setSize(15)
            .align(ControlP5.LEFT, ControlP5.LEFT_OUTSIDE).setPaddingX(-55)
              ;
  cp5.getController("sliderMonth")
    .getValueLabel() 
      .setFont(font)
        .toUpperCase(false)
          .setSize(18)
            .align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(-1)
              ;
  // create a toggle and change the default look to a (on/off) switch look
  cp5.addToggle("toggle")
    .setPosition(450, 450)
      .setSize(50, 20)
        .setValue(false)
          .setMode(ControlP5.SWITCH)
            .setLabel("border")
              .setColorLabel(100) 
                ;
  cp5.getController("toggle")
    .getCaptionLabel()
      .setFont(font)
        .toUpperCase(false)
          .setSize(15)
            .setPaddingX(-2).setPaddingY(-2)
              ;   
  //color switcher
  r1 = cp5.addRadioButton("radio")
    .setPosition(790, 450)
      .setItemWidth(20)
        .setItemHeight(20)
          .setItemsPerRow(5)
            .setSpacingColumn(10)
              .addItem(" ", 0)
                .addItem("  ", 1)
                  .addItem("   ", 2)
                    .addItem("    ", 3)
                      .addItem("     ", 4)
                        .activate(0)
                          ;
  r1.getItem(1)
    .setLabel("color selector")
      .setColorLabel(100) 
        .getCaptionLabel()
          .setFont(font)
            .toUpperCase(false)
              .setSize(15)
                .setPaddingX(-2).setPaddingY(-2)
                  .align(ControlP5.LEFT, ControlP5.BOTTOM_OUTSIDE).setPaddingX(-32).setPaddingY(1)
                    ;   
  for (int i = 0; i < 5; i++) {
    Toggle t = r1.getItem(i);
    t.setColorActive(colorSwitcher[i+5]);
    t.setColorForeground(colorSwitcher[i+5]);
    t.setColorBackground(colorSwitcher[i]);
  }
}

void draw() {
  background(255);
  pushMatrix();
  fill(200, 200);
  noStroke();
  rect(380, 0, 800, 800);
  rect(380, 420, 650, 400);
  popMatrix();
  resetButton();
  if (reset) { 
    carto = new Cartogram(bodyData, values);
  }
  pushMatrix();
  translate(250, 20);
  scale(-1.0, 1.0);
  carto.display(strokeOn, colorSelector);
  popMatrix();
  //border switcher's border
  pushMatrix();
  if (strokeOn) {  
    noFill();
    stroke(0);
    strokeWeight(2);
    rect(450, 450, 50, 20);
  }
  popMatrix();
  carto.textShow(mouseX, mouseY);

  image(textImage, 450, 40, 490, 184);
}

public void controlEvent(ControlEvent theEvent) {
  slide = true;
  reset = false;
  if (slide && released && millis()>5000) {
    currentRow = (sliderYear-2005) * 12 + sliderMonth -1;
    for (int i = 0; i < colCount; i ++) {
      if (currentRow >= rowCount) {
        currentRow = rowCount;
      } else {
        values[i] = data.getFloat(currentRow, i+1);
      }
    }
    carto.setValues(values);
    released = false;
  }
  slide = false;
  if (theEvent.isFrom(r1)) {
    colorSelector = abs(int(theEvent.getGroup().getValue()));
  }
}


void mouseReleased() {
  released = true;
  reset = false;
}

void resetButton() {
  color c = color(#002952);
  int wiB = 100;
  int hiB = 40;
  int posX = 830;
  int posY = 230;
  //button of reset

  pushMatrix();
  smooth();
  translate(posX, posY);
  if ( mouseX> posX && mouseX<(posX + wiB)
    && mouseY> posY  && mouseY<(posY+ hiB)  ) {
    if (mousePressed) {
      c = color(#00AAFF);
      reset = true;
    } else {
      c= color(#0074D9);
    }
  }
  fill(c);
  rect(0, 0, wiB, hiB);
  popMatrix();
  pushMatrix();
  fill(255);
  text("RESET BODY", posX+15, posY+hiB/2+3);
  popMatrix();
}

void toggle(boolean theValue) {
  strokeOn = theValue;
}

//color switcher
void keyPressed() {
  switch(key) {
    case('1'): 
    r1.activate(0); 
    break;
    case('2'): 
    r1.activate(1); 
    break;
    case('3'): 
    r1.activate(2); 
    break;
    case('4'): 
    r1.activate(3); 
    break;
    case('5'): 
    r1.activate(4); 
    break;
  }
}

