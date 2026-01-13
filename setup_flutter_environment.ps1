# Flutter Setup Script (Manual/Auto)
# Installs to D:\flutter

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Green
Write-Host "     Flutter Setup (Smart Mode)         " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

$flutterDir = "D:\flutter"
$zipPath = "D:\flutter_windows.zip"
$mirrorUrl = "https://mirrors.cloud.tencent.com/flutter/flutter_infra_release/releases/stable/windows/flutter_windows_3.38.5-stable.zip"

# 1. Check existing installation
if (Test-Path "$flutterDir\bin\flutter.bat") {
    Write-Host "✅ Existing Flutter installation found at $flutterDir" -ForegroundColor Green
}
elseif (Test-Path $zipPath) {
    # 2. Extract manual zip
    Write-Host "Found manual zip at $zipPath. Extracting..." -ForegroundColor Yellow
    if (Test-Path $flutterDir) { Remove-Item $flutterDir -Recurse -Force }
    try {
        Expand-Archive -Path $zipPath -DestinationPath "D:\" -Force
        Write-Host "✅ Extraction complete." -ForegroundColor Green
        # Rename if extracted to 'flutter' (default)
    }
    catch {
        Write-Host "❌ Extraction failed: $_" -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "❌ No Flutter installation or zip file found." -ForegroundColor Red
    Write-Host "Please download Flutter manually from:" -ForegroundColor Yellow
    Write-Host $mirrorUrl -ForegroundColor Cyan
    Write-Host "Save it to: $zipPath" -ForegroundColor White
    exit 1
}

# 3. Configure Environment Variables (User Scope)
Write-Host "`nConfiguring Environment Variables..." -ForegroundColor Yellow

$flutterBin = "$flutterDir\bin"
$currentPath = [Environment]::GetEnvironmentVariable('Path', 'User')

if ($currentPath -notlike "*$flutterBin*") {
    $newPath = "$currentPath;$flutterBin"
    [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
    Write-Host "✅ Added $flutterBin to User PATH." -ForegroundColor Green
}
else {
    Write-Host "✅ $flutterBin is already in User PATH." -ForegroundColor Green
}

# Set Mirror Variables
[Environment]::SetEnvironmentVariable('PUB_HOSTED_URL', 'https://mirrors.cloud.tencent.com/dart-pub', 'User')
[Environment]::SetEnvironmentVariable('FLUTTER_STORAGE_BASE_URL', 'https://mirrors.cloud.tencent.com/flutter', 'User')

# 4. Refresh & Verify
$env:Path += ";$flutterBin"
$env:PUB_HOSTED_URL = "https://mirrors.cloud.tencent.com/dart-pub"
$env:FLUTTER_STORAGE_BASE_URL = "https://mirrors.cloud.tencent.com/flutter"

Write-Host "`nVerifying installation..." -ForegroundColor Yellow
if (Test-Path "$flutterBin\flutter.bat") {
    & "$flutterBin\flutter.bat" --version
}
else {
    Write-Host "❌ Flutter executable not found!" -ForegroundColor Red
}

Write-Host "`nSetup Complete!" -ForegroundColor Green