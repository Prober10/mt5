#ifndef FIBO_EA_TYPES_MQH
#define FIBO_EA_TYPES_MQH

enum SwingDirection
  {
   SWING_DIRECTION_NONE = 0,
   SWING_DIRECTION_BULLISH,
   SWING_DIRECTION_BEARISH
  };

enum PendingOrderResult
  {
   PENDING_ORDER_PLACED = 0,
   PENDING_ORDER_INVALID_SETUP,
   PENDING_ORDER_BROKER_REJECTED
  };

enum PendingPriceValidation
  {
   PENDING_PRICE_VALID = 0,
   PENDING_PRICE_PERMANENTLY_INVALID,
   PENDING_PRICE_RETRYABLE
  };

struct SwingData
  {
   SwingDirection direction;
   datetime       start_time;
   datetime       end_time;
   double         start_price;
   double         end_price;
   bool           valid;
  };

struct TradeSetup
  {
   SwingData swing;
   double    entry;
   double    stop_loss;
   double    take_profit;
   double    volume;
   bool      valid;
  };

void ResetSwing(SwingData &swing)
  {
   swing.direction = SWING_DIRECTION_NONE;
   swing.start_time = 0;
   swing.end_time = 0;
   swing.start_price = 0.0;
   swing.end_price = 0.0;
   swing.valid = false;
  }

void ResetSetup(TradeSetup &setup)
  {
   ResetSwing(setup.swing);
   setup.entry = 0.0;
   setup.stop_loss = 0.0;
   setup.take_profit = 0.0;
   setup.volume = 0.0;
   setup.valid = false;
  }

#endif
