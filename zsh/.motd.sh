# Color variables with background colors
BG_BLACK="\033[0;40m"
BG_RED="\033[0;41m"
BG_GREEN="\033[0;42m"
BG_YELLOW="\033[0;43m"
BG_BLUE="\033[0;44m"
BG_MAGENTA="\033[0;45m"
BG_CYAN="\033[0;46m"
BG_WHITE="\033[0;47m"
BG_BBLACK="\033[0;100m"
BG_BRED="\033[0;101m"
BG_BGREEN="\033[0;102m"
BG_BYELLOW="\033[0;103m"
BG_BBLUE="\033[0;104m"
BG_BMAGENTA="\033[0;105m"
BG_BCYAN="\033[0;106m"
BG_BWHITE="\033[0;107m"
RESET="\033[0m"
# Color variables with foreground colors
black=" \u001b[30m"
red=" \u001b[31m"
green=" \u001b[32m"
yellow=" \u001b[33m"
blue=" \u001b[34m"
magenta=" \u001b[35m"
cyan=" \u001b[36m"
white=" \u001b[37m"
reset=" \u001b[0m"
bblack="\u001b[90;1m"
bred="\u001b[91;1m"
bgreen="\u001b[92;1m"
byellow="\u001b[93;1m"
bblue="\u001b[94;1m"
bmagenta="\u001b[95;1m"
bcyan="\u001b[96;1m"
bwhite="\u001b[97;1m"
reset="\u001b[0m"
# Fetch battery information
battery_info=$(pmset -g batt | grep -o '[0-9]\+%')
# Fetch total and used memory
total_memory=$(sysctl -n hw.memsize | awk '{print $1/1073741824}') # Total memory in GB
page_size=$(vm_stat | grep "page size of" | awk '{print $8}')
used_memory_pages=$(vm_stat | grep "Pages active:" | awk '{print $3}' | tr -d '.')
used_memory=$(echo "scale=2; $used_memory_pages * $page_size / 1024 / 1024 / 1024" | bc) # Used memory in GB
memory_percentage=$(echo "scale=2; $used_memory / $total_memory * 100" | bc)
# Ascii art and system info
echo "               ${white}.:^mmmmm^:              ""    ${magenta}dMMMMMP  ${bmagenta}.dMMMb   dMP dMP   "
echo "           ${white}^7YG#&@@@@@@@&B57:          ""     ${magenta}.dMP\"  ${bmagenta}dMP\" VP  dMP dMP  "
echo "        ${white}^JB@@@@@@@@@@@@@@@@@&G7.       ""   ${magenta}.dMP\"    ${bmagenta}VMMMb   dMMMMMP    "
echo "      ${white}^5@@@@@@@@@@@@@@@@@@@@@@@B7      "" ${magenta}.dMP\"    ${bmagenta}dP .dMP  dMP dMP     "
echo "     ${white}J@@@@@@@@@@@@@@@@@@@@@@@@@@@5     ""${magenta}dMMMMMP  ${bmagenta}VMMMP\"   dMP dMP  ${bcyan}dMMMMMMP"
echo "    ${white}5@@@@@@@@@@@@@@@@@@@@@@@@#B&B@~    ""${blue}Hardware: ${bblue}$(sysctl -n hw.model)"                                  # Hardware
echo "   ${white}?@@@@@@@@@@@@@@@@@@@@@@@@&:J@~:.    ""${blue}OS: ${bblue}$(sw_vers -productName) $(sw_vers -productVersion)"           # OS
echo "  ${white}.#@@@@@@@@@@@@@@@@@@@@@@@J^ JY:      ""${blue}CPU: ${bblue}$(sysctl -n machdep.cpu.brand_string) ${blue}"               # CPU
echo " ${white}:P&&&@@@@@@@@@@@@@@@@#GBP~            ""${blue}Shell: ${bblue}$(basename $SHELL)"                                        # Shell
echo " ${white}~!   7B@@@@@##&@@@@#^.                ""${blue}User: ${bblue}Diissiident"                                                # User
echo " ${white}?P   :@@@&~    YB#^|.                 ""${blue}Network: ${bblue}$(networksetup -getcomputername)"                        # Network info
echo " ${white}P&?L. ~7B@&.    \`:7!                  ""${blue}Diskspace: ${bblue}$(df -h / | awk 'NR==2 {print $4 " available"}')"     # Diskspace
echo "${white}:#&@B~7: \Y@~ .    .#@7                ""${blue}Uptime: ${bblue}$(uptime | awk -F'up ' '{print $2}' | cut -d',' -f1-2)"   # Uptime
echo "  ${white}!PY5?   .G&5BBG7J7P@@7               ""${blue}Memory: ${bblue}$used_memory GB / $total_memory GB ($memory_percentage%)" # Memory
echo "    ${white}5@Y ;  :@@P555B@@@P                ""${blue}Battery: ${bblue}${battery_info}"                                         # Battery percentage
echo "     ${white}5@G?J!J@B!:  ^G5J^                ""${blue}Font: ${bblue}JetBrainsMono Nerd Font"                                    # Font
echo "     ${white}~PB#&@BJ~^:                        ""${BG_BWHITE}    ${BG_BMAGENTA}    ${BG_BRED}    ${BG_BYELLOW}    ${BG_BBLUE}    ${BG_BCYAN}    ${BG_BGREEN}    ${BG_BBLACK}    ${RESET}"
echo "       ${white}iUN7.                            ""${BG_WHITE}    ${BG_MAGENTA}    ${BG_RED}    ${BG_YELLOW}    ${BG_BLUE}    ${BG_CYAN}    ${BG_GREEN}    ${BG_BLACK}    ${RESET}"
echo ""

