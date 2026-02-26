# Architecture Research

**Domain:** Neovim configuration — modular Lua config with Nix-managed LSP
**Researched:** 2026-02-26
**Confidence:** HIGH — all key claims verified against official docs and current community sources

## Standard Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     Nix Darwin / Home Manager                    │
│  dotfiles/nvim/ → symlink → ~/.config/nvim  (read-only store)  │
│  Nix packages → gopls, pyright, ts-ls, ccls, ... in PATH       │
└──────────────────────────────┬──────────────────────────────────┘
                               │ symlink (directory)
┌──────────────────────────────▼──────────────────────────────────┐
│                    ~/.config/nvim/                               │
│                                                                  │
│  init.lua             ← entry point: options, leader, bootstrap │
│  lua/                                                            │
│  ├── config/          ← core, non-plugin config                  │
│  │   ├── options.lua  ← vim.opt.* settings                       │
│  │   ├── keymaps.lua  ← global keymaps (no plugin deps)          │
│  │   └── autocmds.lua ← filetype overrides, misc autocmds        │
│  ├── plugins/         ← one file per plugin/concern              │
│  │   ├── ui.lua       ← colorscheme + statusline                  │
│  │   ├── editor.lua   ← treesitter, gitsigns, indent             │
│  │   ├── finder.lua   ← fzf-lua (files, grep, buffers)           │
│  │   ├── lsp.lua      ← nvim-lspconfig + on_attach               │
│  │   ├── completion.lua ← blink.cmp                              │
│  │   ├── formatting.lua ← conform.nvim                           │
│  │   └── explorer.lua ← neo-tree (toggleable sidebar)            │
│  └── lsp/             ← per-server configs (Neovim 0.11 native)  │
│      ├── gopls.lua                                               │
│      ├── pyright.lua                                             │
│      ├── ts_ls.lua                                               │
│      ├── lua_ls.lua                                              │
│      ├── nil_ls.lua                                              │
│      └── ccls.lua                                                │
└─────────────────────────────────────────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────────┐
│              lazy.nvim plugin data (~/.local/share/nvim/)        │
│  Plugins fetched from git, NOT managed by Nix                   │
│  lazy-lock.json at stdpath("data") — writable location          │
└─────────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

| Component | Responsibility | Implementation |
|-----------|----------------|----------------|
| `init.lua` | Bootstrap sequence, leader key, load config/, bootstrap lazy | Entry point only — no plugin config |
| `lua/config/options.lua` | All `vim.opt.*` settings | Plain Lua, no dependencies |
| `lua/config/keymaps.lua` | Global keymaps with no plugin deps | `<leader>w`, window nav, indent |
| `lua/config/autocmds.lua` | Filetype overrides, trailing whitespace, etc. | `vim.api.nvim_create_autocmd` |
| `lua/plugins/*.lua` | Plugin specs returned as tables | Each file returns `{}` table |
| `lua/lsp/*.lua` | Per-server LSP config | Consumed by `vim.lsp.enable()` |
| `dotfiles/nvim/` (Nix) | Source of truth, git-tracked | Symlinked by Home Manager |

## Recommended Project Structure

```
dotfiles/nvim/
├── init.lua                  # Entry point: set leader, source config/, bootstrap lazy
├── stylua.toml               # Lua formatter config (already exists)
├── .neoconf.json             # LSP project config (already exists)
├── .gitignore                # Ignore lazy-lock if using stdpath("data")
└── lua/
    ├── config/
    │   ├── options.lua       # vim.opt.* — migrate from init.lua
    │   ├── keymaps.lua       # Non-plugin keymaps — migrate from init.lua
    │   └── autocmds.lua      # Filetype tweaks, misc
    ├── plugins/
    │   ├── ui.lua            # Colorscheme (catppuccin or modus-style)
    │   ├── editor.lua        # Treesitter + gitsigns
    │   ├── finder.lua        # fzf-lua
    │   ├── lsp.lua           # nvim-lspconfig setup + LspAttach keymaps
    │   ├── completion.lua    # blink.cmp
    │   ├── formatting.lua    # conform.nvim
    │   └── explorer.lua      # neo-tree (toggle, closed by default)
    └── lsp/
        ├── gopls.lua
        ├── pyright.lua
        ├── ts_ls.lua
        ├── lua_ls.lua
        ├── nil_ls.lua        # Nix LSP
        └── ccls.lua          # C/C++
```

### Structure Rationale

- **`lua/config/`:** Options, keymaps, and autocmds that have no plugin dependencies load early and unconditionally. Separating them from plugin specs makes the init.lua a clean orchestrator.
- **`lua/plugins/`:** lazy.nvim natively imports all files in this directory when you call `require("lazy").setup("plugins")`. No manual require() needed — add a file, it loads.
- **`lua/lsp/`:** Neovim 0.11's native `vim.lsp.enable()` API reads configs from `lsp/*.lua` automatically on runtimepath. This eliminates Mason entirely. Each file is one server, consumed with a single `vim.lsp.enable({...})` call.
- **Nix symlinks the whole `dotfiles/nvim/` directory** to `~/.config/nvim` as a directory symlink. The `lua/` subdirectory is therefore also symlinked, and Neovim's Lua module resolution follows the symlink transparently. This is already working in the current setup.

## Architectural Patterns

### Pattern 1: Nix-Managed LSP via Neovim 0.11 Native API

**What:** Use `vim.lsp.enable()` with per-server files in `lua/lsp/`, leveraging Neovim 0.11's built-in LSP config discovery. Servers are on PATH via Nix — no absolute paths needed, no Mason.

**When to use:** Always for this project. Neovim 0.11 is installed (v0.11.2 confirmed), all servers are Nix packages already in PATH.

**Trade-offs:** Requires Neovim 0.11+. Neovim resolves server names (e.g., `ts_ls`) to `lsp/ts_ls.lua` automatically. The nvim-lspconfig plugin can still provide default configs as a fallback for servers where you don't write your own `lsp/*.lua` file — they are not mutually exclusive.

**Example:**

```lua
-- lua/lsp/gopls.lua
return {
  cmd = { "gopls" },          -- just the binary name; Nix puts it on PATH
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.mod", "go.sum", ".git" },
  settings = {
    gopls = {
      analyses = { unusedparams = true },
      staticcheck = true,
    },
  },
}

-- lua/config/options.lua (or init.lua, called after lazy setup)
vim.lsp.enable({
  "gopls",
  "pyright",
  "ts_ls",
  "lua_ls",
  "nil_ls",
  "ccls",
})
```

### Pattern 2: lazy.nvim Lazy-Loading Tiers

**What:** Assign every plugin to exactly one loading trigger. Three tiers cover all cases.

**When to use:** All plugins. Never leave `lazy = false` without a reason; never leave a plugin with no trigger (implicit eager load).

**Trade-offs:** More explicit config, but startup time predictability is worth it. The goal is sub-100ms.

**The three tiers:**

```lua
-- TIER 1: Eager (lazy = false, priority = 1000)
-- Only colorscheme. Must load before anything else renders.
{ "catppuccin/nvim", lazy = false, priority = 1000 }

-- TIER 2: Buffer-event (event = {"BufReadPre", "BufNewFile"})
-- Plugins that must be ready when a file opens.
-- Use for: treesitter, gitsigns, LSP, completion, formatting.
-- DO NOT use VeryLazy here — LSP cannot attach to an already-open buffer.
{
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  build = ":TSUpdate",
}

-- TIER 3: On-demand (keys = {...} or cmd = "...")
-- Plugins invoked explicitly by the user.
-- Use for: file finder, file explorer, command palette.
{
  "ibhagwan/fzf-lua",
  keys = {
    { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
    { "<leader>fg", "<cmd>FzfLua grep_project<cr>", desc = "Grep" },
    { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
  },
}
```

### Pattern 3: LspAttach Autocmd for Keymaps

**What:** All LSP keymaps are registered inside an `LspAttach` autocmd, not globally. This ensures keymaps only exist in buffers where an LSP is running.

**When to use:** Always. Never set LSP keymaps globally.

**Trade-offs:** Slightly more boilerplate, but prevents accidental key conflicts in non-LSP buffers. Standard practice as of Neovim 0.11.

**Example:**

```lua
-- lua/plugins/lsp.lua
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local map = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = args.buf, desc = "LSP: " .. desc })
    end
    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gr", vim.lsp.buf.references, "References")
    map("K", vim.lsp.buf.hover, "Hover docs")
    map("<leader>rn", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
  end,
})
```

### Pattern 4: Nix Symlink Compatibility

**What:** Home Manager symlinks `dotfiles/nvim/` to `~/.config/nvim` as a directory (not individual files). This means the entire `lua/` tree is readable by Neovim, but all files are read-only (Nix store).

**When to use:** This is the current pattern — it already works. The read-only constraint is a feature: configs are reproducible.

**Trade-offs:** `lazy-lock.json` cannot be written inside `~/.config/nvim`. This is already handled correctly — the current config sets `lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json"` which points to `~/.local/share/nvim/lazy-lock.json` (writable). Keep this.

**What NOT to do:** Do not use `mkOutOfStoreSymlink` unless you need to edit files in-place without rebuilding. The current `.source = "${configDir}/dotfiles/nvim"` pattern is correct and sufficient.

## Data Flow

### Startup Sequence

```
Neovim starts
    |
    v
init.lua
    |-- set vim.g.mapleader = " "        (must be FIRST, before lazy)
    |-- require("config.options")         (vim.opt.* — no deps)
    |-- require("config.keymaps")         (no-plugin keymaps)
    |-- require("config.autocmds")        (filetype rules)
    |-- bootstrap lazy.nvim
    |-- require("lazy").setup("plugins")  (scans lua/plugins/*.lua)
    |-- vim.lsp.enable({...})             (enable configured servers)
    v
UI rendered (~30ms without lazy plugins)

User opens file
    |
    v
BufReadPre / BufNewFile events fire
    |-- treesitter loads, parses buffer
    |-- gitsigns loads, shows git signs
    |-- LSP server starts (auto-detected by filetype + root_markers)
    |-- blink.cmp activates in insert mode
    v
File fully interactive (~80ms total from cold start)

User presses <leader>ff
    |
    v
fzf-lua loads on first keypress
    v
Picker opens
```

### LSP Server Resolution

```
User opens file.go
    |
    v
Neovim checks: which servers are enabled for "go" filetype?
    |-- vim.lsp.enable() registered "gopls"
    |-- Reads lua/lsp/gopls.lua from runtimepath
    |-- Checks root_markers: found go.mod in project root
    v
gopls binary located via PATH (Nix manages PATH)
    v
LSP client attached to buffer
    v
LspAttach autocmd fires → keymaps registered for this buffer
```

## Plugin Selection Rationale

Based on the project requirements and 2025 ecosystem state:

| Concern | Plugin | Why Not Alternatives |
|---------|--------|---------------------|
| Plugin manager | lazy.nvim (keep) | Already bootstrapped |
| Colorscheme | catppuccin-mocha or modus-vivendi port | catppuccin has first-class treesitter/LSP hl; keep hand-rolled modus if preferred |
| Syntax | nvim-treesitter | Native in 0.11 but nvim-treesitter still needed for parsers |
| Fuzzy finder | fzf-lua | Faster than Telescope; LazyVim switched to fzf-lua as default in 2024 |
| Completion | blink.cmp | Built-in sources (LSP, buffer, path, snippets); 0.5-4ms vs nvim-cmp's 60ms debounce |
| LSP config | nvim-lspconfig (thin wrapper) or native 0.11 | Native preferred; nvim-lspconfig as fallback for server defaults |
| Git signs/blame | gitsigns.nvim | Standard; snacks.nvim also has git support but adds complexity |
| Formatting | conform.nvim | Lightweight, async, fallback to LSP format |
| File explorer | neo-tree.nvim | Toggleable sidebar; matches "closed by default" UX requirement |
| Statusline | lualine.nvim or native | lualine is minimal; native is even more minimal |

**Deliberately omitted:** mason.nvim (Nix handles all server installation), nvim-cmp (blink.cmp is faster), telescope.nvim (fzf-lua is faster and lighter).

## Scaling Considerations

This is a single-user editor config, so "scaling" means: what breaks as plugin count grows?

| Scale | Risk | Prevention |
|-------|------|------------|
| 1-10 plugins | Nothing breaks | Maintain lazy loading discipline |
| 10-20 plugins | Startup time creep | Audit with `:Lazy profile`, ensure every plugin has a trigger |
| 20+ plugins | Config becomes hard to understand | Keep one plugin spec per file in `lua/plugins/` |

### Startup Budget (targeting <100ms)

```
Neovim core initialization:    ~15ms
Options + keymaps + autocmds:   ~5ms
lazy.nvim bootstrap:            ~5ms
Colorscheme (eager):            ~5ms
                               ------
Cold start (no files open):    ~30ms

BufReadPre plugins (treesitter, gitsigns, lsp):  ~30-50ms
                               ------
First file open total:         ~60-80ms
```

fzf-lua, neo-tree, conform load on first use — they cost 0ms at startup.

## Anti-Patterns

### Anti-Pattern 1: Configuring LSP Inside the lazy.nvim Plugin Spec

**What people do:** Put `require("lspconfig").gopls.setup({})` inside the `config = function()` of an nvim-lspconfig lazy spec, triggered with `event = "BufReadPost"`.

**Why it's wrong:** LSP setup must run before or at the same time as `BufReadPre`. Using `BufReadPost` means the LSP misses the initial file open and doesn't attach. With Neovim 0.11, `vim.lsp.enable()` handles this correctly — just call it after lazy setup in `init.lua`.

**Do this instead:** Call `vim.lsp.enable({...})` unconditionally after `require("lazy").setup(...)`. The `lsp/*.lua` files are loaded on-demand when the server is first needed; the enable() call is instant.

### Anti-Pattern 2: Inlining All Config in init.lua

**What people do:** Keep growing the single `init.lua` with all plugin configs inline (current state of this repo).

**Why it's wrong:** At the scale of 10+ plugins, the file becomes unmaintainable. Plugin configs cannot be found, moved, or disabled independently. lazy.nvim's native `require("lazy").setup("plugins")` module scanning was designed to eliminate this.

**Do this instead:** One file per logical concern in `lua/plugins/`. Start the migration by extracting the colorscheme, then each plugin group.

### Anti-Pattern 3: Using Mason with Nix

**What people do:** Install mason.nvim and mason-lspconfig.nvim alongside Nix-managed LSP servers.

**Why it's wrong:** Mason will attempt to manage its own copies of binaries that Nix already provides. This creates version drift, PATH confusion, and defeats the reproducibility goal. mason-lspconfig only recognizes Mason-installed servers, so it won't help with the Nix-installed ones anyway.

**Do this instead:** Skip Mason entirely. Configure each server with `lsp/*.lua` files + `vim.lsp.enable()`. All required servers are already in `packages.nix`.

### Anti-Pattern 4: Sourcing lua/ Modules with require() in init.lua When Using lazy.nvim's Module Scanning

**What people do:** After adopting `lua/plugins/`, they add `require("plugins.lsp")` etc. manually in `init.lua`.

**Why it's wrong:** `require("lazy").setup("plugins")` automatically scans all files in `lua/plugins/` — manual require() calls are redundant and can cause double-loading.

**Do this instead:** Only require `config.*` modules manually. Let lazy.nvim handle `plugins/*`.

## Integration Points

### Nix → Neovim Boundary

| Integration | How It Works | Notes |
|-------------|--------------|-------|
| Config files | Home Manager symlinks `dotfiles/nvim/` → `~/.config/nvim` | Directory symlink; read-only in Nix store |
| LSP binaries | Nix packages on system PATH | Neovim inherits PATH from shell at launch |
| Plugin downloads | lazy.nvim writes to `~/.local/share/nvim/lazy/` | Writable; outside Nix store |
| Lock file | lazy.nvim writes `lazy-lock.json` to `stdpath("data")` | Current config already handles this correctly |
| Formatters | conform.nvim calls `prettier`, `black`, `stylua` by name | All available as Nix packages in PATH |

### Plugin → Plugin Dependencies

```
blink.cmp ──────────── requires ──────────→ nvim-lspconfig (capabilities)
nvim-lspconfig ─────── reads ─────────────→ lua/lsp/*.lua configs
nvim-treesitter ─────── parses ───────────→ buffer (required by gitsigns for context)
fzf-lua ─────────────── depends on ───────→ fzf (system binary via Nix)
neo-tree ─────────────── depends on ───────→ nvim-web-devicons (optional, lazy)
conform.nvim ─────────── calls ────────────→ formatter binaries via PATH
```

**Build order for implementation (what to implement first):**

1. Migrate options/keymaps/autocmds out of `init.lua` → `lua/config/`
2. Add colorscheme plugin spec (eager, priority 1000)
3. Add treesitter (BufReadPre event)
4. Add LSP infrastructure: `lsp/*.lua` files + `vim.lsp.enable()` + LspAttach keymaps
5. Add blink.cmp (depends on LSP capabilities being configured first)
6. Add gitsigns (BufReadPre event, independent)
7. Add fzf-lua (keys-triggered, independent)
8. Add neo-tree (keys-triggered, independent)
9. Add conform.nvim (BufWritePre event, formatters already on PATH)

Steps 4 and 5 must stay in order — blink.cmp needs to advertise LSP capabilities before servers attach, which is done by passing `capabilities = require("blink.cmp").get_lsp_capabilities()` to the `vim.lsp.config()` defaults.

## Sources

- [lazy.nvim Structuring Plugins docs](https://lazy.folke.io/usage/structuring) — HIGH confidence (official)
- [lazy.nvim Examples — loading events](https://lazy.folke.io/spec/examples) — HIGH confidence (official)
- [What's New in Neovim 0.11 — vim.lsp.config/enable](https://gpanders.com/blog/whats-new-in-neovim-0-11/) — HIGH confidence (core contributor)
- [Neovim 0.11 LSP setup guide](https://davelage.com/posts/neovim-lsp-0.11/) — MEDIUM confidence (community, verified against official)
- [blink.cmp vs nvim-cmp comparison](https://gist.github.com/Saghen/e731f6f6e30a4c01f6bc7cdaa389d463) — MEDIUM confidence (blink.cmp author)
- [LazyVim switched to fzf-lua as default](https://github.com/LazyVim/LazyVim/discussions/3619) — MEDIUM confidence (community discussion)
- [Home Manager read-only nvim config — mkOutOfStoreSymlink](https://discourse.nixos.org/t/neovim-config-read-only/35109) — HIGH confidence (official pattern)
- [NixOS Discourse: LSP with Nix-installed binaries](https://discourse.nixos.org/t/i-need-help-setting-up-lsp-for-neovim-using-lspconfig-language-server-binaries/65455) — MEDIUM confidence (community)
- [conform.nvim README — lazy.nvim BufWritePre pattern](https://github.com/stevearc/conform.nvim/blob/master/README.md) — HIGH confidence (official)

---
*Architecture research for: Neovim configuration (modular Lua + Nix LSP integration)*
*Researched: 2026-02-26*
