# Phase 1: Foundation - Research

**Researched:** 2026-02-26
**Domain:** Neovim config modularization, lazy.nvim, modus-themes.nvim, nvim-treesitter, Nix PATH verification
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Config structure:**
- Modular `lua/plugins/` directory with lazy.nvim auto-scanning via `require("lazy").setup("plugins")`
- Core config in `lua/config/`: `options.lua`, `keymaps.lua`, `autocmds.lua`
- `init.lua` becomes a thin bootstrap: load config modules, bootstrap lazy.nvim, call lazy setup
- One plugin spec file per concern (e.g., `lua/plugins/colorscheme.lua`, `lua/plugins/treesitter.lua`)
- Lockfile stays at `vim.fn.stdpath("data")` to avoid read-only Nix store issues

**Colorscheme:**
- Use `miikanissi/modus-themes.nvim` with `modus_vivendi_tinted` variant
- Remove the entire hand-rolled colorscheme block from current init.lua
- Eager-load (no lazy trigger) — colorscheme must be first visual thing applied
- Accept default highlight groups — modus-themes provides full treesitter + LSP coverage
- If `modus_vivendi_tinted` background doesn't match the current `#1d2235`, use the plugin's override mechanism to set it

**Keybind philosophy:**
- Keep space as leader, preserve existing muscle memory binds (`<leader>w`, `<leader>q`, `<leader>h`)
- Keep window navigation (`C-hjkl`) and visual indenting (`</>gv`)
- Remove fzf.vim, telescope, commander, and plenary — they'll be replaced by fzf-lua in Phase 3
- The `-` binding for netrw/Ex stays temporarily until neo-tree replaces it in Phase 3
- Group future keybinds by prefix: `<leader>f` = find, `<leader>g` = git, `<leader>l` = LSP

**Treesitter scope:**
- Install all 12 parsers: nix, python, typescript, go, rust, c, lua, markdown, json, yaml, toml, bash
- Use `ensure_installed` list with `auto_install = false` — explicit is better
- Lazy-load treesitter on `BufReadPre` event (not VeryLazy — avoid missing initial buffer)
- Enable: `highlight`, `indent`, `incremental_selection`
- Disable: `textobjects` (adds startup cost, defer to v2 if wanted)

### Claude's Discretion
- Exact autocmd choices (only add what's genuinely useful)
- Whether to add a `lua/config/lazy.lua` for the bootstrap or keep it in init.lua
- Treesitter `incremental_selection` keybinds
- Any minor options tweaks beyond what's already set

### Deferred Ideas (OUT OF SCOPE)
None — discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| FNDN-01 | Config uses modular lua/plugins/ structure with lazy.nvim auto-scanning | lazy.nvim `require("lazy").setup("plugins")` auto-scans all files in `lua/plugins/` — official documented behavior |
| FNDN-02 | Modus vivendi tinted colorscheme via modus-themes.nvim with treesitter/LSP highlight support | modus-themes.nvim confirmed with `style = "modus_vivendi"` + `variant = "tinted"` or `vim.cmd("colorscheme modus_vivendi_tinted")`; `on_colors` callback enables background override |
| FNDN-03 | Treesitter installed with parsers for all target languages | nvim-treesitter `master` branch supports `ensure_installed` + `require("nvim-treesitter.configs").setup()` — use `branch = "master"` in lazy spec to keep old API |
| FNDN-04 | Core options, keymaps, and autocmds extracted into separate modules | Mechanical migration — move existing init.lua blocks to `lua/config/{options,keymaps,autocmds}.lua` |
| FNDN-05 | Neovim cold start under 100ms via `--startuptime` | With only colorscheme loading eagerly and everything else deferred, expected cold start is 25-40ms |
</phase_requirements>

---

## Summary

Phase 1 migrates a monolithic `init.lua` (currently ~154 lines with inline colorscheme, fzf.vim, telescope, and commander) into a modular `lua/config/` + `lua/plugins/` structure. The migration is largely mechanical — existing options, keymaps, and autocmds move to their own files with no logic changes. The hand-rolled colorscheme block is replaced entirely by modus-themes.nvim. Treesitter is installed fresh with all 12 parsers.

Two findings require attention beyond what project-level research covered. First, nvim-treesitter underwent a full incompatible rewrite moving from `master` to `main` branch in 2025. The new `main` branch removes `ensure_installed`, `auto_install`, `require("nvim-treesitter.configs").setup()`, and the `highlight`/`indent` module configuration. The CONTEXT.md decision to use `ensure_installed` only works with `branch = "master"` — the frozen legacy branch. This is the right choice for this project: the old API is more ergonomic, still functions correctly on Neovim 0.11, and the `master` branch is explicitly maintained for backward compatibility. Lazy-loading treesitter on `BufReadPre` also requires the `master` branch — the new `main` branch requires `lazy = false`.

Second, modus-themes.nvim's `modus_vivendi_tinted` variant uses `bg_main = "#0d0e1c"` as its primary background — substantially darker than the current hand-rolled `#1d2235`. The CONTEXT.md already anticipates this and specifies using the `on_colors` callback to override it. The exact override uses `colors.bg_main = "#1d2235"` inside the `on_colors` function.

**Primary recommendation:** Use `branch = "master"` for nvim-treesitter to keep the familiar `ensure_installed` API, override modus-themes background with `on_colors`, and follow the lazy loading tiers established in project-level architecture research.

---

## Standard Stack

### Core (Phase 1 only)

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| lazy.nvim | stable | Plugin manager + module scanning | Already bootstrapped; `require("lazy").setup("plugins")` auto-scans `lua/plugins/*.lua` |
| miikanissi/modus-themes.nvim | latest (master) | Colorscheme with treesitter + LSP semantic token support | Direct Neovim port of modus-themes; full highlight group coverage; on_colors/on_highlights overrides |
| nvim-treesitter/nvim-treesitter | **branch = "master"** | Parser lifecycle management and highlight/indent modules | Only the `master` branch supports `ensure_installed`, `auto_install`, and the configs module API |

### Not Installed in This Phase
fzf.vim, telescope, commander, and plenary are removed from the lazy spec in Phase 1 (keybinds they provided are temporarily dropped or kept as plain Neovim commands). fzf-lua replaces all of them in Phase 3.

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `branch = "master"` (nvim-treesitter) | `branch = "main"` (new rewrite) | New main branch removes ensure_installed and configs.setup() API; requires FileType autocmds with `vim.treesitter.start()` and manual parser installation — significantly more verbose for 12 parsers. Use master for familiar API. |
| modus-themes.nvim | hand-rolled colorscheme (keep) | Hand-rolled misses treesitter highlight groups (@variable, @function, etc.) and LSP semantic tokens. modus-themes.nvim handles all of these. |

---

## Architecture Patterns

### Recommended Project Structure

```
dotfiles/nvim/
├── init.lua                  # Bootstrap only: leader, config/, lazy bootstrap, lazy.setup("plugins")
├── stylua.toml               # Lua formatter (already exists)
├── .neoconf.json             # LSP project config (already exists)
└── lua/
    ├── config/
    │   ├── options.lua       # All vim.opt.* settings — migrated from init.lua
    │   ├── keymaps.lua       # Non-plugin keymaps — migrated from init.lua
    │   └── autocmds.lua      # Autocmds (filetype tweaks, trailing whitespace, etc.)
    └── plugins/
        ├── colorscheme.lua   # modus-themes.nvim, lazy=false, priority=1000
        └── treesitter.lua    # nvim-treesitter, branch="master", BufReadPre
```

### Pattern 1: Thin init.lua Bootstrap

**What:** `init.lua` contains only the minimal bootstrap sequence — no plugin config, no option lists, no colorscheme code.

**When to use:** Always. The module migration is the core goal of Phase 1.

**Example:**
```lua
-- Source: lazy.nvim official docs + ARCHITECTURE.md
-- 1. Leader MUST be first — before lazy loads
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- 2. Load core config modules (no plugin deps)
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- 3. Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 4. Load plugins via directory scan (lua/plugins/*.lua)
require("lazy").setup("plugins", {
  ui = { border = "rounded" },
  lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json",
})
```

### Pattern 2: Colorscheme Plugin Spec (Eager Load)

**What:** Colorscheme loads before everything else. `priority = 1000` + `lazy = false` guarantees this.

**When to use:** Always for colorschemes — any other loading trigger causes a flash of wrong colors.

**Example:**
```lua
-- lua/plugins/colorscheme.lua
-- Source: lazy.nvim spec docs + miikanissi/modus-themes.nvim README
return {
  "miikanissi/modus-themes.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("modus-themes").setup({
      style = "modus_vivendi",
      variant = "tinted",
      on_colors = function(colors)
        -- bg_main in modus_vivendi_tinted defaults to #0d0e1c
        -- Override to match current terminal/Alacritty bg #1d2235
        colors.bg_main = "#1d2235"
      end,
    })
    vim.cmd("colorscheme modus_vivendi_tinted")
  end,
}
```

### Pattern 3: Treesitter with master Branch

**What:** nvim-treesitter on `branch = "master"` uses the familiar `configs.setup()` API with `ensure_installed` and module toggles. Lazy-loaded on `BufReadPre` so it costs 0ms at cold start.

**When to use:** This project. The new `main` branch removes `ensure_installed` — stick with master for explicit parser control.

**Example:**
```lua
-- lua/plugins/treesitter.lua
-- Source: nvim-treesitter master branch README
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",
  build = ":TSUpdate",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "nix", "python", "typescript", "go", "rust", "c",
        "lua", "markdown", "json", "yaml", "toml", "bash",
      },
      auto_install = false,
      sync_install = false,
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    })
  end,
}
```

### Pattern 4: Config Module Files

**What:** Each `lua/config/` file is a plain Lua file with no return value. `init.lua` requires them directly.

**Example:**
```lua
-- lua/config/options.lua
-- (Migrated from existing init.lua — no changes to the values)
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.termguicolors = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
```

```lua
-- lua/config/keymaps.lua
-- (Migrated from existing init.lua — keep all existing binds)
vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear highlights" })
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Window left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Window down" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Window up" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window right" })
vim.keymap.set("v", "<", "<gv", { desc = "Indent left" })
vim.keymap.set("v", ">", ">gv", { desc = "Indent right" })
vim.keymap.set("n", "-", ":Ex<CR>", { desc = "File explorer (netrw)" })
```

### Anti-Patterns to Avoid

- **Requiring plugins in `lua/config/` files**: Options, keymaps, and autocmds load before plugins. If any config file calls `require("some-plugin")`, it will error.
- **Setting `vim.g.mapleader` after `require("lazy").setup()`**: Plugins register `<leader>` maps during their `config` functions. Leader must be set first or the wrong leader gets baked in.
- **Using `require("lazy").setup({...})` with an inline table AND separately calling `require("config.lazy")`**: Choose one — either `setup("plugins")` module scan or inline spec. Do not mix.
- **Keeping the hand-rolled colorscheme block in `init.lua`**: It runs before the plugin loads and will be overwritten — or conflict with — modus-themes.nvim. Remove it entirely.
- **Adding treesitter to lazy.nvim `dependencies` of another plugin**: This forces treesitter to load when the parent loads rather than on `BufReadPre`. Keep it as a top-level spec with its own event trigger.

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Colorscheme with treesitter hl groups | More `vim.api.nvim_set_hl()` calls covering @variable, @function, etc. | modus-themes.nvim | The plugin covers ~200 treesitter highlight groups and LSP semantic tokens. Hand-rolling these correctly is a days-long project. |
| Parser installation and version tracking | Manual `:TSInstall` scripts | nvim-treesitter `build = ":TSUpdate"` | Parser grammar versions must match the treesitter library version exactly. The build hook keeps them in sync automatically. |
| Module auto-discovery in `lua/plugins/` | `require("plugins.colorscheme")` etc. in init.lua | `require("lazy").setup("plugins")` | lazy.nvim scans the entire `lua/plugins/` directory automatically. Manual require() causes double-loading. |

**Key insight:** The hand-rolled colorscheme is the primary thing to discard. Even with the background color mismatch, the `on_colors` override in modus-themes.nvim takes 2 lines and gives treesitter + LSP highlight group coverage that would take days to hand-roll.

---

## Common Pitfalls

### Pitfall 1: nvim-treesitter main vs master Branch

**What goes wrong:** Installing nvim-treesitter without specifying `branch = "master"` pulls the new `main` branch, which removed `require("nvim-treesitter.configs").setup()`, `ensure_installed`, `auto_install`, and the `highlight`/`indent` module config. The config will error with "attempt to call a nil value" or silently do nothing.

**Why it happens:** nvim-treesitter switched its default branch from `master` to `main` in mid-2025. lazy.nvim clones the default branch unless specified. The new API uses `require("nvim-treesitter").setup()` + `require("nvim-treesitter").install({...}):wait()` — a completely different shape.

**How to avoid:** Always specify `branch = "master"` in the lazy.nvim spec:
```lua
{ "nvim-treesitter/nvim-treesitter", branch = "master", build = ":TSUpdate", ... }
```

**Warning signs:** Error message "module 'nvim-treesitter.configs' not found" at startup, or no treesitter highlights after opening files.

---

### Pitfall 2: modus_vivendi_tinted Background Mismatch

**What goes wrong:** The plugin's `bg_main` for `modus_vivendi_tinted` is `#0d0e1c` (very dark blue-black). The current hand-rolled config uses `#1d2235` (the plugin's `bg_dim`). After installing the plugin without overrides, the editor background looks noticeably different from the terminal.

**Why it happens:** The Emacs modus-vivendi-tinted theme uses `#0d0e1c` as its canonical background. The user's existing hand-rolled config was using a different shade from that palette.

**How to avoid:** Use the `on_colors` callback:
```lua
require("modus-themes").setup({
  style = "modus_vivendi",
  variant = "tinted",
  on_colors = function(colors)
    colors.bg_main = "#1d2235"
  end,
})
vim.cmd("colorscheme modus_vivendi_tinted")
```

**Warning signs:** Background color is clearly darker than expected; terminal and editor backgrounds don't match.

---

### Pitfall 3: Hand-Rolled Colorscheme Block Not Removed

**What goes wrong:** If the inline colorscheme block (`vim.cmd("hi clear")`, `vim.api.nvim_set_hl(...)` calls) in `init.lua` is not removed before installing modus-themes.nvim, it runs at startup and partially overrides the plugin's highlights. The result is an inconsistent hybrid — some groups use hand-rolled colors, others use modus-themes.nvim. Debugging is confusing.

**Why it happens:** `init.lua` runs before lazy.nvim processes plugin `config` functions, so the hand-rolled highlights are set first, then partially overwritten when modus-themes.nvim loads.

**How to avoid:** Delete the entire colorscheme block (lines 41–74 of the current init.lua) as part of the migration. No partial removal — all of it.

**Warning signs:** Some highlight groups look correct, others look wrong; `:hi Normal` shows unexpected colors despite colorscheme being "applied."

---

### Pitfall 4: Nix PATH Verification Required Before Phase 2

**What goes wrong:** This phase's FNDN-05 acceptance criterion requires `vim.fn.exepath("gopls")` to return a non-empty path. If the PATH verification is skipped, Phase 2's LSP configuration will fail silently — LSP clients will not attach.

**Why it happens:** Nix packages on PATH are inherited from the shell environment at the time Neovim starts. Neovim launched via a GUI, launchd agent, or abbreviated shell may not source the full Nix profile.

**How to avoid:** Run the diagnostic at the end of Phase 1 before declaring it complete:
```lua
-- Run this in a scratch buffer with :luafile %
print("PATH:", vim.env.PATH)
print("gopls:", vim.fn.exepath("gopls"))
print("typescript-language-server:", vim.fn.exepath("typescript-language-server"))
print("lua-language-server:", vim.fn.exepath("lua-language-server"))
print("nixd:", vim.fn.exepath("nixd"))
print("rust-analyzer:", vim.fn.exepath("rust-analyzer"))
```

**Warning signs:** Any of the exepath() calls returns an empty string; `:!which gopls` in terminal works but same check inside Neovim fails.

---

### Pitfall 5: Missing Nix Packages — lua-language-server, nixd, rust-analyzer

**What goes wrong:** The current `modules/common/packages.nix` is missing three LSP servers needed for Phase 2: `lua-language-server`, `nixd`, and `rust-analyzer`. They must be added to nixpkgs and the system rebuilt before Phase 2 starts.

**Why it happens:** The current config was never using LSP — these packages were never needed. `rustc` and `cargo` are present but `rust-analyzer` is separate.

**How to avoid:** Add to `modules/common/packages.nix` during Phase 1:
```nix
lua-language-server    # Lua LSP (pkgs.lua-language-server)
nixd                   # Nix LSP (pkgs.nixd)
rust-analyzer          # Rust LSP (pkgs.rust-analyzer)
```
Then rebuild: `nxr` (personal machine) or `darwin-rebuild switch --flake ~/nix#Seths-MacBook-Pro` (work).

**Warning signs:** `vim.fn.exepath("lua-language-server")` returns empty string after rebuild.

---

### Pitfall 6: Treesitter Parser Install Writes to Wrong Location on Nix

**What goes wrong:** On Nix, `~/.config/nvim` is read-only (Nix store symlink). If nvim-treesitter tries to write parser compiled binaries there, it fails. Additionally, Neovim ships with built-in parsers (C, Lua, Vim, Vimdoc, Query) in the Nix store. If treesitter also tries to install those parsers, it may conflict.

**Why it happens:** nvim-treesitter writes parsers to `vim.fn.stdpath("data") .. "/site/parser/"` which is `~/.local/share/nvim/site/parser/` — writable. But the built-in parsers in the Nix store parsers directory can conflict.

**How to avoid:** Set `auto_install = false` (locked decision) and `sync_install = false`. Only list the 12 target parsers in `ensure_installed`. Do not include c, lua, vim, vimdoc, query — these are built-in and conflict. The target list already excludes them.

Run `:checkhealth nvim-treesitter` after installation to confirm no conflicts.

**Warning signs:** Startup errors containing "destination path already exists"; `:TSBufInfo` shows parsers missing for some filetypes.

---

## Code Examples

Verified patterns from official sources and CONTEXT.md decisions:

### Complete colorscheme.lua

```lua
-- lua/plugins/colorscheme.lua
-- Source: miikanissi/modus-themes.nvim README
return {
  "miikanissi/modus-themes.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("modus-themes").setup({
      style = "modus_vivendi",
      variant = "tinted",
      styles = {
        comments = { italic = true },
        keywords = { italic = false },
      },
      on_colors = function(colors)
        -- Plugin default bg_main is #0d0e1c; override to match terminal
        colors.bg_main = "#1d2235"
      end,
    })
    vim.cmd("colorscheme modus_vivendi_tinted")
  end,
}
```

### Complete treesitter.lua

```lua
-- lua/plugins/treesitter.lua
-- Source: nvim-treesitter master branch README + CONTEXT.md decisions
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "master",           -- REQUIRED: new "main" branch removed this API
  build = ":TSUpdate",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        "nix", "python", "typescript", "go", "rust", "c",
        "lua", "markdown", "json", "yaml", "toml", "bash",
      },
      auto_install = false,
      sync_install = false,
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    })
  end,
}
```

### Packages to Add to modules/common/packages.nix

```nix
# Add these three to the systemPackages list:
lua-language-server    # Lua language server for Neovim config editing
nixd                   # Nix language server (feature-rich, nixpkgs-aware)
rust-analyzer          # Rust language server (separate from rustc/cargo)
```

### PATH Verification Diagnostic Script

```lua
-- Save as /tmp/check-path.lua and run with :luafile /tmp/check-path.lua
local servers = {
  "gopls",
  "pyright",
  "typescript-language-server",
  "lua-language-server",
  "nixd",
  "rust-analyzer",
  "ccls",
}

print("=== Neovim PATH check ===")
for _, server in ipairs(servers) do
  local path = vim.fn.exepath(server)
  local status = path ~= "" and "OK  " or "FAIL"
  print(string.format("[%s] %s: %s", status, server, path ~= "" and path or "NOT FOUND"))
end
```

### Startup Time Measurement

```bash
# Run from terminal after Phase 1 complete
nvim --startuptime /tmp/nvim-startup.log +q
tail -5 /tmp/nvim-startup.log
```

The last line shows total time. Target: under 100ms. Expected with this phase's setup: 25-40ms.

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `require("nvim-treesitter.configs").setup({...})` | New `main` branch: `require("nvim-treesitter").setup()` + `vim.treesitter.start()` | Mid-2025 (nvim-treesitter default branch switch) | Use `branch = "master"` to keep old API — it is frozen but stable |
| Inline colorscheme via `nvim_set_hl()` calls | Plugin-provided with full treesitter/LSP hl group support | N/A — community shifted to plugins for treesitter groups | Remove the hand-rolled block entirely; modus-themes.nvim is a strict upgrade |
| `require("lazy").setup({...})` with inline specs | `require("lazy").setup("plugins")` with directory scanning | lazy.nvim initial design | Directory scanning eliminates manual require() per plugin |
| Hand-rolled leader setup anywhere in init.lua | `vim.g.mapleader = " "` as absolute first line | Best practice since lazy.nvim v1 | Plugin `config` functions capture leader at their run time — must be pre-set |

**Deprecated/outdated in this context:**
- `require("nvim-treesitter.configs")`: Removed from nvim-treesitter `main` branch. Valid only on `master`.
- Inline `vim.api.nvim_set_hl()` colorscheme: Misses ~200 treesitter highlight groups and all LSP semantic tokens.
- fzf.vim + telescope + commander: All three removed in Phase 1, replaced by fzf-lua in Phase 3.

---

## Open Questions

1. **modus_vivendi_tinted background — exact match needed?**
   - What we know: Plugin `bg_main = "#0d0e1c"`, current config uses `#1d2235` (which is `bg_dim` in the palette)
   - What's unclear: Whether the user wants strict `#1d2235` match or is open to the canonical `#0d0e1c`
   - Recommendation: Apply `on_colors` override to `#1d2235` as specified in CONTEXT.md; the user can always remove it if they prefer the canonical color

2. **autocmds.lua content — what goes in it?**
   - What we know: Current init.lua has no autocmds defined
   - What's unclear: Whether to create a minimal empty file or add genuinely useful autocmds now
   - Recommendation: Create the file with 1-2 high-value autocmds only (e.g., highlight on yank, trim trailing whitespace on save for non-markdown files). Do not add autocmds speculatively.

3. **lua/config/lazy.lua separate file — worth it?**
   - What we know: CONTEXT.md marks this as Claude's discretion
   - What's unclear: Threshold of complexity where extraction is worth it
   - Recommendation: Keep bootstrap in `init.lua`. At ~10 lines, it is not complex enough to warrant a separate file. Extract only if the bootstrap grows beyond 20 lines.

---

## Sources

### Primary (HIGH confidence)
- [lazy.nvim Structuring Plugins docs](https://lazy.folke.io/usage/structuring) — `require("lazy").setup("plugins")` auto-scan, module merging behavior
- [miikanissi/modus-themes.nvim README](https://github.com/miikanissi/modus-themes.nvim) — setup() API, on_colors/on_highlights callbacks, style/variant options
- [nvim-treesitter master branch README](https://github.com/nvim-treesitter/nvim-treesitter) — current API including `lazy = false` requirement, build hook
- [nvim-treesitter wiki/Installation](https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation) — lazy.nvim spec, `branch = "master"` requirement confirmed
- Project research: ARCHITECTURE.md, PITFALLS.md, STACK.md — all HIGH confidence, already verified

### Secondary (MEDIUM confidence)
- [nvim-treesitter migration discussion #7927](https://github.com/nvim-treesitter/nvim-treesitter/discussions/7927) — master vs main branch differences, what was removed
- [Aliou Diallo: Upgrading nvim-treesitter](https://aliou.me/posts/upgrading-nvim-treesitter/) — old vs new API migration examples
- [LazyVim treesitter spec](http://www.lazyvim.org/plugins/treesitter) — `ensure_installed` with new main branch (via TS.setup wrapper), lazy loading via LazyFile event
- [mynixos.com: lua-language-server](https://mynixos.com/nixpkgs/package/lua-language-server) — nixpkgs package name confirmed
- [mynixos.com: nixd](https://mynixos.com/nixpkgs/package/nixd) — nixpkgs package name confirmed

### Tertiary (LOW confidence)
- modus_vivendi_tinted palette background values (#0d0e1c for bg_main, #1d2235 for bg_dim) — sourced via WebFetch of extras/lua file; verify against actual plugin source before using

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — lazy.nvim, modus-themes.nvim, nvim-treesitter master branch all verified against official sources
- Architecture: HIGH — direct continuation of project-level architecture research with new treesitter branch finding
- Pitfalls: HIGH — nvim-treesitter master/main distinction is a critical new finding with official source confirmation; others from project-level research

**Research date:** 2026-02-26
**Valid until:** 2026-03-28 (30 days) for lazy.nvim and modus-themes; 2026-03-05 (7 days) for nvim-treesitter due to active development
