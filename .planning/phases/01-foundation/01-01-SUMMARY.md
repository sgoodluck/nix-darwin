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

**lua-language-server, nixd, and rust-analyzer added to packages.nix and verified on PATH after darwin-rebuild switch**

## Performance

- **Duration:** ~20 min (including human rebuild time)
- **Started:** 2026-02-26T16:54:45Z
- **Completed:** 2026-02-26T17:13:29Z
- **Tasks:** 2 of 2
- **Files modified:** 1

## Accomplishments
- Added rust-analyzer to the Rust development block in packages.nix
- Added a new "Lua and Nix development" section with lua-language-server and nixd
- Verified file parses as valid Nix syntax with nix-instantiate --parse
- System rebuilt via darwin-rebuild switch; all three executables confirmed on PATH via `which`

## Task Commits

Each task was committed atomically:

1. **Task 1: Add missing LSP packages to packages.nix** - `efb00b8` (feat)
2. **Task 2: Rebuild system with updated packages** - human-action checkpoint, rebuild confirmed by user

**Plan metadata:** (this summary commit)

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

None - rebuild completed. All three LSP executables confirmed on PATH.

## Next Phase Readiness
- All three LSP executables (lua-language-server, nixd, rust-analyzer) are on PATH system-wide
- The concern "Confirm `pkgs.lua-language-server` resolves in nixpkgs 25.05" is resolved — it does
- Plan 03 PATH verification diagnostic can now confirm visibility from inside Neovim

## Self-Check: PASSED

- FOUND: .planning/phases/01-foundation/01-01-SUMMARY.md
- FOUND: modules/common/packages.nix
- FOUND: commit efb00b8 (feat: add lua-language-server, nixd, rust-analyzer)

---
*Phase: 01-foundation*
*Completed: 2026-02-26*
