#include <RBL_nRF8001.h>
#include <boards.h>
#include <ble_shield.h>
#include <SPI.h>
#include <services.h>

#define PIN 7
#define MAX_SIZE 4

/*char* to_str(char buffer[4], int i)
{
  int index = 2; // reverse fill the buffer
  
  while (i != 0)
  {
    int current =  
  
}
*/
void setup()
{
  ble_set_name("ev9");
  
  // Init. and start BLE library.
  ble_begin();
  
  Serial.begin(9600);
}

long microsecondsToCentimeters(long microseconds)
{
   return microseconds / 29 / 2;
}

void loop()
{
  unsigned char str[MAX_SIZE];
  
  while(1)
  {
    long duration, cm;

    pinMode(PIN, OUTPUT);
    digitalWrite(PIN, LOW);
    delayMicroseconds(2);

    digitalWrite(PIN, HIGH);
    delayMicroseconds(5);
    digitalWrite(PIN, LOW);

    pinMode(PIN, INPUT);
    duration = pulseIn(PIN, HIGH);

    cm = microsecondsToCentimeters(duration);
        
    //char* current_str = to_str(c, 
    String distance = String(cm);
    for (int i = 0; i < distance.length() && MAX_SIZE; i++)
      str[i] = distance[i];
      
    if(ble_connected())
    {
      ble_write_bytes(str, distance.length());
      
      Serial.print(cm);
      Serial.print("\n");
    }
    
    ble_do_events();
  
    delay(10);
 
  } 
 
}
