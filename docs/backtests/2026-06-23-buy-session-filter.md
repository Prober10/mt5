# 2026-06-23 Buy Session Filter Discovery Test

## Purpose

Test EXP-005: keep sell setups unchanged, but restrict buy setup placement to a
stronger historical window.

## Configuration

- EA version: 1.05
- Symbol: XAUUSD
- Timeframe: M15
- Model: real ticks
- Date range: 2026-03-01 to 2026-06-19
- `InpUseBuySessionFilter=true`
- `InpBuySessionStartHour=13`
- `InpBuySessionEndHour=23`
- Diagnostics enabled

Output files:

- Report: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-20260623-215902.htm`
- Diagnostics: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-20260623-215902-diagnostics.csv`

## Result

| Metric | Baseline 1.04 | EXP-005 1.05 |
| --- | ---: | ---: |
| Net profit | 584.26 | 1,068.82 |
| Profit factor | 1.15 | 1.35 |
| Expected payoff | 3.25 | 7.27 |
| Total trades | 180 | 147 |
| Short trades won | 85 / 61.18% | 87 / 59.77% |
| Long trades won | 95 / 46.32% | 60 / 53.33% |
| Balance DD max | 564.96 / 5.19% | 250.75 / 2.34% |
| Equity DD max | 609.67 / 5.58% | 297.11 / 2.77% |

Trade split from the deal table:

- Buy trades: 60, +251.95, PF 1.20
- Sell trades: 87, +826.53, PF 1.48

Month split:

| Month | Trades | Net | PF |
| --- | ---: | ---: | ---: |
| 2026.03 | 43 | +575.29 | 1.84 |
| 2026.04 | 35 | +67.95 | 1.09 |
| 2026.05 | 42 | +354.63 | 1.41 |
| 2026.06 | 27 | +80.61 | 1.12 |

## Notes

- Discovery-window performance improved materially versus baseline.
- Drawdown improved more than profit, which is useful for funded-account work.
- The rule is still not accepted. It has only passed the discovery window.
- The filter controls buy setup placement time, not fill time. Pending buy limits
  placed inside the allowed window may still fill later outside the window.
- Some buy trades still entered during `00-06` because of pending order fills.

## Decision

Status: `Discovery`

EXP-005 is promising enough to validate on unseen periods, but should not be
trusted yet. Before acceptance, test at least:

- 2025-01-01 to 2025-06-30
- 2025-07-01 to 2025-12-31
- 2026-01-01 to 2026-02-28

Potential follow-up if validation is mixed: add an explicit pending buy
expiration/cancellation rule outside the allowed session and test it as a
separate experiment.
