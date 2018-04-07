/**
 * Lebaneese H4 trend system
 *
 * @see  https://www.forexfactory.com/showthread.php?p=9307192#post9307192
 */
#include <stddefine.mqh>
int   __INIT_FLAGS__[];
int __DEINIT_FLAGS__[];

////////////////////////////////////////////////////// Configuration ////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#include <core/expert.mqh>
#include <stdfunctions.mqh>
#include <stdlibs.mqh>
#include <functions/EventListener.BarOpen.mqh>
#include <iCustom/icNonLagMA.mqh>


double maxBarSize;

// OrderSend() defaults
string os.name        = "LH4";
int    os.magicNumber = 43210;


/**
 * Main function
 *
 * @return int - error status
 */
int onTick() {
   if (EventListener.BarOpen(PERIOD_H4)) {
      CheckOpenSignal();
   }
   return(last_error);
}


/**
 * Check for and handle entry conditions.
 *
 * @return bool - success status
 */
bool CheckOpenSignal() {
   if (__STATUS_OFF) return(false);

   int trend = GetNonLagMATrend(1); if (!trend) return(false);

   // wait for a trend change of the last bar
   if (Abs(trend) == 1) {
      int type, oe[ORDER_EXECUTION.intSize];
      debug("CheckOpenSignal(1)  "+ TimeToStr(TimeCurrent(), TIME_FULL) +"  NonLagMA turned "+ ifString(trend==1, "up", "down"));

      int orders = OrdersTotal();                                 // lazy, for Tester only
      if (orders > 0) {
         OrderSelect(0, SELECT_BY_POS);
         if (OrderType() <= OP_SELL)                              // continue on open position
            return(true);
         if (!OrderDeleteEx(OrderTicket(), CLR_NONE, NULL, oe))   // delete not yet triggered pending order
            return(false);
      }

      // get last bar data
      double high    = iHigh(NULL, PERIOD_H4, 1);
      double low     =  iLow(NULL, PERIOD_H4, 1);
      double barSize = (high-low)/Pip;

      if (barSize > maxBarSize) {
         maxBarSize = barSize;
         debug("CheckOpenSignal(2)  maxBarSize: "+ DoubleToStr(maxBarSize, Digits & 1));
      }

      // determine order limits
      double entryPrice = ifDouble(trend==1, high, low);
      double stopLoss   = ifDouble(trend==1, low, high);
      double takeProfit = ifDouble(trend==1, high + 1.5*barSize*Pip, low - 1.5*barSize*Pip);

      // submit a new pending order
      if (trend == 1) {
         if      (Ask < entryPrice) type = OP_BUYSTOP;
         else if (Bid > entryPrice) type = OP_BUYLIMIT;
         else                       type = OP_BUY;          // immediately open a market order instead
      }
      else {
         if      (Bid > entryPrice) type = OP_SELLSTOP;
         else if (Ask < entryPrice) type = OP_SELLLIMIT;
         else                       type = OP_SELL;         // immediately open a market order instead
      }
      double lots        = 0.1;
      double slippage    = 0.1;
      color  markerColor = ifInt(trend==1, Blue, Red);

      if (!OrderSendEx(NULL, type, lots, entryPrice, slippage, stopLoss, takeProfit, os.name, os.magicNumber, NULL, markerColor, NULL, oe))
         return(false);
   }
   return(!catch("CheckOpenSignal(3)"));
}


/**
 * Return the trend of the NonLagMA indicator at the specified bar.
 *
 * @param  int bar - bar index
 *
 * @return int - trend value or NULL in case of errors
 */
int GetNonLagMATrend(int bar) {
   int periods   = 20;
   int maxValues = 200;
   return(icNonLagMA(PERIOD_H4, periods, maxValues, MovingAverage.MODE_TREND, bar));
}


/**
 * Return a string representation of the input parameters for logging.
 *
 * @return string
 */
string InputsToStr() {
   return(EMPTY_STR);
}
