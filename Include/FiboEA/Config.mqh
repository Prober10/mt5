#ifndef FIBO_EA_CONFIG_MQH
#define FIBO_EA_CONFIG_MQH

enum ENUM_NEWS_DATA_SOURCE
  {
   NEWS_SOURCE_AUTO = 0,
   NEWS_SOURCE_CALENDAR = 1,
   NEWS_SOURCE_CSV = 2
  };

input group "Signal"
input ENUM_TIMEFRAMES InpSignalTimeframe = PERIOD_M15;
input int             InpZigZagDepth = 12;
input int             InpZigZagDeviation = 5;
input int             InpZigZagBackstep = 3;
input int             InpZigZagLookbackBars = 1000;
input double          InpFibonacciEntry = 0.79;
input bool            InpAllowBuy = true;
input bool            InpAllowSell = true;

input group "Session Filters"
input bool InpUseBuySessionFilter = false;
input int  InpBuySessionStartHour = 13;
input int  InpBuySessionEndHour = 23;
input bool InpUseCoreSessionFilter = false;
input int  InpCoreSessionStartHour = 12;
input int  InpCoreSessionEndHour = 17;

input group "Swing Filters"
input bool   InpUseSwingBandFilter = false;
input double InpAvoidSwingMinPoints = 2500.0;
input double InpAvoidSwingMaxPoints = 5000.0;

input group "Protection"
input double InpStopBuffer = 0.10;
input double InpRiskPercent = 0.50;
input double InpMaxDailyClosedLossPercent = 1.00;
input double InpMinLotSize = 0.01;
input double InpMaxLotSize = 0.10;
input double InpLotStep = 0.01;
input double InpMinMarginLevelPercent = 500.0;

input group "News Protection"
input bool                  InpUseNewsGuard = false;
input ENUM_NEWS_DATA_SOURCE InpNewsDataSource = NEWS_SOURCE_AUTO;
input string                InpNewsCurrencies = "USD";
input string                InpNewsCsvFileName = "FiboEA\\high-impact-news.csv";
input int                   InpNewsMinutesBefore = 2;
input int                   InpNewsMinutesAfter = 2;
input int                   InpNewsCancelPendingMinutesBefore = 5;
input bool                  InpNewsFailSafeBlock = true;

input group "Execution"
input ulong InpMagicNumber = 790015;
input int   InpDeviationPoints = 20;
input string InpOrderComment = "Fibo 79 EA";
input double InpPendingOrderExpirationHours = 0.0;

input group "Diagnostics"
input bool   InpEnableDiagnostics = false;
input string InpDiagnosticsFileName = "FiboEA\\diagnostics.csv";

#endif
