<#
================================================================================
  Dotfiles Windows Bootstrap Script - Quick Start Instructions
================================================================================

1. Copy this script (`setup.ps1`) to a flash drive.

2. On the target Windows 11 machine:
    a. Plug in the flash drive.
    b. Open Windows PowerShell (NOT as Administrator):
         - Press Win + S, type "powershell", press Enter.

    c. Switch to your flash drive (replace E: if needed):
         E:
         cd \

    d. Allow script execution and run the script:
         Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
         .\setup.ps1

3. Follow all prompts on screen:
    - The script will install Git, clone your dotfiles, install PowerShell 7,
      handle shell transitions, enable Developer Mode (admin required),
      set up Scoop and your CLI tools, and symlink all configs.

    - If you are told to reboot, log out, or re-launch in PowerShell 7,
      do exactly as directed and then run the script again.

    - All actions are logged to $env:USERPROFILE\dotfiles-setup.log.

================================================================================
#>

.SYNOPSIS
    Bootstrap your dotfiles and dev environment on a fresh Windows 11 machine.
.DESCRIPTION
    - Installs Git if missing
    - Clones your dotfiles repo if missing
    - Installs PowerShell 7 if missing, prompts user to re-launch script in pwsh 7
    - Enables Developer Mode for symlink support (admin required)
    - Installs Scoop as user, then installs packages from scoop-apps.txt
    - Symlinks config files per locations.txt (idempotent, with backups)
    - Prompts user exactly when to switch shell, log out, etc
.NOTES
    Run this as a normal (non-admin) user in Windows PowerShell 5
#>

# ------------- CONSTANTS --------------
$DotfilesRepoUrl = "https://github.com/dissidentcode/dot-files"
$DotfilesDir = "$env:USERPROFILE\dot-files"
$WindowsDotfilesDir = "$DotfilesDir\windows-dotfiles"
$ScoopAppsFile = "$WindowsDotfilesDir\scoop-apps.txt"
$LocationsFile = "$WindowsDotfilesDir\locations.txt"
$LogFile = "$env:USERPROFILE\dotfiles-setup.log"
$PS7Exe = "$env:ProgramFiles\PowerShell\7\pwsh.exe"
$ScriptSelf = "$WindowsDotfilesDir\setup.ps1"

# ------------- HELPERS ---------------
function Write-Log ($msg) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts $msg" | Tee-Object -FilePath $LogFile -Append
}
function Write-Highlight ($msg) {
    Write-Host "`n*** $msg ***`n" -ForegroundColor Yellow
    Write-Log $msg
}
function Prompt-Continue ($msg) {
    Write-Highlight $msg
    Read-Host "Press [Enter] to continue..."
}

# ------------- STEP 1: Git -------------
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Highlight "Git not found. Installing with winget..."
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "winget not found! Please install Git manually and rerun this script." -ForegroundColor Red
        exit 1
    }
    winget install --id Git.Git -e --source winget
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "Git install failed. Please install manually, then rerun this script." -ForegroundColor Red
        exit 1
    }
}

# ------------- STEP 2: Clone Repo -------------
if (-not (Test-Path $DotfilesDir)) {
    Write-Highlight "Cloning dotfiles repo to $DotfilesDir"
    git clone $DotfilesRepoUrl $DotfilesDir
    if (-not (Test-Path $DotfilesDir)) {
        Write-Host "Failed to clone repo! Check your internet and rerun script." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Log "dot-files repo already present at $DotfilesDir. Skipping clone."
}

# ------------- STEP 3: PowerShell 7 -------------
if (-not (Test-Path $PS7Exe)) {
    Write-Highlight "Installing PowerShell 7 with winget..."
    winget install --id Microsoft.Powershell --source winget
    if (-not (Test-Path $PS7Exe)) {
        Write-Host "PowerShell 7 install failed. Please install manually, then rerun this script." -ForegroundColor Red
        exit 1
    }
}

# ------------- STEP 3b: Relaunch in PowerShell 7 -------------
if (-not ($PSVersionTable.PSEdition -eq "Core")) {
    Write-Highlight "Now launching setup in PowerShell 7..."
    # Use pwsh 7 to rerun this script, pass state var to skip previous steps
    & "$PS7Exe" "-NoProfile" "-ExecutionPolicy" "Bypass" "-File" "$ScriptSelf" "from-pwsh7"
    exit 0
}

# ------------- Only reached in pwsh7 -----------------
param([string]$Pwsh7 = "")

Write-Log "Running in PowerShell 7."

# ------------- STEP 4: Enable Developer Mode -------------
function Is-DevMode {
    $k = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -ErrorAction SilentlyContinue
    return $k.AllowDevelopmentWithoutDevLicense -eq 1
}
if (-not (Is-DevMode)) {
    Write-Highlight "Developer Mode is not enabled. This is required to make symlinks without admin."
    Write-Highlight "You'll be prompted for admin rights. After enabling, you must log out (or reboot), then rerun this script."
    Start-Process powershell "-NoProfile -Command `"Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' -Name 'AllowDevelopmentWithoutDevLicense' -Value 1`"" -Verb RunAs
    Write-Host "`nDeveloper Mode set. Please log out and log back in (or reboot) before continuing. Then rerun this script from PowerShell 7 (`pwsh`)." -ForegroundColor Yellow
    exit 0
}

# ------------- STEP 5: Scoop install -------------
if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
    Write-Highlight "Installing Scoop as current user (must NOT be admin)..."
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    irm get.scoop.sh | iex
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "Scoop failed to install. Please check https://scoop.sh/ and rerun script." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Log "Scoop already installed."
}

# ------------- STEP 6: Scoop Apps -------------
if (Test-Path $ScoopAppsFile) {
    Write-Highlight "Installing Scoop packages from $ScoopAppsFile..."
    Get-Content $ScoopAppsFile | ForEach-Object {
        $app = $_.Trim()
        if ($app -and -not ($app.StartsWith("#"))) {
            if (-not (scoop list | Select-String -Pattern ("^" + [regex]::Escape($app) + "\b"))) {
                Write-Log "Installing $app via scoop..."
                scoop install $app
            } else {
                Write-Log "$app already installed via scoop."
            }
        }
    }
} else {
    Write-Host "Scoop apps list file not found at $ScoopAppsFile, skipping." -ForegroundColor Yellow
}

# ------------- STEP 7: Symlink Dotfiles -------------
function New-SafeSymlink {
    param([string]$Target, [string]$Source)
    if (-not (Test-Path $Source)) {
        Write-Host "Source $Source does not exist, skipping." -ForegroundColor Red
        return
    }
    if (Test-Path $Target) {
        if ((Get-Item $Target).LinkType -eq "SymbolicLink" -and (Get-Item $Target).Target -eq $Source) {
            Write-Log "Symlink $Target -> $Source already exists, skipping."
            return
        } else {
            # Backup old file/dir
            $backup = "$Target.backup.$((Get-Date).ToString('yyyyMMddHHmmss'))"
            Write-Log "Backing up existing $Target to $backup"
            Move-Item $Target $backup
        }
    }
    # Make parent dir if needed
    $parent = Split-Path $Target
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    # Create symlink
    New-Item -ItemType SymbolicLink -Path $Target -Target $Source | Out-Null
    Write-Log "Created symlink: $Target -> $Source"
}
if (Test-Path $LocationsFile) {
    Write-Highlight "Creating symlinks per $LocationsFile..."
    Get-Content $LocationsFile | ForEach-Object {
        $line = $_.Trim()
        if ($line -and -not ($line.StartsWith("#"))) {
            $parts = $line -split '\s+', 2
            if ($parts.Length -eq 2) {
                $Target = $parts[0] -replace '%USERPROFILE%', $env:USERPROFILE
                $Source = $parts[1] -replace '%DOTFILES%', $WindowsDotfilesDir
                New-SafeSymlink -Target $Target -Source $Source
            }
        }
    }
} else {
    Write-Host "locations.txt file not found at $LocationsFile, skipping symlinks." -ForegroundColor Yellow
}

# ------------- STEP 8: Done! -------------
Write-Highlight "Bootstrapping is complete!"

Write-Host @"
What's next?

- If prompted above, set PowerShell 7 (`pwsh`) as your default shell in Windows Terminal.
- Review any .backup.* files if your old configs were preserved.
- To rerun this setup later, just launch PowerShell 7 and re-run this script.

Full log: $LogFile
"@ -ForegroundColor Cyan

exit 0
