# Adaptive AI EA Overview

This project explores a strategy-neutral adaptive Expert Advisor for MetaTrader 5.
It is separate from the Fibonacci retracement EA and must not depend on Fib setup
generation.

The first goal is not to create an unrestricted AI trader. The realistic goal is
to build a constrained adaptive decision engine that learns which predefined
actions perform best in observable market states.

## Core Principle

The EA should learn from facts available at decision time:

- price and candle behavior
- volatility
- spread
- tick volume
- session hour
- higher-timeframe context
- account and execution constraints
- recent closed-trade outcomes

It should not use future data, hindsight labels, or tester-only information when
making decisions.

## First Proof Of Concept

The first version should use a small, neutral action set:

```text
NO_TRADE
BUY_ATR_1R
SELL_ATR_1R
```

For trade actions:

- stop loss is ATR-based
- take profit is a fixed R multiple
- risk is controlled by the risk manager
- learning updates happen only after the trade closes

## Non-Negotiable Constraints

- Risk management is hard-coded and cannot be overridden by the learning model.
- The model starts cautious and requires evidence before trading.
- All decisions and learning updates must be logged for review.
- Learned memory must be persisted separately from the code.
- The system must remain explainable enough to debug.

## Relationship To The Fib EA

The Fib EA remains a benchmark and separate strategy project. It can be compared
against the adaptive EA later, but it should not seed or condition the adaptive
model's first learning process.
