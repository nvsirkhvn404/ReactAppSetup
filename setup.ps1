# Stop on first error
$ErrorActionPreference = "Stop"

# The folder where the script lives (your template folder)
$templateRoot = $PSScriptRoot
# The folder where you're creating the project (where you run the script from)
$projectRoot = Get-Location


Write-Host "Template folder: $templateRoot"
Write-Host "Project folder:  $projectRoot"
Write-Host ""


# 1. Create Vite + React app in the current project folder
Write-Host "==> Creating Vite + React app..."
"n" | npx create-vite@latest ./ -- --template react --skip-git


# 2. Run initial npm install
Write-Host "==> Running npm install..."
npm install


# 3. Copy config files BEFORE Tailwind install
Write-Host "==> Copying template config files (vite.config.js, jsconfig.json)..."
Copy-Item (Join-Path $templateRoot "vite.config.js") -Destination (Join-Path $projectRoot "vite.config.js") -Force
Copy-Item (Join-Path $templateRoot "jsconfig.json") -Destination (Join-Path $projectRoot "jsconfig.json") -Force


# 4. Install Tailwind + Vite plugin
Write-Host "==> Installing Tailwind + @tailwindcss/vite..."
npm install tailwindcss @tailwindcss/vite


# 5. Replace src folder with your template src
Write-Host "==> Replacing src folder with template src..."
$projectSrc = Join-Path $projectRoot "src"
$templateSrc = Join-Path $templateRoot "src"

if (Test-Path $projectSrc) {
    Remove-Item $projectSrc -Recurse -Force
}

Copy-Item $templateSrc -Destination $projectSrc -Recurse


# 6. Init shadcn with neutral
Write-Host "==> Initializing shadcn/ui (neutral)..."
npx shadcn@latest init -y -b neutral


# 7. Copy components.json AFTER  Init Shadcn
Write-Host "==> Copying components.json..."
Copy-Item (Join-Path $templateRoot "components.json") -Destination (Join-Path $projectRoot "components.json") -Force


# 8. Adding a button component from shadcn
Write-Host "==> Add a button component from shadcn..."
npx shadcn@latest add button


# 9 Replace index.css with template version
Write-Host "==> Replacing index.css with template version..."
Copy-Item (Join-Path $templateRoot "index.css") -Destination (Join-Path $projectRoot "src\index.css") -Force


# 10. Start dev server
Write-Host "==> Starting dev server..."
npm run dev
