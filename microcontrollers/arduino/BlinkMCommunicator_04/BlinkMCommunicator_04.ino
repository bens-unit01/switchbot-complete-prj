

#include "Wire.h"
#include "BlinkM_funcs.h"

//#define DEBUG 1

// set this if you're plugging a BlinkM directly into an Arduino,
// into the standard position on analog in pins 2,3,4,5
// otherwise you can set it to false or just leave it alone

#define pin_number 2
// I2C: A4 (SDA) and A5 (SCL). 
const boolean BLINKM_ARDUINO_POWERED = true;

const int CMD_START_BYTE = 0x54;

//int blinkm_addr = 0x09;
int blinkm_addr = 0x00;
const int serBufLen = 10;
byte serInBuf[serBufLen];  // array that will hold the serial input string

int ledPin = 13;

void setup()
{
  Serial.begin(115200); 
  pinMode(pin_number, INPUT);
  //Serial.println("BlinkMCommunicator starting up...");

  pinMode(ledPin, OUTPUT);
  if( BLINKM_ARDUINO_POWERED ) {
    BlinkM_beginWithPower();
  } 
  else {
    BlinkM_begin();
  }
  delay(100);  // wait for power to stabilize

  //lookForBlinkM();

#ifdef DEBUG  
  byte rc = BlinkM_checkAddress( blinkm_addr );
  if( rc == -1 ) 
    Serial.println("No response");  // FIXME: make this an interogator loop?
  else if( rc == 1 ) 
    Serial.println("I2C address mismatch"); 
#endif

 BlinkM_stopScript( blinkm_addr );
 BlinkM_fadeToRGB( blinkm_addr, 0xff,0,0);  
 BlinkM_setFadeSpeed(blinkm_addr, 10);
#ifdef DEBUG
  Serial.println("BlinkMCommunicator ready");
  Serial.println("DEBUG MODE: will not allow proper functionality");
#endif

// we notify the android device that we are ready 
Serial.write(0x54);
Serial.write(0x00);
Serial.write(0x00);
}

void lookForBlinkM()
{
  
 // Serial.print("Looking for a BlinkM: ");
  int a = BlinkM_findFirstI2CDevice();
  if( a == -1 ) {
 //   Serial.println("No I2C devices found");
  } else { 
   // Serial.print("Device found at addr ");
 //   Serial.println( a, DEC);
    blinkm_addr = a;
  }
}

// called when address is found in BlinkM_scanI2CBus()
void i2cScanResult( byte addr, byte result )
{
    Serial.write(addr); 
    Serial.write(result);
}

void loop()
{
  handle_push_button();
  handle_rgb_ctrl();
  delay(20);
    
} 

void handle_push_button(){
  
      int sensorValue = digitalRead(pin_number);
      if(sensorValue == 1){
//        Serial.println("push ");
        Serial.write(0x50);
        Serial.write((byte)0);
        Serial.write((byte)0);
        delay(300);
      }
 }

void handle_rgb_ctrl(){
  
  int num;
  //read the serial port and create a string out of what you read
  num = readCommand(serInBuf);
  if( num == 0 )   // see if we got a proper command string yet
    return;
  


    byte cmd    = serInBuf[0];
    byte select_script = serInBuf[1];
    byte addr = blinkm_addr;


    
#ifdef DEBUG
    Serial.print(" cmd:"); Serial.print(cmd,HEX);
    Serial.print(" select_script:"); Serial.println(select_script,HEX);
#endif

         switch(select_script){
         case 1:  // Solid Red
                BlinkM_stopScript(addr);
                BlinkM_setFadeSpeed( addr, 200);
                BlinkM_fadeToRGB( addr, 0xff,0,0);
                 break;
        case 2:  // Solid Blue
                 BlinkM_stopScript(addr);
                BlinkM_setFadeSpeed( addr, 200);
                 BlinkM_fadeToRGB( addr, 0,0,0xff);
                 break;
         case 3:  // Solid Amber
                 BlinkM_stopScript( addr);
                BlinkM_setFadeSpeed( addr, 200);
                 BlinkM_fadeToRGB( addr, 255,191,0);
                 break;
         case 4:  // Solid Green
                 BlinkM_stopScript( addr);
               BlinkM_setFadeSpeed( addr, 200);
                 BlinkM_fadeToRGB( addr, 0,0xff,0);
                 break;
         case 5:  // Flash Green Slow
                  BlinkM_stopScript( addr);
                BlinkM_setFadeSpeed(addr, 10);
                  BlinkM_setTimeAdj(addr, 10);
                  BlinkM_playScript(addr, 4,0,0 );
                 break;
         case 6:  // Flash Green Quick
                  BlinkM_stopScript(addr);
                BlinkM_setFadeSpeed(addr, 255);
                  BlinkM_setTimeAdj(addr, -40);
                  BlinkM_playScript(addr, 4,0,0 );
                 break;
         case 7:  // Flash Blue Slow
                  BlinkM_stopScript( addr);
                BlinkM_setFadeSpeed(addr, 10);
                  BlinkM_setTimeAdj( addr, 10);
                  BlinkM_playScript( addr, 5,0,0 );
                 break;
          case 8:  // Flash Blue Quick
                  BlinkM_stopScript( addr );
                BlinkM_setFadeSpeed( addr, 255);
                  BlinkM_setTimeAdj( addr, -40);
                  BlinkM_playScript( addr, 5,0,0 );
                 break;
         case 0:
         default: //OFF
               BlinkM_stopScript( addr);
               BlinkM_playScript( addr, 9,0,0 );
               break;


         }
    
  
    
    for(int i=0; i< serBufLen; i++) {
        serInBuf[i] = 0;  // say we've used the string (not needed really)
    }

}  

//read a string from the serial and store it in an array
//you must supply the str array variable
//returns number of bytes read, or zero if fail
uint8_t readCommand(byte *str)
{
  uint8_t b,i;
  if( ! Serial.available() ) return 0;  // wait for serial

  b = Serial.read();
  if( b != CMD_START_BYTE )         // check to see we're at the start
    return 0;

  str[0] = b;
  i = 100;
  while( Serial.available() < 1 ) {   // wait for the rest
    delay(1); 
    if( i-- == 0 ) return 0;        // get out if takes too long
  }

 if(Serial.available()){
   str[1] = Serial.read();
  } else return 0;
  return 3;
}



