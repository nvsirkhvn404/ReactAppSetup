$ErrorActionPreference = "Stop"

$repoOwner = "nvsirkhvn404"
$repoName  = "ReactAppSetup"
$branch    = "main"

# ----------------------------------

Write-Host ""
Write-Host "Downloading setup files..." -ForegroundColor Cyan

# GitHub ZIP URL
$zipUrl = "https://github.com/$repoOwner/$repoName/archive/refs/heads/$branch.zip"

# temp folder
$tempRoot = Join-Path $env:TEMP ("ReactSetup_" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType
