# Adaptive AI EA Architecture

## File Layout

```text
AdaptiveAI_EA.mq5
Include/AdaptiveAI/Config.mqh
Include/AdaptiveAI/Types.mqh
Include/AdaptiveAI/FeatureExtractor.mqh
Include/AdaptiveAI/MarketState.mqh
Include/AdaptiveAI/DecisionEngine.mqh
Include/AdaptiveAI/LearningModel.mqh
Include/AdaptiveAI/RiskManager.mqh
Include/AdaptiveAI/TradeManager.mqh
Include/AdaptiveAI/MemoryStore.mqh
Include/AdaptiveAI/PerformanceTracker.mqh
Include/AdaptiveAI/Diagnostics.mqh
docs/adaptive-ai/OVERVIEW.md
docs/adaptive-ai/ARCHITECTURE.md
docs/adaptive-ai/ROADMAP.md
docs/adaptive-ai/EXPERIMENT_LOG.md
```

## Data Flow

```text
Market data
 -> FeatureExtractor
 -> MarketStateBuilder
 -> DecisionEngine
 -> RiskManager
 -> TradeManager
 -> PerformanceTracker after close
 -> LearningModel
 -> MemoryStore
 -> Diagnostics
```

## Module Responsibilities

```text
AdaptiveAI_EA.mq5
- EA lifecycle and orchestration
- No strategy-specific setup logic

Config.mqh
- All tunable inputs
- Risk, learning, execution, diagnostics, and feature settings

Types.mqh
- Shared enums and structs
- Features, states, actions, decisions, learning records

FeatureExtractor.mqh
- Builds factual market features from MT5 data
- No trading decisions

MarketState.mqh
- Converts continuous features into discrete state buckets
- Keeps learning table small enough for MQL5

DecisionEngine.mqh
- Chooses NO_TRADE, BUY, or SELL from model scores and confidence
- Applies exploration only when enabled

LearningModel.mqh
- Tracks expectancy per state/action
- Updates only after closed outcomes
- Applies sample confidence and decay

RiskManager.mqh
- Enforces max risk, daily loss, spread, margin, and volume constraints
- Final authority before any order is sent

TradeManager.mqh
- Opens and manages orders/positions
- Uses market orders for the first proof of concept unless changed later

MemoryStore.mqh
- Saves and loads learned state/action statistics

PerformanceTracker.mqh
- Converts closed trades into R-multiple outcomes
- Finds which decision produced each trade

Diagnostics.mqh
- Writes decision, feature, order, deal, and learning rows to CSV
```

## Initial Learning Model

The first learning model should be a contextual bandit:

```text
state + action -> performance statistics
```

Each record tracks:

- attempts
- wins
- losses
- total R
- average R
- recent score
- confidence
- last update time

This is intentionally simpler than neural networks or unrestricted
reinforcement learning.
