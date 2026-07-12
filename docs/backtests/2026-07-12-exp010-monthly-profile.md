# 2026-07-12 EXP-010 News CSV Monthly Profile

## Purpose

Check whether the current realistic Fibo candidate has a usable monthly rhythm,
not just acceptable half-year totals.

Candidate tested:

- EXP-010 swing band filter enabled.
- News CSV guard enabled.
- Buy session filter disabled.
- Pending expiration disabled.

## Monthly Results

| Month | Trades | Net | PF | Win Rate | Avg Trade |
| --- | ---: | ---: | ---: | ---: | ---: |
| 2025-01 | 51 | 8.22 | 1.01 | 49.0% | 0.16 |
| 2025-02 | 36 | -150.81 | 0.77 | 41.7% | -4.19 |
| 2025-03 | 43 | 54.26 | 1.08 | 51.2% | 1.26 |
| 2025-04 | 33 | -120.80 | 0.83 | 45.5% | -3.66 |
| 2025-05 | 22 | -69.20 | 0.85 | 45.5% | -3.15 |
| 2025-06 | 27 | 2.31 | 1.00 | 51.9% | 0.09 |
| 2025-07 | 39 | 77.81 | 1.13 | 53.8% | 2.00 |
| 2025-08 | 45 | 269.33 | 1.51 | 57.8% | 5.99 |
| 2025-09 | 42 | 62.09 | 1.09 | 50.0% | 1.48 |
| 2025-10 | 27 | 136.55 | 1.26 | 55.6% | 5.06 |
| 2025-11 | 16 | 358.51 | 3.33 | 75.0% | 22.41 |
| 2025-12 | 26 | 109.41 | 1.24 | 57.7% | 4.21 |
| 2026-01 | 32 | 180.55 | 1.30 | 53.1% | 5.64 |
| 2026-02 | 26 | 104.42 | 1.19 | 53.8% | 4.02 |
| 2026-03 | 38 | 626.00 | 2.25 | 68.4% | 16.47 |
| 2026-04 | 23 | 38.92 | 1.08 | 52.2% | 1.69 |
| 2026-05 | 26 | -157.34 | 0.77 | 42.3% | -6.05 |
| 2026-06 | 15 | 34.79 | 1.12 | 53.3% | 2.32 |

## Read

This monthly profile is not strong enough for a funded-account strategy yet.

The half-year totals hide too much instability:

- 2025 H1 had three meaningfully negative months and two flat months.
- 2025 H2 was positive, but `2025-11` contributed a large share of the net with
  only 16 trades.
- 2026 was positive through the tested date, but `2026-03` carried most of the
  result.
- Several positive months were too small to matter, such as `2025-01`,
  `2025-06`, `2026-04`, and `2026-06`.

## Direction Notes

Worst direction-month clusters:

| Group | Trades | Net |
| --- | ---: | ---: |
| 2025-03 sell setups | 25 | -179.52 |
| 2026-01 buy setups | 15 | -112.46 |
| 2025-02 sell setups | 15 | -98.23 |
| 2025-04 sell setups | 14 | -84.60 |
| 2026-05 buy setups | 12 | -78.95 |
| 2026-05 sell setups | 14 | -78.39 |
| 2025-09 buy setups | 19 | -73.54 |
| 2026-04 buy setups | 10 | -67.54 |
| 2025-05 buy setups | 15 | -67.12 |
| 2025-02 buy setups | 21 | -52.58 |

The losses are not isolated to one side only. Both buy and sell setups can fail
badly depending on month and regime.

## Decision

Do not chase tiny green slices such as `+$40` over a half-year. That is not a
meaningful edge.

Skip EXP-012 for now. The `8000+` outside-core exception has too little economic
weight to justify coding before we solve the bigger issue.

The next useful work should target regime quality, not narrower calendar slices:

- identify months where the setup is flat or negative,
- compare their volatility/trend/range structure,
- and add a filter only if it has a live-market explanation and preserves enough
  trade frequency.
