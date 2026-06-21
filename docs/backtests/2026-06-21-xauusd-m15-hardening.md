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

## Version 1.02 Follow-up

Version 1.02 removed the risk cap but continued marking locally rejected setups
as processed. Its automated comparison produced USD 164.77 net profit, a 1.05
profit factor, 135 trades, 7.19% balance drawdown, and 7.51% equity drawdown.
Suppressing those retries changed trade selection and was also rejected.

Version 1.03 retains retries and suppresses only duplicate diagnostic messages.

## Version 1.03 Acceptance

The automated comparison exactly reproduced version 1.00: USD 584.26 net
profit, 1.15 profit factor, 180 trades, 5.19% balance drawdown, and 5.58%
equity drawdown. All win/loss and direction counts also matched.

Repeated local diagnostics fell from 1,277 invalid-price messages and 100
volume messages to 101 and 5 respectively. Version 1.03 is accepted as a
behavior-preserving reliability improvement.
