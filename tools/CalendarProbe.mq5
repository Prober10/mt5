#property copyright "Prober10"
#property version   "1.00"
#property strict
#property script_show_inputs

input string InpCalendarCurrency = "USD";
input string InpCalendarCountryCode = "";
input int    InpLookbackDays = 7;
input int    InpForwardDays = 7;
input int    InpMaxEventsToPrint = 20;

string ImportanceText(const ENUM_CALENDAR_EVENT_IMPORTANCE importance)
  {
   switch(importance)
     {
      case CALENDAR_IMPORTANCE_NONE:
         return "none";
      case CALENDAR_IMPORTANCE_LOW:
         return "low";
      case CALENDAR_IMPORTANCE_MODERATE:
         return "moderate";
      case CALENDAR_IMPORTANCE_HIGH:
         return "high";
     }

   return "unknown";
  }

void OnStart(void)
  {
   datetime now = TimeTradeServer();
   if(now == 0)
      now = TimeCurrent();

   const datetime from = now - MathMax(InpLookbackDays, 0) * 86400;
   const datetime to = now + MathMax(InpForwardDays, 0) * 86400;

   MqlCalendarValue values[];
   ResetLastError();
   const int count = CalendarValueHistory(
      values,
      from,
      to,
      InpCalendarCountryCode,
      InpCalendarCurrency);
   const int error = GetLastError();

   PrintFormat("CalendarProbe request: currency='%s', country='%s', from=%s, to=%s",
               InpCalendarCurrency,
               InpCalendarCountryCode,
               TimeToString(from, TIME_DATE | TIME_MINUTES),
               TimeToString(to, TIME_DATE | TIME_MINUTES));
   PrintFormat("CalendarProbe result: count=%d, error=%d", count, error);

   if(count < 0)
     {
      Print("CalendarProbe failed. CalendarValueHistory returned -1.");
      return;
     }

   const int limit = MathMin(count, MathMax(InpMaxEventsToPrint, 0));
   for(int index = 0; index < limit; ++index)
     {
      MqlCalendarEvent event;
      ResetLastError();
      if(CalendarEventById(values[index].event_id, event))
        {
         PrintFormat("CalendarProbe event[%d]: time=%s, event_id=%I64d, importance=%s, name='%s'",
                     index,
                     TimeToString(values[index].time, TIME_DATE | TIME_MINUTES),
                     values[index].event_id,
                     ImportanceText(event.importance),
                     event.name);
        }
      else
        {
         PrintFormat("CalendarProbe event[%d]: time=%s, event_id=%I64d, event_lookup_error=%d",
                     index,
                     TimeToString(values[index].time, TIME_DATE | TIME_MINUTES),
                     values[index].event_id,
                     GetLastError());
        }
     }
  }
