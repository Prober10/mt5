# Adaptive AI Experiment Log

This file tracks adaptive EA ideas, tests, and decisions.

## Labels

- `Idea`: not implemented.
- `Prototype`: implemented but not validated.
- `Discovery`: tested on an initial design window.
- `Validation`: tested on unseen windows.
- `Accepted`: kept because it improved robustness.
- `Rejected`: removed or disabled because it failed validation.

## Experiments

### AAI-001: Strategy-Neutral Contextual Bandit

- Status: `Idea`
- Summary: Learn expectancy for a small action set using factual market-state
  buckets.
- Initial actions:
  - `NO_TRADE`
  - `BUY_ATR_1R`
  - `SELL_ATR_1R`
- Goal:
  - Prove the EA can make decisions, persist memory, update after closed trades,
    and avoid future leakage.
- Acceptance requirement:
  - Must be evaluated with walk-forward validation before being trusted.
