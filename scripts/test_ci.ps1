# CI Test Script for AI Language Coach
# This script runs all tests and generates coverage reports

param(
    [switch]$SkipGoldenTests,
    [switch]$SkipIntegrationTests,
    [switch]$CoverageOnly,
    [int]$CoverageThreshold = 80
)

$ErrorActionPreference = "Stop"
$frontendDir = "frontend"
$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  AI Language Coach - QA Test Suite" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Track results
$testResults = @()

function Run-TestStep {
    param(
        [string]$StepName,
        [scriptblock]$Command
    )
    
    Write-Host "`n--- $StepName ---" -ForegroundColor Yellow
    try {
        & $Command
        $script:testResults += @{ Step = $StepName; Status = "PASSED"; Duration = "N/A" }
        Write-Host "  [PASSED] $StepName" -ForegroundColor Green
        return $true
    } catch {
        $script:testResults += @{ Step = $StepName; Status = "FAILED"; Duration = "N/A" }
        Write-Host "  [FAILED] $StepName" -ForegroundColor Red
        Write-Host "  Error: $_" -ForegroundColor Red
        return $false
    }
}

# 1. Setup
Run-TestStep "Setup dependencies" {
    Set-Location $frontendDir
    flutter pub get
    Set-Location ..
}

# 2. Code Analysis
Run-TestStep "Code analysis" {
    Set-Location $frontendDir
    flutter analyze --no-fatal-infos
    Set-Location ..
}

# 3. Format Check
Run-TestStep "Format check" {
    Set-Location $frontendDir
    dart format --set-exit-if-changed .
    Set-Location ..
}

# 4. Unit Tests
$unitTestsPassed = Run-TestStep "Unit tests" {
    Set-Location $frontendDir
    flutter test --coverage --reporter expanded
    Set-Location ..
}

# 5. Widget Tests
$widgetTestsPassed = Run-TestStep "Widget tests" {
    Set-Location $frontendDir
    flutter test test/widgets/ --reporter expanded
    Set-Location ..
}

# 6. Core Tests
$coreTestsPassed = Run-TestStep "Core tests" {
    Set-Location $frontendDir
    flutter test test/core/ --reporter expanded
    Set-Location ..
}

# 7. Feature Tests
$featureTestsPassed = Run-TestStep "Feature tests" {
    Set-Location $frontendDir
    flutter test test/features/ --reporter expanded
    Set-Location ..
}

# 8. Golden Tests (optional)
if (-not $SkipGoldenTests) {
    Run-TestStep "Golden tests" {
        Set-Location $frontendDir
        flutter test test/features/golden/ --update-goldens
        Set-Location ..
    }
}

# 9. Integration Tests (optional)
if (-not $SkipIntegrationTests) {
    Run-TestStep "Integration tests" {
        Set-Location $frontendDir
        flutter test integration_test/ --reporter expanded
        Set-Location ..
    }
}

# 10. Edge Function Tests (requires Deno: https://deno.land)
if (Get-Command deno -ErrorAction SilentlyContinue) {
    Run-TestStep "Edge Function tests" {
        Set-Location "supabase/functions/shared/__tests__"
        deno test --allow-all
        Set-Location "../../.."
    }
} else {
    Write-Host "  [SKIP] Edge Function tests — Deno not installed" -ForegroundColor Yellow
}

# 11. Coverage Report
if ($CoverageOnly -or $unitTestsPassed) {
    Run-TestStep "Generate coverage report" {
        Set-Location $frontendDir
        if (Test-Path "coverage/lcov.info") {
            Write-Host "  Coverage report generated at coverage/lcov.info"
            
            # Check coverage threshold
            $coverageInfo = Get-Content "coverage/lcov.info" -Raw
            if ($coverageInfo -match "LF:(\d+)") {
                $totalLines = [int]$Matches[1]
                if ($coverageInfo -match "LH:(\d+)") {
                    $coveredLines = [int]$Matches[1]
                    $coveragePercent = [math]::Round(($coveredLines / $totalLines) * 100, 2)
                    Write-Host "  Coverage: $coveragePercent% ($coveredLines/$totalLines lines)"
                    
                    if ($coveragePercent -lt $CoverageThreshold) {
                        Write-Host "  WARNING: Coverage $coveragePercent% is below threshold $CoverageThreshold%" -ForegroundColor Yellow
                    }
                }
            }
        }
        Set-Location ..
    }
}

# Summary
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  Test Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$passed = ($testResults | Where-Object { $_.Status -eq "PASSED" }).Count
$failed = ($testResults | Where-Object { $_.Status -eq "FAILED" }).Count

foreach ($result in $testResults) {
    $color = if ($result.Status -eq "PASSED") { "Green" } else { "Red" }
    Write-Host "  $($result.Status): $($result.Step)" -ForegroundColor $color
}

Write-Host "`nTotal: $($testResults.Count) | Passed: $passed | Failed: $failed" -ForegroundColor Cyan

if ($failed -gt 0) {
    Write-Host "`nSome tests failed!" -ForegroundColor Red
    exit 1
} else {
    Write-Host "`nAll tests passed!" -ForegroundColor Green
    exit 0
}
