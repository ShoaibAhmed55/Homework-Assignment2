#ifndef SenseRequestMsg_H
#define SenseRequestMsg_H

typedef nx_struct SenseRequestMsg
{
    nx_uint16_t RequesterMoteID;	// Holds the queried mote id.
    nx_uint16_t dutyCycle;		// User Defined Duty Cycle To Manage Radio On & OFF States. ("0" Means Use Previous Value).
    nx_uint16_t samplingFrequency;	// Sampling Frequency Update For Sensing Data From Sensors. ("0" Means Use Previous Value).
    nx_uint16_t sensorTypeToSense;	// The type of data that is being requested 1 for Temperature 2 for Light and 3 for Humidity readings.
}SenseRequestMsg_t;

enum {
    AM_SENSEREQUESTMSG = 7	// AM Type "7" Representing Data For Querying Telosb Mote. Sent From Basestation.    
};

#endif