#property copyright "Prober10"
#property version   "0.10"
#property strict

#include "Include/AdaptiveAI/Config.mqh"
#include "Include/AdaptiveAI/Types.mqh"
#include "Include/AdaptiveAI/FeatureExtractor.mqh"
#include "Include/AdaptiveAI/MarketState.mqh"
#include "Include/AdaptiveAI/LearningModel.mqh"
#include "Include/AdaptiveAI/DecisionEngine.mqh"
#include "Include/AdaptiveAI/RiskManager.mqh"
#include "Include/AdaptiveAI/TradeManager.mqh"
#include "Include/AdaptiveAI/MemoryStore.mqh"
#include "Include/AdaptiveAI/PerformanceTracker.mqh"
#include "Include/AdaptiveAI/Diagnostics.mqh"

CAdaptiveFeatureExtractor  g_features;
CAdaptiveMarketStateBuilder g_state_builder;
CAdaptiveLearningModel      g_model;
CAdaptiveDecisionEngine     g_decision_engine;
CAdaptiveRiskManager        g_risk_manager;
CAdaptiveTradeManager       g_trade_manager;
CAdaptiveMemoryStore        g_memory_store;
CAdaptivePerformanceTracker g_performance_tracker;
CAdaptiveDiagnostics        g_diagnostics;

datetime g_last_signal_bar = 0;
datetime g_current_day = 0;
bool     g_daily_limit_logged = false;

bool InputsAreValid(void)
  {
   return (InpATRPeriod > 0 &&
           InpSlopeLookbackBars >= 2 &&
           InpRangeLookbackBars >= 5 &&
           InpATRStopMultiplier > 0.0 &&
           InpRewardRiskRatio > 0.0 &&
           InpExplorationPercent >= 0.0 &&
           InpExplorationPercent <= 100.0 &&
           InpMinimumSamples >= 0 &&
           InpLearningDecay >= 0.0 &&
           InpLearningDecay <= 1.0 &&
           InpAdaptiveRiskPercent > 0.0 &&
           InpAdaptiveMaxDailyClosedLossPercent > 0.0 &&
           InpAdaptiveMinLotSize > 0.0 &&
           InpAdaptiveMaxLotSize >= InpAdaptiveMinLotSize &&
           InpAdaptiveLotStep > 0.0 &&
           InpAdaptiveMinMarginLevelPercent >= 0.0 &&
           InpMaxSpreadPoints >= 0.0 &&
           (InpAllowAdaptiveBuy || InpAllowAdaptiveSell));
  }

bool IsNewSignalBar(void)
  {
   const datetime bar_time = iTime(_Symbol, InpAdaptiveTimeframe, 0);
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
      InpAdaptiveMagicNumber, InpAdaptiveMaxDailyClosedLossPercent,
      closed_loss, loss_limit);

   if(reached)
     {
      if(!g_daily_limit_logged)
        {
         PrintFormat("Adaptive daily loss protection active. Closed loss: %.2f, limit: %.2f",
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
      Print("Invalid Adaptive AI EA input configuration.");
      return INIT_PARAMETERS_INCORRECT;
     }

   if(!SymbolSelect(_Symbol, true))
      return INIT_FAILED;

   MathSrand((uint)GetTickCount());

   if(!g_features.Initialize(_Symbol, InpAdaptiveTimeframe, InpATRPeriod,
                             InpSlopeLookbackBars, InpRangeLookbackBars))
      return INIT_FAILED;

   g_model.Initialize(InpLearningDecay);
   g_memory_store.Initialize(InpMemoryFileName);
   if(InpEnableLearning && !g_memory_store.Load(g_model))
      return INIT_FAILED;

   g_trade_manager.Initialize(InpAdaptiveMagicNumber, InpAdaptiveDeviationPoints);
   g_performance_tracker.Initialize();

   if(!g_diagnostics.Initialize(InpAdaptiveEnableDiagnostics,
                                InpAdaptiveDiagnosticsFileName))
      return INIT_FAILED;

   g_current_day = g_risk_manager.CurrentBrokerDayStart();
   PrintFormat("Adaptive AI EA initialized on %s using %s signals. Memory records: %d",
               _Symbol, EnumToString(InpAdaptiveTimeframe), g_model.Count());
   return INIT_SUCCEEDED;
  }

void OnDeinit(const int reason)
  {
   if(InpEnableLearning)
      g_memory_store.Save(g_model);

   g_diagnostics.Deinitialize();
   g_features.Release();
  }

void OnTradeTransaction(const MqlTradeTransaction &transaction,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
   if(transaction.type != TRADE_TRANSACTION_DEAL_ADD || !InpEnableLearning)
      return;

   string state_key = "";
   AdaptiveAction action = ADAPTIVE_ACTION_NO_TRADE;
   double result_r = 0.0;
   if(g_performance_tracker.ConsumeClosedDeal(transaction.deal,
                                             InpAdaptiveMagicNumber,
                                             state_key, action, result_r))
     {
      g_model.Update(state_key, action, result_r);
      g_memory_store.Save(g_model);
      g_diagnostics.LogLearning(state_key, action, result_r, "closed_trade");
      PrintFormat("Adaptive learning update: state=%s action=%s result=%.2fR",
                  state_key, AdaptiveActionName(action), result_r);
     }
  }

void OnTick(void)
  {
   if(!DailyTradingAllowed())
      return;

   if(!IsNewSignalBar() || g_trade_manager.HasActivePosition())
      return;

   MarketFeatures features;
   if(!g_features.Extract(features))
      return;

   if(InpMaxSpreadPoints > 0.0 && features.spread_points > InpMaxSpreadPoints)
      return;

   MarketState state;
   if(!g_state_builder.Build(_Symbol, features, state))
      return;

   ModelDecision decision;
   g_decision_engine.Decide(state, g_model, InpAllowAdaptiveBuy,
                            InpAllowAdaptiveSell, InpTesterExploration,
                            InpExplorationPercent, InpMinimumSamples,
                            InpMinimumAverageR, decision);
   g_diagnostics.LogDecision(features, state, decision);

   if(decision.action == ADAPTIVE_ACTION_NO_TRADE)
      return;

   TradePlan plan;
   if(!g_trade_manager.BuildATRPlan(_Symbol, features, decision,
                                    InpATRStopMultiplier,
                                    InpRewardRiskRatio, plan))
     {
      g_diagnostics.LogPlan("plan_rejected", plan, "build_failed");
      return;
     }

   const VolumeCheckResult volume_result =
      g_risk_manager.CalculateVolume(_Symbol, plan.action, plan.entry,
                                     plan.stop_loss, InpAdaptiveRiskPercent,
                                     InpAdaptiveMinLotSize,
                                     InpAdaptiveMaxLotSize,
                                     InpAdaptiveLotStep,
                                     InpAdaptiveMinMarginLevelPercent,
                                     plan.volume);
   if(volume_result != ADAPTIVE_VOLUME_OK)
     {
      g_diagnostics.LogPlan("plan_rejected", plan,
                            volume_result == ADAPTIVE_VOLUME_RETRYABLE
                            ? "volume_retryable"
                            : "volume_unavailable");
      return;
     }

   ulong deal_ticket = 0;
   ulong position_id = 0;
   if(!g_trade_manager.ExecutePlan(_Symbol, plan, InpAdaptiveOrderComment,
                                   deal_ticket, position_id))
     {
      g_diagnostics.LogPlan("order_failed", plan, "broker_rejected");
      return;
     }

   g_performance_tracker.RecordOpened(position_id, plan);
   g_diagnostics.LogPlan("order_placed", plan, "executed");
   PrintFormat("Adaptive trade opened: %s volume %.2f state=%s",
               AdaptiveActionName(plan.action), plan.volume, plan.state_key);
  }
