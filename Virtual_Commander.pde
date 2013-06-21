/****************************************************
* Trossen Robotics Virtual Commander
*
*
*
*
*******************************************************************************************************/


import processing.serial.*; //import serial library to communicate with the ArbotiX

Serial sPort;  // Create object from Serial class
int val;        // Data received from the serial port
char buttons;
int right_V = 128 ;
int right_H = 128;
int left_H = 128;
int left_V = 128;
int i;
PImage bg;

int [][] buttonCoord = {
{7,26,20,20},
{31,26,20,20},
{55,33,20,20},
{169,33,20,20},
{194,26,20,20},
{219,26,20,20},
{7,0,20,20},
{219,0,20,20},

{110,210,90,90},
{210,210,90,90}
};

//[0] is left [1] is right
int [][] joystickCoord = { 
{0,65,78,78},
{160,65,78,78}
};

int [] buttonState ={0,0,0,0,0,0,0,0};

int allButtons;

int [][] mouseJoystickCoord = { 
{0,0},
{0,0}
};

float [][] mouseJoystickOffset = { 
{0,0},
{0,0}
};





//int joyWidth = 90;
//int joyHeight = 90;

int joyRightCenter[] ={(buttonCoord[8][0] + buttonCoord[8][2]/2) ,(buttonCoord[8][1] + buttonCoord[8][3]/2)} ;//center of right joystick
int lastPacketSent;


void setup() 
{
  print(joyRightCenter[0]);
  print('-');
  print(joyRightCenter[1]);
  println(' ');
  size(242, 151);
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
  String portName = "COM124"; 
  println(Serial.list());

 sPort = new Serial(this, portName, 38400);
 myDelay(1000);
}

void draw() {
  


  
    allButtons = 0;
    
  for(int i=0;i<8;i++)
  {
    if(buttonState[i] == 1)
    {
      allButtons += pow(2,i);
      println(allButtons);
      buttonState[i] = 0;
      
    }
  }
  
  if(mouseOverJoystick(0) == true && mousePressed == true)
  {
    mouseJoystickOffset[0][0] = mouseJoystickCoord[0][0] - joystickCoord[0][0];
     mouseJoystickOffset[0][1] = mouseJoystickCoord[0][1] - joystickCoord[0][1];
     
     left_H = floor(((mouseJoystickOffset[0][0]/joystickCoord[0][2])*255));
     left_V = floor(255-((mouseJoystickOffset[0][1]/joystickCoord[0][3])*255));
   
    print(left_V);
    print("-");
    print(left_H);
    println(" ");    
  }
  else
  {
    left_V = 128;
    left_H = 128;
  }
  
  
  if(mouseOverJoystick(1) == true && mousePressed == true)
  {
    mouseJoystickOffset[1][0] = mouseJoystickCoord[1][0] - joystickCoord[1][0];
     mouseJoystickOffset[1][1] = mouseJoystickCoord[1][1] - joystickCoord[1][1];
     
     right_H = floor(((mouseJoystickOffset[1][0]/joystickCoord[1][2])*255));
     right_V = floor(255-((mouseJoystickOffset[1][1]/joystickCoord[1][3])*255));
   
    print(right_V);
    print("-");
    print(right_H);
    println(" ");    
  }
  else
  {
    right_V = 128;
    right_H = 128;
  }
  


  
//  if(millis()-lastPacketSent > 33 )
//{  
    sPort.write(0xff);
    sPort.write((char)right_V);
    sPort.write((char)right_H);
    sPort.write((char)left_V);
    sPort.write((char)left_H);
    sPort.write(allButtons);
    sPort.write((char)0);
    sPort.write((char)(255 - (right_V+right_H+left_V+left_H+allButtons)%256));
   // lastPacketSent = millis();
    myDelay(33);
//}
    //println("serial "+ i++);
    
    /*
    print(right_V);
    print("-");
    print(right_H);
    print("-");
    print(left_V);
    print("-");
    println(left_H);*/
    
//  } 
  //else {                        // If mouse is not over square,
    //fill(0);                      // change color and
   // sPort.write('L');              // send an L otherwise
  //}
}

boolean mouseOverRect() { // Test if mouse is over square
  return ((mouseX >= 50) && (mouseX <= 150) && (mouseY >= 50) && (mouseY <= 150));
}

boolean mouseClickRect(int rectangle[])
{

   return ((mouseX >= rectangle[0]) && (mouseX <= (rectangle[0]+rectangle[2])) && (mouseY >= rectangle[1]) && (mouseY <= (rectangle[1]+rectangle[3])));
}





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


 void myDelay(int ms){
  int time = millis();
  while(millis()-time < ms);
}

void stop()
{
 sPort.stop(); 
}

