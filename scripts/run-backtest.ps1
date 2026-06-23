[CmdletBinding()]
param(
    [string]$TerminalPath = 'C:\Program Files\MetaTrader 5\terminal64.exe',
    [string]$TerminalDataPath = "$env:APPDATA\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075",
    [string]$ReportDirectory = "$env:USERPROFILE\Documents\MT5\automated-reports",
    [string]$FromDate,
    [string]$ToDate,
    [string]$UseBuySessionFilter,
    [string]$ReportLabel,
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
$safeReportLabel = ''
if (-not [string]::IsNullOrWhiteSpace($ReportLabel)) {
    $safeReportLabel = '-' + ($ReportLabel -replace '[^A-Za-z0-9_-]', '-')
}
$reportBaseName = "FiboRetracementEA-XAUUSD-M15$safeReportLabel-$timestamp"
$relativeReportDirectory = 'backtest-reports'
$relativeReportPath = "$relativeReportDirectory\$reportBaseName.htm"
$stagingReportDirectory = Join-Path $TerminalDataPath $relativeReportDirectory
$stagingReportPath = Join-Path $TerminalDataPath $relativeReportPath
$reportPath = Join-Path $ReportDirectory "$reportBaseName.htm"
$configPath = Join-Path $env:TEMP "FiboRetracementEA-backtest-$timestamp.ini"
$commonFilesPath = Join-Path $env:APPDATA 'MetaQuotes\Terminal\Common\Files'
$diagnosticsPath = Join-Path $commonFilesPath 'FiboEA\diagnostics.csv'
$diagnosticsReportPath = Join-Path $ReportDirectory "$reportBaseName-diagnostics.csv"

New-Item -ItemType Directory -Path $stagingReportDirectory -Force | Out-Null
Remove-Item -LiteralPath $diagnosticsPath -Force -ErrorAction SilentlyContinue
$config = Get-Content -LiteralPath $templatePath -Raw
$config = $config.Replace('{{REPORT_PATH}}', $relativeReportPath)
if (-not [string]::IsNullOrWhiteSpace($FromDate)) {
    $config = $config -replace '(?m)^FromDate=.*$', "FromDate=$FromDate"
}
if (-not [string]::IsNullOrWhiteSpace($ToDate)) {
    $config = $config -replace '(?m)^ToDate=.*$', "ToDate=$ToDate"
}
if (-not [string]::IsNullOrWhiteSpace($UseBuySessionFilter)) {
    $filterText = switch -Regex ($UseBuySessionFilter.Trim()) {
        '^(1|true|yes)$' { 'true'; break }
        '^(0|false|no)$' { 'false'; break }
        default { throw "UseBuySessionFilter must be true/false, yes/no, or 1/0." }
    }
    $config = $config -replace '(?m)^InpUseBuySessionFilter=.*$', "InpUseBuySessionFilter=$filterText||false||0||true||N"
}
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
    if (Test-Path -LiteralPath $diagnosticsPath) {
        Copy-Item -LiteralPath $diagnosticsPath -Destination $diagnosticsReportPath -Force
        [Console]::WriteLine("Diagnostics: $diagnosticsReportPath")
    }
    $report = Get-Item -LiteralPath $reportPath
    [Console]::WriteLine("Report: $($report.FullName)")
}
finally {
    Remove-Item -LiteralPath $configPath -Force -ErrorAction SilentlyContinue
}
