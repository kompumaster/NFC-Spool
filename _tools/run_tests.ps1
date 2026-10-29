# Runs each test file in a separate `flutter test` process.
#
# On Windows, flutter_tester.exe sometimes crashes at startup with 0xc0000005
# (antivirus interference). The whole suite then fails in a random file with
# "Connection closed before test suite loaded" or "did not complete".
# Running files one by one and retrying only those engine crashes keeps the
# result reliable without hiding real test failures.
[CmdletBinding()]
param(
    [string]$Flutter = 'flutter',
    [ValidateRange(1, 10)]
    [int]$Attempts = 3
)

$ErrorActionPreference = 'Continue'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$root = Split-Path -Parent $PSScriptRoot
$testDir = Join-Path $root 'test'
$files = @(Get-ChildItem -Path $testDir -Filter '*_test.dart' -File -Recurse | Sort-Object FullName)

if ($files.Count -eq 0) {
    Write-Error "Не найдены тесты в $testDir"
    exit 1
}

if (-not (Get-Command $Flutter -ErrorAction SilentlyContinue)) {
    Write-Error "Не найден Flutter: $Flutter"
    exit 1
}

$transientSignatures = @(
    'Connection closed before test suite loaded',
    'did not complete',
    'No tests were found'
)

$failed = [System.Collections.Generic.List[string]]::new()
$retries = 0
$index = 0

foreach ($file in $files) {
    $index++
    $relative = $file.FullName.Substring($root.Length + 1)
    $passed = $false

    for ($attempt = 1; $attempt -le $Attempts; $attempt++) {
        Write-Host ("[{0}/{1}] {2} (попытка {3}/{4})" -f $index, $files.Count, $relative, $attempt, $Attempts)
        $output = & $Flutter test $file.FullName --reporter compact 2>&1
        $code = $LASTEXITCODE

        if ($code -eq 0) {
            $summary = ($output | Where-Object { $_ -match 'All tests passed' } | Select-Object -Last 1)
            if ($summary) {
                Write-Host ("  " + $summary.Trim())
            }
            $passed = $true
            break
        }

        $text = ($output | Out-String)
        $isEngineCrash = $false
        foreach ($signature in $transientSignatures) {
            if ($text.Contains($signature)) {
                $isEngineCrash = $true
                break
            }
        }

        if (-not $isEngineCrash -or $attempt -eq $Attempts) {
            Write-Host '--- вывод теста ---'
            $output | Select-Object -Last 40 | ForEach-Object { Write-Host $_ }
            break
        }

        $retries++
        Write-Host '  сбой загрузки тестового движка, повтор'
    }

    if (-not $passed) {
        $failed.Add($relative)
    }
}

Write-Host ''
if ($failed.Count -eq 0) {
    Write-Host ("Все {0} файлов тестов прошли. Повторов из-за сбоя движка: {1}." -f $files.Count, $retries)
    exit 0
}

Write-Host ("Не прошли {0} из {1} файлов:" -f $failed.Count, $files.Count)
$failed | ForEach-Object { Write-Host ("  " + $_) }
exit 1
