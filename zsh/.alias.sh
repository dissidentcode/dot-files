## ALIASES ##
alias nvalias='nvim ~/.zsh/.alias.sh'
alias nvfunctions='nvim ~/.zsh/.functions.sh'
alias nvzshrc='nvim ~/.zshrc'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias home='~'
alias root='/'
alias ave='ansible-vault encrypt'
alias avd='ansible-vault decrypt'
alias _='sudo '
alias ga='git add'
alias gs='git status'
alias gc='git commit -m'
alias gp='git push origin'
alias gd='git diff'
alias rm='rm -v -I'
alias c="clear && neofetch"
alias r='clear && source ~/.zshrc'
alias grepa='alias | grep $1'
alias grep='grep --color=auto'
alias egrep='grep -E --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox}'
alias fgrep='grep -F --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox}'
alias mkcd='foo(){ mkdir -p "$1"; cd "$1" }; foo '
alias md='mkdir'
alias rmd='rmdir -v'
alias del='trash'
alias rms='rm -i -v'
alias la='ls -A1'
alias ls='ls -G'
alias l='ls -lAFh'
#lsd alias with all the fixin's
alias ll='lsd -AhFl --header --group-directories-first --git'
#eza directories only alias with all the fixin's
alias lld='eza -lhmUDa --icons --git --no-user --color-scale-mode=gradient --no-quotes --color-scale=all --no-filesize'
#exa files only alias with all the fixin's
alias llf='eza -lXhmUfa --icons --git --no-user --color-scale-mode=gradient --no-quotes --color-scale=all --no-filesize'
alias l2='eza --tree --level 2 --all --icons'
alias l3='eza --tree --level 3 --all --icons'
alias l4='eza --tree --level 4 --all --icons'
#open aichat history in vscode
alias chathistory='code $HOME/Library/Application\ Support/aichat/messages.md'
#check network speed/quality
alias speedtest='speedtest-cli'
#copy to clipboard (paste board)
alias pb='pbcopy'
#Logseq graph database for git version control
alias notes="cd '$HOME/Personal/Logseq-PKB'"
#Git repos directory shortcut
alias repos="cd ~/git_repos"
#dot-files directory
alias dots="cd ~/git_repos/dot-files"
#zsh scripts directory
alias zshscripts="cd ~/git_repos/dot-files/zsh/.zsh-scripts"
#scripts directory
alias scripts="cd ~/scripts"
#.zsh directory
alias zsh="cd ~/.zsh"
#Trash uses Finder trash instead of sysrem API to esure 'allow putback'
alias trash='trash -F'
#Flush DNS cache - password needed
alias dnsflush='sudo killall -HUP mDNSResponder && sudo killall mDNSResponderHelper && sudo dscacheutil -flushcache'
#simplified 'du' with nice formatting
alias dusage="du -hd 1 | sort -hr | awk 'BEGIN { print \"SIZE     DIRECTORY\"; print \"------------------\" } { print \$1, \$2 }'"
#enhanced disk usage tool written in Rust; more intuitive than 'du' and avoids the UI aspect of 'ncdu'
alias dust='dust --reverse --no-percent-bars -i'
#same as above, but for only files
alias dustf='dust -F -d=1'
#same as above, but for only directories
alias dustd='dust -D -d=1'
#full 'ps aux' output sorted by memory (less cmd args, pid, and vsz) with dashed line row separators
alias psmem="ps aux | sort -nr -k 4 | head -11 | awk 'BEGIN { count=1; } NR==1 {print \"NO   USER               %CPU  %MEM    USAGE   COMMAND\"; print \"---- ------------------- ----- ------ ------- --------------------------------\"} NR > 1 {printf \"%-4d %-20s %-6s %-7s %-8s %s\n\", count++, \$1, \$3, \$4, \$6/1024, \$11; print \"---- ------------------- ----- ------ ------- --------------------------------\"}' | column -t"
#full 'ps aux' output sorted by cpu (less cmd args, pid, and vsz) with dashed line row separators
alias pscpu="ps aux | sort -nr -k 3 | head -11 | awk 'BEGIN { count=1; } NR==1 {print \"NO   USER               %CPU  %MEM    USAGE   COMMAND\"; print \"---- ------------------- ----- ------ ------- --------------------------------\"} NR > 1 {printf \"%-4d %-20s %-6s %-7s %-8s %s\n\", count++, \$1, \$3, \$4, \$6/1024, \$11; print \"---- ------------------- ----- ------ ------- --------------------------------\"}' | column -t"
#remove all 0kb files from current directory (used to clean up auto-generated daily journal docs.)
alias remove0="find * -type f -size 0 -exec trash {} +"
##Apps
alias brave='open -a "Brave Browser.app"'
alias logseq='open -a Logseq'
alias gmail='brave https://www.gmail.com'
alias discord='open -a Discord'
alias signal='open -a Signal'
alias keep='open -a Keep'
alias gpt='open -a chatGPT'
alias mt='open -a Monkeytype'
alias clean='open -a CleanMyMac-MAS'
alias messages='open -a Messages'
