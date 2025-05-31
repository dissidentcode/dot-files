# Edit your PowerShell alias and function files in Neovim
Function nvalias { & "C:\Program Files\Neovim\bin\nvim.exe" "$HOME\.powershell\aliases.ps1" }
Function nvfunctions { & "C:\Program Files\Neovim\bin\nvim.exe" "$HOME\.powershell\functions.ps1" }
Function nvprofile { & "C:\Program Files\Neovim\bin\nvim.exe" "$PROFILE" }
Function mkcd { param($dir) mkdir $dir -Force; Set-Location $dir }
Function winfetch { & "$HOME\Documents\PowerShell\Scripts\winfetch.ps1" }
Function admin { Start-Process "wt.exe" -Verb RunAs -ArgumentList "new-tab -p 'PowerShell'" }

# Quick directory navigation
Function .. { Set-Location .. }
Function ... { Set-Location ../.. }
Function .... { Set-Location ../../.. }
Function ..... { Set-Location ../../../.. }
Function ...... { Set-Location ../../../../.. }
Function ~ { Set-Location $HOME }
Function root { Set-Location C:\ }

# Git (aliases like gc, gp, etc. are reserved; use functions instead)
Function ga { git add @args }
Function gs { git status @args }
Function gc { git commit -m @args }
Function gp { git push origin @args }
Function gd { git diff @args }

# Remove, Make, and Move
Function rm { Remove-Item @args -Verbose -Confirm }
Function rmd { param($dir) Remove-Item $dir -Recurse -Verbose }
Function rms { Remove-Item @args -Verbose -Confirm }
Function mkd { mkdir @args }
Function l { eza -lAhF --icons=always --git --color=always --show-symlinks --time-style=long-iso @args }
Function ll  { lsd -1AhF --header --size=short --total-size --color=always --group-dirs=first --git @args }
Function lld { eza -1ahmlxUD --show-symlinks --total-size --icons=always --git  --color=always @args }
Function llf { eza -1ahmlxUf --show-symlinks  --total-size --icons=always --color=always --git @args }
Function l2  { eza --tree --level 2 --all --icons @args }
Function l3  { eza --tree --level 3 --all --icons @args }
Function l4  { eza --tree --level 4 --all --icons @args }

# Disk usage
Function dusage {
    Get-ChildItem -Directory | ForEach-Object {
        $size = (Get-ChildItem $_.FullName -Recurse | Measure-Object -Property Length -Sum).Sum
        [PSCustomObject]@{Directory=$_.FullName;Size=([math]::Round($size/1MB,2))}
    } | Sort-Object Size -Descending | Format-Table -AutoSize
}
Function dustf { dust -CFt @args }
Function dustd { dust -CD @args }
Function dust { dust.exe --depth 1 @args }

# Quick jump directories (functions, as Set-Alias can't take a command with args)
Function psconf { Set-Location "$HOME\.powershell" }

# Open apps/web shortcuts (functions for URL or args)
Function brave   { Start-Job { Start-Process "$env:ProgramFiles\BraveSoftware\Brave-Browser\Application\brave.exe" } }
Function logseq { Start-Job { Start-Process "$env:LOCALAPPDATA\Logseq\Logseq.exe" } }
Function discord { Start-Job { Start-Process -FilePath "$env:LOCALAPPDATA\Discord\Update.exe" -ArgumentList "--processStart", "Discord.exe" } }
Function signal  { Start-Job { Start-Process "$env:LOCALAPPDATA\Programs\signal-desktop\Signal.exe" } }
Function gmail   { Start-Job { Start-Process "$env:ProgramFiles\BraveSoftware\Brave-Browser\Application\brave.exe" "https://www.gmail.com" } }
Function keep    { Start-Job { Start-Process "$env:ProgramFiles\BraveSoftware\Brave-Browser\Application\brave.exe" "https://keep.google.com" } }
Function gpt     { Start-Job { Start-Process "$env:ProgramFiles\BraveSoftware\Brave-Browser\Application\brave.exe" "https://chat.openai.com" } }
Function mt      { Start-Job { Start-Process "$env:ProgramFiles\BraveSoftware\Brave-Browser\Application\brave.exe" "https://monkeytype.com" } }

# Clipboard
Function pb {
    param(
        [Parameter(ValueFromPipeline=$true, ValueFromRemainingArguments=$true)]
        $InputObject
    )
    process {
        foreach ($item in $InputObject) {
            if (Test-Path $item) {
                Get-Content $item -Raw | Set-Clipboard
            } else {
                $item | Set-Clipboard
            }
        }
    }
}
Function pbpaste { win32yank.exe -o }
# Or use 'clip.exe' and 'Get-Clipboard' if you prefer

# Enhanced clear + system info Function sysc { Clear-Host; neofetch } # Grep & search
Function grepa {
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$Pattern
    )
    Get-Alias | Where-Object {
        $_.Name -like "*$Pattern*" -or
        $_.Definition -like "*$Pattern*"
    } | Format-Table Name, Definition -AutoSize
}

# END

