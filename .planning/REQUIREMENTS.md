# Requirements: Neovim Configuration

**Defined:** 2026-02-26
**Core Value:** Fast, capable editing across all development languages with the fewest plugins possible

## v1 Requirements

Requirements for initial release. Each maps to roadmap phases.

### Foundation

- [ ] **FNDN-01**: Config uses modular lua/plugins/ structure with lazy.nvim auto-scanning
- [ ] **FNDN-02**: Modus vivendi tinted colorscheme via modus-themes.nvim with treesitter/LSP highlight support
- [ ] **FNDN-03**: Treesitter installed with parsers for all target languages (nix, python, typescript, go, rust, c, lua, markdown, json, yaml, toml, bash)
- [ ] **FNDN-04**: Core options, keymaps, and autocmds extracted into separate modules
- [x] **FNDN-05**: Neovim cold start under 100ms measured via `--startuptime`

### LSP & Completion

- [ ] **LSP-01**: LSP active for Nix (nil/nixd), Python (pyright), TypeScript (ts_ls), Go (gopls), Rust (rust-analyzer), C/C++ (ccls)
- [ ] **LSP-02**: Autocompletion via blink.cmp with LSP, buffer, and path sources
- [ ] **LSP-03**: Inline diagnostics with signs and virtual text
- [ ] **LSP-04**: LSP keymaps on attach (go-to-definition, references, rename, hover, code actions)
- [ ] **LSP-05**: Format-on-save via conform.nvim for all configured languages
- [ ] **LSP-06**: Nix PATH verified — all LSP servers resolvable from inside Neovim
- [ ] **LSP-07**: Lua language server configured for Neovim API completions

### Fuzzy Finding

- [ ] **FIND-01**: fzf-lua replaces fzf.vim, telescope, and commander
- [ ] **FIND-02**: File picker, live grep, and buffer list via leader keybinds
- [ ] **FIND-03**: Commands/keymaps browser as toggleable command palette

### Git

- [ ] **GIT-01**: Gitsigns shows added/changed/deleted signs in gutter
- [ ] **GIT-02**: Navigate between hunks with keybinds

### File Explorer

- [ ] **TREE-01**: Neo-tree toggleable sidebar, closed by default
- [ ] **TREE-02**: Single keybind to toggle tree open/closed

## v2 Requirements

Deferred to future release. Tracked but not in current roadmap.

### Enhanced Git

- **GIT-03**: Inline blame annotations
- **GIT-04**: Stage/reset hunks from editor

### Navigation

- **NAV-01**: LSP symbol search via fzf-lua
- **NAV-02**: Breadcrumbs/winbar showing current function

### Editing

- **EDIT-01**: Snippet support via blink.cmp + friendly-snippets
- **EDIT-02**: Auto-pairs for brackets/quotes

## Out of Scope

| Feature | Reason |
|---------|--------|
| DAP/Debugger integration | Use external tools, adds complexity |
| Note-taking/org-mode | Use Emacs for that |
| AI/Copilot plugins | Use Claude Code externally |
| Custom statusline | Keep simple, avoid plugin bloat |
| Session management | Not needed for fast editor workflow |
| Mason.nvim | Redundant — Nix manages all LSP servers |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Phase | Status |
|-------------|-------|--------|
| FNDN-01 | Phase 1 | Pending |
| FNDN-02 | Phase 1 | Pending |
| FNDN-03 | Phase 1 | Pending |
| FNDN-04 | Phase 1 | Pending |
| FNDN-05 | Phase 1 | Complete |
| LSP-01 | Phase 2 | Pending |
| LSP-02 | Phase 2 | Pending |
| LSP-03 | Phase 2 | Pending |
| LSP-04 | Phase 2 | Pending |
| LSP-05 | Phase 2 | Pending |
| LSP-06 | Phase 2 | Pending |
| LSP-07 | Phase 2 | Pending |
| FIND-01 | Phase 3 | Pending |
| FIND-02 | Phase 3 | Pending |
| FIND-03 | Phase 3 | Pending |
| GIT-01 | Phase 3 | Pending |
| GIT-02 | Phase 3 | Pending |
| TREE-01 | Phase 3 | Pending |
| TREE-02 | Phase 3 | Pending |

**Coverage:**
- v1 requirements: 19 total
- Mapped to phases: 19
- Unmapped: 0

---
*Requirements defined: 2026-02-26*
*Last updated: 2026-02-26 after roadmap creation*
