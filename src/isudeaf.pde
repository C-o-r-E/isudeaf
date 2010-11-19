#include <LiquidCrystal.h>

#define C1 11
#define C2 12
#define C3 13
#define C4 A0

#define R1 A1
#define R2 A2
#define R3 A3
#define R4 A4

LiquidCrystal lcd(0,1,2,3,4,5,6,7,8,9,10);

void setup()
{
  pinMode(C1, OUTPUT);
  pinMode(C2, OUTPUT);
  pinMode(C3, OUTPUT);
  pinMode(C4, OUTPUT);
  
  pinMode(R1, INPUT);
  pinMode(R2, INPUT);
  pinMode(R3, INPUT);
  pinMode(R4, INPUT);
  
  lcd.begin(16,4);
  
  lcd.print("Derp");
}

void loop()
{
  //scanning time
  digitalWrite(C1, HIGH); // voltage to column 1
  if(digitalRead(R1) == HIGH)
  {
    lcd.clear();
    lcd.print("ONE");
  }
  else if(digitalRead(R2) == HIGH)
  {
    lcd.clear();
    lcd.print("TWO");
  }
  else if(digitalRead(R3) == HIGH)
  {
    lcd.clear();
    lcd.print("THREE");
  }
  else if(digitalRead(R4) == HIGH)
  {
    lcd.clear();
    lcd.print("A");
  }
  digitalWrite(C1, LOW); // Done with column 1
  delay(100);
  digitalWrite(C2, HIGH); // Column 2
  if(digitalRead(R1) == HIGH)
  {
    lcd.clear();
    lcd.print("FOUR");
  }
  else if(digitalRead(R2) == HIGH)
  {
    lcd.clear();
    lcd.print("FIVE");
  }
  else if(digitalRead(R3) == HIGH)
  {
    lcd.clear();
    lcd.print("SIX");
  }
  else if(digitalRead(R4) == HIGH)
  {
    lcd.clear();
    lcd.print("B");
  }
  digitalWrite(C2, LOW);
  
  digitalWrite(C3, HIGH); // Column 3
  if(digitalRead(R1) == HIGH)
  {
    lcd.clear();
    lcd.print("SEVEN");
  }
  else if(digitalRead(R2) == HIGH)
  {
    lcd.clear();
    lcd.print("EIGHT");
  }
  else if(digitalRead(R3) == HIGH)
  {
    lcd.clear();
    lcd.print("NINE");
  }
  else if(digitalRead(R4) == HIGH)
  {
    lcd.clear();
    lcd.print("C");
  }
  digitalWrite(C3, LOW);
  
  delay(100);
  
digitalWrite(C4, HIGH); // Column 4
  if(digitalRead(R1) == HIGH)
  {
    lcd.clear();
    lcd.print("STAR");
  }
  else if(digitalRead(R2) == HIGH)
  {
    lcd.clear();
    lcd.print("ZERO");
  }
  else if(digitalRead(R3) == HIGH)
  {
    lcd.clear();
    lcd.print("OCTOTHORP");
  }
  else if(digitalRead(R4) == HIGH)
  {
    lcd.clear();
    lcd.print("D");
  }
  digitalWrite(C4, LOW);
  
  delay(100);
}



