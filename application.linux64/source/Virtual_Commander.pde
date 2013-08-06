/****************************************************
* Trossen Robotics Virtual Commander
*
*
* This application is a virtual repreentation of the 
* ArbotiX Commander 
* http://www.trossenrobotics.com/p/arbotix-commander-gamepad-v2.aspx
* The Virtual Commander, like the ArbotiX Commander can be used to 
* control a variety InterbotiX robot kits. The kit must be running 
* firmware that is designed to be controlled from the ArbotiX Commander
*
* The virtual commander can be connected 2 ways
* 1)Direct FTDI
*  Using an FTDI-USB cable (like http://www.trossenrobotics.com/store/p/6406-FTDI-Cable-5V.aspx )
*  or an UartSBee ( http://www.trossenrobotics.com/p/uartsbee )
*  one can connect their computer to the ArbotiX Robocontroller onboard the InterbotiX kit.
*  This will give the computer a direct serial port communication line to the ArbotiX.
*   NOTE: You cannot have an XBee plugged into the ArbotiX while you are controlling it via the FTDI port
* 2)XBee Control
*   You can use 2 paired Xbees running at 34000 baud to create a serial connection between your computer
*   and the ArbotiX Robocontroller. You will plug an XBee into the ArbotiX Robocontoller normally. On the 
*   computer side, you will plug the XBee into your UartSBee (or other USB to XBee device).
*   
*
*
* More information of the Commander protocol can be found here
* http://vanadiumlabs.com/docs/commander-manual.pdf
*
*
*/
import processing.serial.*; //import serial library to communicate with the ArbotiX
import controlP5.*; //Import the P5 Library for GUI interface elements (drop list, button)




Serial sPort;  // Create object from Serial class
ControlP5 cp5;           // p5 control object

DropdownList serialList;    //inintiate drop down boxes for serial port list
int selectedPort;             //currently selected port from serialList drop down
Button connectButton;
Button disconnectButton;

int val;       // Data received from the serial port
char buttons;  //holds the data that represents the 8 pushbuttons. 

int [] buttonState ={0,0,0,0,0,0,0,0}; //Array to hold the current state of each button, 0=unpushed, 1=pushed
int allButtons;

int right_V = 128;   // Vertical position of the right joystick. 0 = All the way down, 127 = centered, 255 = all the way up
int right_H = 128;   // Horizontal position of the right joystick. 0 = All the way left, 127 = centered, 255 = all the way right
int left_H = 128;    // Vertical position of the right joystick. 0 = All the way down, 127 = centered, 255 = all the way up
int left_V = 128;    // Horizontal position of the right joystick. 0 = All the way left, 127 = centered, 255 = all the way right

int running = 0;
int debug =1;
int i;      //
PImage bg;  //PImage object to hold the background image

//XY coordinates for the 8 Digital pushbuttons
int [][] buttonCoord = {
{7,41,20,20},
{31,41,20,20},
{55,48,20,20},
{169,48,20,20},
{194,41,20,20},
{219,41,20,20},
{7,15,20,20},
{219,15,20,20},
{110,225,90,90},
{210,225,90,90}
};

//XY Coordinates for the joysticls. [0] is left and [1] is right
int [][] joystickCoord = { 
{0,80,78,78},
{160,80,78,78}
};


int [][] mouseJoystickCoord = { 
{0,0},
{0,0}
};

float [][] mouseJoystickOffset = { 
{0,0},
{0,0}
};



int joyRightCenter[] ={(buttonCoord[8][0] + buttonCoord[8][2]/2) ,(buttonCoord[8][1] + buttonCoord[8][3]/2)} ;//center of right joystick
int lastPacketSent;


void setup() 
{
  
  
  cp5 = new ControlP5(this);
  
  print(joyRightCenter[0]);
  print('-');
  print(joyRightCenter[1]);
  println(' ');
  size(242, 165);
  bg = loadImage("arbotixCommander.png");

  
  background(bg);
  for(int i=0;i<8;i++)
  {
  //  rect(buttonCoord[i][0],buttonCoord[i][1],buttonCoord[i][2],buttonCoord[i][3]);
  }

   //rect(joystickCoord[0][0],joystickCoord[0][1],joystickCoord[0][2],joystickCoord[0][3]);
   //rect(joystickCoord[1][0],joystickCoord[1][1],joystickCoord[1][2],joystickCoord[1][3]);

  
  
  
  // I know that the first port in the serial list on my mac
  // is always my  FTDI adaptor, so I open Serial.list()[0].
  // On Windows machines, this generally opens COM1.
  // Open whatever port is the one you're using.
  
  //String portName = Serial.list()[6];
 // String port = "tty.usbserial-A900XOMV"; 
 // String portName = "/dev/cu.usbserial-FTT37ZWJ"; 
  /*String portName = "/dev/cu.usbserial-A400C1UX"; 
  println(Serial.list());

 sPort = new Serial(this, portName, 38400);
 myDelay(1000);
 */
 

/*********************SERIAL PORTS/BUTTONS******************/ 

  //initialize button for connecting to selected serial port 
  connectButton = cp5.addButton("connectSerial")
                     .setValue(1)
                     .setPosition(145,0)
                     .setSize(40,15)
                     .setCaptionLabel("Connect")
     ;
     
  //initialize button for disconnecting from current serial port 
  disconnectButton =  cp5.addButton("disconnectSerial")
                         .setValue(1)
                         .setPosition(190,0)
                         .setSize(60,15)
                         .setCaptionLabel("Disconnect")                       
                         .lock()
                         .setColorBackground(color(200))
                         ;    
                         
                         
                           //initialize serialList dropdown properties
  serialList = cp5.addDropdownList("serialPort")
                  .setPosition(0, 15)
                  .setSize(140,150)
                  .setCaptionLabel("Serial Port")
                  ;
  customize(serialList); // customize the com port list
    
  //iterate through all the items in the serial list (all available serial ports) and add them to the 'serialList' dropdown
  for (int i=0;i<Serial.list().length;i++) 
  {
    //if((Serial.list()[i]).startsWith("/dev/tty.usbserial"))//remove extra UNIX ports to ease confusion
    //{  
    ListBoxItem lbi = serialList.addItem(Serial.list()[i], i);
    lbi.setColorBackground(0xffff0000);
    //}
  }
    
    
}


/*****************************************************START P5 CONTROLLER FUNCTIONS****************************/



void customize(DropdownList ddl) {
  // a convenience function to customize a DropdownList
  ddl.setBackgroundColor(color(190));
  ddl.setItemHeight(20);
  ddl.setBarHeight(15);
  
  ddl.captionLabel().style().marginTop = 3;
  ddl.captionLabel().style().marginLeft = 2;
  ddl.valueLabel().style().marginTop = 3;
  


  ddl.setColorBackground(color(60));
  ddl.setColorActive(color(255, 128));
}



/************************************
 * connectSerial
 *
 * connectSerial will receive changes from  controller(button) with name connectSerial
 * connectSerial will take the currently selected serial port and attempt to connect to it
 * connectSerial will also check that serial port to make sure that an arbotix is connected
 *
 ************************************/  
public void connectSerial(int theValue) 
{
  if(running  == 1)//check to make sure we're in run mode
  {
    int serialPortIndex = (int)serialList.value();//get the serial port selected from the serlialList
    
    //try to connect to the port at 115200bps, otherwise show an error message
    try
    {
      sPort = new Serial(this, Serial.list()[serialPortIndex], 38400);
    }
    catch(Exception e)
    {
      if(debug ==1){println("Error Opening Serial Port");}
      //errorGroup.setVisible(true);
      //errorText.setVisible(true);        
      //errorText.setText("Error Connecting to Port - try a different port or try closing other applications using the current port");    
    }
    
    delayMs(100);//add delay for some systems
    
    //send a command to see if the ArbotiX is connected. 
   
      
      //lock connect button and change apperance, unlock disconnect button and change apperance
      connectButton.lock();
      connectButton.setColorBackground(color(200));
      
      
      disconnectButton.unlock();
      disconnectButton.setColorBackground(color(2,52,77));
    
  }
   
}// end connectSerial


/************************************
 * disconnectSerial
 *
 * disconnectSerial will receive changes from  controller(button) with name disconnectSerial
 * disconnectSerial will disconnect from the current serial port and hide GUI elements that should only
 * be available when connected to an arbotix
 ************************************/  
public void disconnectSerial(int theValue) 
{
  //check to make sure we're in run mode and that the serial port is connected
  if(running ==1 && sPort != null)
  {
    sPort.stop();//stop/disconnect the serial port   
    sPort = null;//set the serial port to null, incase another function checks for connectivity
    

    //unlock connect button and change apperance, lock disconnect button and change apperance
    connectButton.unlock();
    connectButton.setColorBackground(color(2,52,77));
    
    disconnectButton.lock();
    disconnectButton.setColorBackground(color(200));
  
  }
}//end disconnectSerial


/*****************************************************END P5 CONTROLLER FUNCTIONS****************************/


void draw() {
  

  background(bg);//redraw background regulary

  running = 1;//set a 'running' flag to keep the P5 control functions from firing before we begin running
  allButtons = 0;//clear variable that holds all the buttons
  
  //the 'mousePressed' function populates the 'buttonState' array with 'on' buttons. 
  //this loop will pack the button into its proper bit in the byte, and clear the
  //'buttonState' array  
  for(int i=0;i<8;i++)
  {
    if(buttonState[i] == 1)
    {
      allButtons += pow(2,i);
      println(allButtons);
      buttonState[i] = 0;
    }
  }
  
  //check to see if the mouse is over the left joystick and if it is pressed
  if(mouseOverJoystick(0) == true && mousePressed == true)
  {
    //figure out the position of the mouse relative to the corner of the joystick
    mouseJoystickOffset[0][0] = mouseJoystickCoord[0][0] - joystickCoord[0][0];
    mouseJoystickOffset[0][1] = mouseJoystickCoord[0][1] - joystickCoord[0][1];
    //calculate the left_H and left_v values by mapping the relative offset value to a 0-255 value
    left_H = floor(((mouseJoystickOffset[0][0]/joystickCoord[0][2])*255));
    left_V = floor(255-((mouseJoystickOffset[0][1]/joystickCoord[0][3])*255));//we need to invert the value since the processing world goes 0->255 up->down, and the commander goes 0->255 down->up
   
    if(debug ==1)
    {
        print(left_V);
        print("-");
        print(left_H);
        println(" ");    
    }

  }
  //if no joystick is being pressed, set the values back to center.
  else
  {
    left_V = 128;
    left_H = 128;
  }
  
  //check to see if the mouse is over the right joystick and if it is pressed
  if(mouseOverJoystick(1) == true && mousePressed == true)
  {
    //figure out the position of the mouse relative to the corner of the joystick
    mouseJoystickOffset[1][0] = mouseJoystickCoord[1][0] - joystickCoord[1][0];
     mouseJoystickOffset[1][1] = mouseJoystickCoord[1][1] - joystickCoord[1][1];
     
    //calculate the right_H and right_V values by mapping the relative offset value to a 0-255 value
     right_H = floor(((mouseJoystickOffset[1][0]/joystickCoord[1][2])*255));
     right_V = floor(255-((mouseJoystickOffset[1][1]/joystickCoord[1][3])*255));
    if(debug ==1)
    {   
      print(right_V);
      print("-");
      print(right_H);
      println(" "); 
    }   
  }
  //if no joystick is being pressed, set the values back to center.
  else
  {
    right_V = 128;
    right_H = 128;
  }
  

  //if the serial port is connected, then send 
  if(sPort != null)
  {
    sPort.write(0xff);          //header
    sPort.write((byte)right_V); //right vertical joystick
    sPort.write((byte)right_H); //right horizontal joystick
    sPort.write((byte)left_V);  //left vertical joystick
    sPort.write((byte)left_H);  //left horizontal joystick
    sPort.write(allButtons);    //single byte holds all the button data 
    sPort.write((byte)0);       //0 char
    sPort.write((byte)(255 - (right_V+right_H+left_V+left_H+allButtons)%256));  //checksum
    delayMs(33);//delay 33ms for 30hz
   // println(right_V)
  }
}


//check if the mouse is over the rectangle passed to it
boolean mouseClickRect(int rectangle[])
{

   return ((mouseX >= rectangle[0]) && (mouseX <= (rectangle[0]+rectangle[2])) && (mouseY >= rectangle[1]) && (mouseY <= (rectangle[1]+rectangle[3])));
}




//check if the mouse is over the joysticl passed to it
boolean mouseOverJoystick(int joystick) 
{
  if((mouseX >= joystickCoord[joystick][0]) && (mouseX <= (joystickCoord[joystick][0]+joystickCoord[joystick][2])) && (mouseY >= joystickCoord[joystick][1]) && (mouseY <= (joystickCoord[joystick][1]+joystickCoord[joystick][3])))
  {
    mouseJoystickCoord[joystick][0] = mouseX;
    mouseJoystickCoord[joystick][1] = mouseY;
  //, mouseY};
    return(true);
  }
  else
  {
    return(false); 
  }

}

//iterate through all to see if any of the buttons are being pressed
void mousePressed()
{
  for(int i=0;i<8;i++)
  {
    if(mouseClickRect(buttonCoord[i])==true)
    {
      print("Clicked");
      println(i);

      buttonState[i]=1;
    }
    else
    {
      buttonState[i]=0;
    }
  }
}



 void delayMs(int ms){
  int time = millis();
  while(millis()-time < ms);
}

//when the program closes, close the serial port
void stop()
{
 sPort.stop(); 
}

