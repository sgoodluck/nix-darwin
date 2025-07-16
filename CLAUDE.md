# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Nix-based configuration repository for managing a macOS system (M1 MacBook Air) using Nix Darwin and Home Manager. The configuration is flake-based and combines both Nix packages and Homebrew (managed declaratively through nix-homebrew).

## Essential Commands

### System Rebuild
```bash
nxr  # Alias for: darwin-rebuild switch --flake ~/nix#sgoodluck-m1air
```

### Doom Emacs Git Management
```bash
doom-commit "message"  # Stage all changes and commit
doom-push             # Push to remote repository  
doom-status           # Check git status of Doom config
doom-git-init         # Initialize git repo for Doom config
```

### Development Tools Available
- **Python**: black, pyflakes, isort, pytest, mypy, debugpy
- **JavaScript/TypeScript**: prettier, eslint, typescript-language-server, vscode-js-debug
- **Go**: gopls, golangci-lint, delve
- **Nix**: nixfmt-rfc-style
- **Shell**: shellcheck, shfmt

## Architecture

The repository follows a modular structure with clear separation of concerns:

1. **`flake.nix`**: Entry point defining inputs (nixpkgs, nix-darwin, home-manager, nix-homebrew, mac-app-util) and system configuration
2. **`personal.nix`**: User-specific settings (username, email, editor preferences) injected into all modules via `_module.args.personal`
3. **`home.nix`**: User-level configurations including dotfile symlinks, shell configuration, and aliases
4. **`darwin/`**: macOS system configuration
   - `default.nix`: Module entry point
   - `system.nix`: System settings, fonts, launch agents
   - `packages.nix`: Package management (Nix + Homebrew)
   - `services.nix`: Service configurations (currently empty)
5. **`dotfiles/`**: Application configurations (amethyst, doom emacs, nvim, karabiner, etc.)

## Key Patterns

- **Flake-based**: Uses flakes with locked dependencies for reproducibility
- **Hybrid Package Management**: Combines Nix packages with Homebrew casks/brews managed declaratively
- **Configuration Injection**: Personal settings from `personal.nix` are available to all modules
- **Dotfile Management**: Configurations in `dotfiles/` are symlinked to expected locations via Home Manager
- **Launch Agents**: Services like Amethyst and Emacs daemon are managed through launchd

## Development Notes

- Default editor: nvim (terminal), emacs (GUI applications)
- Shell: zsh with oh-my-posh prompt
- State versions: Darwin (5), Home Manager (25.05)
- TouchID enabled for sudo authentication
- Emacs installed via Homebrew with: ctags, mailutils, xwidgets, imagemagick
- Custom PATH includes: `~/.config/emacs/bin`, `/opt/homebrew/bin`, `/opt/homebrew/opt/llvm/bin`
