# 2026-06-24 EXP-010: Swing Band Filter

## Purpose

Test whether avoiding the weak confirmed swing-size band from diagnostics
improves robustness without stacking other filters.

## Rule Tested

- Code version: `1.08`
- `InpUseSwingBandFilter=true`
- `InpAvoidSwingMinPoints=2500`
- `InpAvoidSwingMaxPoints=5000`
- `InpUseBuySessionFilter=false`
- `InpPendingOrderExpirationHours=0`

The rule skips setups where the confirmed ZigZag impulse swing is between
`2500` and `5000` points.

## Reports

Discovery:

- Report: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v108-exp010-20260301-20260619-20260624-235022.htm`
- Diagnostics: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v108-exp010-20260301-20260619-20260624-235022-diagnostics.csv`

Validation, Jan-Feb 2026:

- Report: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v108-exp010-20260101-20260228-20260624-235101.htm`
- Diagnostics: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v108-exp010-20260101-20260228-20260624-235101-diagnostics.csv`

Validation, 2025 H2:

- Report: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v108-exp010-20250701-20251231-20260624-235128.htm`
- Diagnostics: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v108-exp010-20250701-20251231-20260624-235128-diagnostics.csv`

Validation, 2025 H1:

- Baseline report: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v108-baseline-20250101-20250630-20260624-235926.htm`
- Baseline diagnostics: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v108-baseline-20250101-20250630-20260624-235926-diagnostics.csv`
- EXP-010 report: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v108-exp010-20250101-20250630-20260625-000221.htm`
- EXP-010 diagnostics: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v108-exp010-20250101-20250630-20260625-000221-diagnostics.csv`

## Result

| Window | Test | Net | PF | Trades | Equity DD | Avg Lot | Max Lot |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 2026 Mar-Jun | Baseline | 546.43 | 1.14 | 180 | 606.10 / 5.55% | 0.0578 | 0.10 |
| 2026 Mar-Jun | EXP-010 | 622.53 | 1.31 | 106 | 279.45 / 2.60% | 0.0512 | 0.10 |
| 2026 Jan-Feb | Baseline | -98.46 | 0.96 | 103 | 475.95 / 4.75% | 0.0525 | 0.10 |
| 2026 Jan-Feb | EXP-010 | 377.54 | 1.31 | 64 | 307.26 / 3.04% | 0.0495 | 0.10 |
| 2025 H2 | Baseline | 643.41 | 1.12 | 290 | 378.90 / 3.72% | 0.0808 | 0.10 |
| 2025 H2 | EXP-010 | 992.61 | 1.32 | 203 | 271.94 / 2.65% | 0.0883 | 0.10 |
| 2025 H1 | Baseline | -772.65 | 0.87 | 300 | 1,200.02 / 11.80% | 0.0870 | 0.10 |
| 2025 H1 | EXP-010 | -421.89 | 0.89 | 223 | 775.03 / 7.66% | 0.0938 | 0.10 |

Side split:

| Window | Side | Trades | Net | PF |
| --- | --- | ---: | ---: | ---: |
| 2026 Mar-Jun | Buy | 54 | +77.97 | 1.07 |
| 2026 Mar-Jun | Sell | 52 | +544.56 | 1.63 |
| 2026 Jan-Feb | Buy | 29 | +71.67 | 1.12 |
| 2026 Jan-Feb | Sell | 35 | +305.87 | 1.50 |
| 2025 H2 | Buy | 95 | +398.09 | 1.28 |
| 2025 H2 | Sell | 108 | +594.52 | 1.36 |
| 2025 H1 | Buy | 112 | -88.15 | 0.96 |
| 2025 H1 | Sell | 111 | -333.74 | 0.82 |

Blocked setup rows:

- 2026 Mar-Jun: 2,390 `swing_band_blocked` rows
- 2026 Jan-Feb: 1,200 `swing_band_blocked` rows
- 2025 H2: 3,859 `swing_band_blocked` rows
- 2025 H1: 3,545 `swing_band_blocked` rows

## Interpretation

EXP-010 is the strongest strategy experiment so far because it improves all
four tested windows:

- Discovery net and PF improved while drawdown fell sharply.
- Jan-Feb 2026 moved from losing to profitable.
- 2025 H2 also improved, unlike EXP-005 and EXP-009.
- 2025 H1 remained losing, but loss and drawdown were both reduced
  substantially.
- Both buy and sell sides were profitable in the first three EXP-010 windows.
- Max lot remained capped at `0.10`.

This result supports the diagnostic hypothesis that the `2500-5000` confirmed
swing band is a repeatable weakness.

## Decision

Status: `Accepted as current candidate, not production-ready`

Keep the filter configurable for now, but treat EXP-010 as the current best
candidate strategy layer.

Do not treat the EA as production-ready yet. The 2025 H1 validation still lost
money and reached `7.66%` equity drawdown with EXP-010, which is too high for a
funded-account target. The next strategy step should analyze the 2025 H1
weakness before adding more filters or making EXP-010 the default.
