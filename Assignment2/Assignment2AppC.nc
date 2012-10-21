configuration Assignment2AppC
{
}
implementation
{
  components MainC;
  components LedsC;
  components Assignment2C;
  components ActiveMessageC;
  components new AMSenderC(AM_SENSERESPONSEMSG);
  components new AMReceiverC(AM_SENSEREQUESTMSG);
  components new TimerMilliC() as Timer0; // Timer For Sampling Frequency
  components new TimerMilliC() as Timer1; // Timer For Turning Radio ON Or OFF
  components new HamamatsuS1087ParC() as Light; // Visible Light Sensor For Telosb
  components new SensirionSht11C() as Humidity_And_Temperature; // Temperature and Humidity Sensor For Telosb

  Assignment2C -> MainC.Boot;
  Assignment2C.Leds -> LedsC;
  Assignment2C.Timer0 -> Timer0;
  Assignment2C.Timer1 -> Timer1;
  Assignment2C.Packet -> AMSenderC;
  Assignment2C.AMSend -> AMSenderC;
  Assignment2C.AMPacket -> AMSenderC;
  Assignment2C.Receive -> AMReceiverC;
  Assignment2C.AMControl -> ActiveMessageC;
  Assignment2C.ReadLight -> Light;
  Assignment2C.ReadHumidity -> Humidity_And_Temperature.Humidity;
  Assignment2C.ReadTemperature -> Humidity_And_Temperature.Temperature;
}

