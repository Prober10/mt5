#ifndef ADAPTIVE_AI_CONFIG_MQH
#define ADAPTIVE_AI_CONFIG_MQH

input group "Signal"
input ENUM_TIMEFRAMES InpAdaptiveTimeframe = PERIOD_M15;
input int             InpATRPeriod = 14;
input int             InpSlopeLookbackBars = 20;
input int             InpRangeLookbackBars = 48;

input group "Action Templates"
input bool   InpAllowAdaptiveBuy = true;
input bool   InpAllowAdaptiveSell = true;
input double InpATRStopMultiplier = 1.50;
input double InpRewardRiskRatio = 1.00;

input group "Learning"
input bool   InpEnableLearning = true;
input bool   InpTesterExploration = true;
input double InpExplorationPercent = 5.0;
input int    InpMinimumSamples = 20;
input double InpMinimumAverageR = 0.05;
input double InpLearningDecay = 0.98;
input string InpMemoryFileName = "AdaptiveAI\\memory.csv";

input group "Protection"
input double InpAdaptiveRiskPercent = 0.25;
input double InpAdaptiveMaxDailyClosedLossPercent = 1.00;
input double InpAdaptiveMinLotSize = 0.01;
input double InpAdaptiveMaxLotSize = 0.10;
input double InpAdaptiveLotStep = 0.01;
input double InpAdaptiveMinMarginLevelPercent = 500.0;
input double InpMaxSpreadPoints = 500.0;

input group "Execution"
input ulong  InpAdaptiveMagicNumber = 790101;
input int    InpAdaptiveDeviationPoints = 20;
input string InpAdaptiveOrderComment = "Adaptive AI EA";

input group "Diagnostics"
input bool   InpAdaptiveEnableDiagnostics = true;
input string InpAdaptiveDiagnosticsFileName = "AdaptiveAI\\diagnostics.csv";

#endif
