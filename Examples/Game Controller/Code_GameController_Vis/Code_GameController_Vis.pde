import processing.serial.*;

int SERIAL_PORT_INDEX = -1;
String SERIAL_PORT_NAME = "";
int SERIAL_BAUD = 9600;
int TIMEOUT = 20;
Serial SERIAL_PORT;
Table CALIB_TABLE;

color bgc = #FFFFFF;
color button_color_passive = #EFEFEF;
color button_color_active = #777777;
int mode = 0;

ArrayList<Controller> controller = new ArrayList<Controller>(0);
int controller_count = 0;

ArrayList<Button> mode_button = new ArrayList<Button>(0);
ArrayList<Button> serial_button = new ArrayList<Button>(0);
int button_w = 100;
int button_h = 25;
int button_buffer = 10;
int button_left = 20;
int serial_button_top = 80;

PGraphics pg1, pg2;

void setup() {
  fullScreen(P3D);
  hint(DISABLE_DEPTH_TEST);
  //noSmooth();

  pg1 = createGraphics(width/2, height);
  pg2 = createGraphics(width/2, height);
  pg1.beginDraw();
  pg1.stroke(#F0F0F0);
  for (int i=2; i<width/2; i=i+4) {
    for (int j=2; j<height; j=j+4) {
      pg1.point(i, j);
    }
  }
  pg1.endDraw();
  pg2.beginDraw();
  pg2.stroke(#B0B0B0);
  for (int i=4; i<width/2; i=i+6) {
    for (int j=4; j<height; j=j+6) {
      pg2.point(i, j);
    }
  }
  pg2.endDraw();

  CALIB_TABLE = loadTable("calibration.csv", "header");
  controller_count = CALIB_TABLE.getRowCount();
  String[] pi_url = {"controller_render_a-01.png", "controller_render_b-01.png", "controller_render_body-01.png", "controller_render_knob-01.png"};
  //adding 2 contollers
  for (int i=0; i<controller_count; i++) {
    controller.add(
      new Controller(
      CALIB_TABLE.getFloat(i, "knob_center_x"), 
      CALIB_TABLE.getFloat(i, "knob_center_y"), 
      CALIB_TABLE.getFloat(i, "knob_ref"), 
      CALIB_TABLE.getFloat(i, "button_trigger_a"), 
      CALIB_TABLE.getFloat(i, "button_trigger_b"), 
      CALIB_TABLE.getFloat(i, "button_rest_a"), 
      CALIB_TABLE.getFloat(i, "button_rest_b"), 
      calib_count, 
      i, 
      CALIB_TABLE.getString(i, "name"), 
      pi_url
      )
      );
  }

  //adding GUI buttons for the three modes
  mode_button.add(
    new Button(
    "calibration", 
    button_left+0*(button_w+button_buffer), 
    button_left, 
    button_w, 
    button_w/2, 
    button_color_passive, 
    button_color_active, 
    true
    )
    );

  mode_button.add(
    new Button(
    "visualization", 
    button_left+1*(button_w+button_buffer), 
    button_left, 
    button_w, 
    button_w/2, 
    button_color_passive, 
    button_color_active, 
    true
    )
    );

  mode_button.add(
    new Button(
    "game demo", 
    button_left+2*(button_w+button_buffer), 
    button_left, 
    button_w, 
    button_w/2, 
    button_color_passive, 
    button_color_active, 
    true
    )
    );

  mode_button.get(mode).active = true;
  createCalibButton();
  mask = loadImage("controller_render_mask-01.png");
  setupGame();
}

void draw() {
  background(bgc);
  imageMode(CORNER);
  image(pg1, 0, 0);
  image(pg2, width/2, 0);
  textSize(14);
  textAlign(LEFT, BOTTOM);

  switch(mode) {
  case 0:
    drawCalib();
    displayCalibButton();
    break;
  case 1:
    drawVis();
    break;
  case 2:
    drawGame();
    break;
  }

  for (Button b : mode_button) {
    b.display();
  }
  readSerial();
}



//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
////                                                          ////
////                       CONTROLLER                         ////
////                                                          ////
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

float button_value_buffer = 0.8;
float cull_dist = 20;

class Controller {

  float x = -1; //knob val X
  float y = -1; //knob val Y
  float xC = -1; //knob center X
  float yC = -1; //knob center Y
  float a = -1; //button A
  float b = -1; //button B
  float aT = -1; //button A trigger
  float bT = -1; //button B trigger
  float aR = -1; //button A rest
  float bR = -1; //button B rest
  PVector[] knob_pt; //history of previous knob pos 
  float[] a_pt; //history of previous button A pos
  float[] b_pt; //history of previous button A pos
  float angle = 0, pangle = 0;
  ;
  float angle_ref = 0;

  PImage[] render = new PImage[4];

  int index;
  String name;

  Controller(float xC1, float yC1, float ref, float aT1, float bT1, float aR1, float bR1, int calib_count, int i, String n, String[] pi) {
    xC = xC1;
    yC = yC1;
    aT = aT1;
    bT = bT1;
    aR = aR1;
    bR = bR1;
    angle_ref = ref;
    knob_pt = new PVector[calib_count];
    a_pt = new float[calib_count];
    b_pt = new float[calib_count];
    resetHistory(xC, yC, aT, bT);
    index = i;
    name = n;
    for (int j=0; j<render.length; j++) {
      render[j] = loadImage(pi[j]);
    }
  }

  void resetHistory(float xX, float yY, float aA, float bB) {
    for (int i=0; i<knob_pt.length; i++) {
      knob_pt[i] = new PVector(xX, yY);
      a_pt[i] = aA;
      b_pt[i] = bB;
    }
  }

  void update(float xX, float yY, float aA, float bB) {
    x = xX;
    y = yY;
    a = aA;
    b = bB;
    for (int i=knob_pt.length-1; i>0; i--) {
      knob_pt[i] = new PVector(knob_pt[i-1].x, knob_pt[i-1].y);
      a_pt[i] = a_pt[i-1];
      b_pt[i] = b_pt[i-1];
    }
    knob_pt[0] = new PVector(x, y);
    a_pt[0] = a;
    b_pt[0] = b;
    pangle = angle;
    angle = atan2(x-xC, y-yC);
  }

  void calibKnob() {
    ArrayList<PVector> points = new ArrayList<PVector>(); //point list with duplicates culled
    for (int i=0; i<knob_pt.length; i++) {
      boolean bool = true;
      for (PVector p : points) {
        float d = dist(knob_pt[i].x, knob_pt[i].y, p.x, p.y);
        if (d < cull_dist) {
          bool = false;
          break;
        }
      }
      if (bool) {
        points.add(new PVector(knob_pt[i].x, knob_pt[i].y));
      }
    }
    float xAvg = 0;
    float yAvg = 0;
    for (PVector p : points) {
      xAvg = xAvg + p.x;
      yAvg = yAvg + p.y;
    }
    xC = xAvg/(float)points.size();
    yC = yAvg/(float)points.size();
    CALIB_TABLE.setFloat(index, "knob_center_x", xC);
    CALIB_TABLE.setFloat(index, "knob_center_y", yC);
    saveTable(CALIB_TABLE, "data/calibration.csv");
  }

  void calibKnobRef() {
    CALIB_TABLE.setFloat(index, "knob_ref", angle);
    saveTable(CALIB_TABLE, "data/calibration.csv");
  }

  void calibButtonA() {
    float aMax = 0;
    float aMin = aT;
    for (int i=0; i<a_pt.length; i++) {
      aMax = a_pt[i] > aMax ? a_pt[i] : aMax;
      aMin = a_pt[i] < aMin ? a_pt[i] : aMin;
    }
    aR = aMin + (aMax-aMin)*(0.05);
    aT = aMin + (aMax-aMin)*(button_value_buffer);
    CALIB_TABLE.setFloat(index, "button_trigger_a", aT);
    CALIB_TABLE.setFloat(index, "button_rest_a", aR);
    saveTable(CALIB_TABLE, "data/calibration.csv");
  }

  void calibButtonB() {
    float bMax = 0;
    float bMin = bT;
    for (int i=0; i<b_pt.length; i++) {
      bMax = b_pt[i] > bMax ? b_pt[i] : bMax;
      bMin = b_pt[i] < bMin ? b_pt[i] : bMin;
    }
    bR = bMin + (bMax-bMin)*(0.05);
    bT = bMin + (bMax-bMin)*(button_value_buffer);
    CALIB_TABLE.setFloat(index, "button_trigger_b", bT);
    CALIB_TABLE.setFloat(index, "button_rest_b", bR);
    saveTable(CALIB_TABLE, "data/calibration.csv");
  }
}


//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
////                                                          ////
////                       CALIBRATION                        ////
////                                                          ////
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

int calib_count = 200;
float knob_scale_factor = 1;
float angle_length = 180;
float button_scale_factor = 1;
float knob_circle_size = 10;
float crosshair_size = 60;
float knob_offset_y = 80;
float button_offset_x = 140;
float button_offset_y = 170;
float button_size = 150;
String alphabet = "ABCDEFGHIJKLMNOPQRSTUVabcdefghijklmnopqrstuv";
color strokeA = #555555;
color strokeB = #00AA88;
int strokeW1 = 2;
int strokeW2 = 1;
int button_w_calib = 120;
int button_h_calib = 25;
int button_buffer_calib = 30;

ArrayList<Button> calib_button = new ArrayList<Button>();

void createCalibButton() {
  float x_4 = (float)width/4;
  float y_2 = (float)height/2;
  int i=0;
  for (Controller c : controller) {
    calib_button.add(
      new Button(
      "calibrate knob", 
      x_4*(1+i*2)-button_w_calib/2, 
      y_2+knob_offset_y+angle_length+button_buffer_calib, 
      button_w_calib, 
      button_h_calib, 
      button_color_passive, 
      button_color_active, 
      false
      )
      );

    calib_button.add(
      new Button(
      "calibrate ref", 
      x_4*(1+i*2)-button_w_calib/2, 
      y_2+knob_offset_y+angle_length+button_buffer_calib+button_h_calib*1.5, 
      button_w_calib, 
      button_h_calib, 
      button_color_passive, 
      button_color_active, 
      false
      )
      );

    calib_button.add(
      new Button(
      "calibrate A", 
      x_4*(1+i*2)-button_w_calib/2-button_offset_x-button_size*0.7, 
      y_2-button_offset_y+button_size/2, 
      button_w_calib, 
      button_h_calib, 
      button_color_passive, 
      button_color_active, 
      false
      )
      );

    calib_button.add(
      new Button(
      "calibrate B", 
      x_4*(1+i*2)-button_w_calib/2+button_offset_x+button_size*0.7, 
      y_2-button_offset_y+button_size/2, 
      button_w_calib, 
      button_h_calib, 
      button_color_passive, 
      button_color_active, 
      false
      )
      );

    i++;
  }
}

void displayCalibButton() {
  for (Button b : calib_button) {
    b.display();
  }
}

void drawCalib() {
  float x_4 = (float)width/4;
  float y_2 = (float)height/2;

  int i = 0;
  for (Controller c : controller) {

    //KNOB
    PVector k_ref = new PVector(c.xC, c.yC);
    PVector k_pos = new PVector(x_4*(1+i*2), y_2+knob_offset_y);
    noFill();
    for (int j=0; j<c.knob_pt.length; j++) {
      float xPos1 = knob_scale_factor*(c.knob_pt[j].x - k_ref.x) + k_pos.x;
      float yPos1 = knob_scale_factor*(c.knob_pt[j].y - k_ref.y) + k_pos.y;
      if (j>0) {
        strokeWeight(strokeW1);
        stroke(strokeB, (int)(150f*(float)(calib_count-j)/(float)(calib_count)));
        float xPos2 = knob_scale_factor*(c.knob_pt[j-1].x - k_ref.x) + k_pos.x;
        float yPos2 = knob_scale_factor*(c.knob_pt[j-1].y - k_ref.y) + k_pos.y;
        line(xPos1, yPos1, xPos2, yPos2);
      } else {
        strokeWeight(strokeW1);
        stroke(strokeA);
        float xPos3 = angle_length*sin(c.angle);
        float yPos3 = angle_length*cos(c.angle);
        line(k_pos.x+xPos3, k_pos.y+yPos3, k_pos.x, k_pos.y);
        textAlign(CENTER, CENTER);
        text(nf(c.x, 0, 0)+", "+nf(c.y, 0, 0), xPos1, yPos1);
        strokeWeight(strokeW2);
        stroke(strokeB);
        arc(k_pos.x, k_pos.y, 1.5*crosshair_size, 1.5*crosshair_size, -PI/2, PI/2-c.angle);
        textAlign(LEFT, TOP);
        text(nf(-(degrees(c.angle)-180), 0, 1)+" deg", k_pos.x+10, k_pos.y+crosshair_size);
      }
    }
    strokeWeight(strokeW2);
    stroke(strokeA, 100);
    ellipse(k_pos.x, k_pos.y, crosshair_size*6, crosshair_size*6);
    stroke(50);
    line(k_pos.x-crosshair_size, k_pos.y, k_pos.x+crosshair_size, k_pos.y);
    line(k_pos.x, k_pos.y-crosshair_size, k_pos.x, k_pos.y+crosshair_size);
    textAlign(LEFT, BOTTOM);
    text(nf(c.xC, 0, 1)+", "+nf(c.yC, 0, 1), k_pos.x+10, k_pos.y-10);

    //BUTTON A
    PVector a_pos = new PVector(x_4*(1+i*2)-button_offset_x, y_2-button_offset_y);
    for (int j=0; j<c.a_pt.length; j++) {
      float dia = map(c.a_pt[j], c.aR, c.aT, 0, button_size);
      strokeWeight(strokeW1);
      if (dia >= button_size) {
        stroke(strokeB, (int)(50f*(float)(calib_count-j)/(float)(calib_count)));
      } else {
        stroke(200, (int)(50f*(float)(calib_count-j)/(float)(calib_count)));
      }
      ellipse(a_pos.x, a_pos.y, dia, dia);
    }
    float dia2 = map(c.a_pt[0], c.aR, c.aT, 0, button_size);
    strokeWeight(strokeW2);
    stroke(strokeB);
    ellipse(a_pos.x, a_pos.y, dia2, dia2);
    stroke(strokeA);
    ellipse(a_pos.x, a_pos.y, button_size, button_size);
    textAlign(CENTER, CENTER);
    text(nf(c.aR, 0, 0), a_pos.x, a_pos.y);
    text(nf(c.a, 0, 0), a_pos.x-dia2/2, a_pos.y-20);
    textAlign(RIGHT, CENTER);
    text(nf(c.aT, 0, 0), a_pos.x-button_size/2-10, a_pos.y);

    //BUTTON B
    PVector b_pos = new PVector(x_4*(1+i*2)+button_offset_x, y_2-button_offset_y);
    for (int j=0; j<c.b_pt.length; j++) {
      float dia3 = map(c.b_pt[j], c.bR, c.bT, 0, button_size);
      strokeWeight(strokeW1);
      if (dia3 >= button_size) {
        stroke(strokeB, (int)(50f*(float)(calib_count-j)/(float)(calib_count)));
      } else {
        stroke(200, (int)(50f*(float)(calib_count-j)/(float)(calib_count)));
      }
      ellipse(b_pos.x, b_pos.y, dia3, dia3);
    }
    float dia4 = map(c.b_pt[0], c.bR, c.bT, 0, button_size);
    strokeWeight(strokeW2);
    stroke(strokeB);
    ellipse(b_pos.x, b_pos.y, dia4, dia4);
    stroke(strokeA);
    ellipse(b_pos.x, b_pos.y, button_size, button_size);
    textAlign(CENTER, CENTER);
    text(nf(c.bR, 0, 0), b_pos.x, b_pos.y);
    text(nf(c.b, 0, 0), b_pos.x-dia4/2, b_pos.y-20);
    textAlign(RIGHT, CENTER);
    text(nf(c.bT, 0, 0), b_pos.x-button_size/2-10, b_pos.y);

    textAlign(CENTER, CENTER);
    text(c.name, k_pos.x, a_pos.y-button_size*0.7);

    i++;
  }
}


//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
////                                                          ////
////                      VISUALIZATION                       ////
////                                                          ////
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

PVector buttonA_movement = new PVector(21, 34);
PVector buttonB_movement = new PVector(-21, 34);
PVector knob_center = new PVector(0, 18);
PImage mask;

float scale_factor = 1.0;

void drawVis() {
  float x_4 = width/4;
  float y_2 = height/2;
  imageMode(CENTER);
  int i=0;
  for (Controller c : controller) {
    pushMatrix();
    translate((1+i*2)*x_4, y_2);
    scale(scale_factor);
    float a_factor = (c.a-c.aR)/(c.aT-c.aR);
    a_factor = a_factor > 1 ? 1 : a_factor < 0 ? 0 : a_factor; 
    image(c.render[0], a_factor*buttonA_movement.x, a_factor*buttonA_movement.y);
    float b_factor = (c.b-c.bR)/(c.bT-c.bR);
    b_factor = b_factor > 1 ? 1 : b_factor < 0 ? 0 : b_factor; 
    image(c.render[1], b_factor*buttonB_movement.x, b_factor*buttonB_movement.y);
    image(c.render[2], 0, 0);
    translate(knob_center.x, knob_center.y);
    rotate(-c.angle+c.angle_ref);
    image(c.render[3], 0, 0);
    popMatrix();
    pushMatrix();
    translate((1+i*2)*x_4, y_2);
    image(mask, 0, 0);
    popMatrix();
    textAlign(CENTER, CENTER);
    text(c.name, (1+i*2)*x_4, y_2+320);
    i++;
  }
}


//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
////                                                          ////
////                        GAME DEMO                         ////
////                                                          ////
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

ArrayList<Player> player = new ArrayList<Player>();
float top_buffer = 100, top_buffer_width = 10;
PGraphics top_buffer_image;
float paddle_w = 28, paddle_h = 150;
float ball_diameter = 55;
float bullet_diameter = 30;
int time_delay_ball = 1500;
int time_delay_bullet = 1000;
float ball_vel_x = 13;
float ball_vel_y = 18;
float bullet_vel_x = 30;
int ball_counter = 0;
float button_sensitivity_adjustment = 0;

class Player {

  PVector pos;
  float vel = 0;
  float acc = 5.0;
  float max_vel = 35;
  float dacc = 0.95;
  float w = paddle_w;
  float h = paddle_h;
  float dir;
  PGraphics pg;
  int ball_count = 6;
  int max_ball_count = ball_count;
  int bullet_count = 6;
  int max_bullet_count = bullet_count;
  int time_stamp_ball = 0;
  boolean ball_bool = true;
  int time_stamp_bullet = 0;
  boolean bullet_bool = true;
  int score=0;
  int index;

  Player(float x, float y, float d, int ii) {
    pos = new PVector(x, y);
    dir = d;
    pg = createGraphics((int)w, (int)h);
    pg.beginDraw();
    for (int i=0; i<w*h; i++) {
      int i1 = i%(int)w;
      int i2 = i/(int)w;
      if (i%6==0) {
        pg.stroke(0);
      } else if (i%3==0) {
        pg.stroke(0);
      } else {
        pg.stroke(150);
      }
      pg.point(i1, i2);
    }
    pg.endDraw();
    index = ii;
  }

  void update(float k1, float k2, float a1, float a2, float aT, float b1, float b2, float bT) {
    float delta = 0;
    k1 = k1+PI;
    k2 = k2+PI;
    if (k1 < PI/2 && k2 > PI/2*3) {
      delta = k1+(TWO_PI-k2);
    } else if (k1 > PI/2*3 && k2 < PI/2) {
      delta = -(TWO_PI-k1) - k2;
    } else {
      delta = k1 - k2;
    }
    delta = -delta;
    vel = vel + delta*acc;
    if (vel > max_vel) {
      vel = max_vel;
    } else if (vel < -max_vel) {
      vel = -max_vel;
    }
    pos.y = pos.y + vel;
    if (pos.y-h/2 <= top_buffer) {
      pos.y = top_buffer+h/2;
    } else if (pos.y+h/2 >= height) {
      pos.y = height-h/2;
    }
    vel = vel*dacc;

    if (a1 > aT-button_sensitivity_adjustment && ball_bool) {
      if (ball_count > 0) {
        ball_count--;
        time_stamp_ball = millis();
        ball.add(new Ball(pos.x+dir*ball_diameter*0.6, pos.y, dir*ball_vel_x, random(-ball_vel_y, ball_vel_y), ball_counter));
        ball_counter++;
        ball_bool = false;
      } else {
        fill(#FF0000, 150);
        rectMode(CENTER);
        rect(pos.x+dir*3, pos.y, w+6, h);
        rectMode(CORNER);
      }
    } else if (a1 < aT && !ball_bool) {
      ball_bool = true;
    }

    if (millis()-time_stamp_ball >= time_delay_ball) {
      ball_count++;
      ball_count = ball_count > max_ball_count ? max_ball_count : ball_count;
      time_stamp_ball = millis();
    }

    if (b1 > bT-button_sensitivity_adjustment && bullet_bool) {
      if (bullet_count > 0) {
        bullet_count--;
        time_stamp_bullet = millis();
        bullet.add(new Bullet(pos.x+dir*bullet_diameter/2, pos.y, dir*bullet_vel_x, index));
        bullet_bool = false;
      } else {
        fill(#FFAA00, 150);
        rectMode(CENTER);
        rect(pos.x+dir*3, pos.y, w+6, h);
        rectMode(CORNER);
      }
    } else if (b1 < bT && !bullet_bool) {
      bullet_bool = true;
    }

    if (millis()-time_stamp_bullet >= time_delay_bullet) {
      bullet_count++;
      bullet_count = bullet_count > max_bullet_count ? max_bullet_count : bullet_count;
      time_stamp_bullet = millis();
    }
  }

  void display() {
    imageMode(CENTER);
    image(pg, pos.x, pos.y);
    imageMode(CORNER);
    for (int i=0; i<ball_count; i++) {
      fill(130);
      stroke(255);
      ellipse(width/2 - dir*20*(i+2), top_buffer+30, 10, 10);
    }
    for (int i=0; i<bullet_count; i++) {
      fill(160);
      stroke(255);
      rectMode(CENTER);
      rect(width/2 - dir*20*(i+2), top_buffer+60, 10, 10);
      rectMode(CORNER);
    }
  }
}

ArrayList<Ball> ball = new ArrayList<Ball>();
class Ball {

  PVector pos;
  PVector vel;
  float dia = ball_diameter;
  boolean kill = false;
  int index;

  Ball(float x, float y, float vx, float vy, int i) {
    pos = new PVector(x, y);
    vel = new PVector(vx, vy);
    index = i;
  }

  void update() {
    pos.add(vel);

    //bounce off walls
    if (pos.y+dia/2 > height) {
      vel.y = -abs(vel.y);
    } else if (pos.y-dia/2 < top_buffer) {
      vel.y = abs(vel.y);
    }
    //die after baseline
    if (pos.x-dia/2 > width) {
      kill = true;
      player.get(0).score = player.get(0).score + 1;
    } else if (pos.x+dia/2 < 0) {
      kill = true;
      player.get(1).score = player.get(1).score + 1;
    }
    //reflect on paddle
    for (Player p : player) {
      float left = p.pos.x-p.w/2;
      float right = p.pos.x+p.w/2;
      float top = p.pos.y-p.h/2;
      float bottom = p.pos.y+p.h/2;
      float left1 = pos.x-dia/2;
      float right1 = pos.x+dia/2;
      float top1 = pos.y-dia/2;
      float bottom1 = pos.y+dia/2;
      if (left < right1 && right > left1 && top < bottom1 && bottom > top1) {
        vel.x = p.dir*abs(vel.x);
        vel.y = vel.y - p.vel*0.2;
        //p.score = p.score + 5;
      }
    }

    for (Ball b : ball) {
      if (b.index != index) {
        float left = b.pos.x-b.dia/2;
        float right = b.pos.x+b.dia/2;
        float top = b.pos.y-b.dia/2;
        float bottom = b.pos.y+b.dia/2;
        float left1 = pos.x-dia/2;
        float right1 = pos.x+dia/2;
        float top1 = pos.y-dia/2;
        float bottom1 = pos.y+dia/2;
        if (left < right1 && right > left1 && top < bottom1 && bottom > top1) {
          vel.x = -vel.x;
          vel.y = -vel.y;
        }
      }
    }
  }

  void display() {
    fill(110);
    polygon(pos.x, pos.y, dia, (int)random(8, 12));
  }
}

ArrayList<Bullet> bullet = new ArrayList<Bullet>();
class Bullet {
  PVector pos;
  PVector vel;
  float dia = bullet_diameter;
  boolean kill = false;
  int index;

  Bullet(float x, float y, float vx, int i) {
    pos = new PVector(x, y);
    vel = new PVector(vx, 0);
    index = i;
  }

  void update() {
    pos.add(vel);

    for (Ball b : ball) {
      float left = b.pos.x-b.dia/2;
      float right = b.pos.x+b.dia/2;
      float top = b.pos.y-b.dia/2;
      float bottom = b.pos.y+b.dia/2;
      float left1 = pos.x-dia/2;
      float right1 = pos.x+dia/2;
      float top1 = pos.y-dia/2;
      float bottom1 = pos.y+dia/2;
      if (left < right1 && right > left1 && top < bottom1 && bottom > top1) {
        b.kill = true;
        kill = true;
        fill(255, 230);
        ellipse(pos.x, pos.y, b.dia*2, b.dia*2);
        player.get(index).score++;
      }
    }

    if (pos.x > width || pos.x < 0) {
      kill = true;
    }
  }

  void display() {
    fill(random(200, 255), random(100, 200), 0);
    polygon(pos.x, pos.y, dia, (int)random(4, 6));
  }
}

void polygon(float x, float y, float diameter, int npoints) {
  float angle = TWO_PI / npoints;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * diameter/2;
    float sy = y + sin(a) * diameter/2;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}

void setupGame() {
  top_buffer_image = createGraphics(width, width);
  top_buffer_image.beginDraw();
  top_buffer_image.strokeWeight(1);
  top_buffer_image.stroke(100);
  for (int i=(int)-top_buffer_width; i<width+top_buffer_width; i=i+5) {
    for (int j=0; j<top_buffer_width; j++) {
      top_buffer_image.point(i-j, top_buffer-j);
    }
  }
  top_buffer_image.endDraw();

  player.add(new Player(paddle_w*2, ((float)height-top_buffer)/2+top_buffer, 1, 0));
  player.add(new Player(width-paddle_w*2, ((float)height-top_buffer)/2+top_buffer, -1, 1));
}

void drawGame() {
  image(top_buffer_image, 0, 0);
  noFill();
  int i=0;
  for (Player p : player) {
    p.update(
      controller.get(i).angle, 
      controller.get(i).pangle, 
      controller.get(i).a_pt[0], 
      controller.get(i).a_pt[1], 
      controller.get(i).aT, 
      controller.get(i).b_pt[0], 
      controller.get(i).b_pt[1], 
      controller.get(i).bT
      );
    p.display();
    i++;
  }
  for (Ball b : ball) {
    b.update();
    b.display();
  }
  for (Bullet b : bullet) {
    b.update();
    b.display();
  }
  
  for (Player p : player) {
    textAlign(CENTER, CENTER);
    textSize(20);
    fill(25);
    text(p.score, width/2-p.dir*20*(11), top_buffer+45);
  }

  for (int j=0; j<ball.size(); j++) {
    if (ball.get(j).kill) {
      ball.remove(j);
      j--;
    }
  }
  for (int j=0; j<bullet.size(); j++) {
    if (bullet.get(j).kill) {
      bullet.remove(j);
      j--;
    }
  }
}



//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
////                                                          ////
////                          SERIAL                          ////
////                                                          ////
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

void setSerial(String portNameStation) {
  if (SERIAL_PORT != null) {
    SERIAL_PORT.clear();
    SERIAL_PORT.stop();
  }
  try {
    SERIAL_PORT = new Serial(this, portNameStation, SERIAL_BAUD);
    SERIAL_PORT_NAME = portNameStation;
    println("Listening to port", portNameStation);
  }
  catch (Exception e) {
    println("ERROR: port not found");
    SERIAL_PORT_INDEX = -1;
    SERIAL_PORT_NAME = "";
  }
}

int counter = 0;
int timeoutCounter = 0;

void readSerial() {
  String[] portNameArr = Serial.list();
  if (serial_button.size() != portNameArr.length) {
    serial_button.clear();
    for (int i=0; i<portNameArr.length; i++) {
      serial_button.add(new Button(
        portNameArr[i], 
        button_left, 
        serial_button_top+i*(button_h+button_buffer), 
        button_w, 
        button_h, 
        button_color_passive, 
        button_color_active, 
        true
        ));
    }
  }
  if (mode==0) {
    for (Button b : serial_button) {
      b.display();
    }
  }
  if (SERIAL_PORT != null && !SERIAL_PORT_NAME.equals("")) {
    String val = "";
    if (SERIAL_PORT.available() > 0) {
      val = SERIAL_PORT.readStringUntil('\n');
      timeoutCounter = 0;
    } else {
      timeoutCounter++;
    }
    if (timeoutCounter >= TIMEOUT) {
      SERIAL_PORT_INDEX = -1;
      SERIAL_PORT_NAME = "";
      SERIAL_PORT.clear();
      SERIAL_PORT.stop();
      timeoutCounter = 0;
      for (Button b : serial_button) {
        b.active = false;
      }
      println("TIMEOUT: disconnecting from serial port");
    }
    if (val != null) {
      val = trim(val); //remove whitespace
      String[] readings = split(val, ' ');
      if (readings.length==4*controller_count) {
        //println(readings);
        for (int i=0; i<controller_count; i++) {
          controller.get(i).update(
            parseFloat(readings[4*i+0]), 
            parseFloat(readings[4*i+1]), 
            parseFloat(readings[4*i+2]), 
            parseFloat(readings[4*i+3])
            );
        }
      }
    }
  }
}


//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////
////                                                          ////
////                           GUI                            ////
////                                                          ////
//////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////

class Button {
  String name;
  float x;
  float y;
  float w;
  float h;
  color bgPassive;
  color bgActive;
  boolean toggle;
  boolean active = false;

  Button(String n, float posX, float posY, float wW, float hH, color bgP, color bgA, boolean tog) {
    name = n;
    x = posX;
    y = posY;
    h = hH;
    w = wW;
    bgPassive = bgP;
    bgActive = bgA;
    toggle = tog;
  }

  void display() {
    if (hover() || active) {
      fill(bgActive);
    } else {
      fill(bgPassive);
    }
    noStroke();
    rect(x, y, w, h);
    if (hover() || active) {
      fill(255);
    } else {
      fill(0);
    }
    textSize(14);
    textAlign(LEFT, BOTTOM);
    text(name, x+5, y+h-4);
    fill(0);
  }

  boolean hover() {
    if (mouseX >= x && mouseX <= x+w && mouseY >= y && mouseY <= y+h) {
      return true;
    } else {
      return false;
    }
  }
}

void mousePressed() {
  for (Button b : serial_button) {
    if (b.hover()) {
      for (Button b2 : serial_button) {
        b2.active = false;
      }
      b.active = true;
      setSerial(b.name);
    }
  }

  int counter = 0;
  for (Button b : mode_button) {
    if (b.hover()) {
      for (Button b2 : mode_button) {
        b2.active = false;
      }
      b.active = true;
      mode = counter;
      for (Player p : player) {
        p.score = 0;
      }
    }
    counter++;
  }

  counter = 0;
  for (Button b : calib_button) {
    if (b.hover() && mode==0) {
      int i = counter/4;
      int j = counter%4;
      switch(j) {
      case 0:
        controller.get(i).calibKnob();
        break;
      case 1:
        controller.get(i).calibKnobRef();
        break;
      case 2:
        controller.get(i).calibButtonA();
        break;
      case 3:
        controller.get(i).calibButtonB();
        break;
      }
      break;
    }
    counter++;
  }
}