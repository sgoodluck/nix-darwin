# Technology Stack

**Analysis Date:** 2026-02-19

## Languages

**Primary:**
- Nix - System configuration and package management
- Shell (Zsh) - Interactive shell and scripting
- Markdown - Documentation and configuration files

**Secondary:**
- Python - Development tooling (black, pyflakes, isort, pytest, mypy, debugpy)
- JavaScript/TypeScript - Development tooling and Node.js projects (TypeScript, ESLint, Prettier)
- Go - Development environment and language server (gopls, delve, golangci-lint)
- Rust - Development environment (rustc, cargo)
- Emacs Lisp - Doom Emacs configuration (`dotfiles/doom/init.el`, `dotfiles/doom/config.el`)

## Runtime

**Environment:**
- macOS (aarch64-darwin) - M1/M2 Apple Silicon architecture
- Nix - Package manager and OS configuration framework

**Package Managers:**
- Nix - Primary package manager for reproducible builds
- Homebrew - Supplementary package manager for casks and taps (managed declaratively via nix-homebrew)
- PNPM - Fast Node.js package manager
- FNM/NVM - Node.js version management
- Poetry - Python dependency management and packaging
- UV - Fast Python package installer and resolver
- Cargo - Rust package manager and build system

## Frameworks

**Core Infrastructure:**
- Nix Darwin - macOS system configuration framework
- Home Manager - User-level package and dotfile management
- nix-homebrew - Declarative Homebrew package management
- mac-app-util - Create .app bundles for Nix GUI applications

**Development Environments:**
- Node.js - JavaScript runtime
- Python 3 - Python runtime with language server
- Go - Go programming language
- Rust - Rust programming language

**Terminal & Shell:**
- Oh-My-Posh - Cross-platform prompt theme engine
- Zoxide - Smart directory navigation
- Zellij - Terminal multiplexer

**Editors/IDEs:**
- Neovim - Terminal text editor with Nix configuration (`dotfiles/nvim`)
- Doom Emacs - Extensible editor with custom configuration (`dotfiles/doom/`)
- Zed - GUI text editor
- VS Code - Code editor (symlinked settings via `dotfiles/vscode/settings.json`)
- Cursor - AI-powered code editor (work machine)

**Development Tools:**
- GNU Make - Build automation
- CMake - Cross-platform build system
- Ninja - Build system focused on speed
- Bear - Compilation database generation
- CCLS - C/C++/Objective-C language server

**Testing:**
- Pytest - Python testing framework
- Go testing - Go built-in testing

**Build/Dev:**
- Cocogitto - Conventional commits validation
- Just - Modern make alternative
- Direnv - Environment switching per directory

## Key Dependencies

**Critical:**
- Git 2.x - Version control system
- GPG/pinentry_mac - Encryption and commit signing with macOS GUI
- Nixpkgs 25.05-darwin - Core package set from NixOS/nixpkgs stable branch
- Nix Darwin 25.05 - macOS system management
- Home Manager 25.05 - User-level configuration

**Development Tools:**
- Lazygit - Git client UI
- Ripgrep (rg) - Fast text search
- FD - Fast file finder
- EZA - Modern ls replacement
- BAT - Syntax-highlighted cat
- FZF - Fuzzy finder
- Dust - Disk usage analyzer
- PROCS - Modern process viewer
- HTOP - Interactive process monitoring
- JQ - JSON processor
- YQ - YAML processor

**Infrastructure:**
- Kubectl - Kubernetes CLI
- Kubectx - Cluster/namespace switching
- K9s - Kubernetes terminal UI
- Stern - Multi-pod log tailing
- kube-ps1 - Kubernetes prompt helper

**Cloud & Integration Tools (Work Machine):**
- AWS CLI v2 - Amazon Web Services command-line interface
- PostgreSQL 16 - Relational database (work machine)
- Prismatic CLI (v7.10.0) - Integration platform CLI (`hosts/work/default.nix` lines 35-65)
- AWS VPN Client - AWS VPN connectivity

**Creative & Utilities:**
- GIMP - Image manipulation
- FFMPEG - Multimedia framework
- Hugo - Static site generator
- Postman - API testing

## Configuration

**Environment:**
- Configuration managed declaratively via Nix flakes
- Host-specific settings injected through `hostConfig` passed to all modules
- Environment variables set in `home.nix` lines 179-196 (sessionVariables, envExtra)
- SSH keys managed via Home Manager (`home.nix` lines 103-132)
- GPG configured for commit signing via `home.nix` lines 88-91

**Build:**
- Entry point: `flake.nix` - Defines inputs, outputs, and system configurations
- Dependency lock: `flake.lock` - Locked versions for reproducibility
- Darwin modules: `darwin/default.nix`, `darwin/system.nix`, `darwin/packages.nix`, `darwin/services.nix`
- Home Manager configuration: `home.nix`
- Host-specific configs: `hosts/personal/default.nix`, `hosts/work/default.nix`
- Module structure: Common packages in `modules/common/packages.nix`, host-specific extensions in `hosts/*/default.nix`

**Homebrew Taps:**
- homebrew/homebrew-bundle - Homebrew package management
- d12frosted/homebrew-emacs-plus - Enhanced Emacs build with ctags, mailutils, xwidgets, imagemagick
- nikitabobko/homebrew-aerospace - i3-inspired tiling window manager
- supabase/homebrew-tap - Supabase CLI (personal machine only)

## Platform Requirements

**Development:**
- macOS 11+ (aarch64-darwin - Apple Silicon M1/M2)
- Nix with flakes support (installed via Determinate Systems installer)
- Xcode Command Line Tools: `xcode-select --install`
- Git 2.x for flake operations

**Production:**
- Deployment target: macOS Darwin systems
- No server/containerized deployment (system configuration only)

**Machines Supported:**
1. `sgoodluck-m1air` - Personal M1 MacBook Air
2. `Seths-MacBook-Pro` - Work MacBook Pro

---

*Stack analysis: 2026-02-19*
