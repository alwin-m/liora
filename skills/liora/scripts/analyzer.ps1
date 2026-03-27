# Liora Project Healthy Check & Analyzer
# This script scans the project structure to ensure it matches the core Liora architecture.

$root = "."
$lib = Join-Path $root "lib"
$skills = Join-Path $root "skills"

Function Write-Header($text) {
    Write-Host "`n=== $text ===" -ForegroundColor Cyan
}

Write-Header "Project Structure Validation"
$requiredDirs = @("lib/core", "lib/services", "lib/home", "lib/admin", "lib/shop", "lib/Screens")
foreach ($dir in $requiredDirs) {
    $path = Join-Path $root $dir
    if (Test-Path $path) {
        Write-Host "[OK] Detected module: $dir" -ForegroundColor Green
    } else {
        Write-Host "[WARNING] Missing module: $dir" -ForegroundColor Yellow
    }
}

Write-Header "Core File Presence"
$requiredFiles = @("lib/main.dart", "lib/core/cycle_session.dart", "lib/core/notification_service.dart", "pubspec.yaml")
foreach ($file in $requiredFiles) {
    $path = Join-Path $root $file
    if (Test-Path $path) {
        Write-Host "[OK] Found file: $file" -ForegroundColor Green
    } else {
        Write-Host "[MISSING!] Critical component not found: $file" -ForegroundColor Red
    }
}

Write-Header "Code Metrics (Rough)"
$dartFiles = Get-ChildItem -Path $lib -Filter *.dart -Recurse
$totalLines = 0
foreach ($f in $dartFiles) {
    $lines = (Get-Content $f.FullName | Measure-Object -Line).Lines
    $totalLines += $lines
}
Write-Host "Total Dart Files: $($dartFiles.Count)" -ForegroundColor Gray
Write-Host "Estimated Code Volume: $totalLines lines" -ForegroundColor Gray

Write-Header "Dependencies Check"
if (Test-Path (Join-Path $root "pubspec.yaml")) {
    $pubspec = Get-Content (Join-Path $root "pubspec.yaml")
    $hasFirebase = $pubspec -match "firebase_core"
    $hasProvider = $pubspec -match "provider"
    
    if ($hasFirebase) { Write-Host "[OK] Firebase dependency detected." -ForegroundColor Green }
    if ($hasProvider) { Write-Host "[OK] Provider dependency detected." -ForegroundColor Green }
}

Write-Header "Analysis Complete"
Write-Host "Liora is ready for development." -ForegroundColor White
