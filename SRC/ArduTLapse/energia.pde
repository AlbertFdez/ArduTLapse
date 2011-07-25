


void awake () {                                                           // Funcion para despertar a la camara  
  time_t t=now();                                                          // Que hora es? 
  tPas = minute() - minSh;                                               // Tiempo pasado es minuto - minuto ultima foto
  tFal = minSh + minProg;                                                // Tiempo que falta para la proxima foto
  if ((t - utS) == 30  && set == HIGH && awaked == LOW) {                // Si falta un minuto 
      escribirmcp(1,1);                                                   // Ready ON
      delay (800);                                                        // Espero un poco
      escribirmcp(1,0);                                                   // Ready OFF
      awaked = HIGH;                                                      // Flag He despertado a la camara.
                      } 
}
/*
void offBLCD () {                                                         // Funcion para apagar el led del LCD pasado dos minutos
  time_t t=now();
  if ((t - utS = 90) && brillo > 0) {
    for (int p=0; p <=10; p++) [
} 
}
*/      
