<#
================================================================================
  Dotfiles Windows Bootstrap Script - Quick Start Instructions
================================================================================

1. Copy this script (`bootstrap.ps1`) to a flash drive.

2. On the target Windows 11 machine:
    a. Plug in the flash drive.
    b. Open Windows PowerShell (NOT as Administrator):
         - Press Win + S, type "powershell", press Enter.

    c. Switch to your flash drive (replace E: if needed):
         E:
         cd \

    d. Allow script execution and run the script:
         Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
         .\bootstrap.ps1

3. Follow all prompts on screen.

    - If you are told to reboot, log out, or re-launch in PowerShell 7,
      do exactly as directed and then run the script again.

    - All actions are logged to $env:USERPROFILE\dotfiles-setup.log.

================================================================================
#>

# ---- Set constants and paths ----
$DotfilesRepo = "https://github.com/dissidentcode/dot-files.git"
$DotfilesDir = "$env:USERPROFILE\.dotfiles"
$WindowsDotfilesDir = "$DotfilesDir\windows-dotfiles"
$LinksProp = "$WindowsDotfilesDir\links.prop"
$PackagesFile = "$WindowsDotfilesDir\packages.txt"
$LogFile = "$env:USERPROFILE\dotfiles-setup.log"

$PS7Exe = "$env:ProgramFiles\PowerShell\7\pwsh.exe"
$ScriptSelf = $MyInvocation.MyCommand.Path

function Write-Log ($msg) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts $msg" | Tee-Object -FilePath $LogFile -Append
}
function Write-Highlight ($msg) {
    Write-Host "`n*** $msg ***`n" -ForegroundColor Yellow
    Write-Log $msg
}

# --- Ensure Git is present ---
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Highlight "Git not found. Installing via winget..."
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "winget not found! Please install Git manually and rerun this script." -ForegroundColor Red
        exit 1
    }
    winget install --id Git.Git -e --source winget

    # Check again for Git, now that it may be installed
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        # Only try relaunching once to avoid infinite loops
        if (-not $env:DOTFILES_BOOTSTRAP_RELAUNCHED) {
            Write-Highlight "Relaunching PowerShell so Git is recognized..."
            # Set a flag so we only relaunch once
            $env:DOTFILES_BOOTSTRAP_RELAUNCHED = "1"
            # Re-run the script in a new process
            Start-Process -FilePath "powershell.exe" -ArgumentList "-NoExit", "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "`"$ScriptSelf`""
exit 0
        } else {
            Write-Host @"
Git was installed, but this PowerShell session still does not see it.
Please close this window, open a NEW PowerShell window, and rerun this script.
"@ -ForegroundColor Yellow
            exit 1
        }
    }
}
# --- Clone dotfiles repo if needed ---
if (-not (Test-Path $DotfilesDir)) {
    Write-Highlight "Cloning dotfiles repo to $DotfilesDir"
    git clone $DotfilesRepo $DotfilesDir
    if (-not (Test-Path $DotfilesDir)) {
        Write-Host "Failed to clone repo! Check your internet and rerun script." -ForegroundColor Red
        exit 1
    }
    attrib +h $DotfilesDir  # Set hidden attribute
} else {
    # Repo exists; check that it's a valid git repo
    if (-not (Test-Path (Join-Path $DotfilesDir ".git"))) {
        Write-Host "The folder $DotfilesDir exists but is not a git repo! Please move or delete it and rerun this script." -ForegroundColor Red
        exit 1
    }
    # Optionally refresh hidden attribute
    attrib +h $DotfilesDir
    Write-Log ".dotfiles repo already present at $DotfilesDir. Skipping clone."
}

# --- Now check for required files (AFTER clone) ---
if (-not (Test-Path $LinksProp)) {
    Write-Host "Missing links.prop at $LinksProp! Please ensure your dotfiles repo is up to date." -ForegroundColor Red
    exit 1
}
if (-not (Test-Path $PackagesFile)) {
    Write-Host "Missing packages.txt at $PackagesFile! Please ensure your dotfiles repo is up to date." -ForegroundColor Red
    exit 1
}
# --- PowerShell 7 check & switch ---
if (-not (Test-Path $PS7Exe)) {
    Write-Highlight "PowerShell 7 not found. Installing via winget..."
    winget install --id Microsoft.Powershell --source winget
    if (-not (Test-Path $PS7Exe)) {
        Write-Host "PowerShell 7 install failed. Please install manually, then rerun this script." -ForegroundColor Red
        exit 1
    }
}
if (-not ($PSVersionTable.PSEdition -eq "Core")) {
    Write-Highlight "Now launching setup in PowerShell 7..."
    & "$PS7Exe" "-NoProfile" "-ExecutionPolicy" "Bypass" "-File" "$ScriptSelf"
    exit 0
}

Write-Log "Running in PowerShell 7."

# --- Developer Mode ---
function Is-DevMode {
    $k = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock" -Name "AllowDevelopmentWithoutDevLicense" -ErrorAction SilentlyContinue
    return $k.AllowDevelopmentWithoutDevLicense -eq 1
}
if (-not (Is-DevMode)) {
    Write-Highlight "Developer Mode is not enabled. This is required to make symlinks without admin."
    Write-Highlight "You'll be prompted for admin rights. After enabling, you must log out (or reboot), then rerun this script."
    Start-Process powershell "-NoProfile -Command `"Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' -Name 'AllowDevelopmentWithoutDevLicense' -Value 1`"" -Verb RunAs

Write-Host @"
================================================================================
 Developer Mode has been enabled!
================================================================================

IMPORTANT:

• Please log out of your Windows account or reboot your computer now.
• AFTER logging back in, launch PowerShell 7 (pwsh)—not Windows PowerShell 5.
    - To do this: Press Win + S, type 'pwsh', and press Enter.
• Then, re-run this bootstrap script.

Why? All further steps require PowerShell 7.

"@ -ForegroundColor Yellow
exit 0

}

# --- Scoop ---
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

# --- Buckets ---
function Ensure-ScoopBuckets {
    $requiredBuckets = @('main', 'extras', 'nerd-fonts')
    foreach ($bucket in $requiredBuckets) {
        if (-not (scoop bucket list | Select-String -Pattern ("^" + [regex]::Escape($bucket) + "\b"))) {
            Write-Host "Adding Scoop bucket: $bucket"
            scoop bucket add $bucket
        } else {
            Write-Log "Scoop bucket '$bucket' is already added."
        }
    }
}
Ensure-ScoopBuckets

# --- Packages ---
function Install-ScoopPackages {
    param([string]$PackagesFile)
    $Packages = Get-Content $PackagesFile | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith("#") }
    foreach ($Package in $Packages) {
        try {
            if (-not (scoop list | Select-String -Pattern ("^" + [regex]::Escape($Package) + "\b"))) {
                Write-Host "Installing package: $Package"
                scoop install $Package
            } else {
                Write-Log "$Package already installed via scoop."
            }
        } catch {
            Write-Host "Failed to install '$Package'. Please check the spelling or the bucket." -ForegroundColor Red
            Write-Log "ERROR: Failed to install $Package"
        }
    }
}
Install-ScoopPackages $PackagesFile

# --- Symlinks ---
function New-SafeSymlink {
    param([string]$Source, [string]$Target)
    # Expand both %USERPROFILE% and $HOME
    $Source = $Source -replace "%USERPROFILE%", $env:USERPROFILE
    $Source = $Source.Replace('$HOME', $env:USERPROFILE)
    $Target = $Target -replace "%USERPROFILE%", $env:USERPROFILE
    $Target = $Target.Replace('$HOME', $env:USERPROFILE)

    # If $Source is not an absolute path, treat it as relative to $WindowsDotfilesDir
    if (!(Split-Path $Source -IsAbsolute)) {
    # Remove leading "windows-dotfiles/" from the path if present
    $RelSource = $Source -replace "^(windows-dotfiles[/\\])", ""
    $Source = Join-Path $WindowsDotfilesDir $RelSource
}

    if (-not (Test-Path $Source)) {
        Write-Host "Source $Source does not exist, skipping." -ForegroundColor Red
        Write-Log "MISSING: $Source for $Target"
        return
    }
    if (Test-Path $Target) {
        try {
            $existing = Get-Item $Target -ErrorAction SilentlyContinue
            if ($existing -and $existing.LinkType -eq "SymbolicLink" -and $existing.Target -eq $Source) {
                Write-Log "Symlink $Target -> $Source already exists, skipping."
                return
            } else {
                # Backup old file/dir
                $backup = "$Target.backup.$((Get-Date).ToString('yyyyMMddHHmmss'))"
                Write-Log "Backing up existing $Target to $backup"
                Move-Item $Target $backup
            }
        } catch {
            Write-Host "Unable to back up $Target. Skipping link." -ForegroundColor Red
            Write-Log "Unable to back up $Target"
            return
        }
    }
    $parent = Split-Path $Target
    if (-not (Test-Path $parent)) { New-Item -ItemType Directory -Path $parent -Force | Out-Null }
    New-Item -ItemType SymbolicLink -Path $Target -Target $Source | Out-Null
    Write-Log "Created symlink: $Target -> $Source"
    Write-Host "Created symlink: $Target -> $Source"
}

function Create-SymlinksFromProp {
    param([string]$LinksProp)
    $Lines = Get-Content $LinksProp | Where-Object { $_ -and -not $_.StartsWith("#") }
    foreach ($Line in $Lines) {
        $Parts = $Line -split "=", 2
        if ($Parts.Length -eq 2) {
            $Source = $Parts[0].Trim()
            $Target = $Parts[1].Trim()
            New-SafeSymlink -Source $Source -Target $Target
        }
    }
}
Create-SymlinksFromProp $LinksProp

# Path to Windows Terminal settings
$wtSettings = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"

if (Test-Path $wtSettings) {
    $settings = Get-Content $wtSettings -Raw | ConvertFrom-Json

    $changed = $false

    foreach ($profile in $settings.profiles.list) {
        # Try to match PowerShell 7 (pwsh)
        if ($profile.name -match "PowerShell" -or $profile.commandline -match "pwsh") {
            if ($profile.font -eq $null) { $profile | Add-Member -MemberType NoteProperty -Name font -Value @{} }
            $profile.font.face = "JetBrainsMono Nerd Font"
            $changed = $true
        }
    }

    if ($changed) {
        $settings | ConvertTo-Json -Depth 100 | Set-Content -Path $wtSettings
        Write-Host "Set font to 'JetBrainsMono Nerd Font' for PowerShell profiles in Windows Terminal."
        Write-Host "Please close and reopen all Windows Terminal windows for the font change to take effect."
    } else {
        Write-Host "Could not find a PowerShell profile in Windows Terminal settings."
    }
} else {
    Write-Host "Windows Terminal settings.json not found. Skipping font configuration."
}


# --- All done ---
Write-Host @"
================================================================================
 BOOTSTRAP COMPLETE!
================================================================================

What’s next?

• If you were prompted above to log out, reboot, or restart PowerShell, do so now, then re-run this script.
• If you just finished, you can:
    – Set PowerShell 7 (pwsh) as your default shell in Windows Terminal, if desired.
    – Check that all your favorite tools and configurations are working as expected.
    – Review any '.backup.*' files created in your config folders (these are backups of previous versions).
    – If you run into any errors, check the log file at: $LogFile

You can safely re-run this script at any time—it will only install or update what’s missing.

Enjoy your new environment!
"@ -ForegroundColor Cyan
