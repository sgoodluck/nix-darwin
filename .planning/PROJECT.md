# Neovim Configuration

## What This Is

A blazingly fast, minimal Neovim IDE configuration managed through the Nix dotfiles repository. 8 plugins provide full LSP coverage for 7 languages, autocompletion, format-on-save, fuzzy finding, git integration, and a toggleable file tree -- all with a 34ms cold start.

## Core Value

Fast, capable editing across all development languages with the fewest plugins possible -- every plugin must earn its place.

## Requirements

### Validated

- ✓ LSP support for all installed languages (Nix, Python, TS, Go, Rust, C/C++, Lua) -- v1.0
- ✓ Autocompletion with LSP integration (blink.cmp with LSP/buffer/path sources) -- v1.0
- ✓ Treesitter for syntax highlighting (12 parsers) -- v1.0
- ✓ Fast fuzzy finder: files, text, buffers (fzf-lua) -- v1.0
- ✓ Git integration: gutter signs and hunk navigation (gitsigns) -- v1.0
- ✓ Toggleable file tree sidebar, closed by default (neo-tree) -- v1.0
- ✓ Toggleable command palette via fzf-lua keymaps browser -- v1.0
- ✓ Well-maintained colorscheme with LSP/treesitter support (modus-themes.nvim) -- v1.0
- ✓ Fast startup time: 34ms measured, under 100ms target -- v1.0
- ✓ Format-on-save for 9 filetypes via conform.nvim -- v1.0
- ✓ Inline diagnostics with signs and virtual text -- v1.0
- ✓ Lua language server configured for Neovim API completions (lazydev.nvim) -- v1.0

### Active

(None -- planning next milestone)

### Out of Scope

- DAP/Debugger integration -- use external tools, adds complexity
- Note-taking/org-mode plugins -- use Emacs for that
- AI/copilot plugins -- use Claude Code externally
- Custom statusline plugin -- keep it simple or use a minimal one
- Session management -- not needed for a fast editor workflow
- Mason.nvim -- redundant, Nix manages all LSP servers

## Context

Shipped v1.0 with 399 LOC Lua across 12 files.
Tech stack: lazy.nvim, modus-themes.nvim, nvim-treesitter, nvim-lspconfig (server defs only), blink.cmp, lazydev.nvim, conform.nvim, fzf-lua, gitsigns.nvim, neo-tree.nvim.
All LSP servers installed via Nix packages.nix, not Mason. Neovim 0.11 native LSP API used throughout.
Config lives in `dotfiles/nvim/`, symlinked to `~/.config/nvim` via Home Manager.

## Constraints

- **Plugin count**: Minimum viable set -- every plugin must justify its inclusion (8 plugins at v1.0)
- **Startup time**: Must feel instant (< 100ms cold start, 34ms achieved)
- **Package manager**: lazy.nvim with directory auto-scan
- **Config structure**: `init.lua` (26-line bootstrap) + `lua/config/` + `lua/plugins/`
- **Nix integration**: LSP servers installed via Nix, not Mason

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| lazy.nvim for plugin management | Already bootstrapped, best lazy-loading support | ✓ Good -- 8 plugins, 34ms startup |
| Nix-managed LSP servers | Reproducible, already in packages.nix | ✓ Good -- no Mason needed, all 7 servers work |
| Space as leader key | User preference, Spacemacs muscle memory | ✓ Good -- consistent keybind namespace |
| Neovim 0.11 native LSP API | vim.lsp.config/enable replaces deprecated lspconfig setup | ✓ Good -- cleaner, future-proof |
| blink.cmp over nvim-cmp | Faster, simpler config, enter preset | ✓ Good -- works with Nix build |
| nvim-treesitter branch=master | New main branch removed configs.setup() API | ✓ Good -- required for current API |
| modus-themes.nvim | Proper treesitter/LSP highlight groups, bg_main override | ✓ Good -- matches terminal theme |
| fzf-lua over telescope | Replaces fzf.vim + telescope + commander with one plugin | ✓ Good -- fewer deps, faster |
| conform.nvim silent mode | No format notifications per user preference | ✓ Good -- no noise |
| Plugin-per-file in lua/plugins/ | lazy.setup("plugins") auto-scan, new plugin = new file only | ✓ Good -- modular, no init.lua edits |

---
*Last updated: 2026-02-26 after v1.0 milestone*
