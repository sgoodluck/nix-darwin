---
phase: 01-foundation
plan: 02
subsystem: editor
tags: [neovim, lua, lazy.nvim, modus-themes, treesitter, colorscheme]

# Dependency graph
requires: []
provides:
  - Modular Neovim config structure: init.lua, lua/config/, lua/plugins/
  - modus-themes.nvim colorscheme plugin spec with bg_main=#1d2235 override
  - nvim-treesitter plugin spec (master branch) with 12 parsers
  - Non-plugin keymaps and autocmds extracted to lua/config/
affects:
  - 01-foundation-03 (LSP config will add to lua/plugins/)
  - 02-editing (all plugins added to lua/plugins/)
  - 03-lsp (all LSP config uses lua/config/ and lua/plugins/ structure)

# Tech tracking
tech-stack:
  added:
    - modus-themes.nvim (miikanissi/modus-themes.nvim)
    - nvim-treesitter (master branch, 12 parsers)
  patterns:
    - Each plugin is a separate file in lua/plugins/ returning a lazy.nvim spec
    - lua/config/ contains non-plugin bootstrapping (options, keymaps, autocmds)
    - init.lua is a thin bootstrap only: leader, requires config.*, lazy setup

key-files:
  created:
    - dotfiles/nvim/lua/config/options.lua
    - dotfiles/nvim/lua/config/keymaps.lua
    - dotfiles/nvim/lua/config/autocmds.lua
    - dotfiles/nvim/lua/plugins/colorscheme.lua
    - dotfiles/nvim/lua/plugins/treesitter.lua
  modified:
    - dotfiles/nvim/init.lua

key-decisions:
  - "modus-themes.nvim replaces hand-rolled hi clear / nvim_set_hl colorscheme block"
  - "nvim-treesitter pinned to branch=master — new main branch removed require('nvim-treesitter.configs').setup()"
  - "All keymaps get desc fields for which-key compatibility in future phases"
  - "autocmds.lua starts with only two: highlight-yank and trim-whitespace (high-value, no surprises)"

patterns-established:
  - "Plugin spec pattern: one file per plugin in lua/plugins/, return a single lazy.nvim spec table"
  - "Config bootstrap order: leader -> options -> keymaps -> autocmds -> lazy.setup()"
  - "lazy.setup('plugins') auto-scans lua/plugins/ — no manual requires list in init.lua"

requirements-completed: [FNDN-01, FNDN-02, FNDN-03, FNDN-04]

# Metrics
duration: 1min
completed: 2026-02-26
---

# Phase 1 Plan 02: Neovim Module Structure Summary

**Monolithic init.lua refactored to modular lua/config/ + lua/plugins/ structure with modus-themes.nvim and nvim-treesitter replacing hand-rolled colorscheme and fzf/telescope/commander**

## Performance

- **Duration:** ~1 min
- **Started:** 2026-02-26T16:54:45Z
- **Completed:** 2026-02-26T16:56:06Z
- **Tasks:** 2
- **Files modified:** 6

## Accomplishments
- Extracted all vim.opt.*, keymaps, and autocmds from init.lua into lua/config/ modules
- Rewrote init.lua as 26-line thin bootstrap (under 30-line limit)
- Removed fzf.vim, telescope, plenary, and commander plugin specs entirely
- Created colorscheme.lua: modus-themes.nvim lazy=false/priority=1000 with bg_main=#1d2235 override
- Created treesitter.lua: master branch pinned, 12 parsers, lazy-loads on BufReadPre/BufNewFile

## Task Commits

Each task was committed atomically:

1. **Task 1: Create lua/config/ modules from existing init.lua** - `c662354` (feat)
2. **Task 2: Rewrite init.lua as thin bootstrap and create plugin specs** - `98bc88e` (feat)

**Plan metadata:** (docs commit follows)

## Files Created/Modified
- `dotfiles/nvim/init.lua` - Rewritten as 26-line thin bootstrap
- `dotfiles/nvim/lua/config/options.lua` - All vim.opt.* settings
- `dotfiles/nvim/lua/config/keymaps.lua` - Non-plugin keymaps with desc fields on all bindings
- `dotfiles/nvim/lua/config/autocmds.lua` - highlight-yank and trim-whitespace autocmds
- `dotfiles/nvim/lua/plugins/colorscheme.lua` - modus-themes.nvim lazy spec with on_colors override
- `dotfiles/nvim/lua/plugins/treesitter.lua` - nvim-treesitter master branch spec with 12 parsers

## Decisions Made
- Pinned nvim-treesitter to `branch = "master"` — the new `main` branch removed `require("nvim-treesitter.configs").setup()`, which would silently break the config
- Added `desc` fields to all keymaps (window nav, indenting) that lacked them — prepares for which-key in phase 2 without requiring changes later
- Used `lazy.setup("plugins")` string form (directory auto-scan) instead of explicit spec list — adding plugins in future tasks only requires a new file, not touching init.lua

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

None. The migration was straightforward extraction and rewrite with no runtime surprises.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness
- Modular structure is ready for Phase 1 Plan 03 (LSP config) which adds files to lua/plugins/
- modus-themes.nvim will install on first `nvim` launch via lazy.nvim bootstrap
- nvim-treesitter will install parsers on first file open (lazy-loaded on BufReadPre)
- No blockers for subsequent plans

---
*Phase: 01-foundation*
*Completed: 2026-02-26*

## Self-Check: PASSED

All files and commits verified:
- FOUND: dotfiles/nvim/lua/config/options.lua
- FOUND: dotfiles/nvim/lua/config/keymaps.lua
- FOUND: dotfiles/nvim/lua/config/autocmds.lua
- FOUND: dotfiles/nvim/lua/plugins/colorscheme.lua
- FOUND: dotfiles/nvim/lua/plugins/treesitter.lua
- FOUND: c662354 (Task 1 commit)
- FOUND: 98bc88e (Task 2 commit)
