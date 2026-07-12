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

- Status: `Mixed validation`
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
  - Continue validation on the longer 2025 windows before accepting.
- Validation result: `2026-01-01` to `2026-02-28`
  - Baseline: -108.61, PF 0.95, 103 trades, equity DD 486.10 / 4.85%
  - EXP-005: +55.88, PF 1.03, 88 trades, equity DD 420.96 / 4.11%
  - Buy side improved from -18.31 to +175.55.
  - Sell side was weak in both versions.
  - Directionally positive, but not strong enough for acceptance.
- v1.06 safety-layer rerun:
  - Discovery baseline: 546.43, PF 1.14, max lot 0.10
  - Discovery EXP-005: 1,070.29, PF 1.37, max lot 0.10
  - Jan-Feb baseline: -98.46, PF 0.96, max lot 0.10
  - Jan-Feb EXP-005: +50.06, PF 1.03, max lot 0.10
  - EXP-005 still improves both tested windows after the lot/margin guard.
- 2025 H2 validation:
  - Baseline: +643.41, PF 1.12, 290 trades, equity DD 378.90 / 3.72%
  - EXP-005: +513.37, PF 1.12, 236 trades, equity DD 479.84 / 4.77%
  - Buy side remained profitable, but total net and drawdown were worse than
    baseline.
- Acceptance status:
  - Not accepted yet. The rule helped both 2026 windows but hurt 2025 H2, so it
    is regime-dependent until proven otherwise.

### EXP-008: Lot Size And Margin Safety Guard

- Status: `Accepted as protection`
- Code version: `1.06`
- Summary: Enforce two-decimal lot sizing, a configurable max lot cap, and a
  projected margin-level guard.
- Default protection inputs:
  - `InpMinLotSize=0.01`
  - `InpMaxLotSize=0.10`
  - `InpLotStep=0.01`
  - `InpMinMarginLevelPercent=500.0`
- Rationale:
  - Funded-account execution should avoid oversized positions and preserve
    margin headroom.
  - Lot sizes such as `0.001` should not be used.
- Decision:
  - Accepted as a safety rule, not as a strategy edge improvement.
- Testing status:
  - Compile verification passed.
  - Rerun reports confirmed max executed lot is now `0.10`.
  - Future validation tests should use this protection layer unless explicitly
    comparing older historical behavior.

### EXP-009: Pending Order Expiration

- Status: `Mixed validation`
- Code version: `1.07`
- Summary: Add configurable pending-order expiration so old retracement setups
  do not remain live indefinitely.
- Default input:
  - `InpPendingOrderExpirationHours=0.0`, meaning Good-Till-Cancelled behavior.
- First candidate:
  - Test `InpPendingOrderExpirationHours=6.0` alongside the current v1.06
    safety layer and EXP-005 buy-session filter.
- Rationale:
  - Diagnostics showed fills older than 6 hours were weak.
  - This is primarily order-lifecycle hygiene, not a pure optimization filter.
- Required next test:
  - Validate on the longer 2025 windows.
- Discovery result: `2026-03-01` to `2026-06-19`
  - v1.06 EXP-005: 1,070.29, PF 1.37, 147 trades, equity DD 280.21 / 2.61%
  - v1.07 EXP-009 6h: 1,193.71, PF 1.44, 139 trades, equity DD 273.60 / 2.56%
  - Buy side improved from +234.54 / PF 1.18 to +395.82 / PF 1.37.
  - Max executed lot remained `0.10`.
- Validation result: `2026-01-01` to `2026-02-28`
  - v1.06 EXP-005: +50.06, PF 1.03, 88 trades, equity DD 420.96 / 4.11%
  - v1.07 EXP-009 6h: +88.26, PF 1.05, 86 trades, equity DD 383.22 / 3.74%
  - Buy side improved from +175.95 / PF 1.31 to +188.45 / PF 1.33.
  - Sell side remained negative, but improved from -128.47 to -102.77.
- 2025 H2 validation:
  - Baseline: +643.41, PF 1.12, 290 trades, equity DD 378.90 / 3.72%
  - EXP-009 6h: +421.71, PF 1.10, 229 trades, equity DD 534.55 / 5.31%
  - The expiration rule improved September, but worsened July, August, and
    November enough to underperform baseline overall.
- Acceptance status:
  - Not accepted yet. Discovery and Jan-Feb 2026 were positive, but 2025 H2 was
    weaker than baseline.

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

### EXP-010: Avoid Mid-Sized Confirmed Swings

- Status: `Accepted as current candidate, not production-ready`
- Code version: `1.08`
- Summary: Skip setups where confirmed swing size is between `2500` and `5000`
  points.
- Rationale:
  - Diagnostics comparison showed this swing-size band was weak across all
    three baseline windows tested so far.
  - Larger swings, especially `5000+`, were consistently stronger.
  - This is more specific than a broad minimum swing-size filter because very
    small 2025 H2 swings were not weak in the same way.
- Baseline evidence:
  - 2026 Mar-Jun: 76 trades, -179.75, PF 0.91
  - 2026 Jan-Feb: 39 trades, -389.09, PF 0.64
  - 2025 H2: 88 trades, -382.02, PF 0.83
- Test configuration:
  - `InpUseSwingBandFilter=true`
  - `InpAvoidSwingMinPoints=2500`
  - `InpAvoidSwingMaxPoints=5000`
  - `InpUseBuySessionFilter=false`
  - `InpPendingOrderExpirationHours=0`
- Discovery result: `2026-03-01` to `2026-06-19`
  - Baseline: +546.43, PF 1.14, 180 trades, equity DD 606.10 / 5.55%
  - EXP-010: +622.53, PF 1.31, 106 trades, equity DD 279.45 / 2.60%
- Validation result: `2026-01-01` to `2026-02-28`
  - Baseline: -98.46, PF 0.96, 103 trades, equity DD 475.95 / 4.75%
  - EXP-010: +377.54, PF 1.31, 64 trades, equity DD 307.26 / 3.04%
- Validation result: `2025-07-01` to `2025-12-31`
  - Baseline: +643.41, PF 1.12, 290 trades, equity DD 378.90 / 3.72%
  - EXP-010: +992.61, PF 1.32, 203 trades, equity DD 271.94 / 2.65%
- Validation result: `2025-01-01` to `2025-06-30`
  - Baseline: -772.65, PF 0.87, 300 trades, equity DD 1,200.02 / 11.80%
  - EXP-010: -421.89, PF 0.89, 223 trades, equity DD 775.03 / 7.66%
  - EXP-010 reduced the loss and drawdown, but the window remained unsuitable
    for funded-account deployment.
- v1.10 news CSV validation:
  - 2026 Mar-Jun: +542.37, PF 1.28, 102 trades, equity DD 259.58 / 2.42%
  - 2026 Jan-Feb: +284.97, PF 1.25, 58 trades, equity DD 265.16 / 2.62%
  - 2025 H2: +1,013.70, PF 1.34, 195 trades, equity DD 240.03 / 2.15%
  - 2025 H1: -276.02, PF 0.92, 212 trades, equity DD 619.55 / 6.13%
  - News protection reduced trade count and drawdown in every window. It did
    not fix 2025 H1, but it made the weak window less severe.
- Acceptance status:
  - Accepted as the current best candidate strategy layer.
  - Keep configurable. Do not make it the production default until the 2025 H1
    weakness is understood and reduced.

### EXP-011: Core Setup Session Filter

- Status: `Promising validation candidate`
- Code version: `1.11`
- Summary: Add an optional all-direction setup session filter and test allowing
  setups only from `12` through `17` broker time.
- Rationale:
  - After EXP-010, the `12-17` setup-hour block was positive in every tested
    window.
  - 2025 H1 remained weak mostly because of `6-11` and `18-23` setups.
  - A broad ban on `6-11` would likely overfit because that block was profitable
    in the other EXP-010 windows.
- EXP-010 setup-hour evidence:
  - 2025 H1 `12-17`: +477.90, PF 1.46
  - 2025 H2 `12-17`: +485.21, PF 1.51
  - 2026 Jan-Feb `12-17`: +216.21, PF 1.57
  - 2026 Mar-Jun `12-17`: +61.62, PF 1.10
- Test configuration:
  - `InpUseCoreSessionFilter=true`
  - `InpCoreSessionStartHour=12`
  - `InpCoreSessionEndHour=17`
  - `InpUseSwingBandFilter=true`
  - `InpUseNewsGuard=true`
  - `InpNewsDataSource=NEWS_SOURCE_CSV`
  - `InpUseBuySessionFilter=false`
  - `InpPendingOrderExpirationHours=0`
- Validation result:
  - 2026 Mar-Jun: +188.58, PF 1.32, 32 trades, equity DD 138.94 / 1.36%
  - 2026 Jan-Feb: +237.62, PF 1.59, 23 trades, equity DD 179.58 / 1.78%
  - 2025 H2: +281.60, PF 1.22, 81 trades, equity DD 232.64 / 2.31%
  - 2025 H1: +214.67, PF 1.17, 82 trades, equity DD 308.30 / 3.06%
- Interpretation:
  - EXP-011 fixed the weak 2025 H1 window and reduced drawdown strongly.
  - It also cut many trades and gave up most net profit in 2026 Mar-Jun and
    2025 H2.
  - This is a risk/stability candidate, not proof of a better live edge.
- Acceptance status:
  - Not accepted as production default yet.
  - Next test should look for a less restrictive version or confirm that the
    lower trade count is acceptable for the funded-account objective.

### EXP-012: Core Session With Large-Swing Outside-Core Exception

- Status: `Deferred`
- Summary: Keep the EXP-011 core session, but allow outside-core setups when
  the confirmed swing is unusually large.
- Candidate rule:
  - Allow all setups from `12` through `17` broker time.
  - Outside `12-17`, allow setups only when confirmed swing size is at least
    `8000` points.
- Rationale:
  - EXP-011 reduced risk but removed too many profitable outside-core trades.
  - EXP-011 removal analysis showed outside-core `8000+` swing trades were
    positive in every tested window.
  - This has a market-structure rationale: very large confirmed impulses may
    produce higher-quality retracement setups even outside the cleanest session.
- Diagnostic what-if from EXP-010 + news CSV executed trades:
  - 2025 H1: +566.71, PF 1.63, 69 trades
  - 2025 H2: +490.83, PF 1.50, 70 trades
  - 2026 Jan-Feb: +259.86, PF 1.51, 30 trades
  - 2026 Mar-Jun: +478.43, PF 1.73, 43 trades
- Caveat:
  - This is not a real Strategy Tester result. Blocking setups changes
    pending-order lifecycle, so the rule must be coded and tested before being
    trusted.
- Acceptance status:
  - Not accepted.
  - Deferred after monthly analysis. Positive but tiny slices such as `+$41`
    over a half-year are not meaningful enough for a funded-account strategy.
  - The next priority is regime-quality analysis, not another narrow session or
    swing exception.
