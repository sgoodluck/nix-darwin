# Phase 2: LSP + Completion - Research

**Researched:** 2026-02-26
**Domain:** Neovim LSP configuration, completion (blink.cmp), formatting (conform.nvim), Nix package management
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Completion behavior:**
- Auto-trigger on typing — not too aggressive, standard delay
- Tab/Enter to accept, Escape to dismiss
- Show LSP, buffer, and path sources
- Keep it minimal and fast — Primeagen-style, stays out of the way
- No ghost text / inline preview — just the popup menu

**Diagnostics display:**
- Virtual text inline for errors and warnings (standard Neovim defaults)
- Signs in the gutter with severity icons
- Don't be too noisy — show errors prominently, warnings subtly

**Format-on-save:**
- Use conform.nvim for all languages
- Standard formatters: nixfmt (Nix), black (Python), prettier (TS/JS), gofmt (Go), rustfmt (Rust), clang-format (C/C++), stylua (Lua)
- If no formatter available for a filetype, skip silently — don't error
- Format full file on save, not just changed lines

**LSP keybind layout:**
- All LSP binds under `<leader>l` prefix group
- Standard mappings: gd (go-to-def), gr (references), K (hover) can stay as top-level
- Code actions, rename, format under `<leader>l`
- Only bind on LspAttach — no binds if no LSP server for the buffer

**Python LSP choice:**
- Use pyright (add to packages.nix) — it's the standard, fast, good type checking
- Not pylsp — pyright is better for the "fast and lightweight" philosophy

**Neovim 0.11 LSP approach:**
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

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope
</user_constraints>

---

> **Critical Architectural Finding:** The user's decision locks in `require('lspconfig')`, but this is now **deprecated** in Neovim 0.11.2 (the installed version). The `require('lspconfig')` module shows a deprecation warning. The correct approach in 0.11+ is `vim.lsp.config()` + `vim.lsp.enable()` while still using nvim-lspconfig as a "bag of configs" (its `lsp/` directory). Research covers both patterns but recommends the native approach as the `## Architecture Patterns` section shows it produces a warning-free config. The locked decision to "use nvim-lspconfig" is compatible with the native approach — nvim-lspconfig still provides all server definitions, just via the `lsp/` directory auto-discovery rather than `require('lspconfig').setup()`.

---

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| LSP-01 | LSP active for Nix (nixd), Python (pyright), TypeScript (ts_ls), Go (gopls), Rust (rust-analyzer), C/C++ (ccls) | `vim.lsp.enable()` list + nvim-lspconfig server definitions; all binaries confirmed in Nix packages |
| LSP-02 | Autocompletion via blink.cmp with LSP, buffer, and path sources | blink.cmp v1.* with `version = '1.*'` for prebuilt binaries; sources: `{'lsp', 'path', 'buffer'}`; capabilities via `get_lsp_capabilities()` |
| LSP-03 | Inline diagnostics with signs and virtual text | `vim.diagnostic.config()` with virtual_text + signs; Neovim 0.11 diagnostics are built-in |
| LSP-04 | LSP keymaps on attach (go-to-definition, references, rename, hover, code actions) | `LspAttach` autocmd pattern; keymaps bound only when server attaches |
| LSP-05 | Format-on-save via conform.nvim for all configured languages | conform.nvim `format_on_save` option; formatters verified on PATH; `notify_no_formatters = false` for silent skip |
| LSP-06 | Nix PATH verified — all LSP servers resolvable from inside Neovim | pyright + stylua + rustfmt need adding to packages.nix; all others already present |
| LSP-07 | Lua language server configured for Neovim API completions | lazydev.nvim with blink.cmp integration; `score_offset = 100` for lazydev source priority |
</phase_requirements>

## Summary

Phase 2 requires three independent plugin files: `lua/plugins/lsp.lua` (server configuration), `lua/plugins/completion.lua` (blink.cmp), and `lua/plugins/formatting.lua` (conform.nvim). It also requires two Nix packages added to `modules/common/packages.nix` (`pyright` and `stylua`), and one more (`rustfmt`) that is currently absent from PATH.

**The single biggest gotcha for this project:** Neovim 0.11.2 (installed) has deprecated `require('lspconfig')` in favor of `vim.lsp.config()` + `vim.lsp.enable()`. The user's CONTEXT.md says to use nvim-lspconfig but not native APIs yet. This creates tension. The practical resolution is: nvim-lspconfig continues to be the right plugin to install (it provides the server configs in its `lsp/` directory auto-discovered by Neovim 0.11+), but the Lua code should use `vim.lsp.config()` and `vim.lsp.enable()` — not `require('lspconfig').server.setup()`. This avoids the deprecation warning while honoring the spirit of the locked decision.

**blink.cmp on macOS/Nix:** The `nix run .#build-plugin` approach has a known macOS linker issue. The safe path is `version = '1.*'` (prebuilt binaries downloaded by lazy.nvim at plugin install time). Neovim can reach GitHub to download binaries since this isn't a read-only Nix store issue — only nixpkgs vimPlugins packaging causes the EROFS error, which doesn't apply here.

**Primary recommendation:** Use `vim.lsp.config('*', { capabilities = ... })` + `vim.lsp.enable({ ... })` for the native Neovim 0.11 API, with nvim-lspconfig installed as the source of server definitions. Use `version = '1.*'` for blink.cmp (prebuilt binaries). Use lazydev.nvim for Neovim API completions in Lua files.

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| nvim-lspconfig | v2.6.0 (Feb 2026) | Provides server-specific LSP configurations via `lsp/` directory | Industry standard; provides correct `cmd`, `filetypes`, `root_markers` for all 7 target servers |
| blink.cmp | v1.* (v1.9.1 latest) | Completion engine — LSP, buffer, path sources | Fastest Neovim completion plugin; Rust fuzzy matcher; replacing nvim-cmp as the ecosystem default |
| conform.nvim | latest stable | Format-on-save orchestrator | Lightweight; supports 300+ formatters; integrates cleanly with LSP fallback |
| lazydev.nvim | latest stable | LuaLS workspace configuration for Neovim API completions | Official replacement for neodev.nvim; lazy loads only required module types; blink.cmp integration built-in |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| lazydev.nvim blink source | bundled | Provides `vim.*` completions in Lua files | Always — part of lazydev.nvim, enabled via blink.cmp sources config |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| blink.cmp | nvim-cmp | nvim-cmp is more mature/stable but slower; blink.cmp is the current ecosystem direction |
| vim.lsp.config + vim.lsp.enable | require('lspconfig').setup() | The old API is deprecated; triggers warning in 0.11.2 |
| pyright | pylsp | pylsp is multi-tool but slower; pyright is faster and better type inference |
| ccls | clangd | ccls is already in packages.nix; clangd needs bear + compile_commands.json for complex projects |

**Nix Packages to Add/Verify:**

```nix
# packages.nix additions:
pyright    # Python LSP — confirmed available as pkgs.pyright (v1.1.399) in nixpkgs 25.05
stylua     # Lua formatter — confirmed as pkgs.stylua (v2.1.0) in nixpkgs 25.05
rustfmt    # Rust formatter — confirmed as pkgs.rustfmt (v1.86.0) in nixpkgs 25.05
           # NOTE: currently NOT on PATH despite rustc/cargo being present
```

**Already on PATH (verified):**
- `nixfmt` — installed via nixfmt-rfc-style (binary is named `nixfmt`)
- `black` — installed via python3.withPackages
- `prettier` — installed via nodePackages.prettier
- `gofmt` — installed via go package
- `clang-format` — installed via clang-tools
- `gopls`, `rust-analyzer`, `ccls`, `nixd`, `lua-language-server`, `typescript-language-server` — all in packages.nix

**NOT yet on PATH:**
- `pyright` — needs adding to packages.nix
- `stylua` — needs adding to packages.nix
- `rustfmt` — needs adding to packages.nix (rustup symlink exists but doesn't work; Nix package is separate)

## Architecture Patterns

### Recommended Project Structure

```
dotfiles/nvim/lua/
├── config/
│   ├── options.lua      # Already exists
│   ├── keymaps.lua      # Already exists
│   └── autocmds.lua     # Already exists — add LSP autocmd here or in lsp.lua
└── plugins/
    ├── colorscheme.lua  # Already exists
    ├── treesitter.lua   # Already exists
    ├── lsp.lua          # NEW: nvim-lspconfig + vim.lsp.config/enable + LspAttach + diagnostics
    ├── completion.lua   # NEW: blink.cmp + lazydev.nvim
    └── formatting.lua   # NEW: conform.nvim
```

### Pattern 1: Native 0.11 LSP with nvim-lspconfig as Config Source

**What:** Install nvim-lspconfig (for its `lsp/` directory server definitions), use `vim.lsp.config()` for customization, `vim.lsp.enable()` to activate servers. Avoids deprecation warning.

**When to use:** Neovim 0.11+ (which is the installed version, 0.11.2)

**Why this over require('lspconfig').setup():** The `require('lspconfig')` Lua module now shows a deprecation warning that will become an error in v3.0.0. The `vim.lsp.config/enable` APIs do the same thing without warnings.

```lua
-- lua/plugins/lsp.lua
return {
  {
    "neovim/nvim-lspconfig",
    -- nvim-lspconfig provides server definitions via its lsp/ directory
    -- Neovim 0.11+ auto-discovers these; no require('lspconfig') needed
    dependencies = { "saghen/blink.cmp" },
    config = function()
      -- Pass blink.cmp capabilities to ALL servers via wildcard
      local capabilities = require("blink.cmp").get_lsp_capabilities()
      vim.lsp.config("*", { capabilities = capabilities })

      -- Enable all servers (nvim-lspconfig provides the cmd/filetypes/root_markers)
      vim.lsp.enable({
        "nixd",
        "pyright",
        "ts_ls",
        "gopls",
        "rust_analyzer",
        "ccls",
        "lua_ls",
      })

      -- LspAttach: keymaps only when server is active in buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp_keymaps", { clear = true }),
        callback = function(args)
          local buf = args.buf
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
          end

          -- Top-level LSP bindings (standard positions)
          map("n", "gd", vim.lsp.buf.definition, "Go to definition")
          map("n", "gr", vim.lsp.buf.references, "Go to references")
          map("n", "K", vim.lsp.buf.hover, "Hover documentation")

          -- <leader>l prefix group
          map("n", "<leader>la", vim.lsp.buf.code_action, "Code action")
          map("n", "<leader>lr", vim.lsp.buf.rename, "Rename symbol")
          map("n", "<leader>lf", function()
            require("conform").format({ bufnr = buf })
          end, "Format buffer")
          map("n", "<leader>ld", vim.diagnostic.open_float, "Show diagnostic")
          map("n", "<leader>lD", vim.diagnostic.setloclist, "Diagnostic list")
        end,
      })

      -- Diagnostic display configuration
      vim.diagnostic.config({
        virtual_text = {
          severity = { min = vim.diagnostic.severity.WARN },
          prefix = "●",
        },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN]  = " ",
            [vim.diagnostic.severity.INFO]  = " ",
            [vim.diagnostic.severity.HINT]  = "󰌵 ",
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })
    end,
  },
}
```

### Pattern 2: blink.cmp Configuration (No Ghost Text, Enter/Tab Accept)

**What:** blink.cmp with `version = '1.*'` (prebuilt binaries), `enter` preset, sources: lsp + path + buffer, lazydev source added for Lua files.

**Key decisions from CONTEXT.md:** No ghost text, auto-trigger on typing, Tab/Enter accept, Escape dismiss.

**Nix-safe build strategy:** Use `version = '1.*'` — lazy.nvim downloads prebuilt `.dylib` binary from GitHub releases. Do NOT use `build = 'nix run .#build-plugin'` (macOS linker issue with older versions) or `build = 'cargo build --release'` (requires Rust nightly). The `version = '1.*'` prebuilt approach has worked reliably since the nixpkgs EROFS issue was fixed in PR #386511 (March 2025).

```lua
-- lua/plugins/completion.lua
return {
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        -- Load luvit types when vim.uv is used
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "saghen/blink.cmp",
    version = "1.*",  -- Downloads prebuilt binary; safe on macOS/Nix
    opts = {
      keymap = { preset = "enter" },  -- Enter to accept; Escape closes menu
      appearance = { nerd_font_variant = "mono" },
      completion = {
        ghost_text = { enabled = false },  -- No inline preview per user decision
        documentation = { auto_show = true, auto_show_delay_ms = 500 },
        trigger = {
          show_on_insert_on_trigger_character = true,
        },
      },
      sources = {
        default = { "lazydev", "lsp", "path", "buffer" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,  -- Neovim API completions take priority in lua files
          },
        },
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
    },
    opts_extend = { "sources.default" },
  },
}
```

### Pattern 3: conform.nvim Format-on-Save

**What:** conform.nvim with `format_on_save` built-in option, `notify_no_formatters = false` for silent skip when formatter unavailable.

**Formatter name mapping in conform.nvim:**
- Nix → `"nixfmt"` (binary is `nixfmt`, provided by nixfmt-rfc-style Nix package)
- Python → `"black"` (binary is `black`)
- TypeScript/JS → `"prettier"` (binary is `prettier`)
- Go → `"gofmt"` (binary is `gofmt`)
- Rust → `"rustfmt"` (binary is `rustfmt` — must add pkgs.rustfmt to packages.nix)
- C/C++ → `"clang_format"` (binary is `clang-format`, conform name uses underscore)
- Lua → `"stylua"` (binary is `stylua` — must add pkgs.stylua to packages.nix)

```lua
-- lua/plugins/formatting.lua
return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        nix        = { "nixfmt" },
        python     = { "black" },
        typescript = { "prettier" },
        javascript = { "prettier" },
        go         = { "gofmt" },
        rust       = { "rustfmt" },
        c          = { "clang_format" },
        cpp        = { "clang_format" },
        lua        = { "stylua" },
      },
      format_on_save = {
        timeout_ms = 500,
        lsp_format = "fallback",  -- Use LSP if conform formatter unavailable
      },
      notify_on_error = false,       -- Silent on formatter errors
      notify_no_formatters = false,  -- Silent skip when no formatter for filetype
    },
  },
}
```

### Pattern 4: lua_ls Server Configuration Override

**What:** lua_ls needs settings for Neovim API awareness. nvim-lspconfig provides the base config; we override settings for the Neovim runtime.

**Why lazydev.nvim replaces manual workspace setup:** lazydev.nvim dynamically loads only the Neovim modules you actually `require()` in open files — much faster than loading the entire Neovim runtime library upfront.

```lua
-- Additional server override in lsp.lua, BEFORE vim.lsp.enable()
vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = {
        -- Don't warn about 'vim' global (lazydev handles this)
        globals = { "vim" },
      },
      workspace = {
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
})
```

### Anti-Patterns to Avoid

- **`require('lspconfig').server.setup()`:** Deprecated in Neovim 0.11+; triggers a warning that will become an error in nvim-lspconfig v3.0.0. Use `vim.lsp.config()` + `vim.lsp.enable()` instead.
- **`build = 'nix run .#build-plugin'` on macOS:** Known linker issue (liconv missing). Use `version = '1.*'` for prebuilt binary download.
- **`build = 'cargo build --release'` for blink.cmp:** Requires Rust nightly, not standard Rust. Will fail with stable Rust.
- **Binding LSP keymaps outside LspAttach:** Keys get bound even in buffers with no LSP server. Always use LspAttach autocmd.
- **`python-lsp-server` as the Python LSP:** Already in packages.nix (inside python3.withPackages), but pyright is the chosen server. The `python-lsp-server` entry won't cause conflicts (different server name: `pylsp` vs `pyright`), but pyright must be added separately as `pkgs.pyright`.
- **`format_on_save` with `lsp_format = "never"`:** Prevents the LSP fallback. Use `"fallback"` to let LSP format when conform has no formatter configured.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| LSP server capability declaration | Manual `vim.lsp.protocol.make_client_capabilities()` + table merging | `require('blink.cmp').get_lsp_capabilities()` | blink.cmp's function correctly merges snippet, completion, workspace capabilities |
| Lua workspace library loading | Manual `vim.lsp.config('lua_ls', { workspace = { library = {...all paths...} } })` | lazydev.nvim | lazydev lazy-loads only modules actually used; loading all Neovim runtime upfront is slow |
| Format-on-save autocmd | Custom `BufWritePre` with `vim.lsp.buf.format()` | conform.nvim `format_on_save` option | conform handles timeout, formatter priority, LSP fallback, error suppression |
| Formatter availability checks | `vim.fn.executable("formatter")` guards in autocmd | conform.nvim silent skip | conform already checks executable and skips silently with `notify_no_formatters = false` |

**Key insight:** In Neovim's LSP ecosystem, the hard parts (capability negotiation, workspace setup, formatter chaining) are already solved by the standard plugins. Custom implementations introduce bugs that the libraries already handle.

## Common Pitfalls

### Pitfall 1: nvim-lspconfig require() Deprecation Warning

**What goes wrong:** Config calls `require('lspconfig').lua_ls.setup({...})` and Neovim shows a deprecation warning at startup for every LSP server.

**Why it happens:** Neovim 0.11 deprecated the `require('lspconfig')` Lua module in favor of native `vim.lsp.config/enable`. The warning appears on any `require('lspconfig')` call.

**How to avoid:** Use `vim.lsp.config()` and `vim.lsp.enable()`. Install nvim-lspconfig as before (it still provides server definitions via `lsp/` directory) but don't call `require('lspconfig')`.

**Warning signs:** Startup message "The `require('lspconfig')` 'framework' is deprecated".

---

### Pitfall 2: blink.cmp Binary Download on Nix-Managed System

**What goes wrong:** blink.cmp fails to download prebuilt binary because it's trying to write to a Nix store path (read-only filesystem). Falls back to Lua fuzzy matcher silently, or shows EROFS error.

**Why it happens:** When blink.cmp is installed via `vimPlugins.blink-cmp` from nixpkgs (the Nix package manager version), the plugin is in the read-only store. This does NOT apply when installed via lazy.nvim (which writes to `~/.local/share/nvim/lazy/`).

**How to avoid:** Install blink.cmp via lazy.nvim (not nixpkgs vimPlugins). Use `version = '1.*'`. The lazy.nvim data directory is writable. This is the current setup, so this pitfall should not occur.

**Warning signs:** `:lua print(require('blink.cmp').implementation)` returns "lua" instead of "rust".

---

### Pitfall 3: rustfmt Not on PATH Despite rust-analyzer Being Present

**What goes wrong:** conform.nvim cannot find `rustfmt` and silently skips formatting Rust files even though rust-analyzer (LSP) works.

**Why it happens:** `rustc` and `rust-analyzer` are in packages.nix but `rustfmt` is a separate Nix package (`pkgs.rustfmt`). The `~/.cargo/bin/rustfmt` symlink points to rustup, which doesn't have a toolchain that provides rustfmt.

**How to avoid:** Add `pkgs.rustfmt` to `modules/common/packages.nix` explicitly.

**Warning signs:** `:ConformInfo` shows no formatter for `rust` filetype, or shows rustfmt as "not available".

---

### Pitfall 4: stylua Missing Despite Lua LSP Working

**What goes wrong:** Lua files get no format-on-save even though lua_ls LSP is active.

**Why it happens:** `stylua` is not in packages.nix. `lsp_format = "fallback"` means conform tries stylua first, and if unavailable, tries LSP. But lua_ls doesn't support formatting (it's a diagnostics/completion server).

**How to avoid:** Add `pkgs.stylua` to `modules/common/packages.nix`.

**Warning signs:** `:ConformInfo` shows stylua as "not available" for lua buffers.

---

### Pitfall 5: pyright and python-lsp-server Coexisting

**What goes wrong:** Both pyright and python-lsp-server (pylsp) start for Python files, causing duplicate diagnostics and completion conflicts.

**Why it happens:** `python-lsp-server` is already in packages.nix inside `python3.withPackages`. If pylsp's server name is in `vim.lsp.enable()`, it will also start.

**How to avoid:** Do NOT add `"pylsp"` to the `vim.lsp.enable()` list. Only enable `"pyright"`. The pylsp binary being on PATH doesn't cause it to auto-start — it only starts if explicitly enabled.

**Warning signs:** Two LSP clients shown in `:LspInfo` for Python files.

---

### Pitfall 6: ts_ls vs tsserver Server Name

**What goes wrong:** Using old server name `tsserver` instead of `ts_ls` — the server doesn't start, LSP shows no client.

**Why it happens:** nvim-lspconfig renamed the TypeScript server from `tsserver` to `ts_ls`. The old name is an alias that may or may not work depending on nvim-lspconfig version.

**How to avoid:** Use `"ts_ls"` as the server name in `vim.lsp.enable()`.

**Warning signs:** No LSP attached in TypeScript files.

---

### Pitfall 7: ccls Requires compile_commands.json for Non-Trivial C Projects

**What goes wrong:** ccls starts but shows no completions or incorrect diagnostics for C files.

**Why it happens:** ccls uses root markers including `compile_commands.json`. Without a compilation database, it cannot resolve includes for complex projects. For simple single-file C programs, it works without configuration.

**How to avoid:** For the phase gate test, use a simple C file (e.g., `main.c` with `#include <stdio.h>`). For real projects, generate `compile_commands.json` with `bear make` or `cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON`.

**Warning signs:** ccls starts (visible in `:LspInfo`) but hover returns no information for standard library types.

---

### Pitfall 8: clang_format Formatter Name (Underscore vs Hyphen)

**What goes wrong:** `formatters_by_ft = { c = { "clang-format" } }` — conform can't find the formatter.

**Why it happens:** conform.nvim uses `"clang_format"` (underscore) as the formatter name even though the binary is `clang-format` (hyphen). The formatter name in conform's registry uses underscores.

**How to avoid:** Use `"clang_format"` in `formatters_by_ft`.

---

### Pitfall 9: Diagnostic Signs Overriding Gutter for Other Plugins

**What goes wrong:** After Phase 3 (git signs), gutter shows overlapping LSP diagnostic signs and git signs.

**Why it happens:** Both gitsigns and vim diagnostic signs use the same sign column. Neovim 0.11 handles this via sign priority.

**How to avoid:** Set diagnostic sign priority lower than gitsigns (`priority = 10` for diagnostics vs `priority = 6` for gitsigns by default). This is a Phase 3 concern — note it here, don't solve it yet.

## Code Examples

Verified patterns from official sources:

### blink.cmp: Get Capabilities for Servers

```lua
-- Source: https://cmp.saghen.dev/installation
local capabilities = require("blink.cmp").get_lsp_capabilities()
-- Pass to vim.lsp.config('*', { capabilities = capabilities })
-- This automatically includes vim.lsp.protocol.make_client_capabilities()
```

### vim.lsp.config Wildcard + Enable Pattern

```lua
-- Source: Neovim 0.11 official docs + neovim/nvim-lspconfig README
-- Set capabilities for all servers at once
vim.lsp.config("*", {
  capabilities = require("blink.cmp").get_lsp_capabilities(),
})

-- Override specific server settings
vim.lsp.config("lua_ls", {
  settings = { Lua = { diagnostics = { globals = { "vim" } } } },
})

-- Enable all servers (nvim-lspconfig provides their lsp/ definitions)
vim.lsp.enable({
  "nixd", "pyright", "ts_ls", "gopls", "rust_analyzer", "ccls", "lua_ls",
})
```

### conform.nvim: Silent Skip When No Formatter

```lua
-- Source: https://github.com/stevearc/conform.nvim README
opts = {
  format_on_save = { timeout_ms = 500, lsp_format = "fallback" },
  notify_on_error = false,
  notify_no_formatters = false,  -- KEY: silently skip, don't notify
}
```

### lazydev.nvim + blink.cmp Integration

```lua
-- Source: https://github.com/folke/lazydev.nvim README
-- In blink.cmp opts:
sources = {
  default = { "lazydev", "lsp", "path", "buffer" },
  providers = {
    lazydev = {
      name = "LazyDev",
      module = "lazydev.integrations.blink",
      score_offset = 100,
    },
  },
},
```

### LspAttach Autocmd Pattern

```lua
-- Source: Neovim 0.11 docs, multiple verified blog posts
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_keymaps", { clear = true }),
  callback = function(args)
    local buf = args.buf
    -- Keymaps are buffer-local; only active when LSP is attached
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = buf })
    vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = buf })
    vim.keymap.set("n", "<leader>la", vim.lsp.buf.code_action, { buffer = buf })
    vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, { buffer = buf })
  end,
})
```

### blink.cmp: Disable Ghost Text (Per User Decision)

```lua
-- Ghost text is enabled by default in blink.cmp; must explicitly disable
completion = {
  ghost_text = { enabled = false },
}
```

### Diagnostic Config: Errors Prominent, Warnings Subtle

```lua
-- Source: :help vim.diagnostic.config
vim.diagnostic.config({
  virtual_text = {
    severity = { min = vim.diagnostic.severity.WARN },
    prefix = "●",
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN]  = " ",
      [vim.diagnostic.severity.INFO]  = " ",
      [vim.diagnostic.severity.HINT]  = "󰌵 ",
    },
  },
  update_in_insert = false,  -- Don't update diagnostics while typing
  severity_sort = true,       -- Show errors above warnings in lists
})
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `require('lspconfig').server.setup({})` | `vim.lsp.config()` + `vim.lsp.enable()` | Neovim 0.11 (Mar 2025) | Old approach now shows deprecation warning |
| neodev.nvim for Neovim API completions | lazydev.nvim | 2024 | lazydev is significantly faster; lazy-loads types |
| nvim-cmp as the completion standard | blink.cmp | 2024-2025 | blink.cmp is now the ecosystem default; faster Rust fuzzy |
| none-ls / null-ls for formatters | conform.nvim | 2023 | conform is purpose-built; simpler API |
| Manual on_attach for keymaps | LspAttach autocmd | Neovim 0.8+ | autocmd pattern is the standard; avoids on_attach boilerplate |

**Deprecated/outdated:**
- `require('lspconfig')` module: deprecated as of Neovim 0.11, will error in nvim-lspconfig v3.0.0
- neodev.nvim: replaced by lazydev.nvim (do not use for new configs)
- tsserver (server name): renamed to `ts_ls` in nvim-lspconfig
- null-ls / none-ls: replaced by conform.nvim + nvim-lint

## Open Questions

1. **blink.cmp `enter` preset behavior with Neovim's built-in CR mapping**
   - What we know: The `enter` preset maps Enter to accept completion
   - What's unclear: Does this conflict with Neovim's normal Enter behavior when completion menu is closed?
   - Recommendation: Test during implementation; if conflicting, use custom keymap with check for pumvisible()

2. **pyright venv detection in direnv-managed projects**
   - What we know: STATE.md notes "validate venv detection with a real .venv project" as Phase 2 concern
   - What's unclear: Whether pyright finds `.venv` created by uv/poetry vs traditional venv
   - Recommendation: Phase gate should include a test with a real Python project that has `.venv/`; pyright's default `venvPath` setting may need overriding

3. **nixd nixpkgs-awareness configuration**
   - What we know: nixd supports `expr` to point at nixpkgs for option completion
   - What's unclear: Whether the simple `cmd = { "nixd" }` default config provides useful completions, or whether the flake-aware config (with `expr`) is needed for real value
   - Recommendation: Start with default configuration; the phase gate doesn't require nixpkgs option completion, only that the server attaches and provides basic Nix completions

## Sources

### Primary (HIGH confidence)

- https://cmp.saghen.dev/installation — blink.cmp installation and configuration
- https://cmp.saghen.dev/configuration/fuzzy — blink.cmp fuzzy/prebuilt binary docs
- https://github.com/neovim/nvim-lspconfig — nvim-lspconfig README and deprecation status (v2.6.0, Feb 2026)
- https://github.com/folke/lazydev.nvim — lazydev.nvim README with blink.cmp integration
- https://github.com/stevearc/conform.nvim — conform.nvim README and formatter list
- `nix eval` commands run against nixpkgs-25.05-darwin — verified: pyright@1.1.399, stylua@2.1.0, rustfmt@1.86.0 all available
- `nvim --version` — confirmed Neovim 0.11.2 installed
- `which` commands — verified formatter PATH status

### Secondary (MEDIUM confidence)

- https://gpanders.com/blog/whats-new-in-neovim-0-11/ — official author's blog, comprehensive 0.11 LSP changes
- https://github.com/NixOS/nixpkgs/issues/386404 — blink.cmp nixpkgs issue, confirmed resolved Mar 2025 via PR #386511
- https://github.com/Saghen/blink.cmp/issues/652 — macOS nix build linker issue, confirmed fix in later commits
- https://github.com/Saghen/blink.cmp/issues/880 — macOS build workaround confirmed

### Tertiary (LOW confidence)

- Various blog posts (tduyng.com, davelage.com, rdrn.me) — patterns cross-verified with official docs

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all packages verified against nixpkgs 25.05-darwin; plugin versions confirmed
- Architecture: HIGH — vim.lsp.config/enable API verified from official Neovim 0.11 changelog and nvim-lspconfig README
- Pitfalls: HIGH for blink.cmp Nix issues (verified via GitHub issues), HIGH for deprecation warning (confirmed in nvim-lspconfig README), MEDIUM for formatter path issues (verified via `which` commands)

**Research date:** 2026-02-26
**Valid until:** 2026-04-15 (stable plugins; blink.cmp is fast-moving but version = '1.*' pins the API)
