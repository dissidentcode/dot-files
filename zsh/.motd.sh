# Background colors (regular)
BG_BLACK="\033[40m"
BG_RED="\033[41m"
BG_GREEN="\033[42m"
BG_YELLOW="\033[43m"
BG_BLUE="\033[44m"
BG_MAGENTA="\033[45m"
BG_CYAN="\033[46m"
BG_WHITE="\033[47m"

# Text colors (regular)
black="\033[30m"
red="\033[31m"
green="\033[32m"
yellow="\033[33m"
blue="\033[34m"
magenta="\033[35m"
cyan="\033[36m"
white="\033[37m"

# Optional bold versions of the regular ANSI colors (still mapped to same base colors)
bold_black="\033[1;30m"
bold_red="\033[1;31m"
bold_green="\033[1;32m"
bold_yellow="\033[1;33m"
bold_blue="\033[1;34m"
bold_magenta="\033[1;35m"
bold_cyan="\033[1;36m"
bold_white="\033[1;37m"

# Reset
RESET="\033[0m"
reset="\033[0m"

#Color variables with background colors
#BG_BLACK="\033[0;40m"
#BG_RED="\033[0;41m"
#BG_GREEN="\033[0;42m"
#BG_YELLOW="\033[0;43m"
#BG_BLUE="\033[0;44m"
#BG_MAGENTA="\033[0;45m"
#BG_CYAN="\033[0;46m"
#BG_WHITE="\033[0;47m"
BG_BBLACK="\033[0;100m"
BG_BRED="\033[0;101m"
BG_BGREEN="\033[0;102m"
BG_BYELLOW="\033[0;103m"
BG_BBLUE="\033[0;104m"
BG_BMAGENTA="\033[0;105m"
BG_BCYAN="\033[0;106m"
BG_BWHITE="\033[0;107m"
#RESET="\033[0m"
## Color variables with foreground colors
#black=" \u001b[30m"
#red=" \u001b[31m"
#green=" \u001b[32m"
#yellow=" \u001b[33m"
#blue=" \u001b[34m"
#magenta=" \u001b[35m"
#cyan=" \u001b[36m"
#white=" \033[37m" #\u001b[37m
#reset=" \u001b[0m"
bblack="\u001b[90;1m"
#bred="\u001b[91;1m"
#bgreen="\u001b[92;1m"
#byellow="\u001b[93;1m"
bblue="\u001b[94;1m"
bmagenta="\u001b[95;1m"
bcyan="\u001b[96;1m"
#bwhite="\u001b[97;1m"
#reset="\u001b[0m"
#Fetch disk info
disk_info=$(df -Pk | awk 'NR>1 && /^\/dev\//' | awk '{print $4}' | sort -nr | head -n1 | awk '{printf "%.0fGi available", $1/1024/1024}')
#Fetch font from Wezterm.lus or throw unknown
font=$(grep 'font = wezterm.font("' ~/.config/wezterm/wezterm.lua 2>/dev/null | sed -E 's/.*font\("([^"]+)".*/\1/') || font="Unknown"
# Fetch battery information
battery_info=$(pmset -g batt | grep -o '[0-9]\+%')
# Fetch total and used memory
total_memory=$(sysctl -n hw.memsize | awk '{print $1/1073741824}') # Total memory in GB
page_size=$(vm_stat | grep "page size of" | awk '{print $8}')
used_memory_pages=$(vm_stat | grep "Pages active:" | awk '{print $3}' | tr -d '.')
used_memory=$(echo "scale=2; $used_memory_pages * $page_size / 1024 / 1024 / 1024" | bc) # Used memory in GB
memory_percentage=$(echo "scale=2; $used_memory / $total_memory * 100" | bc)
# Ascii art and system info
echo ""
echo "               ${white}.:^mmmmm^:${reset}              ""    ${magenta}dMMMMMP${reset}  ${bmagenta}.dMMMb   dMP dMP${reset}   "
echo "           ${white}^7YG#&@@@@@@@&B57:${reset}          ""     ${magenta}.dMP\"${reset}  ${bmagenta}dMP\" VP  dMP dMP${reset}  "
echo "        ${white}^JB@@@@@@@@@@@@@@@@@&G7.${reset}       ""   ${magenta}.dMP\"${reset}    ${bmagenta}VMMMb   dMMMMMP${reset}    "
echo "      ${white}^5@@@@@@@@@@@@@@@@@@@@@@@B7${reset}      "" ${magenta}.dMP\"${reset}    ${bmagenta}dP .dMP  dMP dMP${reset}     "
echo "     ${white}J@@@@@@@@@@@@@@@@@@@@@@@@@@@5${reset}     ""${magenta}dMMMMMP${reset}  ${bmagenta}VMMMP\"   dMP dMP${reset}  ${bblack}dMMMMMMP${reset}"
echo "    ${white}5@@@@@@@@@@@@@@@@@@@@@@@@#B&B@~    ""${blue}Hardware:${reset} ${bblue}$(sysctl -n hw.model)${reset}"                                  # Hardware
echo "   ${white}?@@@@@@@@@@@@@@@@@@@@@@@@&:J@~:.    ""${blue}OS:${reset} ${bblue}$(sw_vers -productName) $(sw_vers -productVersion)${reset}"           # OS
echo "  ${white}.#@@@@@@@@@@@@@@@@@@@@@@@J^ JY:      ""${blue}CPU:${reset} ${bblue}$(sysctl -n machdep.cpu.brand_string)${reset} "                      # CPU
echo " ${white}:P&&&@@@@@@@@@@@@@@@@#GBP~            ""${blue}Shell:${reset} ${bblue}$(basename "$SHELL")${reset}"                                      # Shell
echo " ${white}~!   7B@@@@@##&@@@@#^.                ""${blue}Terminal:${reset} ${bblue}${TERM_PROGRAM}${reset}"                                        # User
echo " ${white}?P   :@@@&~    YB#^|.                 ""${blue}Local Host:${reset} ${bblue}$(scutil --get LocalHostName)${reset}"                        # Host
echo " ${white}P&?L. ~7B@&.    \`:7!                  ""${blue}Diskspace:${reset} ${bblue}${disk_info}${reset}"                                         # Diskspace
echo "${white}:#&@B~7: \Y@~ .    .#@7                ""${blue}Uptime:${reset} ${bblue}$(uptime | awk -F'up ' '{print $2}' | cut -d',' -f1-2)${reset}"   # Uptime
echo "  ${white}!PY5?   .G&5BBG7J7P@@7               ""${blue}Memory:${reset} ${bblue}$used_memory GB / $total_memory GB ($memory_percentage%)${reset}" # Memory
echo "    ${white}5@Y ;  :@@P555B@@@P                ""${blue}Battery:${reset} ${bblue}${battery_info}${reset}"                                         # Battery percentage
echo "     ${white}5@G?J!J@B!:  ^G5J^                ""${blue}Font:${reset} ${bblue}${font}${reset}"                                                    # Font
echo "     ${white}~PB#&@BJ~^:                       ""${BG_BWHITE}    ${BG_BMAGENTA}    ${BG_BRED}    ${BG_BYELLOW}    ${BG_BBLUE}    ${BG_BCYAN}    ${BG_BGREEN}    ${BG_BBLACK}    ${RESET}"
echo "       ${white}iUN7.                           ""${BG_WHITE}    ${BG_MAGENTA}    ${BG_RED}    ${BG_YELLOW}    ${BG_BLUE}    ${BG_CYAN}    ${BG_GREEN}    ${BG_BLACK}    ${RESET}"
echo ""
echo ""
