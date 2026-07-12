# Strategy Research Protocol

This project is not trying to make the prettiest backtest. The goal is to build
an EA that has a realistic chance of behaving well on a funded account, where
capital preservation, rule compliance, and repeatable edge matter more than one
optimized historical curve.

## Production Goal

A candidate strategy should aim for:

- Positive expectancy across different market regimes, not only one hand-picked
  window.
- Controlled drawdown that stays comfortably inside funded-account limits.
- Realistic lot sizing with margin headroom.
- No dependency on fragile parameter values.
- No trading behavior that violates the funded-account news restrictions.

## Current Baseline Candidate

The current realistic baseline is:

- EXP-010 swing band filter enabled.
- News CSV guard enabled.
- Buy session filter disabled.
- Core session filter disabled.
- Pending expiration disabled.
- Lot/margin safety enabled.

This candidate is profitable over several windows, but it is not strong enough
yet. It has too many weak or flat months, and those months matter because the
live goal is consistent funded-account progress, not a single long-period net
profit number.

## What Counts As Progress

A strategy change is only useful if it improves one of these:

- More stable month-to-month expectancy.
- Lower drawdown without removing too much edge.
- Clearer avoidance of known bad market conditions.
- Better trade selection using information available at decision time.
- Better funded-account safety without pretending safety is edge.

Small net-profit gains are not enough unless they come with better robustness.

## Experiment Rules

Each experiment should:

- Change one main idea at a time.
- Have a market reason before it is coded.
- Be tested against the current baseline, not an old version.
- Be validated on multiple windows after discovery.
- Be documented as accepted, rejected, mixed, or deferred.
- Avoid being accepted if it only fixes the window that inspired it.

If a rule improves one period but breaks another, it is not automatically bad.
But we need a simple explanation for when it works and when it fails before it
can become live behavior.

## Required Evidence Before Acceptance

Before accepting a strategy filter or entry/exit change, we should check:

- Net profit, profit factor, drawdown, trade count, and average trade.
- Monthly distribution, not just total period result.
- Direction split: buy versus sell.
- Regime split using diagnostics available at setup time.
- Whether the improvement survives 2025 H1, 2025 H2, 2026 Jan-Feb, and
  2026 Mar-Jun.
- Whether the rule reduces opportunity so much that the remaining profit is not
  meaningful.

## Current Research Direction

The latest diagnostics suggest weak months are not just a session problem. The
best next research direction is regime quality:

- H1 MA50 context is promising, especially for sell setups.
- H1 range efficiency may help separate useful trend/retracement structure from
  chop.
- H4 simple alignment has not shown enough value.

The next experiment should not be a broad "trade with higher timeframe trend"
rule. That would be too blunt. The next useful candidate is a narrow sell-side
rule based on H1 MA50 context, but only if we can understand and protect the
Jan-Feb 2026 failure case.

## Live Readiness Bar

The EA is not live-ready just because it is profitable in backtests.

Before considering funded-account use, we should have:

- Clean compile and stable tester execution.
- News guard validated with CSV fallback in tester and calendar API live.
- Documented results for the chosen candidate.
- A forward-test period on demo or very small live risk.
- Monitoring notes for missed trades, rejected setups, spread, slippage, and
  news-block behavior.

The research path should stay boring on purpose: diagnose, form a simple
hypothesis, test it, document it, and reject it quickly if it does not survive.
