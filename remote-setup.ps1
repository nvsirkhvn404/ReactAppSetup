# remote-setup.ps1
$ErrorActionPreference = "Stop"

$repoOwner = "nvsirkhvn404"
$repoName  = "ReactAppSetup"
$branch    = "main"

Write-Host ""
Write-Host "Downloading setup files..." -ForegroundColor Cyan

# GitHub ZIP URL
$zipUrl = "https://github.com/$repoOwner/$repoName/archive/refs/heads/$branch.zip"

# Create temp folder
$tempRoot = Join-Path $env:TEMP ("ReactSetup_" + [guid]::NewGuid().ToString("N"))
[System.IO.Directory]::CreateDirectory($tempRoot) | Out-Null

$zipPath = Join-Path $tempRoot "repo.zip"

# Download repo zip
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath

Write-Host "Extracting files..." -ForegroundColor Cyan
Expand-Archive -Path $zipPath -DestinationPath $tempRoot -Force

# Path where GitHub extracts the repo
$extractedRepo = Join-Path $tempRoot "$repoName-$branch"

# Path to setup.ps1 inside the repo
$setupScript = Join-Path $extractedRepo "setup.ps1"

if (-not (Test-Path $setupScript)) {
    Write-Host "❌ setup.ps1 not found in repo root!" -ForegroundColor Red
    Write-Host "Expected at: $setupScript" -ForegroundColor DarkRed
    Remove-Item $tempRoot -Recurse -Force
    exit 1
}

Write-Host "Running setup script..." -ForegroundColor Cyan

# Run setup.ps1 in the current project folder
$projectRoot = Get-Location

Push-Location $projectRoot
try {
    & $setupScript
}
finally {
    Pop-Location
    Write-Host "Cleaning up temp files..." -ForegroundColor DarkGray
    Remove-Item $tempRoot -Recurse -Force
}

Write-Host "Done." -ForegroundColor Green
Write-Host ""
Write-Host "Starting dev server (Ctrl + C to stop)..." -ForegroundColor Cyan
Write-Host ""

# Run dev server in the project folder
Push-Location $projectRoot
npm run dev
Pop-Location
