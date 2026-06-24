# Backtest Summary

Average lot size is calculated from executed entry deals, not from canceled
pending orders.

## Discovery Window: 2026-03-01 to 2026-06-19

| Test | Status | Net | PF | Trades | Equity DD | Avg Lot | Avg Buy Lot | Avg Sell Lot | Notes |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Baseline / v1.00-v1.03 | Baseline | 584.26 | 1.15 | 180 | 609.67 / 5.58% | 0.0614 | 0.0605 | 0.0624 | Original accepted behavior |
| v1.01 daily risk reservation | Rejected | 242.79 | 1.08 | 133 | 658.51 / 6.13% | 0.0505 | 0.0506 | 0.0503 | Reduced trades and performance |
| v1.02 setup rejection marking | Rejected | 164.77 | 1.05 | 135 | 810.30 / 7.51% | 0.0514 | 0.0521 | 0.0506 | Changed behavior negatively |
| v1.04 diagnostics | Accepted instrumentation | 584.26 | 1.15 | 180 | 609.67 / 5.58% | 0.0614 | 0.0605 | 0.0624 | Same behavior as baseline; diagnostics added |
| EXP-005 buy setup session filter | Discovery | 1,068.82 | 1.35 | 147 | 297.11 / 2.77% | 0.0607 | 0.0548 | 0.0647 | Promising on discovery window |
| v1.06 baseline with lot/margin guard | Current baseline | 546.43 | 1.14 | 180 | 606.10 / 5.55% | 0.0578 | 0.0576 | 0.0580 | Max lot capped at 0.10 |
| v1.06 EXP-005 with lot/margin guard | Current discovery | 1,070.29 | 1.37 | 147 | 280.21 / 2.61% | 0.0572 | 0.0538 | 0.0595 | Current best discovery result |
| v1.07 EXP-009 6h pending expiration | Discovery | 1,193.71 | 1.44 | 139 | 273.60 / 2.56% | 0.0586 | 0.0568 | 0.0598 | Best discovery result so far |

## Validation Window: 2026-01-01 to 2026-02-28

| Test | Status | Net | PF | Trades | Equity DD | Avg Lot | Avg Buy Lot | Avg Sell Lot | Notes |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Baseline | Validation baseline | -108.61 | 0.95 | 103 | 486.10 / 4.85% | 0.0547 | 0.0531 | 0.0559 | Slightly losing unseen window |
| EXP-005 buy setup session filter | Validation | 55.88 | 1.03 | 88 | 420.96 / 4.11% | 0.0545 | 0.0483 | 0.0578 | Improved, but only modestly |
| v1.06 baseline with lot/margin guard | Current validation baseline | -98.46 | 0.96 | 103 | 475.95 / 4.75% | 0.0525 | 0.0511 | 0.0536 | Max lot capped at 0.10 |
| v1.06 EXP-005 with lot/margin guard | Current validation | 50.06 | 1.03 | 88 | 420.96 / 4.11% | 0.0518 | 0.0457 | 0.0550 | Still improves Jan-Feb modestly |
| v1.07 EXP-009 6h pending expiration | Validation | 88.26 | 1.05 | 86 | 383.22 / 3.74% | 0.0535 | 0.0467 | 0.0571 | Improves Jan-Feb versus EXP-005 |

## Side Split Highlights

Discovery baseline:

- Buy trades: 95, -294.98, PF 0.88
- Sell trades: 85, +880.21, PF 1.54

Discovery EXP-005:

- Buy trades: 60, +251.95, PF 1.20
- Sell trades: 87, +826.53, PF 1.48

Discovery v1.06 baseline:

- Buy trades: 95, -330.25, PF 0.86
- Sell trades: 85, +877.65, PF 1.57

Discovery v1.06 EXP-005:

- Buy trades: 60, +234.54, PF 1.18
- Sell trades: 87, +845.41, PF 1.52

Discovery v1.07 EXP-009 6h:

- Buy trades: 53, +395.82, PF 1.37
- Sell trades: 86, +806.58, PF 1.49

2026 Jan-Feb baseline:

- Buy trades: 45, -18.31, PF 0.98
- Sell trades: 58, -92.88, PF 0.93

2026 Jan-Feb EXP-005:

- Buy trades: 30, +175.55, PF 1.30
- Sell trades: 58, -122.25, PF 0.91

2026 Jan-Feb v1.06 baseline:

- Buy trades: 45, -5.98, PF 0.99
- Sell trades: 58, -95.06, PF 0.93

2026 Jan-Feb v1.06 EXP-005:

- Buy trades: 30, +175.95, PF 1.31
- Sell trades: 58, -128.47, PF 0.91

2026 Jan-Feb v1.07 EXP-009 6h:

- Buy trades: 30, +188.45, PF 1.33
- Sell trades: 56, -102.77, PF 0.92

## Current Read

Under the v1.06 lot/margin guard, EXP-005 still improves both the discovery
window and the first unseen validation window. EXP-009's 6-hour pending-order
expiration improves both of those tested windows further, but still needs longer
2025 validation. The max executed lot is now 0.10 in the rerun reports. The next
validation windows are:

- 2025-07-01 to 2025-12-31
- 2025-01-01 to 2025-06-30
