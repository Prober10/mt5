#ifndef ADAPTIVE_AI_TRADE_MANAGER_MQH
#define ADAPTIVE_AI_TRADE_MANAGER_MQH

#include <Trade/Trade.mqh>
#include "Types.mqh"

class CAdaptiveTradeManager
  {
private:
   CTrade m_trade;
   ulong  m_magic;

public:
   void Initialize(const ulong magic, const int deviation_points)
     {
      m_magic = magic;
      m_trade.SetExpertMagicNumber(m_magic);
      m_trade.SetDeviationInPoints(deviation_points);
      m_trade.SetAsyncMode(false);
     }

   bool HasActivePosition(void) const
     {
      for(int index = PositionsTotal() - 1; index >= 0; --index)
        {
         const ulong ticket = PositionGetTicket(index);
         if(ticket != 0 && (ulong)PositionGetInteger(POSITION_MAGIC) == m_magic)
            return true;
        }
      return false;
     }

   bool BuildATRPlan(const string symbol,
                     const MarketFeatures &features,
                     const ModelDecision &decision,
                     const double atr_stop_multiplier,
                     const double reward_risk_ratio,
                     TradePlan &plan) const
     {
      ResetTradePlan(plan);
      if(decision.action == ADAPTIVE_ACTION_NO_TRADE ||
         !features.valid || features.atr <= 0.0 ||
         atr_stop_multiplier <= 0.0 || reward_risk_ratio <= 0.0)
         return false;

      MqlTick tick;
      if(!SymbolInfoTick(symbol, tick))
         return false;

      const double tick_size = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
      const double risk_distance = features.atr * atr_stop_multiplier;
      if(tick_size <= 0.0 || risk_distance <= 0.0)
         return false;

      plan.action = decision.action;
      plan.state_key = decision.state_key;
      plan.risk_distance = risk_distance;

      if(decision.action == ADAPTIVE_ACTION_BUY_ATR_1R)
        {
         plan.entry = tick.ask;
         plan.stop_loss = plan.entry - risk_distance;
         plan.take_profit = plan.entry + risk_distance * reward_risk_ratio;
        }
      else if(decision.action == ADAPTIVE_ACTION_SELL_ATR_1R)
        {
         plan.entry = tick.bid;
         plan.stop_loss = plan.entry + risk_distance;
         plan.take_profit = plan.entry - risk_distance * reward_risk_ratio;
        }

      plan.entry = MathRound(plan.entry / tick_size) * tick_size;
      plan.stop_loss = MathRound(plan.stop_loss / tick_size) * tick_size;
      plan.take_profit = MathRound(plan.take_profit / tick_size) * tick_size;
      plan.valid = true;
      return true;
     }

   bool ExecutePlan(const string symbol,
                    const TradePlan &plan,
                    const string comment,
                    ulong &deal_ticket,
                    ulong &position_id)
     {
      deal_ticket = 0;
      position_id = 0;
      if(!plan.valid || plan.volume <= 0.0)
         return false;

      m_trade.SetTypeFillingBySymbol(symbol);
      bool ok = false;
      if(plan.action == ADAPTIVE_ACTION_BUY_ATR_1R)
         ok = m_trade.Buy(plan.volume, symbol, 0.0, plan.stop_loss, plan.take_profit, comment);
      else if(plan.action == ADAPTIVE_ACTION_SELL_ATR_1R)
         ok = m_trade.Sell(plan.volume, symbol, 0.0, plan.stop_loss, plan.take_profit, comment);

      if(!ok)
        {
         PrintFormat("Adaptive order failed: %s", m_trade.ResultRetcodeDescription());
         return false;
        }

      deal_ticket = m_trade.ResultDeal();
      if(deal_ticket != 0 && HistoryDealSelect(deal_ticket))
         position_id = (ulong)HistoryDealGetInteger(deal_ticket, DEAL_POSITION_ID);

      return true;
     }
  };

#endif
