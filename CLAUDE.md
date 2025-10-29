# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a Nix-based configuration repository for managing macOS systems using Nix Darwin and Home Manager. The configuration is flake-based, supports multiple machines (work and personal), and combines both Nix packages and Homebrew (managed declaratively through nix-homebrew).

## Essential Commands

### System Rebuild
```bash
# For personal machine:
nxr  # Alias for: darwin-rebuild switch --flake ~/nix#sgoodluck-m1air

# For work machine:
darwin-rebuild switch --flake ~/nix#Seths-MacBook-Pro
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

1. **`flake.nix`**: Entry point defining inputs (nixpkgs 25.05 Darwin branch, nix-darwin, home-manager, nix-homebrew, mac-app-util) and system configuration
2. **`hosts/`**: Machine-specific configurations
   - `personal/default.nix`: Personal M1 MacBook Air (sgoodluck-m1air)
   - `work/default.nix`: Work MacBook Pro (Seths-MacBook-Pro)
3. **`modules/common/`**: Shared configurations across all machines
   - `packages.nix`: Common package sets (dev tools, languages, utilities)
4. **`home.nix`**: User-level configurations including dotfile symlinks, shell configuration, and aliases
5. **`darwin/`**: macOS system configuration
   - `default.nix`: Module entry point
   - `system.nix`: System settings, fonts, launch agents
   - `packages.nix`: Package management integration (merges common + host-specific)
   - `services.nix`: Service configurations
6. **`dotfiles/`**: Application configurations (aerospace, doom emacs, nvim, karabiner, etc.)

## Key Patterns

- **Flake-based**: Uses flakes with locked dependencies for reproducibility
- **Multi-machine Support**: Single repository manages both work and personal machines with host-specific configurations
- **Hybrid Package Management**: Combines Nix packages with Homebrew casks/brews managed declaratively
- **Configuration Injection**: Host settings from `hosts/*/default.nix` are available to all modules via `hostConfig`
- **Modular Design**: Common packages/settings in `modules/common/`, extended by host-specific configurations
- **Dotfile Management**: Configurations in `dotfiles/` are symlinked to expected locations via Home Manager
- **Launch Agents**: Services like Aerospace and Emacs daemon are managed through launchd

## Development Notes

- Default editor: nvim (terminal), emacs (GUI applications)
- Shell: zsh with oh-my-posh prompt (zen theme)
- Terminal: Alacritty
- Window Manager: Aerospace (i3-inspired tiling WM)
- State versions: Darwin (5), Home Manager (25.05)
- TouchID enabled for sudo authentication
- Emacs installed via Homebrew emacs-plus with: ctags, mailutils, xwidgets, imagemagick
- Custom PATH includes: `~/.config/emacs/bin`, `/opt/homebrew/bin`, `/opt/homebrew/opt/llvm/bin`
- Claude Code available as a Nix package

## Host-Specific Packages

### Work Machine (Seths-MacBook-Pro)
- Communication: Zoom, Slack
- Cloud: Google Drive
- Common dev tools + work-specific utilities

### Personal Machine (sgoodluck-m1air)
- Creative: OrcaSlicer (3D printing)
- Privacy: ProtonVPN, Proton Pass
- Utilities: Transmission
- Common dev tools + personal utilities
