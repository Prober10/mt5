# 2026-06-24 Diagnostics Comparison

## Purpose

Compare the current diagnostic exports to find where the strategy is weak before
making another code change.

This analysis uses inferred pairing between placed setup rows and closed deal
rows. The pairing is reliable enough for strategy diagnostics because the EA
keeps only one active order or position per magic number, but future diagnostics
should log the setup/order link directly.

## Data Used

- `2026-03-01` to `2026-06-19`, v1.06 baseline
- `2026-01-01` to `2026-02-28`, v1.06 baseline
- `2025-07-01` to `2025-12-31`, v1.07 baseline
- EXP-005 and EXP-009 reports for comparison

## Main Finding

The best next target is not another broad session filter or a broad pending
expiration rule. The most repeatable weakness is the confirmed swing-size band
around `2500-5000` points.

Baseline results by swing size:

| Window | Swing band | Trades | Net | PF | Avg/trade |
| --- | --- | ---: | ---: | ---: | ---: |
| 2026 Mar-Jun | 2500-5000 | 76 | -179.75 | 0.91 | -2.37 |
| 2026 Jan-Feb | 2500-5000 | 39 | -389.09 | 0.64 | -9.98 |
| 2025 H2 | 2500-5000 | 88 | -382.02 | 0.83 | -4.34 |

The larger swing bands were stronger:

| Window | Swing band | Trades | Net | PF | Avg/trade |
| --- | --- | ---: | ---: | ---: | ---: |
| 2026 Mar-Jun | 5000-10000 | 63 | +598.00 | 1.53 | +9.49 |
| 2026 Jan-Feb | 5000-10000 | 36 | +101.21 | 1.15 | +2.81 |
| 2025 H2 | 5000-10000 | 30 | +310.09 | 1.62 | +10.34 |
| 2026 Mar-Jun | 10000+ | 10 | +205.28 | 4.55 | +20.53 |
| 2026 Jan-Feb | 10000+ | 10 | +87.31 | 1.51 | +8.73 |
| 2025 H2 | 10000+ | 4 | +90.51 | 4.17 | +22.63 |

## Why EXP-005 Helped 2026 But Hurt 2025 H2

EXP-005 restricted buy setup placement to `13-23` broker time.

In the 2026 discovery window, baseline buys were weak:

- Buy trades: 95, -331.22, PF 0.86
- Buy setup hour `0-5`: -202.54
- Buy setup hour `6-11`: -129.38

That explains why a buy-session filter helped 2026.

In 2025 H2, baseline buys were not the weak side:

- Buy trades: 132, +504.97, PF 1.22
- Sell trades: 158, +138.44, PF 1.05
- Buy setup hour `18-23`: +385.01
- Buy setup hour `6-11`: +76.65
- Buy setup hour `12-17`: +77.20

EXP-005 removed some buy exposure that was profitable in 2025 H2, so it reduced
trade count without improving drawdown.

## Why EXP-009 Helped 2026 But Hurt 2025 H2

EXP-009 tested a 6-hour pending-order expiration.

Baseline trades with fills older than 6 hours:

| Window | Fill age | Trades | Net | PF |
| --- | --- | ---: | ---: | ---: |
| 2026 Mar-Jun | 6-12h | 2 | -23.72 | 0.54 |
| 2026 Mar-Jun | 12h+ | 6 | -104.60 | 0.23 |
| 2025 H2 | 6-12h | 9 | -102.57 | 0.58 |
| 2025 H2 | 12h+ | 3 | +131.86 | n/a |

The 6-hour expiration removed bad stale fills in 2026, but in 2025 H2 it also
removed a small group of very profitable `12h+` fills. That makes the rule
regime-dependent instead of safely accepted.

## ATR Read

ATR is not stable enough yet for a broad filter.

- In 2026 Mar-Jun, `500-1000` ATR was weak: 91 trades, -467.90, PF 0.81.
- In 2025 H2, the same ATR band was strong: 115 trades, +510.33, PF 1.22.
- In 2025 H2, `500-1000` ATR buys were slightly weak, but sells were strong.

This argues against adding a simple minimum ATR filter right now.

## Pending Fill Age Read

The `15-60m` fill-age band deserves attention, but it is less clean than swing
size.

- 2026 Jan-Feb: 26 trades, -376.26, PF 0.50
- 2025 H2: 66 trades, -367.85, PF 0.75
- 2026 Mar-Jun: 45 trades, +106.29, PF 1.11

In 2026 Mar-Jun, this band was rescued by sell trades. A simple fill-age filter
could remove good sells, so it needs side-aware analysis before testing.

## Decision

Do not accept EXP-005 or EXP-009 as production defaults yet.

The next code experiment should be a simple, configurable swing-quality filter
that tests whether the weak `2500-5000` swing band can be reduced without
breaking the stronger large-swing behavior.

Suggested next experiment:

- `EXP-010: Avoid mid-sized confirmed swings`
- Candidate rule: skip setups where confirmed swing size is between `2500` and
  `5000` points.
- Test it alone against the baseline first.
- Do not stack it with EXP-005 or EXP-009 until it proves itself independently.

## Diagnostic Improvement Needed

Before deeper optimization, add direct setup-to-order tracing in diagnostics:

- setup id
- order ticket when placed
- position id when filled
- original setup hour
- original swing size
- original ATR
- pending fill age

This will remove the need for inferred pairing in future analyses.
