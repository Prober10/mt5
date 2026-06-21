#ifndef FIBO_EA_SETUP_TRACKER_MQH
#define FIBO_EA_SETUP_TRACKER_MQH

#include "Types.mqh"

class CSetupTracker
  {
private:
   string m_start_key;
   string m_end_key;
   datetime m_last_price_rejection_start;
   datetime m_last_price_rejection_end;
   datetime m_last_volume_rejection_start;
   datetime m_last_volume_rejection_end;

public:
   void Initialize(const string symbol, const ulong magic)
     {
      const string prefix = StringFormat("FiboEA.%I64u.%s", magic, symbol);
      m_start_key = prefix + ".start";
      m_end_key = prefix + ".end";
      m_last_price_rejection_start = 0;
      m_last_price_rejection_end = 0;
      m_last_volume_rejection_start = 0;
      m_last_volume_rejection_end = 0;
     }

   bool IsProcessed(const SwingData &swing) const
     {
      if(!swing.valid || !GlobalVariableCheck(m_start_key) || !GlobalVariableCheck(m_end_key))
         return false;

      return ((datetime)GlobalVariableGet(m_start_key) == swing.start_time &&
              (datetime)GlobalVariableGet(m_end_key) == swing.end_time);
     }

   bool MarkProcessed(const SwingData &swing) const
     {
      if(!swing.valid)
         return false;

      const bool start_saved = (GlobalVariableSet(m_start_key, (double)swing.start_time) != 0);
      const bool end_saved = (GlobalVariableSet(m_end_key, (double)swing.end_time) != 0);
      return start_saved && end_saved;
     }

   bool ShouldLogPriceRejection(const SwingData &swing)
     {
      if(!swing.valid)
         return false;
      if(m_last_price_rejection_start == swing.start_time &&
         m_last_price_rejection_end == swing.end_time)
         return false;

      m_last_price_rejection_start = swing.start_time;
      m_last_price_rejection_end = swing.end_time;
      return true;
     }

   bool ShouldLogVolumeRejection(const SwingData &swing)
     {
      if(!swing.valid)
         return false;
      if(m_last_volume_rejection_start == swing.start_time &&
         m_last_volume_rejection_end == swing.end_time)
         return false;

      m_last_volume_rejection_start = swing.start_time;
      m_last_volume_rejection_end = swing.end_time;
      return true;
     }
  };

#endif
