<# run this script from withing the containing directory using: pwsh -NoProfile -ExecutionPolicy Bypass -File .\bootstrap.ps1
    
Complete Windows Dotfiles Bootstrap Script
- Ensures latest PowerShell 7+, Git, Scoop, Winget
- Checks for admin
- Clones or updates dotfiles repo as ~/.dotfiles
- Installs packages from links.prop & locations.txt
- Creates all symlinks (dirs & files) with backup
- Ensures $PATH and profile sourcing
- Logs all actions
#>

# --- CONFIGURATION ---
$DotfilesDir = "$HOME\.dotfiles\windows-dotfiles"
$PropFile = "$DotfilesDir\links.prop"
$LogFile = "$HOME\.powershell\bootstrap.log"
$LocationsFile = "$DotfilesDir\locations.txt"
$RepoUrl = "https://github.com/dissidentcode/dot-files.git"
$DotfilesRoot = "$HOME\.dotfiles"

# --- LOGGING ---
Function Write-Log($Message) {
  $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -Append -FilePath $LogFile
}

Write-Log "===== Starting dotfiles bootstrap at $(Get-Date) ====="

# --- ADMIN CHECK ---
If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  Write-Host "`n[ERROR] Please run PowerShell as Administrator!`n" -ForegroundColor Red
    Write-Host "To do this: Right-click PowerShell 7 icon and choose 'Run as administrator'." -ForegroundColor Yellow
    Write-Log "Script not running as administrator. Exiting."
    exit 1
}

# --- Ensure PowerShell 7+ ---
if ($PSVersionTable.PSVersion.Major -lt 7) {
  Write-Log "PowerShell 7+ required. Attempting install via winget."
    try {
      winget install --id Microsoft.Powershell --source winget --accept-package-agreements --accept-source-agreements
        Write-Host "`n[INFO] PowerShell 7 installed. Please relaunch 'PowerShell 7' as administrator and re-run this script.`n" -ForegroundColor Yellow
        Write-Log "Installed PowerShell 7, exiting for relaunch."
        exit 0
    } catch {
      Write-Host "`n[ERROR] PowerShell 7 could not be installed automatically. Please install manually from https://github.com/PowerShell/PowerShell/releases and re-run this script." -ForegroundColor Red
        Write-Log "PowerShell 7 auto-install failed."
        exit 1
    }
}

# --- Ensure Git is installed ---
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Write-Log "Git not found. Attempting to install via winget."
    try {
      winget install --id Git.Git -e --accept-package-agreements --accept-source-agreements
        Write-Log "Git installed via winget."
    } catch {
      Write-Host "`n[ERROR] Git could not be installed automatically. Please install Git and re-run this script." -ForegroundColor Red
        Write-Log "Git auto-install failed."
        exit 1
    }
}

# --- Ensure Scoop is installed ---
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
  Write-Log "Scoop not found. Installing."
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    irm get.scoop.sh | iex
    Write-Log "Scoop installed."
}

# --- Ensure Winget is available ---
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  Write-Host "[ERROR] Winget is not installed. Please update to Windows 11 latest or install from Microsoft Store." -ForegroundColor Red
    Write-Log "Winget missing. Exiting."
    exit 1
}

# --- Clone or update dotfiles repo ---
if (-not (Test-Path $DotfilesRoot)) {
  Write-Log "Dotfiles repo not found. Cloning."
    git clone $RepoUrl $DotfilesRoot
    Write-Log "Cloned dotfiles repo into $DotfilesRoot"
} else {
  Write-Log "Dotfiles repo exists. Pulling latest."
    git -C $DotfilesRoot pull
}

# --- Install Packages from locations.txt ---
if (Test-Path $LocationsFile) {
  $scoopPkgs = @()
    $wingetPkgs = @()
    Get-Content $LocationsFile | ForEach-Object {
      if ($_ -match "scoop:") {
        $scoopPkgs += ($_ -replace "scoop:\s*", "")
      } elseif ($_ -match "winget:") {
        $wingetPkgs += ($_ -replace "winget:\s*", "")
      }
    }
  foreach ($pkg in $scoopPkgs) {
    Write-Log "Scoop: installing/updating $pkg"
      scoop install $pkg 2>> $LogFile; scoop update $pkg 2>> $LogFile
  }
  foreach ($pkg in $wingetPkgs) {
    Write-Log "Winget: installing/updating $pkg"
      winget install --id $pkg --silent --accept-package-agreements --accept-source-agreements 2>> $LogFile
  }
} else {
  Write-Log "No locations.txt found at $LocationsFile"
}

# --- Symlink files/directories from links.prop ---
if (Test-Path $PropFile) {
  Get-Content $PropFile | ForEach-Object {
    if ($_ -match "^#|^\s*$") { return } # skip comments/blank lines
      $parts = $_ -split "="
        $srcRel = $parts[0].Trim()
        $dst = $parts[1].Trim() -replace '\$HOME', $HOME
        $srcFull = Join-Path $DotfilesDir $srcRel

        if (-not (Test-Path $srcFull)) {
          Write-Log "Source missing: $srcFull"
            return
        }

    $isDir = Test-Path $srcFull -PathType Container

# Backup existing
      if (Test-Path $dst) {
        $backup = "$dst.bak_$(Get-Date -Format 'yyyyMMddHHmmss')"
          Move-Item $dst $backup -Force
          Write-Log "Backed up $dst to $backup"
      }

# Ensure parent directory exists
    $dstDir = Split-Path $dst
      if (-not (Test-Path $dstDir)) { New-Item -ItemType Directory -Path $dstDir -Force | Out-Null }

# Remove old link or item at target
    if (Test-Path $dst) {
      Remove-Item $dst -Recurse -Force
    }

# Create symlink for file or dir
    if ($isDir) {
      Write-Log "Symlinking DIR $srcFull => $dst"
        New-Item -ItemType SymbolicLink -Path $dst -Target $srcFull -Force -TargetType Directory | Out-Null
    } else {
      Write-Log "Symlinking FILE $srcFull => $dst"
        New-Item -ItemType SymbolicLink -Path $dst -Target $srcFull -Force -TargetType File | Out-Null
    }
  }
} else {
  Write-Log "No links.prop file found at $PropFile"
}

# --- Ensure PowerShell Profile sources aliases and functions ---
$profilePath = "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
$toSource = @(
    "if (Test-Path `"$HOME\.powershell\aliases.ps1`") { . `"$HOME\.powershell\aliases.ps1`" }"
    "if (Test-Path `"$HOME\.powershell\functions.ps1`") { . `"$HOME\.powershell\functions.ps1`" }"
    )
if (Test-Path $profilePath) {
  $profileBackup = "$profilePath.bak_$(Get-Date -Format 'yyyyMMddHHmmss')"
    Copy-Item $profilePath $profileBackup -Force
    Write-Log "Backed up PowerShell profile to $profileBackup"
    $currentContent = Get-Content $profilePath
    foreach ($line in $toSource) {
      if (-not ($currentContent -contains $line)) {
        Add-Content $profilePath "`n$line"
          Write-Log "Added sourcing line to profile: $line"
      }
    }
} else {
  Write-Log "Creating new PowerShell profile."
    Set-Content $profilePath ($toSource -join "`n")
}

# --- Ensure $PATH has scoop shims (idempotent) ---
$scoopShims = "$HOME\scoop\shims"
if (-not ($env:PATH -split ';' | Where-Object { $_ -eq $scoopShims })) {
  [Environment]::SetEnvironmentVariable("PATH", "$env:PATH;$scoopShims", [EnvironmentVariableTarget]::User)
    Write-Log "Appended scoop shims to PATH."
}

Write-Log "===== Dotfiles bootstrap completed at $(Get-Date) ====="
Write-Host "`n🎉 Dotfiles bootstrap complete! Please restart your terminal." -ForegroundColor Green
Write-Host "All actions logged to $LogFile`n" -ForegroundColor Yellow
