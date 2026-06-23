# 2026-06-23 Diagnostics Analysis

## Source Files

- Report: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-20260623-213259.htm`
- Diagnostics: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-20260623-213259-diagnostics.csv`

## Baseline Confirmation

The diagnostic build preserved the accepted baseline behavior:

- Net profit: 584.26
- Profit factor: 1.15
- Total trades: 180
- Short trades: 85, 61.18% won
- Long trades: 95, 46.32% won
- Balance DD max: 564.96 / 5.19%
- Equity DD max: 609.67 / 5.58%

Diagnostics exported:

- Setup placed rows: 353
- Filled setups: 180
- Canceled setups: 173
- Rejected setup rows: 1,377
- Deal rows: 360

## Main Findings

The current edge is mostly short-side:

- Buy trades: 95 trades, -294.98, PF 0.88, 46.3% won
- Sell trades: 85 trades, +880.21, PF 1.54, 61.2% won

Monthly split confirms that buy behavior degraded after March:

| Side | Month | Trades | Net | PF |
| --- | --- | ---: | ---: | ---: |
| Buy | 2026.03 | 31 | +281.97 | 1.51 |
| Buy | 2026.04 | 22 | -155.37 | 0.74 |
| Buy | 2026.05 | 25 | -192.63 | 0.72 |
| Buy | 2026.06 | 17 | -228.95 | 0.57 |
| Sell | 2026.03 | 21 | +431.74 | 2.69 |
| Sell | 2026.04 | 24 | +62.35 | 1.11 |
| Sell | 2026.05 | 26 | +201.74 | 1.36 |
| Sell | 2026.06 | 14 | +184.38 | 1.72 |

Session split shows the weakest zone:

| Side / Session | Trades | Net | PF |
| --- | ---: | ---: | ---: |
| Buy 00-06 | 32 | -162.72 | 0.80 |
| Buy 07-12 | 23 | -281.24 | 0.59 |
| Buy 13-17 | 24 | +75.02 | 1.14 |
| Buy 18-23 | 16 | +73.96 | 1.22 |
| Sell 00-06 | 25 | +484.98 | 2.21 |
| Sell 07-12 | 23 | +5.94 | 1.01 |
| Sell 13-17 | 25 | +127.86 | 1.24 |
| Sell 18-23 | 12 | +261.43 | 2.72 |

The most damaging clusters were buy trades in early sessions:

- Buy May 00-06: 9 trades, -185.08, PF 0.35
- Buy May 07-12: 5 trades, -152.87, PF 0.24
- Buy April 07-12: 5 trades, -145.51, PF 0.26

## Setup Quality Clues

ATR context:

- ATR 500-1000 points: 91 trades, -387.38, PF 0.84
- ATR 1000-1500 points: 58 trades, +538.68, PF 1.50
- ATR 1500-2500 points: 26 trades, +443.57, PF 2.37

Swing size:

- 1500-3000 points: 48 trades, -238.27, PF 0.82
- 3000-5000 points: 58 trades, -25.15, PF 0.98
- 5000-8000 points: 52 trades, +305.56, PF 1.29
- >8000 points: 21 trades, +488.01, PF 4.77

Order fill age:

- 1-15 minutes: 56 trades, -426.34, PF 0.73
- 1-3 hours: 33 trades, +706.67, PF 2.68
- >6 hours: 8 trades, -127.35, PF 0.32

Fill age is useful evidence, but it is less directly actionable than side,
session, ATR, or swing-size filters because the EA cannot know the final fill age
before placing the order.

## Rough Filter Hypotheses

These are historical what-if summaries from the filled trades only. They are not
replacement MT5 backtests because removing trades can affect later equity,
volume, and daily-loss behavior.

| Hypothesis | Trades | Net | PF | Notes |
| --- | ---: | ---: | ---: | --- |
| Baseline | 180 | +585.23 | 1.15 | Current behavior |
| Sell only | 85 | +880.21 | 1.54 | Cleanest evidence, fewer trades |
| All sells + buys only 13-23 | 125 | +1029.19 | 1.41 | Keeps better buy sessions |
| All sells + buys only 18-23 | 101 | +954.17 | 1.49 | More selective |
| All sells + buys with ATR >= 1000 | 130 | +1126.55 | 1.45 | Strong volatility clue |
| ATR >= 1000 only | 86 | +1085.10 | 1.77 | Strong but cuts many trades |
| All sells + buys with swing >= 5000 | 123 | +991.31 | 1.42 | Filters weaker impulses |

## Recommendation

The first real strategy experiment should be simple and explainable. The most
defensible candidates are:

1. Trade sells only as a control experiment.
2. Keep sells, but only allow buys during 13-23 broker time.
3. Add a minimum ATR filter, likely around 1000 points, and test it separately.
4. Add a minimum confirmed swing-size filter and test it separately.

Do not combine every strong-looking filter at once. Start with one rule, rerun
the same backtest, and only keep it if the behavior becomes more robust rather
than merely prettier.
