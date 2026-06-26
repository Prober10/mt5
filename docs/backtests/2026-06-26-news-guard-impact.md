# 2026-06-26 News Guard Impact Check

## Purpose

Check how the v1.09 funded-account news guard affects the current candidate EA
results in Strategy Tester.

This is an implementation impact check, not a final news-filter validation.
MT5 Strategy Tester did not provide usable Economic Calendar data in this run.

## Compile

MetaEditor compile result:

- `0 errors`
- `0 warnings`

## Test Setup

- Symbol: XAUUSD
- Timeframe: M15
- Date range: `2026-03-01` to `2026-06-19`
- Buy session filter: off
- Swing band filter: on
- Avoid swing band: `2500` to `5000` points
- Pending order expiration: `0`
- News currencies: `USD`
- News block window: 2 minutes before through 2 minutes after
- Pending cancellation window: 5 minutes before

## Results

News guard disabled:

- Report: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v109-exp010-news-off-20260301-20260619-20260626-225127.htm`
- Diagnostics: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v109-exp010-news-off-20260301-20260619-20260626-225127-diagnostics.csv`
- Net profit: `622.53`
- Profit factor: `1.31`
- Total trades: `106`
- Balance DD maximal: `238.72 (2.22%)`
- Equity DD maximal: `279.45 (2.60%)`
- Average entry lot: `0.0512`
- Maximum entry lot: `0.10`

News guard enabled, fail-safe on:

- Report: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v109-exp010-news-on-failsafe-20260301-20260619-20260626-225210.htm`
- Diagnostics: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v109-exp010-news-on-failsafe-20260301-20260619-20260626-225210-diagnostics.csv`
- Net profit: `0.00`
- Profit factor: `0.00`
- Total trades: `0`
- Balance DD maximal: `0.00 (0.00%)`
- Equity DD maximal: `0.00 (0.00%)`
- Tester log: `News guard fail-safe active: calendar_unavailable. New entries blocked.`

News guard enabled, fail-safe off:

- Report: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v109-exp010-news-on-no-failsafe-20260301-20260619-20260626-225300.htm`
- Diagnostics: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-v109-exp010-news-on-no-failsafe-20260301-20260619-20260626-225300-diagnostics.csv`
- Net profit: `622.53`
- Profit factor: `1.31`
- Total trades: `106`
- Balance DD maximal: `238.72 (2.22%)`
- Equity DD maximal: `279.45 (2.60%)`
- Average entry lot: `0.0512`
- Maximum entry lot: `0.10`

## Interpretation

The news guard did not produce a realistic news-filtered backtest in Strategy
Tester because the MT5 calendar lookup returned unavailable.

With fail-safe enabled, the EA correctly protected the account by blocking all
new entries when the news calendar could not be checked. With fail-safe disabled,
the results matched the news-off run exactly, which confirms the news guard does
not otherwise change the strategy path when no calendar data is available.

For normal strategy research, keep `InpUseNewsGuard=false`. For a live funded
account, enable `InpUseNewsGuard=true` and keep `InpNewsFailSafeBlock=true`
after confirming MT5 Economic Calendar access works in the terminal.
