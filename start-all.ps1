# SmartSure - Start All Services (Shreya's Machine)
Write-Host "Starting SmartSure services..." -ForegroundColor Cyan

$root = $PSScriptRoot

# ── Backend Services ──────────────────────────────────────────────────────────
$services = @(
    @{ Name = "Identity API"; Project = "backend/services/identity/SmartSure.Identity.API/SmartSure.Identity.API.csproj" },
    @{ Name = "Claims API";   Project = "backend/services/claims/SmartSure.Claims.API/SmartSure.Claims.API.csproj" },
    @{ Name = "Policy API";   Project = "backend/services/policy/SmartSure.Policy.API/SmartSure.Policy.API.csproj" },
    @{ Name = "Admin API";    Project = "backend/services/admin/SmartSure.Admin.API/SmartSure.Admin.API.csproj" },
    @{ Name = "Gateway";      Project = "backend/gateway/SmartSure.Gateway/SmartSure.Gateway.csproj" }
)

foreach ($svc in $services) {
    Write-Host "  Starting $($svc.Name)..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$root'; dotnet run --project $($svc.Project)" -WindowStyle Normal
}

# ── AI Service (Python) ───────────────────────────────────────────────────────
Write-Host "  Starting AI Service..." -ForegroundColor Yellow
$aiDir = "$root/ollama_rag_app/ollama_rag_app"

# Find Python on Shreya's machine
$pyCmd = $null

# Check C:\Python314 first (known install location)
if (Test-Path "C:\Python314\python.exe") {
    $pyCmd = "C:\Python314\python.exe"
}
# Fallback: check PATH
elseif (Get-Command python -ErrorAction SilentlyContinue) {
    $pyCmd = "python"
}
elseif (Get-Command py -ErrorAction SilentlyContinue) {
    $pyCmd = "py"
}

if (-not $pyCmd) {
    Write-Host "  [ERROR] Python not found. Please verify Python is installed at C:\Python314" -ForegroundColor Red
} else {
    Write-Host "  Using Python: $pyCmd" -ForegroundColor Gray
    $commandStr = "cd '$aiDir'; if (-not (Test-Path '.venv')) { & '$pyCmd' -m venv .venv }; .\.venv\Scripts\python.exe -m pip install -q -r requirements.txt; .\.venv\Scripts\python.exe app.py"
    Start-Process powershell -ArgumentList "-NoExit", "-Command", $commandStr -WindowStyle Normal
}

# ── Ollama ────────────────────────────────────────────────────────────────────
Write-Host "  Checking Ollama..." -ForegroundColor Yellow
$ollamaExe = "C:\Users\SHREYA SINGH\AppData\Local\Programs\Ollama\ollama.exe"

if (-not (Test-Path $ollamaExe)) {
    Write-Host "  [ERROR] Ollama not found at: $ollamaExe" -ForegroundColor Red
} else {
    # Only start ollama serve if not already running on port 11434
    $ollamaRunning = netstat -ano 2>$null | Select-String ":11434"
    if ($ollamaRunning) {
        Write-Host "  Ollama already running on port 11434 — skipping serve." -ForegroundColor Green
    } else {
        Write-Host "  Starting Ollama server..." -ForegroundColor Yellow
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "& '$ollamaExe' serve" -WindowStyle Normal
        Start-Sleep -Seconds 3
    }

    # Run the model
    Write-Host "  Loading llama3.2:1b model..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoExit", "-Command", "& '$ollamaExe' run llama3.2:1b" -WindowStyle Normal
}

# ── Frontend ──────────────────────────────────────────────────────────────────
Write-Host "  Starting Frontend..." -ForegroundColor Yellow
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$root/frontend'; npx ng serve --port 4200" -WindowStyle Normal

# ── Summary ───────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "All services started." -ForegroundColor Green
Write-Host ""
Write-Host "  Identity   -> http://localhost:5001" -ForegroundColor White
Write-Host "  Claims     -> http://localhost:5008" -ForegroundColor White
Write-Host "  Policy     -> http://localhost:5152" -ForegroundColor White
Write-Host "  Admin      -> http://localhost:5113" -ForegroundColor White
Write-Host "  Gateway    -> http://localhost:5083" -ForegroundColor White
Write-Host "  AI Service -> http://localhost:5000" -ForegroundColor White
Write-Host "  Ollama     -> http://localhost:11434" -ForegroundColor White
Write-Host "  Frontend   -> http://localhost:4200" -ForegroundColor White