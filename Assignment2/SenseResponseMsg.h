#ifndef SenseResponseMsg_H
#define SenseResponseMsg_H

typedef nx_struct SenseResponseMsg
{
    nx_uint16_t datatype;		// The type of data that is being sensed 1 for Temperature 2 for Light and 3 for Humidity readings.
    nx_uint16_t data;			// The sensed data.
    nx_uint16_t sourceMoteID;		// Holds the queried mote id.
    nx_uint16_t requesterMoteID;	// Holds the mote id of Base Station That Sent the request.
}SenseResponseMsg_t;

enum {
    AM_TEMPERATURE = 1,		// Requested Data Type Temperature.
    AM_LIGHT = 2,		// Requested Data Type Light.
    AM_HUMIDITY = 3,		// Requested Data Type Humidity.
    AM_SENSERESPONSEMSG = 6,	// AM Type "6" Representing Data For Active Message Transmission. Sent To Basestation.
};

#endif