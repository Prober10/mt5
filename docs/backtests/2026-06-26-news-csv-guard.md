# 2026-06-26 CSV News Guard Backtest

## Purpose

Verify that funded-account news protection can be included in Strategy Tester
using an exported MT5 Economic Calendar CSV.

## Export

`ExportHighImpactNewsCsv` was run in the normal MT5 terminal.

- Output: `Common\Files\FiboEA\high-impact-news.csv`
- Date range: `2025.01.01 00:00` to `2026.12.31 23:59`
- Currency: `USD`
- High-impact events written: `924`

## Test Setup

- Symbol: XAUUSD
- Timeframe: M15
- Date range: `2026-03-01` to `2026-06-19`
- Buy session filter: off
- Swing band filter: on
- Avoid swing band: `2500` to `5000` points
- Pending order expiration: `0`
- News guard: on
- News source: CSV
- News currencies: `USD`
- News block window: 2 minutes before through 2 minutes after
- Pending cancellation window: 5 minutes before

## Result

- Report: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v110-exp010-news-csv-20260301-20260619-20260626-234105.htm`
- Diagnostics: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v110-exp010-news-csv-20260301-20260619-20260626-234105-diagnostics.csv`
- Net profit: `542.37`
- Profit factor: `1.28`
- Total trades: `102`
- Balance DD maximal: `249.06 (2.32%)`
- Equity DD maximal: `259.58 (2.42%)`
- Average entry lot: `0.0522`
- Maximum entry lot: `0.10`

Reference candidate without news guard:

- Net profit: `622.53`
- Profit factor: `1.31`
- Total trades: `106`
- Equity DD maximal: `279.45 (2.60%)`
- Average entry lot: `0.0512`
- Maximum entry lot: `0.10`

## Interpretation

The CSV-backed guard is working in Strategy Tester. Tester logs showed blocked
entries near high-impact USD events and pending-order cancellations 5 minutes
before restricted events.

For this window, adding funded news protection removed 4 trades, reduced net
profit by `80.16`, and slightly reduced equity drawdown.
