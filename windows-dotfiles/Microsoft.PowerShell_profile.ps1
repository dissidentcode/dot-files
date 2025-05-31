
Write-Host "Sourcing profile: $PROFILE" -ForegroundColor Cyan
# Microsoft.PowerShell_profile.ps1 - Auto-generated
$dotDir = "$HOME\.powershell"
if (Test-Path "$dotDir\aliases.ps1") { . "$dotDir\aliases.ps1" }
if (Test-Path "$dotDir\functions.ps1") { . "$dotDir\functions.ps1" }

# Explicitly set Starship config file
$env:STARSHIP_CONFIG = "$env:LOCALAPPDATA\\starship.toml"

# Init starship
try {
    $starship = Get-Command starship -ErrorAction Stop
    Invoke-Expression (&starship init powershell | Out-String)
} catch {

    Write-Host "Starship not found in PATH." -ForegroundColor Yellow
}

# Init zoxide
try {
    $zoxide = Get-Command zoxide -ErrorAction Stop
    Invoke-Expression (&zoxide init powershell | Out-String)
} catch {
    Write-Host "Zoxide not found in PATH." -ForegroundColor Yellow
}

# Show system summary on shell launch
if (Get-Command winfetch -ErrorAction SilentlyContinue) {
    winfetch
}
