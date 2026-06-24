# 2026-06-24 Pending Order Expiration Discovery Test

## Purpose

Test EXP-009: add pending-order expiration to prevent old retracement setups
from remaining live indefinitely.

## Configuration

- EA version: 1.07
- Symbol: XAUUSD
- Timeframe: M15
- Model: real ticks
- Date range: 2026-03-01 to 2026-06-19
- `InpUseBuySessionFilter=true`
- `InpPendingOrderExpirationHours=6.0`
- v1.06 lot/margin guard enabled
- Diagnostics enabled

Report:

- `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v107-exp009-6h-20260301-20260619-20260624-210931.htm`

Diagnostics:

- `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v107-exp009-6h-20260301-20260619-20260624-210931-diagnostics.csv`

## Result

Comparison against v1.06 EXP-005 on the same discovery window:

| Metric | v1.06 EXP-005 | v1.07 EXP-009 6h |
| --- | ---: | ---: |
| Net profit | 1,070.29 | 1,193.71 |
| Profit factor | 1.37 | 1.44 |
| Expected payoff | 7.28 | 8.59 |
| Trades | 147 | 139 |
| Short trades won | 87 / 59.77% | 86 / 59.30% |
| Long trades won | 60 / 53.33% | 53 / 58.49% |
| Balance DD max | 233.85 / 2.19% | 227.24 / 2.13% |
| Equity DD max | 280.21 / 2.61% | 273.60 / 2.56% |
| Average lot | 0.0572 | 0.0586 |
| Max lot | 0.10 | 0.10 |

Deal-table side split:

| Side | v1.06 EXP-005 | v1.07 EXP-009 6h |
| --- | ---: | ---: |
| Buy | +234.54 / PF 1.18 | +395.82 / PF 1.37 |
| Sell | +845.41 / PF 1.52 | +806.58 / PF 1.49 |

## Interpretation

The 6-hour expiration improved the discovery window:

- Net profit increased.
- Profit factor increased.
- Trade count decreased.
- Buy-side quality improved materially.
- Drawdown improved slightly.
- Max executed lot remained capped at 0.10.

This is directionally encouraging, but still only a discovery-window result. It
must be tested on unseen windows before acceptance.

## Decision

Status: `Discovery`

EXP-009 should be validated next on `2026-01-01` to `2026-02-28`, comparing
v1.06 EXP-005 versus v1.07 EXP-009 6h.
