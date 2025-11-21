# Stop on first error
$ErrorActionPreference = "Stop"

# ---------- Helpers ----------

function Write-Banner {
    Write-Host ""
    Write-Host "───────────────────────────────────────────────" -ForegroundColor Cyan
    Write-Host "        Nasir React Setup — v1.0" -ForegroundColor Yellow
    Write-Host "   Vite + Tailwind CSS + shadcn + Poppins" -ForegroundColor Yellow
    Write-Host "───────────────────────────────────────────────" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step($msg) {
    Write-Host "==> $msg" -ForegroundColor Cyan
}

function Fail-Step($msg, $err) {
    Write-Host "❌ $msg failed:" -ForegroundColor Red
    Write-Host "   $($err.Exception.Message)" -ForegroundColor DarkRed
    throw $err
}

function Ensure-Command($name) {
    if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
        throw "Required command '$name' is not available in PATH."
    }
}

function Ensure-EmptyFolder($path) {
    if (Test-Path $path) {
        $items = Get-ChildItem -Path $path -Force | Where-Object { $_.Name -notin '.', '..' }
        if ($items.Count -gt 0) {
            throw "Project folder '$path' is not empty. Run this in an empty folder."
        }
    }
}

function Ensure-TemplateFile($templateRoot, $name) {
    $full = Join-Path $templateRoot $name
    if (-not (Test-Path $full)) {
        throw "Template file '$name' not found at '$templateRoot'."
    }
    return $full
}

# ---------- Start ----------

Write-Banner

$templateRoot = $PSScriptRoot
$projectRoot  = Get-Location

Write-Host "Template: $templateRoot" -ForegroundColor DarkGray
Write-Host "Project:  $projectRoot"  -ForegroundColor DarkGray
Write-Host ""

try {
    # 0. Basic checks
    Write-Step "Checking required commands (node, npm, npx)..."
    Ensure-Command "node"
    Ensure-Command "npm"
    Ensure-Command "npx"

    Write-Step "Verifying project folder is empty..."
    Ensure-EmptyFolder $projectRoot

    # 1. Create Vite + React app
    Write-Step "Creating Vite + React app..."
    try {
        "n" | npx create-vite@latest ./ -- --template react --skip-git
    } catch {
        Fail-Step "Create Vite project" $_
    }

    # 2. Install base dependencies
    Write-Step "Installing npm dependencies..."
    try {
        npm install
    } catch {
        Fail-Step "npm install" $_
    }

    # 3. Copy config files (vite + jsconfig)
    Write-Step "Copying template config files..."
    try {
        $viteConfigTemplate = Ensure-TemplateFile $templateRoot "vite.config.js"
        $jsConfigTemplate   = Ensure-TemplateFile $templateRoot "jsconfig.json"

        Copy-Item $viteConfigTemplate -Destination (Join-Path $projectRoot "vite.config.js") -Force
        Copy-Item $jsConfigTemplate   -Destination (Join-Path $projectRoot "jsconfig.json") -Force
    } catch {
        Fail-Step "Copy config files" $_
    }

    # 4. Install Tailwind + Vite plugin
    Write-Step "Installing Tailwind + @tailwindcss/vite..."
    try {
        npm install tailwindcss @tailwindcss/vite
    } catch {
        Fail-Step "Install Tailwind" $_
    }

    # 5. Replace src with template src
    Write-Step "Replacing src folder with template src..."
    try {
        $projectSrc  = Join-Path $projectRoot "src"
        $templateSrc = Join-Path $templateRoot "src"

        if (-not (Test-Path $templateSrc)) {
            throw "Template 'src' folder not found at '$templateSrc'."
        }

        if (Test-Path $projectSrc) {
            Remove-Item $projectSrc -Recurse -Force
        }

        Copy-Item $templateSrc -Destination $projectSrc -Recurse
    } catch {
        Fail-Step "Replace src" $_
    }

    # 6. Init shadcn/ui
    Write-Step "Initializing shadcn/ui (base color: neutral)..."
    try {
        npx shadcn@latest init -y -b neutral
    } catch {
        Fail-Step "Initialize shadcn/ui" $_
    }

    # 7. Copy components.json
    Write-Step "Applying components.json..."
    try {
        $componentsTemplate = Ensure-TemplateFile $templateRoot "components.json"
        Copy-Item $componentsTemplate -Destination (Join-Path $projectRoot "components.json") -Force
    } catch {
        Fail-Step "Copy components.json" $_
    }

    # 8. Add shadcn button
    Write-Step "Adding shadcn button component..."
    try {
        npx shadcn@latest add button
    } catch {
        Fail-Step "Add shadcn button" $_
    }

    # 9. Replace index.css with template version
    Write-Step "Replacing src/index.css with template version..."
    try {
        $indexCssTemplate = Ensure-TemplateFile $templateRoot "index.css"
        $projectIndexCss  = Join-Path $projectSrc "index.css"
        Copy-Item $indexCssTemplate -Destination $projectIndexCss -Force
    } catch {
        Fail-Step "Replace index.css" $_
    }

    Write-Host ""
    Write-Host "✅ Setup complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Green
    Write-Host "  npm run dev" -ForegroundColor Green
    Write-Host ""

    # 10. Optionally start dev server automatically
    Write-Step "Starting dev server (Ctrl + C to stop)..."
    npm run dev
}
catch {
    Write-Host ""
    Write-Host "❌ Setup failed." -ForegroundColor Red
    Write-Host "   $($_.Exception.Message)" -ForegroundColor DarkRed
    Write-Host ""
    exit 1
}
