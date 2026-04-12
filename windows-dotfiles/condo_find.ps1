# Find-Condo-Units.ps1

$patterns = '1042','335'
$patternString = $patterns -join '|'
$home = $HOME

Write-Host "Searching for condo unit numbers ($($patterns -join ', ')) in $home..."

# ----------------------------
# Search .csv and .txt files
# ----------------------------
Get-ChildItem -Path $home -Recurse -Include *.csv,*.txt -File -ErrorAction SilentlyContinue |
    ForEach-Object {
        Select-String -Path $_.FullName -Pattern $patternString -ErrorAction SilentlyContinue |
        ForEach-Object {
            Write-Host "Match found in $($_.Path): Line $($_.LineNumber): $($_.Line.Trim())"
        }
    }

# ----------------------------
# Search .xlsx files
# ----------------------------
if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    Write-Host "Installing ImportExcel module..."
    Install-Module -Name ImportExcel -Scope CurrentUser -Force -AllowClobber
}

Import-Module ImportExcel

Get-ChildItem -Path $home -Recurse -Include *.xlsx -File -ErrorAction SilentlyContinue |
    ForEach-Object {
        try {
            $data = Import-Excel $_.FullName
            $flat = $data | Out-String
            if ($flat -match $patternString) {
                Write-Host "Match found in $($_.FullName)"
            }
        } catch {
            Write-Warning "Could not read: $($_.FullName)"
        }
    }

# ----------------------------
# Search .docx files (requires Word installed)
# ----------------------------
$word = $null
try {
    $word = New-Object -ComObject Word.Application
    $word.Visible = $false

    Get-ChildItem -Path $home -Recurse -Include *.docx -File -ErrorAction SilentlyContinue |
        ForEach-Object {
            try {
                $doc = $word.Documents.Open($_.FullName, $false, $true)
                $text = $doc.Content.Text
                $doc.Close()
                if ($text -match $patternString) {
                    Write-Host "Match found in $($_.FullName)"
                }
            } catch {
                Write-Warning "Could not read: $($_.FullName)"
            }
        }
} finally {
    if ($word) { $word.Quit() }
}

Write-Host "`nDone."
