# Pitfalls Research

**Domain:** Neovim configuration — Nix-managed LSP, lazy.nvim, treesitter, completion
**Researched:** 2026-02-26
**Confidence:** HIGH (critical pitfalls verified via official docs, NixOS Discourse, and GitHub issues)

---

## Critical Pitfalls

### Pitfall 1: Nix Breaks Neovim's PATH — LSP Servers Invisible

**What goes wrong:**
When Neovim is launched from a Nix-managed environment (nix-darwin, home-manager, a Nix overlay), it inherits a stripped PATH that may not include `/run/current-system/sw/bin` or `/nix/var/nix/profiles/default/bin`. LSP servers installed as Nix packages (gopls, pyright, typescript-language-server, etc.) are in the Nix store but not on the PATH that Neovim sees. lspconfig's default `cmd` is just the binary name (e.g., `"gopls"`), which fails silently — the LSP client just never attaches.

**Why it happens:**
Nix packages land in `/nix/store/…/bin/`. When nix-darwin activates, it creates symlinks in `/run/current-system/sw/bin`, which goes on the system PATH. But Neovim launched via a shell alias, a launchd agent, or a GUI wrapper may not source your shell profile, so it gets a minimal PATH. This is more pronounced on macOS with nix-darwin than on NixOS, because macOS doesn't give Nix full control of the login environment.

**How to avoid:**
Verify your LSP binaries are actually on the PATH Neovim sees before configuring lspconfig. Add this to a scratch buffer and run it with `:luafile %`:

```lua
-- Diagnostic: what PATH does Neovim see?
print(vim.env.PATH)

-- Test a specific server
print(vim.fn.exepath("gopls"))       -- empty string = not on PATH
print(vim.fn.exepath("typescript-language-server"))
```

If `exepath()` returns empty strings, fix the PATH. The correct fix in a non-Nix-overlay setup (like this project's dotfiles approach) is to ensure your shell profile adds Nix profile paths before Neovim starts. Verify in `home.nix` or `darwin/system.nix` that the PATH includes Nix paths. As a fallback, set `cmd` explicitly in lspconfig:

```lua
-- Explicit cmd — use as last resort, not first solution
require("lspconfig").gopls.setup({
  cmd = { vim.fn.exepath("gopls") or "gopls" },
})
```

Do NOT hardcode Nix store paths (e.g., `/nix/store/abc123-gopls/bin/gopls`) — they change on every rebuild.

**Warning signs:**
- `:LspInfo` shows "0 active clients" for a supported filetype
- No LSP diagnostics, no completion, no hover
- `vim.fn.exepath("gopls")` returns empty string inside Neovim
- Server works fine when run directly in the terminal

**Phase to address:** Phase 1 (Foundation) — verify PATH diagnostic before attempting any LSP configuration. Do not proceed to LSP setup until `exepath()` returns non-empty for all target servers.

---

### Pitfall 2: treesitter `ensure_installed` Conflicts with Nix-Managed Parsers

**What goes wrong:**
nvim-treesitter's `ensure_installed` option attempts to download and compile grammar parsers at runtime. On Nix, the Nix store is read-only — runtime compilation fails with "read-only filesystem" errors. Worse, Neovim ships with a small set of built-in parsers (C, Lua, Vim, Vimdoc, Query), and if treesitter also tries to install those, you get "destination already exists and is not empty" conflicts.

**Why it happens:**
nvim-treesitter assumes it can write parsers to `~/.local/share/nvim/site/parser/`. On Nix, some parsers are installed to the Nix store and symlinked, but the plugin doesn't know about them via the `ensure_installed` mechanism — it just sees an occupied directory and errors. The plugin maintainers have acknowledged this as a known NixOS packaging mess.

**How to avoid:**
This project uses dotfile-managed Lua config (not nixvim), so parsers must be installed by nvim-treesitter at runtime — which means NOT via Nix packages and NOT using `ensure_installed` in a way that conflicts. The correct approach:

```lua
require("nvim-treesitter.configs").setup({
  -- DO NOT set ensure_installed if you plan to handle via :TSInstall
  -- OR set a list and ensure the install_dir is writable
  ensure_installed = {},  -- empty: manage manually with :TSInstall

  -- Or use auto_install for lazy per-filetype install (requires network access)
  auto_install = true,    -- installs on first open of a filetype

  -- Critical: these are always safe to enable
  highlight = { enable = true },
  indent = { enable = true },
})
```

The safest approach for this project: use `auto_install = true` (installs parsers on first filetype open, no conflicts at startup) combined with `ensure_installed = {}`. This defers compilation until the parser is actually needed and writes to `~/.local/share/nvim/` which is writable.

**Warning signs:**
- Errors at startup: "destination path already exists and is not empty"
- Errors: "Failed to load parser" or "no parser for [filetype]"
- Treesitter highlights work for some filetypes but not others
- `:TSInstall lua` errors with "read-only filesystem"

**Phase to address:** Phase 1 (Foundation) — configure treesitter's install behavior before enabling highlight/indent. Check `:checkhealth nvim-treesitter` as acceptance criterion.

---

### Pitfall 3: `vim.g.mapleader` Set After lazy.nvim — Keymaps Break

**What goes wrong:**
If `vim.g.mapleader = " "` is set anywhere after `require("lazy").setup(...)` runs, plugins loaded at startup that register `<leader>` keymaps during their `config` function will bind to the *previous* leader (default: `\`), not `<Space>`. The wrong leader gets baked in.

**Why it happens:**
lazy.nvim's `require("lazy").setup()` processes all plugin specs immediately, including running `config` functions for non-lazy plugins. Any plugin that registers keymaps in its `config` (like which-key, telescope, gitsigns) captures `vim.g.mapleader` at that moment. If leader is set after setup, those mappings use the default leader.

**How to avoid:**
Always set leader before lazy.nvim loads. The correct ordering at the top of `init.lua`:

```lua
-- 1. Set leader FIRST — before anything else
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 2. Bootstrap lazy.nvim (no plugin loading yet)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- ... bootstrap code ...
vim.opt.rtp:prepend(lazypath)

-- 3. NOW call lazy.setup() — plugins see correct leader
require("lazy").setup({ ... })
```

The existing `init.lua` already does this correctly. Do not move the leader assignment.

**Warning signs:**
- `<Space>` key in normal mode doesn't trigger any commands
- `\ff` works but `<Space>ff` doesn't
- `:map <Space>` shows no mappings

**Phase to address:** Phase 1 (Foundation) — this is already handled correctly in the existing init.lua. Verify in acceptance criteria that `<Space>` triggers the command palette.

---

### Pitfall 4: blink.cmp Nix Build Failure — Prebuilt Binary Download Blocked

**What goes wrong:**
blink.cmp includes a Rust-based fuzzy matcher that must be compiled or downloaded as a prebuilt binary. When installed via lazy.nvim (not nixpkgs), it tries to download prebuilt binaries from GitHub at startup. This fails silently or with an error like "falling back to Lua implementation" — which disables the performance fuzzy matcher. In some Nix setups, the download itself fails due to network sandboxing during build phases.

**Why it happens:**
blink.cmp's architecture has the fuzzy matching library as a separately compiled Rust crate (`blink-cmp-fuzzy`). The plugin either needs the prebuilt binary fetched at runtime (network call on startup), or it needs to be compiled via `cargo build --release` during plugin installation. lazy.nvim's `build` hook would handle this, but if Rust/cargo isn't available at the right moment, it falls back to a slower Lua implementation.

**How to avoid:**
Since this project has `rustc` and `cargo` in `packages.nix`, the build hook will work. Configure blink.cmp in lazy.nvim with the explicit build step:

```lua
{
  "saghen/blink.cmp",
  build = "cargo build --release",  -- explicit, not "nix run .#build-plugin"
  -- ...
}
```

If the build fails (check `:Lazy log`), verify `cargo` is on PATH inside Neovim with `vim.fn.exepath("cargo")`. This ties back to Pitfall 1 — PATH must be correct first.

Alternatively, use nvim-cmp instead of blink.cmp to avoid this complexity entirely. nvim-cmp is pure Lua with no compilation step.

**Warning signs:**
- blink.cmp startup message: "falling back to Lua implementation"
- Completion feels slow compared to expectations
- `:Lazy log` shows build errors for blink.cmp
- `vim.fn.exepath("cargo")` returns empty string

**Phase to address:** Phase 2 (LSP + Completion) — decide between blink.cmp and nvim-cmp before implementation. If choosing blink.cmp, verify cargo PATH as prerequisite.

---

### Pitfall 5: rust-analyzer Not in packages.nix — Missing LSP for Rust Files

**What goes wrong:**
The current `packages.nix` includes `rustc` and `cargo` but NOT `rust-analyzer`. Opening a `.rs` file will show no LSP support. The user may assume Rust LSP is covered because Rust itself is installed.

**Why it happens:**
rust-analyzer is a separate package from the Rust compiler. It's available in nixpkgs but must be explicitly added. Additionally, rust-analyzer needs access to the Rust standard library source (`rust-src`) for go-to-definition into stdlib — missing this causes "failed to load proc macro" warnings and incomplete type information.

**How to avoid:**
Add to `modules/common/packages.nix`:
```nix
rust-analyzer    # Rust language server
rustfmt          # Rust formatter (may already be in cargo tools)
```

And ensure `rust-src` is available. With nixpkgs:
```nix
(rust-bin.stable.latest.default.override {
  extensions = [ "rust-src" "rust-analyzer" ];
})
```

Or more simply for this project's setup, just add `rust-analyzer` to `systemPackages`.

**Warning signs:**
- `:LspInfo` shows no active LSP client when editing `.rs` files
- `vim.fn.exepath("rust-analyzer")` returns empty string

**Phase to address:** Phase 1 (Foundation) — audit all LSP binaries against packages.nix before writing any LSP config.

---

### Pitfall 6: lazy.nvim `dependencies` Defeats Lazy Loading

**What goes wrong:**
Using `dependencies = { "nvim-lua/plenary.nvim" }` in a lazy-loaded plugin causes plenary (and other dependencies) to load eagerly at the trigger point, not when actually `require()`d. This adds unnecessary load time to the triggering event. For heavy dependencies like plenary, this can add 10-30ms to the first invocation.

**Why it happens:**
lazy.nvim's `dependencies` field loads the listed plugins before the parent plugin initializes. The official lazy.nvim docs clarify that Lua libraries loaded via `require()` are auto-lazy by default — `dependencies` is only needed when a plugin needs *pre-initialization setup* (e.g., running a `setup()` call), not just when another plugin does `require("plenary")`.

**How to avoid:**
Define shared libraries separately with `lazy = true` and let `require()` handle loading:

```lua
-- Good: plenary loads on-demand when telescope requires it
{ "nvim-lua/plenary.nvim", lazy = true },
{ "nvim-telescope/telescope.nvim", cmd = "Telescope" },

-- Bad: plenary loads the instant :Telescope is called, before telescope even needs it
{
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },  -- forces early load
  cmd = "Telescope",
},
```

Exception: use `dependencies` only when a plugin requires another plugin's `setup()` to run first (rare in Lua-native plugins).

**Warning signs:**
- `:Lazy profile` shows dependencies loading at the same timestamp as parent
- Startup time doesn't improve despite lazy-loading parent plugin
- `:Lazy` shows plenary or other libraries with load time on startup

**Phase to address:** Phase 1 (Foundation) — audit plugin specs during initial configuration. Verify with `:Lazy profile` that no non-essential plugins load at startup.

---

### Pitfall 7: Neovim 0.11 Changes LSP API — Tutorials Use Deprecated Patterns

**What goes wrong:**
Neovim 0.11 (released 2025) introduced `vim.lsp.config()` and `vim.lsp.enable()` as replacements for most of what nvim-lspconfig's `setup()` does. Most tutorials, blog posts, and LLM-generated configs still use `lspconfig.gopls.setup({})`. While lspconfig still works, mixing old lspconfig patterns with new native APIs causes unexpected behavior and duplicate server starts.

**Why it happens:**
The LSP ecosystem is mid-transition. lspconfig's README still documents the old `setup()` pattern, and nixpkgs ships an older lspconfig. New Neovim users copy tutorials that predate 0.11.

**How to avoid:**
For this project, pick one approach and stick with it. Given this is a fresh config, use the new native API where possible (simpler, fewer plugins), but keep lspconfig for servers with complex default configurations:

```lua
-- New (0.11+): native LSP config
vim.lsp.config("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  root_markers = { "go.work", "go.mod", ".git" },
})
vim.lsp.enable("gopls")

-- OR: stick with lspconfig (still valid, simpler for multi-server setups)
require("lspconfig").gopls.setup({})
```

The lspconfig approach is simpler to copy from documentation and works fine. Choose one and don't mix them for the same server.

**Warning signs:**
- Two LSP clients attaching to the same buffer for the same language
- `:LspInfo` shows duplicate servers
- LSP features work then break unpredictably

**Phase to address:** Phase 2 (LSP + Completion) — decide on approach at the start of LSP configuration, not mid-implementation.

---

### Pitfall 8: Python LSP Breaks Inside Virtual Environments

**What goes wrong:**
`python-lsp-server` (pylsp) is installed as a Nix package and is on the PATH. But when editing Python files in a project with a `.venv` or Poetry/uv virtual environment, pylsp uses the Nix Python (with mypy, black, etc.) not the project's Python. It reports type errors for packages that are installed in the venv but not in the Nix Python environment.

**Why it happens:**
Nix installs pylsp linked to a specific Python interpreter. It doesn't know about virtualenvs. lspconfig's default pylsp configuration doesn't detect or switch to the active virtual environment's Python.

**How to avoid:**
Configure pylsp (or switch to pyright, which has better venv auto-detection) to detect the virtual environment:

```lua
-- pyright is better at venv auto-detection
require("lspconfig").pyright.setup({
  settings = {
    python = {
      -- Pyright auto-detects .venv, pyrightconfig.json, etc.
      analysis = { autoSearchPaths = true }
    }
  }
})
```

Note: `pyright` is NOT currently in `packages.nix` — add it. `python-lsp-server` (pylsp) is available as `python3.withPackages(ps: [ ps.python-lsp-server ])` which is the current setup.

For pylsp with venv support, add the `pylsp-mypy` plugin and configure `python.pythonPath` in the lspconfig to point to the active venv's Python.

**Warning signs:**
- False "module not found" errors for packages that are clearly installed
- Import resolution works in terminal but not in Neovim
- Type checker uses wrong Python version

**Phase to address:** Phase 2 (LSP + Completion) — test with a real Python project that has a venv. Accept only when imports resolve correctly inside a venv.

---

## Technical Debt Patterns

Shortcuts that seem reasonable but create long-term problems.

| Shortcut | Immediate Benefit | Long-term Cost | When Acceptable |
|----------|-------------------|----------------|-----------------|
| Hardcoding Nix store paths in `cmd` | LSP starts working immediately | Breaks on every `nix rebuild`, config not portable | Never — use exepath() instead |
| Copy a full distribution config (LazyVim) | Everything works out of the box | 100+ plugins, mystery keymaps, slow startup, hard to debug | Never for this project — defeats the purpose |
| Setting `ensure_installed` for all languages | Parsers just work | Conflicts on Nix, slow first-start compile | Only if auto_install doesn't meet needs |
| Disabling lazy loading for all plugins (`lazy = false`) | Simpler config, no "plugin not loaded" errors | Defeats 100ms startup goal, startup grows with each plugin | MVP only, then revisit |
| Using Mason alongside Nix | Familiar workflow from tutorials | Duplicate installs, Mason fails on Nix due to read-only FS, version mismatches | Never — this project uses Nix exclusively |
| Installing every lspconfig server preset | Easy: just call `setup()` for everything | Memory cost, LSP clients attach to wrong filetypes, noise | Never — configure only languages in packages.nix |

---

## Integration Gotchas

Common mistakes when connecting components.

| Integration | Common Mistake | Correct Approach |
|-------------|----------------|------------------|
| lspconfig + blink.cmp/nvim-cmp | Forgetting to update LSP capabilities to enable completion suggestions | Pass `capabilities = require("blink.cmp").get_lsp_capabilities()` (or nvim-cmp equivalent) to every `lspconfig.X.setup({})` call |
| treesitter + LSP | Enabling treesitter indent for languages where the LSP also provides indentation, causing conflicts | Disable treesitter indent (`indent = { enable = false }`) for Go and Lua where LSP indent works better |
| fzf.vim + telescope | Both installed, different keymaps, cognitive overhead | Pick one. fzf.vim is already in the config; telescope adds plenary overhead. Use fzf for files/text, telescope only if commander.nvim requires it |
| gitsigns + lazy-loading | gitsigns set to lazy load on `BufReadPost` but git blame and hunk navigation don't work until after first write | Load gitsigns on `BufReadPost` (not `VeryLazy`) to ensure it attaches immediately when opening git-tracked files |
| LSP + null-ls/conform | Configuring LSP formatting AND a formatter plugin for the same filetype causes double-format on save | Use LSP formatting for languages where the server supports it (gopls, typescript-language-server), use conform/none-ls only for languages where LSP formatting is poor |

---

## Performance Traps

Patterns that kill startup time.

| Trap | Symptoms | Prevention | When It Breaks |
|------|----------|------------|----------------|
| Loading colorscheme plugin on startup without `priority = 1000` | Flash of wrong colors, other plugins see wrong highlights | Set `priority = 1000, lazy = false` on colorscheme plugin | Every startup |
| Telescope loaded at startup (no `cmd =`) | Adds 15-40ms for plenary + telescope modules | Use `cmd = "Telescope"` to defer until first invocation | Immediately |
| `require("lspconfig")` called at top-level (not inside config function) | lspconfig loads at startup even if no LSP-enabled file is open | Wrap in `event = "BufReadPost"` lazy trigger | Every startup |
| treesitter highlight enabled for all filetypes including very large files | Editor freezes on large log files or minified JS | Add `disable = function(_, buf) return vim.api.nvim_buf_line_count(buf) > 10000 end` | When opening large files |
| nvim-cmp loaded in normal mode | Completion popup visible in non-insert contexts, resources wasted | Load cmp on `InsertEnter` event | Every startup |
| Sync plugin installs (no `event` or `keys`) for non-critical plugins | Startup adds 5-10ms per synchronously loaded plugin | Audit `:Lazy profile` and add `event` or `keys` triggers | Each additional plugin |

---

## "Looks Done But Isn't" Checklist

Things that appear complete but are missing critical pieces.

- [ ] **LSP configured:** Run `vim.fn.exepath("gopls")` (and all other servers) inside Neovim — verify non-empty before calling LSP "done"
- [ ] **LSP attached:** Open a Go file and run `:LspInfo` — verify the server appears as "active" not "attached to other buffers"
- [ ] **Completion working:** LSP completion items (not just buffer/path) appear in insert mode — check source label in popup
- [ ] **Treesitter highlighting:** Run `:TSBufInfo` in each target language — verify parser is installed and active, not falling back to regex
- [ ] **Startup time measured:** Run `nvim --startuptime /tmp/nvim-startup.log +q` and check total time, not just assumed
- [ ] **All LSP servers tested:** Open one file per language (Go, Python, TS, Nix, C/C++, Rust) and verify LSP attaches
- [ ] **Python venv test:** Open a Python file inside a project with `.venv`, verify imports resolve to venv packages
- [ ] **Keymaps not shadowed:** Run `:map <Space>` to verify all intended leader mappings exist and nothing unexpected appears
- [ ] **No startup errors:** Run `nvim` with a clean data directory (`NVIM_DATA=/tmp/test nvim`) and check for errors in `:messages`

---

## Recovery Strategies

When pitfalls occur despite prevention, how to recover.

| Pitfall | Recovery Cost | Recovery Steps |
|---------|---------------|----------------|
| LSP not on PATH | LOW | Add `vim.env.PATH = vim.env.PATH .. ":" .. "/run/current-system/sw/bin"` as a temporary diagnostic; then fix permanently via shell profile or nix-darwin configuration |
| treesitter parser conflicts | LOW | Run `:TSUpdate` to force reinstall; if it fails, delete `~/.local/share/nvim/lazy/nvim-treesitter/parser/` and let auto_install regenerate |
| blink.cmp build failure | LOW | Switch to `nvim-cmp` (pure Lua, no build step); or run `cd ~/.local/share/nvim/lazy/blink.cmp && cargo build --release` manually |
| Startup regression past 100ms | MEDIUM | Run `:Lazy profile`, identify heaviest plugins, add `event` triggers; check `nvim --startuptime /tmp/s.log +q` for non-plugin sources |
| Plugin keymap conflict | LOW | Use `:verbose map <key>` to find which plugin owns the mapping; override in your config with explicit `vim.keymap.set(..., { force = true })` |
| Wrong Neovim version | MEDIUM | Check `vim.version()` — requires Neovim 0.10+ for vim.lsp.config API; nix channel may have older version; pin nixpkgs or use overlays |

---

## Pitfall-to-Phase Mapping

How roadmap phases should address these pitfalls.

| Pitfall | Prevention Phase | Verification |
|---------|------------------|--------------|
| Nix PATH breaks LSP discovery | Phase 1: Foundation | `vim.fn.exepath("gopls")` returns non-empty from inside Neovim |
| treesitter ensure_installed conflicts | Phase 1: Foundation | `:checkhealth nvim-treesitter` shows no errors; `:TSBufInfo` shows parsers active |
| mapleader set after lazy.nvim | Phase 1: Foundation | `<Space>` triggers command palette immediately |
| blink.cmp Rust build failure | Phase 2: LSP + Completion | Completion popup appears with LSP source items in insert mode |
| rust-analyzer missing from Nix | Phase 1: Foundation | Audit packages.nix against languages before writing any lspconfig |
| lazy.nvim dependencies anti-pattern | Phase 1: Foundation | `:Lazy profile` shows no surprise loads at startup |
| Neovim 0.11 API transition confusion | Phase 2: LSP + Completion | Decide lspconfig vs native at phase start; consistent approach throughout |
| Python venv not detected | Phase 2: LSP + Completion | Test with a real `.venv` project; imports resolve correctly |
| Startup time regression | All phases | Run `nvim --startuptime /tmp/s.log +q` at end of each phase; target stays below 100ms |

---

## Sources

- [NixOS Discourse: LSP unable to start in neovim overlay with its own PATH](https://discourse.nixos.org/t/lsp-unable-to-start-in-neovim-overlay-with-its-own-path/25200) — MEDIUM confidence (verified community solution)
- [NixOS Discourse: Setting up LSP with lspconfig and Nix language server binaries](https://discourse.nixos.org/t/i-need-help-setting-up-lsp-for-neovim-using-lspconfig-language-server-binaries/65455) — MEDIUM confidence
- [NixOS Wiki: Treesitter](https://nixos.wiki/wiki/Treesitter) — HIGH confidence (official wiki)
- [NixOS/nixpkgs Issue #189838: nvim-treesitter declarative install causes errors](https://github.com/NixOS/nixpkgs/issues/189838) — HIGH confidence (official issue)
- [NixOS/nixpkgs Issue #341442: nvim-treesitter not linking grammars](https://github.com/NixOS/nixpkgs/issues/341442) — HIGH confidence
- [The tree-sitter packaging mess](https://ayats.org/blog/tree-sitter-packaging) — MEDIUM confidence (expert analysis)
- [lazy.nvim: Don't use dependencies](https://dev.to/delphinus35/dont-use-dependencies-in-lazynvim-4bk0) — HIGH confidence (verified against lazy.nvim docs)
- [lazy.nvim official spec documentation](https://lazy.folke.io/spec/lazy_loading) — HIGH confidence (official)
- [Neovim 0.11 native LSP changes](https://gpanders.com/blog/whats-new-in-neovim-0-11/) — HIGH confidence (written by Neovim core contributor)
- [NixOS/nixpkgs Issue #386404: blink-cmp errors on startup](https://github.com/NixOS/nixpkgs/issues/386404) — HIGH confidence (official issue)
- [blink.cmp Issue #1278: Nix build fails](https://github.com/saghen/blink.cmp/issues/1278) — HIGH confidence
- [vim-startuptime tool](https://github.com/rhysd/vim-startuptime) — HIGH confidence

---
*Pitfalls research for: Neovim configuration with Nix-managed LSP, lazy.nvim, treesitter*
*Researched: 2026-02-26*
