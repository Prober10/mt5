#property copyright "Prober10"
#property version   "1.10"
#property strict

#include "Include/FiboEA/Config.mqh"
#include "Include/FiboEA/Types.mqh"
#include "Include/FiboEA/ZigZagSwingDetector.mqh"
#include "Include/FiboEA/FiboCalculator.mqh"
#include "Include/FiboEA/RiskManager.mqh"
#include "Include/FiboEA/TradeManager.mqh"
#include "Include/FiboEA/SetupTracker.mqh"
#include "Include/FiboEA/NewsGuard.mqh"
#include "Include/FiboEA/Diagnostics.mqh"

CZigZagSwingDetector g_swing_detector;
CFiboCalculator      g_fibo_calculator;
CRiskManager         g_risk_manager;
CTradeManager        g_trade_manager;
CSetupTracker        g_setup_tracker;
CNewsGuard           g_news_guard;
CDiagnostics         g_diagnostics;

datetime g_last_signal_bar = 0;
datetime g_current_day = 0;
bool     g_daily_limit_logged = false;
bool     g_news_guard_logged = false;

bool InputsAreValid(void)
  {
   return (InpZigZagDepth > 0 &&
           InpZigZagDeviation >= 0 &&
           InpZigZagBackstep > 0 &&
           InpZigZagLookbackBars >= 100 &&
           InpFibonacciEntry > 0.0 && InpFibonacciEntry < 1.0 &&
           InpBuySessionStartHour >= 0 && InpBuySessionStartHour <= 23 &&
           InpBuySessionEndHour >= 0 && InpBuySessionEndHour <= 23 &&
           InpAvoidSwingMinPoints >= 0.0 &&
           InpAvoidSwingMaxPoints >= InpAvoidSwingMinPoints &&
           InpStopBuffer >= 0.0 &&
           InpRiskPercent > 0.0 &&
           InpMaxDailyClosedLossPercent > 0.0 &&
           InpMinLotSize > 0.0 &&
           InpMaxLotSize >= InpMinLotSize &&
           InpLotStep > 0.0 &&
           InpMinMarginLevelPercent >= 0.0 &&
           InpNewsMinutesBefore >= 0 &&
           InpNewsMinutesAfter >= 0 &&
           InpNewsCancelPendingMinutesBefore >= InpNewsMinutesBefore &&
           InpPendingOrderExpirationHours >= 0.0 &&
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

bool BuySessionAllowsCurrentTime(void)
  {
   if(!InpUseBuySessionFilter)
      return true;

   datetime now = TimeTradeServer();
   if(now == 0)
      now = TimeCurrent();

   MqlDateTime parts;
   TimeToStruct(now, parts);
   if(InpBuySessionStartHour <= InpBuySessionEndHour)
      return (parts.hour >= InpBuySessionStartHour && parts.hour <= InpBuySessionEndHour);

   return (parts.hour >= InpBuySessionStartHour || parts.hour <= InpBuySessionEndHour);
  }

double SwingSizePoints(const SwingData &swing)
  {
   const double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(point <= 0.0)
      return 0.0;

   return MathAbs(swing.end_price - swing.start_price) / point;
  }

bool SwingBandAllowsSetup(const SwingData &swing)
  {
   if(!InpUseSwingBandFilter)
      return true;

   const double swing_points = SwingSizePoints(swing);
   return (swing_points < InpAvoidSwingMinPoints ||
           swing_points > InpAvoidSwingMaxPoints);
  }

bool NewsGuardAllowsNewEntries(void)
  {
   bool restricted = false;
   datetime event_time = 0;
   string currency = "";
   string event_name = "";
   string reason = "";

   const bool calendar_ok = g_news_guard.CheckRestriction(
      InpUseNewsGuard, InpNewsMinutesBefore, InpNewsMinutesAfter,
      InpNewsFailSafeBlock, restricted, event_time, currency, event_name, reason);

   if(!calendar_ok && restricted)
     {
      if(!g_news_guard_logged)
        {
         PrintFormat("News guard fail-safe active: %s. New entries blocked.", reason);
         g_news_guard_logged = true;
        }
      return false;
     }

   if(restricted)
     {
      if(!g_news_guard_logged)
        {
         PrintFormat("News guard active. New entries blocked near high-impact %s event '%s' at %s.",
                     currency, event_name, TimeToString(event_time, TIME_DATE | TIME_MINUTES));
         g_news_guard_logged = true;
        }
      return false;
     }

   g_news_guard_logged = false;
   return true;
  }

void ApplyNewsPendingProtection(void)
  {
   bool restricted = false;
   datetime event_time = 0;
   string currency = "";
   string event_name = "";
   string reason = "";

   const bool calendar_ok = g_news_guard.CheckRestriction(
      InpUseNewsGuard, InpNewsCancelPendingMinutesBefore, InpNewsMinutesAfter,
      InpNewsFailSafeBlock, restricted, event_time, currency, event_name, reason);

   if(!restricted || !g_trade_manager.HasPendingOrder())
      return;

   if(g_trade_manager.CancelPendingOrders())
     {
      if(calendar_ok)
         PrintFormat("News guard cancelled pending orders before high-impact %s event '%s' at %s.",
                     currency, event_name, TimeToString(event_time, TIME_DATE | TIME_MINUTES));
      else
         PrintFormat("News guard cancelled pending orders because calendar check failed: %s.", reason);
     }
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

   if(InpUseNewsGuard && !g_news_guard.Initialize(InpNewsCurrencies,
                                                   InpNewsDataSource,
                                                   InpNewsCsvFileName))
     {
      Print("Invalid news guard configuration or news CSV unavailable.");
      return INIT_PARAMETERS_INCORRECT;
     }

   if(!g_swing_detector.Initialize(_Symbol, InpSignalTimeframe,
                                   InpZigZagDepth, InpZigZagDeviation,
                                   InpZigZagBackstep, InpZigZagLookbackBars))
      return INIT_FAILED;

   g_trade_manager.Initialize(InpMagicNumber, InpDeviationPoints);
   g_setup_tracker.Initialize(_Symbol, InpMagicNumber);
   if(!g_diagnostics.Initialize(InpEnableDiagnostics, InpDiagnosticsFileName,
                                _Symbol, InpSignalTimeframe))
      return INIT_FAILED;

   g_current_day = g_risk_manager.CurrentBrokerDayStart();
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   g_diagnostics.Deinitialize();
   g_swing_detector.Release();
  }

void OnTradeTransaction(const MqlTradeTransaction &transaction,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
   if(transaction.type == TRADE_TRANSACTION_DEAL_ADD)
      g_diagnostics.LogTradeDeal(transaction.deal, InpMagicNumber);
  }

void OnTick(void)
  {
   if(!DailyTradingAllowed())
      return;

   ApplyNewsPendingProtection();

   if(!IsNewSignalBar() || g_trade_manager.HasActivePosition())
      return;

   if(!NewsGuardAllowsNewEntries())
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

   if(swing.direction == SWING_DIRECTION_BULLISH && !BuySessionAllowsCurrentTime())
     {
      TradeSetup blocked_setup;
      ResetSetup(blocked_setup);
      g_diagnostics.LogSetupRejected(_Symbol, swing, blocked_setup, "buy_session_blocked");
      return;
     }

   if(!SwingBandAllowsSetup(swing))
     {
      TradeSetup blocked_setup;
      ResetSetup(blocked_setup);
      g_diagnostics.LogSetupRejected(_Symbol, swing, blocked_setup, "swing_band_blocked");
      return;
     }

   TradeSetup setup;
   if(!g_fibo_calculator.Calculate(_Symbol, swing, InpFibonacciEntry,
                                   InpStopBuffer, setup))
     {
      g_diagnostics.LogSetupRejected(_Symbol, swing, setup, "fibo_calculation_failed");
      return;
     }

   g_diagnostics.LogSetupCalculated(_Symbol, setup);

   const VolumeCalculationResult volume_result =
      g_risk_manager.CalculateVolume(_Symbol, swing.direction,
                                     setup.entry, setup.stop_loss,
                                     InpRiskPercent, InpMinLotSize,
                                     InpMaxLotSize, InpLotStep,
                                     InpMinMarginLevelPercent, setup.volume);
   if(volume_result == VOLUME_PERMANENTLY_UNAVAILABLE)
     {
      g_diagnostics.LogSetupRejected(_Symbol, swing, setup, "volume_permanently_unavailable");
      if(g_setup_tracker.ShouldLogVolumeRejection(swing))
         Print("Setup volume does not fit the configured risk allowance; retries will be silent for this swing.");
      return;
     }
   if(volume_result == VOLUME_RETRYABLE)
     {
      g_diagnostics.LogSetupRejected(_Symbol, swing, setup, "volume_retryable");
      Print("Setup deferred because trade volume could not be calculated temporarily.");
      return;
     }

   const PendingOrderResult order_result =
      g_trade_manager.PlacePendingOrder(_Symbol, setup, InpOrderComment,
                                        InpPendingOrderExpirationHours);
   if(order_result == PENDING_ORDER_INVALID_SETUP)
     {
      g_diagnostics.LogSetupRejected(_Symbol, swing, setup, "pending_price_invalid");
      if(g_setup_tracker.ShouldLogPriceRejection(swing))
         Print("Setup price is currently invalid; retries will be silent for this swing.");
      return;
     }
   if(order_result == PENDING_ORDER_BROKER_REJECTED)
     {
      g_diagnostics.LogSetupRejected(_Symbol, swing, setup, "pending_order_broker_rejected");
      return;
     }

   if(order_result == PENDING_ORDER_PLACED)
     {
      g_setup_tracker.MarkProcessed(swing);
      g_diagnostics.LogSetupPlaced(_Symbol, setup);
      PrintFormat("Placed %s limit: volume %.2f, entry %.*f, SL %.*f, TP %.*f",
                  swing.direction == SWING_DIRECTION_BULLISH ? "buy" : "sell",
                  setup.volume, _Digits, setup.entry, _Digits, setup.stop_loss,
                  _Digits, setup.take_profit);
     }
  }
