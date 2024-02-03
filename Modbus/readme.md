#Modbus documentation

##ArduinoModbus
Use Modbus equipment with your Arduino.
Using TCP or RS485 shields, like the MKR 485 Shield. This library depends on the ArduinoRS485 library. 

###Usage

This library implements the Modbus protocol over two different types of transport: serial communication over RS485 with RTU (Remote Terminal Unit) or Ethernet and WiFi communication with TCP protocol. There are a few differences in the APIs depending on the transport, but the majority of the functions are the same for both. Modbus is also a client server protocol where Client = master and Server = slave in Modbus terminilogy; we suggest to read some papers about this protocol if you don’t have any former experience because it is based heavily on some formal conventions.

We have organized this reference so that you find the common functions of both transports together and only the transport related functions are given individually. As a rule of thumb, RTU communication is multipoint and therefore the ID of the unit involved in the communication needs to be specified. TCP is point to point using the IP address and therefore there is no need for an ID in the parameters.

The library is available in our Library Manager; it is compatible with our MKR RS485 Shield and with our network enabled products like the Ethernet shield, the MKR family of boards and the Arduino UNO WiFi Rev 2 just to name a few.

To use this library:
```
#include <ArduinoModbus.h>
```

Modbus Client

    client.coilRead()
    client.discreteInputRead()
    client.holdingRegisterRead()
    client.inputRegisterRead()
    client.coilWrite()
    client.holdingRegisterWrite()
    client.registerMaskWrite()
    client.beginTransmission()
    client.write()
    client.endTransmission()
    client.requestFrom()
    client.available()
    client.read()
    client.lastError()
    client.end()

ModbusRTUClient Class

    modbusRTUClient.begin()

ModbusServer Class

    modbusServer.configureCoils()
    modbusServer.configureDiscreteInputs()
    modbusServer.configureHoldingRegisters()
    modbusServer.configureInputRegisters()
    modbusServer.coilRead()
    modbusServer.discreteInputRead()
    modbusServer.holdingRegisterRead()
    modbusServer.inputRegisterRead()
    modbusServer.coilWrite()
    modbusServer.holdingRegisterWrite()
    modbusServer.registerMaskWrite()
    modbusServer.discreteInputWrite()
    modbusServer.writeDiscreteInputs()
    modbusServer.inputRegisterWrite()
    modbusServer.writeInputRegisters()
    modbusServer.poll()
    modbusServer.end()

ModbusRTUServer Class

    modbusRTUServer.begin()

