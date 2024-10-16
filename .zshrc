 export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/System/Cryptexes/App/usr/bin:/usr/bin:/bin:/usr/sbin:/sbin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/local/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/bin:/var/run/com.apple.security.cryptexd/codex.system/bootstrap/usr/appleinternal/bin"

export EDITOR=nvim

# Loads version control information for use in the prompt
autoload -Uz vcs_info
precmd() { vcs_info }

# Customize the version control information format for git repositories
# This sets the branch name to appear in red and the git icon in yellow
zstyle ':vcs_info:git:*' formats '%F{yellow}  󰘬 %f%F{yellow}%b %f'
 
# Configure the prompt appearance
# Displays an arrow, the directory path, the git branch, and a symbol before the cursor
setopt PROMPT_SUBST
PROMPT='%F{magenta}%f %F{yellow} %f%F{green}%n%f %F{yellow} %f %F{blue}${PWD/#$HOME/~}%f ${vcs_info_msg_0_}%F{magenta} %f'

# Set directory and file color scheme for 'ls' and 'grep' commands
export LSCOLORS=ExFxBxDxCxegedabagacad

# Automatically navigate to a directory without typing 'cd'
setopt AUTO_CD 

# Load and initialize the completion system, providing options and file paths predictions
autoload -Uz compinit
compinit
_comp_options+=(globdots) #include hidden files

# Load syntax highlighting, which provides different coloring for commands, options, paths, etc.
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Load auto-suggestions, which provides suggestions for commands as you type based on command history
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# Load 'z', which tracks your most visited directories and allows quick navigation to them
source $(brew --prefix)/etc/profile.d/z.sh

# Set up fzf keybindings and fuzzy completion
source <(fzf --zsh)

# Configure how command completions are displayed and navigated
zstyle ':completion:*' menu select
# Configure how the command line tries to auto-correct and match your input
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=10000
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt EXTENDED_HISTORY   
# export HIST_STAMPS="mm/dd/yyyy"


# Enable colored man pages for better readability
export LESS_TERMCAP_mb=$'\E[01;31m'       # Begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # Begin bold
export LESS_TERMCAP_me=$'\E[0m'           # End mode
export LESS_TERMCAP_se=$'\E[0m'           # End standout-mode
export LESS_TERMCAP_so=$'\E[38;5;246m'    # Begin standout-mode (for info box)
export LESS_TERMCAP_ue=$'\E[0m'           # End underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # Begin underline

# Custom scripts for additional configuration
source ~/.zsh/.motd.sh      # Load a custom message of the day script
source ~/.zsh/.alias.sh     # Load a custom aliases script
source ~/.zsh/.functions.sh # Load a custom functions script
export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval "$(starship init zsh)"
# Fetch and display Quote of the Day
quote_of_the_day=$(curl -s "https://zenquotes.io/api/today" | jq -r '.[0].q')
echo "${bwhite}Quote of the day:${yellow}$quote_of_the_day"
echo ""
#vim keybinds
bindkey -v