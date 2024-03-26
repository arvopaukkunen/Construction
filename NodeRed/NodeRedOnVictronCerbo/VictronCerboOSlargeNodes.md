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

### Battery Monitor
This node allows for monitoring the state of the battery.

Alarm, dbus path: /Alarms/Alarm, type enum


    0 - No alarm
    2 - Alarm

Cell Imbalance alarm, dbus path: /Alarms/CellImbalance, type enum


    0 - No alarm
    1 - Warning
    2 - Alarm

Fuse blown alarm, dbus path: /Alarms/FuseBlown, type enum


    0 - No alarm
    2 - Alarm

High charge current alarm, dbus path: /Alarms/HighChargeCurrent, type enum


    0 - No alarm
    1 - Warning
    2 - Alarm

High charge temperature alarm, dbus path: /Alarms/HighChargeTemperature, type enum


    0 - No alarm
    1 - Warning
    2 - Alarm

High discharge current alarm, dbus path: /Alarms/HighDischargeCurrent, type enum


    0 - No alarm
    1 - Warning
    2 - Alarm

High fused-voltage alarm, dbus path: /Alarms/HighFusedVoltage, type enum


    0 - No alarm
    2 - Alarm

High internal-temperature alarm, dbus path: /Alarms/HighInternalTemperature, type enum


    0 - No alarm
    2 - Alarm

High starter-voltage alarm, dbus path: /Alarms/HighStarterVoltage, type enum


    0 - No alarm
    2 - Alarm

High battery temperature alarm, dbus path: /Alarms/HighTemperature, type enum


    0 - No alarm
    2 - Alarm

High voltage alarm, dbus path: /Alarms/HighVoltage, type enum


    0 - No alarm
    2 - Alarm

Internal failure, dbus path: /Alarms/InternalFailure, type enum


    0 - No alarm
    1 - Warning
    2 - Alarm

Low cell voltage alarm, dbus path: /Alarms/LowCellVoltage, type enum


    0 - No alarm
    1 - Almost discharged
    2 - Alarm

Low charge temperature alarm, dbus path: /Alarms/LowChargeTemperature, type enum


    0 - No alarm
    1 - Warning
    2 - Alarm

Low fused-voltage alarm, dbus path: /Alarms/LowFusedVoltage, type enum


    0 - No alarm
    2 - Alarm

Low state-of-charge alarm, dbus path: /Alarms/LowSoc, type enum


    0 - No alarm
    2 - Alarm

Low starter-voltage alarm, dbus path: /Alarms/LowStarterVoltage, type enum


    0 - No alarm
    2 - Alarm

Low battery temperature alarm, dbus path: /Alarms/LowTemperature, type enum


    0 - No alarm
    2 - Alarm

Low voltage alarm, dbus path: /Alarms/LowVoltage, type enum


    0 - No alarm
    2 - Alarm

Mid-voltage alarm, dbus path: /Alarms/MidVoltage, type enum


    0 - No alarm
    2 - Alarm

Balancing, dbus path: /Balancing, type enum


    0 - Inactive
    1 - Active

Capacity (Ah), dbus path: /Capacity, type float
Consumed Amphours (Ah), dbus path: /ConsumedAmphours, type float
Battery current (A), dbus path: /Dc/0/Current, type float
Mid-point voltage of the battery bank (V), dbus path: /Dc/0/MidVoltage, type float
Mid-point deviation of the battery bank (%), dbus path: /Dc/0/MidVoltageDeviation, type float
Battery power (W), dbus path: /Dc/0/Power, type float
Battery temperature (°C), dbus path: /Dc/0/Temperature, type float
Battery voltage (V), dbus path: /Dc/0/Voltage, type float
Starter battery voltage (V), dbus path: /Dc/1/Voltage, type float
Diagnostics; 1st last error, dbus path: /Diagnostics/LastErrors/1/Error, type enum



    0 - No error
    1 - Battery initialization error
    2 - No batteries connected
    3 - Unknown battery connected
    4 - Different battery type
    5 - Number of batteries incorrect
    6 - Lynx Shunt not found
    7 - Battery measure error
    8 - Internal calculation error
    9 - Batteries in series not ok
    10 - Number of batteries incorrect
    11 - Hardware error
    12 - Watchdog error
    13 - Over voltage
    14 - Under voltage
    15 - Over temperature
    16 - Under temperature
    17 - Hardware fault
    18 - Standby shutdown
    19 - Pre-charge charge error
    20 - Safety contactor check error
    21 - Pre-charge discharge error
    22 - ADC error
    23 - Slave error
    24 - Slave warning
    25 - Pre-charge error
    26 - Safety contactor error
    27 - Over current
    28 - Slave update failed
    29 - Slave update unavailable
    30 - Calibration data lost
    31 - Settings invalid
    32 - BMS cable
    33 - Reference failure
    34 - Wrong system voltage
    35 - Pre-charge timeout

Diagnostics; 1st last error timestamp, dbus path: /Diagnostics/LastErrors/1/Time, type float
Diagnostics; 2nd last error, dbus path: /Diagnostics/LastErrors/2/Error, type float
Diagnostics; 2nd last error timestamp, dbus path: /Diagnostics/LastErrors/2/Time, type float
Diagnostics; 3rd last error, dbus path: /Diagnostics/LastErrors/3/Error, type float
Diagnostics; 3rd last error timestamp, dbus path: /Diagnostics/LastErrors/3/Time, type float
Diagnostics; 4th last error, dbus path: /Diagnostics/LastErrors/4/Error, type float
Diagnostics; 4th last error timestamp, dbus path: /Diagnostics/LastErrors/4/Time, type float
Diagnostics; shutdowns due to error (count), dbus path: /Diagnostics/ShutDownsDueError, type float
Error, dbus path: /ErrorCode, type enum



    0 - No error
    1 - Battery initialization error
    2 - No batteries connected
    3 - Unknown battery connected
    4 - Different battery type
    5 - Number of batteries incorrect
    6 - Lynx Shunt not found
    7 - Battery measure error
    8 - Internal calculation error
    9 - Batteries in series not ok
    10 - Number of batteries incorrect
    11 - Hardware error
    12 - Watchdog error
    13 - Over voltage
    14 - Under voltage
    15 - Over temperature
    16 - Under temperature
    17 - Hardware fault
    18 - Standby shutdown
    19 - Pre-charge charge error
    20 - Safety contactor check error
    21 - Pre-charge discharge error
    22 - ADC error
    23 - Slave error
    24 - Slave warning
    25 - Pre-charge error
    26 - Safety contactor error
    27 - Over current
    28 - Slave update failed
    29 - Slave update unavailable
    30 - Calibration data lost
    31 - Settings invalid
    32 - BMS cable
    33 - Reference failure
    34 - Wrong system voltage
    35 - Pre-charge timeout

Automatic syncs (count), dbus path: /History/AutomaticSyncs, type float
Average discharge (Ah), dbus path: /History/AverageDischarge, type float
Charge cycles (count), dbus path: /History/ChargeCycles, type float
Charged Energy (kWh), dbus path: /History/ChargedEnergy, type float
Deepest discharge (Ah), dbus path: /History/DeepestDischarge, type float
Discharged Energy (kWh), dbus path: /History/DischargedEnergy, type float
Full discharges (count), dbus path: /History/FullDischarges, type float
High fused-voltage alarms (count), dbus path: /History/HighFusedVoltageAlarms, type float
High starter voltage alarms (count), dbus path: /History/HighStarterVoltageAlarms, type float
High voltage alarms (count), dbus path: /History/HighVoltageAlarms, type float
Last discharge (Ah), dbus path: /History/LastDischarge, type float
Low fused-voltage alarms (count), dbus path: /History/LowFusedVoltageAlarms, type float
Low starter voltage alarms (count), dbus path: /History/LowStarterVoltageAlarms, type float
Low voltage alarms (count), dbus path: /History/LowVoltageAlarms, type float
History; Max cell-voltage (V DC), dbus path: /History/MaximumCellVoltage, type float
Maximum fused voltage (V DC), dbus path: /History/MaximumFusedVoltage, type float
Maximum starter voltage (V DC), dbus path: /History/MaximumStarterVoltage, type float
Maximum voltage (V DC), dbus path: /History/MaximumVoltage, type float
History; Min cell-voltage (V DC), dbus path: /History/MinimumCellVoltage, type float
Minimum fused voltage (V DC), dbus path: /History/MinimumFusedVoltage, type float
Minimum starter voltage (V DC), dbus path: /History/MinimumStarterVoltage, type float
Minimum voltage (V DC), dbus path: /History/MinimumVoltage, type float
Time since last full charge (seconds), dbus path: /History/TimeSinceLastFullCharge, type float
Total Ah drawn (Ah), dbus path: /History/TotalAhDrawn, type float
Min discharge voltage (V DC), dbus path: /Info/BatteryLowVoltage, type float
CCL - Charge Current Limit (A), dbus path: /Info/MaxChargeCurrent, type float
CVL - Charge Voltage Limit (V), dbus path: /Info/MaxChargeVoltage, type float
DCL - Discharge Current Limit (A), dbus path: /Info/MaxDischargeCurrent, type float
ATC (Allow to Charge), dbus path: /Io/AllowToCharge, type enum


    0 - No
    1 - Yes

ATD (Allow to Discharge), dbus path: /Io/AllowToDischarge, type enum


    0 - No
    1 - Yes

IO; external relay, dbus path: /Io/ExternalRelay, type enum


    0 - Inactive
    1 - Active

Mode, dbus path: /Mode, type enum


    3 - On
    252 - Standby

Relay status, dbus path: /Relay/0/State, type enum


    0 - Open
    1 - Closed

State of charge (%), dbus path: /Soc, type float
State of health (%), dbus path: /Soh, type float
State, dbus path: /State, type enum


    0 - Initializing (Wait start)
    1 - Initializing (before boot)
    2 - Initializing (Before boot delay)
    3 - Initializing (Wait boot)
    4 - Initializing
    5 - Initializing (Measure battery voltage)
    6 - Initializing (Calculate battery voltage)
    7 - Initializing (Wait bus voltage)
    8 - Initializing (Wait for lynx shunt)
    9 - Running
    10 - Error
    11 - Unused
    12 - Shutdown
    13 - Slave updating
    14 - Standby
    15 - Going to run
    16 - Pre-charging
    17 - Contactor check

System; batteries parallel (count), dbus path: /System/BatteriesParallel, type float
System; batteries series (count), dbus path: /System/BatteriesSeries, type float
System; ID of module with highest cell voltage, dbus path: /System/MaxVoltageCellId, type string
Maximum cell temperature (°C), dbus path: /System/MaxCellTemperature, type float
System; maximum cell voltage (V DC), dbus path: /System/MaxCellVoltage, type float
System; ID of module with highest cell temperature, dbus path: /System/MaxTemperatureCellId, type string
System; ID of module with lowest cell voltage, dbus path: /System/MinVoltageCellId, type string
Minimum cell temperature (°C), dbus path: /System/MinCellTemperature, type float
System; minimum cell voltage (V DC), dbus path: /System/MinCellVoltage, type float
System; ID of module with lowest cell temperature, dbus path: /System/MinTemperatureCellId, type string
System; number of batteries (count), dbus path: /System/NrOfBatteries, type float
System; number of cells per battery (count), dbus path: /System/NrOfCellsPerBattery, type float
Number of modules blocking charge, dbus path: /System/NrOfModulesBlockingCharge, type integer
Number of modules blocking discharge, dbus path: /System/NrOfModulesBlockingDischarge, type integer
Number of offline modules, dbus path: /System/NrOfModulesOffline, type integer
Number of online modules, dbus path: /System/NrOfModulesOnline, type integer
System-switch, dbus path: /SystemSwitch, type enum


    0 - Disabled
    1 - Enabled

*For monitoring the state of the built-in contactor.*

Time to go (s), dbus path: /TimeToGo, type float

### DC-DC
This node allows for monitoring the state of an Orion XS.

/Dc/0/Current (A DC), dbus path: /Dc/0/Current, type float
/Dc/0/Temperature (Degrees celsius), dbus path: /Dc/0/Temperature, type float
/Dc/0/Voltage (V DC), dbus path: /Dc/0/Voltage, type float
/Dc/In/V (V DC), dbus path: /Dc/In/V, type float
/Dc/In/P (W), dbus path: /Dc/In/P, type float
/ErrorCode, dbus path: /ErrorCode, type enum


    0 - No error
    1 - Battery temperature too high
    2 - Battery voltage too high
    3 - Battery temperature sensor miswired (+)
    4 - Battery temperature sensor miswired (-)
    5 - Battery temperature sensor disconnected
    6 - Battery voltage sense miswired (+)
    7 - Battery voltage sense miswired (-)
    8 - Battery voltage sense disconnected
    9 - Battery voltage wire losses too high
    17 - Charger temperature too high
    18 - Charger over-current
    19 - Charger current polarity reversed
    20 - Bulk time limit reached
    22 - Charger temperature sensor miswired
    23 - Charger temperature sensor disconnected
    34 - Input current too high

/FirmwareVersion, dbus path: /FirmwareVersion, type float
/History/Cumulative/User/ChargedAh (Ah), dbus path: /History/Cumulative/User/ChargedAh, type float
/ProductId, dbus path: /ProductId, type float
/State, dbus path: /State, type enum


    0 - Off
    2 - Fault
    3 - Bulk
    4 - Absorption
    5 - Float
    6 - Storage
    7 - Equalize

### DC Load
This node allows for monitoring the state of BMVs configured in Monitor Mode and DC meter type is a load

High starter-voltage alarm, dbus path: /Alarms/HighStarterVoltage, type enum


    0 - No alarm
    2 - Alarm

High battery temperature alarm, dbus path: /Alarms/HighTemperature, type enum


    0 - No alarm
    2 - Alarm

High voltage alarm, dbus path: /Alarms/HighVoltage, type enum


    0 - No alarm
    2 - Alarm

Low starter-voltage alarm, dbus path: /Alarms/LowStarterVoltage, type enum


    0 - No alarm
    2 - Alarm

Low battery temperature alarm, dbus path: /Alarms/LowTemperature, type enum


    0 - No alarm
    2 - Alarm

Low voltage alarm, dbus path: /Alarms/LowVoltage, type enum


    0 - No alarm
    2 - Alarm

Battery current (A), dbus path: /Dc/0/Current, type float
Battery temperature (°C), dbus path: /Dc/0/Temperature, type float
Battery voltage (V), dbus path: /Dc/0/Voltage, type float
Starter battery voltage (V), dbus path: /Dc/1/Voltage, type float
Total energy consumed (kWh), dbus path: /History/EnergyIn, type float
Relay status, dbus path: /Relay/0/State, type enum


    0 - Open
    1 - Closed

### DC Source
This node allows for monitoring the state of Battery Monitor Victron devices (BMV's) configured in Monitor Mode and DC meter type is a source.

High starter-voltage alarm, dbus path: /Alarms/HighStarterVoltage, type enum


    0 - No alarm
    2 - Alarm

High battery temperature alarm, dbus path: /Alarms/HighTemperature, type enum


    0 - No alarm
    2 - Alarm

High voltage alarm, dbus path: /Alarms/HighVoltage, type enum


    0 - No alarm
    2 - Alarm

Low starter-voltage alarm, dbus path: /Alarms/LowStarterVoltage, type enum


    0 - No alarm
    2 - Alarm

Low battery temperature alarm, dbus path: /Alarms/LowTemperature, type enum


    0 - No alarm
    2 - Alarm

Low voltage alarm, dbus path: /Alarms/LowVoltage, type enum


    0 - No alarm
    2 - Alarm

Battery current (A), dbus path: /Dc/0/Current, type float
Battery temperature (°C), dbus path: /Dc/0/Temperature, type float
Battery voltage (V), dbus path: /Dc/0/Voltage, type float
Starter battery voltage (V), dbus path: /Dc/1/Voltage, type float
Total energy produced (kWh), dbus path: /History/EnergyOut, type float
Relay status, dbus path: /Relay/0/State, type enum


    0 - Open
    1 - Closed

### DC System
DC system input node is a DC measurement for loads in your system.

High auxiliary voltage alarm, dbus path: /Alarms/HighStarterVoltage, type enum


    0 - Ok
    1 - Warning
    2 - Alarm

High temperature alarm, dbus path: /Alarms/HighTemperature, type enum


    0 - Ok
    1 - Warning
    2 - Alarm

High voltage alarm, dbus path: /Alarms/HighVoltage, type enum


    0 - No alarm
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
    1 - Warning
    2 - Alarm

Battery current (A), dbus path: /Dc/0/Current, type float
Battery temperature (°C), dbus path: /Dc/0/Temperature, type float
Battery voltage (V DC), dbus path: /Dc/0/Voltage, type float
Auxiliary voltage (V DC), dbus path: /Dc/1/Voltage, type float
Total energy consumed (kWh), dbus path: /History/EnergyIn, type float
Total energy produced (kWh), dbus path: /History/EnergyOut, type float

### Digital Input
With this node it is possible to read the digital inputs from the Venus device. The node only shows the enabled digital inputs, so first make sure to enable the input from the Venus OS GUI (Settings -> I/O -> digital inputs) for the desired readout.Depending on the selected type of input, different measurements become available.Also see the section on digital inputs in the Cerbo GX manual.

Pulse meter aggregate, dbus path: /Aggregate, type float
Pulse meter count, dbus path: /Count, type float
Digital input alarm, dbus path: /Alarm, type enum


    0 - No alarm
    1 - Warning
    2 - Alarm

Digital input count, dbus path: /Count, type float
Digital input state, dbus path: /State, type enum


    0 - low
    1 - high
    2 - off
    3 - on
    4 - no
    5 - yes
    6 - open
    7 - closed
    8 - ok
    9 - alarm
    10 - running
    11 - stopped

Digital input type, dbus path: /Type, type enum


    0 - Disabled
    1 - Pulse meter
    2 - Door sensor
    3 - Bilge pump
    4 - Bilge alarm
    5 - Burglar alarm
    6 - Smoke alarm
    7 - Fire alarm
    8 - CO2 alarm
    9 - Generator
    10 - Generic input

### ESS
This node gives information on the energy storage system (ESS).

Maximum battery cell temperature, dbus path: /System/MaxCellTemperature, type integer
Maximum battery cell voltage, dbus path: /System/MaxCellVoltage, type integer
Minimum battery cell temperature, dbus path: /System/MinCellTemperature, type integer
Minimum battery cell voltage, dbus path: /System/MinCellVoltage, type integer
Number of modules blocking charge, dbus path: /System/NrOfModulesBlockingCharge, type integer
Number of modules blocking discharge, dbus path: /System/NrOfModulesBlockingDischarge, type integer
Number of offline modules, dbus path: /System/NrOfModulesOffline, type integer
Number of online modules, dbus path: /System/NrOfModulesOnline, type integer
Disable charge, dbus path: /Hub4/DisableCharge, type enum


    0 - No
    1 - Yes

Disable feed-in, dbus path: /Hub4/DisableFeedIn, type enum


    0 - No
    1 - Yes

Feed in overvoltage, dbus path: /Hub4/DoNotFeedInOvervoltage, type enum


    0 - Yes
    1 - No

AC Power L1 setpoint (W), dbus path: /Hub4/L1/AcPowerSetpoint, type integer
Maximum overvoltage feed-in power L1 (W), dbus path: /Hub4/L1/MaxFeedInPower, type integer
AC Power L2 setpoint (W), dbus path: /Hub4/L2/AcPowerSetpoint, type integer
Maximum overvoltage feed-in power L2 (W), dbus path: /Hub4/L2/MaxFeedInPower, type integer
Maximum overvoltage feed-in power L3 (W), dbus path: /Hub4/L3/MaxFeedInPower, type integer
AC Power L3 setpoint (W), dbus path: /Hub4/L3/AcPowerSetpoint, type integer
Disable PV inverter, dbus path: /PvInverter/Disable, type enum


    0 - No
    1 - Yes

VE.Bus system restart, dbus path: /SystemReset, type enum


    0 - No
    1 - Yes

Grid set-point (W), dbus path: /Settings/CGwacs/AcPowerSetPoint, type integer
Minimum Discharge SOC (%), dbus path: /Settings/CGwacs/BatteryLife/MinimumSocLimit, type integer
Schedule 1: Self-consumption above limit, dbus path: /Settings/CGwacs/BatteryLife/Schedule/Charge/0/AllowDischarge, type enum


    0 - Yes
    1 - No

Schedule 1: Day, dbus path: /Settings/CGwacs/BatteryLife/Schedule/Charge/0/Day, type enum


    0 - Sunday
    1 - Monday
    2 - Tuesday
    3 - Wednesday
    4 - Thursday
    5 - Friday
    6 - Saturday
    7 - Every day
    8 - Weekdays
    9 - Weekends

*A negative value means that the schedule has been de-activated.*

Schedule 1: Duration (seconds), dbus path: /Settings/CGwacs/BatteryLife/Schedule/Charge/0/Duration, type integer
Schedule 1: State of charge (%), dbus path: /Settings/CGwacs/BatteryLife/Schedule/Charge/0/Soc, type integer
Schedule 1: Start (seconds after midnight), dbus path: /Settings/CGwacs/BatteryLife/Schedule/Charge/0/Start, type integer
Schedule 2: Self-consumption above limit, dbus path: /Settings/CGwacs/BatteryLife/Schedule/Charge/1/AllowDischarge, type enum


    0 - Yes
    1 - No

Schedule 2: Day, dbus path: /Settings/CGwacs/BatteryLife/Schedule/Charge/1/Day, type enum


    0 - Sunday
    1 - Monday
    2 - Tuesday
    3 - Wednesday
    4 - Thursday
    5 - Friday
    6 - Saturday
    7 - Every day
    8 - Weekdays
    9 - Weekends

*A negative value means that the schedule has been de-activated.*

Schedule 2: Duration (seconds), dbus path: /Settings/CGwacs/BatteryLife/Schedule/Charge/1/Duration, type integer
Schedule 2: State of charge (%), dbus path: /Settings/CGwacs/BatteryLife/Schedule/Charge/1/Soc, type integer
Schedule 2: Start (seconds after midnight), dbus path: /Settings/CGwacs/BatteryLife/Schedule/Charge/1/Start, type integer
Schedule 3: Self-consumption above limit, dbus path: /Settings/CGwacs/BatteryLife/Schedule/Charge/2/AllowDischarge, type enum


    0 - Yes
    1 - No

Schedule 3: Day, dbus path: /Settings/CGwacs/BatteryLife/Schedule/Charge/2/Day, type enum


    0 - Sunday
    1 - Monday
    2 - Tuesday
    3 - Wednesday
    4 - Thursday
    5 - Friday
    6 - Saturday
    7 - Every day
    8 - Weekdays
    9 - Weekends
*A negative value means that the schedule has been de-activated.*

Schedule 3: Duration (seconds), dbus path: /Settings/CGwacs/BatteryLife/Schedule/Charge/2/Duration, type integer
Schedule 3: State of charge (%), dbus path: /Settings/CGwacs/BatteryLife/Schedule/Charge/2/Soc, type integer
Schedule 3: Start (seconds after midnight), dbus path: /Settings/CGwacs/BatteryLife/Schedule/Charge/2/Start, type integer
Schedule 4: Self-consumption above limit, dbus path: /Settings/CGwacs/BatteryLife/Schedule/Charge/3/AllowDischarge, type enum


    0 - Yes
    1 - No

Schedule 4: Day, dbus path: /Settings/CGwacs/BatteryLife/Schedule/Charge/3/Day, type enum


    0 - Sunday
    1 - Monday
    2 - Tuesday
    3 - Wednesday
    4 - Thursday
    5 - Friday
    6 - Saturday
    7 - Every day
    8 - Weekdays
    9 - Weekends
*A negative value means that the schedule has been de-activated.*

Schedule 4: Duration (seconds), dbus path: /Settings/CGwacs/BatteryLife/Schedule/Charge/3/Duration, type integer
Schedule 4: State of charge (%), dbus path: /Settings/CGwacs/BatteryLife/Schedule/Charge/3/Soc, type integer
Schedule 4: Start (seconds after midnight), dbus path: /Settings/CGwacs/BatteryLife/Schedule/Charge/3/Start, type integer
Schedule 5: Self-consumption above limit, dbus path: /Settings/CGwacs/BatteryLife/Schedule/Charge/4/AllowDischarge, type enum


    0 - Yes
    1 - No

Schedule 5: Day, dbus path: /Settings/CGwacs/BatteryLife/Schedule/Charge/4/Day, type enum


    0 - Sunday
    1 - Monday
    2 - Tuesday
    3 - Wednesday
    4 - Thursday
    5 - Friday
    6 - Saturday
    7 - Every day
    8 - Weekdays
    9 - Weekends

*Writing a negative value to the path will de-activate the schedule.* Schedule 5: Duration (seconds), dbus path: /Settings/CGwacs/BatteryLife/Schedule/Charge/4/Duration, type integer
Schedule 5: State of charge (%), dbus path: /Settings/CGwacs/BatteryLife/Schedule/Charge/4/Soc, type integer
Schedule 5: Start (seconds after midnight), dbus path: /Settings/CGwacs/BatteryLife/Schedule/Charge/4/Start, type integer
ESS state, dbus path: /Settings/CGwacs/BatteryLife/State, type enum


    1 - BatteryLife enabled (GUI controlled)
    2 - Optimized Mode /w BatteryLife: self consumption
    3 - Optimized Mode /w BatteryLife: self consumption, SoC exceeds 85%
    4 - Optimized Mode /w BatteryLife: self consumption, SoC at 100%
    5 - Optimized Mode /w BatteryLife: SoC below dynamic SoC limit
    6 - Optimized Mode /w BatteryLife: SoC has been below SoC limit for more than 24 hours. Charging the battery (5A)
    7 - Optimized Mode /w BatteryLife: Inverter/Charger is in sustain mode
    8 - Optimized Mode /w BatteryLife: recharging, SoC dropped by 5% or more below the minimum SoC
    9 - 'Keep batteries charged' mode is enabled
    10 - Optimized mode w/o BatteryLife: self consumption, SoC at or above minimum SoC
    11 - Optimized mode w/o BatteryLife: self consumption, SoC is below minimum SoC
    12 - Optimized mode w/o BatteryLife: recharging, SoC dropped by 5% or more below minimum SoC

ESS mode, dbus path: /Settings/CGwacs/Hub4Mode, type enum


    1 - Optimized mode or 'keep batteries charged' and phase compensation enabled
    2 - Optimized mode or 'keep batteries charged' and phase compensation disabled
    3 - External control

Max charge power (W), dbus path: /Settings/CGwacs/MaxChargePower, type integer

*Not used with DVCC*.

Max inverter power (W), dbus path: /Settings/CGwacs/MaxDischargePower, type integer
Feed excess DC-coupled PV into grid, dbus path: /Settings/CGwacs/OvervoltageFeedIn, type enum


    0 - Don’t feed excess DC-tied PV into grid
    1 - Feed excess DC-tied PV into the grid

Don’t feed excess AC-coupled PV into grid, dbus path: /Settings/CGwacs/PreventFeedback, type enum


    0 - Feed excess AC-tied PV into grid
    1 - Don’t feed excess AC-tied PV into the grid

DVCC Charge current limit (A), dbus path: /Settings/SystemSetup/MaxChargeCurrent, type float
DVCC Maximum charge voltage (V), dbus path: /Settings/SystemSetup/MaxChargeVoltage, type float
Active SOC limit (%), dbus path: /Control/ActiveSocLimit, type integer

### EV Charger
The EV charger input node is for reading from the EV Charging Station.Also see here for more information.

Energy consumed by charger (kWh), dbus path: /Ac/Energy/Forward, type float
L1 Power (W), dbus path: /Ac/L1/Power, type float
L2 Power (W), dbus path: /Ac/L2/Power, type float
L3 Power (W), dbus path: /Ac/L3/Power, type float
Total power (W), dbus path: /Ac/Power, type float
Charging time (seconds), dbus path: /ChargingTime, type float
Charge current (A), dbus path: /Current, type float
Display, dbus path: /EnableDisplay, type enum


    0 - Locked
    1 - Unlocked


