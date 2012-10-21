import net.tinyos.message.*;
import net.tinyos.util.*;
import java.io.*;

public class Communicate implements MessageListener
{
    public static int ID;
    MoteIF mote;

    /* Main entry point */
    void run() throws Exception {
	mote = new MoteIF(PrintStreamMessenger.err);
	mote.registerListener(new SenseResponseMsg(), this);
    }

    /* Function to receieve message data from serial forwarder */
    synchronized public void messageReceived(int dest_addr, Message msg) {
	if ((msg instanceof SenseResponseMsg)) {
	    try {
		SenseResponseMsg omsg = (SenseResponseMsg)msg;
	
		    /* Display Sensed Data To User */
		    if (omsg.get_requesterMoteID() == 9510) // Check If UniqueID of the message matches the UniqueID we have.
		    // This is done to ensure that the received message is against our request.
		    {
			    if (omsg.get_datatype() == 1) // Temperature value was quried and hence returned by Sensor Mote.
			    {
				System.out.println("The Temperature Value At Mote \"" + omsg.get_sourceMoteID() + "\" Is : " + omsg.get_data() + "\n");
				System.out.println("Please Enter Next Choice (t, i, h, d or f), Or Press \"q\" to quit .......\n");
			    }
			    else if (omsg.get_datatype() == 2) // Light Intensity value was quried and hence returned by Sensor Mote.
			    {
				System.out.println("The Light Value At Mote \"" + omsg.get_sourceMoteID() + "\" Is : " + omsg.get_data() + "\n");
				System.out.println("Please Enter Next Choice (t, i, h, d or f), Or Press \"q\" to quit .......\n");
			    }
			    else if (omsg.get_datatype() == 3) // Humidity value was quried and hence returned by Sensor Mote.
			    {
				System.out.println("The Humidity Value At Mote \"" + omsg.get_sourceMoteID() + "\" Is : " + omsg.get_data() + "\n");
				System.out.println("Please Enter Next Choice (t, i, h, d or f), Or Press \"q\" to quit .......\n");
		    	    }
	    	    }
	    }
	    catch (Exception e) {
	    	System.out.println("Cannot Receieve Message.\n");
	    }
	}
    }

    /* Function to Send Request To Mote */
    void sendRequest(int ID, int RadioDutyCycle, int SamplingFrequency, int ReqType) {
	SenseRequestMsg omsg = new SenseRequestMsg();

	omsg.set_RequesterMoteID(ID); // UniqueID of The Request, This will be returned as it is by Sensor Mote.
	// This UniqueID will identify that the message received in response to a query was requested by us.

	omsg.set_dutyCycle(RadioDutyCycle); // Updated Value Of Duty Cycle, 
	// If a non zero value is sent Duty cycle will get updated with that value. If it is "0" then duty cycle remains unchanged.

	omsg.set_samplingFrequency(SamplingFrequency); // Updated Value Of Sampling Frequency, 
	// If a non zero value is sent Sampling Frequency will get updated with that value. If it is "0" then Sampling Frequency remains unchanged

	omsg.set_sensorTypeToSense(ReqType); // The Type of data that is bieng requested (Temperature, Light or Humidity).

	try {
	    mote.send(MoteIF.TOS_BCAST_ADDR, omsg); // Send Request Message.
	}
	catch (IOException e) {
	    System.out.println("Cannot Send Message To Mote.\n");
	}
    }

    public static void main(String[] args) {
	Communicate c = new Communicate();
	try {
	    c.run();
	    System.out.println("Connected To Serial Forwader....... \n");
	}
	catch (Exception e) {
	    System.out.println("Unable To Connect With Serial Forwader..... Quiting Application (Please Ensure Serial Forwader is running \n");
	}

	System.out.println("Starting ....... \n");
	System.out.println("Select From Belwo Options: \n");
	System.out.println("t ------- Temperature \n");
	System.out.println("i ------- Light \n");
	System.out.println("h ------- Humidity \n");
	System.out.println("d ------- Change Radio Duty Cycle \n");
	System.out.println("f ------- Change Sampling Frequency \n");
	System.out.println("q ------- Quit  \n\n");

	String input = null;
	ID = 9510; // Unique ID Of Representing Our Application
	// We only process messages that have "requesterMoteID" set to above value is response message from the mote.
	// All Other messages are not processed.
	// This Unique ID is passed to the mote while quering. And Then Is verified in response message to determine the message was addressed to us.
	

	// Main Loop to process User requests, Continues till user presses "Q" or "q" to terminate the application.
	do {
		char ch = 0;
		try {
		    ch = (char)System.in.read();
		}
		catch (IOException e) {
		    System.out.println("Incorrect Input");
		}
	
		input = Character.toString(ch);
		// Checking below if input is valid, If not than the value is ignored.
		if (ch == '\n'){} // Ignore New Line Characters.
		else if (ch == 't' || ch == 'T' ||
			ch == 'i' || ch == 'I' ||
			ch == 'h' || ch == 'H' ||
			ch == 'd' || ch == 'D' ||
			ch == 'f' || ch == 'F' ||
			ch == 'q' || ch == 'Q'){

			System.out.println("\n You Entered : \"" + input.toLowerCase() + "\"  .....\n");
			if (input.toLowerCase().equals("t"))
			{
				c.sendRequest(ID, 0, 0 , 1); // Send Temperature query request.
			}
			else if (input.toLowerCase().equals("i"))
			{
				c.sendRequest(ID, 0, 0 , 2); // Send Visible Light Intensity query request.
			}
			else if (input.toLowerCase().equals("h"))
			{
				c.sendRequest(ID, 0, 0 , 3); // Send Humidity query request.
			}
			else if (input.toLowerCase().equals("d"))
			{
				// Get Updated Value Of Duty Cycle from User.
				int newval = GetNewValue();
				// Verify if entered value is in given range.
				if ( newval > 0 && newval < 32767)
				{
					c.sendRequest(ID, newval, 0 , 0); // Send Duty Cycle Update request.
					System.out.println("Radio Duty Cycle Updated To \"" + newval + "\" Milli Seconds.\n");
					System.out.println("Please Enter Next Choice (t, i, h, d or f), Or Press \"q\" to quit .......\n");
				}
				else
				{
					System.out.println("Entered Value Must be between 0 & 32768 (both exclusive) ....... \n");
					System.out.println("Please Enter your Choice (t, i, h, d or f), Or Press \"q\" to quit .......\n");
				}
			}
			else if (input.toLowerCase().equals("f"))
			{
				// Get Updated Value Of Sampling Frequency from User.
				int newval = GetNewValue();
				// Verify if entered value is in given range.
				if ( newval > 0 && newval < 32767)
				{
					c.sendRequest(ID, 0, newval , 0); // Send Sampling Frequency Update request.
					System.out.println("Sampling Frequency Updated To \"" + newval + "\" Milli Seconds.\n");
					System.out.println("Please Enter Next Choice (t, i, h, d or f), Or Press \"q\" to quit .......\n");
				}
				else
				{
					System.out.println("Entered Value Must be between 0 & 32768 (both exclusive) ....... \n");
					System.out.println("Please Enter your Choice (t, i, h, d or f), Or Press \"q\" to quit .......\n");
				}
			}
			else if (input.toLowerCase().equals("q"))
			{
				System.out.println("Exiting Mote Communicator....... \n"); // Exit application on user request.
				break;
			}
		}
		else { // Reprint usage in case of a wrong input.

			System.out.println("\nWrong Choice Entered ....... \n");
			System.out.println("Select From Belwo Options: \n");
			System.out.println("t ------- Temperature \n");
			System.out.println("i ------- Light \n");
			System.out.println("h ------- Humidity \n");
			System.out.println("d ------- Change Radio Duty Cycle \n");
			System.out.println("f ------- Change Sampling Frequency \n");
			System.out.println("q ------- Change Sampling Frequency \n\n");
		}
	} while (true);
	System.out.println("Good Bye ....... \n");
	System.exit(0); // Quit Application.
    }

    /* Function to Read a New integer value of Duty Cycle Or Sampling Frequency from User */
    public static int GetNewValue() {
    	String line = null;
    	int val = 0;
	System.out.println("\nPlease Entered The New Value, Must be between 0 & 32768 (both exclusive) ....... \n");
  	  try {
	     while (System.in.available() > 1 )
	     {
		     System.in.read();
		     continue;
	     }
	     System.in.read();
 	     BufferedReader is = new BufferedReader(
	        new InputStreamReader(System.in));
	      line = is.readLine();
	      val = Integer.parseInt(line);
	      System.out.println("\n");
	    } catch (NumberFormatException ex) {
 	     System.err.println("Not a valid number: \"" + line + "\"\n");
	     val = 0;
 	   } catch (IOException e) {
 	     System.err.println("Error While Reading New Value \n");
	     val = 0;
 	   }	
         return val;
    }
}
