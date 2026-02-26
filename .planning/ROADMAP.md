# Roadmap: Neovim Configuration

## Overview

Three phases build a minimal, fast Neovim IDE from the ground up. Phase 1 establishes the module structure and verifies the Nix-Neovim integration that everything else depends on. Phase 2 adds the core IDE infrastructure — LSP servers and completion — which must be correct before any editor UX features can use it. Phase 3 completes the editing experience with fuzzy finding, git integration, and the file tree, all of which load on demand and carry no startup cost.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

- [x] **Phase 1: Foundation** - Module structure, colorscheme, treesitter, and verified Nix PATH (completed 2026-02-26)
- [ ] **Phase 2: LSP + Completion** - Full LSP for all languages, autocompletion, diagnostics, and format-on-save
- [ ] **Phase 3: Editor Experience** - Fuzzy finding, git signs, and toggleable file tree

## Phase Details

### Phase 1: Foundation
**Goal**: The config is modular, Nix PATH integration is verified, colorscheme loads eagerly, and treesitter highlights all target languages — all before any LSP config is written
**Depends on**: Nothing (first phase)
**Requirements**: FNDN-01, FNDN-02, FNDN-03, FNDN-04, FNDN-05
**Success Criteria** (what must be TRUE):
  1. Neovim opens to modus_vivendi_tinted colorscheme with full treesitter highlight groups active
  2. Syntax highlighting works in all target files (Nix, Python, TypeScript, Go, Rust, C, Lua, Markdown, JSON, YAML, TOML, Bash)
  3. `vim.fn.exepath("gopls")` returns a non-empty path inside a running Neovim session
  4. Core options, keymaps, and autocmds live in `lua/config/` with no plugin dependencies
  5. Cold start measured via `--startuptime` is under 100ms
**Plans**: 3 plans

Plans:
- [x] 01-01-PLAN.md — Add missing LSP packages to packages.nix and rebuild system
- [ ] 01-02-PLAN.md — Modular Lua structure, modus-themes.nvim, and nvim-treesitter plugin specs
- [ ] 01-03-PLAN.md — PATH verification inside Neovim and startup time measurement

### Phase 2: LSP + Completion
**Goal**: All six target languages have active LSP servers, autocompletion triggers automatically from LSP/buffer/path sources, diagnostics appear inline, and code formatting runs on save
**Depends on**: Phase 1
**Requirements**: LSP-01, LSP-02, LSP-03, LSP-04, LSP-05, LSP-06, LSP-07
**Success Criteria** (what must be TRUE):
  1. Go-to-definition, hover, rename, code actions, and references work via keymaps in Go, Python, TypeScript, Nix, Rust, C, and Lua files
  2. Completion populates automatically on typing with LSP suggestions, buffer words, and file paths as sources
  3. Errors and warnings appear as inline virtual text and gutter signs without any manual command
  4. Saving a file automatically formats it for all configured languages
  5. The Lua language server provides Neovim API completions (e.g., `vim.` autocompletes with core functions)
**Plans**: 2 plans

Plans:
- [ ] 02-01-PLAN.md — Add Nix packages (pyright, stylua, rustfmt) and create LSP, completion, and formatting plugin files
- [ ] 02-02-PLAN.md — System rebuild and end-to-end verification of LSP, completion, and formatting

### Phase 3: Editor Experience
**Goal**: Fuzzy finding replaces all previous finder plugins, git changes are visible in the gutter with navigable hunks, and the file tree is available on demand — all loading at zero startup cost
**Depends on**: Phase 2
**Requirements**: FIND-01, FIND-02, FIND-03, GIT-01, GIT-02, TREE-01, TREE-02
**Success Criteria** (what must be TRUE):
  1. `<leader>ff`, `<leader>fg`, and `<leader>fb` open file picker, live grep, and buffer list respectively via fzf-lua
  2. A single keybind opens a command palette showing all available keymaps and commands
  3. Git-modified, added, and deleted lines show as gutter signs immediately on opening a file in a git repo
  4. Navigating between git hunks forward and backward works via keybinds
  5. A single keybind toggles the file tree open and closed from any buffer, with the tree closed by default
**Plans**: TBD

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation | 3/3 | Complete    | 2026-02-26 |
| 2. LSP + Completion | 0/2 | In progress | - |
| 3. Editor Experience | 0/? | Not started | - |
