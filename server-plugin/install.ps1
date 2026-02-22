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
Write-Host "[1/3] Installing server plugin..." -ForegroundColor Yellow
$sourcePlugin = Join-Path $PSScriptRoot "."
$destPlugin = Join-Path $pluginDir "janitor-importer"

if (Test-Path $destPlugin) {
    Write-Host "  Removing existing plugin..." -ForegroundColor Gray
    Remove-Item -Path $destPlugin -Recurse -Force
}

Copy-Item -Path $sourcePlugin -Destination $destPlugin -Recurse -Force -Exclude @("*.ps1", "*.sh", "INSTALL.md", ".git*")
Write-Host "  ✓ Server plugin installed" -ForegroundColor Green

# Copy client extension
Write-Host "[2/3] Installing client extension..." -ForegroundColor Yellow
$sourceExtension = Join-Path $PSScriptRoot "..\public\scripts\extensions\janitor-importer"
$destExtension = Join-Path $extensionDir "janitor-importer"

if (-not (Test-Path $sourceExtension)) {
    # Try alternative path structure
    $sourceExtension = Join-Path $PSScriptRoot "public\scripts\extensions\janitor-importer"
}

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
Write-Host "[3/3] Checking configuration..." -ForegroundColor Yellow
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

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "1. Make sure 'enableServerPlugins: true' is set in config.yaml" -ForegroundColor White
Write-Host "2. (Optional) Apply the avatar patch: git apply plugins/janitor-importer/avatar-base64-support.patch" -ForegroundColor White
Write-Host "3. Restart SillyTavern" -ForegroundColor White
Write-Host "4. Try importing a JanitorAI character URL" -ForegroundColor White
Write-Host ""
