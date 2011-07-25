/*   ArduTLapse is Copyright (C) 2011 Albert J. Fernandez <git@estudiosproamp.com>

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.


    This program uses libraries released under the LGPL, which are listed here.

      LiquidCrystal.h        by the Arduino Team.
      Time.h                 by the Arduino Team.
      Wire.h  		     Copyright (c) 2006 Nicholas Zambetti.
      DS1307RTC.h            by the Arduino Team.
      IOexpander.h           Copyright (c) 2011 Koen Warffemius. www.koenwar.nl

    All this libraries and their license can be found on the Arduino website. http://www.arduino.cc/
    
    You will find a copy of the LGPL in /doc/LGPL.txt or on this wesite: http://www.gnu.org/licenses/lgpl.html

    You will find a copy of the GPL in /doc/GPL.txt or on this website: http://www.gnu.org/licenses/gpl.html

    You will find a how to use in /doc/howto.txt
    
-------------------------------------------------------------------------------------------------------------------------------    
            
                Fecha Inicial 4 - JUL - 2011
                
 La funcion de este codigo es la de un intervalometro, en el que poder automatizar disparos con una camara DSLR mediante
 la interfaz remote. O Automatizar un disparo cuando se detecte un fogonazo de luz con un LDR, superior al valor de un potenciometro.
 
 En la version 0.1.2 Ya estan implementados la lectura de 5 botones que escriben sobre 4 leds mediante librerias
 
--------------------------------------  TODO   ---------------------------------------------------------------

 -  LDR sensor rayos
 -  Configurar hora desde el menu.
 -  El tiempo de READY y DISPARO deberian de ser configurables, y no depender de la funcion delay.

---------------------------------------  VERSIONES   ---------------------------------------------------------
 
-------------------------------------- 0.1.2   /    4 JUL 2011  ----------------------------------------------

  
  -Version inicial procedente de diversas pruebas.
  

--------------------------------------  0.1.3   /   5 JUL 2011  ----------------------------------------------
   
  
   - Creacion rutina de debounce para entrar en el menu   (Anexo A)
   - Uso de un switch para navegacion por menu mediante la rutina SelMenu.
   - Creacion de funcion debug para mostrar en la ultima linea el estado de los pulsadores. 
   - Creacion de algoritmo para cazar nada mas que una pulsacion para saltar de case en el menu.
   
-------------------------------------- 0.1.4   /   11 JUL 2011  ----------------------------------------------

  - Mas limpieza en la entrada al menu.
  - Separacion archivo de funciones.
  - El menu de programacion de disparo ya funciona.
  - Cambio en como se muestra la informacion DEBUG.
  - Todo el sistema de conversion decimal a horario ya funciona.
  
  ------------------------------------ 0.1.5   /  13 JUL 2011  -----------------------------------------------
  
  - Control del brillo del LCD por PWM (Pin 6)
  - Nuevo sistema de seleccion de menu que da cabida a la configuracion del brillo del LCD.
  - Algoritmo de disparo funcional aunque igual un poco arcaico (usa un delay para el tiempo de disparo)
  - Reducido codigo de navegacion por el menu.

---------------------------------------- Anexo A  -----------------------------------------------------------
 
                                                       // Rutina DEBOUNCE
  if (bot3 != lastButtonState3) {                      // Si Boton1 difiere de su estado previo
   lastDebounceTime = millis(); }                      // reset al timer de debounce
  if ((millis() - lastDebounceTime) > debounceDelay) {
   bot3d = bot3; }                                     // Si millis - ultima pulsacion > que el delay 1
   ...
   ...
  lastButtonState1 = bot1;                             // Reset a la funcion
  
  
---------------------- ESCRIBIR EN EL MCP  ---------------------------------------------------------------------

    if (bot1d == 1) {               // Si es 1 el boton no se ha pulsado
    escribirmcp(0,0);              // Asi que pone el led 1 a 0
    }
    

  if (bot1d == 0) {                // Si es 0 el boton se ha pulsado
    escribirmcp(0,1);             // Asi que pone el led 1 a 1
            }
  
  
 
*/

#include <LiquidCrystal.h>
#include <Time.h>  
#include <Wire.h>  
#include <DS1307RTC.h>  // a basic DS1307 library that returns time as a time_t
#include <IOexpander.h> // Libreria MCP23016
//#include <inttypes.h>;  // Necesario para libreria MCP23016 O NO TANTO...
//#include <funciones.pde>

LiquidCrystal lcd(12, 11, 5, 4, 3, 2);

IOexpander IOexp;

//#define shots 0
unsigned int horaProg = 0;              //
unsigned int minProg = 0;
unsigned int segProg = 0;
unsigned int progshots = 0;

int SelMenu = 0;               // Flag de modo de seleccion menu

int buttonState;              // the current reading from the input pin
int lastButtonState1 = 1;   // the previous reading from the input pin
int lastButtonState2 = 1;   // the previous reading from the input pin
int lastButtonState3 = 1;   // the previous reading from the input pin
int lastButtonState4 = 1;
int bot1;
int bot2;
int bot3;
int bot4;
int bot5;
int bot1d = 1;
int bot2d = 1;
int bot3d = 1;
int bot4d = 1;
int bot5d = 1;
int lectmcp = 1;
int extmen = 1;
int lastincdec = 1;
int bLCD = 10;             // Brillo LCD
int delS = 2;            // Tiempo de Ready
int shotsR = 0;          // Disparos realizados
int minSh = 0;                // Minuto en el que se tomo la ultima foto
int tPas = 0;              // Minutos que han pasado desde la ultima foto
int tFal = 0;              // Minutos que faltan para la ultima foto
int utS;                   // Tiempo de programacion en segundos
long shotsT = 500;    // tiempo en millis de disparo

long incdecT;
long TmD;

boolean shotsF = LOW;
boolean prtmF = LOW;
boolean shooting = LOW;
boolean ready = LOW;
boolean set = LOW;
boolean awaked = LOW;                  // FLAG He despertado a la camara?

unsigned int shots = 0;                 // Variable numero de disparos

long lastDebounceTime = 0;              // the last time the output pin was toggled
int debounceDelayM = 90;                // the debounce time; increase if the output flickers  MENU
int debounceDelayB = 50;                //  BOTONES
int debounceDelayB1 = 200;               // Tiempo de incremento / decremento
long SelMenuT = 0;
long tP;


//-----------------------------------------------------------------------------------



void setup()  {
  lcd.begin(20,4);
  Serial.begin(9600);
  IOexp.init(0x20, MCP23016);   // Inicializacion MCP23016
  IOexp.pinModePort(0,OUTPUT);  // 0 Salida
  IOexp.pinModePort(1,INPUT);   // 1 Entrada



  setSyncProvider(RTC.get);   // the function to get the time from the RTC
  setSyncInterval(10);
   
  SelMenu = 0;               //  MODO DIRECTO
  brillolcd(10);            //  LCD 100 %     
   
  escribirmcp(0,0);              // Asi que pone el led 1 a 0 
  escribirmcp(1,0);              // Asi que pone el led 1 a 0
  intro();
}



//---------------------------------------------------------------------------------------------------


void loop()
{
  if(Serial.available())
  {
    time_t t = processSyncMessage();
    if(t >0)
    {
      RTC.set(t);   // set the RTC and the system time to the received value
      setTime(t);          
    }
  }
  
  disparo();              // Rutina disparo 1
  digitalClockDisplay();  // Muestra la hora
  disparo();              // Rutina disparo 2  (Nas precision al poner a 0 el disparo?)
  shotsDisplay();         // Muestra el numero de disparos realizados   
  progShot();             // Muestra el tiempo programado
  disparo();              // Rutina disparo 3  (Nas precision al poner a 0 el disparo?)
  modo();                 // Muestra el modo.
  brillolcd(bLCD);        // Setea brillo LCD
  disparo();              // Rutina disparo 4
  awake();                // Rutina despertar a la camara
  

  
                      // MENU -----------------------------------------
  
  leermcp(0);                      // Lee el boton 1
  bot1 = lectmcp;                  // Intercambio de variables                                    
  if (bot1 != lastButtonState1) {  // Si Boton1 difiere de su estado previo       // Rutina DEBOUNCE
   lastDebounceTime = millis(); 
   lastButtonState1 = bot1;     }  // reset al timer de debounce
 
  if ((millis() - lastDebounceTime) > debounceDelayM) {
   bot1d = bot1; }             // Si millis - ultima pulsacion > que el delay 1
  if (bot1d == 0) {
    SelMenu = 1; }
   
                     
   
    // ---------------------------- MENU de SELECCION --------------------------------------------  
                       
   switch (SelMenu) {
    
     case 1:                                // Si SelMenu 1 SHOTS -------------------------------
    
    set = LOW;                             //  Si entro en el menu no tiro fotos.
                 
    leermcp(1);                             //  INCREMENTAR  ---------------------------------------------------------------
    bot2 = lectmcp;
   
    if (bot2 != lastButtonState2) {                         // Si Boton1 difiere de su estado previo       // Rutina DEBOUNCE
    lastDebounceTime = millis();       
    lastButtonState2 = bot2;      }                         // reset al timer de debounce
    
    if ((millis() - lastDebounceTime) > debounceDelayB) {
    bot2d = bot2;} 
                                                
    if ((millis() - incdecT) > debounceDelayB1) {
    lastincdec = 1;}  
   
    if (bot2d == 0 && bot2d != lastincdec) {
    shots = shots + 1; 
    lastincdec = 0;    
    incdecT = millis(); }
    
   
   
    leermcp(2);                              //  DECREMENTAR  ------------------------------------------------------------------
    bot3 = lectmcp;
    
    if (bot3 != lastButtonState3) {                        // Si Boton1 difiere de su estado previo       // Rutina DEBOUNCE
    lastDebounceTime = millis(); 
    lastButtonState3 = bot3;      }                        // reset al timer de debounce
    
    if ((millis() - lastDebounceTime) > debounceDelayB) {
    bot3d = bot3; }             
    
    if ((millis() - incdecT) > debounceDelayB1) {
      lastincdec = 1; }
    
    if (bot3d == 0 && bot3d != lastincdec && shots != 0) {
      shots = shots - 1;
      lastincdec = 0;
      incdecT = millis();}
     
   sPaso();
                
    break;

     case 2:                            // Si SelMenu 2 Segundos  ------------------------------------------------------
    

    leermcp(1);                             //  INCREMENTAR  -----------------------------------------------------------
    bot2 = lectmcp;
   
    if (bot2 != lastButtonState2) {                         // Si Boton1 difiere de su estado previo       // Rutina DEBOUNCE
    lastDebounceTime = millis();       
    lastButtonState2 = bot2;      }                         // reset al timer de debounce
    
    if ((millis() - lastDebounceTime) > debounceDelayB) {
    bot2d = bot2;} 
                                                
    if ((millis() - incdecT) > debounceDelayB1) {
    lastincdec = 1;}  
   
    if (bot2d == 0 && bot2d != lastincdec) {
    ++segProg; 
    lastincdec = 0;    
    incdecT = millis(); }



 
    
    leermcp(2);                                            //  DECREMENTAR ---------------------------------------------
    bot3 = lectmcp; 
    
    if (bot3 != lastButtonState3) {                        // Si Boton1 difiere de su estado previo       // Rutina DEBOUNCE
    lastDebounceTime = millis(); 
    lastButtonState3 = bot3;      }                        // reset al timer de debounce
    
    if ((millis() - lastDebounceTime) > debounceDelayB) {
    bot3d = bot3; }             
    
    if ((millis() - incdecT) > debounceDelayB1) {
      lastincdec = 1; }
    
    if (bot3d == 0 && bot3d != lastincdec && segProg != 0) {
      --segProg;
      lastincdec = 0;
      incdecT = millis();}
    
    if (segProg > 59) {
    minProg = minProg + 1;
    segProg = 0; }
    
  sPaso();
  
    break;
    
     case 3:                          // Si SelMenu 3 minutos -------------------------------------------------------------------
   
    leermcp(1);                             //  INCREMENTAR  -----------------------------------------------------------
    bot2 = lectmcp;
   
    if (bot2 != lastButtonState2) {                         // Si Boton1 difiere de su estado previo       // Rutina DEBOUNCE
    lastDebounceTime = millis();       
    lastButtonState2 = bot2;      }                         // reset al timer de debounce
    
    if ((millis() - lastDebounceTime) > debounceDelayB) {
    bot2d = bot2;} 
                                                
    if ((millis() - incdecT) > debounceDelayB1) {
    lastincdec = 1;}  
   
    if (bot2d == 0 && bot2d != lastincdec) {
    ++minProg; 
    lastincdec = 0;    
    incdecT = millis(); }



 
    
    leermcp(2);                                            //  DECREMENTAR ---------------------------------------------
    bot3 = lectmcp; 
    
    if (bot3 != lastButtonState3) {                        // Si Boton1 difiere de su estado previo       // Rutina DEBOUNCE
    lastDebounceTime = millis(); 
    lastButtonState3 = bot3;      }                        // reset al timer de debounce
    
    if ((millis() - lastDebounceTime) > debounceDelayB) {
    bot3d = bot3; }             
    
    if ((millis() - incdecT) > debounceDelayB1) {
      lastincdec = 1; }
    
    if (bot3d == 0 && bot3d != lastincdec && minProg != 0) {
      --minProg;
      lastincdec = 0;
      incdecT = millis();}
    
    if (minProg > 59) {
    horaProg = horaProg + 1;
    minProg = 0; }
    
    sPaso();
  
    break;
  
     case 4:                          // Se SelMenu 4 HORAS --------------------------------    
     
       leermcp(1);                             //  INCREMENTAR  -----------------------------------------------------------
    bot2 = lectmcp;
   
    if (bot2 != lastButtonState2) {                         // Si Boton1 difiere de su estado previo       // Rutina DEBOUNCE
    lastDebounceTime = millis();       
    lastButtonState2 = bot2;      }                         // reset al timer de debounce
    
    if ((millis() - lastDebounceTime) > debounceDelayB) {
    bot2d = bot2;} 
                                                
    if ((millis() - incdecT) > debounceDelayB1) {
    lastincdec = 1;}  
   
    if (bot2d == 0 && bot2d != lastincdec && horaProg < 24) {
    ++horaProg; 
    lastincdec = 0;    
    incdecT = millis(); }



 
    
    leermcp(2);                                            //  DECREMENTAR ---------------------------------------------
    bot3 = lectmcp; 
    
    if (bot3 != lastButtonState3) {                        // Si Boton1 difiere de su estado previo       // Rutina DEBOUNCE
    lastDebounceTime = millis(); 
    lastButtonState3 = bot3;      }                        // reset al timer de debounce
    
    if ((millis() - lastDebounceTime) > debounceDelayB) {
    bot3d = bot3; }             
    
    if ((millis() - incdecT) > debounceDelayB1) {
      lastincdec = 1; }
    
    if (bot3d == 0 && bot3d != lastincdec && horaProg != 0) {
      --horaProg;
      lastincdec = 0;
      incdecT = millis();}
    
    
    sPaso();
  
     break;
    
    case 5:              //   --------------------  BRILLO LCD -------------------------------------------                   
    
    leermcp(1);                             //  INCREMENTAR  -----------------------------------------------------------
    bot2 = lectmcp;
   
    if (bot2 != lastButtonState2) {                         // Si Boton1 difiere de su estado previo       // Rutina DEBOUNCE
    lastDebounceTime = millis();       
    lastButtonState2 = bot2;      }                         // reset al timer de debounce
    
    if ((millis() - lastDebounceTime) > debounceDelayB) {
    bot2d = bot2;} 
                                                
    if ((millis() - incdecT) > debounceDelayB1) {
    lastincdec = 1;}  
   
    if (bot2d == 0 && bot2d != lastincdec && bLCD < 10) {
    bLCD = bLCD +1;
    
    lastincdec = 0;    
    incdecT = millis(); }



 
    
    leermcp(2);                                            //  DECREMENTAR ---------------------------------------------
    bot3 = lectmcp; 
    
    if (bot3 != lastButtonState3) {                        // Si Boton1 difiere de su estado previo       // Rutina DEBOUNCE
    lastDebounceTime = millis(); 
    lastButtonState3 = bot3;      }                        // reset al timer de debounce
    
    if ((millis() - lastDebounceTime) > debounceDelayB) {
    bot3d = bot3; }             
    
    if ((millis() - incdecT) > debounceDelayB1) {
      lastincdec = 1; }
    
    if (bot3d == 0 && bot3d != lastincdec && bLCD >= 0) {
      bLCD = bLCD - 1;
      lastincdec = 0;
      incdecT = millis();}
      
    sPaso();
  
    break;
    
    
     
     case 6:                          // Si SelMenu 6 Salir 
  
     leermcp(4);               
     extmen = lectmcp;      
     if (extmen == 0) {
     SelMenu = 0;
     lcd.clear();
     time_t t = now();
     tP = t;
     shotsR = 0;
     minSh = minute();                                                   // Flag para poder despertar a la camara    
     if (shots > 1 && segProg >= 1 || minProg >= 1 || horaProg >= 1) {
      set = HIGH;  } 
     break;                 }                   
    
     
                        }            //switch                        
                       }            //loop
 

