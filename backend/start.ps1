# Wassali Backend - Clean Start Script
# Kills all stale node processes then starts the dev server

Write-Host "🧹 Cleaning up stale node processes..." -ForegroundColor Yellow

# Kill ALL node processes
Get-Process -Name "node" -ErrorAction SilentlyContinue | ForEach-Object {
    $_.Kill()
}

Start-Sleep -Seconds 2

# Double-check port 3000 is free
$conn = Get-NetTCPConnection -LocalPort 3000 -ErrorAction SilentlyContinue
if ($conn) {
    Stop-Process -Id $conn.OwningProcess -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
}

Write-Host "✅ Port 3000 is free. Starting backend..." -ForegroundColor Green
npm run start:dev
