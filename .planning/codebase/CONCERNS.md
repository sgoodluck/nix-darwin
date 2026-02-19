# Codebase Concerns

**Analysis Date:** 2026-02-19

## Tech Debt

**Mutable Homebrew Taps Configuration:**
- Issue: `mutableTaps = true` and `autoMigrate = true` in `flake.nix` line 87-88 allow modifications outside Nix control
- Files: `flake.nix` (lines 87-88)
- Impact: Reduces reproducibility and may cause divergence between declared and actual system state. Makes rollbacks unreliable and introduces human error potential
- Fix approach: Set `mutableTaps = false` for production-grade reproducibility. Accept that manual tap management is required for edge cases, or update flake.nix to declare all taps explicitly

**Commented-out Emacs Daemon Service:**
- Issue: Large block of commented code for Emacs daemon in `darwin/services.nix` lines 8-19
- Files: `darwin/services.nix`
- Impact: Dead code creates confusion about actual system state. Indicates incomplete migration to Zed editor
- Fix approach: Remove entirely or create a separate `DISABLED_SERVICES.md` documenting why each was disabled. If returning to it, verify launch paths match current Homebrew installation

**Hardcoded Remote SSH Hostname:**
- Issue: SSH local forwarding config uses hardcoded IP `100.89.94.46` in `home.nix` line 117
- Files: `home.nix` (line 117)
- Impact: Not portable - if home network changes or Tailscale IP reassigns, config breaks. Security concern if IP changes mean different host
- Fix approach: Consider using hostname from Tailscale DNS (e.g., `home.tail-xxxxx.ts.net`) or document IP assignment strategy with static DNS name

**Editor Transition Artifacts:**
- Issue: Comments "# Previously: emacs" at `hosts/personal/default.nix:60` and `hosts/work/default.nix:140` indicate incomplete documentation of transition
- Files: `hosts/personal/default.nix`, `hosts/work/default.nix`
- Impact: Unclear why Zed was chosen over Emacs or when/how to revert
- Fix approach: Document the transition decision in CLAUDE.md or create MIGRATION.md explaining pros/cons of each editor choice

**Backup Directory Not Cleaned:**
- Issue: `dotfiles/nvim.backup` directory exists (listed in ls output) but not referenced in config
- Files: `dotfiles/nvim.backup/` (orphaned)
- Impact: Disk waste, confusion about which config is active
- Fix approach: Verify `dotfiles/nvim` is the active source, then remove `nvim.backup` directory

## Known Bugs

**Work Machine rpsql Function Complexity:**
- Symptoms: `rpsql` shell function in `hosts/work/default.nix:111-132` is fragile - breaks if kubectl exec or grep behavior changes
- Files: `hosts/work/default.nix` (lines 111-132)
- Trigger: Running `rpsql <context>` with missing or misconfigured Kubernetes deployment
- Workaround: Fall back to manual `kubectx` + manual SSH port forwarding; can test with `kubectx -l` to verify context exists
- Root cause: Tightly coupled to specific deployment structure. Assumes `deploy/notifications` exists and contains `SQLALCHEMY_DATABASE_URI` env var

**nix-homebrew enableRosetta Configuration:**
- Symptoms: `enableRosetta = true` in `flake.nix:85` but no documentation on what it does or when it's needed
- Files: `flake.nix` (line 85)
- Trigger: Only relevant on Apple Silicon Macs running x86 packages - may be unnecessary
- Workaround: Remove if native packages work; re-add if specific Homebrew cask requires x86 compatibility
- Root cause: Set for initial ARM64 support, unclear if still needed with modern package availability

## Security Considerations

**SSH Key Assumptions:**
- Risk: `home.nix:114` assumes `~/.ssh/id_ed25519` exists but doesn't verify or create it
- Files: `home.nix` (lines 103-132)
- Current mitigation: User must create SSH keys manually before rebuild
- Recommendations: Add activation script to generate SSH keys if missing (but don't overwrite existing); document key generation in README

**Hardcoded Work Email in Config:**
- Risk: `hosts/work/default.nix:6` contains email `seth.martin@firstresonance.io` - exposed in git history and can be harvested
- Files: `hosts/work/default.nix` (line 6)
- Current mitigation: Assumes private repo
- Recommendations: Extract to environment variables or separate secrets file (.env.nix that's .gitignored); use git config conditional includes for work identity

**PostgreSQL Tools in PATH:**
- Risk: `hosts/work/default.nix:206` adds PostgreSQL binaries to PATH without version pinning
- Files: `hosts/work/default.nix` (line 206)
- Current mitigation: Uses specific version `postgresql@16`
- Recommendations: Add comment documenting why this version; create upgrade plan for when version needs to advance

## Performance Bottlenecks

**Recursive Org File Discovery:**
- Problem: `home.nix:53` uses `directory-files-recursively` on entire Documents directory - can be slow with many files
- Files: `home.nix` (line 52-53)
- Cause: Scans all subdirectories without filtering. If Documents has thousands of files, org-agenda startup will lag
- Improvement path: Whitelist specific directories (`org-main-dir` and related) instead of entire Documents folder; or use `org-agenda-files` with explicit list

**Homebrew Cleanup on Every Activation:**
- Problem: `modules/common/packages.nix:113` with `cleanup = "zap"` removes unlisted packages on every rebuild
- Files: `modules/common/packages.nix` (line 113)
- Cause: Useful for consistency but slow; runs even when no packages changed
- Improvement path: Change to `cleanup = "uninstall"` for gentler behavior, or document that manual Homebrew installs will be removed

**Prism NPM Package Extraction:**
- Problem: `hosts/work/default.nix:35-65` builds Prism CLI from tarball with custom derivation - duplicates stdenv and Node.js setup
- Files: `hosts/work/default.nix` (lines 35-65)
- Cause: Package lacks package-lock.json, can't use standard npm2nix tooling
- Improvement path: Maintain a simpler wrapper that calls Homebrew-installed Node.js; or submit package-lock.json to upstream Prism project

## Fragile Areas

**Shell Function Coupling:**
- Files: `hosts/work/default.nix:109-133`, `home.nix:150-169`
- Why fragile: Shell initialization uses complex bash/zsh constructs (`OPTIND`, `getopts`, `preexec/precmd hooks`). Changes to Zsh version may break prompt spacing logic or `rpsql` argument parsing
- Safe modification: Test changes in interactive shell first before rebuilding; keep backups of working preexec/precmd hooks
- Test coverage: No tests for shell initialization - all validation is manual

**Nix-Homebrew Integration:**
- Files: `flake.nix:78-97`, `modules/common/packages.nix:104-169`
- Why fragile: Nix-homebrew is a third-party wrapper with frequent API changes; `mutableTaps = true` creates divergence. Changes to Homebrew tap structure (URL formats, tap naming) will break config
- Safe modification: Always test in isolation on one machine before applying to both; maintain flake.lock with current working hash; read nix-homebrew changelog before updating
- Test coverage: Only validated by actual system rebuild - no dry-run safety

**Host-Specific Package Derivation:**
- Files: `hosts/work/default.nix:31-66`
- Why fragile: Custom Nix derivation for Prism CLI tightly couples to specific tarball URL and directory structure. If Prismatic.io changes tarball format or removes old versions, build fails with cryptic error
- Safe modification: Keep comment with Prismatic version requirement; set up monitoring/CI to detect when tarball URL breaks; maintain fallback installation method (e.g., direct npm install via Homebrew Node.js)
- Test coverage: Only tested by full rebuild; no isolated unit test

**SSH Local Port Forwarding:**
- Files: `home.nix:119-129`
- Why fragile: Nine hardcoded port mappings with cryptic comments. If remote services move or ports change, entire SSH config becomes invalid
- Safe modification: Create separate `ssh-config.nix` file with clearer structure; consider moving to Tailscale subnet routing instead of manual forwarding; document each port's purpose in README
- Test coverage: Manual testing only (`ssh home` to verify forwarding works)

## Scaling Limits

**Package Sets Growing Unbounded:**
- Current capacity: `modules/common/packages.nix` has 100+ packages; host-specific adds 10-20 more
- Limit: No clear breaking point, but readability degrades above ~150 packages; rebuild time increases linearly
- Scaling path: Organize packages into semantic categories (`language-dev.nix`, `cli-tools.nix`, `creative.nix`) and import selectively based on machine role

**Dotfile Management at 20+ Symlinks:**
- Current capacity: `home.nix:33-74` manages 25+ file symlinks
- Limit: Beyond ~50 symlinks, manual maintenance becomes error-prone (easy to forget removal when deleting config)
- Scaling path: Create helper Nix function to generate symlinks from directory tree instead of manual list

**Home-Manager State Complexity:**
- Current capacity: Managing single user across 2 machines with 80% shared configuration
- Limit: Adding third machine or more significant per-machine customization requires careful module refactoring to avoid duplication
- Scaling path: Create `modules/home-manager/` similar to `modules/common/` and compose selectively by machine role

## Dependencies at Risk

**nix-homebrew (zhaofengli-wip/nix-homebrew):**
- Risk: Uses `-wip` (work-in-progress) tag `github:zhaofengli-wip/nix-homebrew`. WIP typically means unstable API and breaking changes
- Impact: Updates may fail to apply; Homebrew tap definitions or options change without warning
- Migration plan: Monitor upstream for promotion to stable release; if never stabilizes, consider forking into personal repo with pinned version; evaluate pure Nix homebrew replacements

**home-manager release-25.05:**
- Risk: Pinned to `release-25.05` but system uses `nixpkgs-25.05-darwin` - different schedules. If Darwin branch ends EOL but home-manager continues, state mismatch occurs
- Impact: Security updates or package removals may cause conflicts
- Migration plan: Establish clear upgrade schedule (e.g., upgrade quarterly to latest release branch); document reasons for staying on specific versions

**Doom Emacs Configuration:**
- Risk: Doom Emacs (`dotfiles/doom/`) managed outside Nix, separate git repo required (`doom-git-init`), but Home Manager symlinks its files
- Impact: Doom config can drift from Nix-managed rest of system; Easy to break with `doom sync` but no version control integration
- Migration plan: Migrate Doom config into Nix flake as Emacs derivation with custom elisp; or accept separate git repo and document in CLAUDE.md

**Homebrew Emacs-plus Formula:**
- Risk: Relies on third-party tap `d12frosted/homebrew-emacs-plus` with custom build flags (xwidgets, imagemagick, ctags)
- Impact: If tap is abandoned or formula changes, specific feature combination may become unavailable
- Migration plan: Pre-build and cache binary, or switch to official Emacs formula; test flag support in each update cycle

## Missing Critical Features

**No Disaster Recovery Plan:**
- Problem: No documented process for recovering configuration if flake.lock becomes corrupted or both machines become unbootable
- Blocks: Can't safely experiment with major version upgrades; no rollback procedure
- Fix: Create offline backup of flake.lock and working system state hash; document recovery steps in README

**No Configuration Validation:**
- Problem: No pre-rebuild syntax checks or compatibility validation (e.g., `nix flake check` not mentioned in troubleshooting)
- Blocks: Syntax errors only discovered during `darwin-rebuild`, wasting time
- Fix: Add CI/CD step or pre-commit hook running `nix flake check` before commit

**No Secrets Management:**
- Problem: Hardcoded email addresses, GitHub usernames, and remote IP in config files
- Blocks: Can't share config publicly without redacting sensitive data; can't separate work/personal as cleanly
- Fix: Introduce Agenix, sops-nix, or environment variable injection for sensitive values

**No Rollback Guidance:**
- Problem: If rebuild breaks system, README doesn't document how to revert to previous generation
- Blocks: Users must manually diagnose which aspect of config broke
- Fix: Document `darwin-rebuild switch --switch-generation <N>` and create helper script `nxr-rollback`

## Test Coverage Gaps

**Shell Configuration Not Tested:**
- What's not tested: Aliases work correctly (`nxr`, `doom-commit`, etc.); environment variables export to subshells; prompt renders correctly
- Files: `home.nix:137-250` (entire shell configuration section)
- Risk: Misquoted variables or missing `export` statements silently fail or break subshell behavior
- Priority: Medium - affects daily UX but rare to break

**Nix Syntax Not Validated:**
- What's not tested: Flake syntax validity; module resolution order; specialArgs injection works as expected
- Files: `flake.nix`, `darwin/`, `modules/`
- Risk: Syntax errors only caught at rebuild time; hard-to-debug evaluation errors
- Priority: High - blocks entire system when broken

**Homebrew Tap Integration:**
- What's not tested: Custom taps resolve correctly; cask/brew formulas still exist in upstream; renamed formulas are caught
- Files: `flake.nix:89-95`, `modules/common/packages.nix:104-169`
- Risk: Homebrew formula renamed or removed silently breaks rebuild
- Priority: Medium - happens when upstream changes

**Host-Specific Package Derivation:**
- What's not tested: Prism tarball extraction produces correct binary; Node.js wrapper resolves dependencies
- Files: `hosts/work/default.nix:35-65`
- Risk: Silent failures during tarball extraction or binary not executable after build
- Priority: High - only used on work machine, breaks critical development tool

---

*Concerns audit: 2026-02-19*
