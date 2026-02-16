#!/bin/bash
# ALIAS MODULE
# Command handler for 'alias' commands
en_alias() {
    local full_cmd="$1"
    local subcmd="${full_cmd#alias }"

    case "$subcmd" in
        create)
            alias_creation
            ;;
        delete*)
            local args="${subcmd#delete }"
            if [[ -n "$args" ]]; then
                alias_deletion "$args"
            else
                alias_deletion
            fi
            ;;
        *)
            echo -e "${RED}Unknown alias command:${NC} $subcmd"
            echo "Available: alias create, alias delete <name>"
            ;;
    esac
}

alias_creation() {
    read -p "Enter alias: " alias_name
    read -p "Enter alias_command: " alias_command
    cat >>~/.enrc << EOL
${alias_name}() {
    ${alias_command}
}
EOL
    source ~/.enrc
}

alias_deletion() {

    if [ "$#" -eq 0 ]; then
        read -p "Enter the alias to be deleted: " alias_name
    else
        alias_name="$1"
    fi
    pattern="${alias_name}() {"
    escaped_pattern=$(printf '%s\n' "$pattern" | sed 's/[]\/$*.^[]/\\&/g')
    if grep -q "${pattern}" ~/.enrc; then
        # Cross-platform sed: macOS requires empty string after -i
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "/${escaped_pattern}/,/^[[:space:]]*}[[:space:]]*$/d" ~/.enrc
        else
            sed -i "/${escaped_pattern}/,/^[[:space:]]*}[[:space:]]*$/d" ~/.enrc
        fi
    else
        echo "Could not find ${alias_name}"
    fi

    source ~/.enrc
}
