# Adaptive AI EA Roadmap

## Phase 1: Documentation And Skeleton

- Create neutral adaptive EA branch.
- Add architecture and roadmap documentation.
- Add MQL5 module skeletons with no Fib dependency.
- Compile empty orchestration flow.

## Phase 2: Feature And State Prototype

- Extract basic M15 features:
  - ATR regime
  - spread regime
  - session hour
  - candle body/range behavior
  - short slope
  - distance from recent high/low
- Convert features into a stable discrete market-state key.
- Log every state calculation to diagnostics.

## Phase 3: First Decision Model

- Implement action set:
  - NO_TRADE
  - BUY_ATR_1R
  - SELL_ATR_1R
- Use cautious defaults:
  - no trade until minimum sample rules are met, or
  - controlled exploration in tester only.
- Add memory persistence.

## Phase 4: Learning From Closed Trades

- Match closed deals back to model decisions.
- Convert result to R multiple.
- Update state/action statistics only after closure.
- Add decay so older data loses influence.

## Phase 5: Backtest Discipline

- Run deterministic training windows.
- Run unseen validation windows.
- Compare against:
  - random/action baseline
  - always-no-trade baseline
  - Fib EA benchmark
- Reject changes that improve only one narrow period.

## Phase 6: Expansion

- Add controlled SL/TP templates.
- Add optional higher-timeframe features.
- Add optional news/spread protections.
- Consider multiple opportunity generators only after the neutral model is
  understood.

## Current Decision

Do not seed the adaptive learner with Fib strategy outcomes. The Fib EA remains
a benchmark and possible future opportunity generator, not the initial training
source.
