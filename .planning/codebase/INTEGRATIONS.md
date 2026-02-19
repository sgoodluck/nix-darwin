# External Integrations

**Analysis Date:** 2026-02-19

## APIs & External Services

**Cloud Platforms:**
- AWS - Amazon Web Services integration
  - SDK/Client: AWS CLI v2 (work machine)
  - Auth: Environment-based credentials expected
  - Usage: Infrastructure management and development

- Prismatic - Integration platform
  - SDK/Client: Prismatic CLI v7.10.0 (work machine, `hosts/work/default.nix` lines 35-65)
  - Purpose: Build, deploy, and manage integrations

- Supabase - Backend-as-a-service platform
  - SDK/Client: Supabase CLI via `homebrew-supabase` tap (personal machine)
  - Purpose: Backend development, database, auth, real-time, storage
  - Port forwarding configured in SSH config for local development (`home.nix` lines 119-129)

**Remote Access & VPN:**
- Tailscale - Private network connectivity
  - Used for remote machine access via IP 100.89.94.46 in SSH config (`home.nix` line 117)
  - SSH forwarding configured for home server services via ports 54321-54329

- ProtonVPN - VPN service (personal machine)
  - Purpose: Privacy and network encryption
  - Installed as cask

**Communication:**
- GitHub - Code repository hosting and CI/CD
  - SDK/Client: GitHub CLI (gh) in `modules/common/packages.nix` line 54
  - Auth: SSH key-based authentication configured (`home.nix` lines 111-115)
  - Identity: Work and personal GitHub accounts configured per machine

- Superhuman - Email client (work machine only)
  - Installed as cask, configured in dock

## Data Storage

**Databases:**
- PostgreSQL 16
  - Connection: TCP connection via remote SSH tunneling (work machine)
  - Client: psql CLI tool via Homebrew (`hosts/work/default.nix` lines 100-105)
  - ORM: None configured at system level
  - Purpose: Primary development database on Kubernetes clusters
  - Helper function: `rpsql()` for remote PostgreSQL access via Kubernetes exec (`hosts/work/default.nix` lines 111-132)

- Supabase (Postgres-based)
  - Local port forwarding: Port 54322 (PostgreSQL), 54323 (REST API), 54325 (Storage), 54326 (Auth), 54327 (Edge Functions), 54328 (Analytics) via home SSH tunnel

**File Storage:**
- Homebrew local filesystem - Package cache and binaries
- Nix store - Immutable package storage at `/nix/store`
- Local dotfiles - Configuration files in `dotfiles/` directory
- Google Drive - Cloud file sync (work machine, installed as cask)

**Caching:**
- Nix build cache - Implicit via Nix derivations
- Homebrew cache - Implicit via Homebrew installation

## Authentication & Identity

**Auth Provider:**
- Custom - SSH and GPG key-based authentication

**Implementation:**
- SSH keys: Ed25519 keys managed by macOS Keychain (`home.nix` lines 103-132)
  - GitHub host: SSH key-based auth for `github.com` (`home.nix` lines 111-115)
  - Home server: SSH tunneling with port forwarding via Tailscale IP (`home.nix` lines 116-131)
  - UseKeychain: Enabled to store passphrases in macOS Keychain

- GPG/Signing: Commit signing configured per machine
  - Personal: GPG key E322D2003CDAA1E0 (`hosts/personal/default.nix` line 10)
  - Work: GPG key 79F5B64411A630A8 (`hosts/work/default.nix` line 10)
  - Signing: Enabled by default in git config (`home.nix` lines 88-91)
  - Passphrase entry: GUI pinentry_mac for macOS Keychain integration

**API Key Management:**
- Environment variables can be set in `home.nix` sessionVariables (commented example: `ANTHROPIC_API_KEY` at line 195)
- `.authinfo.gpg` support implied but not configured
- `.env` files managed outside of Nix (note in CLAUDE.md: never read .env contents)

## Monitoring & Observability

**Error Tracking:**
- Not detected - No centralized error tracking service configured

**Logs:**
- Console/standard output - Applications log to stdout
- File logging: Emacs daemon logs to `/tmp/emacs.log` and `/tmp/emacs.error.log` (commented out in `darwin/services.nix`)
- Claude Code statusline: Custom shell command integration (`darwin/system.nix` lines 22-32)

**Debugging:**
- Delve - Go debugger (dlv)
- Python debugpy - Python debugger protocol
- VS Code JS Debug - JavaScript debugger for editors

## CI/CD & Deployment

**Hosting:**
- macOS systems (M1 MacBook Air, MacBook Pro) - Target deployment platform
- No cloud hosting or containerized deployment configured
- Local development only

**CI Pipeline:**
- Not detected - No CI/CD service configured
- GitHub Actions possible but not configured in this repository

**Version Control:**
- Git - Primary version control (configured in `home.nix` lines 84-98)
- Conventional commits - Enforced via Cocogitto CLI
- Branch management: Auto-rebase on pull, simple push strategy

## Environment Configuration

**Required env vars:**
- `DOOMDIR` - Doom Emacs config directory (set to `$HOME/.config/doom`)
- `XDG_CONFIG_HOME` - XDG base directory (set to `$HOME/.config`)
- `HOMEBREW_NO_AUTO_UPDATE` - Prevent Homebrew auto-updates
- `HOMEBREW_NO_ENV_HINTS` - Suppress Homebrew environment hints
- `PAGER` - Default pager set to `moor`
- `MANPAGER` - Manual page pager set to `moor`
- `GPG_TTY` - GPG tty for passphrase entry
- Custom PATH additions: Doom Emacs bin, Homebrew paths, LLVM, PostgreSQL tools

**Secrets location:**
- macOS Keychain - SSH key passphrases and Git credentials
- `.authinfo.gpg` - Credentials (implied support, not explicitly configured)
- Environment variables - Custom credentials (must be set in sessionVariables or via .env)
- Note: `.env` files exist but should never be committed (handled by .gitignore)

**Host-specific configuration:**
- Work machine (`hosts/work/default.nix`):
  - AWS credentials expected in standard AWS location (~/.aws/credentials)
  - PostgreSQL connection via Kubernetes exec and SSH tunneling
  - Privileges CLI for admin privilege management
  - PGOPTIONS and SQLALCHEMY_DATABASE_URI handling via `rpsql()` function

- Personal machine (`hosts/personal/default.nix`):
  - Supabase CLI configured with SSH port forwarding
  - VPN integration via ProtonVPN

## Webhooks & Callbacks

**Incoming:**
- Not detected - No webhook endpoints configured

**Outgoing:**
- Not detected - No outgoing webhook integrations configured

**Application Lifecycle:**
- Launch agents: Currently disabled (Emacs daemon commented out in `darwin/services.nix` lines 7-19)
- Activation scripts: Post-activation hooks for application symlinking and Claude Code settings (`darwin/system.nix` lines 18-32)

---

*Integration audit: 2026-02-19*
