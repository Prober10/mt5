# 2026-06-24 EXP-009 Validation: 2026 Jan-Feb

## Purpose

Validate the 6-hour pending-order expiration on the first unseen window already
used for EXP-005 validation.

## Window

- Symbol: XAUUSD
- Timeframe: M15
- Model: real ticks
- Date range: 2026-01-01 to 2026-02-28
- v1.06 lot/margin guard enabled
- `InpUseBuySessionFilter=true`
- `InpPendingOrderExpirationHours=6.0`

## Reports

EXP-009:

- Report: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v107-exp009-6h-20260101-20260228-20260624-211353.htm`
- Diagnostics: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v107-exp009-6h-20260101-20260228-20260624-211353-diagnostics.csv`

Comparison reports:

- Baseline v1.06: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v106-baseline-20260101-20260228-20260624-205738.htm`
- EXP-005 v1.06: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v106-exp005-20260101-20260228-20260624-205809.htm`

## Result

| Metric | v1.06 Baseline | v1.06 EXP-005 | v1.07 EXP-009 6h |
| --- | ---: | ---: | ---: |
| Net profit | -98.46 | +50.06 | +88.26 |
| Profit factor | 0.96 | 1.03 | 1.05 |
| Expected payoff | -0.96 | 0.57 | 1.03 |
| Trades | 103 | 88 | 86 |
| Balance DD max | 475.55 / 4.75% | 392.29 / 3.84% | 354.55 / 3.47% |
| Equity DD max | 475.95 / 4.75% | 420.96 / 4.11% | 383.22 / 3.74% |
| Average lot | 0.0525 | 0.0518 | 0.0535 |
| Max lot | 0.10 | 0.10 | 0.10 |

Side split:

| Side | v1.06 EXP-005 | v1.07 EXP-009 6h |
| --- | ---: | ---: |
| Buy | +175.95 / PF 1.31 | +188.45 / PF 1.33 |
| Sell | -128.47 / PF 0.91 | -102.77 / PF 0.92 |

## Interpretation

EXP-009 improved the first unseen validation window versus EXP-005:

- Net profit increased.
- Profit factor increased slightly.
- Drawdown decreased.
- Trade count decreased from 88 to 86.
- Buy side stayed strong.
- Sell side remained negative, but less negative than EXP-005.

This supports the order-lifecycle rationale, but the result is still modest and
only one validation window.

## Decision

Status: `Validation`

EXP-009 is more credible after passing the first unseen window. It still needs
longer 2025 validation before acceptance.
