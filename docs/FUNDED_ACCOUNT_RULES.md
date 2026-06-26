# Funded Account Rules Notes

This document records funded-account constraints that affect EA behavior.

## The Trading Pit CFD News Rule

Sources:

- `https://support.thetradingpit.com/is-news-trading-allowed-1-0`
- `https://support.thetradingpit.com/can-i-use-an-expert-advisor-0`

Current read:

- News trading is allowed for CFD accounts except the `$100,000` and `$200,000`
  CFD accounts.
- For CFD accounts up to `$50,000`, The Trading Pit says traders may open and
  close trades during high-impact news using market or pending orders.
- For `$100,000` and `$200,000` CFD Prime accounts, opening trades is not
  allowed within 2 minutes before or after high-impact news releases.
- Pending orders must not trigger within that same restricted window.
- Existing open trades may close during the news window, including by stop loss
  or take profit.

EA implication:

- Block new entries around high-impact news.
- Cancel pending orders before the restricted window so they cannot trigger
  during high-impact news.
- Do not force-close already-open positions for this rule.
- Use broker/server time for news windows because MT5 calendar functions use
  trade-server time.

Implementation:

- `InpUseNewsGuard=false` by default.
- `InpNewsDataSource=NEWS_SOURCE_AUTO`
- `InpNewsCurrencies="USD"` by default for XAUUSD.
- `InpNewsCsvFileName="FiboEA\high-impact-news.csv"`
- `InpNewsMinutesBefore=2`
- `InpNewsMinutesAfter=2`
- `InpNewsCancelPendingMinutesBefore=5`
- `InpNewsFailSafeBlock=true`

Operational note:

An EA can only cancel pending orders while the terminal is running and receiving
ticks. For larger funded accounts, use a wider pending-cancel buffer if needed.

Backtesting note:

MT5 Strategy Tester may not provide direct Economic Calendar access. The EA now
supports a CSV news source for testing:

- Run `ExportHighImpactNewsCsv` in the normal MT5 terminal to refresh
  `Common\Files\FiboEA\high-impact-news.csv`.
- In tester mode, `InpNewsDataSource=NEWS_SOURCE_AUTO` reads that CSV.
- In live/demo mode, `InpNewsDataSource=NEWS_SOURCE_AUTO` uses the MT5 Economic
  Calendar API.
