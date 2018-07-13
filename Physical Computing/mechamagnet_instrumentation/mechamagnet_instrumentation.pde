//// Mechamagnets instrumentation and visualization via linear hall effect sensors
//// Clement Zheng 2018

// Visualize and calibrate Mechamagnet objects with this sketch.
// Each object's calibration is saved to a CSV file in this sketch's data folder, named with its "name" variable.

import processing.serial.*;

//ARDUINO Serial data format:
//separate each hall effect reading with a space (" ")
//use a new line to send each frame of data
//PROCESSING will split each line using the space delimiter to create an array of readings for each frame
Serial SERIAL_PORT;
int SERIAL_PORT_INDEX = 1; //Check arduino "port" menu and count from the top to the serial port, start from 0.
int SERIAL_ARRAY_SIZE = 0; //Incremented automatically when a new mechamagnet object is created.
float[] SERIAL_DATA = {0, 0};

MMButton button1, button2;
MMKnob knob1;
MMStick stick1;

void setup() {
  size(1000, 600);
  SERIAL_PORT = new Serial(this, Serial.list()[SERIAL_PORT_INDEX], 9600);
  button1 = new MMButton("BUTTON 1", 0, false, 0.5, 50, 50, 80, 200); //arguments: name, serial data index, inverted?, trigger threshold (0-1), xpos, ypos, width, height
  button2 = new MMButton("BUTTON 2", 1, false, 0.5, 150, 50, 80, 200);
  knob1 = new MMKnob("KNOB 1", 1, 0, false, 300, 50, 150); //arguments: name, serial data index A, serial data index B, inverted?, xpos, ypos, diameter
  stick1 = new MMStick("STICK 1", 1, 0, false, true, 500, 50, 150); //arguments: name, serial data index A, serial data index B, inverted x?, inverted y?, xpos, ypos, diameter
  //note: if the inverse variable does not work for knobs or sticks, try swapping the serial data indices instead.
}

void draw() {
  background(50);
  readSerial(); //listens to the serial port defined in setup, and updates SERIAL_DATA array
  
  button1.update(SERIAL_DATA); //updates object with new serial data.
  button2.update(SERIAL_DATA);
  knob1.update(SERIAL_DATA);
  stick1.update(SERIAL_DATA);
  button1.display(); //display the object's visualization and calibration GUI.
  button2.display();
  knob1.display();
  stick1.display();
}

void readSerial() {
  if (SERIAL_PORT.available() > 0) {
    String str =  SERIAL_PORT.readStringUntil('\n');
    if (str != null) {
      str = trim(str);
      String[] readings = str.split(" ");
      SERIAL_DATA = new float[readings.length];
      for (int i=0; i<readings.length; i++) {
        SERIAL_DATA[i] = parseFloat(readings[i]);
      }
    }
  }
}
