---
phase: 03-editor-experience
plan: "01"
subsystem: editor
tags: [neovim, fzf-lua, gitsigns, neo-tree, lazy-nvim, lua]

requires:
  - phase: 02-lsp-completion
    provides: working lazy.nvim setup with plugins directory auto-scan

provides:
  - fzf-lua lazy.nvim spec with ff/fg/fb/fc fuzzy finder keymaps
  - gitsigns lazy.nvim spec with BufReadPre load and hunk navigation
  - neo-tree lazy.nvim spec with leader-e toggle and directory handling

affects:
  - 03-editor-experience phase gate verification

tech-stack:
  added:
    - ibhagwan/fzf-lua (fuzzy finder)
    - lewis6991/gitsigns.nvim (git gutter)
    - nvim-neo-tree/neo-tree.nvim v3.x (file tree sidebar)
  patterns:
    - One file per plugin in lua/plugins/ auto-scanned by lazy.setup('plugins')
    - BufReadPre for plugins needed before buffer display (gitsigns)
    - cmd + keys dual lazy-load trigger for command-line and keymap access
    - BufEnter once autocmd in init() for directory-open handling (neo-tree)

key-files:
  created:
    - dotfiles/nvim/lua/plugins/fzf-lua.lua
    - dotfiles/nvim/lua/plugins/gitsigns.lua
    - dotfiles/nvim/lua/plugins/neo-tree.lua
  modified:
    - dotfiles/nvim/lua/config/keymaps.lua

key-decisions:
  - "fzf-lua preview layout=horizontal puts preview on right side (not vertical)"
  - "gitsigns uses BufReadPre not VeryLazy so signs appear before first buffer display"
  - "gitsigns ]h/[h guard vim.wo.diff to avoid breaking :Gitsigns diffthis view"
  - "neo-tree sources limited to filesystem only, no buffers/git_status tabs"
  - "neo-tree init() BufEnter autocmd (once=true) handles nvim /some/dir without eager load"
  - "netrw - keymap removed in favor of neo-tree leader-e toggle"

patterns-established:
  - "Plugin file = one return {} table, cmd+keys for dual lazy-load trigger"
  - "on_attach callbacks use local map() helper for buffer-scoped keymaps with desc"
  - "diff-mode guards required for hunk navigation keymaps"

requirements-completed: [FIND-01, FIND-02, FIND-03, GIT-01, GIT-02, TREE-01, TREE-02]

duration: 8min
completed: 2026-02-26
---

# Phase 3 Plan 01: Editor Experience Plugins Summary

**fzf-lua fuzzy finder, gitsigns git gutter, and neo-tree file tree added as lazy.nvim specs; netrw keymap removed**

## Performance

- **Duration:** 8 min
- **Started:** 2026-02-26T21:08:00Z
- **Completed:** 2026-02-26T21:16:00Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- Created fzf-lua spec with floating window, right-side preview, and four leader keymaps (ff/fg/fb/fc)
- Created gitsigns spec with BufReadPre loading, custom sign characters, diff-mode-guarded hunk navigation, and stage/reset/preview keymaps
- Created neo-tree spec with filesystem-only source, leader-e toggle, directory-open BufEnter handling, and custom git status symbols
- Removed netrw `-` keymap from keymaps.lua

## Task Commits

Each task was committed atomically:

1. **Task 1: Create fzf-lua, gitsigns, and neo-tree plugin specs** - `54c4976` (feat)
2. **Task 2: Remove netrw keymap from keymaps.lua** - `29762ea` (fix)

**Plan metadata:** (docs commit follows)

## Files Created/Modified

- `dotfiles/nvim/lua/plugins/fzf-lua.lua` - Fuzzy finder spec: floating window, right preview, ff/fg/fb/fc keymaps
- `dotfiles/nvim/lua/plugins/gitsigns.lua` - Git gutter spec: BufReadPre, custom signs, ]h/[h hunk nav, gs/gr/gp keymaps
- `dotfiles/nvim/lua/plugins/neo-tree.lua` - File tree spec: filesystem-only, leader-e toggle, BufEnter dir init
- `dotfiles/nvim/lua/config/keymaps.lua` - Removed netrw - :Ex bind and comment

## Decisions Made

- fzf-lua preview uses `layout = "horizontal"` (not "vertical") to place preview on the right
- gitsigns loads on `BufReadPre` so signs appear before first buffer display
- gitsigns hunk navigation guards `vim.wo.diff` to preserve behavior in diffthis view
- neo-tree `init()` registers a `once = true` BufEnter autocmd to handle `nvim /dir` without eager loading

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

The Task 2 verify command `grep -c ... | grep -q "^0$"` reported FAIL due to shell pipeline behavior (grep exits 1 when count is 0, breaking the pipe). Manual inspection confirmed the file was correctly modified — netrw lines absent. No code changes were needed.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- All three plugin specs ready for lazy.nvim to install on next Neovim launch
- Plan 03-02 can proceed: system rebuild to install plugins and verify keybinds in live session
- No blockers

---
*Phase: 03-editor-experience*
*Completed: 2026-02-26*
