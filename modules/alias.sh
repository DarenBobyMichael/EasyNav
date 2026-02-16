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
        list)
            alias_list
            ;;
        *)
            echo -e "${RED}Unknown alias command:${NC} $subcmd"
            echo "Available commands:"
            echo "  alias create        - Create a new alias"
            echo "  alias delete <name> - Delete an alias"
            echo "  alias list          - List all aliases"
            ;;
    esac
}

alias_creation() {
    echo -e "${CYAN}Creating new alias${NC}"
    read -p "Enter alias name: " alias_name

    echo -e "${CYAN}Enter command${NC} (use \$1, \$2 for arguments, or \$@ for all arguments)"
    echo -e "${CYAN}Example:${NC} cd \"\$1\" && ls    ${CYAN}or${NC}    echo \"Args: \$@\""
    read -p "Command: " alias_command

    # Validate command is not empty
    if [[ -z "$alias_command" ]]; then
        echo -e "${RED}Error:${NC} Command cannot be empty"
        return 1
    fi

    # Create the function in .enrc
    cat >>~/.enrc << EOL
${alias_name}() {
    ${alias_command}
}
EOL

    source ~/.enrc
    echo -e "${GREEN}✓${NC} Alias '${alias_name}' created successfully"

    # Show usage example if arguments are detected
    if [[ "$alias_command" =~ \$[0-9@*] ]]; then
        echo -e "${CYAN}Usage:${NC} ${alias_name} <arguments>"
    fi
}

alias_deletion() {
    if [ "$#" -eq 0 ]; then
        read -p "Enter the alias to be deleted: " alias_name
    else
        alias_name="$1"
    fi

    # Validate alias name is not empty
    if [[ -z "$alias_name" ]]; then
        echo -e "${RED}Error:${NC} Alias name cannot be empty"
        return 1
    fi

    pattern="${alias_name}() {"
    escaped_pattern=$(printf '%s\n' "$pattern" | sed 's/[]\/$*.^[]/\\&/g')

    if grep -q "${pattern}" ~/.enrc 2>/dev/null; then
        # Cross-platform sed: macOS requires empty string after -i
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "/${escaped_pattern}/,/^[[:space:]]*}[[:space:]]*$/d" ~/.enrc
        else
            sed -i "/${escaped_pattern}/,/^[[:space:]]*}[[:space:]]*$/d" ~/.enrc
        fi
        echo -e "${GREEN}✓${NC} Alias '${alias_name}' deleted successfully"
    else
        echo -e "${RED}Error:${NC} Could not find alias '${alias_name}'"
        return 1
    fi

    source ~/.enrc
}

alias_list() {
    if [[ ! -f ~/.enrc ]]; then
        echo -e "${YELLOW}No aliases defined yet${NC}"
        echo "Use 'alias create' to create your first alias"
        return
    fi

    echo -e "${CYAN}Defined aliases:${NC}\n"

    # Extract and display function definitions
    local in_function=0
    local func_name=""
    local func_body=""

    while IFS= read -r line; do
        # Skip comments and empty lines
        if [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "$line" ]]; then
            continue
        fi

        # Function start
        if [[ "$line" =~ ^([a-zA-Z_][a-zA-Z0-9_]*)\(\)[[:space:]]*\{ ]]; then
            func_name="${BASH_REMATCH[1]}"
            in_function=1
            func_body=""
        # Function body
        elif [[ $in_function -eq 1 ]]; then
            if [[ "$line" =~ ^[[:space:]]*\}[[:space:]]*$ ]]; then
                # Function end - display it
                echo -e "${GREEN}${func_name}${NC}"
                echo -e "  ${func_body}"
                echo ""
                in_function=0
            else
                # Accumulate function body
                func_body="${func_body}${line}\n"
            fi
        fi
    done < ~/.enrc

    if [[ -z "$func_name" ]]; then
        echo -e "${YELLOW}No aliases found in ~/.enrc${NC}"
    fi
}
