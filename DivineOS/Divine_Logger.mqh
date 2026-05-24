#ifndef __ETHERIC_DIVINE_LOGGER_MQH__
#define __ETHERIC_DIVINE_LOGGER_MQH__

#include "Divine_Types.mqh"
#include "Divine_Config.mqh"
#include "Divine_Utils.mqh"

class CDivineLogger
  {
private:
   void AppendCsv(const string file_name,const string header,const string row)
     {
      bool exists = FileIsExist(file_name);
      int handle = FileOpen(file_name,FILE_READ|FILE_WRITE|FILE_TXT|FILE_ANSI|FILE_SHARE_READ|FILE_SHARE_WRITE);
      if(handle == INVALID_HANDLE)
        {
         Print(DIVINE_SYSTEM_NAME + " [LOG] FILE_OPEN_FAILED " + file_name + " code=" + IntegerToString(GetLastError()));
         return;
        }

      if(!exists || FileSize(handle) == 0)
         FileWriteString(handle,header + "\r\n");

      FileSeek(handle,0,SEEK_END);
      FileWriteString(handle,row + "\r\n");
      FileClose(handle);
     }

   string Timestamp(void)
     {
      return TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS);
     }

public:
   void Info(const string area,const string message)
     {
      Print(DIVINE_SYSTEM_NAME + " [" + area + "] " + message);
     }

   void Reason(const string area,const string symbol,const string reason_code,const bool allowed)
     {
      Print(DIVINE_SYSTEM_NAME + " [" + area + "] " + symbol + " " + reason_code + " allowed=" + (allowed ? "true" : "false"));
     }

   void StateLog(const long sequence_id,const string from_state,const string to_state,const string reason_code,const string result)
     {
      string row = StringFormat("%I64d,%s,%s,%s,%s,%s,%s",
                                sequence_id,
                                CDivineUtils::CsvEscape(Timestamp()),
                                CDivineUtils::CsvEscape(DIVINE_SYSTEM_NAME),
                                CDivineUtils::CsvEscape(from_state),
                                CDivineUtils::CsvEscape(to_state),
                                CDivineUtils::CsvEscape(reason_code),
                                CDivineUtils::CsvEscape(result));
      AppendCsv(DIVINE_STATE_LOG,"sequence_id,timestamp,system,from_state,to_state,reason_code,result",row);
     }

   void TradeLog(const long sequence_id,const string mode,const string symbol,const string action,const double lots,const string reason_code,const string result)
     {
      string row = StringFormat("%I64d,%s,%s,%s,%s,%s,%.2f,%s,%s",
                                sequence_id,
                                CDivineUtils::CsvEscape(Timestamp()),
                                CDivineUtils::CsvEscape(DIVINE_SYSTEM_NAME),
                                CDivineUtils::CsvEscape(mode),
                                CDivineUtils::CsvEscape(symbol),
                                CDivineUtils::CsvEscape(action),
                                lots,
                                CDivineUtils::CsvEscape(reason_code),
                                CDivineUtils::CsvEscape(result));
      AppendCsv(DIVINE_TRADE_LOG,"sequence_id,timestamp,system,mode,symbol,action,lots,reason_code,result",row);
     }

   void ErrorLog(const long sequence_id,const string area,const string reason_code,const string detail)
     {
      string row = StringFormat("%I64d,%s,%s,%s,%s,%s",
                                sequence_id,
                                CDivineUtils::CsvEscape(Timestamp()),
                                CDivineUtils::CsvEscape(DIVINE_SYSTEM_NAME),
                                CDivineUtils::CsvEscape(area),
                                CDivineUtils::CsvEscape(reason_code),
                                CDivineUtils::CsvEscape(detail));
      AppendCsv(DIVINE_ERROR_LOG,"sequence_id,timestamp,system,area,reason_code,detail",row);
     }

   void RelayLog(const long sequence_id,const string lifecycle,const string symbol,const string reason_code,const bool allowed,const string result)
     {
      string row = StringFormat("%I64d,%s,%s,%s,%s,%s,%s,%s",
                                sequence_id,
                                CDivineUtils::CsvEscape(Timestamp()),
                                CDivineUtils::CsvEscape(DIVINE_SYSTEM_NAME),
                                CDivineUtils::CsvEscape(lifecycle),
                                CDivineUtils::CsvEscape(symbol),
                                CDivineUtils::CsvEscape(reason_code),
                                CDivineUtils::CsvEscape(CDivineUtils::BoolText(allowed)),
                                CDivineUtils::CsvEscape(result));
      AppendCsv(DIVINE_RELAY_LOG,"sequence_id,timestamp,system,lifecycle,symbol,reason_code,allowed,result",row);
     }
  };

#endif
