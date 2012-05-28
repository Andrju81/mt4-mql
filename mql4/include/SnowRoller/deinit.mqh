
/**
 * Kein UninitializeReason gesetzt: im Tester nach regul�rem Ende (Testperiode zu Ende)
 *
 * @return int - Fehlerstatus
 */
int onDeinitUndefined() {
   if (IsTesting()) {
      if (status==STATUS_WAITING || status==STATUS_PROGRESSING)
         if (StopSequence())                                         // ruft intern UpdateStatus() und SaveStatus() auf
            ShowStatus();
      return(last_error);
   }
   return(catch("onDeinitUndefined()", ERR_RUNTIME_ERROR));          // mal schaun, wann hier jemand reinlatscht
}


/**
 * - Chart geschlossen
 * - Template wird neu geladen
 * - im Tester nach vorzeitigem, manuellem Abbruch
 * - Terminal-Shutdown
 *
 * @return int - Fehlerstatus
 */
int onDeinitChartClose() {
   if (IsTesting()) {
      //debug("onDeinitChartClose()   "+ StatusToStr(status));
      if (status==STATUS_WAITING || status==STATUS_PROGRESSING)      // TODO: !!! statt StopSequence() Statusfile l�schen und Titelzeile des Testers zur�cksetzen
         if (StopSequence())                                         // ruft intern UpdateStatus() und SaveStatus() auf
            ShowStatus();
      return(last_error);
   }

   // der Status kann sich seit dem letzten Tick ge�ndert haben
   if (status==STATUS_WAITING || status==STATUS_PROGRESSING || status==STATUS_STOPPING) {
      UpdateStatus();
      SaveStatus();
   }
   StoreTransientStatus();                                           // f�r evt. Terminal-Restart
   return(last_error);
}


/**
 * EA von Hand entfernt (Chart ->Expert ->Remove)
 *
 * @return int - Fehlerstatus
 */
int onDeinitRemove() {
   // der Status kann sich seit dem letzten Tick ge�ndert haben
   if (status==STATUS_WAITING || status==STATUS_PROGRESSING || status==STATUS_STOPPING) {
      UpdateStatus();
      SaveStatus();
   }
   return(last_error);
}


/**
 *
 * @return int - Fehlerstatus
 */
int onDeinitRecompile() {
   StoreTransientStatus();
   return(-1);
}


/**
 *
 * @return int - Fehlerstatus
 */
int onDeinitParameterChange() {
   // alte Parameter f�r Vergleich mit neuen Parametern zwischenspeichern
   last.Sequence.ID      = StringConcatenate(Sequence.ID,      "");
   last.GridDirection    = StringConcatenate(GridDirection,    "");  // Pointer-Bug bei String-Inputvariablen (siehe MQL.doc)
   last.GridSize         = GridSize;
   last.LotSize          = LotSize;
   last.StartConditions  = StringConcatenate(StartConditions,  "");
   last.StopConditions   = StringConcatenate(StopConditions,   "");
   last.OrderDisplayMode = StringConcatenate(OrderDisplayMode, "");
   last.Breakeven.Color  = Breakeven.Color;
   last.Breakeven.Width  = Breakeven.Width;
   return(-1);

}


/**
 * Symbol- oder Timeframewechsel
 *
 * @return int - Fehlerstatus
 */
int onDeinitChartChange() {
   // nicht-statische Input-Parameter werden f�r's n�chste init() zwischengespeichert
   return(onDeinitParameterChange());                                // Funktionalit�t entspricht onDeinitParameterChange()
}
