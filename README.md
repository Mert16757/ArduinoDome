This driver is written because of a question someone had to send an
open and a close command to a ROR.
The driver talks to an Arduino board that should have the commands
implemented to give the responses the driver expects and activate
the motor or mecanism to open/close the ROR.
The piece of code that the driver talks to in the Arduino is
included as well.

IF the installer can not be downloaded, you can also just download
the driver and register it by hand ( from command window type
ASCOM.NANO.exe /regserver ).

Security means should be taken such that there is no danger for
the equipment when the roof opens/closes.
That is up to you.

Drivr has been tested on my table with an Arduino Uno board and with
an Arduino NANO board.
Driver passes Conformance Tests with no errors or isues.
