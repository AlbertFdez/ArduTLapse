void disparo() {
  utS = (segProg + (minProg * 60) + (horaProg * 60 * 60)); 

  time_t t = now();
    
  if ((tP + utS) - delS <= t && shots > 0 && ready == LOW && set == HIGH) {    //------------------------------------    READY

    escribirmcp(1,1);                          // Ready ON
    escribirmcp(2,1);                          // LED READY
    ready = HIGH;
    lcd.setCursor(0,3);
    lcd.print("READY");                     
  }

  if ((tP + utS) == t && shots > 0 && shooting == LOW && ready == HIGH) {    //   ---------------------------------------    DISPARO

    escribirmcp(0,1);                        // Disparo ON
    escribirmcp(3,1);                        // LED DISPARO
    shooting = HIGH;

    TmD = millis(); 

    lcd.setCursor(0,3);
    lcd.print("SHOOT");
  }

  if ((TmD + shotsT) <= millis() && shooting == HIGH && ready == HIGH) {

    escribirmcp(0,0);                      // Disparo OFF
    escribirmcp(3,0);                      // LED DISPARO
    escribirmcp(1,0);                      // Ready OFF
    escribirmcp(2,0);                      // LED READY
    time_t t = now();
    tP = t;
    -- shots;
    ++ shotsR;
    shooting = LOW;                        // Flag de disparo OFF   
    ready = LOW;                           // Flag de Listo OFF
    minSh = minute();                      // Minuto de la ultima foto tomada. 
    awaked = LOW;                          // Libero el flag para poder despertar a la camara
    
    if (shots == 0) {
      set = LOW; 
    }  

    lcd.setCursor(0,3);
    lcd.print("     ");   
  }


}


