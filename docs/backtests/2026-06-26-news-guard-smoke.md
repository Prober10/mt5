# 2026-06-26 News Guard Smoke Test

## Purpose

Verify that the v1.09 news guard compiles and can be toggled by the automated
runner.

This was not a strategy validation test.

## Compile

MetaEditor compile result:

- `0 errors`
- `0 warnings`

## Smoke Tests

Window:

- Symbol: XAUUSD
- Timeframe: M15
- Date range: `2026-06-01` to `2026-06-05`

News guard enabled:

- Report: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v109-news-guard-smoke-20260601-20260605-20260626-224418.htm`
- Diagnostics: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v109-news-guard-smoke-20260601-20260605-20260626-224418-diagnostics.csv`
- Trades: 0
- Tester log: `News guard fail-safe active: calendar_unavailable. New entries blocked.`

News guard disabled:

- Report: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v109-news-guard-off-smoke-20260601-20260605-20260626-224556.htm`
- Diagnostics: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v109-news-guard-off-smoke-20260601-20260605-20260626-224556-diagnostics.csv`
- Trades: 6
- Net: -113.62
- Profit factor: 0.44
- Equity DD: 193.49 / 1.92%

## Interpretation

The news guard is intentionally fail-safe. In this tester run, MT5 calendar data
was unavailable, so enabling the guard blocked all new entries.

Keep `InpUseNewsGuard=false` for normal strategy backtests. Enable it for live
funded-account protection after confirming the terminal can access MT5 Economic
Calendar data.
