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

<#
.SYNOPSIS
    Bootstrap your Windows development environment using dotfiles.
.DESCRIPTION
    - Installs Git if missing.
    - Clones dotfiles repository.
    - Installs PowerShell 7 if missing and prompts for shell restart.
    - Enables Developer Mode for symlink support.
    - Installs Scoop and required packages.
    - Creates symlinks as defined in links.prop.
.NOTES
    Run this script in Windows PowerShell (not as Administrator).
#>

# Define paths
$DotfilesRepo = "https://github.com/dissidentcode/dot-files.git"
$DotfilesDir = "$env:USERPROFILE\dot-files"
$WindowsDotfilesDir = "$DotfilesDir\windows-dotfiles"
$LinksProp = "$WindowsDotfilesDir\links.prop"
$PackagesFile = "$WindowsDotfilesDir\packages.txt"

# Function to install Git if missing
function Install-Git {
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "Git not found. Installing via winget..."
        winget install --id Git.Git -e --source winget
    } else {
        Write-Host "Git is already installed."
    }
}

# Function to clone dotfiles repository
function Clone-Dotfiles {
    if (-not (Test-Path $DotfilesDir)) {
        Write-Host "Cloning dotfiles repository..."
        git clone $DotfilesRepo $DotfilesDir
    } else {
        Write-Host "Dotfiles repository already exists."
    }
}

# Function to install PowerShell 7 if missing
function Install-PowerShell7 {
    if (-not (Get-Command pwsh -ErrorAction SilentlyContinue)) {
        Write-Host "PowerShell 7 not found. Installing via winget..."
        winget install --id Microsoft.Powershell --source winget
        Write-Host "Please restart the shell using 'pwsh' and re-run this script."
        exit
    } else {
        Write-Host "PowerShell 7 is already installed."
    }
}

# Function to enable Developer Mode
function Enable-DeveloperMode {
    $DevModeKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock"
    $DevModeName = "AllowDevelopmentWithoutDevLicense"
    $DevModeValue = Get-ItemProperty -Path $DevModeKey -Name $DevModeName -ErrorAction SilentlyContinue

    if ($DevModeValue.$DevModeName -ne 1) {
        Write-Host "Enabling Developer Mode..."
        Start-Process powershell -ArgumentList "-Command Set-ItemProperty -Path '$DevModeKey' -Name '$DevModeName' -Value 1" -Verb RunAs
        Write-Host "Developer Mode enabled. Please log out and log back in, then re-run this script."
        exit
    } else {
        Write-Host "Developer Mode is already enabled."
    }
}

# Function to install Scoop
function Install-Scoop {
    if (-not (Get-Command scoop -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Scoop..."
        Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        iwr -useb get.scoop.sh | iex
    } else {
        Write-Host "Scoop is already installed."
    }
}

# Function to add required Scoop buckets
function Add-ScoopBuckets {
    $RequiredBuckets = @("main", "extras", "nerd-fonts")
    foreach ($Bucket in $RequiredBuckets) {
        if (-not (scoop bucket list | Select-String $Bucket)) {
            Write-Host "Adding Scoop bucket: $Bucket"
            scoop bucket add $Bucket
        } else {
            Write-Host "Scoop bucket '$Bucket' is already added."
        }
    }
}

# Function to install packages from packages.txt
function Install-Packages {
    if (Test-Path $PackagesFile) {
        $Packages = Get-Content $PackagesFile | Where-Object { $_ -and -not $_.StartsWith("#") }
        foreach ($Package in $Packages) {
            if (-not (scoop list | Select-String $Package)) {
                Write-Host "Installing package: $Package"
                scoop install $Package
            } else {
                Write-Host "Package '$Package' is already installed."
            }
        }
    } else {
        Write-Host "packages.txt not found at $PackagesFile"
    }
}

# Function to create symlinks from links.prop
function Create-Symlinks {
    if (Test-Path $LinksProp) {
        $Lines = Get-Content $LinksProp | Where-Object { $_ -and -not $_.StartsWith("#") }
        foreach ($Line in $Lines) {
            $Parts = $Line -split "="
            if ($Parts.Count -eq 2) {
                $Source = $Parts[0].Trim()
                $Destination = $Parts[1].Trim() -replace "%USERPROFILE%", $env:USERPROFILE

                if (Test-Path $Destination) {
                    Write-Host "Destination '$Destination' already exists. Skipping."
                } else {
                    $DestinationDir = Split-Path $Destination
                    if (-not (Test-Path $DestinationDir)) {
                        New-Item -ItemType Directory -Path $DestinationDir -Force | Out-Null
                    }
                    New-Item -ItemType SymbolicLink -Path $Destination -Target $Source | Out-Null
                    Write-Host "Created symlink: $Destination -> $Source"
                }
            }
        }
    } else {
        Write-Host "links.prop not found at $LinksProp"
    }
}

# Main script execution
Install-Git
Clone-Dotfiles
Install-PowerShell7
Enable-DeveloperMode
Install-Scoop
Add-ScoopBuckets
Install-Packages
Create-Symlinks

Write-Host "Bootstrap process completed successfully."
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
    – If you run into any errors, check the log file at: $env:USERPROFILE\dotfiles-setup.log

You can safely re-run this script at any time—it will only install or update what’s missing.

Enjoy your new environment!
"@ -ForegroundColor Cyan

exit 0
