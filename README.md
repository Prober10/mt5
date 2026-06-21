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

## Build

Open `FiboRetracementEA.mq5` in MetaEditor and compile it. Build output (`*.ex5`)
is intentionally excluded from Git.
