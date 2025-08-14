# Nix Darwin Configuration

A clean, well-organized Nix configuration for macOS using Nix Darwin, Home Manager, and declarative Homebrew management.

## Overview

This repository contains a complete system configuration for macOS (M1 MacBook Air) that manages:

- System-level settings and preferences
- Package installation (both Nix and Homebrew)
- User dotfiles and shell configuration
- Font management
- Application launchers (Amethyst, Emacs daemon)

## Quick Start

### Prerequisites

1. Install Nix using the [Determinate Systems installer](https://zero-to-nix.com/start/install)
2. Ensure you have Command Line Tools installed: `xcode-select --install`

### Initial Setup

1. Clone this repository:
   ```bash
   git clone <repository-url> ~/nix
   cd ~/nix
   ```

2. Build and activate the configuration:
   ```bash
   darwin-rebuild switch --flake ~/nix#<machine-name>
   ```

### Daily Usage

After initial setup, use the `nxr` alias to rebuild:

```bash
nxr  # Rebuilds the system configuration
```

## Repository Structure

```
.
├── flake.nix           # Entry point - defines inputs and system configuration
├── flake.lock          # Locked dependencies for reproducibility
├── hosts/              # Machine-specific configurations
│   ├── personal/       # Personal machine settings
│   └── work/           # Work machine settings
├── home.nix            # Home Manager configuration (dotfiles, shell, user programs)
├── darwin/             # macOS system configuration
│   ├── default.nix     # Module entry point
│   ├── system.nix      # System settings, fonts, launch agents
│   └── packages.nix    # Package declarations (Nix + Homebrew)
├── dotfiles/           # Configuration files symlinked to ~/.config/
└── CLAUDE.md           # AI assistant instructions

```

## Key Features

### Hybrid Package Management

This configuration uses both Nix and Homebrew:

- **Nix packages**: Development tools, compilers, language servers
- **Homebrew brews**: CLI tools not available in Nix
- **Homebrew casks**: GUI applications

### Machine-Specific Configuration

Each machine has its own configuration in the `hosts/` directory:
- `hosts/personal/default.nix`: Personal machine settings (username, email, packages)
- `hosts/work/default.nix`: Work machine settings with work-specific tools

This structure allows you to:
- Manage multiple machines with different identities and packages
- Keep work and personal configurations separate
- Share common settings while customizing per-machine needs

### Automatic Setup

The configuration automatically:
- Installs and configures all specified packages
- Sets up dotfile symlinks
- Configures macOS system preferences
- Starts services (Amethyst window manager, Emacs daemon)
- Manages Homebrew taps and packages declaratively

## Customization

### Adding Packages

1. **Nix packages**: Edit `darwin/packages.nix`, add to `environment.systemPackages`
2. **Homebrew CLI tools**: Add to the `brews` list in `darwin/packages.nix`
3. **GUI applications**: Add to the `casks` list in `darwin/packages.nix`

### Adding Dotfiles

1. Place your configuration file in the `dotfiles/` directory
2. Add a symlink entry in `home.nix` under `home.file`

### Modifying System Settings

Edit `darwin/system.nix` to change:
- Dock preferences
- Finder settings
- Keyboard behavior
- Launch agents

## Troubleshooting

### Rebuild Failures

If `nxr` fails:

1. Check for syntax errors: `nix flake check`
2. Ensure all files are tracked by git: `git add .`
3. Try with verbose output: `darwin-rebuild switch --flake ~/nix#<machine-name> --show-trace`

### Homebrew Issues

If Homebrew packages fail to install:

1. Ensure Homebrew is in PATH: `/opt/homebrew/bin/brew`
2. Manually update Homebrew: `brew update`
3. Check for conflicts: `brew doctor`

## Philosophy

"Simplicity is the final achievement." - This configuration aims to be:

- **Simple**: Clear structure, minimal complexity
- **Declarative**: Entire system defined in code
- **Reproducible**: Same configuration yields same result
- **Maintainable**: Well-documented and organized