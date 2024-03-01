# Working with the MKR IoT Carrier
The MKR IoT Carrier is designed for the MKR board to be attached on top of it. It comes with the following sensors:

    Five capacitive touch sensors
    A temperature, humidity, and barometric pressure sensor
    A six-axis inertial measurement unit
    A color detection sensor
    A gesture sensor

It also has an OLED display, two onboard relays, two analog Grove connectors, and one I2C Grove connector. You can see the MKR IoT Carrier in this video: https://packt.link/sfncm.

Let’s work with the MKR IoT Carrier to collect sensor data.

#Project 2 – Collecting sensor data with the Arduino MKR IoT Carrier
In this project, we will use the MKR WiFi 1010 to connect to a wireless network and then fetch the time from an NTP server when the microcontroller starts up. Afterward, every minute, we will read the temperature, humidity, and pressure and display those on the OLED display. The code for this project is available on GitHub at the following URL: https://github.com/PacktPublishing/Arduino-Data-Communications/tree/main/chapter-3/Arduino-MKR-WiFi-1010-Carrier.

Please follow these steps to complete this project:
1. Attach the MKR WiFi 1010 board to the MKR IoT Carrier, making sure the pins are aligned according to the labels.
2. Launch the Android IDE.
3. Open the Library Manager.
4. Search for and install the following libraries: MKRIoTCarrier, RTCZero, UnixTime, and Arduino_JSON.
5. Clone the project from the GitHub repository and open it in the Arduino IDE.
6. Open arduino_secrets.h and fill in your Wi-Fi credentials.
7. Upload the sketch onto the MKR board.

A video showing the code in action is available at https://packt.link/sfncm. Let’s discuss some of the code.

