# EasyNav

An interactive shell with modular architecture, visual theming, alias management, and command history — built entirely in Bash.

## Features

- **Modular design** — drop a `.sh` file into `modules/` and it's auto-discovered
- **Visual theming** — customize prompt colors, symbols, and apply preset themes
- **Alias system** — create parameterized command shortcuts persisted across sessions
- **Command history** — search, analyze, and manage your command history
- **Quote validation** — prevents broken commands from malformed input
- **Cross-platform** — works on Linux, macOS, and Windows (WSL/Git Bash)

## Quick Start

```bash
git clone https://github.com/DarenBobyMichael/EasyNav.git
cd EasyNav
bash master.sh
```

On first launch, EasyNav creates `~/.enrc` (settings/aliases) and `~/.en_history` (command log) automatically.

## Usage

Once running, you'll see a directory box and prompt:

```
╭──────────────────────────────╮
│  ✪  ~/projects/EasyNav
╰──────────────────────────────╯

>>
```

Type any shell command as normal — EasyNav executes it and captures output. Module commands like `visual`, `alias`, and `history` are intercepted and handled by their respective modules.

### Built-in Commands

| Command | Description |
|---------|-------------|
| `cd <path>` | Change directory (re-renders directory box) |
| `clear` | Clear screen |

---

## Modules

### Visual

Customize the look and feel of EasyNav.

```bash
visual                          # Show current settings with preview
visual prompt-color <color>     # Set prompt color
visual prompt-symbol <symbol>   # Set prompt symbol (default: >>)
visual dir-color <color>        # Set directory box color
visual dir-symbol <symbol>      # Set directory icon (default: ✪)
visual theme <name>             # Apply a preset theme
visual reset                    # Reset to defaults
```

**Available colors:** red, green, yellow, blue, magenta, cyan, white

**Themes:**

| Theme | Prompt | Dir Box | Style |
|-------|--------|---------|-------|
| `default` | `>>` red | red / ✪ | Classic |
| `ocean` | `~~` cyan | blue / ⚓ | Cool tones |
| `forest` | 🌿 green | green / 🌲 | Natural |
| `sunset` | ☀ yellow | magenta / ✦ | Warm |
| `minimal` | `$` white | white / → | Clean |

### Alias

Create persistent command shortcuts with argument support.

```bash
alias create              # Interactive alias creation
alias delete <name>       # Delete an alias
alias list                # List all aliases
```

Aliases support positional arguments (`$1`, `$2`) and all-args (`$@`):

```
>> alias create
Enter alias name: proj
Command: cd "$1" && ls
✓ Alias 'proj' created successfully
Usage: proj <arguments>

>> proj ~/projects
```

### History

View, search, and manage command history.

```bash
history                   # Show last 20 commands
history search <term>     # Search history (case-insensitive)
history top               # Show 10 most-used commands
history clear             # Clear history (with confirmation)
```

---

## Project Structure

```
EasyNav/
├── master.sh                # Entry point, core loop, command dispatch
└── modules/
    ├── module_master.sh     # Auto-discovers and sources all modules
    ├── visual.sh            # Theming and visual customization
    ├── alias.sh             # Alias creation and management
    └── history.sh           # Command history and search
```

**Config files** (in home directory):
- `~/.enrc` — visual settings and alias definitions
- `~/.en_history` — command history log

## Creating a Module

Add a new `.sh` file to `modules/` with a handler function following the `en_<command>` naming convention:

```bash
#!/bin/bash
# modules/greet.sh

en_greet() {
    local full_cmd="$1"
    local name="${full_cmd#greet }"
    echo "Hello, ${name}!"
}
```

That's it — `module_master.sh` auto-discovers it on the next launch. Users can then run:

```
>> greet world
Hello, world!
```

## Requirements

- Bash 4+ (for associative arrays)
- Standard Unix utilities: `sed`, `grep`, `sort`, `uniq`, `awk`, `nl`
