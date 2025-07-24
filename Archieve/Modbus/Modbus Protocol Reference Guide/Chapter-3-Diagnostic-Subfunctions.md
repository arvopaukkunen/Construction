# Modbus Function 08 – Diagnostics
## Description
Modbus function 08 provides a series of tests for checking the communication
system between the master and slave, or for checking various internal error
conditions within the slave. Broadcast is not supported.
The function uses a two–byte subfunction code field in the query to define the
type of test to be performed. The slave echoes both the function code and
subfunction code in a normal response.
Most of the diagnostic queries use a two–byte data field to send diagnostic data or
control information to the slave. Some of the diagnostics cause data to be returned
from the slave in the data field of a normal response.

## Diagnostic Effects on the Slave
In general, issuing a diagnostic function to a slave device does not affect the
running of the user program in the slave. User logic, like discretes and registers,
is not accessed by the diagnostics. Certain functions can optionally reset error
counters in the slave.
A slave device can, however, be forced into ‘Listen Only Mode’ in which it will
monitor the messages on the communications system but not respond to them.
This can affect the outcome of your application program it it depends upon any
further exchange of data with the slave device. Generally, the mode is forced to
remove a malfunctioning slave device from the communications system.

## How This Information is Organized in Your Guide
An example diagnostics query and response are shown on the opposite page.
These show the location of the function code, subfunction code, and data field
within the messages.
A list of subfunction codes supported by the controllers is shown on the pages
after the example response. Each subfunction code is then listed with an example
of the data field contents that would apply for that diagnostic.


# Diagnostic Subfunctions
