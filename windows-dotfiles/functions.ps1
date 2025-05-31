# functions.ps1
Function acp {
    param([string]$Message)
    if (-not $Message) {
        Write-Host "Please provide a commit message."; return
    }
    if (-not (git status --porcelain)) {
        Write-Host "No changes to commit."; return
    }
    git add -A
    git commit -m "$Message"
    $branch = git symbolic-ref --short HEAD
    git push origin $branch
}

Function symlink {
    param($Link, $Target)
    if (Test-Path $Link) {
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        Rename-Item $Link "$Link.backup.$timestamp"
    }
    New-Item -ItemType SymbolicLink -Path $Link -Target $Target
}

Function ddg($query) {
    Start-Process "https://duckduckgo.com/?q=$query"
}

Function youtube($query) {
    Start-Process "https://www.youtube.com/results?search_query=$query"
}
