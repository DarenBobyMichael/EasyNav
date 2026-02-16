#!/bin/bash
# VISUAL MODULE
# Command handler for 'visual' commands
# Customize prompt color, symbol, directory box, and themes

# Available color names mapped to ANSI codes
declare -A EN_COLOR_MAP=(
    [red]='\033[0;31m'
    [green]='\033[0;32m'
    [yellow]='\033[0;33m'
    [blue]='\033[0;34m'
    [magenta]='\033[0;35m'
    [cyan]='\033[0;36m'
    [white]='\033[0;37m'
)

# Apply visual settings from ~/.enrc (called on module load and after changes)
visual_apply() {
    EN_PROMPT_COLOR="${EN_PROMPT_COLOR:-$RED}"
    EN_PROMPT_SYMBOL="${EN_PROMPT_SYMBOL:->>}"
    EN_DIR_COLOR="${EN_DIR_COLOR:-$RED}"
    EN_DIR_SYMBOL="${EN_DIR_SYMBOL:-✪}"
}

# Initialize on load
visual_apply

en_visual() {
    local full_cmd="$1"
    local subcmd="${full_cmd#visual }"

    # Handle bare 'visual' command
    [[ "$subcmd" == "visual" ]] && subcmd="status"

    case "$subcmd" in
        status)
            visual_status
            ;;
        prompt-color|prompt-color\ *)
            local color="${subcmd#prompt-color}"
            color="${color# }"
            if [[ -n "$color" ]]; then
                visual_set_prompt_color "$color"
            else
                echo -e "${RED}Usage:${NC} visual prompt-color <color>"
                visual_show_colors
            fi
            ;;
        prompt-symbol|prompt-symbol\ *)
            local symbol="${subcmd#prompt-symbol}"
            symbol="${symbol# }"
            if [[ -n "$symbol" ]]; then
                visual_set "EN_PROMPT_SYMBOL" "$symbol"
                EN_PROMPT_SYMBOL="$symbol"
                echo -e "${GREEN}✓${NC} Prompt symbol set to: $symbol"
            else
                echo -e "${RED}Usage:${NC} visual prompt-symbol <symbol>"
            fi
            ;;
        dir-color|dir-color\ *)
            local color="${subcmd#dir-color}"
            color="${color# }"
            if [[ -n "$color" ]]; then
                visual_set_dir_color "$color"
            else
                echo -e "${RED}Usage:${NC} visual dir-color <color>"
                visual_show_colors
            fi
            ;;
        dir-symbol|dir-symbol\ *)
            local symbol="${subcmd#dir-symbol}"
            symbol="${symbol# }"
            if [[ -n "$symbol" ]]; then
                visual_set "EN_DIR_SYMBOL" "$symbol"
                EN_DIR_SYMBOL="$symbol"
                echo -e "${GREEN}✓${NC} Directory symbol set to: $symbol"
            else
                echo -e "${RED}Usage:${NC} visual dir-symbol <symbol>"
            fi
            ;;
        theme|theme\ *)
            local theme="${subcmd#theme}"
            theme="${theme# }"
            if [[ -n "$theme" ]]; then
                visual_set_theme "$theme"
            else
                visual_list_themes
            fi
            ;;
        reset)
            visual_reset
            ;;
        *)
            echo -e "${RED}Unknown visual command:${NC} $subcmd"
            echo "Available commands:"
            echo "  visual                          - Show current settings"
            echo "  visual prompt-color <color>     - Set prompt color"
            echo "  visual prompt-symbol <symbol>   - Set prompt symbol"
            echo "  visual dir-color <color>        - Set directory box color"
            echo "  visual dir-symbol <symbol>      - Set directory icon"
            echo "  visual theme <name>             - Apply a preset theme"
            echo "  visual reset                    - Reset to defaults"
            ;;
    esac
}

visual_status() {
    echo -e "${CYAN}Current visual settings:${NC}\n"
    echo -e "  Prompt color:    ${EN_PROMPT_COLOR}sample${NC}"
    echo -e "  Prompt symbol:   ${EN_PROMPT_SYMBOL}"
    echo -e "  Dir box color:   ${EN_DIR_COLOR}sample${NC}"
    echo -e "  Dir symbol:      ${EN_DIR_SYMBOL}"
    echo ""
    echo -e "  Preview:"
    echo -e "  ${EN_DIR_COLOR}╭──────────────────────────────╮${NC}"
    echo -e "  ${EN_DIR_COLOR}│${NC}  ${EN_DIR_SYMBOL}  ~/example/path  ${NC}"
    echo -e "  ${EN_DIR_COLOR}╰──────────────────────────────╯${NC}"
    echo -e "  ${EN_PROMPT_COLOR}${EN_PROMPT_SYMBOL}${NC} command here"
}

visual_show_colors() {
    echo -e "\nAvailable colors:"
    for color in red green yellow blue magenta cyan white; do
        echo -e "  ${EN_COLOR_MAP[$color]}${color}${NC}"
    done
}

visual_resolve_color() {
    local name="$1"
    name=$(echo "$name" | tr '[:upper:]' '[:lower:]')
    if [[ -n "${EN_COLOR_MAP[$name]}" ]]; then
        echo "${EN_COLOR_MAP[$name]}"
        return 0
    fi
    return 1
}

visual_set_prompt_color() {
    local color_code
    color_code=$(visual_resolve_color "$1")
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error:${NC} Unknown color '$1'"
        visual_show_colors
        return 1
    fi
    visual_set "EN_PROMPT_COLOR" "$color_code"
    EN_PROMPT_COLOR="$color_code"
    echo -e "${GREEN}✓${NC} Prompt color set to: ${color_code}$1${NC}"
}

visual_set_dir_color() {
    local color_code
    color_code=$(visual_resolve_color "$1")
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Error:${NC} Unknown color '$1'"
        visual_show_colors
        return 1
    fi
    visual_set "EN_DIR_COLOR" "$color_code"
    EN_DIR_COLOR="$color_code"
    echo -e "${GREEN}✓${NC} Directory box color set to: ${color_code}$1${NC}"
}

# Persist a setting to ~/.enrc
visual_set() {
    local key="$1"
    local value="$2"

    touch ~/.enrc

    # Remove existing setting if present
    if grep -q "^${key}=" ~/.enrc 2>/dev/null; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "/^${key}=/d" ~/.enrc
        else
            sed -i "/^${key}=/d" ~/.enrc
        fi
    fi

    # Append new setting
    echo "${key}='${value}'" >> ~/.enrc
    source ~/.enrc
}

visual_set_theme() {
    local theme="$1"
    theme=$(echo "$theme" | tr '[:upper:]' '[:lower:]')

    case "$theme" in
        default)
            visual_apply_theme '\033[0;31m' '>>' '\033[0;31m' '✪'
            echo -e "${GREEN}✓${NC} Theme 'default' applied (classic red)"
            ;;
        ocean)
            visual_apply_theme '\033[0;36m' '~~' '\033[0;34m' '⚓'
            echo -e "${GREEN}✓${NC} Theme 'ocean' applied"
            ;;
        forest)
            visual_apply_theme '\033[0;32m' '🌿' '\033[0;32m' '🌲'
            echo -e "${GREEN}✓${NC} Theme 'forest' applied"
            ;;
        sunset)
            visual_apply_theme '\033[0;33m' '☀' '\033[0;35m' '✦'
            echo -e "${GREEN}✓${NC} Theme 'sunset' applied"
            ;;
        minimal)
            visual_apply_theme '\033[0;37m' '$' '\033[0;37m' '→'
            echo -e "${GREEN}✓${NC} Theme 'minimal' applied"
            ;;
        *)
            echo -e "${RED}Error:${NC} Unknown theme '$theme'"
            visual_list_themes
            return 1
            ;;
    esac

    visual_status
}

visual_apply_theme() {
    local p_color="$1" p_symbol="$2" d_color="$3" d_symbol="$4"

    visual_set "EN_PROMPT_COLOR" "$p_color"
    visual_set "EN_PROMPT_SYMBOL" "$p_symbol"
    visual_set "EN_DIR_COLOR" "$d_color"
    visual_set "EN_DIR_SYMBOL" "$d_symbol"

    EN_PROMPT_COLOR="$p_color"
    EN_PROMPT_SYMBOL="$p_symbol"
    EN_DIR_COLOR="$d_color"
    EN_DIR_SYMBOL="$d_symbol"
}

visual_list_themes() {
    echo -e "${CYAN}Available themes:${NC}\n"
    echo -e "  ${EN_COLOR_MAP[red]}default${NC}   - Classic red prompt"
    echo -e "  ${EN_COLOR_MAP[cyan]}ocean${NC}     - Cool blue and cyan tones"
    echo -e "  ${EN_COLOR_MAP[green]}forest${NC}    - Natural green theme"
    echo -e "  ${EN_COLOR_MAP[yellow]}sunset${NC}    - Warm yellow and magenta"
    echo -e "  ${EN_COLOR_MAP[white]}minimal${NC}   - Clean white, no frills"
    echo ""
    echo -e "Usage: visual theme <name>"
}

visual_reset() {
    read -p "Reset all visual settings to defaults? (y/n): " confirm
    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
        for key in EN_PROMPT_COLOR EN_PROMPT_SYMBOL EN_DIR_COLOR EN_DIR_SYMBOL; do
            if grep -q "^${key}=" ~/.enrc 2>/dev/null; then
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    sed -i '' "/^${key}=/d" ~/.enrc
                else
                    sed -i "/^${key}=/d" ~/.enrc
                fi
            fi
        done

        EN_PROMPT_COLOR="$RED"
        EN_PROMPT_SYMBOL=">>"
        EN_DIR_COLOR="$RED"
        EN_DIR_SYMBOL="✪"

        echo -e "${GREEN}✓${NC} Visual settings reset to defaults"
        visual_status
    else
        echo "Cancelled"
    fi
}
