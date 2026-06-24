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

## Validation Window: 2026-01-01 to 2026-02-28

| Test | Status | Net | PF | Trades | Equity DD | Avg Lot | Avg Buy Lot | Avg Sell Lot | Notes |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Baseline | Validation baseline | -108.61 | 0.95 | 103 | 486.10 / 4.85% | 0.0547 | 0.0531 | 0.0559 | Slightly losing unseen window |
| EXP-005 buy setup session filter | Validation | 55.88 | 1.03 | 88 | 420.96 / 4.11% | 0.0545 | 0.0483 | 0.0578 | Improved, but only modestly |

## Side Split Highlights

Discovery baseline:

- Buy trades: 95, -294.98, PF 0.88
- Sell trades: 85, +880.21, PF 1.54

Discovery EXP-005:

- Buy trades: 60, +251.95, PF 1.20
- Sell trades: 87, +826.53, PF 1.48

2026 Jan-Feb baseline:

- Buy trades: 45, -18.31, PF 0.98
- Sell trades: 58, -92.88, PF 0.93

2026 Jan-Feb EXP-005:

- Buy trades: 30, +175.55, PF 1.30
- Sell trades: 58, -122.25, PF 0.91

## Current Read

EXP-005 improved both the discovery window and the first unseen validation
window. It is still not accepted because one modest validation result is not
enough. The next validation windows are:

- 2025-07-01 to 2025-12-31
- 2025-01-01 to 2025-06-30
