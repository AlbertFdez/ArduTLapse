void intro(){
  lcd.setCursor(0,3);
  lcd.print("INTERVALOMETRO");
  delay (500);
  
  lcd.setCursor(0,2);
  lcd.print("INTERVALOMETRO");
  lcd.setCursor(0,3);
  lcd.print("FOTOGRAFICO 0.1.4");
  delay (500);
  
  lcd.setCursor(0,1);
  lcd.print("INTERVALOMETRO");
  lcd.setCursor(1,2);
  lcd.print("FOTOGRAFICO 0.1.4");
  lcd.setCursor(0,3);
  lcd.print("COPYRIGHT         ");
  delay (500);
  
  lcd.setCursor(0,0);
  lcd.print("INTERVALOMETRO");
  lcd.setCursor(0,1);
  lcd.print("FOTOGRAFICO 0.1.6_I");
  lcd.setCursor(0,2);
  lcd.print("COPYRIGHT         ");
  lcd.setCursor(0,3);
  lcd.print("Albert J. Fdez. 2011");
  delay (2500);
  lcd.clear();
}

void modo(){
  if (SelMenu == 0) {
  lcd.setCursor(0,0);    
  lcd.print("Modo directo");}
  if (SelMenu == 1) {
  lcd.setCursor(0,0);
  lcd.print("PROG. DISPAROS     ");}
  if (SelMenu == 2) {
  lcd.setCursor(0,0);
  lcd.print("PROG. SEGUNDOS");}
  if (SelMenu == 3) {
  lcd.setCursor(0,0);
  lcd.print("PROG. MINUTOS ");}
  if (SelMenu == 4) {
  lcd.setCursor(0,0);
  lcd.print("PROG. HORAS   ");}
  
  if (SelMenu == 5) {
  lcd.setCursor(0,0);
  lcd.print("ADJ BRILLO LCD "); 
  if (bLCD < 10) {
  lcd.print(bLCD);
  lcd.print(" ");}
  else           {
   lcd.print(bLCD);} 
                    } 
   
  if (SelMenu == 6) {
  lcd.setCursor(0,0);
  lcd.print("PULSA 5 PARA SALIR");}
   
  lcd.setCursor(10,1);
  lcd.print("Fot. R ");
  lcd.print(shotsR); 
}
void brillolcd(int brillo){
  int brilloM = map(brillo,0,10,0,255);
  analogWrite(6, brilloM);
}
