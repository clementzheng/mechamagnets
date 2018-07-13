int data_history_size = 200;
int button_height = 25;
int button_gap = 10;
int text_size = 11;



////////////////
//   BUTTON   //
////////////////

class MMButton {

  String name;
  int serial_index; //index of serial data sent by arduino
  boolean inverse; //TRUE sensor val decreases when button is pressed, FALSE, sensor val increases when button is pressed
  float min = 0, max = 1023;
  float threshold = 0; //between 0 - 1
  float[] val = new float[data_history_size];
  float threshold_val;

  float x, y, w, h;
  color val_color = color(#FF0000, 255);
  color history_color = color(#EEEEEE, 10);
  color threshold_color = color(#00FF00, 255);
  color extent_color = color(#FFFFFF, 255);
  color text_color  = color(#FFFFFF);

  GUIButton calibrate_button;

  Table table;

  MMButton(String Name, int Serial_Index, boolean Inverse, float Threshold, float X, float Y, float W, float H) {
    name = Name;
    serial_index = Serial_Index;
    inverse = Inverse;
    threshold = Threshold;
    x = X;
    y = Y;
    w = W;
    h = H;
    for (int i=0; i<val.length; i++) {
      val[i] = 0;
    }
    calibrate_button = new GUIButton("calibrate", x, y+h+button_gap, w, button_height);

    try {
      table = loadTable(name+"_MMButton.csv", "header");
    } 
    catch(Error e) {
      println(e);
    }
    if (table != null) {
      TableRow row = table.getRow(0);
      min = row.getFloat("min");
      max = row.getFloat("max");
    } else {
      table = new Table();
      table.addColumn("min");
      table.addColumn("max");
      TableRow row = table.addRow();
      row.setFloat("min", min);
      row.setFloat("max", max);
      saveTable(table, "data/"+name+"_MMButton.csv");
    }
    threshold_val = (max-min)*threshold + min;
  }

  void update(float[] v) {
    if (v.length >= serial_index+1) {
      for (int i=val.length-1; i>0; i--) {
        val[i] = val[i-1];
      }
      if (inverse) {
        val[0] = -v[serial_index];
      } else {
        val[0] = v[serial_index];
      }
    }
    calibrate_button.update();
    if (calibrate_button.click()) {
      calibrate();
    }
  }

  void calibrate() {
    min = val[0];
    max = val[0];
    for (int i=0; i<val.length; i++) {
      min = min > val[i] ? val[i] : min;
      max = max < val[i] ? val[i] : max;
    }
    threshold_val = (max-min)*threshold + min;
    TableRow row = table.getRow(0);
    row.setFloat("min", min);
    row.setFloat("max", max);
    saveTable(table, "data/"+name+"_MMButton.csv");
  }

  void display() {
    stroke(history_color);
    for (int i=val.length-1; i>=0; i--) {
      float ypos = map(val[i], min, max, y, y+h);
      if (i==0) {
        stroke(val_color);
        line(x, ypos, x+w, ypos);
        fill(text_color);
        textSize(text_size);
        if (val[i] > min+(max-min)*threshold) {
          textAlign(RIGHT, BOTTOM);
        } else {
          textAlign(RIGHT, TOP);
        }
        text(nf(val[0], 0, 1), x+w, ypos);
      } else {
        line(x, ypos, x+w, ypos);
      }
    }
    stroke(extent_color);
    line(x, y, x+w, y);
    line(x, y+h, x+w, y+h);
    stroke(threshold_color);
    line(x, y+h*threshold, x+w, y+h*threshold);
    fill(text_color);
    textSize(text_size);
    textAlign(LEFT, BOTTOM);
    text(name, x, y-button_gap);
    textSize(text_size);
    textAlign(LEFT, TOP);
    text(nf(min, 0, 1), x, y);
    textSize(text_size);
    textAlign(LEFT, BOTTOM);
    text(nf(max, 0, 1), x, y+h);
    textSize(text_size);
    textAlign(LEFT, BOTTOM);
    text(nf(min+(max-min)*threshold, 0, 1), x, y+h*threshold);
    calibrate_button.display();
  }
}




//////////////
//   KNOB   //
//////////////

class MMKnob {

  String name;
  int[] serial_index = new int[2]; //indices of serial data sent by arduino
  boolean inverse; //FALSE clockwise, TRUE counter clockwise
  PVector center_point = new PVector(512, 512);
  float angle_offset = 0;
  PVector[] val = new PVector[data_history_size];
  float angle = 0;
  float max = 512;

  float x, y, d;
  color val_color = color(#FF0000, 255);
  color angle_color = color(#00FF00, 255);
  color history_color = color(#EEEEEE, 15);
  color line_color = color(#FFFFFF, 100);
  color text_color  = color(#FFFFFF);

  GUIButton calibrate_button, center_button;

  Table table;

  MMKnob(String Name, int Serial_Index0, int Serial_Index1, boolean Inverse, float X, float Y, float D) {
    name = Name;
    serial_index[0] = Serial_Index0;
    serial_index[1] = Serial_Index1;
    inverse = Inverse;
    x = X;
    y = Y;
    d = D;
    for (int i=0; i<val.length; i++) {
      val[i] = new PVector(center_point.x, center_point.y);
    }
    calibrate_button = new GUIButton("calibrate", x, y+d+button_gap, d, button_height);
    center_button = new GUIButton("center", x, y+d+button_gap*2+button_height, d, button_height);

    try {
      table = loadTable(name+"_MMKnob.csv", "header");
    } 
    catch(Error e) {
      println(e);
    }
    if (table != null) {
      TableRow row = table.getRow(0);
      center_point.x = row.getFloat("cpx");
      center_point.y = row.getFloat("cpy");
      max = row.getFloat("max");
      angle_offset = row.getFloat("angle_offset");
    } else {
      table = new Table();
      table.addColumn("cpx");
      table.addColumn("cpy");
      table.addColumn("max");
      table.addColumn("angle_offset");
      TableRow row = table.addRow();
      row.setFloat("cpx", center_point.x);
      row.setFloat("cpy", center_point.y);
      row.setFloat("max", max);
      row.setFloat("angle_offset", angle_offset);
      saveTable(table, "data/"+name+"_MMKnob.csv");
    }
  }

  void update(float[] v) {
    if (v.length >= serial_index[0]+1 && v.length >= serial_index[1]+1) {
      for (int i=val.length-1; i>0; i--) {
        val[i] = new PVector(val[i-1].x, val[i-1].y);
      }
      if (inverse) {
        val[0] = new PVector(-v[serial_index[0]], v[serial_index[1]]);
      } else {
        val[0] = new PVector(v[serial_index[0]], v[serial_index[1]]);
      }
    }
    angle = atan2(val[0].y - center_point.y, val[0].x - center_point.x) - angle_offset;

    calibrate_button.update();
    if (calibrate_button.click()) {
      calibrate();
    }
    center_button.update();
    if (center_button.click()) {
      centerCalibrate();
    }
  }

  float calibrate_tolerance = 7.5;
  void calibrate() {
    ArrayList<PVector> filter_points = new ArrayList<PVector>();
    for (int i=0; i<val.length; i++) {
      boolean check = false;
      for (PVector p : filter_points) {
        float delta = PVector.dist(p, val[i]);
        if (delta < calibrate_tolerance) {
          check = true;
          break;
        }
      }
      if (!check) {
        filter_points.add(val[i]);
      }
    }
    PVector cp = new PVector(0, 0);
    float counter = 0;
    for (PVector p : filter_points) {
      cp.add(p);
      counter++;
    }
    center_point = new PVector(cp.x/counter, cp.y/counter);
    max = 0;
    for (int i=0; i<val.length; i++) {
      float delta = PVector.dist(center_point, val[i]);
      max = max < delta ? delta : max;
    }
    TableRow row = table.getRow(0);
    row.setFloat("cpx", center_point.x);
    row.setFloat("cpy", center_point.y);
    row.setFloat("max", max);
    row.setFloat("angle_offset", angle_offset);
    saveTable(table, "data/"+name+"_MMKnob.csv");
  }

  void centerCalibrate() {
    angle_offset = angle;
    TableRow row = table.getRow(0);
    row.setFloat("cpx", center_point.x);
    row.setFloat("cpy", center_point.y);
    row.setFloat("max", max);
    row.setFloat("angle_offset", angle_offset);
    saveTable(table, "data/"+name+"_MMKnob.csv");
  }

  void display() {
    fill(history_color);
    noStroke();
    for (int i=val.length-1; i>=0; i--) {
      float px = (val[i].x - center_point.x)/max * d/2;
      float py = (val[i].y - center_point.y)/max * d/2;
      if (i==0) {
        fill(val_color);
      }
      if (sqrt(sq(px)+sq(py)) < d/2) {
        ellipse(x + d/2 + px, y + d/2 + py, 5, 5);
      }
    }
    stroke(angle_color);
    float xend = x + d/2 + d/2*cos(angle);
    float yend = y + d/2 + d/2*sin(angle);
    line(x+d/2, y+d/2, xend, yend);
    stroke(line_color);
    noFill();
    ellipse(x+d/2, y+d/2, d, d);
    fill(text_color);
    textSize(text_size);
    textAlign(CENTER, CENTER);
    text(nf(val[0].x, 0, 1)+","+nf(val[0].y, 0, 1), xend, yend);
    textAlign(CENTER, TOP);
    text(nf(center_point.x, 0, 1)+","+nf(center_point.y, 0, 1), x+d/2, y+d/2+text_size);
    textSize(text_size*1.5);
    textAlign(CENTER, CENTER);
    text(nf(degrees(angle-angle_offset), 0, 1), x+d/2, y+d/2);
    textSize(text_size);
    textAlign(LEFT, BOTTOM);
    text(name, x, y-button_gap);
    calibrate_button.display();
    center_button.display();
  }
}


///////////////
//   STICK   //
///////////////

class MMStick {

  String name;
  int[] serial_index = new int[2]; //indices of serial data sent by arduino
  boolean flipX, flipY;
  PVector center_point = new PVector(512, 512);
  PVector[] val = new PVector[data_history_size];
  float angle = 0;
  float dead_zone = 0;
  PVector start = new PVector(0, 1023);
  PVector end = new PVector(0, 1023);

  float x, y, d;
  color val_color = color(#FF0000, 255);
  color angle_color = color(#00FF00, 255);
  color history_color = color(#EEEEEE, 15);
  color line_color = color(#FFFFFF, 100);
  color text_color  = color(#FFFFFF);

  GUIButton center_button, range_button;

  Table table;

  MMStick(String Name, int Serial_Index0, int Serial_Index1, boolean fX, boolean fY, float X, float Y, float D) {
    name = Name;
    serial_index[0] = Serial_Index0;
    serial_index[1] = Serial_Index1;
    flipX = fX;
    flipY = fY;
    x = X;
    y = Y;
    d = D;
    for (int i=0; i<val.length; i++) {
      val[i] = new PVector(center_point.x, center_point.y);
    }
    center_button = new GUIButton("center", x, y+d+button_gap, d, button_height);
    range_button = new GUIButton("set range", x, y+d+button_gap*2+button_height, d, button_height);

    try {
      table = loadTable(name+"_MMStick.csv", "header");
    } 
    catch(Error e) {
      println(e);
    }
    if (table != null) {
      TableRow row = table.getRow(0);
      center_point.x = row.getFloat("cpx");
      center_point.y = row.getFloat("cpy");
      start.x = row.getFloat("sx");
      end.x = row.getFloat("ex");
      start.y = row.getFloat("sy");
      end.y = row.getFloat("ey");
      dead_zone = row.getFloat("dz");
    } else {
      table = new Table();
      table.addColumn("cpx");
      table.addColumn("cpy");
      table.addColumn("sx");
      table.addColumn("sy");
      table.addColumn("ex");
      table.addColumn("ey");
      table.addColumn("dz");
      TableRow row = table.addRow();
      row.setFloat("cpx", center_point.x);
      row.setFloat("cpy", center_point.y);
      row.setFloat("sx", start.x);
      row.setFloat("sy", start.y);
      row.setFloat("ex", end.x);
      row.setFloat("ey", end.y);
      row.setFloat("dz", dead_zone);
      saveTable(table, "data/"+name+"_MMStick.csv");
    }
  }

  void update(float[] v) {
    if (v.length >= serial_index[0]+1 && v.length >= serial_index[1]+1) {
      for (int i=val.length-1; i>0; i--) {
        val[i] = new PVector(val[i-1].x, val[i-1].y);
      }

      val[0].x = flipX ? -v[serial_index[0]] : v[serial_index[0]];
      val[0].y = flipY ? -v[serial_index[1]] : v[serial_index[1]];
    }

    center_button.update();
    if (center_button.click()) {
      centerCalibrate();
    }
    range_button.update();
    if (range_button.click()) {
      rangeCalibrate();
    }
  }

  float calibrate_tolerance = 3.0;
  void centerCalibrate() {
    float dx = 0, dy = 0;
    int indexax = 0, indexbx = 0;
    int indexay = 0, indexby = 0;
    for (int i=0; i<val.length; i++) {
      for (int j=0; j<val.length; j++) {
        float dx_check = abs(val[i].x - val[j].x);
        float dy_check = abs(val[i].y - val[j].y);
        if (dx_check > dx) {
          dx = dx_check;
          indexax = i;
          indexbx = j;
        }
        if (dy_check > dy) {
          dy = dy_check;
          indexay = i;
          indexby = j;
        }
      }
    }
    center_point.x = (val[indexax].x + val[indexbx].x)/2;
    center_point.y = (val[indexay].y + val[indexby].y)/2;
    dead_zone = 0;
    for (int i=0; i<val.length; i++) {
      float delta = PVector.dist(center_point, val[i]);
      dead_zone = dead_zone < delta ? delta : dead_zone;
    }
    dead_zone = dead_zone *1.1;
    TableRow row = table.getRow(0);
    row.setFloat("cpx", center_point.x);
    row.setFloat("cpy", center_point.y);
    row.setFloat("dz", dead_zone);
    saveTable(table, "data/"+name+"_MMStick.csv");
  }

  void rangeCalibrate() {
    start.x = center_point.x;
    start.y = center_point.y;
    end.x = center_point.x;
    end.y = center_point.y;
    for (int i=0; i<val.length; i++) {
      start.x = val[i].x < start.x ? val[i].x : start.x;
      start.y = val[i].y < start.y ? val[i].y : start.y;
      end.x = val[i].x > end.x ? val[i].x : end.x;
      end.y = val[i].y > end.y ? val[i].y : end.y;
    }
    TableRow row = table.getRow(0);
    row.setFloat("sx", start.x);
    row.setFloat("sy", start.y);
    row.setFloat("ex", end.x);
    row.setFloat("ey", end.y);
    saveTable(table, "data/"+name+"_MMStick.csv");
  }

  void display() {
    fill(history_color);
    noStroke();
    PVector p0 = new PVector(0, 0);
    for (int i=val.length-1; i>=0; i--) {
      float px, py;
      if (val[i].x < center_point.x) {
        px = (val[i].x - center_point.x)/(center_point.x - start.x) * d/2;
      } else {
        px = (val[i].x - center_point.x)/(end.x - center_point.x) * d/2;
      }
      if (val[i].y < center_point.y) {
        py = (val[i].y - center_point.y)/(center_point.y - start.y) * d/2;
      } else {
        py = (val[i].y - center_point.y)/(end.y - center_point.y) * d/2;
      }
      if (i==0) {
        fill(val_color);
        p0.x = px;
        p0.y = py;
      }
      ellipse(x + d/2 + px, y + d/2 + py, 5, 5);
    }
    stroke(line_color);
    noFill();
    rect(x, y, d, d);
    ellipse(x+d/2, y+d/2, dead_zone*2, dead_zone*2);
    fill(text_color);
    textSize(text_size);
    textAlign(CENTER, CENTER);
    text(nf(val[0].x, 0, 1)+","+nf(val[0].y, 0, 1), x+d/2+p0.x, y+d/2+p0.y);
    textAlign(CENTER, TOP);
    text(nf(center_point.x, 0, 1)+","+nf(center_point.y, 0, 1), x+d/2, y+d/2);
    textSize(text_size);
    textAlign(LEFT, BOTTOM);
    text(name, x, y-button_gap);
    center_button.display();
    range_button.display();
  }
}



class GUIButton {

  color hover_color = color(#555555);
  color fill_color = color(#222222);
  color text_color = color(#FFFFFF);

  float x, y, w, h;
  String name;

  boolean mouse_down = false;
  boolean trigger = false;
  boolean hover = false;

  GUIButton(String Name, float X, float Y, float W, float H) {
    name = Name;
    x = X;
    y = Y;
    w = W;
    h = H;
  }

  void update() {
    if (mouseX > x && mouseX < x+w && mouseY > y && mouseY < y+h) {
      hover = true;
      if (!mouse_down && mousePressed) {
        mouse_down = true;
        trigger = false;
      }
      if (mouse_down &&!mousePressed) {
        mouse_down = false;
        trigger = true;
      }
    } else {
      mouse_down = false;
      hover = false;
    }
  }

  boolean click() {
    if (trigger) {
      trigger = false;
      return true;
    } else {
      return false;
    }
  }

  void display() {
    if (hover) {
      fill(hover_color);
    } else {
      fill(fill_color);
    }
    noStroke();
    rect(x, y, w, h);
    textSize(text_size);
    textAlign(LEFT, TOP);
    fill(text_color);
    text(name, x+4, y+2);
  }
}
