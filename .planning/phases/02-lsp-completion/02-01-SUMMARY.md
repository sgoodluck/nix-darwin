---
phase: 02-lsp-completion
plan: 01
subsystem: editor
tags: [neovim, lsp, blink-cmp, conform-nvim, lazydev, nvim-lspconfig, nix]

requires:
  - phase: 01-foundation
    provides: "lazy.nvim auto-scan of lua/plugins/, Neovim 0.11 installed, 6 LSP servers on PATH"

provides:
  - "lsp.lua: 7 LSP servers enabled via vim.lsp.config/enable with LspAttach buffer-local keymaps and diagnostic config"
  - "completion.lua: blink.cmp 1.* completion engine with lazydev.nvim for Lua file Neovim API completions"
  - "formatting.lua: conform.nvim format-on-save for 9 languages, silent mode"
  - "packages.nix: pyright, rustfmt, stylua added to their correct Nix language groups"

affects: [02-lsp-completion, 03-workflow-polish]

tech-stack:
  added: [neovim/nvim-lspconfig, saghen/blink.cmp, folke/lazydev.nvim, stevearc/conform.nvim, pyright, stylua, rustfmt]
  patterns: [native-neovim-0.11-lsp-api, lspattach-buffer-local-keymaps, blink-cmp-capabilities-injection, conform-format-on-save]

key-files:
  created:
    - dotfiles/nvim/lua/plugins/lsp.lua
    - dotfiles/nvim/lua/plugins/completion.lua
    - dotfiles/nvim/lua/plugins/formatting.lua
  modified:
    - modules/common/packages.nix

key-decisions:
  - "Use vim.lsp.config/enable (Neovim 0.11 native API) not require('lspconfig') — nvim-lspconfig is only for its lsp/ server definitions"
  - "blink.cmp capabilities injected via vim.lsp.config('*', ...) wildcard before enabling servers"
  - "ghost_text disabled in blink.cmp (no inline preview per user preference)"
  - "Enter preset for blink.cmp completion acceptance"
  - "conform.nvim in fully silent mode: notify_on_error=false, notify_no_formatters=false"
  - "pyright added as standalone Nix package (separate from python-lsp-server in withPackages)"

patterns-established:
  - "LspAttach autocmd pattern: buffer-local keymaps only activate when a server is actually attached"
  - "blink.cmp capabilities flow: get_lsp_capabilities() -> vim.lsp.config('*') -> all servers inherit"
  - "lazydev integration: ft='lua' load guard + blink source with score_offset=100 to prioritize"
  - "clang_format uses underscore (not hyphen) in conform.nvim formatters_by_ft keys"

requirements-completed: [LSP-01, LSP-02, LSP-03, LSP-04, LSP-05, LSP-06, LSP-07]

duration: 2min
completed: 2026-02-26
---

# Phase 2 Plan 01: LSP + Completion + Formatting Summary

**Neovim 0.11 native LSP for 7 languages via vim.lsp.config/enable, blink.cmp with enter preset, lazydev.nvim for Lua, and conform.nvim format-on-save across 9 filetypes**

## Performance

- **Duration:** 2 min
- **Started:** 2026-02-26T18:45:37Z
- **Completed:** 2026-02-26T18:47:30Z
- **Tasks:** 2
- **Files modified:** 4

## Accomplishments

- Added pyright, rustfmt, and stylua as Nix packages so conform.nvim and the LSP can find them on PATH
- Created lsp.lua configuring 7 servers (nixd, pyright, ts_ls, gopls, rust_analyzer, ccls, lua_ls) via the Neovim 0.11 native API with 8 buffer-local keymaps and nerd font diagnostic icons
- Created completion.lua with blink.cmp (enter to accept, no ghost text) plus lazydev.nvim for Neovim API completions in Lua files
- Created formatting.lua with conform.nvim format-on-save for 9 languages in fully silent mode

## Task Commits

Each task was committed atomically:

1. **Task 1: Add pyright, stylua, and rustfmt to Nix packages** - `2292e46` (chore)
2. **Task 2: Create LSP, completion, and formatting plugin files** - `b6f5595` (feat)

**Plan metadata:** (docs commit — see below)

## Files Created/Modified

- `modules/common/packages.nix` - Added pyright (Python LSP), rustfmt (Rust formatter), stylua (Lua formatter) in correct language group sections
- `dotfiles/nvim/lua/plugins/lsp.lua` - 7 LSP servers, LspAttach keymaps, diagnostic virtual text with nerd font signs
- `dotfiles/nvim/lua/plugins/completion.lua` - blink.cmp 1.* + lazydev.nvim, enter preset, no ghost text
- `dotfiles/nvim/lua/plugins/formatting.lua` - conform.nvim format-on-save, 9 formatters, silent mode

## Decisions Made

- Used `vim.lsp.config/enable` (Neovim 0.11 native API) instead of the deprecated `require('lspconfig')` pattern. nvim-lspconfig is installed only for its `lsp/` server definition files which Neovim 0.11 auto-discovers.
- blink.cmp capabilities are injected once via `vim.lsp.config("*", { capabilities = ... })` wildcard so all 7 servers inherit them without per-server boilerplate.
- `clang_format` uses underscore in conform.nvim (not hyphen) — this is the correct key for the formatter name.

## Deviations from Plan

None - plan executed exactly as written.

## Issues Encountered

The `grep -c 'pyright|stylua|rustfmt'` verify command in the plan failed because the shell has `grep` aliased to `rg` (ripgrep), which interprets the `-E` flag differently. Used the Grep tool directly to verify — all 3 packages confirmed present.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- All 3 plugin files ready in lua/plugins/ and will be auto-scanned by lazy.nvim on next Neovim start
- 3 missing tool binaries (pyright, rustfmt, stylua) added to Nix — system rebuild required to make them available on PATH
- Phase 2 Plan 02 (if any) or phase gate verification can proceed once `nxr` is run to activate the new Nix packages

---
*Phase: 02-lsp-completion*
*Completed: 2026-02-26*

## Self-Check: PASSED

- FOUND: dotfiles/nvim/lua/plugins/lsp.lua
- FOUND: dotfiles/nvim/lua/plugins/completion.lua
- FOUND: dotfiles/nvim/lua/plugins/formatting.lua
- FOUND: .planning/phases/02-lsp-completion/02-01-SUMMARY.md
- FOUND: commit 2292e46 (chore: add pyright, stylua, rustfmt)
- FOUND: commit b6f5595 (feat: create LSP, completion, formatting plugin files)
