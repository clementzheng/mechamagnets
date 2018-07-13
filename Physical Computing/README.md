# Physical computing

This section details the sensors employed by Mechamagnets, and code used to read the sensors.
<br><br><br>

## Sensor List

| Part Name | Part Number | Description | Source |
| --- | --- | --- | --- |
| Linear Hall effect sensor | A1324LUA-T | Package: 3-SIP<br>Sensitivity : 5.0mV/G<br>Suitable for sensing 1/8in by 1/8in N48 neodymium magnets at a distance of ~ 5 to 10mm. | [Digikey](https://www.digikey.com/product-detail/en/allegro-microsystems-llc/A1324LUA-T/620-1432-ND/2728144) |
| Linear Hall effect sensor | A1308KUA-1-T | Package: 3-SIP<br>Sensitivity : 1.3mV/G<br>Suitable for sensing 1/4in by 1/16in N48 neodymium magnets at a distance of ~ 5 to 10mm. | [Digikey](https://www.digikey.com/product-detail/en/allegro-microsystems-llc/A1308KUA-1-T/620-1863-ND/6821585) |
<br><br>

## Custom PCBs
🚧 Under construction 🚧
<br><br><br>

## Arduino / Processing code
<br>

**mechamagnet_instrumentation** folder
<br><br>

| `mechamagnet_instrumentation.ino` | Example Arduino sketch to read linear Hall effect sensors |
 --- | --- |
| in setup<br> `Serial.begin(9600);` | Initialize the serial communication which we will use in Processing to obtain the sensor readings |
| in loop<br> `analogRead(int analog_pin_number);` | Read the sensor and return an integer based on the resolution of the ADC (10bit range = 0 - 1023). <br>Linear Hall effect sensors return the middle value (512 in the case of 10bit ADCs) when it does not pick up any magnetic field. The values deviate from the middle according to the strength and polarity of the magnetic field. |
| in loop<br> `Serial.print(val);`<br>`Serial.print(" ");` | Print a sensor reading to the serial port, and then a space character. The space is use to separate each sensor value. |
| in loop<br> `Serial.println();`<br>`delay(25);` | End the serial print with a line break. Processing will listen for this line break to determine when it has received a complete set of sensor readings. We inroduce a delay to avoid overloading Processing's buffer and to ensure minimal delay between sensor reading and visualization. |

<br><br>

| `mechamagnet_instrumentation.pde` | Example Processing visualization sketch |
| --- | --- |
| Objects<br>`MMButton`<br>`MMKnob`<br>`MMStick` | Button: push buttons, switches etc.<br>Knob: knobs, dials, rotary encoders etc.<br>Stick: joystick, thumbsticks etc.<br><br> |
| Creating an object | First, declare object, e.g. <br>`MMButton button`<br><br>Then, in setup, define object, e.g.<br>`button = new MMButton("BUTTON 1", 0, false, 0.5, 50, 50, 80, 200);`  <br><br>|
| Updating and displaying object | in draw loop<br><br>update object with serial data, e.g.<br>`button.update(SERIAL_DATA);`<br><br>then display object<br>`button.display();`<br><br> |
| Object arguments: MMButton<br>`MMButton(name, index, inverted, threshold, xpos, ypos, w, h)` | *name (String)*: object name, also used to name calibration CSV<br>*index (int)*: index of value from SERIAL_DATA to read<br>*inverted (boolean)*: TRUE&mdash;values decrease when button is pressed<br>*threshold (float)*: from 0-1, actuation point of button<br>*xpos, ypos, w, h (float)*: x position, y position, width and height of visualization.<br><br> |
| Object arguments: MMKnob<br>`MMKnob(name, index0, index1, inverted, xpos, ypos, d)` | *name (String)*: object name, also used to name calibration CSV<br>*index0 (int)*: first index of value from SERIAL_DATA to read<br>*index1 (int)*: second index of value from SERIAL_DATA to read<br>*inverted (boolean)*: TRUE&mdash;flip first sensor reading<br>*xpos, ypos, d (float)*: x position, y position and diameter of visualization.<br><br>*if visualization rotates in the opposite direction, try switching index0 and index1.* <br><br>|
| Object arguments: MMStick<br>`MMStick(name, index0, index1, inverted0, inverted1, xpos, ypos, size)` | *name (String)*: object name, also used to name calibration CSV<br>*index0 (int)*: first index of value from SERIAL_DATA to read<br>*index1 (int)*: second index of value from SERIAL_DATA to read<br>*inverted0 (boolean)*: TRUE&mdash;flip first sensor reading<br>*inverted1 (boolean)*: TRUE&mdash;flip second sensor reading<br>*xpos, ypos, size (float)*: x position, y position and size of visualization.<br><br>*if visualization axes are swapped, switch index0 and index1.*|
| Calibration method | Each object has its own calibration method(s). They can be accessed through the GUI button(s) under each individual visualizations. Calibrated values are stored in a CSV file located in the sketch's "data" folder, and named after the objects `name` field. When the sketch starts, it will attempt to find and load the object's calibration file; if the file cannot be found, a new file will be created. <br><br>|
| `MMButton` fields | `val` *(float array)*: an array with the last x number of sensor readings.<br>`val[0]` *(float)*: most recent sensor reading.<br>`min` *(float)*: minimum sensor value.<br>`max` *(float)*: maximum sensor value.<br>`threshold` *(float)*: button actuation point (0-1).<br>`threshold_val` *(float)*: button actuation point between min and max values.<br><br> |
| `MMKnob` fields | `val` *(PVector)*: an array of 2D vectors with the last x number of sensor readings.<br>`val[0]` *(PVector)*: Most recent sensor reading.<br>`val[i].x` *(float)*: first sensor reading.<br>`val[i].y` *(float)*: second sensor reading.<br>`angle` *(float)*: knob's angle of orientation.<br>`center_point` *(PVector)*: center of rotation.<br>`angle_offset` *(float)*: knob's start of rotation.<br><br> |
| `MMStick` fields | `val` *(PVector)*: an array of 2D vectors with the last x number of sensor readings.<br>`val[0]` *(PVector)*: Most recent sensor reading.<br>`val[i].x` *(float)*: first sensor reading.<br>`val[i].y` *(float)*: second sensor reading.<br>`start` *(PVector)*: minimum sensor readings.<br>`end` *(PVector)*: maximum sensor readings<br>`center_point` *(PVector)*: stick's center point.<br><br> |


