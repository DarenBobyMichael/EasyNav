#!/bin/bash
# HISTORY MODULE
# Command handler for 'history' commands

en_history() {
    local full_cmd="$1"
    local subcmd="${full_cmd#history }"

    case "$subcmd" in
        search*)
            local term="${subcmd#search }"
            if [[ -n "$term" ]]; then
                history_search "$term"
            else
                echo -e "${RED}Usage:${NC} history search <term>"
            fi
            ;;
        clear)
            history_clear
            ;;
        top)
            history_top
            ;;
        list|"")
            history_list
            ;;
        *)
            echo -e "${RED}Unknown history command:${NC} $subcmd"
            echo "Available: history [list], history search <term>, history top, history clear"
            ;;
    esac
}

history_list() {
    if [[ -f ~/.en_history ]]; then
        nl -w3 -s'. ' ~/.en_history | tail -20
    else
        echo "No history found"
    fi
}

history_search() {
    local term="$1"
    if [[ -f ~/.en_history ]]; then
        grep -i "$term" ~/.en_history | nl -w3 -s'. '
    else
        echo "No history found"
    fi
}

history_clear() {
    read -p "Are you sure you want to clear history? (y/n): " confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        > ~/.en_history
        history -c
        echo -e "${GREEN}History cleared${NC}"
    else
        echo "Cancelled"
    fi
}

history_top() {
    if [[ -f ~/.en_history ]]; then
        echo -e "${CYAN}Top 10 most used commands:${NC}"
        sort ~/.en_history | uniq -c | sort -rn | head -10 | awk '{$1=$1; print NR". "$0}'
    else
        echo "No history found"
    fi
}
