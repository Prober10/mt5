#property copyright "Prober10"
#property version   "1.00"
#property strict

#include "Include/FiboEA/Config.mqh"
#include "Include/FiboEA/Types.mqh"
#include "Include/FiboEA/ZigZagSwingDetector.mqh"
#include "Include/FiboEA/FiboCalculator.mqh"
#include "Include/FiboEA/RiskManager.mqh"
#include "Include/FiboEA/TradeManager.mqh"
#include "Include/FiboEA/SetupTracker.mqh"

CZigZagSwingDetector g_swing_detector;
CFiboCalculator      g_fibo_calculator;
CRiskManager         g_risk_manager;
CTradeManager        g_trade_manager;
CSetupTracker        g_setup_tracker;

datetime g_last_signal_bar = 0;
datetime g_current_day = 0;
bool     g_daily_limit_logged = false;

bool InputsAreValid(void)
  {
   return (InpZigZagDepth > 0 &&
           InpZigZagDeviation >= 0 &&
           InpZigZagBackstep > 0 &&
           InpZigZagLookbackBars >= 100 &&
           InpFibonacciEntry > 0.0 && InpFibonacciEntry < 1.0 &&
           InpStopBuffer >= 0.0 &&
           InpRiskPercent > 0.0 &&
           InpMaxDailyClosedLossPercent > 0.0 &&
           (InpAllowBuy || InpAllowSell));
  }

bool IsNewSignalBar(void)
  {
   const datetime bar_time = iTime(_Symbol, InpSignalTimeframe, 0);
   if(bar_time == 0 || bar_time == g_last_signal_bar)
      return false;

   g_last_signal_bar = bar_time;
   return true;
  }

bool DailyTradingAllowed(void)
  {
   const datetime day = g_risk_manager.CurrentBrokerDayStart();
   if(day != g_current_day)
     {
      g_current_day = day;
      g_daily_limit_logged = false;
     }

   double closed_loss = 0.0;
   double loss_limit = 0.0;
   const bool reached = g_risk_manager.IsDailyLossLimitReached(
      InpMagicNumber, InpMaxDailyClosedLossPercent, closed_loss, loss_limit);

   if(reached)
     {
      g_trade_manager.CancelPendingOrders();
      if(!g_daily_limit_logged)
        {
         PrintFormat("Daily loss protection active. Closed loss: %.2f, limit: %.2f",
                     closed_loss, loss_limit);
         g_daily_limit_logged = true;
        }
      return false;
     }

   return true;
  }

int OnInit(void)
  {
   if(!InputsAreValid())
     {
      Print("Invalid EA input configuration.");
      return INIT_PARAMETERS_INCORRECT;
     }

   if(!SymbolSelect(_Symbol, true))
      return INIT_FAILED;

   if(!g_swing_detector.Initialize(_Symbol, InpSignalTimeframe,
                                   InpZigZagDepth, InpZigZagDeviation,
                                   InpZigZagBackstep, InpZigZagLookbackBars))
      return INIT_FAILED;

   g_trade_manager.Initialize(InpMagicNumber, InpDeviationPoints);
   g_setup_tracker.Initialize(_Symbol, InpMagicNumber);
   g_current_day = g_risk_manager.CurrentBrokerDayStart();
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   g_swing_detector.Release();
  }

void OnTick(void)
  {
   if(!DailyTradingAllowed())
      return;

   if(!IsNewSignalBar() || g_trade_manager.HasActivePosition())
      return;

   SwingData swing;
   if(!g_swing_detector.GetLatestConfirmedSwing(swing))
      return;

   if((swing.direction == SWING_DIRECTION_BULLISH && !InpAllowBuy) ||
      (swing.direction == SWING_DIRECTION_BEARISH && !InpAllowSell))
      return;

   const bool already_processed = g_setup_tracker.IsProcessed(swing);
   if(g_trade_manager.HasPendingOrder())
     {
      if(already_processed)
         return;

      if(!g_trade_manager.CancelPendingOrders())
         return;
     }
   else if(already_processed)
      return;

   TradeSetup setup;
   if(!g_fibo_calculator.Calculate(_Symbol, swing, InpFibonacciEntry,
                                   InpStopBuffer, setup))
      return;

   setup.volume = g_risk_manager.CalculateVolume(_Symbol, swing.direction,
                                                  setup.entry, setup.stop_loss,
                                                  InpRiskPercent);
   if(setup.volume <= 0.0)
     {
      Print("Setup skipped because a compliant trade volume could not be calculated.");
      return;
     }

   if(g_trade_manager.PlacePendingOrder(_Symbol, setup, InpOrderComment))
     {
      g_setup_tracker.MarkProcessed(swing);
      PrintFormat("Placed %s limit: volume %.2f, entry %.*f, SL %.*f, TP %.*f",
                  swing.direction == SWING_DIRECTION_BULLISH ? "buy" : "sell",
                  setup.volume, _Digits, setup.entry, _Digits, setup.stop_loss,
                  _Digits, setup.take_profit);
     }
  }
