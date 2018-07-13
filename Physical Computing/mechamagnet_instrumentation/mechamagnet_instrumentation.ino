int button_val = 0;
int knob_val_A = 0;
int knob_val_B = 0;

void setup() {

  Serial.begin(9600);

}

void loop() {
  
  button_val = analogRead(A0) - 512;
  knob_val_A = analogRead(A1) - 512;
  knob_val_B = analogRead(A2) - 512;

  Serial.print(button_val); //button sensor reading at index 0;
  Serial.print(" "); //separate values with a space
  Serial.print(knob_val_A); //knob sensor A reading at index 1;
  Serial.print(" "); //separate values with a space
  Serial.print(knob_val_B); //knob sensor B reading at index 2;
  Serial.println();

  delay(25);

}
