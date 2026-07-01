# Wassali - Force Stop Script
# Kills everything running on port 3000 and any lingering node processes

Write-Host "🛑 Force stopping Wassali Backend..." -ForegroundColor Red

# Get processes using port 3000
$portProcesses = Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue
if ($portProcesses) {
    foreach ($proc in $portProcesses) {
        Write-Host "Killing process on port 3000 (PID: $($proc.OwningProcess))"
        Stop-Process -Id $proc.OwningProcess -Force -ErrorAction SilentlyContinue
    }
}

# Kill all node instances just to be sure
Get-Process -Name "node" -ErrorAction SilentlyContinue | ForEach-Object {
    Write-Host "Killing node process (PID: $($_.Id))"
    $_.Kill()
}

Write-Host "✅ Backend stopped. Port 3000 is now free." -ForegroundColor Green
