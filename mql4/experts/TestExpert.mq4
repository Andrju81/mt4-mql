/**
 * TestExpert
 */
#include <stdlib.mqh>
#include <win32api.mqh>


/**
 * Initialisierung
 *
 * @return int - Fehlerstatus
 */
int init() {
   if (IsError(onInit(T_EXPERT)))
      return(last_error);

   return(catch("init()"));
}


/**
 * Deinitialisierung
 *
 * @return int - Fehlerstatus
 */
int deinit() {
   return(catch("deinit()"));
}


/**
 * Main-Funktion
 *
 * @return int - Fehlerstatus
 */
int onTick() {
   static bool done = false;
   if (!done) {
      done = true;
   }

   HandleEvent(EVENT_BAR_OPEN);

   return(catch("onTick()"));
}


/**
 *
 * @return int - Fehlerstatus
 */
int onBarOpen(int details[]) {

   debug("onBarOpen("+ Tick +")   details = "+ IntArrayToStr(details, NULL));

   return(catch("onBarOpen()"));
}
