# Current EA Behavior

This document describes the behavior implemented by version 1.11 of
`FiboRetracementEA.mq5`. It records what the code does today; `SPEC.md`
remains the source for the intended strategy rules.

## Runtime Scope

- The EA trades the symbol of the chart it is attached to. This supports broker
  symbol suffixes such as `XAUUSD.a` without hard-coding a symbol name.
- Signals are read from the configured signal timeframe, which defaults to M15,
  regardless of the chart timeframe.
- Strategy evaluation runs once at the start of each new signal-timeframe bar.
- Daily-loss protection is checked on every tick.
- News protection is checked on every tick when enabled.
- Trades and orders are isolated using the configured magic number.
- Diagnostic CSV export is available as an opt-in testing aid and is disabled by
  default.

## Swing Detection

- The EA loads the standard MT5 `Examples\\ZigZag` indicator through `iCustom`.
- Default ZigZag inputs are Depth 12, Deviation 5, and Backstep 3.
- It reads the three newest non-empty ZigZag vertices.
- The newest vertex is treated as the repainting, still-forming leg and ignored.
- The next two vertices define the latest confirmed impulse swing.
- A rising confirmed impulse is bullish; a falling confirmed impulse is bearish.

## Setup Calculation

For a bullish impulse:

- Entry is a Buy Limit at `high - 0.79 * (high - low)`.
- Stop loss is the swing low minus the configured price buffer, default `0.10`.
- Take profit is placed at a 1:1 reward-to-risk distance.

For a bearish impulse:

- Entry is a Sell Limit at `low + 0.79 * (high - low)`.
- Stop loss is the swing high plus the configured price buffer, default `0.10`.
- Take profit is placed at a 1:1 reward-to-risk distance.

All prices are normalized to the symbol's trade tick size. A setup is rejected if
its pending entry, stop loss, or take profit violates the broker's minimum stop
distance or is on the wrong side of the current market.

## Risk And Volume

- Default risk is 0.5% of current account equity.
- The EA uses `OrderCalcProfit` to estimate the entry-to-stop loss for one lot.
- Volume is rounded down to the stricter of the broker volume step and
  `InpLotStep`, which defaults to `0.01`.
- Volume must be at least `InpMinLotSize`, default `0.01`.
- Volume is capped at `InpMaxLotSize`, default `0.10`.
- This means the EA will not intentionally place `0.001` lots when the default
  protection inputs are used.
- Before accepting the volume, the EA estimates required margin and reduces
  volume until the projected margin level remains at or above
  `InpMinMarginLevelPercent`, default `500%`.
- A setup is skipped when the broker's minimum volume would exceed the risk
  allowance, margin protection cannot be satisfied, or a compliant volume cannot
  be calculated.

## Daily Loss Protection

- The broker server's midnight starts a new trading day.
- The day-start balance is reconstructed from the current balance and today's
  account deal history.
- Only negative closing-deal results carrying this EA's magic number count toward
  the closed-loss total. Closing commission, swap, and fees are included when
  reported on the closing deal.
- The default limit is 1% of the reconstructed day-start balance.
- Once the limit is reached, the EA cancels its pending orders and blocks new
  setups until the next broker day.
- Existing open positions are not closed by the daily-loss guard.
- If today's history cannot be read, trading is blocked as a safety measure.

## News Protection

- `InpUseNewsGuard` defaults to `false`.
- `InpNewsDataSource` defaults to `NEWS_SOURCE_AUTO`.
- In a normal terminal, `NEWS_SOURCE_AUTO` uses the MT5 Economic Calendar to
  check configured currencies for high-importance events.
- In the Strategy Tester, `NEWS_SOURCE_AUTO` uses an exported CSV calendar file
  so funded news rules can be included in backtests.
- The default currency list is `USD`, which is the main news driver for XAUUSD.
- `InpNewsCsvFileName` defaults to `FiboEA\high-impact-news.csv` in the MT5
  common files area.
- New entries are blocked from `InpNewsMinutesBefore` through
  `InpNewsMinutesAfter`, default `2` minutes before through `2` minutes after a
  high-impact event.
- Pending orders are cancelled earlier, from
  `InpNewsCancelPendingMinutesBefore` through `InpNewsMinutesAfter`, default `5`
  minutes before through `2` minutes after a high-impact event.
- Existing open positions are not closed by the news guard.
- If `InpNewsFailSafeBlock` is `true`, the EA blocks new entries and cancels
  pending orders when the enabled news source cannot be checked or loaded.
- Calendar event times are interpreted in broker trade-server time, matching the
  MT5 Economic Calendar API and the exported CSV produced by
  `ExportHighImpactNewsCsv`.
- This protection is designed for The Trading Pit's CFD Prime news restriction
  on larger account sizes, where opening positions or having pending orders
  trigger within 2 minutes before or after high-impact news is not allowed.
- Strategy Tester may not have direct Economic Calendar access. Use
  `tools/ExportHighImpactNewsCsv.mq5` to refresh the CSV before running
  news-aware backtests.

## Order And Setup Lifecycle

- The EA permits only one active position or pending order for its magic number.
- Pending orders use Good-Till-Cancelled expiration by default.
- If `InpPendingOrderExpirationHours` is greater than zero, pending orders are
  sent with a broker expiration time that many hours after placement.
- When a newer confirmed swing appears before entry, the old pending order is
  cancelled and a setup is calculated from the new swing.
- An open position is never replaced because a newer swing appears.
- Both buy and sell setups are enabled by default and can be disabled separately.

## Buy Session Filter

- `InpUseBuySessionFilter` defaults to `false`.
- When enabled, bullish setups are considered only during the configured broker
  server-hour window.
- The default candidate window is `13` through `23`, inclusive.
- If the start hour is greater than the end hour, the session is treated as a
  midnight-crossing window.
- The filter controls setup placement time only. A buy limit placed during the
  allowed window can still fill later outside that window unless a separate
  order-expiration or cancellation rule is added.
- Sell setups are not affected by this filter.

## Core Session Filter

- `InpUseCoreSessionFilter` defaults to `false`.
- When enabled, both bullish and bearish setups are considered only during the
  configured broker server-hour window.
- The default candidate window is `12` through `17`, inclusive.
- If the start hour is greater than the end hour, the session is treated as a
  midnight-crossing window.
- The filter controls setup placement time only. A pending limit placed during
  the allowed window can still fill later outside that window unless another
  order-cancellation rule removes it.

## Swing Band Filter

- `InpUseSwingBandFilter` defaults to `false`.
- When enabled, setups are skipped if the confirmed ZigZag impulse swing size is
  between `InpAvoidSwingMinPoints` and `InpAvoidSwingMaxPoints`, inclusive.
- The default candidate blocked band is `2500` to `5000` points.
- On XAUUSD quoted with 2 decimals, that roughly means swings from `$25` to
  `$50`.
- Both buy and sell setups are affected by this filter.

## One Trade Per Swing

- A swing is identified by the timestamps of its two confirmed anchor vertices.
- The swing is marked as processed only after a pending order is placed.
- Invalid prices and unavailable compliant volumes are re-evaluated on later
  signal bars, preserving the original strategy behavior.
- Repeated local rejection diagnostics are logged only once per swing and reason.
- Temporary quote and broker-distance conditions remain retryable.
- Processed swing timestamps are stored in MT5 terminal global variables, so an
  EA or terminal restart does not place another order for the same swing.

## Current Boundaries

- There is an optional swing-band filter, disabled by default.
- There is an optional all-direction core-session filter, disabled by default.
- There is an optional high-impact-news guard, disabled by default.
- There is no spread filter.
- There is no trailing stop, break-even rule, or partial close.
- Pending orders use no time-based expiration by default, but optional
  expiration is available.
- The EA has compiled successfully, but strategy behavior still needs validation
  in the MT5 Strategy Tester using representative broker XAUUSD data.

## Diagnostics

- `InpEnableDiagnostics` defaults to `false`; diagnostic export only runs in the
  Strategy Tester when this input is enabled.
- `InpDiagnosticsFileName` defaults to `FiboEA\diagnostics.csv` in the MT5 common
  files area.
- The CSV records setup calculation, rejection, placement, and deal events.
- Setup rows include direction, swing anchors, Fibonacci entry/SL/TP, volume,
  risk/reward distance, setup age, spread, equity, ATR(14), and a 20-bar slope
  snapshot.
- Deal rows include deal/order/position identifiers, entry direction, realized
  profit, commission, swap, fee, and MT5 deal comments.
- Diagnostics do not change strategy decisions or order placement behavior.

## Module Ownership

- `FiboRetracementEA.mq5`: lifecycle and module coordination.
- `Config.mqh`: user inputs.
- `Types.mqh`: shared strategy data types.
- `ZigZagSwingDetector.mqh`: confirmed swing extraction.
- `FiboCalculator.mqh`: entry, stop loss, and take-profit prices.
- `RiskManager.mqh`: volume sizing and broker-day loss protection.
- `TradeManager.mqh`: broker validation and pending-order operations.
- `SetupTracker.mqh`: persistent one-trade-per-swing state.
- `NewsGuard.mqh`: high-impact-news entry blocking and pending-order protection.
- `Diagnostics.mqh`: tester-only CSV export for setup and trade analysis.
