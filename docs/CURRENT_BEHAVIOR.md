# Current EA Behavior

This document describes the behavior implemented by version 1.03 of
`FiboRetracementEA.mq5`. It records what the code does today; `SPEC.md`
remains the source for the intended strategy rules.

## Runtime Scope

- The EA trades the symbol of the chart it is attached to. This supports broker
  symbol suffixes such as `XAUUSD.a` without hard-coding a symbol name.
- Signals are read from the configured signal timeframe, which defaults to M15,
  regardless of the chart timeframe.
- Strategy evaluation runs once at the start of each new signal-timeframe bar.
- Daily-loss protection is checked on every tick.
- Trades and orders are isolated using the configured magic number.

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
- Volume is rounded down to the broker's volume step and capped at its maximum.
- A setup is skipped when the broker's minimum volume would exceed the risk
  allowance or a compliant volume cannot be calculated.

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

## Order And Setup Lifecycle

- The EA permits only one active position or pending order for its magic number.
- Pending orders use Good-Till-Cancelled expiration.
- When a newer confirmed swing appears before entry, the old pending order is
  cancelled and a setup is calculated from the new swing.
- An open position is never replaced because a newer swing appears.
- Both buy and sell setups are enabled by default and can be disabled separately.

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

- There is no minimum impulse-size filter.
- There is no trading-session or news filter.
- There is no spread filter.
- There is no trailing stop, break-even rule, or partial close.
- Pending orders have no time-based expiration.
- The EA has compiled successfully, but strategy behavior still needs validation
  in the MT5 Strategy Tester using representative broker XAUUSD data.

## Module Ownership

- `FiboRetracementEA.mq5`: lifecycle and module coordination.
- `Config.mqh`: user inputs.
- `Types.mqh`: shared strategy data types.
- `ZigZagSwingDetector.mqh`: confirmed swing extraction.
- `FiboCalculator.mqh`: entry, stop loss, and take-profit prices.
- `RiskManager.mqh`: volume sizing and broker-day loss protection.
- `TradeManager.mqh`: broker validation and pending-order operations.
- `SetupTracker.mqh`: persistent one-trade-per-swing state.
