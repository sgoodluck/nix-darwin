---
phase: 02-lsp-completion
verified: 2026-02-26T19:30:00Z
status: human_needed
score: 5/5 automated must-haves verified
re_verification: false
human_verification:
  - test: "Open Go file and run :LspInfo — confirm gopls attaches"
    expected: "gopls shows as active client for the buffer"
    why_human: "Cannot invoke live Neovim session programmatically to test LSP attachment"
  - test: "Open Python file and run :LspInfo — confirm pyright attaches"
    expected: "pyright shows as active client for the buffer"
    why_human: "Cannot invoke live Neovim session programmatically to test LSP attachment"
  - test: "Open Nix file (e.g. flake.nix) and run :LspInfo — confirm nixd attaches"
    expected: "nixd shows as active client for the buffer"
    why_human: "Cannot invoke live Neovim session programmatically to test LSP attachment"
  - test: "Open Lua file and run :LspInfo — confirm lua_ls attaches"
    expected: "lua_ls shows as active client for the buffer"
    why_human: "Cannot invoke live Neovim session programmatically to test LSP attachment"
  - test: "In a Lua file type 'vim.' and confirm completion popup appears with Neovim API items"
    expected: "blink.cmp popup shows vim.* completions sourced via lazydev.nvim"
    why_human: "Completion popup is visual/interactive behavior"
  - test: "In a Python file introduce a type error (e.g. x = 1 + 'str'), confirm inline virtual text warning appears without running any command"
    expected: "Pyright diagnostic appears as virtual text with a gutter sign"
    why_human: "Diagnostic rendering is visual behavior inside a running Neovim session"
  - test: "Open a Lua file, add wrong indentation, save with :w — confirm stylua reformats it"
    expected: "File is reformatted on save by conform.nvim using stylua"
    why_human: "Format-on-save side-effect requires a live buffer and save event"
  - test: "In a buffer with LSP attached, press gd on a symbol — confirm go-to-definition works"
    expected: "Cursor jumps to definition location in source code"
    why_human: "Keymap behavior in response to LSP navigation is not verifiable statically"
  - test: "Run: nvim --startuptime /tmp/startup.log +q && tail -1 /tmp/startup.log"
    expected: "Total startup time is under 100ms"
    why_human: "Startup time measurement requires running Neovim on the actual system"
  - test: "Run: which pyright stylua rustfmt — confirm all three binaries are on PATH after nxr rebuild"
    expected: "All three binaries resolve to Nix store paths"
    why_human: "PATH state depends on whether nxr (darwin-rebuild switch) has been run — not verifiable from the repository state alone"
---

# Phase 2: LSP + Completion Verification Report

**Phase Goal:** All six target languages have active LSP servers, autocompletion triggers automatically from LSP/buffer/path sources, diagnostics appear inline, and code formatting runs on save
**Verified:** 2026-02-26T19:30:00Z
**Status:** human_needed
**Re-verification:** No — initial verification

## Goal Achievement

### Observable Truths

| # | Truth | Status | Evidence |
|---|-------|--------|----------|
| 1 | LSP servers configured for all 7 target languages (Nix, Python, TS, Go, Rust, C, Lua) | VERIFIED | `lsp.lua:25` — `vim.lsp.enable({ "nixd", "pyright", "ts_ls", "gopls", "rust_analyzer", "ccls", "lua_ls" })` |
| 2 | Autocompletion popup from LSP, buffer, and path sources | VERIFIED | `completion.lua:28` — `sources.default = { "lazydev", "lsp", "path", "buffer" }` with `saghen/blink.cmp version = "1.*"` |
| 3 | Inline diagnostics as virtual text with gutter signs | VERIFIED | `lsp.lua:48-64` — `vim.diagnostic.config()` with `virtual_text`, `signs.text` nerd font icons, `underline = true` |
| 4 | LSP keymaps (gd, gr, K, leader-la/lr/lf/ld/lD) bind only on LspAttach | VERIFIED | `lsp.lua:28-45` — `LspAttach` autocmd with `augroup lsp_keymaps`, 8 buffer-local `vim.keymap.set("n", ...)` mappings |
| 5 | Format-on-save for all configured languages | VERIFIED | `formatting.lua:9-19` — 9 `formatters_by_ft` entries; `format_on_save = { timeout_ms = 500, lsp_format = "fallback" }` |
| 6 | Lua language server provides Neovim API completions via lazydev.nvim | VERIFIED | `completion.lua:7-13` — `folke/lazydev.nvim` with `ft = "lua"`, blink source `lazydev.integrations.blink` at score_offset 100 |
| 7 | pyright, stylua, and rustfmt binaries in Nix packages | VERIFIED | `packages.nix:70,94,99` — `pyright`, `rustfmt`, `stylua` in correct language sections |

**Score:** 7/7 truths verified (configuration layer)

Note: Truths 1-7 above verify the configuration exists and is correctly wired. Whether those configurations produce the expected runtime behavior (LSP attachment, completion popup, diagnostics visible, format triggering, binary on PATH) requires human verification in a live Neovim session after `nxr` rebuild — see Human Verification Required section.

### Required Artifacts

| Artifact | Expected | Status | Details |
|----------|----------|--------|---------|
| `modules/common/packages.nix` | pyright, stylua, rustfmt Nix packages | VERIFIED | Line 70: `pyright` (with comment); line 94: `rustfmt` (after rust-analyzer); line 99: `stylua` (after nixd) |
| `dotfiles/nvim/lua/plugins/lsp.lua` | LSP server config, keymaps, diagnostics | VERIFIED | 66 lines — `vim.lsp.config/enable` (Neovim 0.11 native API), 8 LspAttach keymaps, full diagnostic config |
| `dotfiles/nvim/lua/plugins/completion.lua` | blink.cmp + lazydev.nvim completion engine | VERIFIED | 41 lines — two-spec table (lazydev.nvim + blink.cmp), enter preset, no ghost text, lazydev source wired |
| `dotfiles/nvim/lua/plugins/formatting.lua` | conform.nvim format-on-save | VERIFIED | 24 lines — 9 formatters mapped, BufWritePre event, silent mode (both notify flags false) |

All artifacts are substantive (not stubs). None are orphaned — `lazy.setup("plugins")` in `init.lua:23` auto-scans `lua/plugins/` and picks up all three files automatically.

### Key Link Verification

| From | To | Via | Status | Details |
|------|----|-----|--------|---------|
| `lsp.lua` | `completion.lua` | `require("blink.cmp").get_lsp_capabilities()` | WIRED | `lsp.lua:9` calls `require("blink.cmp").get_lsp_capabilities()`, result passed to `vim.lsp.config("*", ...)` at line 10 |
| `completion.lua` | `lsp.lua` | `lazydev.integrations.blink` source | WIRED | `completion.lua:32` — `module = "lazydev.integrations.blink"` wires lazydev completions into blink.cmp for Lua LSP |
| `formatting.lua` | `modules/common/packages.nix` | formatters must be on PATH for conform.nvim | WIRED (config) | `formatting.lua:9-19` lists all formatters; `packages.nix` provides: `nixfmt-rfc-style` (line 19), `black` via python3.withPackages, `prettier` (line 77), `gofmt` via `go` package, `rustfmt` (line 94), `clang-tools` (line 52, provides clang-format), `stylua` (line 99). Note: PATH availability requires `nxr` rebuild — human verification needed |
| `lsp.lua` keymaps | `formatting.lua` | `<leader>lf` calls `require("conform").format()` | WIRED | `lsp.lua:41` — `require("conform").format({ bufnr = buf })` in the LspAttach keymap |
| `init.lua` | `lua/plugins/*.lua` | `lazy.setup("plugins")` auto-scan | WIRED | `init.lua:23` — `require("lazy").setup("plugins", ...)` auto-scans `lua/plugins/`; lsp.lua, completion.lua, formatting.lua all exist in that directory |

### Requirements Coverage

| Requirement | Description | Status | Evidence |
|-------------|-------------|--------|----------|
| LSP-01 | LSP active for Nix (nixd), Python (pyright), TypeScript (ts_ls), Go (gopls), Rust (rust_analyzer), C/C++ (ccls) | SATISFIED (config) | `lsp.lua:25` — all 6 servers in `vim.lsp.enable()` list. Runtime attachment requires human verification |
| LSP-02 | Autocompletion via blink.cmp with LSP, buffer, and path sources | SATISFIED (config) | `completion.lua:28` — `sources.default = { "lazydev", "lsp", "path", "buffer" }` |
| LSP-03 | Inline diagnostics with signs and virtual text | SATISFIED (config) | `lsp.lua:48-64` — full `vim.diagnostic.config()` with virtual_text and signs.text |
| LSP-04 | LSP keymaps on attach (go-to-definition, references, rename, hover, code actions) | SATISFIED (config) | `lsp.lua:28-45` — gd (definition), gr (references), K (hover), `<leader>la` (code_action), `<leader>lr` (rename) all wired via LspAttach |
| LSP-05 | Format-on-save via conform.nvim for all configured languages | SATISFIED (config) | `formatting.lua` — 9 languages with BufWritePre trigger and `format_on_save` |
| LSP-06 | Nix PATH verified — all LSP servers resolvable from inside Neovim | NEEDS HUMAN | Binaries added to `packages.nix`, but PATH availability depends on `nxr` rebuild having been run. SUMMARY-02 claims verified but this is a runtime check |
| LSP-07 | Lua language server configured for Neovim API completions | SATISFIED (config) | `completion.lua:7-13` — lazydev.nvim with `ft = "lua"` and blink integration; `lsp.lua:13-22` — lua_ls with LuaJIT runtime and vim globals |

All 7 LSP-* requirements have configuration-layer evidence. SUMMARY-02 documents human verification as passed. LSP-06 (PATH) and LSP-01/02/03/04/05 runtime behavior remain human-only verifiable.

**Orphaned requirements:** None. All requirements mapped to Phase 2 in REQUIREMENTS.md traceability table are covered by the two plans.

### Anti-Patterns Found

| File | Line | Pattern | Severity | Impact |
|------|------|---------|----------|--------|
| None | — | — | — | No anti-patterns detected |

Scanned for: TODO/FIXME/PLACEHOLDER comments, empty returns (`return null`, `return {}`, `return []`), debug logging, deprecated `require('lspconfig')` calls.

`require('lspconfig')` check: only appears in a comment on line 2 of lsp.lua explaining why it is NOT used. No actual usage. PASS.

### Human Verification Required

All automated configuration checks pass. The following items require live Neovim session verification. SUMMARY-02 documents that a human verified these during plan execution, but as a verifier I cannot confirm runtime behavior from static analysis.

#### 1. LSP Attachment — All 7 Servers

**Test:** Open files of each type and run `:LspInfo`:
- `nvim /tmp/test.go` → `:LspInfo` — expect gopls active
- `nvim /tmp/test.py` → `:LspInfo` — expect pyright active
- `nvim ~/nix/flake.nix` → `:LspInfo` — expect nixd active
- `nvim ~/nix/dotfiles/nvim/lua/plugins/lsp.lua` → `:LspInfo` — expect lua_ls active
- Test .ts, .rs, .c files similarly for ts_ls, rust_analyzer, ccls

**Expected:** Each file type shows exactly one active LSP client matching the configured server
**Why human:** Live Neovim session with LSP servers running on PATH required

#### 2. Completion Popup

**Test:** In a Go file, type `fmt.` and observe; in a Lua file, type `vim.` and observe
**Expected:** blink.cmp popup appears with LSP suggestions; no ghost/inline preview text; Tab or Enter accepts; lazydev provides vim.* completions in Lua files
**Why human:** Completion popup is interactive visual behavior

#### 3. Inline Diagnostics

**Test:** In a Python file, write `x: int = 1 + "string"` and wait briefly
**Expected:** Virtual text appears inline (showing warning or error); gutter shows diagnostic icon
**Why human:** Diagnostic rendering requires pyright to run and report to Neovim

#### 4. LSP Keymaps

**Test:** In a Go file with a symbol under cursor, press `gd`, `K`, and `<leader>la`
**Expected:** `gd` jumps to definition; `K` shows hover docs in floating window; `<leader>la` shows code actions menu
**Why human:** Keymap behavior requires live LSP connection and cursor position

#### 5. Format-on-Save

**Test:** Add misformatted Lua (wrong indentation), save with `:w`; repeat for Python and Nix
**Expected:** File is reformatted automatically on each save
**Why human:** Requires BufWritePre event and formatter binary on PATH to execute

#### 6. Binary PATH Verification

**Test:** After `nxr` rebuild: `which pyright stylua rustfmt`
**Expected:** All three resolve to Nix store paths
**Why human:** PATH state depends on whether system rebuild was applied; cannot verify from repository

#### 7. Startup Time

**Test:** `nvim --startuptime /tmp/startup.log +q && tail -1 /tmp/startup.log`
**Expected:** Total under 100ms (FNDN-05 budget, which passed in Phase 1 at 34ms baseline)
**Why human:** Requires running Neovim on the actual hardware

### Gaps Summary

No configuration gaps found. All artifacts exist, are substantive, and are correctly wired together. The phase goal is achievable with the code as written.

The `human_needed` status reflects that LSP attachment, completion popup, diagnostics, keymaps, and format-on-save are runtime behaviors that require a live Neovim session to confirm. SUMMARY-02 documents that human verification was conducted and passed during plan execution. If that human confirmation is accepted as evidence, the phase goal is fully achieved.

---

_Verified: 2026-02-26T19:30:00Z_
_Verifier: Claude (gsd-verifier)_
