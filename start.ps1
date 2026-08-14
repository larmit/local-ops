[CmdletBinding()]
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $ServerArguments
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Set-Location -LiteralPath $PSScriptRoot

$pythonCandidates = [System.Collections.Generic.List[string]]::new()
$localAppData = [Environment]::GetFolderPath('LocalApplicationData')
$pythonRoot = Join-Path $localAppData 'Programs\Python'
$installations = Get-ChildItem -LiteralPath $pythonRoot -Directory -ErrorAction SilentlyContinue |
    Where-Object Name -Match '^Python\d+$' |
    Sort-Object Name -Descending
foreach ($installation in $installations) {
    $candidate = Join-Path $installation.FullName 'python.exe'
    if (Test-Path -LiteralPath $candidate -PathType Leaf) {
        $pythonCandidates.Add($candidate)
    }
}

$pathPython = Get-Command python.exe -ErrorAction SilentlyContinue |
    Select-Object -First 1
if ($null -ne $pathPython -and $pathPython.Source) {
    $pythonCandidates.Add($pathPython.Source)
}

$selectedPython = $null
foreach ($candidate in $pythonCandidates | Select-Object -Unique) {
    try {
        $versionText = & $candidate -c "import sys; print('%d.%d' % sys.version_info[:2])" 2>$null
        $versionParts = $versionText.Trim().Split('.')
        if ([int]$versionParts[0] -eq 3 -and [int]$versionParts[1] -ge 12) {
            $selectedPython = $candidate
            break
        }
    } catch {
        continue
    }
}

if (-not $selectedPython) {
    Write-Error '未找到 Python 3.12 或更高版本。请安装 64 位 CPython 后重试。'
    exit 1
}

Write-Host "使用 Python: $selectedPython"
& $selectedPython (Join-Path $PSScriptRoot 'server.py') @ServerArguments
exit $LASTEXITCODE
