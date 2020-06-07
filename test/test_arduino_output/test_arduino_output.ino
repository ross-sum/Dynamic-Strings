int firstSensor = 0;    // first analog sensor
    const int led            = 13;    // On-board LED light D13.

void setup()
{
  // start serial port at 9600 bps:
  Serial.begin(9600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }

       pinMode(led, OUTPUT);           // initialise on-board LED as output.
  
  establishContact();  // send a byte to establish contact until receiver responds 
  Serial.println("Echoing input");
}

void loop()
{
  // Read in stuff, then write out what we get:
  if (Serial.available() > 0) {
         digitalWrite(led, HIGH);
     char eqChar = Serial.read();
     if (eqChar == '\n') {
       Serial.println(" <<new line>>");
     } else {
       Serial.print(eqChar);
     }
  }
  delay(100);
  digitalWrite(led, LOW);
}

void establishContact() {
  while (Serial.available() <= 0) {
    Serial.print('.');   // send a dot ('.')
    delay(300);
  }
 char response = Serial.read();
 Serial.print('\n');
}

