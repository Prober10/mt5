# Strategy Specification

## Overview

Build an MT5 MQL5 Expert Advisor for XAUUSD using M15 signals.

The EA detects an automated Fibonacci swing using ZigZag, immediately places a pending limit order at the 79% retracement, and manages risk with fixed-percentage sizing and a daily loss cap.

## Market And Timeframe

- Main market: XAUUSD / gold
- Signal timeframe: M15
- The EA should read signals from M15 even if attached to another chart timeframe.

## Swing Detection

- Use ZigZag to detect the latest confirmed impulse swing.
- Ignore the still-forming ZigZag leg because it can repaint.
- Use the latest confirmed swing as the Fibonacci anchor.

Initial ZigZag settings:

```text
Depth: 12
Deviation: 5
Backstep: 3
```

## Entry Rules

- Use pending limit orders only.
- Place the limit order immediately after a valid confirmed swing is detected.
- Bullish impulse: swing low to swing high.
  - Place a Buy Limit at the 79% retracement.
- Bearish impulse: swing high to swing low.
  - Place a Sell Limit at the 79% retracement.

## Stop Loss And Take Profit

- Stop loss is placed beyond the impulse start.
- Use fixed XAUUSD price-distance buffer, not generic points.
- Initial SL buffer: 0.10.

Buy setup:

- SL below the swing low by 0.10.
- TP at 1:1 from entry to SL.

Sell setup:

- SL above the swing high by 0.10.
- TP at 1:1 from entry to SL.

## Risk Management

- Risk per trade: 0.5% of account.
- Max daily closed loss: 1% of account.
- Daily loss calculation should count only closed losses from this EA.
- EA trades and orders are identified by magic number.

## Order Behavior

- One active setup/order total.
- One trade per Fibonacci swing.
- If a newer confirmed ZigZag swing forms before entry, cancel the old pending order and recalculate.
- No minimum swing size filter for now.
- No trading-session filter for now.
- Buy and sell setups are both allowed.

## Architecture

Keep all configurable settings separate from trading logic.

```text
FiboRetracementEA.mq5
Include/FiboEA/Config.mqh
Include/FiboEA/Types.mqh
Include/FiboEA/ZigZagSwingDetector.mqh
Include/FiboEA/FiboCalculator.mqh
Include/FiboEA/RiskManager.mqh
Include/FiboEA/TradeManager.mqh
Include/FiboEA/SetupTracker.mqh
```

Responsibilities:

```text
FiboRetracementEA.mq5
- Main EA entry point
- OnInit, OnTick, OnDeinit
- Coordinates modules only

Config.mqh
- All user-configurable inputs
- ZigZag settings
- Signal timeframe
- Fibonacci entry level
- SL buffer
- Risk settings
- Magic number
- Buy/sell toggles

Types.mqh
- Shared structs and enums
- Swing data
- Setup data

ZigZagSwingDetector.mqh
- Reads ZigZag
- Finds latest confirmed swing
- Detects new swing formation

FiboCalculator.mqh
- Calculates entry, SL, and TP

RiskManager.mqh
- Calculates lot size from 0.5% risk
- Checks 1% daily max closed loss
- Filters by magic number

TradeManager.mqh
- Places and cancels limit orders
- Checks active orders and positions
- Enforces one active order total

SetupTracker.mqh
- Prevents repeated trades on the same swing
```
