#include <Wire.h>
#include <Adafruit_ADS1015.h>

Adafruit_ADS1015 adsA;
Adafruit_ADS1015 adsB(0x49);

int16_t adcA0 = 0, adcA1 = 0, adcA2 = 0, adcA3 = 0;
int16_t adcB0 = 0, adcB1 = 0, adcB2 = 0, adcB3 = 0;
boolean readAds = false;

void setup()
{
  Serial.begin(9600);
  //  Serial.println("Hello!");
  //
  //  Serial.println("Getting single-ended readings from AIN0..3");
  //  Serial.println("ADC Range: +/- 6.144V (1 bit = 3mV/ADS1015, 0.1875mV/ADS1115)");

  // The ADC input range (or gain) can be changed via the following
  // functions, but be careful never to exceed VDD +0.3V max, or to
  // exceed the upper and lower limits if you adjust the input range!
  // Setting these values incorrectly may destroy your ADC!
  //                                                                ADS1015  ADS1115
  //                                                                -------  -------
  // ads.setGain(GAIN_TWOTHIRDS);  // 2/3x gain +/- 6.144V  1 bit = 3mV      0.1875mV (default)
  // ads.setGain(GAIN_ONE);        // 1x gain   +/- 4.096V  1 bit = 2mV      0.125mV
  // ads.setGain(GAIN_TWO);        // 2x gain   +/- 2.048V  1 bit = 1mV      0.0625mV
  // ads.setGain(GAIN_FOUR);       // 4x gain   +/- 1.024V  1 bit = 0.5mV    0.03125mV
  // ads.setGain(GAIN_EIGHT);      // 8x gain   +/- 0.512V  1 bit = 0.25mV   0.015625mV
  // ads.setGain(GAIN_SIXTEEN);    // 16x gain  +/- 0.256V  1 bit = 0.125mV  0.0078125mV

  while (!Serial) {} //Wait for serial connection

  Wire.begin();
  delay(1000);
  readAds = checkI2C();
}

void loop()
{
  if (readAds) {
    adcA0 = (adcA0 + adsA.readADC_SingleEnded(0)) / 2; //button A2
    adcA1 = (adcA1 + adsA.readADC_SingleEnded(1)) / 2; //knob A1
    adcA2 = (adcA2 + adsA.readADC_SingleEnded(2)) / 2; //button A1
    adcA3 = (adcA3 + adsA.readADC_SingleEnded(3)) / 2; //knob A2
    adcB0 = (adcB0 + adsB.readADC_SingleEnded(0)) / 2; //knob B1
    adcB1 = (adcB1 + adsB.readADC_SingleEnded(1)) / 2; //button B1
    adcB2 = (adcB2 + adsB.readADC_SingleEnded(2)) / 2; //knob B2
    adcB3 = (adcB3 + adsB.readADC_SingleEnded(3)) / 2; //button B2

    Serial.print(adcA1);
    Serial.print(" "); Serial.print(adcA3);
    Serial.print(" "); Serial.print(adcA2);
    Serial.print(" "); Serial.print(adcA0);
    Serial.print(" "); Serial.print(adcB0);
    Serial.print(" "); Serial.print(adcB2);
    Serial.print(" "); Serial.print(adcB1);
    Serial.print(" "); Serial.print(adcB3);
    Serial.println();
  } else {
    Serial.println("check connection and restart");
  }

  delay(25);
}

boolean checkI2C() {
  Wire.beginTransmission(0x48);
  Serial.println("Checking 0x48");
  int valA = Wire.endTransmission();
  Serial.print("0x48: ");
  Serial.println(valA);
  Wire.beginTransmission(0x49);
  Serial.println("Checking 0x49");
  int valB = Wire.endTransmission();
  Serial.print("0x49: ");
  Serial.println(valB);
  if (valB == 0 && valA == 0) {
    return true;
  } else {
    return false;
  }
}

