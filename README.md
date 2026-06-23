# MT5 Fibonacci Retracement EA

This repository tracks the design and implementation of an MT5 Expert Advisor for a Fibonacci retracement strategy on gold.

The first implementation is available in `FiboRetracementEA.mq5`, with focused
modules under `Include/FiboEA`. The EA compiles against MetaTrader 5 with the
standard `Examples\\ZigZag` indicator.

## Current Scope

- Platform: MetaTrader 5
- Language: MQL5
- Main market: XAUUSD / gold
- Signal timeframe: M15
- Entry style: pending limit orders
- Entry level: 79% Fibonacci retracement
- Risk per trade: 0.5%
- Max daily closed loss: 1%

See [SPEC.md](SPEC.md) for the strategy specification and
[docs/CURRENT_BEHAVIOR.md](docs/CURRENT_BEHAVIOR.md) for an exact description of
the behavior implemented by the current code.

Backtest findings are stored as dated notes under [`docs/backtests`](docs/backtests).

## Automated Backtest

With MT5 closed, run
`powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts\run-backtest.ps1`.
The runner uses the checked-in
XAUUSD M15 real-tick configuration, exports a timestamped HTML report under
`Documents\MT5\automated-reports`, copies the matching diagnostics CSV when
enabled, and closes MT5 when testing completes.

## Diagnostics

Diagnostics are disabled by default for normal/live use. The automated backtest
configuration enables them and writes `FiboEA\diagnostics.csv` in the MT5 common
files area, then the runner copies it beside the HTML report using the same
timestamped base name. The CSV records setup calculation/rejection/placement
events, swing/Fibonacci prices, spread, ATR/slope context, and trade deals.

## Build

Open `FiboRetracementEA.mq5` in MetaEditor and compile it. Build output (`*.ex5`)
is intentionally excluded from Git.
