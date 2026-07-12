# 2026-07-12 EXP-011 Core Session Filter

## Purpose

Test whether restricting all Fibo setups to a broker-time core session improves
robustness after EXP-010 and funded-account news protection are included.

This is a robustness test, not an attempt to make one backtest look better.

## Setup

- Symbol: XAUUSD
- Timeframe: M15
- EXP-010 swing band filter: on
- Avoid swing band: `2500` to `5000` points
- News CSV guard: on
- News source: CSV
- News currencies: `USD`
- Buy session filter: off
- Pending order expiration: `0`
- EXP-011 core session filter: on
- Core session: `12` through `17` broker time

## Results

| Window | Net | PF | Trades | Balance DD | Equity DD | Avg Lot | Max Lot |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 2026 Mar-Jun | 188.58 | 1.32 | 32 | 115.64 / 1.13% | 138.94 / 1.36% | 0.0519 | 0.10 |
| 2026 Jan-Feb | 237.62 | 1.59 | 23 | 135.32 / 1.35% | 179.58 / 1.78% | 0.0617 | 0.10 |
| 2025 H2 | 281.60 | 1.22 | 81 | 190.54 / 1.89% | 232.64 / 2.31% | 0.0898 | 0.10 |
| 2025 H1 | 214.67 | 1.17 | 82 | 279.40 / 2.77% | 308.30 / 3.06% | 0.0974 | 0.10 |

## Reports

- 2026 Mar-Jun: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v111-exp011-core12-17-news-csv-20260301-20260619-20260712-184933.htm`
- 2026 Mar-Jun diagnostics: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v111-exp011-core12-17-news-csv-20260301-20260619-20260712-184933-diagnostics.csv`
- 2026 Jan-Feb: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v111-exp011-core12-17-news-csv-20260101-20260228-20260712-185057.htm`
- 2026 Jan-Feb diagnostics: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v111-exp011-core12-17-news-csv-20260101-20260228-20260712-185057-diagnostics.csv`
- 2025 H2: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v111-exp011-core12-17-news-csv-20250701-20251231-20260712-185148.htm`
- 2025 H2 diagnostics: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v111-exp011-core12-17-news-csv-20250701-20251231-20260712-185148-diagnostics.csv`
- 2025 H1: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v111-exp011-core12-17-news-csv-20250101-20250630-20260712-185319.htm`
- 2025 H1 diagnostics: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v111-exp011-core12-17-news-csv-20250101-20250630-20260712-185319-diagnostics.csv`

## Comparison To EXP-010 + News CSV Guard

| Window | EXP-010 News Net | EXP-011 Net | Net Change | EXP-010 Trades | EXP-011 Trades | EXP-010 Equity DD | EXP-011 Equity DD |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 2026 Mar-Jun | 542.37 | 188.58 | -353.79 | 102 | 32 | 259.58 / 2.42% | 138.94 / 1.36% |
| 2026 Jan-Feb | 284.97 | 237.62 | -47.35 | 58 | 23 | 265.16 / 2.62% | 179.58 / 1.78% |
| 2025 H2 | 1,013.70 | 281.60 | -732.10 | 195 | 81 | 240.03 / 2.15% | 232.64 / 2.31% |
| 2025 H1 | -276.02 | 214.67 | +490.69 | 212 | 82 | 619.55 / 6.13% | 308.30 / 3.06% |

## Interpretation

EXP-011 is promising for risk control because it made every tested window
positive and brought the weak 2025 H1 window down to `3.06%` equity drawdown.

It is also very restrictive. It removed most trades in 2026 Mar-Jun and 2025
H2, and 2025 H2 drawdown did not improve despite the large trade reduction.

Do not accept this as production default yet. The next step should either test
a less restrictive session variant or confirm that the lower trade frequency is
acceptable for the funded-account objective.
