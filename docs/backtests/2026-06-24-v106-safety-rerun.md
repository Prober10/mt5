# 2026-06-24 v1.06 Safety-Layer Rerun

## Purpose

Rerun the key baseline and EXP-005 comparisons after adding the lot-size and
margin safety guard in version 1.06.

Safety defaults:

- `InpMinLotSize=0.01`
- `InpMaxLotSize=0.10`
- `InpLotStep=0.01`
- `InpMinMarginLevelPercent=500.0`

Average lot size is calculated from executed entry deals.

## Discovery Window: 2026-03-01 to 2026-06-19

| Test | Net | PF | Trades | Equity DD | Avg Lot | Max Lot |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| v1.06 baseline | 546.43 | 1.14 | 180 | 606.10 / 5.55% | 0.0578 | 0.10 |
| v1.06 EXP-005 | 1,070.29 | 1.37 | 147 | 280.21 / 2.61% | 0.0572 | 0.10 |

Side split:

| Test | Buy Net / PF | Sell Net / PF |
| --- | ---: | ---: |
| v1.06 baseline | -330.25 / 0.86 | +877.65 / 1.57 |
| v1.06 EXP-005 | +234.54 / 1.18 | +845.41 / 1.52 |

Reports:

- Baseline: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v106-baseline-20260301-20260619-20260624-205615.htm`
- EXP-005: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v106-exp005-20260301-20260619-20260624-205659.htm`

## Validation Window: 2026-01-01 to 2026-02-28

| Test | Net | PF | Trades | Equity DD | Avg Lot | Max Lot |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| v1.06 baseline | -98.46 | 0.96 | 103 | 475.95 / 4.75% | 0.0525 | 0.10 |
| v1.06 EXP-005 | +50.06 | 1.03 | 88 | 420.96 / 4.11% | 0.0518 | 0.10 |

Side split:

| Test | Buy Net / PF | Sell Net / PF |
| --- | ---: | ---: |
| v1.06 baseline | -5.98 / 0.99 | -95.06 / 0.93 |
| v1.06 EXP-005 | +175.95 / 1.31 | -128.47 / 0.91 |

Reports:

- Baseline: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v106-baseline-20260101-20260228-20260624-205738.htm`
- EXP-005: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v106-exp005-20260101-20260228-20260624-205809.htm`

## Decision

The safety layer slightly changed performance by capping lots at 0.10, but it did
not invalidate the EXP-005 direction:

- EXP-005 still improves the discovery window materially.
- EXP-005 still improves the first unseen validation window modestly.
- Maximum executed lot is now 0.10 in all rerun reports.

Continue future validation with the v1.06 safety layer enabled.
