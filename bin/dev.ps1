# Start Rails server and Tailwind watcher together
# Usage: .\bin\dev.ps1

Write-Host "Starting Portfolio Tracker development servers..." -ForegroundColor Green

# Check if foreman is installed
$foremanInstalled = gem list foreman -i 2>$null
if ($foremanInstalled -ne "true") {
    Write-Host "Installing foreman..." -ForegroundColor Yellow
    gem install foreman
}

# Start both servers using foreman
foreman start -f Procfile.dev
