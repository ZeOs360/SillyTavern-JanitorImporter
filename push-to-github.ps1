# Quick Push to GitHub Script
# Run this after creating the repository on GitHub

Write-Host "🚀 Pushing SillyTavern-JanitorImporter to GitHub" -ForegroundColor Cyan
Write-Host ""

# Check if we're in the right directory
if (-not (Test-Path ".\README.md")) {
    Write-Host "❌ Error: Run this script from the SillyTavern-JanitorImporter directory!" -ForegroundColor Red
    exit 1
}

# Prompt for GitHub username (default to ZeOs360)
$username = Read-Host "Enter your GitHub username (default: ZeOs360)"
if ([string]::IsNullOrWhiteSpace($username)) {
    $username = "ZeOs360"
}

$repoUrl = "https://github.com/$username/SillyTavern-JanitorImporter.git"

Write-Host ""
Write-Host "📝 Before running this script, make sure you've created the GitHub repository:" -ForegroundColor Yellow
Write-Host "   1. Go to: https://github.com/new" -ForegroundColor Yellow
Write-Host "   2. Repository name: SillyTavern-JanitorImporter" -ForegroundColor Yellow
Write-Host "   3. Make it Public" -ForegroundColor Yellow
Write-Host "   4. DON'T initialize with README" -ForegroundColor Yellow
Write-Host ""

$confirm = Read-Host "Have you created the repository? (y/n)"
if ($confirm -ne "y") {
    Write-Host "Create the repository first, then run this script again." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "🔗 Adding remote origin..." -ForegroundColor Green
git remote add origin $repoUrl 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "   Remote already exists, updating..." -ForegroundColor Gray
    git remote set-url origin $repoUrl
}

Write-Host "📤 Pushing to GitHub..." -ForegroundColor Green
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Success! Your plugin is now on GitHub!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📍 Repository URL:" -ForegroundColor Cyan
    Write-Host "   https://github.com/$username/SillyTavern-JanitorImporter" -ForegroundColor White
    Write-Host ""
    Write-Host "🎯 Next steps:" -ForegroundColor Cyan
    Write-Host "   1. Create a release: https://github.com/$username/SillyTavern-JanitorImporter/releases/new" -ForegroundColor White
    Write-Host "   2. Share with the SillyTavern community!" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "❌ Push failed. Check the error above." -ForegroundColor Red
    Write-Host "   Make sure you've created the repository on GitHub first." -ForegroundColor Yellow
}
