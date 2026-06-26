# Calendar Probe

`tools/CalendarProbe.mq5` is a tiny script for checking whether the MT5
Economic Calendar API is available independently from the EA.

It does not trade. It only calls `CalendarValueHistory`, prints the result
count and last error, then prints a few returned calendar events.

## Installed Copy

An installed copy is also placed here for direct MT5 use:

`MQL5\Scripts\CalendarProbe.mq5`

## How To Run

1. Open MT5.
2. Open Navigator.
3. Go to `Scripts`.
4. Run `CalendarProbe` on any chart.
5. Check the `Experts` tab for lines beginning with `CalendarProbe`.

Good sign:

- `CalendarProbe result: count=<positive number>, error=0`

Problem sign:

- `CalendarProbe result: count=-1, error=<number>`

If this script fails on a normal chart, the issue is MT5 calendar access or
terminal/broker environment. If it succeeds on a normal chart but the Strategy
Tester fails, the news guard implementation is probably fine and the limitation
is tester-only calendar availability.

## 2026-06-26 Terminal Probe Result

Codex ran the installed script through MT5 startup on `XAUUSD,M15`.

Terminal log:

- `script CalendarProbe (XAUUSD,M15) loaded successfully`
- `script CalendarProbe (XAUUSD,M15) removed`

MQL5 log:

- Request window: `2026.06.19 20:19` to `2026.07.03 20:19`
- `CalendarProbe result: count=140, error=0`
- Returned events included USD calendar events such as `Fed Governor Waller Speech`
  and `Current Account`

Interpretation:

The MT5 Economic Calendar API is available in the normal terminal. The earlier
`calendar_unavailable` result appears to be a Strategy Tester limitation, not a
basic implementation or parameter issue in the news guard.
