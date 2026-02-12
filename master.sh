#!/bin/bash

# Source EasyNav configuration file
source ~/.enrc 2>/dev/null

source ./modules/module_master.sh


#COLORS
NC='\033[0m'
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[0;37m'

BG_BLACK='\033[40m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_MAGENTA='\033[45m'
BG_CYAN='\033[46m'
BG_WHITE='\033[47m'

render_current_dir() {
    current_dir=$(pwd)
    echo -e "\n${RED}╭──────────────────────────────╮${NC}"
    echo -e "${RED}│${NC}  ✪  ${current_dir}  ${NC}"
    echo -e "${RED}╰──────────────────────────────╯${NC}\n"
}

check_quotes() {
    local input="$1"
    local single_quotes=$(echo "$input" | grep -o "'" | wc -l)
    local double_quotes=$(echo "$input" | grep -o '"' | wc -l)

    if [ $((single_quotes % 2)) -ne 0 ] || [ $((double_quotes % 2)) -ne 0 ]; then
        return 1
    fi
    return 0
}

execute_command() {
    local cmd="$1"

    if ! check_quotes "$cmd"; then
        echo -e "${RED}Error:${NC} Unmatched quotes in command"
        return 1
    fi

    local prev_dir=$(pwd)
    local temp_err=$(mktemp)
    eval "$cmd" 2>"$temp_err"
    local status=$?

    if [ "$status" -ne 0 ]; then
        local clean_error=$(sed 's/^[^:]*: line [0-9]*: //' "$temp_err")
        printf '%s\n' "$clean_error"
    fi
    rm -f "$temp_err"

    if [ "$(pwd)" != "$prev_dir" ]; then
        render_current_dir
    fi

    return $status
}

dispatch_command() {
    local cmd="$1"
    local first_word="${cmd%% *}"

    # Check if a handler function exists for this command
    # Modules define functions like: en_alias, en_git, etc.
    if declare -f "en_${first_word}" > /dev/null 2>&1; then
        "en_${first_word}" "$cmd"
        return $?
    fi

    return 1
}

home_render() {
    read -p "$(echo -e "${RED}>>${NC}") " option

    # Built-in commands that must stay in core
    case "$option" in
        "clear")
            clear
            render_current_dir
            return
            ;;
        cd|cd\ *)
            eval "$option" 2>/dev/null
            if [ $? -eq 0 ]; then
                render_current_dir
            else
                echo "cd: no such file or directory"
            fi
            return
            ;;
    esac

    # Try to dispatch to a module command handler
    if dispatch_command "$option"; then
        return
    fi

    # Default: execute as shell command
    execute_command "$option"
}


render_current_dir

while [ true ]
do
    home_render
done



