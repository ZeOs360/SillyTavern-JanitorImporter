param(
    [Parameter(Mandatory=$true)]
    [string]$SillyTavernPath
)

$ErrorActionPreference = "Stop"

Write-Host "JanitorAI Native Bypass Installer" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $SillyTavernPath)) {
    Write-Host "Error: SillyTavern directory not found: $SillyTavernPath" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path (Join-Path $SillyTavernPath "server.js"))) {
    Write-Host "Error: Not a valid SillyTavern directory (server.js not found)" -ForegroundColor Red
    exit 1
}

Write-Host "Applying native patch to SillyTavern core..." -ForegroundColor Yellow

$sourcePatch = Join-Path $PSScriptRoot "janitor-native-bypass.patch"

if (Test-Path $sourcePatch) {
    $tempPatch = Join-Path $SillyTavernPath "janitor-native-bypass.patch"
    Copy-Item -Path $sourcePatch -Destination $tempPatch -Force
    
    Push-Location -Path $SillyTavernPath
    
    $gitOutput = git apply "janitor-native-bypass.patch" 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ Core code successfully patched!" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ Patch could not be applied automatically. It might already be applied or there is a conflict." -ForegroundColor Yellow
        Write-Host "    Git output: $gitOutput" -ForegroundColor DarkGray
    }
    
    Remove-Item "janitor-native-bypass.patch" -ErrorAction SilentlyContinue
    Pop-Location
} else {
    Write-Host "  ⚠ Patch file not found! Please ensure 'janitor-native-bypass.patch' is in the repository root." -ForegroundColor Red
}

Write-Host ""
Write-Host "Installation complete! Please restart your SillyTavern server." -ForegroundColor Green
Write-Host ""