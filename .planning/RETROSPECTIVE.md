# Project Retrospective

*A living document updated after each milestone. Lessons feed forward into future planning.*

## Milestone: v1.0 -- Neovim Configuration

**Shipped:** 2026-02-26
**Phases:** 3 | **Plans:** 7

### What Was Built
- Modular lazy.nvim config: 26-line init.lua bootstrap, lua/config/ for options/keymaps/autocmds, lua/plugins/ for one-file-per-plugin specs
- 7 LSP servers (nixd, pyright, ts_ls, gopls, rust_analyzer, ccls, lua_ls) via Neovim 0.11 native API with blink.cmp autocompletion
- Format-on-save via conform.nvim for 9 filetypes (Lua, Python, Nix, Go, Rust, C, TypeScript, JavaScript, Bash)
- fzf-lua fuzzy finder replacing fzf.vim + telescope + commander with one plugin
- gitsigns git gutter with hunk navigation, neo-tree toggleable file tree
- 34ms cold start with all 8 plugins lazy-loaded

### What Worked
- **Plugin-per-file pattern**: Adding a plugin meant creating one file in lua/plugins/ -- no init.lua edits, no import lists to maintain
- **Nix-managed LSP servers**: All 7 servers declared in packages.nix, no Mason complexity. darwin-rebuild propagates PATH automatically
- **Phase-gate verification**: Measuring cold start and running vim.fn.exepath() checks before writing LSP config caught potential silent PATH failures early
- **Neovim 0.11 native API**: vim.lsp.config/enable with blink.cmp wildcard capabilities injection eliminated per-server boilerplate
- **Single-day execution**: All 3 phases completed in one session with clear phase boundaries

### What Was Inefficient
- **Treesitter except* desync**: Python 3.11 exception group syntax caused a treesitter query desync that required debugging mid-verification. Could have been caught with a pre-verification Python test file
- **Colorscheme name confusion**: Two commits needed to fix modus_vivendi_tinted (not a valid command) vs variant='tinted' in setup(). The modus-themes.nvim API was not obvious from docs alone
- **grep alias collisions**: Shell aliases (grep -> rg) broke verification commands in plans. Plan verification commands should use tool-specific syntax

### Patterns Established
- Plugin spec pattern: one file per plugin in `lua/plugins/`, return a single lazy.nvim spec table
- Config bootstrap order: leader -> options -> keymaps -> autocmds -> lazy.setup("plugins")
- LspAttach autocmd for buffer-local keymaps (only active when a server attaches)
- blink.cmp capabilities flow: get_lsp_capabilities() -> vim.lsp.config('*') -> all servers inherit
- Rebuild pattern: nxr -> nvim --headless "+Lazy! sync" -> human verify
- BufReadPre for plugins needed before first buffer display (gitsigns)
- init() with BufEnter once autocmd for directory handling (neo-tree)

### Key Lessons
1. **Neovim 0.11 API is the future**: vim.lsp.config/enable is cleaner than lspconfig setup loops. nvim-lspconfig is only needed for its lsp/ server definition files.
2. **Test with real language files before verification**: A Python file with except* syntax would have caught the treesitter issue before it became a blocker.
3. **Check plugin README for exact API**: modus-themes.nvim variant selection is not via colorscheme command suffix -- always verify setup() options against the actual README.
4. **Nix + lazy.nvim is a clean split**: Nix manages server binaries, lazy.nvim manages Lua plugins. No overlap, no conflicts.

### Cost Observations
- Sessions: 1 (single continuous session)
- Notable: All 7 plans completed in sequence in one session; phase-gate verification added ~30 min each but prevented cascading issues

---

## Cross-Milestone Trends

### Process Evolution

| Milestone | Sessions | Phases | Key Change |
|-----------|----------|--------|------------|
| v1.0 | 1 | 3 | Established plugin-per-file, Nix LSP, phase-gate pattern |

### Top Lessons (Verified Across Milestones)

1. Phase-gate verification catches integration issues before they compound
2. One-file-per-plugin with lazy.nvim auto-scan scales cleanly
