#ifndef ADAPTIVE_AI_MEMORY_STORE_MQH
#define ADAPTIVE_AI_MEMORY_STORE_MQH

#include "Types.mqh"
#include "LearningModel.mqh"

class CAdaptiveMemoryStore
  {
private:
   string m_file_name;

public:
   void Initialize(const string file_name)
     {
      m_file_name = file_name;
      FolderCreate("AdaptiveAI", FILE_COMMON);
     }

   bool Load(CAdaptiveLearningModel &model) const
     {
      const int handle = FileOpen(m_file_name, FILE_READ | FILE_CSV | FILE_COMMON | FILE_ANSI);
      if(handle == INVALID_HANDLE)
         return true;

      while(!FileIsEnding(handle))
        {
         ActionStats stats;
         stats.state_key = FileReadString(handle);
         if(stats.state_key == "")
            break;
         stats.action = (AdaptiveAction)FileReadInteger(handle);
         stats.samples = FileReadNumber(handle);
         stats.wins = FileReadNumber(handle);
         stats.losses = FileReadNumber(handle);
         stats.total_r = FileReadNumber(handle);
         stats.recent_r = FileReadNumber(handle);
         stats.last_update = (datetime)FileReadInteger(handle);
         model.Upsert(stats);
        }

      FileClose(handle);
      return true;
     }

   bool Save(const CAdaptiveLearningModel &model) const
     {
      const int handle = FileOpen(m_file_name, FILE_WRITE | FILE_CSV | FILE_COMMON | FILE_ANSI);
      if(handle == INVALID_HANDLE)
        {
         PrintFormat("Unable to save adaptive memory file: %s", m_file_name);
         return false;
        }

      for(int index = 0; index < model.Count(); ++index)
        {
         ActionStats stats;
         if(!model.GetByIndex(index, stats))
            continue;

         FileWrite(handle, stats.state_key, (int)stats.action, stats.samples,
                   stats.wins, stats.losses, stats.total_r, stats.recent_r,
                   (long)stats.last_update);
        }

      FileClose(handle);
      return true;
     }
  };

#endif
