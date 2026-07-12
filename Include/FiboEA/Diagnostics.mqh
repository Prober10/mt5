#ifndef FIBO_EA_DIAGNOSTICS_MQH
#define FIBO_EA_DIAGNOSTICS_MQH

#include "Types.mqh"

struct DiagnosticMarketContext
  {
   double spread_points;
   double bid;
   double ask;
   double equity;
   double atr14_points;
   double slope20_points;
   double h1_slope20_points;
   double h4_slope20_points;
   double h1_ma50_distance_points;
   double h4_ma50_distance_points;
   double h1_range_efficiency20;
   double h4_range_efficiency20;
  };

class CDiagnostics
  {
private:
   bool            m_enabled;
   int             m_handle;
   string          m_symbol;
   ENUM_TIMEFRAMES m_timeframe;

   string TimeText(const datetime value) const
     {
      if(value == 0)
         return "";
      return TimeToString(value, TIME_DATE | TIME_SECONDS);
     }

   string DirectionText(const SwingDirection direction) const
     {
      if(direction == SWING_DIRECTION_BULLISH)
         return "buy";
      if(direction == SWING_DIRECTION_BEARISH)
         return "sell";
      return "";
     }

   string DealTypeText(const ENUM_DEAL_TYPE type) const
     {
      switch(type)
        {
         case DEAL_TYPE_BUY:
            return "buy";
         case DEAL_TYPE_SELL:
            return "sell";
         case DEAL_TYPE_BALANCE:
            return "balance";
         default:
            return EnumToString(type);
        }
     }

   string DealEntryText(const ENUM_DEAL_ENTRY entry) const
     {
      switch(entry)
        {
         case DEAL_ENTRY_IN:
            return "in";
         case DEAL_ENTRY_OUT:
            return "out";
         case DEAL_ENTRY_INOUT:
            return "inout";
         case DEAL_ENTRY_OUT_BY:
            return "out_by";
         default:
            return EnumToString(entry);
        }
     }

   double PointsForPriceDistance(const string symbol,
                                 const double first_price,
                                 const double second_price) const
     {
      const double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      if(point <= 0.0)
         return 0.0;
      return MathAbs(first_price - second_price) / point;
     }

   void FillTimeframeContext(const string symbol,
                             const ENUM_TIMEFRAMES timeframe,
                             double &slope20_points,
                             double &ma50_distance_points,
                             double &range_efficiency20) const
     {
      slope20_points = 0.0;
      ma50_distance_points = 0.0;
      range_efficiency20 = 0.0;

      const double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      if(point <= 0.0)
         return;

      MqlRates rates[];
      const int copied = CopyRates(symbol, timeframe, 1, 51, rates);
      if(copied < 21)
         return;

      const int last = copied - 1;
      const int slope_start = MathMax(0, last - 20);
      slope20_points = (rates[last].close - rates[slope_start].close) / point;

      double close_sum = 0.0;
      const int ma_start = MathMax(0, copied - 50);
      int ma_count = 0;
      for(int index = ma_start; index < copied; ++index)
        {
         close_sum += rates[index].close;
         ++ma_count;
        }
      if(ma_count > 0)
        {
         const double ma = close_sum / (double)ma_count;
         ma50_distance_points = (rates[last].close - ma) / point;
        }

      double path = 0.0;
      for(int index = slope_start + 1; index <= last; ++index)
         path += MathAbs(rates[index].close - rates[index - 1].close);

      if(path > 0.0)
         range_efficiency20 = MathAbs(rates[last].close - rates[slope_start].close) / path;
     }

   int AlignmentScore(const SwingDirection direction, const double slope_points) const
     {
      if(direction == SWING_DIRECTION_BULLISH)
        {
         if(slope_points > 0.0)
            return 1;
         if(slope_points < 0.0)
            return -1;
        }
      if(direction == SWING_DIRECTION_BEARISH)
        {
         if(slope_points < 0.0)
            return 1;
         if(slope_points > 0.0)
            return -1;
        }

      return 0;
     }

   DiagnosticMarketContext MarketContext(const string symbol) const
     {
      DiagnosticMarketContext context;
      context.spread_points = 0.0;
      context.bid = 0.0;
      context.ask = 0.0;
      context.equity = AccountInfoDouble(ACCOUNT_EQUITY);
      context.atr14_points = 0.0;
      context.slope20_points = 0.0;
      context.h1_slope20_points = 0.0;
      context.h4_slope20_points = 0.0;
      context.h1_ma50_distance_points = 0.0;
      context.h4_ma50_distance_points = 0.0;
      context.h1_range_efficiency20 = 0.0;
      context.h4_range_efficiency20 = 0.0;

      const double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
      MqlTick tick;
      if(SymbolInfoTick(symbol, tick))
        {
         context.bid = tick.bid;
         context.ask = tick.ask;
         if(point > 0.0)
            context.spread_points = (tick.ask - tick.bid) / point;
        }

      if(point <= 0.0)
         return context;

      MqlRates rates[];
      const int copied = CopyRates(symbol, m_timeframe, 1, 21, rates);
      if(copied >= 2)
        {
         double tr_sum = 0.0;
         int tr_count = 0;
         for(int index = MathMax(1, copied - 14); index < copied; ++index)
           {
            const double high_low = rates[index].high - rates[index].low;
            const double high_close = MathAbs(rates[index].high - rates[index - 1].close);
            const double low_close = MathAbs(rates[index].low - rates[index - 1].close);
            tr_sum += MathMax(high_low, MathMax(high_close, low_close));
            ++tr_count;
           }

         if(tr_count > 0)
            context.atr14_points = (tr_sum / (double)tr_count) / point;

         context.slope20_points = (rates[copied - 1].close - rates[0].close) / point;
        }

      FillTimeframeContext(symbol, PERIOD_H1,
                           context.h1_slope20_points,
                           context.h1_ma50_distance_points,
                           context.h1_range_efficiency20);
      FillTimeframeContext(symbol, PERIOD_H4,
                           context.h4_slope20_points,
                           context.h4_ma50_distance_points,
                           context.h4_range_efficiency20);

      return context;
     }

   void WriteSetupRow(const string event_name,
                      const string symbol,
                      const SwingData &swing,
                      const TradeSetup &setup,
                      const string result,
                      const string reason,
                      const string comment)
     {
      if(!m_enabled || m_handle == INVALID_HANDLE)
         return;

      const DiagnosticMarketContext context = MarketContext(symbol);
      const double swing_points = PointsForPriceDistance(symbol, swing.start_price, swing.end_price);
      const double risk_points = setup.valid ? PointsForPriceDistance(symbol, setup.entry, setup.stop_loss) : 0.0;
      const double reward_points = setup.valid ? PointsForPriceDistance(symbol, setup.entry, setup.take_profit) : 0.0;
      const double setup_age_minutes = (setup.valid && setup.swing.end_time > 0)
                                       ? (double)(TimeCurrent() - setup.swing.end_time) / 60.0
                                       : 0.0;
      const int h1_alignment = AlignmentScore(swing.direction, context.h1_slope20_points);
      const int h4_alignment = AlignmentScore(swing.direction, context.h4_slope20_points);

      FileWrite(m_handle,
                TimeText(TimeCurrent()), event_name, symbol, EnumToString(m_timeframe),
                DirectionText(swing.direction), TimeText(swing.start_time), TimeText(swing.end_time),
                swing.start_price, swing.end_price, swing_points,
                setup.entry, setup.stop_loss, setup.take_profit, setup.volume,
                risk_points, reward_points, setup_age_minutes,
                context.spread_points, context.bid, context.ask, context.equity,
                context.atr14_points, context.slope20_points,
                context.h1_slope20_points, context.h4_slope20_points,
                context.h1_ma50_distance_points, context.h4_ma50_distance_points,
                context.h1_range_efficiency20, context.h4_range_efficiency20,
                h1_alignment, h4_alignment,
                result, reason, "", "", "", "", "", 0.0, 0.0, 0.0, 0.0, comment);
      FileFlush(m_handle);
     }

public:
   CDiagnostics(void) : m_enabled(false), m_handle(INVALID_HANDLE), m_symbol(""), m_timeframe(PERIOD_CURRENT)
     {
     }

   bool Initialize(const bool enabled,
                   const string file_name,
                   const string symbol,
                   const ENUM_TIMEFRAMES timeframe)
     {
      m_enabled = (enabled && MQLInfoInteger(MQL_TESTER));
      m_symbol = symbol;
      m_timeframe = timeframe;

      if(!m_enabled)
         return true;

      FolderCreate("FiboEA", FILE_COMMON);
      m_handle = FileOpen(file_name, FILE_WRITE | FILE_CSV | FILE_COMMON | FILE_ANSI, ',');
      if(m_handle == INVALID_HANDLE)
        {
         PrintFormat("Unable to open diagnostics file '%s'. Error: %d", file_name, GetLastError());
         m_enabled = false;
         return false;
        }

      FileWrite(m_handle,
                "event_time", "event", "symbol", "timeframe",
                "direction", "swing_start", "swing_end", "swing_start_price", "swing_end_price",
                "swing_points", "entry", "stop_loss", "take_profit", "volume",
                "risk_points", "reward_points", "setup_age_minutes",
                "spread_points", "bid", "ask", "equity", "atr14_points", "slope20_points",
                "h1_slope20_points", "h4_slope20_points",
                "h1_ma50_distance_points", "h4_ma50_distance_points",
                "h1_range_efficiency20", "h4_range_efficiency20",
                "h1_alignment", "h4_alignment",
                "result", "reason", "deal", "order", "position", "deal_type", "deal_entry",
                "profit", "commission", "swap", "fee", "comment");
      FileFlush(m_handle);
      return true;
     }

   void Deinitialize(void)
     {
      if(m_handle != INVALID_HANDLE)
        {
         FileClose(m_handle);
         m_handle = INVALID_HANDLE;
        }
      m_enabled = false;
     }

   void LogSetupCalculated(const string symbol, const TradeSetup &setup)
     {
      WriteSetupRow("setup", symbol, setup.swing, setup, "calculated", "", "");
     }

   void LogSetupRejected(const string symbol,
                         const SwingData &swing,
                         const TradeSetup &setup,
                         const string reason)
     {
      WriteSetupRow("setup", symbol, swing, setup, "rejected", reason, "");
     }

   void LogSetupPlaced(const string symbol, const TradeSetup &setup)
     {
      WriteSetupRow("setup", symbol, setup.swing, setup, "placed", "", "");
     }

   void LogTradeDeal(const ulong deal_ticket, const ulong expected_magic)
     {
      if(!m_enabled || m_handle == INVALID_HANDLE || deal_ticket == 0)
         return;
      if(!HistoryDealSelect(deal_ticket))
         return;
      if((ulong)HistoryDealGetInteger(deal_ticket, DEAL_MAGIC) != expected_magic)
         return;

      const string symbol = HistoryDealGetString(deal_ticket, DEAL_SYMBOL);
      const DiagnosticMarketContext context = MarketContext(symbol);
      const ENUM_DEAL_TYPE deal_type = (ENUM_DEAL_TYPE)HistoryDealGetInteger(deal_ticket, DEAL_TYPE);
      const ENUM_DEAL_ENTRY deal_entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(deal_ticket, DEAL_ENTRY);

      FileWrite(m_handle,
                TimeText((datetime)HistoryDealGetInteger(deal_ticket, DEAL_TIME)), "deal", symbol,
                EnumToString(m_timeframe), "", "", "", 0.0, 0.0, 0.0,
                HistoryDealGetDouble(deal_ticket, DEAL_PRICE), 0.0, 0.0,
                HistoryDealGetDouble(deal_ticket, DEAL_VOLUME), 0.0, 0.0, 0.0,
                context.spread_points, context.bid, context.ask, context.equity,
                context.atr14_points, context.slope20_points,
                context.h1_slope20_points, context.h4_slope20_points,
                context.h1_ma50_distance_points, context.h4_ma50_distance_points,
                context.h1_range_efficiency20, context.h4_range_efficiency20,
                0, 0,
                "", "", (string)deal_ticket,
                (string)HistoryDealGetInteger(deal_ticket, DEAL_ORDER),
                (string)HistoryDealGetInteger(deal_ticket, DEAL_POSITION_ID),
                DealTypeText(deal_type), DealEntryText(deal_entry),
                HistoryDealGetDouble(deal_ticket, DEAL_PROFIT),
                HistoryDealGetDouble(deal_ticket, DEAL_COMMISSION),
                HistoryDealGetDouble(deal_ticket, DEAL_SWAP),
                HistoryDealGetDouble(deal_ticket, DEAL_FEE),
                HistoryDealGetString(deal_ticket, DEAL_COMMENT));
      FileFlush(m_handle);
     }
  };

#endif
