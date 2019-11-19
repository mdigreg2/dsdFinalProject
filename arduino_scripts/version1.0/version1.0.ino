
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
