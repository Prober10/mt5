#ifndef FIBO_EA_NEWS_GUARD_MQH
#define FIBO_EA_NEWS_GUARD_MQH

class CNewsGuard
  {
private:
   struct NewsEvent
     {
      datetime time;
      string currency;
      string name;
     };

   string m_currencies[];
   NewsEvent m_csv_events[];
   ENUM_NEWS_DATA_SOURCE m_source;
   string m_csv_file_name;
   bool m_csv_loaded;

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

   bool CurrencyIsAllowed(const string value) const
     {
      string currency = value;
      StringToUpper(currency);
      for(int index = 0; index < ArraySize(m_currencies); ++index)
        {
         if(currency == m_currencies[index])
            return true;
        }

      return false;
     }

   bool UseCsvSource(void) const
     {
      if(m_source == NEWS_SOURCE_CSV)
         return true;

      return (m_source == NEWS_SOURCE_AUTO && MQLInfoInteger(MQL_TESTER));
     }

   string NormalizeTimeText(const string value) const
     {
      string result = Trim(value);
      StringReplace(result, "-", ".");
      if(StringLen(result) >= 16 && StringSubstr(result, 10, 1) == "T")
         StringSetCharacter(result, 10, ' ');
      return result;
     }

   bool LoadCsvEvents(string &reason)
     {
      ArrayResize(m_csv_events, 0);
      reason = "";

      if(m_csv_file_name == "")
        {
         reason = "news_csv_not_configured";
         return false;
        }

      ResetLastError();
      const int handle = FileOpen(m_csv_file_name, FILE_READ | FILE_CSV | FILE_COMMON, ',');
      if(handle == INVALID_HANDLE)
        {
         reason = "news_csv_unavailable";
         return false;
        }

      while(!FileIsEnding(handle))
        {
         const string time_text = Trim(FileReadString(handle));
         if(time_text == "")
            continue;

         const string currency_text = Trim(FileReadString(handle));
         const string importance_text = Trim(FileReadString(handle));
         const string name_text = Trim(FileReadString(handle));

         string header = time_text;
         StringToLower(header);
         if(header == "time")
            continue;

         string importance = importance_text;
         StringToLower(importance);
         if(importance != "high")
            continue;

         string currency = currency_text;
         StringToUpper(currency);
         if(!CurrencyIsAllowed(currency))
            continue;

         const datetime event_time = StringToTime(NormalizeTimeText(time_text));
         if(event_time <= 0)
            continue;

         const int size = ArraySize(m_csv_events);
         ArrayResize(m_csv_events, size + 1);
         m_csv_events[size].time = event_time;
         m_csv_events[size].currency = currency;
         m_csv_events[size].name = name_text;
        }

      FileClose(handle);
      m_csv_loaded = true;
      return true;
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

   bool CheckCsvRestriction(const int minutes_before,
                            const int minutes_after,
                            const bool fail_safe_block,
                            bool &restricted,
                            datetime &restricted_event_time,
                            string &restricted_currency,
                            string &restricted_event_name,
                            string &reason) const
     {
      if(!m_csv_loaded)
        {
         reason = "news_csv_not_loaded";
         restricted = fail_safe_block;
         return false;
        }

      datetime now = TimeTradeServer();
      if(now == 0)
         now = TimeCurrent();

      for(int index = 0; index < ArraySize(m_csv_events); ++index)
        {
         const datetime window_start = m_csv_events[index].time - minutes_before * 60;
         const datetime window_end = m_csv_events[index].time + minutes_after * 60;
         if(now < window_start || now > window_end)
            continue;

         restricted = true;
         restricted_event_time = m_csv_events[index].time;
         restricted_currency = m_csv_events[index].currency;
         restricted_event_name = m_csv_events[index].name;
         reason = "high_impact_news_csv";
         return true;
        }

      return true;
     }

public:
   bool Initialize(const string currencies_csv,
                   const ENUM_NEWS_DATA_SOURCE source,
                   const string csv_file_name)
     {
      m_source = source;
      m_csv_file_name = csv_file_name;
      m_csv_loaded = false;
      ArrayResize(m_csv_events, 0);

      if(ParseCurrencies(currencies_csv) <= 0)
         return false;

      if(UseCsvSource())
        {
         string reason = "";
         return LoadCsvEvents(reason);
        }

      return true;
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

      if(UseCsvSource())
         return CheckCsvRestriction(minutes_before, minutes_after, fail_safe_block,
                                    restricted, restricted_event_time,
                                    restricted_currency, restricted_event_name, reason);

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
