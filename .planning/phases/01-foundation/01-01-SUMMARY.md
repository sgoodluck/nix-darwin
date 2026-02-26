---
phase: 01-foundation
plan: 01
subsystem: infra
tags: [nix, lsp, neovim, lua-language-server, nixd, rust-analyzer]

# Dependency graph
requires: []
provides:
  - lua-language-server declared in packages.nix
  - nixd declared in packages.nix
  - rust-analyzer declared in packages.nix
affects: [01-02, 01-03, phase-2-lsp-config]

# Tech tracking
tech-stack:
  added: [lua-language-server, nixd, rust-analyzer]
  patterns: [LSP servers managed via Nix packages.nix, not Mason]

key-files:
  created: []
  modified: [modules/common/packages.nix]

key-decisions:
  - "lua-language-server and nixd added as separate Nix packages in a dedicated Lua and Nix development block"
  - "rust-analyzer placed after cargo in the Rust development block"

patterns-established:
  - "LSP servers are Nix-managed in modules/common/packages.nix, grouped by language"

requirements-completed: [FNDN-05]

# Metrics
duration: 5min
completed: 2026-02-26
---

# Phase 1 Plan 01: Add Missing LSP Packages Summary

**lua-language-server, nixd, and rust-analyzer added to packages.nix; system rebuild pending user action to make them available on PATH**

## Performance

- **Duration:** ~5 min
- **Started:** 2026-02-26T16:54:45Z
- **Completed:** 2026-02-26T16:59:00Z (Task 1); Task 2 pending user rebuild
- **Tasks:** 1 of 2 (Task 2 is a human-action checkpoint)
- **Files modified:** 1

## Accomplishments
- Added rust-analyzer to the Rust development block in packages.nix
- Added a new "Lua and Nix development" section with lua-language-server and nixd
- Verified file parses as valid Nix syntax with nix-instantiate --parse

## Task Commits

Each task was committed atomically:

1. **Task 1: Add missing LSP packages to packages.nix** - `efb00b8` (feat)
2. **Task 2: Rebuild system with updated packages** - pending user action (checkpoint:human-action)

**Plan metadata:** (docs commit follows after Task 2 confirmation)

## Files Created/Modified
- `modules/common/packages.nix` - Added rust-analyzer, lua-language-server, and nixd to the Nix system packages list

## Decisions Made
- Used bare `lua-language-server` nixpkgs package name directly (no wrapper), confirming pkgs.lua-language-server resolves in nixpkgs 25.05
- rust-analyzer placed inside existing Rust development block for organizational consistency
- lua-language-server and nixd placed in a new dedicated comment group after the Rust block

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered
None

## User Setup Required

Task 2 requires a manual system rebuild:

```bash
# Personal machine:
nxr

# Work machine:
darwin-rebuild switch --flake ~/nix#Seths-MacBook-Pro
```

After the rebuild, verify all three LSP executables are on PATH:

```bash
which lua-language-server
which nixd
which rust-analyzer
```

All three should return a path (e.g., `/run/current-system/sw/bin/lua-language-server`).

## Next Phase Readiness
- Task 1 complete: packages.nix declares all required LSP servers
- Blocked on user rebuild for Task 2 before Phase 2 LSP config can begin
- Once rebuild confirms executables on PATH, Plan 03 PATH verification diagnostic can proceed

---
*Phase: 01-foundation*
*Completed: 2026-02-26*
