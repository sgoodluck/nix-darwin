# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Guiding Principle

"Simplicity is the final achievement. After one has played a vast quantity of notes and more notes, it is simplicity that emerges as the crowning reward of art." 

We want simple, clear, and concise. Always evaluate to remove unneeded things and simplify wherever possible!


## Repository Overview

This is a Nix-based configuration repository for managing a macOS system (M1 MacBook Air) using Nix Darwin and Home Manager. The configuration is flake-based and combines both Nix packages and Homebrew (managed declaratively through nix-homebrew).

## Essential Commands

### System Rebuild
```bash
nxr  # Alias for: darwin-rebuild switch --flake ~/nix#sgoodluck-m1air
```

### Development Tools Available
- **Python**: black, pyflakes, isort, pytest, mypy
- **JavaScript/TypeScript**: prettier, eslint, typescript-language-server
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
- State versions: Darwin (5), Home Manager (24.11)
- TouchID enabled for sudo authentication
