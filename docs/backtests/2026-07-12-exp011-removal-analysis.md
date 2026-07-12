# 2026-07-12 EXP-011 Removal Analysis

## Purpose

Understand what the EXP-011 core-session filter removed from the current
EXP-010 + news CSV candidate.

The goal is not to optimize one backtest. The goal is to identify whether the
removed trades share a sensible quality pattern that can lead to a less
restrictive and more live-robust rule.

## Method

Diagnostics from the EXP-010 + news CSV runs were reconstructed into executed
trades by pairing:

- the placed setup row,
- the entry deal row,
- and the closing deal row.

Trades were then split by setup hour:

- Core session: `12` through `17`
- Outside core: all other setup hours

Important caveat: these are executed-trade diagnostics from EXP-010. They are
not a perfect simulation of EXP-011, because blocking an outside-core setup can
change pending-order lifecycle and allow later setups to appear. This analysis
is for pattern discovery only.

## Core Versus Outside-Core In EXP-010

| Window | Group | Trades | Net | PF | Win Rate | Avg Lot |
| --- | --- | ---: | ---: | ---: | ---: | ---: |
| 2025 H1 | Outside core | 146 | -801.49 | 0.71 | 41.8% | 0.0927 |
| 2025 H1 | Core | 66 | 525.47 | 1.61 | 60.6% | 0.0979 |
| 2025 H2 | Outside core | 132 | 574.40 | 1.28 | 54.5% | 0.0864 |
| 2025 H2 | Core | 63 | 439.30 | 1.50 | 60.3% | 0.0924 |
| 2026 Jan-Feb | Outside core | 39 | 37.97 | 1.05 | 48.7% | 0.0454 |
| 2026 Jan-Feb | Core | 19 | 247.00 | 1.81 | 63.2% | 0.0611 |
| 2026 Mar-Jun | Outside core | 76 | 466.31 | 1.33 | 56.6% | 0.0514 |
| 2026 Mar-Jun | Core | 26 | 76.06 | 1.14 | 53.8% | 0.0542 |

Core was cleaner in three windows, but outside-core was very profitable in 2025
H2 and 2026 Mar-Jun. This explains why EXP-011 reduced drawdown but gave up too
much opportunity.

## Outside-Core By Window And Time Block

| Window | Time Block | Trades | Net | PF |
| --- | --- | ---: | ---: | ---: |
| 2025 H1 | 00-05 | 48 | -14.19 | 0.98 |
| 2025 H1 | 06-11 | 61 | -538.34 | 0.54 |
| 2025 H1 | 18-23 | 37 | -248.96 | 0.71 |
| 2025 H2 | 00-05 | 53 | 115.86 | 1.14 |
| 2025 H2 | 06-11 | 47 | 246.19 | 1.34 |
| 2025 H2 | 18-23 | 32 | 212.35 | 1.43 |
| 2026 Jan-Feb | 00-05 | 16 | -147.86 | 0.66 |
| 2026 Jan-Feb | 06-11 | 8 | 272.87 | 6.83 |
| 2026 Jan-Feb | 18-23 | 15 | -87.04 | 0.76 |
| 2026 Mar-Jun | 00-05 | 29 | 320.50 | 1.71 |
| 2026 Mar-Jun | 06-11 | 22 | 44.28 | 1.10 |
| 2026 Mar-Jun | 18-23 | 25 | 101.53 | 1.20 |

The weak time blocks are not stable enough for a simple hour ban. For example,
`06-11` was terrible in 2025 H1, but positive in every other tested window.

## Outside-Core By Direction And Time Block

| Group | Trades | Net | PF | Win Rate |
| --- | ---: | ---: | ---: | ---: |
| Buy 00-05 | 72 | -282.40 | 0.81 | 45.8% |
| Buy 06-11 | 59 | 70.71 | 1.07 | 50.8% |
| Buy 18-23 | 55 | 70.83 | 1.07 | 50.9% |
| Sell 00-05 | 74 | 556.71 | 1.57 | 56.8% |
| Sell 06-11 | 79 | -45.71 | 0.97 | 48.1% |
| Sell 18-23 | 54 | -92.95 | 0.92 | 44.4% |

This suggests direction matters, but the pattern is still not clean enough to
use alone.

## Outside-Core By Setup Quality

Swing size:

| Swing Bucket | Trades | Net | PF | Win Rate |
| --- | ---: | ---: | ---: | ---: |
| `<1000` | 55 | 60.30 | 1.13 | 49.1% |
| `1000-2500` | 217 | -317.21 | 0.93 | 47.5% |
| `5000-8000` | 83 | 26.10 | 1.01 | 49.4% |
| `8000+` | 38 | 508.00 | 2.14 | 63.2% |

ATR:

| ATR Bucket | Trades | Net | PF | Win Rate |
| --- | ---: | ---: | ---: | ---: |
| `<150` | 4 | -72.60 | 0.00 | 0.0% |
| `150-250` | 49 | -22.34 | 0.96 | 49.0% |
| `250-400` | 93 | -330.34 | 0.79 | 43.0% |
| `400+` | 247 | 702.47 | 1.15 | 53.0% |

Slope:

| Slope Bucket | Trades | Net | PF | Win Rate |
| --- | ---: | ---: | ---: | ---: |
| Down | 67 | 291.59 | 1.29 | 56.7% |
| Down strong | 134 | 295.52 | 1.12 | 52.2% |
| Up | 72 | -119.96 | 0.89 | 43.1% |
| Up strong | 120 | -189.96 | 0.92 | 46.7% |

The cleanest outside-core quality signal is confirmed swing size `8000+`.

## Large Outside-Core Swings By Window

Outside-core trades with confirmed swing size `8000+`:

| Window | Trades | Net | PF | Win Rate |
| --- | ---: | ---: | ---: | ---: |
| 2025 H1 | 3 | 41.24 | 2.24 | 66.7% |
| 2025 H2 | 7 | 51.53 | 1.48 | 57.1% |
| 2026 Jan-Feb | 11 | 12.86 | 1.06 | 45.5% |
| 2026 Mar-Jun | 17 | 402.37 | 5.23 | 76.5% |

This is a small sample, but it was positive in every tested window and has a
reasonable market rationale: very large confirmed impulses may carry enough
market structure to justify taking the retracement setup outside the core
session.

## Simple Executed-Trade What-If

This is not a full Strategy Tester run, only a diagnostic reconstruction:

Keep:

- all core-session trades, and
- outside-core trades only when confirmed swing size is `8000+`.

| Window | Trades | Net | PF | Win Rate |
| --- | ---: | ---: | ---: | ---: |
| 2025 H1 | 69 | 566.71 | 1.63 | 60.9% |
| 2025 H2 | 70 | 490.83 | 1.50 | 60.0% |
| 2026 Jan-Feb | 30 | 259.86 | 1.51 | 56.7% |
| 2026 Mar-Jun | 43 | 478.43 | 1.73 | 62.8% |

Because order lifecycle changes when setups are blocked, this must be tested in
the EA before drawing conclusions.

## Next Candidate

EXP-012 should test a less restrictive version of EXP-011:

- Allow all setups during the core session `12-17`.
- Outside the core session, allow only setups with confirmed swing size at or
  above `8000` points.
- Keep EXP-010 and the news CSV guard enabled.

This is a better live-oriented hypothesis than simply narrowing the session,
because it says: normal setups need the cleaner session, but unusually large
market-structure swings can be valid outside it.
