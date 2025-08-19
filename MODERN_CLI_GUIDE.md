# Modern CLI Tools Quick Reference

## Tool Replacements
- **bat** → `cat` - View files with syntax highlighting
- **eza** → `ls` - List files with icons and git status  
- **fd** → `find` - Find files and directories
- **ripgrep** → `grep` - Search file contents
- **dust** → `du` - Analyze disk usage  
- **procs** → `ps` - View running processes
- **htop** → `top` - Interactive process viewer
- **zoxide** → `cd` - Smart directory navigation

## Key Features

### bat (Better cat)
```bash
bat file.py                    # View with syntax highlighting
bat -n file.py                 # Show line numbers
bat file1.py file2.py          # View multiple files
```

### eza (Better ls)
```bash
ls                             # Basic listing with icons
ll                             # Long format with git status
tree                           # Tree view
eza -la --git-ignore           # Respect .gitignore
```

### fd (Better find)
```bash
fd pattern                     # Find files matching pattern
fd -e py                       # Find Python files
fd -H pattern                  # Include hidden files
fd -x command {} \;            # Execute command on results
```

### ripgrep (Better grep)
```bash
rg pattern                     # Search for pattern
rg -i pattern                  # Case insensitive
rg -C 3 pattern                # Show 3 lines of context
rg -t py pattern               # Search only Python files
```

### zoxide (Smart cd)
```bash
z project                      # Jump to most frecent 'project' dir
zi                             # Interactive selection
z -                            # Go to previous directory
```

### fzf (Fuzzy Finder)
```bash
# Command history search
Ctrl+R                         

# File search
vim $(fzf)                     

# Process kill
kill -9 $(procs | fzf | awk '{print $1}')
```

### just (Better make)
Create a `justfile` in your project:
```
# List available commands
default:
    @just --list

# Run tests
test:
    pytest tests/

# Build and run
run: build
    ./app
```

## Useful Combinations

```bash
# Find and edit files
vim $(fd -e py | fzf)

# Search and replace
fd -e js -x sd 'old' 'new' {}

# Interactive file browsing
ll | fzf --preview 'bat --color=always {}'

# Git diff with syntax highlighting  
git diff | bat --style=numbers,changes

# Find large files
dust -n 10

# Search code and open in editor
vim $(rg -l pattern | fzf)
```

## Tips
- Most tools support `--help` for more options
- Check out each tool's GitHub page for advanced usage
- These aliases are already set up in your shell
- Original commands still available (e.g., `/bin/ls`)