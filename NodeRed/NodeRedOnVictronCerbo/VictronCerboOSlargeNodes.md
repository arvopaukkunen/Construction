Ref:
https://github.com/victronenergy/node-red-contrib-victron/wiki/Available-nodes

# Available nodes(26.3.2024)

On this page you find and overview of all possible services and measurements for the available nodes. The edit panel will only show items available in your system. For example a Cerbo CX has 2 relays and thus will show 2 relays to control. An EasySolar-II GX has only one relay and thus will only show one.

You can find more background information on the paths and how to use them here. https://github.com/victronenergy/venus/wiki/dbus

**Input nodes:** 
AC Charger, AC Load, Alternator, Battery Monitor, DC-DC, DC Load, DC Source, DC System, Digital Input, Energy Meter, ESS, EV Charger, Fuel cell, Generator, GPS, Grid Meter, Inverter, Meteo, Motordrive, Multi RS, Pulsemeter, Pump, PV Inverter, Relay, Settings, Solar Charger, System, Tank Sensor, Temperature Sensor, VE.Bus System

**Output nodes:** 
AC Charger Control, Battery Monitor Control, Charger Control, DC-DC Control, ESS Control, EV Charger Control, GX Generator Control, Inverter Control, Multi RS Control, Pump Control, PV Inverter Control, Relay Control, Settings Control, Solar Charger Control, VE.Bus System Control
If there are services and paths not covered by the above nodes, there are also 2 custom nodes that allow you to read from and write to all found dbus services and paths.

## Input nodes
The input nodes have two selectable inputs: the devices select and measurement select. The available options are dynamically updated based on the data that is actually available on the Venus device.

    - Device select - lists all available devices
    - Measurement select - lists all available device-specific measurements
    - Node label input field - sets a custom label for the node

The measurement unit type is shown in the measurement label in brackets, e.g. Battery voltage (V). In case the data type is enumerated, an appropriate enum legend is shown below the selected option.

If the data type is float, a dropdown for rounding the output appears.

By default the node outputs its value every five seconds. If the only changes is checked, the node will only output on value changes.

![alt text](edit-vebus-input.png)

### AC Charger
The AC charger can be read with this node.

AC Current limit (A), dbus path: /Ac/In/CurrentLimit, type float
AC Current (A), dbus path: /Ac/In/L1/I, type float
AC Power (W), dbus path: /Ac/In/L1/P, type float
High voltage alarm, dbus path: /Alarms/HighVoltage, type enum


    0 - No alarm
    1 - Warning
    2 - Alarm


Low voltage alarm, dbus path: /Alarms/LowVoltage, type enum


    0 - No alarm
    2 - Alarm


Output 1 - current (A), dbus path: /Dc/0/Current, type float
Output 1 - temperature (°C), dbus path: /Dc/0/Temperature, type float
Output 1 - voltage (V), dbus path: /Dc/0/Voltage, type float
Output 2 - current (A), dbus path: /Dc/1/Current, type float
Battery 1 temperature (°C), dbus path: /Dc/1/Temperature, type float
Output 2 - voltage (V), dbus path: /Dc/1/Voltage, type float
Output 3 - current (A), dbus path: /Dc/2/Current, type float
Battery 2 temperature (°C), dbus path: /Dc/2/Temperature, type float
Output 3 - voltage (V), dbus path: /Dc/2/Voltage, type float
Error, dbus path: /ErrorCode, type enum


    0 - No error
    1 - Err 1: Battery temperature too high
    2 - Err 2: Battery voltage too high
    3 - Err 3: Battery temperature sensor miswired (+)
    4 - Err 3: Battery temperature sensor miswired (-)
    5 - Err 5: Battery temperature sensor disconnected
    6 - Err 6: Battery voltage sense miswired (+)
    7 - Err 7: Battery voltage sense miswired (-)
    8 - Err 8: Battery voltage sense disconnected
    9 - Err 9: Battery voltage wire losses too high
    17 - Err 17: Charger temperature too high
    18 - Err 18: Charger over-current
    19 - Err 19: Charger current polarity reversed
    20 - Err 20: Bulk time limit reached
    22 - Err 22: Charger temperature sensor miswired
    23 - Err 23: Charger temperature sensor disconnected
    34 - Err 34: Input current too high
    67 - Err 67: No BMS

Charger on/off, dbus path: /Mode, type enum


    1 - On
    4 - Off

Relay on the charger, dbus path: /Relay/0/State, type enum


    0 - Open
    1 - Closed

Charge state, dbus path: /State, type enum


    0 - Off
    2 - Fault
    3 - Bulk
    4 - Absorption
    5 - Float
    6 - Storage
    7 - Equalize
    11 - Power supply mode
    246 - Repeated absorption
    247 - Equalize
    248 - Battery safe

