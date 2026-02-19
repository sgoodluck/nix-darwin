# Architecture

**Analysis Date:** 2026-02-19

## Pattern Overview

**Overall:** Declarative Infrastructure-as-Code (IaC) using Nix Flakes

This is a system configuration repository that manages macOS machines (work and personal) using Nix Darwin and Home Manager. The architecture follows a modular, composable approach where configuration is declaratively defined and reproducibly built. All system state (packages, settings, dotfiles, services) flows from Nix expressions that compose into a final system configuration.

**Key Characteristics:**
- Flake-based for lock-file guarantees and reproducible outputs
- Multi-machine support from single configuration repository
- Hybrid package management (Nix packages + declarative Homebrew)
- Configuration injection pattern to expose host settings everywhere
- Declarative service and dotfile management
- Layered module composition for reusable configs

## Layers

**Flake Output Layer (`flake.nix`):**
- Purpose: Define inputs (nixpkgs, nix-darwin, home-manager, etc.), create configuration factory, export system definitions
- Location: `flake.nix`
- Contains: Input definitions, `mkDarwinConfig` helper function, Darwin system instantiation
- Depends on: All downstream modules via composition
- Used by: nix-darwin to build system, deployed via `darwin-rebuild switch`

**Host Configuration Layer (`hosts/*/`):**
- Purpose: Machine-specific identity, package sets, and preferences
- Location: `hosts/personal/default.nix`, `hosts/work/default.nix`
- Contains: Username, fullName, email, GPG key, dock apps, host-specific packages, shell functions, aliases
- Depends on: Nothing (pure data)
- Used by: Darwin system modules via `hostConfig` special arg, Home Manager modules

**Darwin System Layer (`darwin/`):**
- Purpose: macOS system configuration (settings, packages, services)
- Location: `darwin/default.nix`, `darwin/system.nix`, `darwin/packages.nix`, `darwin/services.nix`
- Contains: System preferences (dock, finder, screencapture), font definitions, Homebrew configuration, launch agents
- Depends on: Host configuration (`hostConfig`), nixpkgs
- Used by: nix-darwin to configure `/nix/store` and system defaults

**Common Packages Layer (`modules/common/`):**
- Purpose: Shared development tools and utilities across all machines
- Location: `modules/common/packages.nix`
- Contains: Nix packages (git, neovim, development tools, CLI replacements), Homebrew formula/cask definitions
- Depends on: nixpkgs
- Used by: `darwin/packages.nix` which imports it

**Home Manager Layer (`home.nix`):**
- Purpose: User-level configuration (dotfile symlinks, shell setup, programs)
- Location: `home.nix`
- Contains: File symlinks from `dotfiles/` to `~/.config/`, Git config, SSH config, Zsh config with aliases and functions
- Depends on: Host configuration (`personal`), dotfiles directory
- Used by: nix-darwin's home-manager integration to configure user environment

**Dotfiles Layer (`dotfiles/`):**
- Purpose: Application configuration files (source of truth for tool configs)
- Location: `dotfiles/` (aerospace, alacritty, karabiner, doom, nvim, zed, zellij, lazygit, etc.)
- Contains: TOML, JSON, Lua, ELisp, KDL configuration files for various tools
- Depends on: Nothing
- Used by: Home Manager symlinks these to `~/.config/`

**Scripts Layer (`scripts/`):**
- Purpose: Executable scripts for utilities and helpers
- Location: `scripts/` (prompt helpers, Claude Code integrations, Doom git management)
- Contains: Bash/Shell scripts for vpn-status, venv-status, aws-profile-status, kube-status, doom-git-init, screenshot capture
- Depends on: External tools (kubectl, aws, etc.)
- Used by: Home Manager adds to `~/.local/bin/`, referenced in shell aliases and dotfiles

## Data Flow

**System Configuration Bootstrap:**

1. User runs `darwin-rebuild switch --flake ~/nix#sgoodluck-m1air`
2. nix-darwin evaluates `flake.nix` → calls `mkDarwinConfig ./hosts/personal "sgoodluck-m1air"`
3. Host config loaded: `hosts/personal/default.nix` → provides `hostConfig` with username, packages, preferences
4. `flake.nix` injects `hostConfig` via `_module.args.hostConfig` making it available to all Darwin and Home Manager modules
5. Darwin modules compose:
   - `darwin/system.nix` → System preferences (dock apps from `hostConfig.dockApps`)
   - `darwin/packages.nix` → Common packages imported + host-specific packages/brews/casks
   - `darwin/services.nix` → Launch agents (currently minimal)
6. Home Manager evaluates `home.nix` with `hostConfig` available:
   - Symlinks dotfiles from `dotfiles/` → `~/.config/`
   - Configures Git with `hostConfig.gitConfig`
   - Sets up SSH with static matchBlocks
   - Configures Zsh with `hostConfig.preferences` and `hostConfig.extraAliases`
   - Adds scripts to PATH at `~/.local/bin/`
7. All packages and dotfiles deployed to system
8. Launch agents start (none currently active, Emacs daemon commented out)

**State Management:**

- **System State**: Stored in `/nix/store/`, Nix manages via generational symlinks
- **User State**: Managed by Home Manager in `~/.nix-profile/`, symlinks created via `home.nix`
- **Version Control**: `flake.lock` pins all inputs for reproducibility
- **Config Overrides**: Dotfiles in `dotfiles/` are source of truth, symlinked to standard locations
- **Host Customization**: `hosts/*/default.nix` captures all machine-specific configuration

## Key Abstractions

**HostConfig Object:**
- Purpose: Single source of truth for machine identity and preferences
- Examples: `hosts/personal/default.nix` (11 top-level attributes), `hosts/work/default.nix` (11 top-level attributes)
- Pattern: Plain Nix attribute set with username, email, githubUsername, dockApps, extraPackages, extraBrews, extraCasks, extraAliases, extraShellInit, preferences
- Usage: Injected into all modules via specialArgs, allows conditional logic (e.g., `hostConfig.extraPackages or []`)

**Module Composition:**
- Purpose: Combine features from multiple files into final config
- Examples: `darwin/default.nix` imports `system.nix`, `packages.nix`, `services.nix`; `home.nix` defines all user-level features
- Pattern: Nix modules with explicit imports, each module adds to option sets
- Usage: Allows splitting large configs into concerns without duplication

**Configuration Injection via specialArgs:**
- Purpose: Make host-specific data available to modules without explicit imports
- Pattern: In `flake.nix`, inject `hostConfig` and `inputs` as special arguments to nix-darwin modules
- Usage: All modules can access `hostConfig` and `inputs` without circular dependencies

**Dotfile Symlink Pattern:**
- Purpose: Keep tool configs in git repository, symlinked to standard locations
- Examples: `.config/aerospace/aerospace.toml` (actual: `dotfiles/aerospace/aerospace.toml`)
- Pattern: Home Manager `home.file` entries with `.source` pointing to dotfiles directory
- Usage: Allows version control of configs, easy rollback, single source of truth

## Entry Points

**System Initialization (`flake.nix`):**
- Location: `/Users/sgoodluck/nix/flake.nix`
- Triggers: `darwin-rebuild switch --flake ~/nix#<machine-name>`
- Responsibilities: Define inputs, create Darwin systems for both machines, inject host configs, compose all modules

**Host Configurations (`hosts/*/default.nix`):**
- Location: `hosts/personal/default.nix`, `hosts/work/default.nix`
- Triggers: Loaded by `mkDarwinConfig` helper
- Responsibilities: Provide machine identity, custom packages, dock configuration, shell aliases/functions

**Darwin System (`darwin/default.nix`):**
- Location: `darwin/default.nix`
- Triggers: Loaded by nix-darwin module system
- Responsibilities: Import darwin submodules (system, packages, services), aggregate into system config

**Home Manager (`home.nix`):**
- Location: `home.nix`
- Triggers: Loaded by nix-darwin's home-manager integration
- Responsibilities: Configure user-level settings, symlink dotfiles, set up programs (git, ssh, zsh)

**System Activation (`darwin/system.nix`):**
- Location: `darwin/system.nix`
- Triggers: Each `darwin-rebuild switch`
- Responsibilities: Run activation scripts (Claude settings initialization), configure system preferences, install fonts

## Error Handling

**Strategy:** Fail-safe via Nix evaluation errors and module conflicts

**Patterns:**
- **Type Safety**: Nix's type system catches misconfigurations at evaluation time (e.g., wrong attribute types)
- **Module Conflicts**: nix-darwin's module system prevents conflicting option values with clear error messages
- **Missing Optional Values**: Use `or` operator for optional host config values (e.g., `hostConfig.extraPackages or []`, `hostConfig.extraAliases or {}`)
- **Activation Scripts**: System activation scripts use bash error handling for config migrations (Claude settings initialization)
- **No Runtime Errors**: Most errors caught at build time via Nix evaluation; runtime issues are configuration-related (missing env vars, permission problems)

## Cross-Cutting Concerns

**Logging:** No structured logging framework. System configuration happens at build time; Nix reports all evaluation and build output to stdout/stderr.

**Validation:** Nix's type system validates configuration at evaluation time. hostConfig must have required attributes (username, machineName, etc.) or evaluation fails with clear errors.

**Authentication:**
- Git: SSH key-based (`~/.ssh/id_ed25519`), configured via `home.nix` programs.git
- GPG: GPG key IDs stored in `hostConfig.gpgKey`, used for commit signing
- Sudoers: TouchID enabled via `security.pam.services.sudo_local.touchIdAuth = true` in `darwin/system.nix`
- Environment Secrets: Not handled in Nix; use `.authinfo.gpg` template in `dotfiles/doom/`

---

*Architecture analysis: 2026-02-19*
