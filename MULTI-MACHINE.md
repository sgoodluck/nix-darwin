# Multi-Machine Configuration

This Nix configuration now supports multiple machines with different settings while sharing common packages and configurations.

## Available Configurations

### Work Machine: `Seths-MacBook-Pro`
- **Username**: seth.martin@firstresonance.io
- **Email**: seth.martin@firstresonance.io
- **GitHub**: smartin-firstresonance
- **Extra packages**: zoom, slack, google-drive
- **Build command**: `nxr-work` or `darwin-rebuild switch --flake ~/nix#Seths-MacBook-Pro`

### Personal Machine: `sgoodluck-m1air`
- **Username**: sgoodluck
- **Email**: sethgoodluck@pm.me
- **GitHub**: Seth
- **Extra packages**: orcaslicer, transmission, protonvpn, proton-pass
- **Build command**: `nxr-personal` or `darwin-rebuild switch --flake ~/nix#sgoodluck-m1air`

## Directory Structure

```
nix/
├── hosts/
│   ├── work/
│   │   └── default.nix      # Work-specific configuration
│   └── personal/
│       └── default.nix      # Personal configuration
├── modules/
│   └── common/
│       └── packages.nix     # Shared packages (~90% of all packages)
├── darwin/                  # System-level Darwin configuration
├── home.nix                 # User-level home-manager configuration
└── flake.nix               # Defines both machine configurations
```

## Usage

1. **Switch to work configuration**:
   ```bash
   nxr-work
   ```

2. **Switch to personal configuration**:
   ```bash
   nxr-personal
   ```

3. **Use current machine's configuration**:
   ```bash
   nxr
   ```

## Adding New Packages

- **Common packages** (used by both): Add to `modules/common/packages.nix`
- **Work-only packages**: Add to `hosts/work/default.nix` in `extraCasks` or `extraBrews`
- **Personal-only packages**: Add to `hosts/personal/default.nix` in `extraCasks` or `extraBrews`

## Managed vs Unmanaged Apps

### Work Apps NOT Managed by Nix (Corporate IT managed):
- CrowdStrike Falcon
- Qualys Cloud Agent
- Okta Verify
- Self Service

These are provisioned by corporate IT and should not be managed through Nix.