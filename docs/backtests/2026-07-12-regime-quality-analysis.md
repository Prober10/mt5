# 2026-07-12 Regime Quality Analysis

## Purpose

Compare strong months and weak months for the current realistic candidate:

- EXP-010 swing band filter enabled.
- News CSV guard enabled.
- Buy session filter disabled.
- Pending expiration disabled.

The goal is to avoid chasing tiny green slices and instead identify what kind
of market regime makes the Fibo setup worth trading.

## Month Groups

Strong months:

- `2025-08`
- `2025-11`
- `2026-01`
- `2026-03`

Weak months:

- `2025-02`
- `2025-04`
- `2025-05`
- `2026-05`

Flat/small months:

- `2025-01`
- `2025-03`
- `2025-06`
- `2025-09`
- `2026-04`
- `2026-06`

## Group Summary

| Group | Trades | Net | PF | Win Rate | Avg Trade | Avg Swing | Avg ATR | Avg Slope |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Strong months | 131 | 1,434.39 | 1.80 | 61.8% | 10.95 | 4,253 | 877 | -141 |
| Weak months | 117 | -498.15 | 0.81 | 43.6% | -4.26 | 2,995 | 644 | -224 |
| Flat/small months | 201 | 200.59 | 1.06 | 50.7% | 1.00 | 2,045 | 493 | 95 |

Strong months had larger confirmed swings and higher ATR. Flat months had the
smallest structure and volatility. Weak months were not simply low-volatility;
they had enough movement to trigger trades, but the setup quality was poor.

## Direction

| Group | Trades | Net | PF | Win Rate | Avg Trade |
| --- | ---: | ---: | ---: | ---: | ---: |
| Strong buy | 68 | 279.89 | 1.24 | 54.4% | 4.12 |
| Strong sell | 63 | 1,154.50 | 2.87 | 69.8% | 18.33 |
| Weak buy | 67 | -234.85 | 0.84 | 46.3% | -3.51 |
| Weak sell | 50 | -263.30 | 0.76 | 40.0% | -5.27 |

Strong months were heavily carried by sell setups. Weak months lost on both
sides, so a simple buy-only or sell-only fix is not enough.

## Time Blocks

| Group | Trades | Net | PF | Win Rate | Avg Trade |
| --- | ---: | ---: | ---: | ---: | ---: |
| Strong 00-05 | 34 | 53.46 | 1.09 | 50.0% | 1.57 |
| Strong 06-11 | 30 | 710.84 | 4.21 | 80.0% | 23.69 |
| Strong 12-17 | 43 | 381.26 | 1.58 | 60.5% | 8.87 |
| Strong 18-23 | 24 | 288.83 | 1.95 | 58.3% | 12.03 |
| Weak 00-05 | 28 | -66.11 | 0.88 | 46.4% | -2.36 |
| Weak 06-11 | 22 | -135.10 | 0.72 | 40.9% | -6.14 |
| Weak 12-17 | 38 | 115.41 | 1.17 | 52.6% | 3.04 |
| Weak 18-23 | 29 | -412.35 | 0.51 | 31.0% | -14.22 |

The `12-17` block was the best weak-month block, but strong months also made
significant money outside it. This confirms that pure session restriction is
too blunt.

## Swing And ATR

Swing buckets:

| Group | Trades | Net | PF | Win Rate | Avg Trade |
| --- | ---: | ---: | ---: | ---: | ---: |
| Strong `1000-2500` | 61 | 419.01 | 1.44 | 59.0% | 6.87 |
| Strong `5000-8000` | 39 | 626.51 | 2.06 | 66.7% | 16.06 |
| Strong `8000+` | 17 | 366.47 | 3.80 | 70.6% | 21.56 |
| Weak `1000-2500` | 81 | -191.97 | 0.89 | 45.7% | -2.37 |
| Weak `5000-8000` | 26 | -389.18 | 0.50 | 30.8% | -14.97 |
| Weak `8000+` | 4 | 77.60 | 3.33 | 75.0% | 19.40 |

ATR buckets:

| Group | Trades | Net | PF | Win Rate | Avg Trade |
| --- | ---: | ---: | ---: | ---: | ---: |
| Strong `250-400` | 21 | 133.95 | 1.63 | 57.1% | 6.38 |
| Strong `400+` | 98 | 1,285.76 | 1.91 | 64.3% | 13.12 |
| Weak `250-400` | 29 | -388.67 | 0.44 | 27.6% | -13.40 |
| Weak `400+` | 83 | -126.08 | 0.93 | 48.2% | -1.52 |

Large movement alone is not enough. In weak months, `5000-8000` swings were bad
and `400+` ATR was still slightly negative. The missing ingredient is probably
trend/range quality, not just volatility.

## Setup Age

| Group | Trades | Net | PF | Win Rate | Avg Trade |
| --- | ---: | ---: | ---: | ---: | ---: |
| Strong `<1h` | 15 | 119.81 | 1.60 | 60.0% | 7.99 |
| Strong `1-6h` | 109 | 1,201.15 | 1.78 | 62.4% | 11.02 |
| Weak `<1h` | 14 | 236.60 | 2.39 | 71.4% | 16.90 |
| Weak `1-6h` | 97 | -542.37 | 0.75 | 41.2% | -5.59 |
| Weak `6-24h` | 5 | -148.18 | 0.11 | 0.0% | -29.64 |

Fresh fills were good even in weak months. Most weak-month damage came from
setups filled after `1-6h`, with older fills also bad. This gives a useful live
hypothesis: stale retracements may be dangerous in poor regimes.

## Conclusion

The current diagnostics point to regime quality, not a single simple filter:

- Strong months have larger swings and higher ATR, but volatility alone does
  not explain the difference.
- Pure session filtering is too blunt.
- Direction-only filtering is too blunt.
- Tiny positive pockets are not meaningful enough.
- Weak months are likely range/chop or failed-continuation regimes where the
  retracement entry gets filled after the original impulse edge has decayed.

## Next Useful Work

Add diagnostics for higher-timeframe and regime quality before adding another
entry filter:

- H1 trend alignment with setup direction.
- H4 trend alignment with setup direction.
- H1/H4 ADX or trend-strength proxy.
- Recent range efficiency/chop score.
- Distance from H1/H4 moving average.
- Whether the setup is with or against the higher-timeframe slope.

Then rerun the same candidate and compare strong, weak, and flat months using
those features. This is more likely to produce a live-usable rule than more
session slicing.
