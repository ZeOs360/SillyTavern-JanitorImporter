#!/usr/bin/env pwsh
# Installation script for JanitorAI Importer Plugin
# Usage: .\install.ps1 "C:\path\to\SillyTavern"

param(
    [Parameter(Mandatory=$true)]
    [string]$SillyTavernPath
)

$ErrorActionPreference = "Stop"

Write-Host "JanitorAI Importer Plugin Installer" -ForegroundColor Cyan
Write-Host "===================================" -ForegroundColor Cyan
Write-Host ""

# Validate SillyTavern path
if (-not (Test-Path $SillyTavernPath)) {
    Write-Host "Error: SillyTavern directory not found: $SillyTavernPath" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path (Join-Path $SillyTavernPath "server.js"))) {
    Write-Host "Error: Not a valid SillyTavern directory (server.js not found)" -ForegroundColor Red
    exit 1
}

Write-Host "Installing to: $SillyTavernPath" -ForegroundColor Green
Write-Host ""

# Create directories if they don't exist
$pluginDir = Join-Path $SillyTavernPath "plugins"
$extensionDir = Join-Path $SillyTavernPath "public\scripts\extensions"

if (-not (Test-Path $pluginDir)) {
    New-Item -ItemType Directory -Path $pluginDir -Force | Out-Null
}

if (-not (Test-Path $extensionDir)) {
    New-Item -ItemType Directory -Path $extensionDir -Force | Out-Null
}

# Copy server plugin
Write-Host "[1/4] Installing server plugin..." -ForegroundColor Yellow
$sourcePlugin = Join-Path $PSScriptRoot "."
$destPlugin = Join-Path $pluginDir "janitor-importer"

if (Test-Path $destPlugin) {
    Write-Host "  Removing existing plugin..." -ForegroundColor Gray
    Remove-Item -Path $destPlugin -Recurse -Force
}

Copy-Item -Path $sourcePlugin -Destination $destPlugin -Recurse -Force -Exclude @("*.ps1", "*.sh", "INSTALL.md", ".git*", "janitor-native-bypass.patch")
Write-Host "  ✓ Server plugin installed" -ForegroundColor Green

# Copy client extension
Write-Host "[2/4] Installing client extension..." -ForegroundColor Yellow
# Try to find 'client-extension' folder in root or current dir
$sourceExtension = Join-Path $PSScriptRoot "..\client-extension"
if (-not (Test-Path $sourceExtension)) {
    $sourceExtension = Join-Path $PSScriptRoot "client-extension"
}

$destExtension = Join-Path $extensionDir "janitor-importer"

if (Test-Path $sourceExtension) {
    if (Test-Path $destExtension) {
        Write-Host "  Removing existing extension..." -ForegroundColor Gray
        Remove-Item -Path $destExtension -Recurse -Force
    }
    Copy-Item -Path $sourceExtension -Destination $destExtension -Recurse -Force
    Write-Host "  ✓ Client extension installed" -ForegroundColor Green
} else {
    Write-Host "  ⚠ Client extension files not found - you may need to install manually" -ForegroundColor Yellow
}

# Check config.yaml
Write-Host "[3/4] Checking configuration..." -ForegroundColor Yellow
$configPath = Join-Path $SillyTavernPath "config.yaml"

if (Test-Path $configPath) {
    $configContent = Get-Content $configPath -Raw
    if ($configContent -match "enableServerPlugins:\s*true") {
        Write-Host "  ✓ Server plugins already enabled" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ WARNING: You need to enable server plugins in config.yaml" -ForegroundColor Yellow
        Write-Host "    Add or change: enableServerPlugins: true" -ForegroundColor Yellow
    }
} else {
    Write-Host "  ⚠ config.yaml not found - will be created on first run" -ForegroundColor Yellow
}

# Apply native Cloudflare bypass patch
Write-Host "[4/4] Applying native Cloudflare bypass patch to SillyTavern core..." -ForegroundColor Yellow

# Try to find the patch file in root or current dir
$sourcePatch = Join-Path $PSScriptRoot "..\janitor-native-bypass.patch"
if (-not (Test-Path $sourcePatch)) {
    $sourcePatch = Join-Path $PSScriptRoot "janitor-native-bypass.patch"
}

if (Test-Path $sourcePatch) {
    # Copy patch temporarily to SillyTavern root to ensure Git applies it with correct paths
    $tempPatch = Join-Path $SillyTavernPath "janitor-native-bypass.patch"
    Copy-Item -Path $sourcePatch -Destination $tempPatch -Force
    
    Push-Location -Path $SillyTavernPath
    
    # Run git apply and capture the output
    $gitOutput = git apply "janitor-native-bypass.patch" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Core code successfully patched!" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Patch could not be applied automatically. It might already be applied or there is a conflict." -ForegroundColor Yellow
        Write-Host "    Git output: $gitOutput" -ForegroundColor DarkGray
    }
    
    # Clean up the temporary patch file and return
    Remove-Item "janitor-native-bypass.patch" -ErrorAction SilentlyContinue
    Pop-Location
} else {
    Write-Host "  ⚠ Patch file not found! Please ensure 'janitor-native-bypass.patch' is in the repository root." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Make sure 'enableServerPlugins: true' is set in config.yaml" -ForegroundColor White
Write-Host "2. Restart SillyTavern" -ForegroundColor White
Write-Host "3. Try importing a JanitorAI character URL" -ForegroundColor White
Write-Host ""