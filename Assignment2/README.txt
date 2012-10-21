README for Assignment2AppC
Author: Shoaib Ahmed; Diego Buitargo; Micheal Sanchez; Manikandan Vijakumar;

Description:
Application will retrieve sensor data whenever it receives a request. 
Requests will be transmitted by a base station node (a node with TOSBase
program) connected to a PC. The requests will be in the following format SenseRequestMsg.h. The
AM_SENSEREQUESTMSG message will be used by the basestation to send a request to the motes and AM_SENSERESPONSEMSG will be
used by the motes to send the data back to the base station.
Requests will be initiated by a java program (Communicate.java) that takes queries from the user. It prompts the user to
enter the type of data to request and the id of the mote. Types of data that can be requested are 1)
temperature 2) light reading 3) humidity reading. The sensed data is returned as voltage values. 
Also The user is provided the option to update the values of "Duty Cycle" And "Sampling Frequency".

The single make file does all, Just use "make" command with appropriate device parameter to compile the application.
example : "make telosb"

Tools:

Known bugs/limitations:

None.

$Id: README.txt,v 1.0 2012/10/18 18:22:48 Shoaib Exp $
