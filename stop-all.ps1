# SmartSure - Stop All Services
Write-Host "Stopping SmartSure services..." -ForegroundColor Cyan

$processes = @("SmartSure.Identity.API", "SmartSure.Claims.API", "SmartSure.Policy.API", "SmartSure.Admin.API", "SmartSure.Gateway")

foreach ($proc in $processes) {
    $p = Get-Process -Name $proc -ErrorAction SilentlyContinue
    if ($p) {
        Stop-Process -Name $proc -Force
        Write-Host "  Stopped $proc" -ForegroundColor Yellow
    }
}

# Stop Angular dev server (node process on port 4200)
$node = Get-NetTCPConnection -LocalPort 4200 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess
if ($node) {
    Stop-Process -Id $node -Force -ErrorAction SilentlyContinue
    Write-Host "  Stopped Frontend (port 4200)" -ForegroundColor Yellow
}

# Stop AI Service (Python Flask on port 5000)
$flask = Get-NetTCPConnection -LocalPort 5000 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess
if ($flask) {
    $flask | ForEach-Object { Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue }
    Write-Host "  Stopped AI Service (port 5000)" -ForegroundColor Yellow
}

Write-Host "All services stopped." -ForegroundColor Green
