#!/bin/bash

source ~/.bashrc 2>/dev/null 


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
    echo -e "${RED}│${NC}${BG_WHITE}${BLACK}  ✪  ${current_dir}  ${NC}"
    echo -e "${RED}╰──────────────────────────────╯${NC}\n"
}
# ALIAS MODULES
alias_creation() {
    read -p "Enter alias: " alias_name
    read -p "Enter alias_command: " alias_command
    cat >>~/.bashrc << EOL
${alias_name}() {
    ${alias_command}
}
EOL
    source ~/.bashrc
}

alias_deletion() {

    if [ "$#" -eq 0 ]; then
        read -p "Enter the alias to be deleted: " alias_name
    else
        alias_name="$1"
    fi
    pattern="${alias_name}() {"
    escaped_pattern=$(printf '%s\n' "$pattern" | sed 's/[]\/$*.^[]/\\&/g')
    if grep -q "${pattern}" ~/.bashrc; then
        sed -i '' "/${escaped_pattern}/,/^[[:space:]]*}[[:space:]]*$/d" ~/.bashrc
    else
        echo "Could not find ${alias_name}"
    fi

    source ~/.bashrc
}

home_render() {

    read -p "$(echo -e "${RED}>>${NC}") " option

    if [[ "$option" == "alias create" ]]; then
        alias_creation
    elif [[ "$option" == alias\ delete* ]]; then
        args="${option#alias delete }"
        if [[ "$args" != "$option" ]]; then
            alias_deletion "$args"
        else
            alias_deletion
        fi
    elif [[ "$option" == "clear" ]]; then
        clear
        render_current_dir
    elif [[ "$option" == "cd" || "$option" == cd\ * ]]; then
        eval "$option" 2>/dev/null
        if [ $? -eq 0 ]; then
            render_current_dir
        else
            echo "cd: no such file or directory"
        fi
    else
        prev_dir=$(pwd)
        temp_err=$(mktemp)
        eval "$option" 2>"$temp_err"
        status=$?

        if [ "$status" -ne 0 ]; then
            clean_error=$(sed 's/^[^:]*: line [0-9]*: //' "$temp_err")
            printf '%s\n' "$clean_error"
        fi
        rm -f "$temp_err"

        if [ "$(pwd)" != "$prev_dir" ]; then
            render_current_dir
        fi
    fi

}


render_current_dir
while [ true ]
do
    home_render
done



