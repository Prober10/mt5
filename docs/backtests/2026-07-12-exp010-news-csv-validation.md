# 2026-07-12 EXP-010 News CSV Validation

## Purpose

Rerun the broader EXP-010 validation set with funded-account news protection
enabled through the exported CSV news source.

This checks whether the current Fibo candidate still behaves reasonably when
the The Trading Pit high-impact-news restriction is included in Strategy Tester.

## Shared Setup

- Symbol: XAUUSD
- Timeframe: M15
- News CSV: `Common\Files\FiboEA\high-impact-news.csv`
- News events in CSV: `924`
- News guard: on
- News source: CSV
- News currencies: `USD`
- News block window: 2 minutes before through 2 minutes after
- Pending cancellation window: 5 minutes before
- Buy session filter: off
- Swing band filter: on
- Avoid swing band: `2500` to `5000` points
- Pending order expiration: `0`

## Results

| Window | Net | PF | Trades | Balance DD | Equity DD | Avg Lot | Max Lot |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 2026 Jan-Feb | 284.97 | 1.25 | 58 | 224.46 / 2.22% | 265.16 / 2.62% | 0.0505 | 0.10 |
| 2026 Mar-Jun | 542.37 | 1.28 | 102 | 249.06 / 2.32% | 259.58 / 2.42% | 0.0522 | 0.10 |
| 2025 H2 | 1,013.70 | 1.34 | 195 | 223.63 / 2.01% | 240.03 / 2.15% | 0.0883 | 0.10 |
| 2025 H1 | -276.02 | 0.92 | 212 | 606.54 / 6.00% | 619.55 / 6.13% | 0.0943 | 0.10 |

## Reports

- 2026 Jan-Feb: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v110-exp010-news-csv-20260101-20260228-20260712-183055.htm`
- 2026 Jan-Feb diagnostics: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v110-exp010-news-csv-20260101-20260228-20260712-183055-diagnostics.csv`
- 2026 Mar-Jun: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v110-exp010-news-csv-20260301-20260619-20260626-234105.htm`
- 2026 Mar-Jun diagnostics: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v110-exp010-news-csv-20260301-20260619-20260626-234105-diagnostics.csv`
- 2025 H2: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v110-exp010-news-csv-20250701-20251231-20260712-183159.htm`
- 2025 H2 diagnostics: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v110-exp010-news-csv-20250701-20251231-20260712-183159-diagnostics.csv`
- 2025 H1: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v110-exp010-news-csv-20250101-20250630-20260712-183355.htm`
- 2025 H1 diagnostics: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v110-exp010-news-csv-20250101-20250630-20260712-183355-diagnostics.csv`

## Comparison To EXP-010 Without News Guard

| Window | No-News Net | News CSV Net | Change | No-News Trades | News CSV Trades | No-News Equity DD | News CSV Equity DD |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| 2026 Jan-Feb | 377.54 | 284.97 | -92.57 | 64 | 58 | 307.26 / 3.04% | 265.16 / 2.62% |
| 2026 Mar-Jun | 622.53 | 542.37 | -80.16 | 106 | 102 | 279.45 / 2.60% | 259.58 / 2.42% |
| 2025 H2 | 992.61 | 1,013.70 | +21.09 | 203 | 195 | 271.94 / 2.65% | 240.03 / 2.15% |
| 2025 H1 | -421.89 | -276.02 | +145.87 | 223 | 212 | 775.03 / 7.66% | 619.55 / 6.13% |

## Interpretation

The CSV news guard does not invalidate EXP-010. It reduces trades in every
window, lowers drawdown in every window, hurts 2026 net profit, slightly helps
2025 H2, and materially reduces the 2025 H1 loss.

However, 2025 H1 is still negative and still reaches `6.13%` equity drawdown,
which is too close to a typical funded-account max-drawdown limit. The next
strategy work should still focus on reducing 2025 H1 weakness before treating
the candidate as production-ready.
