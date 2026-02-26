# Phase 2: LSP + Completion - Context

**Gathered:** 2026-02-26
**Status:** Ready for planning

<domain>
## Phase Boundary

Configure LSP servers for all 7 target languages (Nix, Python, TypeScript, Go, Rust, C/C++, Lua), autocompletion via blink.cmp, inline diagnostics, LSP keymaps on attach, format-on-save via conform.nvim, and Lua LSP with Neovim API awareness. No fuzzy finder, no git integration, no file tree — those are Phase 3.

</domain>

<decisions>
## Implementation Decisions

### Completion behavior
- Auto-trigger on typing — not too aggressive, standard delay
- Tab/Enter to accept, Escape to dismiss
- Show LSP, buffer, and path sources
- Keep it minimal and fast — Primeagen-style, stays out of the way
- No ghost text / inline preview — just the popup menu

### Diagnostics display
- Virtual text inline for errors and warnings (standard Neovim defaults)
- Signs in the gutter with severity icons
- Don't be too noisy — show errors prominently, warnings subtly

### Format-on-save
- Use conform.nvim for all languages
- Standard formatters: nixfmt (Nix), black (Python), prettier (TS/JS), gofmt (Go), rustfmt (Rust), clang-format (C/C++), stylua (Lua)
- If no formatter available for a filetype, skip silently — don't error
- Format full file on save, not just changed lines

### LSP keybind layout
- All LSP binds under `<leader>l` prefix group
- Standard mappings: gd (go-to-def), gr (references), K (hover) can stay as top-level
- Code actions, rename, format under `<leader>l`
- Only bind on LspAttach — no binds if no LSP server for the buffer

### Python LSP choice
- Use pyright (add to packages.nix) — it's the standard, fast, good type checking
- Not pylsp — pyright is better for the "fast and lightweight" philosophy

### Neovim 0.11 LSP approach
- Use nvim-lspconfig for server configuration — saves boilerplate across 7 servers
- Don't use native vim.lsp.config()/vim.lsp.enable() yet — lspconfig is more battle-tested
- One plugin file: lua/plugins/lsp.lua containing lspconfig setup + all server configs
- blink.cmp capabilities must be passed to each server

### Claude's Discretion
- Exact blink.cmp configuration options and keybinds
- conform.nvim formatter configuration details
- Diagnostic severity levels and sign characters
- Whether to split LSP config into multiple files or keep in one
- pyright configuration options (type checking level, etc.)

</decisions>

<specifics>
## Specific Ideas

- Primeagen-style: fast, lightweight, capable but not in your face
- pyright needs to be added to packages.nix (like we did with lua-language-server/nixd/rust-analyzer in Phase 1)
- stylua is already available as a Nix package for Lua formatting
- nixfmt-rfc-style is already in packages.nix
- All formatters referenced by conform.nvim should already be on PATH via Nix packages — verify during research

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 02-lsp-completion*
*Context gathered: 2026-02-26*
