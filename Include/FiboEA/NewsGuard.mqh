#ifndef FIBO_EA_NEWS_GUARD_MQH
#define FIBO_EA_NEWS_GUARD_MQH

class CNewsGuard
  {
private:
   string m_currencies[];

   string Trim(const string value) const
     {
      string result = value;
      StringTrimLeft(result);
      StringTrimRight(result);
      return result;
     }

   int ParseCurrencies(const string csv)
     {
      ArrayResize(m_currencies, 0);

      string parts[];
      const int count = StringSplit(csv, ',', parts);
      for(int index = 0; index < count; ++index)
        {
         string currency = Trim(parts[index]);
         StringToUpper(currency);
         if(currency == "")
            continue;

         const int size = ArraySize(m_currencies);
         ArrayResize(m_currencies, size + 1);
         m_currencies[size] = currency;
        }

      return ArraySize(m_currencies);
     }

   bool EventIsRestricted(const MqlCalendarValue &value,
                          const datetime now,
                          const int minutes_before,
                          const int minutes_after,
                          const string event_currency,
                          bool &lookup_failed,
                          string &event_name,
                          string &currency) const
     {
      lookup_failed = false;
      MqlCalendarEvent event;
      ResetLastError();
      if(!CalendarEventById(value.event_id, event))
        {
         lookup_failed = true;
         return false;
        }

      if(event.importance != CALENDAR_IMPORTANCE_HIGH)
         return false;

      const datetime window_start = value.time - minutes_before * 60;
      const datetime window_end = value.time + minutes_after * 60;
      if(now < window_start || now > window_end)
         return false;

      event_name = event.name;
      currency = event_currency;
      return true;
     }

public:
   bool Initialize(const string currencies_csv)
     {
      return (ParseCurrencies(currencies_csv) > 0);
     }

   bool CheckRestriction(const bool enabled,
                         const int minutes_before,
                         const int minutes_after,
                         const bool fail_safe_block,
                         bool &restricted,
                         datetime &restricted_event_time,
                         string &restricted_currency,
                         string &restricted_event_name,
                         string &reason) const
     {
      restricted = false;
      restricted_event_time = 0;
      restricted_currency = "";
      restricted_event_name = "";
      reason = "";

      if(!enabled)
         return true;

      if(ArraySize(m_currencies) == 0 || minutes_before < 0 || minutes_after < 0)
        {
         reason = "news_guard_invalid_configuration";
         restricted = fail_safe_block;
         return false;
        }

      datetime now = TimeTradeServer();
      if(now == 0)
         now = TimeCurrent();

      const datetime from = now - minutes_after * 60;
      const datetime to = now + minutes_before * 60;

      for(int index = 0; index < ArraySize(m_currencies); ++index)
        {
         MqlCalendarValue values[];
         ResetLastError();
         const int count = CalendarValueHistory(values, from, to, NULL, m_currencies[index]);
         if(count < 0)
           {
            reason = "calendar_unavailable";
            restricted = fail_safe_block;
            return false;
           }

         for(int value_index = 0; value_index < count; ++value_index)
           {
            string event_name = "";
            string event_currency = "";
            bool lookup_failed = false;
            if(EventIsRestricted(values[value_index], now, minutes_before, minutes_after,
                                 m_currencies[index], lookup_failed,
                                 event_name, event_currency))
              {
               restricted = true;
               restricted_event_time = values[value_index].time;
               restricted_currency = (event_currency == "") ? m_currencies[index] : event_currency;
               restricted_event_name = event_name;
               reason = "high_impact_news";
               return true;
              }
            if(lookup_failed)
              {
               reason = "calendar_event_unavailable";
               restricted = fail_safe_block;
               return false;
              }
           }
        }

      return true;
     }
  };

#endif
