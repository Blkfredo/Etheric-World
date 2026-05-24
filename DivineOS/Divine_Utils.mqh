#ifndef __ETHERIC_DIVINE_UTILS_MQH__
#define __ETHERIC_DIVINE_UTILS_MQH__

class CDivineUtils
  {
public:
   static string BoolText(const bool value)
     {
      return value ? "true" : "false";
     }

   static string CsvEscape(string value)
     {
      StringReplace(value,"\"","\"\"");
      return "\"" + value + "\"";
     }
  };

#endif

