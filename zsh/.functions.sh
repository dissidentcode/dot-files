## GIT FUNCTIONS ##

#git add, commit -m, push function (no need to use quotes for commit message 😉)
function acp() {
  # Check if there are any changes to add
  if [ -z "$(git status --porcelain)" ]; then
    echo "No changes to commit."
    return 1
  fi

  # Check if a commit message is provided
  if [ -z "$1" ]; then
    echo "Please provide a commit message."
    return 1
  fi

  # Concatenate all arguments into one commit message
  local message="$*"

  # Add all changes
  git add -A

  # Commit the changes with the concatenated message
  git commit -m "$message"

  # Push the changes to the master branch
  git push origin master
}

## NETWORK FUNCTIONS##

#Currnt wifi network passwaork#

wifi() {
  local ssid=$(system_profiler SPAirPortDataType | awk '/Current Network Information:/{getline; print; exit}' | sed 's/^[[:space:]]*//;s/:$//')

  if [[ -z "$ssid" || "$ssid" == "Not associated with any network" ]]; then
    echo "No active Wi-Fi network found. Please ensure you're connected to a Wi-Fi network."
  else
    wifi-password "$ssid"
  fi
}

## MISCELLANEOUS FUNCTIONS ##

##Symlink creation function that backs up a file or directory and then turns it into a symlink
symlink() {
  local dest="$1"
  local src="$2"

  # Resolve full paths manually (portable alternative to realpath -m)
  dest=$(cd "$(dirname "$dest")" && pwd)/$(basename "$dest")
  src=$(cd "$(dirname "$src")" && pwd)/$(basename "$src")

  # If source doesn't exist but destination does, assume we're migrating the original file
  if [ ! -e "$src" ] && [ -e "$dest" ]; then
    echo "💡 Source $src does not exist — assuming $dest is the original file."
    mkdir -p "$(dirname "$src")"
    mv "$dest" "$src"
    echo "📦 Moved $dest → $src"
  fi

  # If source STILL doesn't exist, we can't link to it
  if [ ! -e "$src" ]; then
    echo "❌ Source file $src does not exist. Aborting."
    return 1
  fi

  # Backup existing destination
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    local timestamp=$(date +"%Y%m%d%H%M%S")
    mv "$dest" "$dest.backup.$timestamp"
    echo "📦 Backed up $dest → $dest.backup.$timestamp"
  fi

  # Ensure parent dir of destination exists
  mkdir -p "$(dirname "$dest")"

  # Create the symlink
  ln -sf "$src" "$dest"
  echo "🔗 Linked $dest → $src"
}

#symlink creation function for directories
symlink_dir() {
  local link_path=$1
  local real_path=$2

  if [[ -z "$link_path" || -z "$real_path" ]]; then
    echo "Usage: symlink_dir <link_path> <real_path>"
    return 1
  fi

  mkdir -p "$(dirname "$link_path")" "$(dirname "$real_path")"

  if [[ -d "$link_path" && ! -L "$link_path" ]]; then
    local ts=$(date +"%Y%m%d%H%M%S")
    echo "📦 Backing up $link_path → ${link_path}.backup.$ts"
    cp -a "$link_path" "${link_path}.backup.$ts"

    if [[ ! -e "$real_path" ]]; then
      echo "📁 Moving $link_path → $real_path"
      mv "$link_path" "$real_path"
    else
      echo "⚠️  $real_path already exists — skipping move"
    fi
  fi

  ln -sfn "$real_path" "$link_path"
  echo "🔗 Symlinked: $link_path → $real_path"
}

#fzf with preview functionality using lf preview script
fp() {
  local file choice

  file=$(fzf --preview '~/git_repos/dot-files/zsh/.zsh-scripts/preview.sh {} 2>/dev/null' --preview-window=right:60%) || return

  if [ -n "$file" ]; then
    echo ""
    echo "Open with:"
    echo "  [1] macOS Preview (open)"
    echo "  [2] Neovim        (nvim)"
    echo "  [3] Less pager    (less)"
    echo "  [4] Bat preview   (bat)"
    echo "  [5] Cancel"
    echo -n "Choose [1-5]: "
    read -r choice

    case "$choice" in
    1) open "$file" 2>/dev/null ;;
    2) nvim "$file" ;;
    3) less "$file" ;;
    4) bat "$file" ;;
    *) echo "Aborted." ;;
    esac

    echo ""
    read -r -p "Press enter to return to shell..."
  fi
}

#history search
h() {
  gawk -F';' '
    BEGIN {
      CYAN = "\033[36m"; RESET = "\033[0m"; GRAY = "\033[90m"
      last_ts = ""
    }
    /^: [0-9]+:[0-9]+;/ {
      ts = substr($1, 3)
      cmd = $2
      if (ts != last_ts) {
        time = strftime("%-m/%-d/%y %I:%M %p", ts)
        printf "%s%s%s │ %s\n", CYAN, time, RESET, cmd
        last_ts = ts
      } else {
        printf "             │ %s\n", cmd
      }
    }
    /^[^:]/ {
      printf "%s(no timestamp)%s │ %s\n", GRAY, RESET, $0
    }
  ' "$HISTFILE" | fzf --tac --no-sort --ansi
}

#fp() {

#  fzf --preview '~/git_repos/dot-files/zsh/.zsh-scripts/preview.sh {}' --preview-window=right:60%
#}

#function symlink() {
#  if [ -e "$1" ]; then
#    # Create a timestamp for the backup
#    timestamp=$(date +"%Y%m%d%H%M%S")
#    # Rename using the timestamp to avoid conflicts
#    mv "$1" "$1.backup.$timestamp"
#    ln -sf "$2" "$1"
#  else
#    echo "$1 does not exist."
#    return 1
#  fi
#}

## IMAGE MANIPULATION FUNCTIONS ##

#Image organization function - takes a directory and sorts all common image types into appropriately labeled folders
function orgimg() {
  ~/.zsh-scripts/.organize_images.sh "$@"
}

#Image conversion functions
function jpg2png() {
  ~/.zsh-scripts/.jpg2png.sh "$@"
}
function jpg2webp() {
  ~/.zsh-scripts/.jpg2webp.sh "$@"
}
function png2jpg() {
  ~/.zsh-scripts/.png2jpg.sh "$@"
}
function png2webp() {
  ~/.zsh-scripts/.png2webp.sh "$@"
}
function webp2jpg() {
  ~/.zsh-scripts/.webp2jpg.sh "$@"
}
function webp2png() {
  ~/.zsh-scripts/.webp2png.sh "$@"
}
function pdf2jpg() {
  ~/.zsh-scripts/.pdf2jpg.sh "$@"
}
function jpg2pdf() {
  ~/.zsh-scripts/.jpg2pdf.sh "$@"
}
function vector2png() {
  ~/.zsh-scripts/.vector2png.sh "$@"
}
function heic2jpg() {
  ~/.zsh-scripts/.heic2jpg.sh "$@"
}

#Image optimization functions
function optjpg() {
  ~/.zsh-scripts/.optimize-jpg.sh "$@"
}
function optpng() {
  ~/.zsh-scripts/.optimize-png.sh "$@"
}

source ~/git_repos/makegif/makegif.sh

# Searching the web

function ddg() {
  brave "https://www.duckduckgo.com/?q=$1"
}

function google() {
  brave "https://www.google.com/search?q=$1"
}

gmailsearch() {
  open -a "Brave Browser" "https://mail.google.com/mail/u/0/#search/$1"
}

function youtube() {
  brave "https://www.youtube.com/results?search_query=$1"
}

function torrent() {
  local label=$1
  local infohash=$2
  local base_dir="/Users/nate/Downloads/torrents"

  if [ -z "$label" ] || [ -z "$infohash" ]; then
    echo "Error: Please provide both a label and an info hash"
    return 1
  fi

  # Fetch the tracker list from the new source
  local trackers="$(curl -s https://raw.githubusercontent.com/ngosang/trackerslist/master/trackers_all_https.txt)"
  trackers=$(printf '%s' "$trackers" | awk '{ printf "&tr="; printf "%s", $0 }')
  trackers=${trackers//:/\%3A}
  trackers=${trackers//\//\%2F}

  local magnet_link="magnet:?xt=urn:btih:$infohash$trackers"
  local target_dir="${base_dir}/${label}"
  local log_file="${target_dir}/log.txt"

  # Create the target directory if it doesn't exist
  mkdir -p "$target_dir"

  # Check if the info hash already exists in the log file
  if ! grep -q "$infohash" "$log_file" 2>/dev/null; then
    # Append the info hash, magnet link, and label to the log file
    {
      echo "----------------------------------------"
      echo ""
      echo "Label: $label"
      echo ""
      echo "Date: $(date +"%A %m/%d/%Y %I:%M %p")"
      echo ""
      echo "Info Hash: $infohash"
      echo ""
      echo "Magnet Link: $magnet_link"
      echo ""
      echo "----------------------------------------"
      echo ""
    } >>"$log_file"
  fi

  # Start or resume the torrent download with aria2 using optimized settings
  aria2c \
    -d "$target_dir" \
    --bt-save-metadata=true \
    --bt-max-peers=200 \
    --bt-request-peer-speed-limit=1M \
    --bt-tracker-connect-timeout=5 \
    --bt-tracker-interval=120 \
    --bt-detach-seed-only=true \
    --split=64 \
    --max-connection-per-server=16 \
    --min-split-size=1M \
    --seed-time=0 \
    "$magnet_link"
}

shorturl() {
  if [[ -z "$1" ]]; then
    echo "Usage: shorturl <long_url>"
    return 1
  fi
  local short
  short=$(curl -s "https://is.gd/create.php?format=simple&url=$1")

  if [[ -n "$short" ]]; then
    echo "$short" | pbcopy
    echo "Shortened URL copied to clipboard: $short"
  else
    echo "Failed to shorten URL"
    return 1
  fi
}
