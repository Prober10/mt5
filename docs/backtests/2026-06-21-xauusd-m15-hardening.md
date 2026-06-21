# XAUUSD M15 Hardening Comparison - 2026-06-21

## Test Configuration

- EA version: 1.01
- Symbol/timeframe: XAUUSD M15
- Period: 2026-03-01 through 2026-06-19
- Model quality: 99% real ticks
- Initial deposit: USD 10,000
- Leverage: 1:100
- Inputs: documented defaults

## Comparison

| Metric | Version 1.00 | Version 1.01 |
| --- | ---: | ---: |
| Net profit | USD 584.26 | USD 242.79 |
| Return | 5.84% | 2.43% |
| Profit factor | 1.15 | 1.08 |
| Expected payoff | USD 3.25 | USD 1.83 |
| Recovery factor | 0.96 | 0.37 |
| Total trades | 180 | 133 |
| Win rate | 53.33% | 51.13% |
| Balance drawdown | 5.19% | 5.78% |
| Equity drawdown | 5.58% | 6.13% |

Local invalid-price messages fell from 1,277 to 104, confirming that persistent
setup rejection tracking worked. Daily-limit activations fell from nine to zero,
but the remaining-budget volume cap skipped too many subsequent opportunities.
It reduced return, profit factor, and recovery while increasing total drawdown.

## Decision

Do not promote version 1.01. Retain the setup-lifecycle improvements and remove
the remaining-daily-budget volume cap. Funded-account protection will be designed
and tested separately from general setup reliability.
