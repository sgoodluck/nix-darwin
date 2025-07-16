#!/usr/bin/env bash
#
# Initialize git repository for Doom Emacs configuration

set -euo pipefail

DOOM_DIR="$HOME/.config/doom"

echo "Setting up git repository for Doom configuration..."

# Check if doom directory exists
if [ ! -d "$DOOM_DIR" ]; then
    echo "Error: Doom config directory not found at $DOOM_DIR"
    echo "Run 'nxr' first to set up the configuration"
    exit 1
fi

cd "$DOOM_DIR"

# Initialize git if not already done
if [ ! -d .git ]; then
    echo "Initializing git repository..."
    git init
    git branch -M main
    
    # Make initial commit
    git add -A
    git commit -m "Initial Doom Emacs configuration
    
- Minimal, elegant configuration
- Modus-vivendi-tinted theme
- Modern Org mode setup
- AI integration with Claude
- DAP debugging support"
    
    echo ""
    echo "Git repository initialized successfully!"
    echo ""
    echo "To add a remote repository:"
    echo "  cd $DOOM_DIR"
    echo "  git remote add origin https://github.com/YOUR_USERNAME/doom-config.git"
    echo "  git push -u origin main"
else
    echo "Git repository already exists in $DOOM_DIR"
fi

echo ""
echo "Useful aliases added to your shell:"
echo "  doom-status  - Check git status"
echo "  doom-commit  - Stage all and commit (follow with message)"
echo "  doom-push    - Push to remote"