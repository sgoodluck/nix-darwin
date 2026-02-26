---
phase: 01-foundation
plan: 03
subsystem: editor
tags: [neovim, treesitter, lsp, modus-themes, path-verification]

# Dependency graph
requires:
  - phase: 01-foundation-01
    provides: LSP server binaries (gopls, lua-language-server, nixd, rust-analyzer, ccls, typescript-language-server) added to packages.nix
  - phase: 01-foundation-02
    provides: Modular Neovim config (init.lua bootstrap, lua/config/, lua/plugins/)
provides:
  - Verified phase gate: all 6 required LSP servers visible from vim.fn.exepath() inside Neovim
  - Cold start confirmed under 100ms (34.330ms measured)
  - Treesitter: 12 parsers installed and highlighting active
  - modus_vivendi with tinted variant colorscheme loading correctly at startup
  - Phase 2 (LSP + Completion) unblocked
affects: [02-lsp-completion, all future phases]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "modus-themes.nvim setup: use variant='tinted' in setup(), not colorscheme name suffix"
    - "Treesitter branch=master required; new main branch removed configs.setup() API"

key-files:
  created: []
  modified:
    - dotfiles/nvim/lua/plugins/colorscheme.lua

key-decisions:
  - "modus_vivendi colorscheme loaded via :colorscheme modus_vivendi with variant='tinted' in setup() — not modus_vivendi_tinted as a command"
  - "pyright intentionally absent from PATH at phase gate — will be added in Phase 2 Python LSP decision"

patterns-established:
  - "Phase gate pattern: measure cold start + run vim.fn.exepath() checks before writing LSP config to catch silent PATH failures"

requirements-completed: [FNDN-05]

# Metrics
duration: ~30min
completed: 2026-02-26
---

# Phase 1 Plan 03: Neovim Phase Gate Verification Summary

**Neovim verified at phase gate: 34ms cold start, 6/6 LSP servers on PATH, 12 treesitter parsers active, modus_vivendi tinted colorscheme correct after two colorscheme name fixes**

## Performance

- **Duration:** ~30 min
- **Started:** 2026-02-26
- **Completed:** 2026-02-26
- **Tasks:** 2
- **Files modified:** 1 (colorscheme.lua, via deviation fixes)

## Accomplishments

- Cold start measured at 34.330ms — well under 100ms target
- All 6 required LSP servers confirmed visible from inside Neovim via vim.fn.exepath()
- All 12 treesitter parsers installed and syntax highlighting active
- modus_vivendi tinted colorscheme loading correctly with #1d2235 background
- Phase 1 foundation fully verified — Phase 2 is unblocked

## Task Commits

Each task was committed atomically:

1. **Task 1: Run startup time measurement and prepare PATH verification script** - `a160d0b` (chore)
2. **Task 2: Verify Neovim opens correctly and PATH check passes** - (human-verify checkpoint, approved by user)

Deviation fix commits (during Task 1 / pre-checkpoint):
- `aa6c13b` fix(01-03): remove invalid style/variant options from modus-themes setup
- `f57623f` fix(01-03): use correct modus-themes colorscheme name and variant option

## Files Created/Modified

- `dotfiles/nvim/lua/plugins/colorscheme.lua` - Fixed modus-themes setup: removed invalid style/variant from setup(), corrected colorscheme command to use variant="tinted" in setup() rather than modus_vivendi_tinted as a command name

## Decisions Made

- pyright intentionally absent at this phase gate — it will be added in Phase 2 during the Python LSP decision (pylsp vs pyright)
- modus_vivendi_tinted is not a valid colorscheme name; the correct approach is `require('modus-themes').setup({ variant = 'tinted' })` then `:colorscheme modus_vivendi`

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Removed invalid style/variant options from modus-themes setup()**
- **Found during:** Task 1 (pre-checkpoint verification)
- **Issue:** colorscheme.lua passed `style` and `variant` keys directly to setup() which modus-themes.nvim does not accept, causing startup warnings
- **Fix:** Removed the invalid keys from the setup() call
- **Files modified:** dotfiles/nvim/lua/plugins/colorscheme.lua
- **Verification:** Startup errors eliminated
- **Committed in:** aa6c13b

**2. [Rule 1 - Bug] Corrected colorscheme command name from modus_vivendi_tinted to modus_vivendi with variant in setup()**
- **Found during:** Task 1 (pre-checkpoint verification)
- **Issue:** `:colorscheme modus_vivendi_tinted` is not a valid colorscheme name — the tinted variant is selected via `setup({ variant = "tinted" })` and then loaded with `:colorscheme modus_vivendi`
- **Fix:** Updated colorscheme.lua to set variant="tinted" in setup() and use the correct `:colorscheme modus_vivendi` command
- **Files modified:** dotfiles/nvim/lua/plugins/colorscheme.lua
- **Verification:** Colorscheme loads correctly with #1d2235 background, no errors on startup
- **Committed in:** f57623f

---

**Total deviations:** 2 auto-fixed (both Rule 1 bugs)
**Impact on plan:** Both fixes required for correct colorscheme loading. No scope creep.

## Issues Encountered

None beyond the colorscheme bugs documented above.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Phase 2 (LSP + Completion) is fully unblocked:
- All 6 LSP server binaries confirmed on Neovim's PATH
- Modular plugin structure in place (new LSP config = new file in lua/plugins/)
- Cold start headroom available (34ms used of 100ms budget — room for LSP plugins)
- Remaining decision: Python LSP (pylsp vs pyright) — validate venv detection with real .venv project
- Known risk: blink.cmp Rust build may fail in Nix context (fallback to nvim-cmp pre-planned)

---
*Phase: 01-foundation*
*Completed: 2026-02-26*
