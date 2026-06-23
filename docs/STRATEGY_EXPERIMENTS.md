# Strategy Experiment Log

This file tracks strategy ideas, tests, and outcomes. Its purpose is to prevent
curve-fitting, repeated experiments, and vague memories of what "worked".

## Result Labels

- `Idea`: not coded or tested yet.
- `Discovery`: tested only on the current discovery window.
- `Validation`: tested on one or more unseen windows.
- `Accepted`: kept because it improved robustness across validation windows.
- `Rejected`: removed because it failed validation, increased risk, or only
  improved one narrow window.
- `Superseded`: replaced by a clearer or safer version of the same idea.

## Test Windows

Current discovery window:

- `2026-03-01` to `2026-06-19`, XAUUSD M15, real ticks

Candidate validation windows:

- `2025-01-01` to `2025-06-30`
- `2025-07-01` to `2025-12-31`
- `2026-01-01` to `2026-02-28`
- Later recent data that was not used to design the rule

## Acceptance Rules

A strategy change should not be accepted only because it improves the discovery
window. It should:

- Have a simple market rationale.
- Change one main thing at a time.
- Preserve or improve drawdown behavior.
- Avoid depending on a very exact parameter value.
- Survive at least one unseen validation window before being trusted.
- Avoid violating the funded-account direction: controlled risk first, profit
  target second.

## Experiments

### EXP-001: Baseline Fibonacci 79% Retracement

- Status: `Accepted as baseline`
- Code version: `1.03`
- Summary: Trades both bullish and bearish confirmed ZigZag impulse retracements
  at the 79% Fibonacci level with 1:1 reward-to-risk and 0.5% equity risk.
- Discovery result:
  - Net profit: 584.26
  - Profit factor: 1.15
  - Trades: 180
  - Equity DD max: 609.67 / 5.58%
- Notes:
  - Sells carried most of the edge.
  - Buys degraded after March.

### EXP-002: Daily Risk Reservation Hardening

- Status: `Rejected`
- Code version: `1.01`
- Summary: Added stricter daily risk reservation before placing new trades.
- Discovery result:
  - Net profit: 242.79
  - Profit factor: 1.08
  - Trades: 133
  - Equity DD max: 6.13%
- Decision:
  - Rejected because it reduced performance and did not improve the strategy
    enough to justify the trade suppression.

### EXP-003: Setup Rejection Marking Without Daily Risk Cap

- Status: `Rejected`
- Code version: `1.02`
- Summary: Removed the daily risk experiment but marked rejected setups as
  processed.
- Discovery result:
  - Net profit: 164.77
  - Profit factor: 1.05
  - Trades: 135
  - Equity DD max: 7.51%
- Decision:
  - Rejected because marking rejected setups changed strategy behavior in a bad
    way.

### EXP-004: Behavior-Neutral Diagnostics

- Status: `Accepted as instrumentation`
- Code version: `1.04`
- Summary: Added tester-only CSV diagnostics for setup, rejection, placement,
  market context, and deal events.
- Discovery result:
  - Net profit: 584.26
  - Profit factor: 1.15
  - Trades: 180
  - Equity DD max: 609.67 / 5.58%
  - Diagnostic rows: 3,821
- Decision:
  - Accepted because it preserved baseline trading behavior exactly and improves
    analysis quality.

### EXP-005: Restrict Buy Trades By Session

- Status: `Discovery`
- Summary: Keep sell behavior unchanged, but allow buys only during stronger
  historical buy sessions. The first tested candidate restricts buy setup
  placement to `13-23` broker time.
- Rationale:
  - Diagnostics showed buy trades from `00-12` broker time were the largest
    weakness.
  - Buy `13-17` and `18-23` were positive in the discovery window.
- Discovery what-if from filled trades only:
  - Baseline: 180 trades, +585.23, PF 1.15
  - All sells + buys only `13-23`: 125 trades, +1029.19, PF 1.41
- Discovery test:
  - Code version: `1.05`
  - Report: `Documents\MT5\automated-reports\FiboRetracementEA-XAUUSD-M15-20260623-215902.htm`
  - Net profit: 1,068.82
  - Profit factor: 1.35
  - Trades: 147
  - Equity DD max: 297.11 / 2.77%
  - Buy trades: 60, +251.95, PF 1.20
  - Sell trades: 87, +826.53, PF 1.48
  - All tested months were net positive in the discovery window.
- Notes:
  - The rule filters buy setup placement time only.
  - Pending buy limits placed during the allowed session can still fill outside
    the session.
- Required next test:
  - Validate on unseen windows before accepting.
- Acceptance status:
  - Not accepted yet. Discovery-window improvement is promising but not proof.

### EXP-006: Minimum ATR Filter

- Status: `Idea`
- Summary: Avoid low-volatility setups, with `ATR(14) >= 1000 points` as an
  initial candidate from diagnostics.
- Rationale:
  - ATR `500-1000` points was weak.
  - ATR `1000-2500` points performed much better in the discovery window.
- Discovery what-if from filled trades only:
  - ATR `>= 1000` only: 86 trades, +1085.10, PF 1.77
  - All sells + buys with ATR `>= 1000`: 130 trades, +1126.55, PF 1.45
- Required next test:
  - Test separately from session filtering.
  - Validate across unseen windows because volatility filters can overfit.
- Acceptance status:
  - Not accepted yet. This is only a hypothesis.

### EXP-007: Minimum Confirmed Swing Size Filter

- Status: `Idea`
- Summary: Avoid small confirmed impulse swings, with `>= 5000 points` as an
  initial candidate from diagnostics.
- Rationale:
  - Small/medium swings were weak.
  - Larger swings were stronger in the discovery window.
- Discovery what-if from filled trades only:
  - Swing `>= 5000` only: 73 trades, +793.57, PF 1.66
  - All sells + buys with swing `>= 5000`: 123 trades, +991.31, PF 1.42
- Required next test:
  - Test separately from ATR and session filters.
  - Check whether the threshold remains useful on unseen windows.
- Acceptance status:
  - Not accepted yet. This is only a hypothesis.
