# Changelog

## Unreleased

- Record locally invalid swings as processed so they are not rejected again on every signal bar.
- Record swings that cannot fit the broker's minimum volume as processed once.
- Keep broker-side order failures retryable for transient execution errors.
- Removed the experimental remaining-daily-budget volume cap after its comparison
  test reduced return and increased total drawdown.

- Added initial documentation for the MT5 Fibonacci retracement EA.
- Captured the current XAUUSD M15 strategy specification.
- Added the modular MQL5 Expert Advisor implementation.
- Added confirmed ZigZag swing detection and 79% retracement calculations.
- Added fixed-percentage volume sizing and broker-day closed-loss protection.
- Added pending-order replacement and persistent one-trade-per-swing tracking.
- Added current-behavior documentation for version 1.00.
- Added analysis of the first XAUUSD M15 real-tick backtest.
