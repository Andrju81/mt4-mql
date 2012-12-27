
/**
 * Nach Parameter�nderung
 *
 *  - altes Chartfenster, alter EA, Input-Dialog
 *
 * @return int - Fehlerstatus
 */
int onInitParameterChange() {
   StoreConfiguration();

   if (!ValidateConfiguration(true))
      RestoreConfiguration();

   return(last_error);
}


/**
 * Vorheriger EA von Hand entfernt (Chart->Expert->Remove) oder neuer EA dr�bergeladen
 *
 * - altes Chartfenster, neuer EA, Input-Dialog
 *
 * @return int - Fehlerstatus
 */
int onInitRemove() {
   return(onInitChartClose());                                       // Funktionalit�t entspricht onInitChartClose()
}


/**
 * Nach Symbol- oder Timeframe-Wechsel
 *
 * - altes Chartfenster, alter EA, kein Input-Dialog
 *
 * @return int - Fehlerstatus
 */
int onInitChartChange() {
   // nur die nicht-statischen Input-Parameter restaurieren
   StartConditions = last.StartConditions;

   // TODO: Symbolwechsel behandeln
   return(NO_ERROR);
}


/**
 * Altes Chartfenster mit neu geladenem Template
 *
 * - neuer EA, Input-Dialog, keine Statusdaten im Chart
 *
 * @return int - Fehlerstatus
 */
int onInitChartClose() {
   ValidateConfiguration(true);
   return(last_error);
}


/**
 * Kein UninitializeReason gesetzt
 *
 * - nach Terminal-Neustart:    neues Chartfenster, vorheriger EA, kein Input-Dialog
 * - nach File -> New -> Chart: neues Chartfenster, neuer EA, Input-Dialog
 *
 * @return int - Fehlerstatus
 */
int onInitUndefined() {
   // Pr�fen, ob im Chart Statusdaten existieren (einziger Unterschied zwischen vorherigem/neuem EA)
   if (RestoreStickyStatus())
      return(onInitRecompile());    // ja:   vorheriger EA -> kein Input-Dialog: Funktionalit�t entspricht onInitRecompile()

   if (__STATUS_ERROR)
      return(last_error);

   return(onInitChartClose());      // nein: neuer EA      -> Input-Dialog:      Funktionalit�t entspricht onInitChartClose()
}


/**
 * Nach Recompilation
 *
 * - altes Chartfenster, vorheriger EA, kein Input-Dialog, Statusdaten im Chart
 *
 * @return int - Fehlerstatus
 */
int onInitRecompile() {
   // im Chart gespeicherte Daten restaurieren
   if (RestoreStickyStatus())
      ValidateConfiguration(false);

   ClearStickyStatus();
   return(last_error);
}
