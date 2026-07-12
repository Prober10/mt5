# 2026-07-12 HTF Regime Diagnostics

## Purpose

Add and analyze higher-timeframe diagnostics without changing strategy behavior.

This is intentionally diagnostics-only. The EA should place the same trades as
before, but the CSV now gives enough context to ask whether weak months happen
when M15 Fibo setups fight the bigger market.

## Added Diagnostic Fields

Version: `1.12`

New setup/deal CSV columns:

- `h1_slope20_points`
- `h4_slope20_points`
- `h1_ma50_distance_points`
- `h4_ma50_distance_points`
- `h1_range_efficiency20`
- `h4_range_efficiency20`
- `h1_alignment`
- `h4_alignment`

Alignment values:

- `1`: setup direction agrees with timeframe slope.
- `-1`: setup direction is against timeframe slope.
- `0`: unavailable or neutral.

## Test Setup

- EXP-010 swing band filter: on
- News CSV guard: on
- Core session filter: off
- Buy session filter: off
- Pending expiration: `0`

## Reports

- 2025 H1: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v112-exp010-news-csv-regime-20250101-20250630-20260712-204524.htm`
- 2025 H1 diagnostics: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v112-exp010-news-csv-regime-20250101-20250630-20260712-204524-diagnostics.csv`
- 2025 H2: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v112-exp010-news-csv-regime-20250701-20251231-20260712-204633.htm`
- 2025 H2 diagnostics: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v112-exp010-news-csv-regime-20250701-20251231-20260712-204633-diagnostics.csv`
- 2026 Jan-Feb: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v112-exp010-news-csv-regime-20260101-20260228-20260712-204810.htm`
- 2026 Jan-Feb diagnostics: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v112-exp010-news-csv-regime-20260101-20260228-20260712-204810-diagnostics.csv`
- 2026 Mar-Jun: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v112-exp010-news-csv-regime-20260301-20260619-20260712-204908.htm`
- 2026 Mar-Jun diagnostics: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v112-exp010-news-csv-regime-20260301-20260619-20260712-204908-diagnostics.csv`

## Reconstructed Baseline

| Window | Trades | Net | PF | Win Rate | Avg Trade |
| --- | ---: | ---: | ---: | ---: | ---: |
| 2025 H1 | 212 | -276.02 | 0.92 | 47.6% | -1.30 |
| 2025 H2 | 195 | 1,013.70 | 1.34 | 56.4% | 5.20 |
| 2026 Jan-Feb | 58 | 284.97 | 1.25 | 53.4% | 4.91 |
| 2026 Mar-Jun | 102 | 542.37 | 1.28 | 55.9% | 5.32 |

These match the v1.10 current-candidate behavior closely, so the diagnostics
change did not alter strategy decisions.

## HTF Slope Alignment

H1 alignment:

| H1 Alignment | Trades | Net | PF | Win Rate | Avg Trade |
| --- | ---: | ---: | ---: | ---: | ---: |
| Aligned | 269 | 1,079.11 | 1.24 | 54.6% | 4.01 |
| Against | 298 | 485.91 | 1.09 | 51.0% | 1.63 |

H4 alignment:

| H4 Alignment | Trades | Net | PF | Win Rate | Avg Trade |
| --- | ---: | ---: | ---: | ---: | ---: |
| Aligned | 269 | 485.95 | 1.10 | 52.0% | 1.81 |
| Against | 298 | 1,079.07 | 1.22 | 53.4% | 3.62 |

Slope alignment is not enough. H1 alignment helps, but H4 slope alignment is
actually worse in aggregate. This is not a clean production rule.

Combined H1/H4 slope alignment:

| Group | Trades | Net | PF | Win Rate | Avg Trade |
| --- | ---: | ---: | ---: | ---: | ---: |
| Both against | 205 | 501.61 | 1.15 | 51.2% | 2.45 |
| Both aligned | 176 | 501.65 | 1.16 | 52.8% | 2.85 |
| Mixed, some aligned | 186 | 561.76 | 1.18 | 54.3% | 3.02 |

No strong separation.

## H1/H4 Range Efficiency

H1 range efficiency:

| H1 Efficiency | Trades | Net | PF | Win Rate | Avg Trade |
| --- | ---: | ---: | ---: | ---: | ---: |
| `<0.20` | 293 | 240.81 | 1.05 | 50.9% | 0.82 |
| `0.20-0.40` | 179 | 1,149.58 | 1.43 | 56.4% | 6.42 |
| `0.40+` | 95 | 174.63 | 1.11 | 51.6% | 1.84 |

H4 range efficiency:

| H4 Efficiency | Trades | Net | PF | Win Rate | Avg Trade |
| --- | ---: | ---: | ---: | ---: | ---: |
| `<0.20` | 248 | 782.19 | 1.19 | 53.2% | 3.15 |
| `0.20-0.40` | 185 | 649.70 | 1.21 | 54.6% | 3.51 |
| `0.40+` | 134 | 133.13 | 1.05 | 49.3% | 0.99 |

H1 efficiency `0.20-0.40` is interesting: it avoids the choppiest H1 conditions
without requiring a very directional H1 move. But it still needs window-level
validation before becoming a rule.

## MA50 Direction Context

H1 MA50 context:

| H1 MA Context | Trades | Net | PF | Win Rate | Avg Trade |
| --- | ---: | ---: | ---: | ---: | ---: |
| Against setup | 299 | 184.67 | 1.03 | 49.5% | 0.62 |
| Aligned with setup | 268 | 1,380.35 | 1.32 | 56.3% | 5.15 |

H4 MA50 context:

| H4 MA Context | Trades | Net | PF | Win Rate | Avg Trade |
| --- | ---: | ---: | ---: | ---: | ---: |
| Against setup | 298 | 956.18 | 1.19 | 53.0% | 3.21 |
| Aligned with setup | 269 | 608.84 | 1.13 | 52.4% | 2.26 |

H1 MA50 alignment is the strongest feature found so far, but it is not universal
across direction and window.

H1 MA50 aligned by window:

| Window | Trades | Net | PF | Win Rate | Avg Trade |
| --- | ---: | ---: | ---: | ---: | ---: |
| 2025 H1 | 100 | 330.65 | 1.21 | 54.0% | 3.31 |
| 2025 H2 | 83 | 747.22 | 1.68 | 62.7% | 9.00 |
| 2026 Jan-Feb | 31 | -66.03 | 0.91 | 45.2% | -2.13 |
| 2026 Mar-Jun | 54 | 368.51 | 1.38 | 57.4% | 6.82 |

This improves 2025 H1, 2025 H2, and 2026 Mar-Jun, but fails Jan-Feb 2026.

## Direction-Specific MA50 Read

| Group | Trades | Net | PF | Win Rate | Avg Trade |
| --- | ---: | ---: | ---: | ---: | ---: |
| Buy, H1 MA against | 120 | 430.98 | 1.21 | 54.2% | 3.59 |
| Buy, H1 MA aligned | 152 | 120.63 | 1.04 | 51.3% | 0.79 |
| Sell, H1 MA against | 179 | -246.31 | 0.92 | 46.4% | -1.38 |
| Sell, H1 MA aligned | 116 | 1,259.72 | 1.79 | 62.9% | 10.86 |

This is the clearest practical insight:

- Sell setups are much better when aligned with H1 MA50 context.
- Buy setups are not better when aligned; counter-H1-MA buys performed better.

But a sell-only H1 MA rule is still not automatically acceptable:

| Window | Rule: buys unchanged, sells require H1 MA alignment | Trades | Net | PF |
| --- | --- | ---: | ---: | ---: |
| 2025 H1 | Candidate | 139 | 180.64 | 1.08 |
| 2025 H2 | Candidate | 125 | 1,042.27 | 1.63 |
| 2026 Jan-Feb | Candidate | 37 | -67.16 | 0.92 |
| 2026 Mar-Jun | Candidate | 87 | 655.58 | 1.42 |

It helps three windows but breaks Jan-Feb 2026 because Jan-Feb had profitable
sell setups against H1 MA context.

## Decision

Do not code a production filter yet.

The new diagnostics are valuable, but the first analysis says:

- H1 MA50 context is promising, especially for sells.
- H1 range efficiency is also promising.
- H4 context is not useful in the simple forms tested here.
- A broad HTF-alignment rule would overfit and would have failed Jan-Feb 2026.

## Next Candidate

The next useful experiment should be narrow and explicit:

- Test a **sell-side H1 MA50 alignment filter** as EXP-013.
- Keep buys unchanged.
- Keep EXP-010 and news CSV guard enabled.
- Reject it unless Jan-Feb can be protected or explained by another simple
  condition.

This is not accepted yet; it is just the first HTF-backed candidate worth a real
Strategy Tester run.
