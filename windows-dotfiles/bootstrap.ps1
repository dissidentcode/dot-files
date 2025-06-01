<# 
COMPLETE WINDOWS DOTFILES BOOTSTRAP SCRIPT (ENHANCED)

<# run this script from withing the containing directory using: 

Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
./bootstrap.ps1
<or>
pwsh -NoProfile -ExecutionPolicy Bypass -File .\bootstrap.ps1

if pwsh 7 not installed; use github url given to 'curl' .msi and then install with these:
curl:
Invoke-WebRequest -Uri "https://github.com/PowerShell/PowerShell/releases/download/v7.4.2/PowerShell-7.4.2-win-x64.msi" -OutFile "$HOME\Desktop\PowerShell-7.4.2-win-x64.msi"
install: 
run install package on desktop

if pwsh 7 installs wait till done then close terminal and type pwsh in start menu and launch pwsh 7 as administrator

Stages:
  1. Run as regular user: Installs Scoop if needed (never as admin).
  2. Prompts to rerun as admin for symlink creation and config.
  3. Ensures Scoop main bucket is present and updated.
  4. Installs packages via Scoop/Winget with error handling.
  5. Logs all actions and prints a summary of any failed tools.

To run:
  pwsh -NoProfile -ExecutionPolicy Bypass -File .\bootstrap.ps1
#>

# --- CONFIG ---
$DotfilesRoot   = "$HOME\.dotfiles"
$DotfilesDir    = "$DotfilesRoot\windows-dotfiles"
$PropFile       = "$DotfilesDir\links.prop"
$LogFile        = "$HOME\.powershell\bootstrap.log"
$LocationsFile  = "$DotfilesDir\locations.txt"
$RepoUrl        = "https://github.com/dissidentcode/dot-files.git"

# Logging (force UTF8 to avoid mojibake)
$LogDir = [System.IO.Path]::GetDirectoryName($LogFile)
if (!(Test-Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir | Out-Null }
function Write-Log($Message) {
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $Message" | Out-File -Append -FilePath $LogFile -Encoding utf8
}

Write-Log "===== Starting dotfiles bootstrap at $(Get-Date) ====="

function Is-Admin {
    return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Ensure-Elevation {
    if (-not (Is-Admin)) {
        Write-Host "`n[INFO] Relaunching script as Administrator for privileged steps..." -ForegroundColor Yellow
        Start-Process -FilePath "pwsh" -ArgumentList "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$PSCommandPath`"" -Verb RunAs
        exit
    }
}

# 1. Ensure PowerShell 7+
if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "`n[ERROR] PowerShell 7+ is required. Please install it from https://github.com/PowerShell/PowerShell/releases and re-run this script." -ForegroundColor Red
    Write-Log "PowerShell 7 required but not present. Exiting."
    exit 1
}

# 2. Ensure Scoop (user-level, NOT as admin)
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    if (Is-Admin) {
        Write-Host "`n[ERROR] Scoop must be installed as a normal user, not Administrator!" -ForegroundColor Red
        Write-Host "Close this window and run: 'pwsh -NoProfile -ExecutionPolicy Bypass -File .\bootstrap.ps1' as your normal user."
        Write-Log "Attempted Scoop install as Admin. Aborted."
        exit 1
    }
    Write-Host "[INFO] Scoop not found. Installing as current user..." -ForegroundColor Yellow
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    irm get.scoop.sh | iex
    Write-Log "Scoop installed as user."
    Write-Host "[INFO] Scoop installed. Please close this terminal and relaunch PowerShell **as Administrator** to continue setup." -ForegroundColor Cyan
    exit 0
}

# --- STAGE 2: ELEVATE FOR ADMIN TASKS ---
Ensure-Elevation

# --- Ensure Scoop main bucket (always update) ---
try {
    scoop bucket add main -f | Out-Null
    scoop update
    Write-Log "Scoop main bucket added/updated."
} catch {
    Write-Log "Failed to add/update scoop main bucket: $_"
}

# --- Ensure Scoop extras bucket for vcredist2022 ---
try {
    scoop bucket add extras -f | Out-Null
    scoop update
    Write-Log "Scoop extras bucket added/updated."
} catch {
    Write-Log "Failed to add Scoop extras bucket: $_"
}

# Install VC++ redistributable (vcredist2022)
try {
    scoop install vcredist2022 2>> $LogFile
    Write-Log "Installed vcredist2022 via Scoop."
} catch {
    Write-Log "Failed to install vcredist2022: $_"
}

# --- Ensure Scoop nerd-fonts bucket if JetBrainsMono-NF is needed ---
$requiresNerdFonts = $false
if (Test-Path $LocationsFile) {
    $requiresNerdFonts = Get-Content $LocationsFile | Select-String -Pattern "JetBrainsMono-NF" -Quiet
}
if ($requiresNerdFonts) {
    try {
        scoop bucket add nerd-fonts -f | Out-Null
        scoop update
        Write-Log "Scoop nerd-fonts bucket added/updated."
    } catch {
        Write-Host "[ERROR] Could not add scoop nerd-fonts bucket!" -ForegroundColor Red
        Write-Log "Failed to add scoop nerd-fonts bucket: $_"
    }
}# --- Now continue with Git, WinGet, and your package install logic ---
# --- Ensure Git is installed (Scoop or Winget, prefer Scoop) ---
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Log "Git not found. Installing via Scoop."
    $gitError = $false
    try {
        scoop install git
        if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
            Write-Log "Scoop git install failed, trying winget."
            if (Get-Command winget -ErrorAction SilentlyContinue) {
                winget install --id Git.Git -e --accept-package-agreements --accept-source-agreements
            } else {
                Write-Host "`n[ERROR] Git could not be installed. Please install manually and re-run this script." -ForegroundColor Red
                Write-Log "Git auto-install failed."
                $gitError = $true
            }
        }
    } catch {
        Write-Host "`n[ERROR] Git install failed. Please install and re-run this script." -ForegroundColor Red
        Write-Log "Git install error: $_"
        $gitError = $true
    }
    if ($gitError) { exit 1 }
}

# --- Ensure Winget is available, but do NOT exit if missing ---
$hasWinget = Get-Command winget -ErrorAction SilentlyContinue
if (-not $hasWinget) {
    Write-Host "[WARNING] Winget is not installed. All possible packages will be installed with Scoop." -ForegroundColor Yellow
    Write-Log "Winget missing. Proceeding with Scoop only."
}

# --- Clone or update dotfiles repo ---
if (-not (Test-Path $DotfilesRoot)) {
    Write-Log "Cloning dotfiles repo."
    git clone $RepoUrl $DotfilesRoot
    Write-Log "Dotfiles repo cloned to $DotfilesRoot"
} else {
    Write-Log "Pulling latest dotfiles repo."
    git -C $DotfilesRoot pull
}

# --- Install Packages from locations.txt (always as user, never as admin) ---
$allPkgs = @{}
$failedPkgs = @()

if (Test-Path $LocationsFile) {
    $scoopPkgs = @()
    $wingetPkgs = @()
    Get-Content $LocationsFile | ForEach-Object {
        if ($_ -match "scoop:") {
            $pkg = ($_ -replace "scoop:\s*", "")
            $scoopPkgs += $pkg
            $allPkgs[$pkg] = "scoop"
        } elseif ($_ -match "winget:") {
            $pkg = ($_ -replace "winget:\s*", "")
            $wingetPkgs += $pkg
            if (-not $allPkgs.ContainsKey($pkg)) {
                $allPkgs[$pkg] = "winget"
            }
        }
    }
    # Always update buckets before install
    scoop update
    foreach ($pkg in $scoopPkgs) {
        try {
            Write-Host "[INFO] Installing (scoop): $pkg" -ForegroundColor Cyan
            scoop install $pkg 2>> $LogFile
            scoop update $pkg 2>> $LogFile
            if (-not (scoop list | Select-String -Pattern " $pkg " -SimpleMatch)) {
                Write-Log "FAILED: scoop $pkg"
                $failedPkgs += $pkg
            }
        } catch {
            Write-Log "FAILED (exception): scoop $pkg"
            $failedPkgs += $pkg
        }
    }
    foreach ($pkg in $wingetPkgs) {
        # Prefer scoop if present
        $pkgFound = (scoop search $pkg | Select-String -Pattern $pkg) -ne $null
        if ($pkgFound) {
            continue  # already handled above
        } elseif ($hasWinget) {
            try {
                Write-Host "[INFO] Installing (winget): $pkg" -ForegroundColor Cyan
                winget install --id $pkg --silent --accept-package-agreements --accept-source-agreements 2>> $LogFile
                # No clean way to check success, but log anyway
            } catch {
                Write-Log "FAILED (exception): winget $pkg"
                $failedPkgs += $pkg
            }
        } else {
            Write-Log "FAILED: $pkg not found in scoop and winget unavailable."
            $failedPkgs += $pkg
        }
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
        if (Test-Path $dst) { Remove-Item $dst -Recurse -Force }
        # Create symlink for file or dir
        if ($isDir) {
            Write-Log "Symlinking DIR $srcFull => $dst"
            New-Item -ItemType SymbolicLink -Path $dst -Target $srcFull -Force | Out-Null
        } else {
            Write-Log "Symlinking FILE $srcFull => $dst"
            New-Item -ItemType SymbolicLink -Path $dst -Target $srcFull -Force | Out-Null
        }
    }
} else {
    Write-Log "No links.prop file found at $PropFile"
}

# --- Ensure $PATH has scoop shims (idempotent) ---
$scoopShims = "$HOME\scoop\shims"
if (-not ($env:PATH -split ';' | Where-Object { $_ -eq $scoopShims })) {
    [Environment]::SetEnvironmentVariable("PATH", "$env:PATH;$scoopShims", [EnvironmentVariableTarget]::User)
    Write-Log "Appended scoop shims to PATH."
}

# --- Print summary of any failed package installs ---
if ($failedPkgs.Count -gt 0) {
    Write-Host "`n[WARNING] The following packages could not be installed automatically:" -ForegroundColor Yellow
    $failedPkgs | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    Write-Log "FAILED PACKAGE SUMMARY: $($failedPkgs -join ', ')"
} else {
    Write-Host "`n[INFO] All packages installed successfully (or already present)." -ForegroundColor Green
}

Write-Log "===== Dotfiles bootstrap completed at $(Get-Date) ====="
Write-Host "`n🎉 Dotfiles bootstrap complete! Please restart your terminal." -ForegroundColor Green
Write-Host "All actions logged to $LogFile`n" -ForegroundColor Yellow
