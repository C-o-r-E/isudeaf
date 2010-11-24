#define DEBUG 1
#include <avr/interrupt.h>
#include <LiquidCrystal.h>
#include <EEPROM.h>

#define C1 11
#define C2 12
#define C3 13
#define C4 A0

#define R1 A1
#define R2 A2
#define R3 A3
#define R4 A4

enum Key {
  k_one,
  k_two,
  k_three,
  k_four, 
  k_five,
  k_six, 
  k_seven, 
  k_eight,
  k_nine,
  k_a,
  k_b,
  k_c,
  k_d,
  k_star,
  k_zero,
  k_octothorpe,
  k_NONE
};

#ifndef DEBUG
  enum Screen {
    s1,
    s2,
    s3,
    s4,
    s5
  };
#else
  enum Screen {
    s1,
    s2,
    s3,
    s4,
    s5,
    s6
  };
#endif

Key lastKey = k_NONE;
Key keyState = k_NONE;

Screen screen;
unsigned char age;
boolean earbuds;
unsigned short frequency;
unsigned short delta;
boolean done;

int cntDataPoints;

volatile int led = HIGH;
LiquidCrystal lcd(0,1,2,3,4,5,6,7,8,A5,10);
void setup()
{
  //get the number of saved data points
  cntDataPoints = EEPROM.read(0); //counter will be stored
  if(cntDataPoints == 0xFF)
    cntDataPoints ^= cntDataPoints;// bootstrap if this is first run

  pinMode(C1, OUTPUT);
  pinMode(C2, OUTPUT);
  pinMode(C3, OUTPUT);
  pinMode(C4, OUTPUT);

  pinMode(R1, INPUT);
  pinMode(R2, INPUT);
  pinMode(R3, INPUT);
  pinMode(R4, INPUT);

  lcd.begin(16,4);

  ////////////////////////////
  // set the 8 bit timer2
  ////////////////////////////
  TCCR2A = 0;//??
  TCCR2B = 0x0D;
  TIMSK2 |= (1 << OCIE2A); //set bit 1 -> enable interupt CTC

  //sei();

  //set Output Compare Register
  //OCR1AH = 0x00;
  OCR2A = 0xFF;
  //0xFF;
  //TIMSK0 |= (1 << CS00) | (1 << CS02);
}

ISR(TIMER2_COMPA_vect) 
{
  ///////////////////////////////
  // Scan Keypad
  //////////////////////////////

  //first check to see if anything is being pressed at all
  digitalWrite(C1, HIGH);
  digitalWrite(C2, HIGH);
  digitalWrite(C3, HIGH);
  digitalWrite(C4, HIGH);
  if(digitalRead(R1) == HIGH || digitalRead(R2) == HIGH || digitalRead(R3) == HIGH || digitalRead(R4) == HIGH)
  {
    //something is being pressed, de-assert all but one line and start scanning
    digitalWrite(C2, LOW);
    digitalWrite(C3, LOW);
    digitalWrite(C4, LOW);
    //also set the old key state
    lastKey = keyState;    
    //digitalWrite(C1, HIGH); // assert column 1
    if(digitalRead(R1) == HIGH)
    {
      keyState = k_one;
    }
    else if(digitalRead(R2) == HIGH)
    {
      keyState = k_two;
    }
    else if(digitalRead(R3) == HIGH)
    {
      keyState = k_three;
    }
    else if(digitalRead(R4) == HIGH)
    {
      keyState = k_a;
    }
    digitalWrite(C1, LOW); // Done with column 1

    digitalWrite(C2, HIGH); // Column 2
    if(digitalRead(R1) == HIGH)
    {
      keyState = k_four;
    }
    else if(digitalRead(R2) == HIGH)
    {
      keyState = k_five;
    }
    else if(digitalRead(R3) == HIGH)
    {
      keyState = k_six;
    }
    else if(digitalRead(R4) == HIGH)
    {
      keyState = k_b;
    }
    digitalWrite(C2, LOW); // done with 2

    digitalWrite(C3, HIGH); // Column 3
    if(digitalRead(R1) == HIGH)
    {
      keyState = k_seven;
    }
    else if(digitalRead(R2) == HIGH)
    {
      keyState = k_eight;
    }
    else if(digitalRead(R3) == HIGH)
    {
      keyState = k_nine;
    }
    else if(digitalRead(R4) == HIGH)
    {
      keyState = k_c;
    }
    digitalWrite(C3, LOW); // done with 3

    digitalWrite(C4, HIGH); // Column 4
    if(digitalRead(R1) == HIGH)
    {
      keyState = k_star;
    }
    else if(digitalRead(R2) == HIGH)
    {
      keyState = k_zero;
    }
    else if(digitalRead(R3) == HIGH)
    {
      keyState = k_octothorpe;
    }
    else if(digitalRead(R4) == HIGH)
    {
      keyState = k_d;
    }
    digitalWrite(C4, LOW); //done with 4
    //delay(75);//debounce
  }
  else
    keyState = k_NONE;  //nothing being pressed
}

void loop()
{
  //initialize some things here instead of in setup()
  //since we come back here after a successful save
  screen = s1; //start on screen1
  age = 0;
  earbuds = false;
  frequency = 10000;
  delta = 500;
  done = false;// we just got started!
  
  //////////////////////////////
  // Screen 1 -- get user age //
  //////////////////////////////
  screen = s1;
  drawScreen1();
  while(screen == s1)
  {
    handleInputScreen1();
  }

  ///////////////////////////////////////
  // Screen 2 -- earbuds or headphones //
  ///////////////////////////////////////
  drawScreen2();
  while(screen == s2)
  {
    handleInputScreen2();
  }

  /**
   *  At this point, we need to enter a state that switches
   *  between states 3,4, and 5
   */
  pwmTone(frequency); //start making annoying sounds
  while(!done)// loop here until we get data from the user
  {
    ////////////////////////////
    // Screen 3 -- Help Menu //
    ///////////////////////////
    drawScreen3();
    while(screen == s3)
    {
      handleInputScreen34();
    }

    ////////////////////////////
    // Screen 4 -- Frequency //
    ///////////////////////////
    drawScreen4();
    while(screen == s4)
    {
      handleInputScreen34();
    }

    //////////////////////////////
    // Screen 5 -- Change Delta //
    //////////////////////////////
    drawScreen5();
    while(screen == s5)
    {
      handleInputScreen5();
    }
  }
  #ifdef DEBUG
    //undocumented secret debug screen
    lcd.clear();
    lcd.print("cnt = ");
    lcd.print(cntDataPoints, DEC);
    lcd.setCursor(0,1);
    lcd.print("last = ");
    lcd.print(EEPROM.read(1+(3*(cntDataPoints-1))), HEX);
    lcd.print(EEPROM.read(2+(3*(cntDataPoints-1))), HEX);
    lcd.print(EEPROM.read(3+(3*(cntDataPoints-1))), HEX);
    while(1);
  #endif
}

void drawScreen1()
{
  lcd.clear();
  lcd.print("Enter Age:");
  lcd.setCursor(-4,2);  //-4 due to a bug in the LCD lib
  lcd.print("Enter--->A");
  lcd.setCursor(-4,3);
  lcd.print("Clear--->D");
  lcd.setCursor(5,1);
  lcd.cursor();
  lcd.blink();
}

void drawScreen2()
{
  lcd.noBlink();
  lcd.noCursor();
  lcd.clear();
  lcd.print("which do you use");
  lcd.setCursor(0,1);
  lcd.print("Headphones->A");
  lcd.setCursor(-4,2);
  lcd.print("Earbuds---->B");  
}

void drawScreen3()
{
  lcd.clear();
  lcd.print("Increase Freq->A"); 
  lcd.setCursor(0, 1);
  lcd.print("Decrease Freq->B"); 
  lcd.setCursor(-4, 2);
  lcd.print("Specify Freq-->C"); 
  lcd.setCursor(-4, 3);
  lcd.print("Continue------>D");
}

void drawScreen4()
{
  lcd.clear();
  int i = frequency - 5000;
  if(i < 1)
    i = 1;
  //make sure we are in the right position
  lcd.setCursor(0,0);
  for(;i>0; i-=1250)
  {
    //we subtracted 1250 so add a block
    lcd.print((char)0xFF);
  }
  lcd.setCursor(6,1);
  if(frequency > 1100)
  {
    lcd.print(frequency/1000, DEC);
    lcd.print(".");
    lcd.print(frequency%1000, DEC);
    lcd.print("KHz");
  }
  else
  {
    lcd.print(frequency, DEC);
    lcd.print("Hz");
  }

  lcd.setCursor(-4,2);
  lcd.print("Inc by:");
  lcd.print(delta, DEC);
  lcd.print("Hz");

  lcd.setCursor(-4,3);
  lcd.print("Help->* Save->#");  
}

void drawScreen5()
{
  lcd.clear();
  lcd.print("Change Freq By:");
  lcd.setCursor(-4,2);
  lcd.print("1:100 2:500 3:1K");
}

inline void handleInputScreen1()
{

  if(lastKey == keyState) //if nothing changed, then do nothing :)
    return;

  if(age > 10)
  {
    //dont take any more digits, assuming nobody we meet will be older that 99
    switch(keyState)
    {
    case k_a:
      screen = s2;
      break;
    case k_d:
      age = 0;
      drawScreen1();
      break;
    }
    return;
  }
  switch(keyState)
  {
  case k_NONE:
    break;
  case k_one:
    lcd.print("1");
    age = (age*10)+1;
    break;
  case k_two:
    lcd.print("2");
    age = (age*10)+2;
    break;
  case k_three:
    lcd.print("3");
    age = (age*10)+3;
    break;
  case k_four:
    lcd.print("4");
    age = (age*10)+4;
    break;
  case k_five:
    lcd.print("5");
    age = (age*10)+5;
    break;
  case k_six:
    lcd.print("6");
    age = (age*10)+6;
    break;
  case k_seven:
    lcd.print("7");
    age = (age*10)+7;
    break;
  case k_eight:
    lcd.print("8");
    age = (age*10)+8;
    break;
  case k_nine:
    lcd.print("9");
    age = (age*10)+9;
    break;
  case k_a:
    screen = s2;
    break;
  case k_d:
    age = 0;
    drawScreen1();
    break;
  default:
    break;//stub
  }
  lastKey = keyState;
}

inline void handleInputScreen2()
{
  if(lastKey == keyState) //if nothing changed, then do nothing :)
    return;
  switch(keyState)
  {
  case k_NONE:
    break;
  case k_a:
    screen = s3;
    break;
  case k_b:
    earbuds = true;
    screen = s3;
    break;
  default:
    break;//stub
  }
  lastKey = keyState;
}

//this one isnt inline as both screen 3 and 4 should just jmp to it
void handleInputScreen34()
{
  if(lastKey == keyState) //if nothing changed, then do nothing :)
    return;
  switch(keyState)
  {
  case k_NONE:
    break;
  case k_a: 
    if(frequency + delta <= 25000) 
    {
      frequency += delta;
      screen = s4;
      //redraw progbar
      drawScreen4();
      //make the new frequency
      pwmTone(frequency);
    }
    break;
  case k_b:
    if(frequency - delta >= 100)
    {
      frequency -= delta;
      screen = s4;
      drawScreen4();
      pwmTone(frequency);
    }
    break;
  case k_c:
    screen = s5;
    break;
  case k_star:
    screen = s3;
    break;
  case k_octothorpe:
    if(screen = s4)
    {
      unsigned char e_data;
      //the first byte
      if(earbuds)
      {
        //set most significant bit for earbuds
        e_data = 128;
      }
      //set lower 7 bits for age
      e_data += age;           
      //write the first byte
      EEPROM.write(1+(3*cntDataPoints), e_data);
      //now write the first freq byte
      e_data = *(unsigned char*)(frequency);
      EEPROM.write(2+(3*cntDataPoints), e_data);
      //now the lower byte
      e_data = *(unsigned char*)(frequency+1);
      EEPROM.write(3+(3*cntDataPoints), e_data);
      //finally update the counter
      cntDataPoints++;
      EEPROM.write(0, cntDataPoints);
      done = true;
      #ifdef DEBUG
        screen = s6;
      #endif
    }
    break;
  default:
    break;//stub
  }
  lastKey = keyState;

}

inline void handleInputScreen5()
{
  if(lastKey == keyState) //if nothing changed, then do nothing :)
    return;
  switch(keyState)
  {
    case k_NONE:
      break;
    case k_one: 
      delta = 100;
      screen = s4;
      break;
    case k_two:
      delta = 500;
      screen = s4;
      break;
    case k_three:
      delta = 1000;
      screen = s4;
      break;
    default:
      break;//stub
  }
  lastKey = keyState;

}

/*
*  So after spending 3 days building rectifiers, Highpass filters,
*  lowpass filters, amplifiers and RC networks to try and eliminate
*  noise, it turned out that the Arduino tone(); function is flawed.
*  It produces a 'fluttering noise' on high frequencies which 
*  directly conflicts with this project. PWM to the rescue!!!
*/
void pwmTone(int _freq)
{
   //assume pwm is not on so set the control registers
   //for Fast PWM with OCR1A as TOP
   DDRB |= _BV(DDB1);
   TCCR1A = _BV(WGM11) | _BV(WGM10) | _BV(COM1A0);
   TCCR1B = _BV(CS10) | _BV(WGM13) | _BV(WGM12);
   OCR1AH = (8000000 / _freq) >> 8;
   OCR1AL = 8000000 / _freq;
}

inline void pwmToneDisable()
{
  TCCR1B = 0;
}
