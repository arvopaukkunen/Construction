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

### AC Load
This node allows for AC load monitoring. Measuring can be done by using an energy meter and assigning it the 'ac load' role.

L1 Current (A), dbus path: /Ac/L1/Current, type float
L1 Energy (kWh), dbus path: /Ac/L1/Energy/Forward, type float
L1 Power (W), dbus path: /Ac/L1/Power, type float
L1 Voltage (V AC), dbus path: /Ac/L1/Voltage, type float
L2 Current (A), dbus path: /Ac/L2/Current, type float
L2 Energy (kWh), dbus path: /Ac/L2/Energy/Forward, type float
L2 Power (W), dbus path: /Ac/L2/Power, type float
L2 Voltage (V AC), dbus path: /Ac/L2/Voltage, type float
L3 Current (A), dbus path: /Ac/L3/Current, type float
L3 Energy (kWh), dbus path: /Ac/L3/Energy/Forward, type float
L3 Power (W), dbus path: /Ac/L3/Power, type float
L3 Voltage (V AC), dbus path: /Ac/L3/Voltage, type float
Serial number, dbus path: /Serial, type string

### Alternator
This node allows for monitoring the state of BMVs configured in Monitor Mode and DC meter type is Alternator or an alternator controller which is interfaced to the Venus OS.

High auxiliary voltage alarm, dbus path: /Alarms/HighStarterVoltage, type enum


    0 - Ok
    1 - Warning
    2 - Alarm

High temperature alarm, dbus path: /Alarms/HighTemperature, type enum


    0 - Ok
    1 - Warning
    2 - Alarm

High voltage alarm, dbus path: /Alarms/HighVoltage, type enum


    0 - Ok
    1 - Warning
    2 - Alarm

Low auxiliary voltage alarm, dbus path: /Alarms/LowStarterVoltage, type enum


    0 - Ok
    1 - Warning
    2 - Alarm

Low temperature alarm, dbus path: /Alarms/LowTemperature, type enum


    0 - Ok
    1 - Warning
    2 - Alarm

Low voltage alarm, dbus path: /Alarms/LowVoltage, type enum


    0 - No alarm
    2 - Alarm

Battery current (A), dbus path: /Dc/0/Current, type float
Battery temperature (°C), dbus path: /Dc/0/Temperature, type float
Battery voltage (V), dbus path: /Dc/0/Voltage, type float
Auxiliary voltage (V DC), dbus path: /Dc/1/Voltage, type float
Input voltage (before DC/DC converter) (V DC), dbus path: /Dc/In/V, type float
Input power (W DC), dbus path: /Dc/In/P, type float
Engine speed (RPM), dbus path: /Engine/Speed, type float
Alternator error code, dbus path: /ErrorCode, type enum


    12 - High battery temperature
    13 - High battery voltage
    14 - Low battery voltage
    15 - VBat exceeds $CPB
    21 - High alternator temperature
    22 - Alternator overspeed
    24 - Internal error
    41 - High field FET temperature
    42 - Sensor missing
    43 - Low VAlt
    44 - High Voltage offset
    45 - VAlt exceeds $CPB
    53 - Battery instance out of range
    54 - Too many BMSes
    55 - AEBus fault
    56 - Too many Victron devices
    91 - BMS lost
    92 - Forced idle
    201 - DCDC converter fail
    51-52 - Battery disconnect request
    58-61 - Battery requested disconnection
    201-207 - DCDC error

Alternator Field Drive %, dbus path: /FieldDrive, type float
Cumulative amp-hours charged (Ah), dbus path: /History/Cumulative/User/ChargedAh, type float
Total energy produced (kWh), dbus path: /History/EnergyOut, type float
Mode, dbus path: /Mode, type enum


    1 - On
    4 - Off

Alternator speed (RPM), dbus path: /Speed, type float
Alternator state, dbus path: /State, type enum


    0 - Off
    2 - Fault
    3 - Bulk
    4 - Absorption
    5 - Float
    6 - Storage
    7 - Equalize
    11 - Psu
    252 - External control

