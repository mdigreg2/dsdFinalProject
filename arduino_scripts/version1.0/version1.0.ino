//void setup() {
//  // initialize serial communication at 9600 bits per second:
//  Serial.begin(9600);
//  pinMode(4, INPUT);
//}
//
//// the loop routine runs over and over again forever:
//void loop() {
//  // read the input on analog pin 0:
//  int sensorValue = analogRead(A4);
//  // Convert the analog reading (which goes from 0 - 1023) to a voltage (0 - 5V):
//  float voltage = sensorValue * (5.0 / 1023.0);
//  // print out the value you read:
//  Serial.println(voltage);
//  int val = digitalRead(4);
//  Serial.println(val);
//    //Serial.println("high");
//
//}



void setup(){
  Serial.begin(9600);
  pinMode(3, INPUT);
  pinMode(4, INPUT);
  pinMode(5, INPUT);
  pinMode(6, INPUT);

  //pinMode(13, OUTPUT);
}

void loop(){
  int pin3 = digitalRead(3);
  int pin4 = digitalRead(4);
  int pin5 = digitalRead(5);
  int pin6 = digitalRead(6);

  digitalWrite(13, HIGH);

  if (pin3 > .5){
    Serial.println("Pin 3 High");
  }

  if (pin4 > .5){
    Serial.println("Pin 4 High");
  }

  if (pin5 > .5){
    Serial.println("Pin 5 High");
  }

  if (pin6 > .5){
    Serial.println("Pin 6 High");
  }

  
}
////This code will send a series of binary signals to the FPGA depending 
//
//#define in1 2
//#define in2 3
//#define in3 4
//#define in4 5
//
//#define out1 9
//#define out2 10
//#define out3 11
//#define out4 12
//void setup() {
//  // set pins 5 to 2 as input pins
//  Serial.begin(9600);
//  Serial.println("Running");
////  pinMode(A4, INPUT);
////  pinMode(in4, INPUT);
////  pinMode(in3, INPUT);
////  pinMode(in2, INPUT);
////  pinMode(in1, INPUT);
////
////  pinMode(13, OUTPUT);
////  pinMode(out4, OUTPUT);
////  pinMode(out3, OUTPUT); 
////  pinMode(out2, OUTPUT);
////  pinMode(out1, OUTPUT);
//}
//
//void loop() {
//
//  int sensorValue = analogRead(A4);
//  float voltage = sensorValue * (5/1023);
//  Serial.println(voltage);
//  
//
////  
////  
////    digitalWrite(13, HIGH);
////    if(in1 == HIGH){
////      digitalWrite(out1, HIGH);
////      Serial.println("in1 is high");
////    }
////    if(in2 == HIGH){
////      digitalWrite(out2, HIGH);
////      Serial.println("in2 is high");
////    }
////    if(in3 == HIGH){
////      digitalWrite(out3, HIGH);
////      Serial.println("in3 is high");
////    }
////    if(in4 == HIGH){
////      digitalWrite(out4, HIGH);
////      Serial.println("in4 is high");
////    }
////
////    
////    if(in1 == LOW){
////      digitalWrite(out1, LOW);
////      Serial.println("out1 is low");
////    }
////    if(in2 == LOW){
////      digitalWrite(out2, LOW);
////      Serial.println("out2 is low");
////    }
////    if(in3 == LOW){
////      digitalWrite(out3, LOW);
////      Serial.println("out3 is low");
////    }
////    if(in4 == LOW){
////      digitalWrite(out4, LOW);
////      Serial.println("out4 is low");
////    }
//    
//  
//
//}
