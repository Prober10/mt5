[CmdletBinding()]
param(
    [string]$TerminalPath = 'C:\Program Files\MetaTrader 5\terminal64.exe',
    [string]$TerminalDataPath = "$env:APPDATA\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075",
    [string]$ReportDirectory = "$env:USERPROFILE\Documents\MT5\automated-reports",
    [int]$TimeoutSeconds = 900
)

$ErrorActionPreference = 'Stop'

$templatePath = Join-Path $PSScriptRoot 'backtest-xauusd-m15.ini'
if (-not (Test-Path -LiteralPath $TerminalPath)) {
    throw "MT5 terminal was not found at: $TerminalPath"
}
if (-not (Test-Path -LiteralPath $templatePath)) {
    throw "Tester configuration was not found at: $templatePath"
}

$terminalFullPath = [IO.Path]::GetFullPath($TerminalPath)
$runningTerminal = Get-Process -Name 'terminal64' -ErrorAction SilentlyContinue |
    Where-Object { $_.Path -eq $terminalFullPath }
if ($runningTerminal) {
    throw 'MT5 is currently open. Close it normally before running an automated backtest.'
}

New-Item -ItemType Directory -Path $ReportDirectory -Force | Out-Null
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$reportBaseName = "FiboRetracementEA-XAUUSD-M15-$timestamp"
$relativeReportDirectory = 'backtest-reports'
$relativeReportPath = "$relativeReportDirectory\$reportBaseName.htm"
$stagingReportDirectory = Join-Path $TerminalDataPath $relativeReportDirectory
$stagingReportPath = Join-Path $TerminalDataPath $relativeReportPath
$reportPath = Join-Path $ReportDirectory "$reportBaseName.htm"
$configPath = Join-Path $env:TEMP "FiboRetracementEA-backtest-$timestamp.ini"

New-Item -ItemType Directory -Path $stagingReportDirectory -Force | Out-Null
$config = Get-Content -LiteralPath $templatePath -Raw
$config = $config.Replace('{{REPORT_PATH}}', $relativeReportPath)
[IO.File]::WriteAllText($configPath, $config, [Text.Encoding]::Unicode)

try {
    $process = Start-Process -FilePath $terminalFullPath `
        -ArgumentList "/config:$configPath" -PassThru

    if (-not $process.WaitForExit($TimeoutSeconds * 1000)) {
        throw "MT5 did not finish within $TimeoutSeconds seconds. It was left running for inspection."
    }

    if (-not (Test-Path -LiteralPath $stagingReportPath)) {
        throw "MT5 exited without creating the expected report: $stagingReportPath"
    }

    Get-ChildItem -LiteralPath $stagingReportDirectory -File |
        Where-Object { $_.BaseName -like "$reportBaseName*" } |
        Copy-Item -Destination $ReportDirectory -Force
    $report = Get-Item -LiteralPath $reportPath
    [Console]::WriteLine("Report: $($report.FullName)")
}
finally {
    Remove-Item -LiteralPath $configPath -Force -ErrorAction SilentlyContinue
}
