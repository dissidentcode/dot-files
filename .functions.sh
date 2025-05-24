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

#Symlink creation function that backs up a file or directory and then turns it into a symlink
function symlink() {
  if [ -e "$1" ]; then
    # Create a timestamp for the backup
    timestamp=$(date +"%Y%m%d%H%M%S")
    # Rename using the timestamp to avoid conflicts
    mv "$1" "$1.backup.$timestamp"
    ln -sf "$2" "$1"
  else
    echo "$1 does not exist."
    return 1
  fi
}

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

# function torrent() {
#   local label=$1
#   local infohash=$2
#   local base_dir="/Users/nate/Downloads/torrents"
#
#   if [ -z "$label" ] || [ -z "$infohash" ]; then
#     echo "Error: Please provide both a label and an info hash"
#     return 1
#   fi
#
#   local trackers="$(curl -s https://github.com/ngosang/trackerslist/blob/master/trackers_all_https.txt)"
#   trackers=$(printf '%s' "$trackers" | awk '{ printf "&tr="; printf "%s", $0 }')
#   trackers=${trackers//:/\%3A}
#   trackers=${trackers//\//\%2F}
#
#   local magnet_link="magnet:?xt=urn:btih:$infohash$trackers"
#   local target_dir="${base_dir}/${label}"
#   local log_file="${target_dir}/log.txt"
#
#   # Create the target directory if it doesn't exist
#   mkdir -p "$target_dir"
#
#   # Check if the info hash already exists in the log file
#   if ! grep -q "$infohash" "$log_file" 2>/dev/null; then
#     # Append the info hash, magnet link, and label to the log file
#     {
#       echo "----------------------------------------"
#       echo ""
#       echo "Label: $label"
#       echo ""
#       echo "Date: $(date +"%A %m/%d/%Y %I:%M %p")"
#       echo ""
#       echo "Info Hash: $infohash"
#       echo ""
#       echo "Magnet Link: $magnet_link"
#       echo ""
#       echo "----------------------------------------"
#       echo ""
#     } >>"$log_file"
#   fi
#
#   # Start or resume the torrent download with aria2
#   aria2c -d "$target_dir" --bt-save-metadata=true "$magnet_link"
# }
