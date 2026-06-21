#ifndef FIBO_EA_TRADE_MANAGER_MQH
#define FIBO_EA_TRADE_MANAGER_MQH

#include <Trade/Trade.mqh>
#include "Types.mqh"

class CTradeManager
  {
private:
   CTrade m_trade;
   ulong  m_magic;

   bool IsPendingType(const ENUM_ORDER_TYPE type) const
     {
      return (type == ORDER_TYPE_BUY_LIMIT || type == ORDER_TYPE_SELL_LIMIT ||
              type == ORDER_TYPE_BUY_STOP || type == ORDER_TYPE_SELL_STOP ||
              type == ORDER_TYPE_BUY_STOP_LIMIT || type == ORDER_TYPE_SELL_STOP_LIMIT);
     }

   bool ValidatePendingPrices(const string symbol, const TradeSetup &setup) const
     {
      const MqlTick tick = {};
      MqlTick current_tick = tick;
      if(!SymbolInfoTick(symbol, current_tick))
         return false;

      const double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      const double minimum_distance = (double)SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL) * point;

      if(setup.swing.direction == SWING_DIRECTION_BULLISH)
        {
         return (setup.entry < current_tick.ask && setup.stop_loss < setup.entry &&
                 setup.take_profit > setup.entry &&
                 current_tick.ask - setup.entry >= minimum_distance &&
                 setup.entry - setup.stop_loss >= minimum_distance &&
                 setup.take_profit - setup.entry >= minimum_distance);
        }

      if(setup.swing.direction == SWING_DIRECTION_BEARISH)
        {
         return (setup.entry > current_tick.bid && setup.stop_loss > setup.entry &&
                 setup.take_profit < setup.entry &&
                 setup.entry - current_tick.bid >= minimum_distance &&
                 setup.stop_loss - setup.entry >= minimum_distance &&
                 setup.entry - setup.take_profit >= minimum_distance);
        }

      return false;
     }

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

   bool HasPendingOrder(void) const
     {
      for(int index = OrdersTotal() - 1; index >= 0; --index)
        {
         const ulong ticket = OrderGetTicket(index);
         if(ticket == 0 || (ulong)OrderGetInteger(ORDER_MAGIC) != m_magic)
            continue;

         if(IsPendingType((ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE)))
            return true;
        }
      return false;
     }

   bool CancelPendingOrders(void)
     {
      bool success = true;
      for(int index = OrdersTotal() - 1; index >= 0; --index)
        {
         const ulong ticket = OrderGetTicket(index);
         if(ticket == 0 || (ulong)OrderGetInteger(ORDER_MAGIC) != m_magic)
            continue;

         if(!IsPendingType((ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE)))
            continue;

         if(!m_trade.OrderDelete(ticket))
           {
            PrintFormat("Unable to cancel order %I64u: %s",
                        ticket, m_trade.ResultRetcodeDescription());
            success = false;
           }
        }
      return success;
     }

   bool PlacePendingOrder(const string symbol,
                          const TradeSetup &setup,
                          const string comment)
     {
      if(!setup.valid || setup.volume <= 0.0 || !ValidatePendingPrices(symbol, setup))
        {
         Print("Pending order rejected by local price or volume validation.");
         return false;
        }

      m_trade.SetTypeFillingBySymbol(symbol);
      bool placed = false;
      if(setup.swing.direction == SWING_DIRECTION_BULLISH)
        {
         placed = m_trade.BuyLimit(setup.volume, setup.entry, symbol,
                                   setup.stop_loss, setup.take_profit,
                                   ORDER_TIME_GTC, 0, comment);
        }
      else if(setup.swing.direction == SWING_DIRECTION_BEARISH)
        {
         placed = m_trade.SellLimit(setup.volume, setup.entry, symbol,
                                    setup.stop_loss, setup.take_profit,
                                    ORDER_TIME_GTC, 0, comment);
        }

      if(!placed)
         PrintFormat("Unable to place pending order: %s", m_trade.ResultRetcodeDescription());
      return placed;
     }
  };

#endif
