#property copyright "Prober10"
#property version   "1.00"
#property strict
#property script_show_inputs

input string InpExportCurrencies = "USD";
input string InpExportFrom = "2025.01.01 00:00";
input string InpExportTo = "2026.12.31 23:59";
input string InpExportFileName = "FiboEA\\high-impact-news.csv";

string Trim(const string value)
  {
   string result = value;
   StringTrimLeft(result);
   StringTrimRight(result);
   return result;
  }

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

int ParseCurrencies(const string csv, string &currencies[])
  {
   ArrayResize(currencies, 0);

   string parts[];
   const int count = StringSplit(csv, ',', parts);
   for(int index = 0; index < count; ++index)
     {
      string currency = Trim(parts[index]);
      StringToUpper(currency);
      if(currency == "")
         continue;

      const int size = ArraySize(currencies);
      ArrayResize(currencies, size + 1);
      currencies[size] = currency;
     }

   return ArraySize(currencies);
  }

void OnStart(void)
  {
   const datetime from = StringToTime(InpExportFrom);
   const datetime to = StringToTime(InpExportTo);
   if(from <= 0 || to <= 0 || to <= from)
     {
      Print("ExportHighImpactNewsCsv failed: invalid date range.");
      return;
     }

   string currencies[];
   if(ParseCurrencies(InpExportCurrencies, currencies) <= 0)
     {
      Print("ExportHighImpactNewsCsv failed: no currencies configured.");
      return;
     }

   FolderCreate("FiboEA", FILE_COMMON);
   ResetLastError();
   const int handle = FileOpen(InpExportFileName,
                               FILE_WRITE | FILE_CSV | FILE_COMMON,
                               ',');
   if(handle == INVALID_HANDLE)
     {
      PrintFormat("ExportHighImpactNewsCsv failed: could not open '%s', error=%d",
                  InpExportFileName, GetLastError());
      return;
     }

   FileWrite(handle, "time", "currency", "importance", "name");

   int written = 0;
   for(int currency_index = 0; currency_index < ArraySize(currencies); ++currency_index)
     {
      MqlCalendarValue values[];
      ResetLastError();
      const int count = CalendarValueHistory(values, from, to, NULL, currencies[currency_index]);
      if(count < 0)
        {
         PrintFormat("ExportHighImpactNewsCsv calendar lookup failed for %s, error=%d",
                     currencies[currency_index], GetLastError());
         continue;
        }

      for(int value_index = 0; value_index < count; ++value_index)
        {
         MqlCalendarEvent event;
         ResetLastError();
         if(!CalendarEventById(values[value_index].event_id, event))
           {
            PrintFormat("ExportHighImpactNewsCsv event lookup failed: event_id=%I64d, error=%d",
                        values[value_index].event_id, GetLastError());
            continue;
           }

         if(event.importance != CALENDAR_IMPORTANCE_HIGH)
            continue;

         FileWrite(handle,
                   TimeToString(values[value_index].time, TIME_DATE | TIME_MINUTES),
                   currencies[currency_index],
                   ImportanceText(event.importance),
                   event.name);
         ++written;
        }
     }

   FileClose(handle);
   PrintFormat("ExportHighImpactNewsCsv wrote %d high-impact events to Common\\Files\\%s",
               written, InpExportFileName);
  }
