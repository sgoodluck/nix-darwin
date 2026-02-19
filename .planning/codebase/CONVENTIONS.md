# Coding Conventions

**Analysis Date:** 2026-02-19

## Naming Patterns

**Files:**
- Nix modules use `default.nix` as entry points for directories: `./darwin/default.nix`, `./hosts/work/default.nix`
- Descriptive naming with concern separation: `packages.nix` (packages), `system.nix` (settings), `services.nix` (launch agents)
- Shell scripts use `.sh` extension with lowercase hyphenated names: `doom-git-init.sh`, `screenshot-capture.sh`, `vpn-status.sh`
- Home Manager configuration imports use the role name: `home.nix`

**Functions:**
- Nix functions use camelCase: `mkDarwinConfig`, `mkDerivation`, `withPackages`
- Shell functions use lowercase with underscores: `add_newline`, `rpsql`
- Functions are typically single-purpose with descriptive names

**Variables:**
- Nix variables use camelCase: `hostConfig`, `configDir`, `machineName`, `promptTheme`
- Shell variables use UPPERCASE for environment vars: `DOOM_DIR`, `SCREENSHOT_DIR`, `TIMESTAMP`
- Shell local vars use lowercase: `last_cmd`, `pgoptions`

**Types/Attributes:**
- Nix attribute sets use descriptive lowercase names: `preferences`, `gitConfig`, `hostConfig`, `dockApps`
- Configuration paths follow XDG conventions: `.config/`, `.local/bin/`

## Code Style

**Formatting:**
- Nix files use 2-space indentation consistently throughout
- Shell scripts use 2-space indentation in bash code
- Nix formatter: `nixfmt-rfc-style` (declared in common packages)

**Linting:**
- Shell linting: `shellcheck` available in environment
- No eslint/prettier configurations in repository (managed via system packages)

## Import Organization

**Order in Nix:**
1. Function parameters destructured in header: `{ pkgs, lib, config, hostConfig, ... }`
2. Let bindings for local computations
3. Configuration blocks (nested sets)
4. Imports of submodules via `imports = [ ]`

**Path Aliases:**
- No path aliases used; imports use relative paths: `../modules/common/packages.nix`, `./darwin/default.nix`
- In `home.nix`: configuration directory accessed via `builtins.toString ./.`

**Examples from codebase:**
```nix
# flake.nix - parameter destructuring
outputs =
  inputs@{
    self,
    nix-darwin,
    nixpkgs,
    home-manager,
    ...
  }:
```

```nix
# home.nix - let bindings for convenience
let
  configDir = builtins.toString ./.;
  machineName = personal.machineName;
  promptTheme = personal.preferences.promptTheme;
in
```

## Error Handling

**Patterns:**
- Shell scripts use `set -euo pipefail` for strict error handling: `#!/usr/bin/env bash` + `set -euo pipefail`
- Conditional checks before operations: `if [ ! -d "$DOOM_DIR" ]; then ... exit 1; fi`
- Error messages sent to stderr with context: `echo "Error: Doom config directory not found..." >&2`
- Early returns with helpful messages rather than silent failures

**Examples:**
```bash
# From doom-git-init.sh
if [ ! -d "$DOOM_DIR" ]; then
    echo "Error: Doom config directory not found at $DOOM_DIR" >&2
    exit 1
fi
```

```bash
# From kube-status.sh - guard clause for command existence
if command -v kubectl &> /dev/null; then
  # process
fi
```

## Logging

**Framework:** No structured logging framework; uses `echo` for user-facing messages

**Patterns:**
- Status messages to stdout: `echo "Setting up git repository..."`
- Error messages to stderr with >&2: `echo "Error: ..." >&2`
- Informational output with blank lines for readability
- Command output captured silently with redirects: `2>/dev/null`

**Examples:**
```bash
# Informational output
echo "Git repository initialized successfully!"
echo ""
echo "Useful aliases added to your shell:"

# Silent command execution
CONTEXT=$(kubectl config current-context 2>/dev/null)
AWS_PROCESS=$(pgrep -f "pattern" 2>/dev/null | head -1)
```

## Comments

**When to Comment:**
- Explain the "why" not the "how": comments describe intent and business logic
- Section headers in Nix for major configuration blocks: `# DOTFILE MANAGEMENT`, `# GIT CONFIGURATION`
- Complex operations get inline explanations
- Disabled code kept with rationale: `# Emacs daemon for fast client startup (commented out - using Zed now)`

**Style:**
- Single-line comments with `#`
- Block comments for sections with clear header format
- Each major section has header comments explaining purpose

**Examples from codebase:**
```nix
# Extract values from personal config for convenience
machineName = personal.machineName;

# Helper function to create a Darwin configuration
mkDarwinConfig = hostPath: hostName:
```

```bash
# Default to 'default' namespace if not set
NAMESPACE="${NAMESPACE:-default}"
```

## Function Design

**Size:** Functions stay compact and focused
- Nix helper functions typically 5-10 lines
- Shell functions handle single concerns

**Parameters:**
- Nix uses attribute set destructuring: `{ pkgs, lib, config, ... }`
- Shell uses getopts for option parsing: `-n NAMESPACE`, `-s SEARCH_PATH`
- Optional parameters use defaults: `hostConfig.extraPackages or []`

**Return Values:**
- Nix functions return attribute sets or lists
- Shell functions return exit codes (0 for success, 1 for failure)
- Shell functions echo output to stdout for use in command substitution: `CONTEXT=$(kubectl config current-context)`

**Examples:**
```nix
# Nix function with parameters and defaults
extraPackages = pkgs: [
  pkgs.awscli2
  # ...
];

# Using defaults
homebrew = {
  brews = hostConfig.extraBrews or [];
  casks = hostConfig.extraCasks or [];
};
```

```bash
# Shell getopts pattern for options
OPTIND=1
while getopts "s:n:" opt; do
  case $opt in
    n) NAMESPACE=${OPTARG} ;;
    s) PGOPTIONS=--search_path=${OPTARG} ;;
  esac
done
shift $((OPTIND-1))
```

## Module Design

**Exports:**
- Nix modules use attribute sets as the main export
- Home Manager configuration parameterized: `{pkgs, lib, config, personal, ...}`
- Each module focuses on one concern

**Barrel Files:**
- `default.nix` acts as module entry point when directory is imported
- Used to aggregate submodules: `imports = [ ./system.nix ./packages.nix ./services.nix ]`
- Passes arguments through: `{ config, pkgs, inputs, hostConfig, ... }`

## Configuration Injection Pattern

**Special Pattern - Host Config Injection:**
- Host-specific settings defined in `hosts/*/default.nix` as attribute sets
- Passed through flake's `specialArgs` to all modules: `_module.args.hostConfig = hostConfig`
- Makes host config available everywhere without explicit imports
- Enables single flake to manage multiple machines

**Example:**
```nix
# In hosts/personal/default.nix
{
  username = "sgoodluck";
  dockApps = [ "/Applications/Alacritty.app" ];
  preferences = { editor.default = "nvim"; };
}

# In darwin/system.nix - hostConfig is automatically available
system.primaryUser = hostConfig.username;
persistent-apps = hostConfig.dockApps or [];
```

---

*Convention analysis: 2026-02-19*
