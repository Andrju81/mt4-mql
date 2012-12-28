
/**
 * Ermittelt ID und Status der im aktuellen Chart gemanagten Sequenzen.
 *
 * @param  string ids[]    - Array zur Aufnahme der gefundenen Sequenz-ID's
 * @param  int    status[] - Array zur Aufnahme der gefundenen Sequenz-Statuswerte
 *
 * @return bool - ob mindestens eine aktive Sequenz gefunden wurde
 */
bool FindChartSequences(string ids[], int status[]) {
   ArrayResize(ids,    0);
   ArrayResize(status, 0);

   string label = "SnowRoller.status";

   if (ObjectFind(label) == 0) {
      string values[], data[], strValue, text=StringToUpper(StringTrim(ObjectDescription(label)));
      int sizeOfValues = Explode(text, ",", values, NULL);

      for (int i=0; i < sizeOfValues; i++) {
         if (Explode(values[i], "|", data, NULL) != 2) return(_false(catch("FindChartSequences(1)   illegal chart label "+ label +" = \""+ ObjectDescription(label) +"\"", ERR_RUNTIME_ERROR)));

         // Sequenz-ID
         strValue  = StringTrim(data[0]);
         bool test = false;
         if (StringLeft(strValue, 1) == "T") {
            test     = true;
            strValue = StringRight(strValue, -1);
         }
         if (!StringIsDigit(strValue))                 return(_false(catch("FindChartSequences(2)   illegal sequence id in chart label "+ label +" = \""+ ObjectDescription(label) +"\"", ERR_RUNTIME_ERROR)));
         int iValue = StrToInteger(strValue);
         if (iValue == 0)
            continue;
         string strSequenceId = ifString(test, "T", "") + iValue;

         // Sequenz-Status
         strValue = StringTrim(data[1]);
         if (!StringIsDigit(strValue))                 return(_false(catch("FindChartSequences(3)   illegal sequence status in chart label "+ label +" = \""+ ObjectDescription(label) +"\"", ERR_RUNTIME_ERROR)));
         iValue = StrToInteger(strValue);
         if (!IsSequenceStatus(iValue))                return(_false(catch("FindChartSequences(4)   illegal sequence status in chart label "+ label +" = \""+ ObjectDescription(label) +"\"", ERR_RUNTIME_ERROR)));
         int sequenceStatus = iValue;

         ArrayPushString(ids,    strSequenceId );
         ArrayPushInt   (status, sequenceStatus);
         //debug("FindChartSequences()   "+ label +" = "+ strSequenceId +"|"+ sequenceStatus);
      }
   }
   return(ArraySize(ids));                                           // (bool) int
}


/**
 * Ob ein Wert einen g�ltigen Sequenzstatus-Code darstellt.
 *
 * @param  int value
 *
 * @return bool
 */
bool IsSequenceStatus(int value) {
   switch (value) {
      case STATUS_UNINITIALIZED: return(true);
      case STATUS_WAITING      : return(true);
      case STATUS_STARTING     : return(true);
      case STATUS_PROGRESSING  : return(true);
      case STATUS_STOPPING     : return(true);
      case STATUS_STOPPED      : return(true);
   }
   return(false);
}


/**
 * BarOpen-Eventhandler zur Erkennung von MA-Trendwechseln.
 *
 * @param  int    timeframe   - zu verwendender Timeframe
 * @param  string maPeriods   - Indikator-Parameter
 * @param  string maTimeframe - Indikator-Parameter
 * @param  string maMethod    - Indikator-Parameter
 * @param  int    lag         - Trigger-Verz�gerung, gr��er oder gleich 0
 * @param  int    directions  - Kombination von Trend-Identifiern:
 *                              MODE_UPTREND   - ein Wechsel zum Up-Trend soll signalisiert werden
 *                              MODE_DOWNTREND - ein Wechsel zum Down-Trend soll signalisiert werden
 * @param  int    lpSignal    - Zeiger auf Variable zur Signalaufnahme (+: Wechsel zum Up-Trend, -: Wechsel zum Down-Trend)
 *
 * @return bool - Erfolgsstatus (nicht, ob ein Signal aufgetreten ist)
 *
 *
 *  TODO: 1) refaktorieren und auslagern
 *        2) Die Funktion k�nnte den Indikator selbst berechnen und nur bei abweichender Periode auf iCustom() zur�ckgreifen.
 */
bool CheckTrendChange(int timeframe, string maPeriods, string maTimeframe, string maMethod, int lag, int directions, int &lpSignal) {
   if (lag < 0)
      return(!catch("CheckTrendChange(1)   illegal parameter lag = "+ lag, ERR_INVALID_FUNCTION_PARAMVALUE));

   bool detectUp   = _bool(directions & MODE_UPTREND  );
   bool detectDown = _bool(directions & MODE_DOWNTREND);


   //[2788] MetaTrader::EURUSD,H1::SnowRoller.Strategy::CheckTrendChange()   2012.11.20 11:00   trend change down

   // (1) Trend der letzten Bars ermitteln                                       // +-----+------+
   int error, /*ICUSTOM*/ic[]; if (!ArraySize(ic)) InitializeICustom(ic, NULL);  // | lag | bars |
   ic[IC_LAST_ERROR] = NO_ERROR;                                                 // +-----+------+
                                                                                 // |  0  |   4  | - Erkennung onBarOpen der neuen Bar (neuer Trend 1 Periode lang, fr�hester Zeitpunkt)
   int    barTrend, trend, counterTrend;                                         // |  1  |  12  | - Erkennung onBarOpen der n�chsten Bar (neuer Trend 2 Perioden lang)
   string strTrend, changePattern;                                               // |  2  |  20  | - Erkennung onBarOpen der �bern�chsten Bar (neuer Trend 3 Perioden lang)
   int    bars = 4 + 8*lag;                                                      // +-----+------+

   for (int bar=bars-1; bar>0; bar--) {                        // Bar 0 ist immer unvollst�ndig und wird nicht ben�tigt
      // (1.1) Trend der einzelnen Bar bestimmen
      barTrend = iCustom(NULL, timeframe, "Moving Average",    // (int) double ohne Pr�zisionsfehler (siehe MA-Implementierung)
                         maPeriods,                            // MA.Periods
                         maTimeframe,                          // MA.Timeframe
                         maMethod,                             // MA.Method
                         "",                                   // MA.Method.Help
                         "Close",                              // AppliedPrice
                         "",                                   // AppliedPrice.Help
                         Max(bars+1, 20),                      // Max.Values: +1 wegen fehlendem Trend der �ltesten Bar; mind. 20 (lag=2) zur Reduktion ansonsten identischer
                         ForestGreen,                          // Color.UpTrend                                        | Indikator-Instanzen (mit oder ohne Lag)
                         Red,                                  // Color.DownTrend
                         "",                                   // _________________
                         ic[IC_PTR],                           // __iCustom__
                         BUFFER_2, bar); //throws ERS_HISTORY_UPDATE, ERR_TIMEFRAME_NOT_AVAILABLE

      error = GetLastError();
      if (IsError(error)) /*&&*/ if (error!=ERS_HISTORY_UPDATE)
         return(_false(catch("CheckTrendChange(2)", error)));
      if (IsError(ic[IC_LAST_ERROR]))
         return(_false(SetLastError(ic[IC_LAST_ERROR])));
      if (!barTrend)
         return(_false(catch("CheckTrendChange(3)->iCustom(Moving Average)   invalid trend for bar="+ bar +": "+ barTrend, ERR_CUSTOM_INDICATOR_ERROR)));
      if (barTrend > 0) barTrend =  1;
      else              barTrend = -1;

      // (1.2) vorherrschenden Trend bestimmen
      if (bar == bars-1) {
         trend = barTrend;                                     // Initialisierung
      }
      else if (bar > 1) {
         if (barTrend == trend) {
            counterTrend = 0;
         }
         else {
            counterTrend++;
            if (counterTrend > lag) {
               trend        = -Sign(trend);
               counterTrend = 0;
            }
         }
      }
      strTrend = StringConcatenate(strTrend, ifString(barTrend>0, "+", "-"));
   }
   if (error == ERS_HISTORY_UPDATE)
      debug("CheckTrendChange()   ERS_HISTORY_UPDATE");        // TODO: bei ERS_HISTORY_UPDATE die zur Berechnung verwendeten Bars pr�fen


   lpSignal = 0;

   // (2) Trendwechsel detektieren
   if (trend < 0) {
      if (detectUp) {
         changePattern = "-"+ StringRepeat("+", lag+1);        // up change "-++" f�r lag=1
         if (StringEndsWith(strTrend, changePattern)) {        // Trendwechsel im Down-Trend
            lpSignal = 1;
            //debug("CheckTrendChange()   "+ TimeToStr(TimeCurrent()) +"   trend change up");
         }
      }
   }
   else if (trend > 0) {
      if (detectDown) {
         changePattern = "+"+ StringRepeat("-", lag+1);        // down change "+--" f�r lag=1
         if (StringEndsWith(strTrend, changePattern)) {        // Trendwechsel im Up-Trend
            lpSignal = -1;
            //debug("CheckTrendChange()   "+ TimeToStr(TimeCurrent()) +"   trend change down");
         }
      }
   }
   return(!catch("CheckTrendChange(4)"));
}
