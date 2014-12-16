#include <RBL_nRF8001.h>
#include <boards.h>
#include <ble_shield.h>
#include <SPI.h>
#include <services.h>

#define PIN 7
#define MAX_SIZE 7
#define SKIP_SIZE 20

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
  int count = 0;
  
  unsigned char str[MAX_SIZE];
  
  memset(str, 0, MAX_SIZE * sizeof(char));
  
  while(1)
  {
    long duration, cm;
    int number_bytes_to_send;

    pinMode(PIN, OUTPUT);
    digitalWrite(PIN, LOW);
    delayMicroseconds(2);

    digitalWrite(PIN, HIGH);
    delayMicroseconds(5);
    digitalWrite(PIN, LOW);

    pinMode(PIN, INPUT);
    duration = pulseIn(PIN, HIGH);
    
    cm = microsecondsToCentimeters(duration);
         
    String distance = String(cm);
    number_bytes_to_send = distance.length();
    
    for (int i = 0; i < distance.length() && MAX_SIZE-1; i++)
      str[i] = distance[i];
     
    if (count == SKIP_SIZE)
    { 
      if (Serial.available() > 0)
      {
        char char_read = Serial.read();
        if (char_read == '1')
        {
          str[distance.length()] = 'P';
          number_bytes_to_send++;
        }
        else if (char_read == '0')
        {
          str[distance.length()] = 'N';
          number_bytes_to_send++;
        }
      } 
      
      count = 0;
    }
    
    ++count;
     
    if(ble_connected())
    {
      ble_write_bytes(str, number_bytes_to_send);
    }
    
    ble_do_events();
  } 
 
}
