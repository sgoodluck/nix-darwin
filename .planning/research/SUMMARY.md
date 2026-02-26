# Project Research Summary

**Project:** Minimal Neovim IDE configuration (Nix-managed)
**Domain:** Neovim plugin configuration with Nix-managed LSP infrastructure
**Researched:** 2026-02-26
**Confidence:** HIGH

## Executive Summary

This project rebuilds a Neovim configuration to achieve a sub-100ms cold start, full IDE capability across 6 languages (Go, Python, TypeScript, Nix, Rust, C/C++), and a minimal plugin count (7-9 total). The current config is a monolithic `init.lua` with hand-rolled code and plugin choices that carry heavy transitive dependencies (telescope + plenary, fzf.vim, nvim-cmp sources). Research confirms each of those can be replaced with a single modern plugin that provides strictly more capability: fzf-lua replaces telescope + fzf.vim + commander + plenary, and blink.cmp replaces nvim-cmp and all of its source plugins.

The recommended approach is a modular Lua directory structure (`lua/config/`, `lua/plugins/`, `lua/lsp/`) with lazy.nvim as the plugin manager. Neovim 0.11's native `vim.lsp.config()` and `vim.lsp.enable()` APIs eliminate the need for Mason entirely — Nix already puts all LSP binaries on PATH. The architecture is deliberately layered: options and keymaps load unconditionally, plugins load on events or keypresses, and LSP servers spin up per-filetype. With this loading discipline, only the colorscheme loads at startup; everything else costs 0ms until first use.

The central risk is Nix-Neovim PATH integration. LSP servers installed as Nix packages are invisible to Neovim unless the shell environment is correctly propagated — this fails silently. The second major risk is the treesitter parser install mechanism, which conflicts with the read-only Nix store. Both are solvable with specific diagnostic steps that must be run before any LSP or treesitter configuration is declared "working." All other pitfalls (blink.cmp Rust build, Python venv detection, Neovim 0.11 API transition) are moderate and have clear mitigations.

## Key Findings

### Recommended Stack

The stack collapses from 5+ plugins with heavy transitive dependencies to 7 focused plugins. lazy.nvim stays as the plugin manager. fzf-lua is the single-plugin replacement for fzf.vim, telescope, commander, plenary, and fzf-native. blink.cmp replaces nvim-cmp and all its source plugins with a Rust-based fuzzy matcher (0.5-4ms async vs. nvim-cmp's 60ms debounce). nvim-treesitter manages grammar parsers; the native Neovim treesitter integration requires this plugin for grammar lifecycle management. modus-themes.nvim (miikanissi's port) replaces the hand-rolled inline colorscheme with proper LSP semantic token and treesitter highlight group coverage. LSP configuration uses Neovim 0.11 native APIs with per-server files in `lua/lsp/` — no Mason, no runtime downloads.

**Core technologies:**
- lazy.nvim: Plugin manager + bytecode compilation — already bootstrapped, keep
- blink.cmp: Completion engine — replaces nvim-cmp + 4-6 source plugins; built-in LSP/buffer/path/snippets
- nvim-treesitter: Syntax highlighting and indentation — handles grammar installation in writable location
- fzf-lua: Fuzzy finder + command palette — replaces fzf.vim + telescope + commander + plenary
- gitsigns.nvim: Git hunk signs + inline blame + hunk staging — zero dependencies, loads asynchronously
- neo-tree.nvim: Toggleable file tree — closed by default, loads on first keypress
- modus-themes.nvim: Colorscheme — modus_vivendi_tinted variant; full treesitter + LSP semantic token coverage

### Expected Features

The config must preserve existing muscle memory (Space leader, window navigation, `<leader>ff/fg/fb/fh`, `<leader><space>` command palette) while adding what a professional editor provides by default in 2025.

**Must have (table stakes):**
- LSP go-to-definition, hover, diagnostics, rename, code actions, references — Neovim 0.11 native bindings
- Syntax highlighting beyond regex for all 6 target languages
- Auto-triggered LSP completion with tab-to-accept — blink.cmp with built-in sources
- Git change signs in gutter with hunk navigation — gitsigns.nvim
- Toggleable file tree, closed by default — neo-tree.nvim

**Should have (differentiators):**
- Nix-managed LSP binaries with no Mason — reproducible across machines
- Inline git blame on current line — gitsigns `current_line_blame = true`
- Command palette that covers all new LSP bindings — fzf-lua `commands`/`keymaps` pickers
- Single auditable config — modular files but no mystery behavior

**Defer (v2+):**
- conform.nvim for formatter-per-language — only if LSP formatting proves insufficient
- Treesitter textobjects — only if va/vi motions feel missing in practice
- Diffview.nvim — only if gitsigns hunk workflow proves insufficient

### Architecture Approach

The config moves from a monolithic `init.lua` to a standard modular layout: `lua/config/` holds options/keymaps/autocmds with no plugin dependencies; `lua/plugins/` holds one file per plugin group (lazy.nvim scans this directory automatically); `lua/lsp/` holds per-server configs consumed by `vim.lsp.enable()`. The Nix-to-Neovim boundary is clean: Home Manager symlinks the whole `dotfiles/nvim/` directory to `~/.config/nvim`, lazy.nvim writes plugins and the lock file to `~/.local/share/nvim/` (writable), and LSP binaries are on PATH via Nix without hardcoded store paths.

**Major components:**
1. `init.lua` — Entry point only: set leader, load config/, bootstrap lazy, call `vim.lsp.enable()`
2. `lua/config/` — options.lua, keymaps.lua, autocmds.lua — unconditional, no plugin deps
3. `lua/plugins/` — one file per concern: ui.lua, editor.lua, finder.lua, lsp.lua, completion.lua, explorer.lua
4. `lua/lsp/` — per-server files (gopls.lua, pyright.lua, ts_ls.lua, lua_ls.lua, nil_ls.lua, ccls.lua)
5. lazy.nvim plugin store — `~/.local/share/nvim/lazy/` — writable, outside Nix store

**Build order for implementation:**
1. Extract options/keymaps/autocmds from `init.lua` → `lua/config/`
2. Add colorscheme (eager, priority 1000)
3. Add treesitter (BufReadPre, explicit parser list)
4. Add LSP infrastructure (`lsp/*.lua` + `vim.lsp.enable()` + LspAttach keymaps)
5. Add blink.cmp (depends on LSP capabilities being advertised first)
6. Add gitsigns (BufReadPre, independent)
7. Add fzf-lua (keys-triggered, independent)
8. Add neo-tree (keys-triggered, independent)

### Critical Pitfalls

1. **Nix PATH breaks LSP discovery** — LSP servers on Nix PATH are invisible to Neovim launched without shell profile. Verify with `vim.fn.exepath("gopls")` inside Neovim before writing any LSP config. Fix via shell profile propagation, not hardcoded store paths.

2. **treesitter `ensure_installed` conflicts with Nix store** — Runtime grammar compilation fails on read-only Nix store; built-in parsers conflict if treesitter also tries to install them. Use `ensure_installed = {}` and `auto_install = true` to defer compilation to first filetype open in writable `~/.local/share/nvim/`.

3. **blink.cmp Rust build failure** — blink.cmp requires its fuzzy matcher compiled via cargo. Must set `build = "cargo build --release"` in lazy spec and verify `vim.fn.exepath("cargo")` inside Neovim. Falls back silently to slow Lua implementation if build fails.

4. **rust-analyzer missing from packages.nix** — `rustc` and `cargo` are in packages.nix but `rust-analyzer` is not. Add it before writing Rust LSP config. Also add `lua-language-server` and `nixd` (or `nil`) which are similarly absent.

5. **Neovim 0.11 API transition** — Most tutorials still use `lspconfig.gopls.setup({})`. The native `vim.lsp.config()` + `vim.lsp.enable()` approach is preferred for new configs but must be chosen consistently. Mixing old and new patterns for the same server causes duplicate server starts.

## Implications for Roadmap

Based on research, the natural phase structure follows the implementation build order from ARCHITECTURE.md, with pitfall gates between phases.

### Phase 1: Foundation

**Rationale:** Everything else depends on a correct Nix-Neovim PATH integration, a working lazy.nvim structure, and the right packages in packages.nix. These checks must pass before writing any plugin config — failures here cause silent breakage downstream.

**Delivers:** Correct module structure, verified PATH, audited packages.nix, colorscheme plugin replacing hand-rolled code, treesitter with parsers loading on BufReadPre.

**Addresses:**
- Migrate `init.lua` options/keymaps/autocmds to `lua/config/`
- Add missing Nix packages: `rust-analyzer`, `lua-language-server`, `nixd`
- Replace hand-rolled colorscheme with modus-themes.nvim (eager load)
- Add nvim-treesitter with `auto_install = true` and explicit parser list

**Avoids:**
- PATH diagnostic must pass (`vim.fn.exepath("gopls")` non-empty) before Phase 2
- treesitter must pass `:checkhealth nvim-treesitter` before Phase 2
- Startup time measured at end of phase; target: <35ms cold start

### Phase 2: LSP + Completion

**Rationale:** LSP and completion are tightly coupled — blink.cmp must advertise capabilities to LSP servers before they attach. This phase implements both together in order: LSP infrastructure first, then blink.cmp.

**Delivers:** Full LSP for Go, Python, TypeScript, Nix, Lua, Rust, C/C++. Auto-triggered completion with LSP/buffer/path sources. All Neovim 0.11 default LSP keymaps working (`gd`, `K`, `grn`, `gra`, `grr`, `[d`/`]d`).

**Uses:** nvim-lspconfig (for server default configs) + `vim.lsp.enable()` (native 0.11 API), blink.cmp with `build = "cargo build --release"`, per-server `lua/lsp/*.lua` files.

**Implements:** Pattern 1 (Nix-managed LSP via native API), Pattern 3 (LspAttach autocmd for keymaps), blink.cmp capability advertisement before server attach.

**Avoids:**
- Decide lspconfig vs native approach at phase start — do not mix
- Verify `cargo` on PATH before implementing blink.cmp
- Test Python venv import resolution as acceptance criterion

### Phase 3: Editor Experience

**Rationale:** Git signs, file tree, and fuzzy finder are independent of LSP and each other. They load on-demand. This phase completes the "IDE feeling" without touching the critical LSP infrastructure.

**Delivers:** gitsigns (gutter signs, inline blame, hunk nav), fzf-lua replacing fzf.vim + commander.nvim (files, grep, buffers, commands, keymaps pickers), neo-tree replacing netrw as toggleable sidebar.

**Addresses:**
- Remove fzf.vim, commander.nvim, telescope (and plenary dependency)
- All new bindings registered in fzf-lua's commands picker (`<leader><space>`)
- gitsigns hunk staging keymaps (`<leader>hp`, `<leader>hs`, `<leader>hr`)

**Avoids:**
- neo-tree netrw conflict: set `vim.g.loaded_netrw = 1` before neo-tree loads
- gitsigns must load on BufReadPost (not VeryLazy) to attach on first file open
- Startup time still measured; fzf-lua/neo-tree must cost 0ms (keys-triggered)

### Phase Ordering Rationale

- Phase 1 first because PATH and package gaps cause silent failures throughout all subsequent phases. No point writing LSP configs if `gopls` isn't visible.
- Phase 2 before Phase 3 because LSP and completion are infrastructure that editor experience features (gitsigns, fzf-lua pickers for LSP symbols) depend on.
- Phase 3 last because fzf-lua, gitsigns, and neo-tree are independent of each other and load on demand — they pose no sequencing risk and can be done in any order within the phase.

### Research Flags

Phases needing deeper research during planning:
- **Phase 2:** Python virtual environment detection with pylsp vs pyright warrants specific investigation. The research identifies pyright as better at venv auto-detection but it is not currently in packages.nix. Confirm which Python LSP server to use before implementing.
- **Phase 2:** blink.cmp Rust build in the lazy.nvim context has known Nix issues (nixpkgs issue #386404). If build fails during implementation, the fallback to nvim-cmp is documented and should be pre-planned.

Phases with standard patterns (skip additional research):
- **Phase 1:** Module structure migration and packages.nix audit are mechanical. lazy.nvim scanning of `lua/plugins/` is official documented behavior. Colorscheme plugin installation is trivial.
- **Phase 3:** gitsigns, fzf-lua, and neo-tree are well-documented with no Nix-specific gotchas. Their lazy.nvim specs are provided in STACK.md and are copy-implementable.

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Core plugin choices verified against official docs, community benchmarks, and LazyVim's own migrations. Startup time figures are MEDIUM (community estimates, no single authoritative benchmark). |
| Features | HIGH | LSP keybindings and UX behaviors verified against Neovim 0.11 official changelog. Completion UX verified against blink.cmp README. Feature prioritization is opinionated but well-grounded. |
| Architecture | HIGH | Module structure, lazy loading patterns, and Nix symlink behavior all verified against official lazy.nvim docs, Home Manager docs, and Neovim core contributor blog posts. |
| Pitfalls | HIGH | All critical pitfalls verified via official GitHub issues, NixOS Discourse threads, and official Neovim 0.11 changelog. Recovery strategies are tested community patterns. |

**Overall confidence:** HIGH

### Gaps to Address

- **Python LSP choice (pylsp vs pyright):** Research identifies pyright as better for venv detection but doesn't confirm whether the existing pylsp config is causing real pain. Validate in Phase 2 by testing with a real `.venv` project. If pylsp resolves venv imports correctly, keep it; otherwise add pyright to packages.nix.
- **Startup time figures:** STACK.md estimates 25-50ms are based on community benchmarks with no single authoritative source. Run `nvim --startuptime /tmp/nvim-startup.log +q` as the actual measurement at the end of each phase.
- **lua-language-server availability:** STACK.md recommends `pkgs.lua-language-server` but the current packages.nix hasn't been audited against this. Confirm the package name resolves in nixpkgs 25.05 during Phase 1.

## Sources

### Primary (HIGH confidence)
- [lazy.nvim Structuring Plugins docs](https://lazy.folke.io/usage/structuring) — module scanning, loading patterns
- [lazy.nvim lazy loading spec](https://lazy.folke.io/spec/lazy_loading) — event/keys/cmd triggers
- [What's New in Neovim 0.11](https://gpanders.com/blog/whats-new-in-neovim-0-11/) — vim.lsp.config/enable APIs (written by Neovim core contributor)
- [conform.nvim README](https://github.com/stevearc/conform.nvim) — BufWritePre lazy loading pattern
- [NixOS Wiki: Treesitter](https://nixos.wiki/wiki/Treesitter) — parser management, Nix conflicts
- [NixOS/nixpkgs Issue #189838](https://github.com/NixOS/nixpkgs/issues/189838) — nvim-treesitter declarative install errors
- [NixOS/nixpkgs Issue #386404](https://github.com/NixOS/nixpkgs/issues/386404) — blink-cmp Nix startup errors
- [Home Manager mkOutOfStoreSymlink pattern](https://discourse.nixos.org/t/neovim-config-read-only/35109) — read-only config handling

### Secondary (MEDIUM confidence)
- [fzf-lua GitHub](https://github.com/ibhagwan/fzf-lua) — builtin pickers catalog
- [blink.cmp GitHub](https://github.com/saghen/blink.cmp) — performance claims, capabilities API
- [LazyVim fzf-lua vs telescope discussion](https://github.com/LazyVim/LazyVim/discussions/3619) — community performance comparison
- [Neovim config for 2025 — Chris Arderne](https://rdrn.me/neovim-2025/) — plugin selection rationale
- [NixOS Discourse: LSP with Nix-managed binaries](https://discourse.nixos.org/t/i-need-help-setting-up-lsp-for-neovim-using-lspconfig-language-server-binaries/65455) — PATH and cmd configuration
- [blink.cmp vs nvim-cmp comparison](https://gist.github.com/Saghen/e731f6f6e30a4c01f6bc7cdaa389d463) — by blink.cmp author
- [Debloating Neovim — rootknecht.net](https://rootknecht.net/blog/debloating-neovim-config/) — anti-patterns and startup optimization
- [miikanissi/modus-themes.nvim](https://github.com/miikanissi/modus-themes.nvim) — treesitter/LSP semantic token support

### Tertiary (LOW confidence / supporting)
- [dotfyle.com trending colorschemes 2025](https://dotfyle.com/neovim/colorscheme/trending) — ecosystem popularity
- [The tree-sitter packaging mess](https://ayats.org/blog/tree-sitter-packaging) — Nix treesitter analysis
- [lazy.nvim: Don't use dependencies](https://dev.to/delphinus35/dont-use-dependencies-in-lazynvim-4bk0) — loading anti-pattern

---
*Research completed: 2026-02-26*
*Ready for roadmap: yes*
