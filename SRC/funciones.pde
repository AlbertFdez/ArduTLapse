//        FUNCIONES ------------------
//-------------------------------------------------------------------------------------

void debug(){
      lcd.setCursor(0,3);
      lcd.print(SelMenu);            // Escritura del FLAG de SelMenu      DEBUG      
      lcd.setCursor(2,3);
      lcd.print(bot1d);              // Escritura del FLAG del boton 1      DEBUG      
      lcd.print(bot2d);              // Escritura del FLAG del boton 2      DEBUG      
      lcd.print(bot3d);              // Escritura del FLAG del boton 3      DEBUG      
      lcd.print(bot4);              // Escritura del FLAG del boton 4      DEBUG      
      lcd.print(bot5);              // Escritura del FLAG del boton 5      DEBUG
}

void leermcp(int boton){
  lectmcp = IOexp.digitalRead(1,boton);
 }

void escribirmcp(int out,int cont){
  IOexp.digitalWrite(0,out,cont);
}

void progShot(){
  lcd.setCursor(0,2);
  lcd.print("Tiempo ");
  if (horaProg < 10){
  lcd.print("0");  
  lcd.print(horaProg);}
  if (horaProg >= 10){
  lcd.print(horaProg);}
  
  printDigits(minProg);
  printDigits(segProg);
}


void shotsDisplay() {
  lcd.setCursor(0,1);
  lcd.print("Fotos ");
  if (shots <= 10) { 
  lcd.print(shots);
  lcd.print(" "); }  
  if (shots > 10) {
  lcd.print(shots); }
}


void sPaso() {
    
  leermcp(3);
    bot4 = lectmcp;                                        // Siguiente paso  ------------------------------------------
     
    if (bot4 != lastButtonState4) {                        // Si Boton1 difiere de su estado previo       // Rutina DEBOUNCE
    lastDebounceTime = millis(); 
    lastButtonState4 = bot4;      }                        // reset al timer de debounce
    
    if ((millis() - lastDebounceTime) > debounceDelayB) {
    bot4d = bot4; }             
    
    if ((millis() - incdecT) > debounceDelayB1) {
    lastincdec = 1; }
    
    if (bot4d == 0 && bot4d != lastincdec ) {
      SelMenu = SelMenu + 1;
      lastincdec = 0;
      incdecT = millis();} 
  
}

void digitalClockDisplay(){
  // digital clock display of the time
  lcd.setCursor(12,3);
  if (hour() < 10) {
  lcd.print("0");}  
  lcd.print(hour());
  printDigits(minute());
  printDigits(second());
  // lcd.print("  ");
  // lcd.print(day());
  // lcd.print("/");
  // lcd.print(month());
  // lcd.print("/");
  // lcd.print(year()); 
}

void printDigits(int digits){
  // utility function for digital clock display: prints preceding colon and leading 0
  lcd.print(":");
  if(digits < 10)
    lcd.print('0');
  lcd.print(digits);
}

/*  code to process time sync messages from the serial port   */
#define TIME_MSG_LEN  11   // time sync to PC is HEADER followed by unix time_t as ten ascii digits
#define TIME_HEADER  'T'   // Header tag for serial time sync message

time_t processSyncMessage() {
  // return the time if a valid sync message is received on the serial port.
  while(Serial.available() >=  TIME_MSG_LEN ){  // time message consists of a header and ten ascii digits
    char c = Serial.read() ; 
    Serial.print(c);  
    if( c == TIME_HEADER ) {       
      time_t pctime = 0;
      for(int i=0; i < TIME_MSG_LEN -1; i++){   
        c = Serial.read();          
        if( c >= '0' && c <= '9'){   
          pctime = (10 * pctime) + (c - '0') ; // convert digits to a number    
        }
      }   
      return pctime; 
    }  
  }
  return 0;
}
