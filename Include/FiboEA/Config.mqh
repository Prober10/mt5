#ifndef FIBO_EA_CONFIG_MQH
#define FIBO_EA_CONFIG_MQH

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

input group "Protection"
input double InpStopBuffer = 0.10;
input double InpRiskPercent = 0.50;
input double InpMaxDailyClosedLossPercent = 1.00;

input group "Execution"
input ulong InpMagicNumber = 790015;
input int   InpDeviationPoints = 20;
input string InpOrderComment = "Fibo 79 EA";

input group "Diagnostics"
input bool   InpEnableDiagnostics = false;
input string InpDiagnosticsFileName = "FiboEA\\diagnostics.csv";

#endif
