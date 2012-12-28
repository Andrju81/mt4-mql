
/**
 * Parameter�nderung
 *
 * @return int - Fehlerstatus
 */
int onDeinitParameterChange() {
   // nicht-statische Input-Parameter f�r Vergleich mit neuen Werten zwischenspeichern
   last.StartConditions = StringConcatenate(StartConditions, "");    // Pointer-Bug bei String-Inputvariablen (siehe MQL.doc)
   return(-1);
}


/**
 * EA von Hand entfernt (Chart -> Expert -> Remove) oder neuer EA dr�bergeladen
 *
 * @return int - Fehlerstatus
 */
int onDeinitRemove() {
   return(last_error);
}


/**
 * Symbol- oder Timeframewechsel
 *
 * @return int - Fehlerstatus
 */
int onDeinitChartChange() {
   // nicht-statische Input-Parameter zwischenspeichern
   return(onDeinitParameterChange());                                // entspricht onDeinitParameterChange()
}


/**
 * - Chart geschlossen                       -oder-
 * - Template wird neu geladen               -oder-
 * - Terminal-Shutdown                       -oder-
 * - im Tester nach Bet�tigen des "Stop"-Buttons oder nach Chart->Close
 *
 * @return int - Fehlerstatus
 *
 *
 * NOTE: Der "Stop"-Button des Testers kann vom Code "bet�tigt" worden sein (nach Fehler oder Testabschlu�).
 */
int onDeinitChartClose() {
   // (1) Im Tester
   if (IsTesting()) {
      __STATUS_CANCELLED = true;
      return(last_error);
   }

   // (2) Nicht im Tester
   StoreStickyStatus();                                              // f�r Terminal-Restart oder Profile-Wechsel
   return(last_error);
}


/**
 * Kein UninitializeReason gesetzt: im Tester nach regul�rem Ende (Testperiode zu Ende)
 *
 * @return int - Fehlerstatus
 */
int onDeinitUndefined() {
   if (IsTesting()) {
      if (__STATUS_CANCELLED)
         return(onDeinitChartClose());                               // entspricht gewaltsamen Ende
      return(last_error);
   }
   return(catch("onDeinitUndefined()", ERR_RUNTIME_ERROR));          // mal schaun, wer hier wann reintappt
}


/**
 * Recompilation
 *
 * @return int - Fehlerstatus
 */
int onDeinitRecompile() {
   StoreStickyStatus();
   return(-1);
}
