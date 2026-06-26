# 2026-06-26 Analysis: 2025 H1 Weakness After EXP-010

## Purpose

Analyze why the EA still lost money in `2025-01-01` to `2025-06-30` after the
EXP-010 swing-band filter improved the result.

## Result Recap

| Window | Test | Net | PF | Trades | Equity DD |
| --- | --- | ---: | ---: | ---: | ---: |
| 2025 H1 | Baseline | -772.65 | 0.87 | 300 | 1,200.02 / 11.80% |
| 2025 H1 | EXP-010 | -421.89 | 0.89 | 223 | 775.03 / 7.66% |

EXP-010 helped, but not enough.

## 2025 H1 EXP-010 Breakdown

Monthly:

| Month | Trades | Net | PF |
| --- | ---: | ---: | ---: |
| 2025-01 | 54 | -36.42 | 0.94 |
| 2025-02 | 40 | -64.65 | 0.91 |
| 2025-03 | 44 | +13.06 | 1.02 |
| 2025-04 | 33 | -120.80 | 0.83 |
| 2025-05 | 25 | -209.16 | 0.66 |
| 2025-06 | 27 | -3.92 | 0.99 |

Side:

| Side | Trades | Net | PF |
| --- | ---: | ---: | ---: |
| Buy | 112 | -88.15 | 0.96 |
| Sell | 111 | -333.74 | 0.82 |

The sell side was the larger problem, especially March-April, but May also had
large buy losses.

## Session Pattern

EXP-010 by setup-hour block:

| Setup hour block | 2025 H1 | 2025 H2 | 2026 Jan-Feb | 2026 Mar-Jun |
| --- | ---: | ---: | ---: | ---: |
| 0-5 | -14.19 | +66.72 | -147.86 | +320.50 |
| 6-11 | -631.10 | +178.89 | +396.23 | +138.88 |
| 12-17 | +477.90 | +485.21 | +216.21 | +61.62 |
| 18-23 | -254.50 | +261.79 | -87.04 | +101.53 |

The `12-17` broker-time setup block is the cleanest robust positive pattern. It
is positive in every EXP-010 window.

The `6-11` block caused most of the 2025 H1 damage, but it was profitable in the
other three windows. A simple ban on `6-11` would likely overfit 2025 H1.

## Fill-Age Pattern

EXP-010 by pending fill age:

| Fill age | 2025 H1 | 2025 H2 | 2026 Jan-Feb | 2026 Mar-Jun |
| --- | ---: | ---: | ---: | ---: |
| <15m | -124.50 | +603.76 | +167.05 | +12.08 |
| 15-60m | +113.34 | +177.61 | -54.55 | +61.57 |
| 1-3h | -83.31 | +142.58 | +123.15 | +503.24 |
| 3-6h | -152.42 | +58.95 | +226.71 | +164.15 |
| 6-12h | -71.54 | -122.15 | -84.36 | -23.72 |
| 12h+ | -103.46 | +131.86 | -0.46 | -94.79 |

The `6-12h` fill-age bucket is negative in every EXP-010 window, but it is a
small sample. A broad 6-hour expiration already failed because it removed
profitable `12h+` fills in 2025 H2.

## ATR Pattern

ATR is still not clean enough for the next rule:

- 2025 H1 `500-1000`: +10.19, PF 1.01
- 2025 H2 `500-1000`: +717.96, PF 1.79
- 2026 Jan-Feb `500-1000`: +162.63, PF 1.35
- 2026 Mar-Jun `500-1000`: -11.00, PF 0.99

A simple ATR filter does not explain the 2025 H1 weakness.

## Interpretation

The next issue is probably not another swing-size filter. After EXP-010, the
most robust clue is time-of-day:

- `12-17` broker time is positive in every window.
- `6-11` is extremely bad in 2025 H1 but good elsewhere.
- `18-23` is mixed.

This suggests testing a conservative core-session filter that allows both buy
and sell setups only during `12-17` broker time.

That would intentionally trade less often. The goal would be funded-account
survivability and consistency, not maximum trade count.

## Next Candidate

EXP-011: Core Setup Session Filter

- Add an optional all-direction setup session filter.
- Candidate: allow setups only from `12` through `17` broker time.
- Test only after EXP-010 is enabled.
- Compare against EXP-010, not against the old baseline.

Acceptance should require:

- 2025 H1 drawdown materially below EXP-010's `7.66%`.
- No major damage to 2025 H2.
- PF and drawdown remain healthy in both 2026 windows.

Do not stack EXP-005 or EXP-009 into this test.
