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

   PendingPriceValidation ValidatePendingPrices(const string symbol,
                                                const TradeSetup &setup) const
     {
      const MqlTick tick = {};
      MqlTick current_tick = tick;
      if(!SymbolInfoTick(symbol, current_tick))
         return PENDING_PRICE_RETRYABLE;

      const double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      const double minimum_distance = (double)SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL) * point;

      if(setup.swing.direction == SWING_DIRECTION_BULLISH)
        {
         if(setup.stop_loss >= setup.entry || setup.take_profit <= setup.entry ||
            setup.entry - setup.stop_loss < minimum_distance ||
            setup.take_profit - setup.entry < minimum_distance)
            return PENDING_PRICE_PERMANENTLY_INVALID;
         if(setup.entry >= current_tick.ask)
            return PENDING_PRICE_PERMANENTLY_INVALID;
         if(current_tick.ask - setup.entry < minimum_distance)
            return PENDING_PRICE_RETRYABLE;
         return PENDING_PRICE_VALID;
        }

      if(setup.swing.direction == SWING_DIRECTION_BEARISH)
        {
         if(setup.stop_loss <= setup.entry || setup.take_profit >= setup.entry ||
            setup.stop_loss - setup.entry < minimum_distance ||
            setup.entry - setup.take_profit < minimum_distance)
            return PENDING_PRICE_PERMANENTLY_INVALID;
         if(setup.entry <= current_tick.bid)
            return PENDING_PRICE_PERMANENTLY_INVALID;
         if(setup.entry - current_tick.bid < minimum_distance)
            return PENDING_PRICE_RETRYABLE;
         return PENDING_PRICE_VALID;
        }

      return PENDING_PRICE_PERMANENTLY_INVALID;
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

   PendingOrderResult PlacePendingOrder(const string symbol,
                                        const TradeSetup &setup,
                                        const string comment)
     {
      if(!setup.valid || setup.volume <= 0.0)
         return PENDING_ORDER_INVALID_SETUP;

      const PendingPriceValidation price_validation = ValidatePendingPrices(symbol, setup);
      if(price_validation == PENDING_PRICE_PERMANENTLY_INVALID)
         return PENDING_ORDER_INVALID_SETUP;
      if(price_validation == PENDING_PRICE_RETRYABLE)
        {
         Print("Pending order deferred because current quote or stop-distance conditions are temporary.");
         return PENDING_ORDER_BROKER_REJECTED;
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
        {
         PrintFormat("Unable to place pending order: %s", m_trade.ResultRetcodeDescription());
         return PENDING_ORDER_BROKER_REJECTED;
        }

      return PENDING_ORDER_PLACED;
     }
  };

#endif
