# Game Controller

_A 3D printed controller comprised of two momentary push buttons and a rotary input. Two controllers can be connected to a microcontroller that communicates over usb serial to a software visualization_

<br>

## Video

[![Mechamagnets: Designing and Fabrication a Physical Input Device](https://i.vimeocdn.com/video/690320654_200x150.webp)](https://vimeo.com/261341959)

<br><br>

## Bill of Materials (per controller)

| Part Name | Quantity | Sample Source |
| --- | :---: | --- |
| <br>**_3D printed parts_** | | |
| Button Cap | 2 | [Download from repo](Print_GameController_ButtonCap.stl) |
| Button Shaft | 2 | [Download from repo](Print_GameController_ButtonShaft.stl) |
| Wheel | 1 | [Download from repo](Print_GameController_Wheel.stl) |
| Knob A | 1 | [Download from repo](Print_GameController_KnobA.stl) |
| Knob B | 1 | [Download from repo](Print_GameController_KnobB.stl) |
| Case Top | 1 | [Download from repo](Print_GameController_CaseA.stl) |
| Case Base | 1 | [Download from repo](Print_GameController_CaseB.stl) |
| <br>**_Magnets_** | | |
| _Buttons_<br>1/8 x 1/8 Inch Neodymium Rare Earth Cylinder Magnets | 8 | [Total Element](https://totalelement.com/collections/cylinder-magnets/products/1-8-x-1-8-inch-neodymium-rare-earth-cylinder-magnets-n48-100-pack) |
| _Wheel_<br>1/8 x 1/16 Inch Neodymium Rare Earth Cylinder Magnets | 20 | [Total Element](https://totalelement.com/collections/all-discs/products/1-8-x-1-16-inch-neodymium-rare-earth-disc-magnets-n48-250-pack) |
| _Knob center (to sense rotation via Hall effect)_<br>1/8 x 1/8 Inch Neodymium Rare Earth Cylinder Magnets | 1 | [Total Element](https://totalelement.com/collections/cylinder-magnets/products/1-8-x-1-8-inch-neodymium-rare-earth-cylinder-magnets-n48-100-pack) |
| _Knob option 1_<br>1/8 x 1/8 Inch Neodymium Rare Earth Cylinder Magnets | 1+ | [Total Element](https://totalelement.com/collections/cylinder-magnets/products/1-8-x-1-8-inch-neodymium-rare-earth-cylinder-magnets-n48-100-pack) |
| _Knob option 2_<br>3mm Diameter Chrome Steel Bearing Balls | 1+ | [Amazon](https://www.amazon.com/gp/product/B004YL4782) |
| <br>**_Electronics_** | | |
| Linear Hall Effect Sensor Single Axis A1324LUA-T | 4 | [Digikey](http://www.digikey.com/scripts/DkSearch/dksus.dll?Detail&itemSeq=256163689&uq=636577817741922875) |
| 4 Channel 10 Bit Analog to Digital Converter I2C Board | 1 | [Digikey](http://www.digikey.com/scripts/DkSearch/dksus.dll?Detail&itemSeq=256163686&uq=636577817741932875) |
| TRRS Breakout | 2 | [Digikey](http://www.digikey.com/scripts/DkSearch/dksus.dll?Detail&itemSeq=256163687&uq=636577817741932875) |
| TRRS Male-to-male Cable | 2 | [Amazon](https://www.amazon.com/gp/product/B01MU3TY2O) |
| Arduino-based Microcontroller with USB Serial<br>⚠️ _only one microcontroller is required for both controllers_  | 1 | [Arduino](https://store.arduino.cc/usa/arduino-micro) |
| Stranded wire to connect electronic parts |  |  |

<br>

## Code

| Item | Description |
| --- | --- |
| [**Arduino Code**](Code_GameController_MCU) | [Arduino](https://www.arduino.cc/) code<br>Parses the 4 analog inputs from each controller over I2C, and sends all eight readings over USB serial. The readings can also be visualized via the Arduino IDE serial monitor or serial plotter. |
| [**Game&nbsp;Controller Visualization**](Code_GameController_Vis) | [Processing](http://www.processing.org) code with 3 components<br>_Calibration:_ select serial port and calibrate and characterize sensor readings.<br>_Visualization:_ one to one mapping of physical controllers to on-screen representations.<br>_Game Demo:_ pong meets space invaders hybrid game. |

<br>

## Electronics Schematic

🚧 Under construction 🚧