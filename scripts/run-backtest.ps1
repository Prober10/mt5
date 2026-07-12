[CmdletBinding()]
param(
    [string]$TerminalPath = 'C:\Program Files\MetaTrader 5\terminal64.exe',
    [string]$TerminalDataPath = "$env:APPDATA\MetaQuotes\Terminal\D0E8209F77C8CF37AD8BF550E51FF075",
    [string]$ReportDirectory = "$env:USERPROFILE\Documents\MT5\automated-reports",
    [string]$FromDate,
    [string]$ToDate,
    [string]$UseBuySessionFilter,
    [string]$UseCoreSessionFilter,
    [string]$CoreSessionStartHour,
    [string]$CoreSessionEndHour,
    [string]$UseSwingBandFilter,
    [string]$AvoidSwingMinPoints,
    [string]$AvoidSwingMaxPoints,
    [string]$UseNewsGuard,
    [string]$NewsDataSource,
    [string]$NewsCurrencies,
    [string]$NewsCsvFileName,
    [string]$NewsMinutesBefore,
    [string]$NewsMinutesAfter,
    [string]$NewsCancelPendingMinutesBefore,
    [string]$NewsFailSafeBlock,
    [string]$PendingOrderExpirationHours,
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
if (-not [string]::IsNullOrWhiteSpace($UseCoreSessionFilter)) {
    $filterText = switch -Regex ($UseCoreSessionFilter.Trim()) {
        '^(1|true|yes)$' { 'true'; break }
        '^(0|false|no)$' { 'false'; break }
        default { throw "UseCoreSessionFilter must be true/false, yes/no, or 1/0." }
    }
    $config = $config -replace '(?m)^InpUseCoreSessionFilter=.*$', "InpUseCoreSessionFilter=$filterText||false||0||true||N"
}
if (-not [string]::IsNullOrWhiteSpace($CoreSessionStartHour)) {
    [int]$startHour = 0
    if (-not [int]::TryParse($CoreSessionStartHour, [ref]$startHour) -or $startHour -lt 0 -or $startHour -gt 23) {
        throw "CoreSessionStartHour must be an integer from 0 through 23."
    }
    $config = $config -replace '(?m)^InpCoreSessionStartHour=.*$', "InpCoreSessionStartHour=$startHour||12||0||23||N"
}
if (-not [string]::IsNullOrWhiteSpace($CoreSessionEndHour)) {
    [int]$endHour = 0
    if (-not [int]::TryParse($CoreSessionEndHour, [ref]$endHour) -or $endHour -lt 0 -or $endHour -gt 23) {
        throw "CoreSessionEndHour must be an integer from 0 through 23."
    }
    $config = $config -replace '(?m)^InpCoreSessionEndHour=.*$', "InpCoreSessionEndHour=$endHour||17||0||23||N"
}
if (-not [string]::IsNullOrWhiteSpace($UseSwingBandFilter)) {
    $filterText = switch -Regex ($UseSwingBandFilter.Trim()) {
        '^(1|true|yes)$' { 'true'; break }
        '^(0|false|no)$' { 'false'; break }
        default { throw "UseSwingBandFilter must be true/false, yes/no, or 1/0." }
    }
    $config = $config -replace '(?m)^InpUseSwingBandFilter=.*$', "InpUseSwingBandFilter=$filterText||false||0||true||N"
}
if (-not [string]::IsNullOrWhiteSpace($AvoidSwingMinPoints)) {
    [double]$minPoints = 0.0
    if (-not [double]::TryParse($AvoidSwingMinPoints, [Globalization.NumberStyles]::Float, [Globalization.CultureInfo]::InvariantCulture, [ref]$minPoints)) {
        throw "AvoidSwingMinPoints must be a number."
    }
    if ($minPoints -lt 0.0) {
        throw "AvoidSwingMinPoints must be greater than or equal to zero."
    }
    $minPointsText = $minPoints.ToString('0.########', [Globalization.CultureInfo]::InvariantCulture)
    $config = $config -replace '(?m)^InpAvoidSwingMinPoints=.*$', "InpAvoidSwingMinPoints=$minPointsText||2500.0||250.000000||25000.000000||N"
}
if (-not [string]::IsNullOrWhiteSpace($AvoidSwingMaxPoints)) {
    [double]$maxPoints = 0.0
    if (-not [double]::TryParse($AvoidSwingMaxPoints, [Globalization.NumberStyles]::Float, [Globalization.CultureInfo]::InvariantCulture, [ref]$maxPoints)) {
        throw "AvoidSwingMaxPoints must be a number."
    }
    if ($maxPoints -lt 0.0) {
        throw "AvoidSwingMaxPoints must be greater than or equal to zero."
    }
    $maxPointsText = $maxPoints.ToString('0.########', [Globalization.CultureInfo]::InvariantCulture)
    $config = $config -replace '(?m)^InpAvoidSwingMaxPoints=.*$', "InpAvoidSwingMaxPoints=$maxPointsText||5000.0||500.000000||50000.000000||N"
}
if (-not [string]::IsNullOrWhiteSpace($UseNewsGuard)) {
    $filterText = switch -Regex ($UseNewsGuard.Trim()) {
        '^(1|true|yes)$' { 'true'; break }
        '^(0|false|no)$' { 'false'; break }
        default { throw "UseNewsGuard must be true/false, yes/no, or 1/0." }
    }
    $config = $config -replace '(?m)^InpUseNewsGuard=.*$', "InpUseNewsGuard=$filterText||false||0||true||N"
}
if (-not [string]::IsNullOrWhiteSpace($NewsDataSource)) {
    $sourceText = switch -Regex ($NewsDataSource.Trim()) {
        '^(0|auto)$' { '0'; break }
        '^(1|calendar)$' { '1'; break }
        '^(2|csv)$' { '2'; break }
        default { throw "NewsDataSource must be auto, calendar, csv, 0, 1, or 2." }
    }
    $config = $config -replace '(?m)^InpNewsDataSource=.*$', "InpNewsDataSource=$sourceText||0||0||2||N"
}
if (-not [string]::IsNullOrWhiteSpace($NewsCurrencies)) {
    $config = $config -replace '(?m)^InpNewsCurrencies=.*$', "InpNewsCurrencies=$NewsCurrencies"
}
if (-not [string]::IsNullOrWhiteSpace($NewsCsvFileName)) {
    $config = $config -replace '(?m)^InpNewsCsvFileName=.*$', "InpNewsCsvFileName=$NewsCsvFileName"
}
if (-not [string]::IsNullOrWhiteSpace($NewsMinutesBefore)) {
    [int]$minutesBefore = 0
    if (-not [int]::TryParse($NewsMinutesBefore, [ref]$minutesBefore) -or $minutesBefore -lt 0) {
        throw "NewsMinutesBefore must be a non-negative integer."
    }
    $config = $config -replace '(?m)^InpNewsMinutesBefore=.*$', "InpNewsMinutesBefore=$minutesBefore||2||1||30||N"
}
if (-not [string]::IsNullOrWhiteSpace($NewsMinutesAfter)) {
    [int]$minutesAfter = 0
    if (-not [int]::TryParse($NewsMinutesAfter, [ref]$minutesAfter) -or $minutesAfter -lt 0) {
        throw "NewsMinutesAfter must be a non-negative integer."
    }
    $config = $config -replace '(?m)^InpNewsMinutesAfter=.*$', "InpNewsMinutesAfter=$minutesAfter||2||1||30||N"
}
if (-not [string]::IsNullOrWhiteSpace($NewsCancelPendingMinutesBefore)) {
    [int]$cancelMinutesBefore = 0
    if (-not [int]::TryParse($NewsCancelPendingMinutesBefore, [ref]$cancelMinutesBefore) -or $cancelMinutesBefore -lt 0) {
        throw "NewsCancelPendingMinutesBefore must be a non-negative integer."
    }
    $config = $config -replace '(?m)^InpNewsCancelPendingMinutesBefore=.*$', "InpNewsCancelPendingMinutesBefore=$cancelMinutesBefore||5||1||60||N"
}
if (-not [string]::IsNullOrWhiteSpace($NewsFailSafeBlock)) {
    $filterText = switch -Regex ($NewsFailSafeBlock.Trim()) {
        '^(1|true|yes)$' { 'true'; break }
        '^(0|false|no)$' { 'false'; break }
        default { throw "NewsFailSafeBlock must be true/false, yes/no, or 1/0." }
    }
    $config = $config -replace '(?m)^InpNewsFailSafeBlock=.*$', "InpNewsFailSafeBlock=$filterText||false||0||true||N"
}
if (-not [string]::IsNullOrWhiteSpace($PendingOrderExpirationHours)) {
    [double]$expirationHours = 0.0
    if (-not [double]::TryParse($PendingOrderExpirationHours, [Globalization.NumberStyles]::Float, [Globalization.CultureInfo]::InvariantCulture, [ref]$expirationHours)) {
        throw "PendingOrderExpirationHours must be a number."
    }
    if ($expirationHours -lt 0.0) {
        throw "PendingOrderExpirationHours must be greater than or equal to zero."
    }
    $expirationText = $expirationHours.ToString('0.########', [Globalization.CultureInfo]::InvariantCulture)
    $config = $config -replace '(?m)^InpPendingOrderExpirationHours=.*$', "InpPendingOrderExpirationHours=$expirationText||0.0||1.000000||24.000000||N"
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
