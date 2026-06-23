# 2026-06-23 EXP-005 Validation: 2026 Jan-Feb

## Purpose

Validate EXP-005 on an unseen window before the March-June discovery period.
This compares the current baseline behavior against the buy-session filter using
the same symbol, timeframe, model, and risk settings.

## Window

- Symbol: XAUUSD
- Timeframe: M15
- Model: real ticks
- Date range: 2026-01-01 to 2026-02-28
- Initial deposit: 10,000 USD

## Reports

Baseline, buy-session filter disabled:

- Report: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-baseline-20260101-20260228-20260623-221606.htm`
- Diagnostics: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-baseline-20260101-20260228-20260623-221606-diagnostics.csv`

EXP-005, buy-session filter enabled:

- Report: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-exp005-20260101-20260228-20260623-222050.htm`
- Diagnostics: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-exp005-20260101-20260228-20260623-222050-diagnostics.csv`

## Result

| Metric | Baseline | EXP-005 |
| --- | ---: | ---: |
| Net profit | -108.61 | +55.88 |
| Profit factor | 0.95 | 1.03 |
| Expected payoff | -1.05 | +0.64 |
| Total trades | 103 | 88 |
| Short trades won | 58 / 46.55% | 58 / 46.55% |
| Long trades won | 45 / 48.89% | 30 / 56.67% |
| Balance DD max | 485.70 / 4.85% | 392.29 / 3.84% |
| Equity DD max | 486.10 / 4.85% | 420.96 / 4.11% |

Deal-table split:

| Side | Baseline Net | EXP-005 Net | Notes |
| --- | ---: | ---: | --- |
| Buy | -18.31 | +175.55 | Filter improved buy behavior |
| Sell | -92.88 | -122.25 | Sell side was weak in this window |

## Interpretation

EXP-005 improved this unseen window versus baseline:

- Turned net result from negative to slightly positive.
- Improved profit factor from 0.95 to 1.03.
- Reduced total trades from 103 to 88.
- Reduced balance drawdown and equity drawdown.
- Improved buy-side behavior.

However, this is not strong enough to accept the rule yet:

- Profit factor is only barely above 1.0.
- Sell trades were weak in both baseline and EXP-005.
- This is only one validation window.

## Decision

Status: `Validation`

EXP-005 passes the first unseen validation window directionally, but remains
unaccepted. Continue validation on longer 2025 windows before trusting it.
