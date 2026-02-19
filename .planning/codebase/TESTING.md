# Testing Patterns

**Analysis Date:** 2026-02-19

## Test Framework

**Framework Status:** Not detected

No traditional test framework is used in this codebase. This is a configuration repository (Nix flakes + shell scripts) where testing is implicit through successful builds and manual verification.

**Codebase Type:** Configuration Management
- Primary language: Nix (declarative configuration)
- Secondary language: Bash/Shell scripts
- No application code requiring unit tests
- Testing happens at system rebuild time

## Manual Verification Approach

**Build Verification:**
```bash
# Rebuild command (mentioned in CLAUDE.md)
nxr  # darwin-rebuild switch --flake ~/nix#sgoodluck-m1air
```

The primary test is whether `darwin-rebuild switch --flake` succeeds without errors. This validates:
- Nix flake configuration is syntactically correct
- All imports resolve properly
- Package declarations are valid
- Home Manager configuration compiles
- No circular dependencies or missing references

**Runtime Verification:**
After rebuild, manual verification includes:
- System boots and reaches login screen
- All configured packages are accessible
- Shell aliases work correctly
- Configuration files are symlinked properly
- Services (launch agents) start successfully

## Configuration-as-Code Testing Pattern

**Implicit Testing:**
- Nix evaluates the entire configuration at build time
- Type checking happens through Nix's type system
- Flake.lock provides reproducible builds (locks all dependencies)
- Home Manager validates all symlinked files exist before activation

**File Validation:**
```bash
# From home.nix - sources validate files exist at reference time
".config/nvim".source = "${configDir}/dotfiles/nvim";
".config/aerospace/aerospace.toml".source = "${configDir}/dotfiles/aerospace/aerospace.toml";
```

If a source file is missing, Home Manager activation fails with clear error message.

## Shell Script Testing

**Approach:** Shell scripts use defensive programming patterns

**Script Verification:**
```bash
# From doom-git-init.sh - validates prerequisites
if [ ! -d "$DOOM_DIR" ]; then
    echo "Error: Doom config directory not found at $DOOM_DIR"
    exit 1
fi

# From screenshot-capture.sh - handles failure gracefully
if [ -f "$SCREENSHOT_PATH" ]; then
    echo "$SCREENSHOT_PATH"
    exit 0
fi
```

**Error Handling Standard:**
```bash
# All shell scripts start with strict error handling
#!/usr/bin/env bash
set -euo pipefail
```

This ensures:
- `-e`: Exit on error
- `-u`: Error on undefined variables
- `-o pipefail`: Pipeline fails if any command fails

**Testing Tool Available:**
- `shellcheck` is installed in common packages: `modules/common/packages.nix`
- Can be used to lint scripts: `shellcheck scripts/*.sh`

## Shell Script Patterns

**Pattern: Guard Clauses**
```bash
# From kube-status.sh
if command -v kubectl &> /dev/null; then
  # only run if kubectl exists
fi

# From vpn-status.sh
AWS_PROCESS=$(pgrep -f "pattern" 2>/dev/null | head -1)
if [[ -n "$AWS_PROCESS" ]]; then
  # process
fi
```

**Pattern: Explicit Variable Assignment**
```bash
# From rpsql function in hosts/work/default.nix
NAMESPACE="ion"  # default if none provided
OPTIND=1         # Reset in case getopts used previously
```

**Pattern: Safe Output Capture**
```bash
# From screenshot-capture.sh
if [ -f "$SCREENSHOT_PATH" ]; then
    echo "$SCREENSHOT_PATH"
    exit 0
fi
```

## No Formal Testing Infrastructure

**Why No Tests Are Present:**
1. **Configuration Repository:** Nix configurations are declarative; validity is checked at build time
2. **Single User:** Personal system configuration with manual verification
3. **System-Level Code:** Testing through actual system rebuild and manual use
4. **Script Simplicity:** Shell scripts are short, focused utilities with defensive programming

**Validation Instead of Testing:**
- Nix flake lock provides reproducibility
- Home Manager validates file sources before symlinking
- darwin-rebuild provides clear feedback on errors
- Manual verification after successful rebuild

## Build and Rebuild

**Primary Build Command:**
```bash
# From CLAUDE.md
nxr  # Alias for: darwin-rebuild switch --flake ~/nix#sgoodluck-m1air

# Explicit form
darwin-rebuild switch --flake ~/nix#sgoodluck-m1air

# For work machine
darwin-rebuild switch --flake ~/nix#Seths-MacBook-Pro
```

**What Happens on Rebuild:**
1. Nix evaluates all flake inputs (nixpkgs, home-manager, etc.)
2. Builds closure of all configured packages
3. Home Manager evaluates and validates all dotfile configurations
4. Applies configuration to system
5. Creates symlinks for all configured dotfiles
6. Applies macOS system preferences
7. Returns clear error if anything fails

## Configuration Validation Points

**Flake Evaluation:**
- `flake.nix` syntax validation
- Input URL resolution
- Output definitions validation

**Host Configuration:**
- `hosts/work/default.nix` and `hosts/personal/default.nix` must provide required attributes:
  - `username`
  - `dockApps`
  - `preferences`
  - `gitConfig`

**Module Composition:**
- All imported modules must have valid Nix syntax
- Dependencies between modules resolved correctly
- No circular imports

**Example from home.nix:**
```nix
# Nix validates this file exists before symlinking
".config/doom/init.el".source = "${configDir}/dotfiles/doom/init.el";

# If file missing, activation fails with clear error
```

## Coverage

**Requirements:** Not enforced (configuration repository)

**Implicit Coverage:**
- All code paths exercised at rebuild time
- System must be fully functional after rebuild to declare success
- Manual testing through use of configured system

## Test Data and Fixtures

**Not Applicable:** Configuration repository has no test data needs

**Real Configuration Used:**
- Actual dotfiles in `dotfiles/` are sources
- Real package lists are evaluated
- Real system preferences are applied
- No mock data; system uses real configuration

## Continuous Verification

**Git Integration:**
- `.gitignore` prevents accidental commits of secrets
- Configuration is version controlled
- Can revert to previous configurations via git history
- Build reproducibility through `flake.lock`

**Manual Verification Checklist:**
After successful rebuild:
- [ ] System boots normally
- [ ] Shell aliases (`nxr`, `doom-commit`, etc.) work
- [ ] All applications launch successfully
- [ ] SSH/Git signing configured
- [ ] Prompt theme displays correctly
- [ ] Kubernetes tools (if work machine) function
- [ ] dotfile symlinks point to correct locations

---

*Testing analysis: 2026-02-19*
