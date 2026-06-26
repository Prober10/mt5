# News CSV Workflow

The EA uses two news data paths:

- Normal terminal: MT5 Economic Calendar API.
- Strategy Tester: exported CSV file.

With `InpNewsDataSource=NEWS_SOURCE_AUTO`, the EA chooses the correct path for
the environment.

## Export The CSV

Run this installed script in MT5:

`Scripts\ExportHighImpactNewsCsv`

Default export:

- Currencies: `USD`
- Date range: `2025.01.01 00:00` to `2026.12.31 23:59`
- Output: `Common\Files\FiboEA\high-impact-news.csv`

The script writes rows in this format:

`time,currency,importance,name`

Example:

`2026.06.10 12:30,USD,high,CPI m/m`

## Backtest With News Protection

Use these EA inputs:

- `InpUseNewsGuard=true`
- `InpNewsDataSource=NEWS_SOURCE_AUTO` or `NEWS_SOURCE_CSV`
- `InpNewsCsvFileName=FiboEA\high-impact-news.csv`
- `InpNewsFailSafeBlock=true`

The automated runner accepts:

```powershell
-UseNewsGuard true -NewsDataSource csv -NewsCsvFileName 'FiboEA\high-impact-news.csv'
```

## Notes

- Refresh the CSV before testing a new date range.
- CSV event times come from MT5's Economic Calendar and should be treated as
  broker/server time.
- If the CSV is missing and fail-safe is enabled, the EA refuses to trade.
