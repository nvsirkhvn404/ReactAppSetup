$ErrorActionPreference = 'Stop'

Write-Host ''
Write-Host '========================================'
Write-Host ' Nasir React Setup v1.0'
Write-Host ' Vite + Tailwind + shadcn + Poppins'
Write-Host '========================================'
Write-Host ''

# The folder where the script lives (your template folder)
$templateRoot = $PSScriptRoot
# The folder where you're creating the project (where you run the script from)
$projectRoot = Get-Location

Write-Host ('Template folder: {0}' -f $templateRoot)
Write-Host ('Project folder:  {0}' -f $projectRoot)
Write-Host ''

# 1. Create Vite + React app in the current project folder
Write-Host '==> Creating Vite + React app...'
"n" | npx create-vite@latest ./ -- --template react --skip-git

# 2. Run initial npm install
Write-Host '==> Running npm install...'
npm install

# 3. Copy config files BEFORE Tailwind install
Write-Host '==> Copying template config files: vite.config.js, jsconfig.json'
Copy-Item (Join-Path $templateRoot 'vite.config.js') -Destination (Join-Path $projectRoot 'vite.config.js') -Force
Copy-Item (Join-Path $templateRoot 'jsconfig.json') -Destination (Join-Path $projectRoot 'jsconfig.json') -Force

# 4. Install Tailwind + Vite plugin
Write-Host '==> Installing Tailwind and @tailwindcss/vite...'
npm install tailwindcss @tailwindcss/vite

# 5. Replace src folder with your template src
Write-Host '==> Replacing src folder with template src...'
$projectSrc = Join-Path $projectRoot 'src'
$templateSrc = Join-Path $templateRoot 'src'

if (Test-Path $projectSrc) {
    Remove-Item $projectSrc -Recurse -Force
}

Copy-Item $templateSrc -Destination $projectSrc -Recurse

# 6. Init shadcn with neutral
Write-Host '==> Initializing shadcn/ui (neutral)...'
npx shadcn@latest init -y -b neutral

# 7. Copy components.json AFTER Init shadcn
Write-Host '==> Copying components.json...'
Copy-Item (Join-Path $templateRoot 'components.json') -Destination (Join-Path $projectRoot 'components.json') -Force

# 8. Adding a button component from shadcn
Write-Host '==> Adding shadcn button component...'
npx shadcn@latest add button

# 9. Replace index.css with template version
Write-Host '==> Replacing index.css with template version...'
$projectIndexCss = Join-Path $projectSrc 'index.css'
Copy-Item (Join-Path $templateRoot 'index.css') -Destination $projectIndexCss -Force

# 10. Done / instructions
Write-Host ''
Write-Host 'Setup complete.' -ForegroundColor Green
Write-Host ''
Write-Host 'Next steps:'
Write-Host '  npm run dev'
Write-Host ''
