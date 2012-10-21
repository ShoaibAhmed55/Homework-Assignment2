#include <Timer.h>
#include "SenseResponseMsg.h"
#include "SenseRequestMsg.h"

module Assignment2C
{;
	uses interface Leds;
	uses interface Boot;
	uses interface Packet;
	uses interface AMSend;
	uses interface Receive;
	uses interface AMPacket;
	uses interface Timer<TMilli> as Timer0;
	uses interface Timer<TMilli> as Timer1;
	uses interface SplitControl as AMControl;
	uses interface Read<uint16_t> as ReadLight;
	uses interface Read<uint16_t> as ReadHumidity;
	uses interface Read<uint16_t> as ReadTemperature; 
}
implementation
{
	message_t pkt;
	bool busy = FALSE;
	bool isRadioON = TRUE;
	uint16_t light = 99; // Variable holding the Latest value of Light.
	uint16_t humidity = 99; // Variable holding the Latest value of Humidity.
	uint16_t temperature = 99; // Variable holding the Latest value of Temperature.
	uint16_t toggleRadio = 0;// Variable used to toggle Radio ON or OFF, Even Number (Radio ON) | Odd Number Radio OFF.

	uint16_t DEFAULT_SAMPLING_FREQUENCY = 500; // The interval at which to sense data instread of sensing continuously.
	// The value Of DEFAULT_SAMPLING_FREQUENCY Can Be User Defined However It Should Be Less than 32767, To Avoid Overflow.
	uint16_t DEFAULT_DUTY_CYCLE = (1000 * 30 * 1); // The Default Duty Cycle is 30 Seconds 
	// (Radio stays ON for 30 Seconds and then OFF for 30 Seconds).
	// The value Of DEFAULT_DUTY_CYCLE Can Be User Defined However It Should Be Less than 32767, To Avoid Overflow.

	//*********************************************************************************************************
	//*************************** Functions Below Send Requested Data Through Radio ***************************
	//*********************************************************************************************************
	// Sending Temperature Data
	void SendTemperatureData(nx_uint16_t RequesterMoteID) {
		if (!busy && isRadioON) {
			SenseResponseMsg_t* btrpkt = (SenseResponseMsg_t*)(call Packet.getPayload(&pkt, sizeof (SenseResponseMsg_t)));
			if (btrpkt == NULL) {
				return;
			}
			btrpkt->data = temperature;
			btrpkt->sourceMoteID = TOS_NODE_ID;
			btrpkt->requesterMoteID = RequesterMoteID;
			btrpkt->datatype = 1;// The type of data that is being sensed, 1 for Temperature.			
			if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(SenseResponseMsg_t)) == SUCCESS) {
				busy = TRUE;
			}
			dbg("Assignment2C", "Temperature value [%i] Sent To Mot : %i  @ %s.\n", temperature , RequesterMoteID, sim_time_string());
		}
	}

	// Sending Light Data
	void SendLightData(nx_uint16_t RequesterMoteID) {
		if (!busy && isRadioON) {
			SenseResponseMsg_t* btrpkt = (SenseResponseMsg_t*)(call Packet.getPayload(&pkt, sizeof (SenseResponseMsg_t)));
			if (btrpkt == NULL) {
				return;
			}
			btrpkt->data = light;
			btrpkt->sourceMoteID = TOS_NODE_ID;
			btrpkt->requesterMoteID = RequesterMoteID;
			btrpkt->datatype = 2;// The type of data that is being sensed, 2 for Light.
			if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(SenseResponseMsg_t)) == SUCCESS) {
				busy = TRUE;
			}
			dbg("Assignment2C", "Light value [%i] Sent To Mot : %i  @ %s.\n", light , RequesterMoteID, sim_time_string());
		}
	}

	// Sending Humidity Data
	void SendHumidityData(nx_uint16_t RequesterMoteID) {
		if (!busy && isRadioON) {
			SenseResponseMsg_t* btrpkt = (SenseResponseMsg_t*)(call Packet.getPayload(&pkt, sizeof (SenseResponseMsg_t)));
			if (btrpkt == NULL) {
				return;
			}
			btrpkt->data = humidity;
			btrpkt->sourceMoteID = TOS_NODE_ID;
			btrpkt->requesterMoteID = RequesterMoteID;
			btrpkt->datatype = 3;// The type of data that is being sensed, 3 for Humidity.
			if (call AMSend.send(AM_BROADCAST_ADDR, &pkt, sizeof(SenseResponseMsg_t)) == SUCCESS) {
				busy = TRUE;
			}
			dbg("Assignment2C", "Humidity value [%i] Sent To Mot : %i  @ %s.\n", humidity , RequesterMoteID, sim_time_string());
		}
	}

	// Function to Determine which Type of Data Is Requested
	void ProcessRequest(nx_uint16_t ReqType, nx_uint16_t RequesterMoteID) {
		if (ReqType == AM_LIGHT)
			SendLightData(RequesterMoteID);
		else if (ReqType == AM_HUMIDITY)
			SendHumidityData(RequesterMoteID);
		else if (ReqType == AM_TEMPERATURE)
			SendTemperatureData(RequesterMoteID);
	}
	//*********************************************************************************************************	
	//*********************************************************************************************************

	//*********************************************************************************************************
	//****************************** Functions Below Acquire Data From Sensors ********************************
	//*********************************************************************************************************
	// Acquiring Temperature Data
	void UpdateTemperatureData()
	{
		call ReadTemperature.read();
	}

	// Acquiring Light Data
	void UpdateLightData()
	{
		call ReadLight.read();
	}

	// Acquiring Humidity Data
	void UpdateHumidityData()
	{
		call ReadHumidity.read(); 
	}
	//*********************************************************************************************************	
	//*********************************************************************************************************

	//*********************************************************************************************************
	//******************** Functions Below Initialize Required Events From Used Interfaces ********************
	//*********************************************************************************************************
	event void Boot.booted()
	{
		call AMControl.start();		
	}

	// Radio Stated, Initialize Timer With Default Frequency.
	event void AMControl.startDone(error_t err) {
		if (err == SUCCESS) {
			call Timer0.startPeriodic( DEFAULT_SAMPLING_FREQUENCY );
			call Timer1.startPeriodic( DEFAULT_DUTY_CYCLE );
			call Leds.led1On(); // Turn LED 1 On, While Radio Is ON. (At Startup)
		}
		else {
			call AMControl.start();
		}
		dbg("Assignment2C", "Sampling Timer Started @ %s.\n", sim_time_string());
	}
	
	event void AMControl.stopDone(error_t err) {
	}
	
	// Message Send Confirmation
	event void AMSend.sendDone(message_t* msg, error_t error) {
		if (&pkt == msg) {
			busy = FALSE;
		}
	}
	
	// Read Light Sensor
	event void ReadLight.readDone(error_t result, uint16_t data) {
		if (result == SUCCESS)
		{
			light = data;
		}
	}

	// Read Humidity Sensor
	event void ReadHumidity.readDone(error_t result, uint16_t data) {
		if (result == SUCCESS)
		{
			humidity = data;
		}
	}

	// Read Temperature Sensor
	event void ReadTemperature.readDone(error_t result, uint16_t data) {
		if (result == SUCCESS)
		{
			temperature = data;
		}
	}
	//**********************************************************************************************************	
	//**********************************************************************************************************

	//**********************************************************************************************************
	//************ Timer Used To Sense Data At Specific Interval Instead Of Sensing Continuously ***************
	//**********************************************************************************************************
	event void Timer0.fired()
	{		
		UpdateLightData();
		dbg("Assignment2C", "Light Sensor Update Requested @ %s \n", sim_time_string());

		UpdateHumidityData();
		dbg("Assignment2C", "Humidity Sensor Update Requested %s.\n", sim_time_string());

		UpdateTemperatureData();
		dbg("Assignment2C", "Temperature Sensor Update Requested @ %s.\n", sim_time_string());

		call Leds.led0Toggle();
	}
	//**********************************************************************************************************	
	//**********************************************************************************************************

	//**********************************************************************************************************
	//******* Timer To Implement Duty Cycle For Radio, Radio Stays ON For One Cycle And OFF For Other **********
	//**********************************************************************************************************
	void TrunRadioON()
	{
		call AMControl.start();	
		call Leds.led1On(); // Turn LED 1 On, While Radio Is ON. (Only For Demonstration as LED will consume Battery Itself !)
	}

	void TrunRadioOFF()
	{
		call AMControl.stop();	
		call Leds.led1Off();  // Turn LED 1 OFF, While Radio Is OFF. (Only For Demonstration as LED will consume Battery Itself !)
	}
	
	event void Timer1.fired()
	{
		toggleRadio++;
		if ((toggleRadio % 2) == 0){
			isRadioON = TRUE;
			TrunRadioON();
		}
		else {
			isRadioON = FALSE;
			TrunRadioOFF();
		}		
	}
	//**********************************************************************************************************	
	//**********************************************************************************************************

	//**********************************************************************************************************
	//************************** Updating Sampling Frequency To User Defined Value *****************************
	//**********************************************************************************************************
	void ResetTimerSamplingFrequency(nx_uint16_t UpdatedSamplingFrequency) {
		DEFAULT_SAMPLING_FREQUENCY = UpdatedSamplingFrequency;
		call Timer0.startPeriodic( UpdatedSamplingFrequency );
		call Leds.led2Toggle();
	}
	//**********************************************************************************************************	
	//**********************************************************************************************************

	//**********************************************************************************************************
	//***************************** Updating Duty Cycle To User Defined Value **********************************
	//**********************************************************************************************************
	void ResetDutyCycle(nx_uint16_t UpdatedDutyCycle) {
		DEFAULT_DUTY_CYCLE = UpdatedDutyCycle;
		call Timer1.startPeriodic( UpdatedDutyCycle );
		call Leds.led2Toggle();
	}
	//**********************************************************************************************************	
	//**********************************************************************************************************

	//**********************************************************************************************************
	//************************** Function Receieving Data From Base Station ************************************
	//**********************************************************************************************************
	// Receieve Data From Base Station
	event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len){		
		if (len == sizeof(SenseRequestMsg_t)) {
			SenseRequestMsg_t* btrpkt = (SenseRequestMsg_t*)payload;
			if (btrpkt->samplingFrequency > 0) // Check If Sampling Frequency Update is provided.
			{
				ResetTimerSamplingFrequency(btrpkt->samplingFrequency); // Update Sampling Frequency.
			}
			if ((btrpkt->dutyCycle > 0) && (btrpkt->dutyCycle < 32767)) // Check If Duty Cycle is provided & Value Is Valid.
			{
				ResetDutyCycle(btrpkt->dutyCycle); // Update Radio Duty Cycle.
			}
			ProcessRequest(btrpkt->sensorTypeToSense, btrpkt->RequesterMoteID);
		}
		return msg;
	}
	//**********************************************************************************************************	
	//**********************************************************************************************************
}