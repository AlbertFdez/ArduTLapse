import processing.core.*; 
import processing.xml.*; 

import processing.serial.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class SyncArduinoClock extends PApplet {

/**
 * SyncArduinoClock. 
 *
 * portIndex must be set to the port connected to the Arduino
 * 
 * The current time is sent in response to request message from Arduino 
 * or by clicking the display window 
 *
 * The time message is 11 ASCII text characters; a header (the letter 'T')
 * followed by the ten digit system time (unix time)
 */
 



public static final short portIndex = 1;  // select the com port, 0 is the first port
public static final char TIME_HEADER = 'T'; //header byte for arduino serial time message 
public static final char TIME_REQUEST = 7;  // ASCII bell character 
public static final char LF = 10;     // ASCII linefeed
public static final char CR = 13;     // ASCII linefeed
Serial myPort;     // Create object from Serial class

public void setup() {  
  size(200, 200);
  println(Serial.list());
  println(" Connecting to -> " + Serial.list()[portIndex]);
  myPort = new Serial(this,Serial.list()[portIndex], 9600);
}

public void draw()
{
  if ( myPort.available() > 0) {  // If data is available,
    char val = PApplet.parseChar(myPort.read());         // read it and store it in val
    if(val == TIME_REQUEST){
       long t = getTimeNow();
       sendTimeMessage(TIME_HEADER, t);   
    }
    else
    { 
       if(val == LF)
           ; //igonore
       else if(val == CR)           
         println();
       else  
         print(val); // echo everying but time request
    }
  }  
}

public void mousePressed() {  
  sendTimeMessage( TIME_HEADER, getTimeNow());   
}


public void sendTimeMessage(char header, long time) {  
  String timeStr = String.valueOf(time);  
  myPort.write(header);  // send header and time to arduino
  myPort.write(timeStr);   
}

public long getTimeNow(){
  // java time is in ms, we want secs    
  GregorianCalendar cal = new GregorianCalendar();
  cal.setTime(new Date());
  int	tzo = cal.get(Calendar.ZONE_OFFSET);
  int	dst = cal.get(Calendar.DST_OFFSET);
  long now = (cal.getTimeInMillis() / 1000) ; 
  now = now + (tzo/1000) + (dst/1000); 
  return now;
}
  static public void main(String args[]) {
    PApplet.main(new String[] { "--bgcolor=#F0F0F0", "SyncArduinoClock" });
  }
}