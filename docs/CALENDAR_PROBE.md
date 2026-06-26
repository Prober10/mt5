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
