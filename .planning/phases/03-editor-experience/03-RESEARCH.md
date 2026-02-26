# Phase 3: Editor Experience - Research

**Researched:** 2026-02-26
**Domain:** Neovim fuzzy finding (fzf-lua), git gutter signs (gitsigns.nvim), file tree (neo-tree.nvim)
**Confidence:** HIGH

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Fuzzy finder (fzf-lua)**
- fzf-lua for all finding — replaces fzf.vim and telescope
- Centered floating window with preview pane on the right
- File picker shows devicons and respects .gitignore
- `<leader>ff` files, `<leader>fg` live grep, `<leader>fb` buffers
- Live grep uses ripgrep (already on PATH)
- Remove fzf.vim and telescope after fzf-lua is working

**Command palette**
- `<leader>fc` opens fzf-lua's builtin keymaps/commands picker
- Shows all available keymaps and commands in one searchable list
- No separate commander plugin needed — fzf-lua covers this

**Git gutter (gitsigns.nvim)**
- Signs only: `+` added, `~` modified, `-` deleted in the gutter
- No inline blame by default (too noisy for fast editing)
- Hunk navigation: `]h` next hunk, `[h` previous hunk
- Stage/unstage hunks available under `<leader>g` prefix but not primary workflow
- Load on BufReadPre for git repos only

**File tree (neo-tree.nvim)**
- Left side, 30 character width
- Toggle with `<leader>e`
- Closed by default — toggle open when needed
- Show file icons and git status indicators
- Opening a file from tree focuses the file, tree stays open
- Filesystem source only (no buffers/git source tabs)

### Claude's Discretion
- fzf-lua theme/color integration with modus vivendi
- Exact gitsigns sign characters and highlight groups
- neo-tree indent guides and styling
- Whether to lazy-load neo-tree on command or on VeryLazy

### Deferred Ideas (OUT OF SCOPE)

None — discussion stayed within phase scope
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| FIND-01 | fzf-lua replaces fzf.vim, telescope, and commander | fzf-lua lazy loaded via `keys` trigger; old plugins removed by deleting their plugin files |
| FIND-02 | File picker, live grep, and buffer list via leader keybinds | `FzfLua files`, `FzfLua live_grep`, `FzfLua buffers` — all map directly to fzf-lua builtins |
| FIND-03 | Commands/keymaps browser as toggleable command palette | `FzfLua keymaps` shows all keymaps; `FzfLua commands` shows all commands — both are builtins |
| GIT-01 | Gitsigns shows added/changed/deleted signs in gutter | gitsigns.nvim `signs` table configures text per change type; lazy loaded via `event = "BufReadPre"` |
| GIT-02 | Navigate between hunks with keybinds | `gitsigns.nav_hunk('next')` / `gitsigns.nav_hunk('prev')` — set in `on_attach` callback |
| TREE-01 | Neo-tree toggleable sidebar, closed by default | `Neotree toggle` command; `sources = { "filesystem" }` for filesystem-only mode |
| TREE-02 | Single keybind to toggle tree open/closed | `<leader>e` mapped to `Neotree toggle` via lazy.nvim `keys` trigger |
</phase_requirements>

## Summary

Phase 3 installs three well-established Neovim plugins: fzf-lua (fuzzy finder), gitsigns.nvim (git gutter), and neo-tree.nvim (file tree). All are actively maintained, widely adopted, and have direct lazy.nvim integration. The phase also removes two existing plugins (fzf.vim and telescope/commander equivalents) once fzf-lua is confirmed working.

The most important technical finding is the **neo-tree lazy loading pitfall**: neo-tree v3.30+ has its own internal lazy-loading mechanism. Using `keys` or `cmd` triggers in lazy.nvim without an additional `init` BufEnter autocmd causes a blank buffer bug when opening Neovim on a directory. The LazyVim-blessed pattern (add a `once = true` BufEnter autocmd in the `init` field) prevents this. Since the user wants "closed by default" and not directory hijacking, this is lower risk here, but the pattern should still be followed.

fzf-lua's command palette requirement maps to two builtins: `:FzfLua keymaps` (all keymaps with descriptions) and `:FzfLua commands` (all Neovim commands). The user decision uses `<leader>fc` — research confirms this can call either or both. The most useful single binding for "command palette" is `keymaps`, as it surfaces all defined leader bindings. A second binding for `commands` adds Neovim's ex-commands.

**Primary recommendation:** Three separate plugin files (`fzf-lua.lua`, `gitsigns.lua`, `neo-tree.lua`) in `lua/plugins/`; lazy load all three; remove obsolete plugin files in the same plan.

## Standard Stack

### Core

| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| ibhagwan/fzf-lua | latest (no version pin needed) | Fuzzy finder for files, grep, buffers, keymaps, commands | Fastest Lua fuzzy finder; replaces both fzf.vim and telescope; native fzf binary wrapper |
| lewis6991/gitsigns.nvim | latest | Git diff signs in gutter + hunk navigation | De-facto standard for git gutter in Neovim; minimal, fast, integrates with status lines |
| nvim-neo-tree/neo-tree.nvim | branch="v3.x" | File tree sidebar | Most feature-complete file tree for Neovim; active maintenance; v3.x is stable branch |

### Supporting

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| nvim-tree/nvim-web-devicons | latest | File icons for fzf-lua and neo-tree | Required for devicons in both plugins; already likely installed or needed by both |
| nvim-lua/plenary.nvim | latest | Lua utilities required by neo-tree | neo-tree hard dependency |
| MunifTanjim/nui.nvim | latest | UI components required by neo-tree | neo-tree hard dependency |

### Alternatives Considered

| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| fzf-lua | telescope.nvim | telescope has richer ecosystem but slower; user explicitly chose fzf-lua |
| fzf-lua | snacks.nvim picker | snacks is newer, all-in-one; user explicitly chose fzf-lua |
| gitsigns.nvim | mini.diff | mini.diff is lighter but less feature-rich; gitsigns is the standard |
| neo-tree.nvim | nvim-tree.lua | nvim-tree is faster but less featureful; neo-tree v3 has self-lazy-loading |

**Installation:** These are Nix-managed Neovim plugins added as lazy.nvim plugin specs in `lua/plugins/`. No system package installation needed — lazy.nvim fetches from GitHub.

## Architecture Patterns

### Recommended Project Structure

```
lua/plugins/
├── fzf-lua.lua      # fuzzy finder (FIND-01, FIND-02, FIND-03)
├── gitsigns.lua     # git gutter signs (GIT-01, GIT-02)
└── neo-tree.lua     # file tree (TREE-01, TREE-02)
```

The existing `lua/plugins/` files (colorscheme, completion, formatting, lsp, treesitter) use the same pattern. Each new file returns a lazy.nvim plugin spec table.

### Pattern 1: fzf-lua — Lazy Load via `keys`, Floating Window, Preview Right

**What:** Plugin loads only when a mapped key is pressed for the first time. Each mapping uses `<cmd>FzfLua picker_name<CR>` syntax.

**When to use:** Correct approach for all three fuzzy finders — zero startup cost.

```lua
-- Source: https://github.com/ibhagwan/fzf-lua/blob/main/README.md
return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = "FzfLua",
  keys = {
    { "<leader>ff", "<cmd>FzfLua files<CR>",     desc = "Find files" },
    { "<leader>fg", "<cmd>FzfLua live_grep<CR>", desc = "Live grep" },
    { "<leader>fb", "<cmd>FzfLua buffers<CR>",   desc = "Buffers" },
    { "<leader>fc", "<cmd>FzfLua keymaps<CR>",   desc = "Keymaps (command palette)" },
  },
  opts = {
    winopts = {
      width  = 0.8,
      height = 0.8,
      row    = 0.5,
      col    = 0.5,
      border = "rounded",
      preview = {
        layout     = "horizontal",
        horizontal = "right:50%",
      },
    },
  },
}
```

### Pattern 2: gitsigns.nvim — Lazy Load via BufReadPre, Signs in on_attach

**What:** Plugin loads when first buffer is read. Custom signs and keymaps set inside `on_attach` callback, which fires per-buffer when gitsigns attaches.

**When to use:** Standard gitsigns setup. BufReadPre is the canonical event — loads before display, never delays startup.

```lua
-- Source: https://github.com/lewis6991/gitsigns.nvim/blob/main/README.md
return {
  "lewis6991/gitsigns.nvim",
  event = "BufReadPre",
  opts = {
    signs = {
      add          = { text = "+" },
      change       = { text = "~" },
      delete       = { text = "-" },
      topdelete    = { text = "-" },
      changedelete = { text = "~" },
      untracked    = { text = "?" },
    },
    on_attach = function(bufnr)
      local gs = require("gitsigns")
      local function map(mode, l, r, desc)
        vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
      end

      -- Hunk navigation (respects diff mode)
      map("n", "]h", function()
        if vim.wo.diff then vim.cmd.normal({ "]h", bang = true })
        else gs.nav_hunk("next") end
      end, "Next hunk")
      map("n", "[h", function()
        if vim.wo.diff then vim.cmd.normal({ "[h", bang = true })
        else gs.nav_hunk("prev") end
      end, "Prev hunk")

      -- Stage/unstage under <leader>g prefix (secondary workflow)
      map("n", "<leader>gs", gs.stage_hunk,  "Stage hunk")
      map("n", "<leader>gr", gs.reset_hunk,  "Reset hunk")
      map("n", "<leader>gp", gs.preview_hunk, "Preview hunk")
    end,
  },
}
```

### Pattern 3: neo-tree.nvim — Lazy Load via keys + init BufEnter Autocmd

**What:** Plugin loads when `<leader>e` is pressed OR when Neovim opens with a directory argument. The `init` field runs at startup (before load) to register the BufEnter autocmd — this is not a startup cost, it's just registering a one-shot autocmd.

**When to use:** The LazyVim-blessed pattern. Required because neo-tree v3.30+ has internal lazy loading that conflicts with external lazy loading when opening a directory.

```lua
-- Source: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/editor/neo-tree.lua
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons",
  },
  cmd = "Neotree",
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<CR>", desc = "Toggle file tree" },
  },
  -- init runs at startup (before load) — registers a one-shot autocmd
  -- to handle `nvim /some/dir` correctly without eagerly loading neo-tree
  init = function()
    vim.api.nvim_create_autocmd("BufEnter", {
      group = vim.api.nvim_create_augroup("neotree_start_directory", { clear = true }),
      once = true,
      callback = function()
        if package.loaded["neo-tree"] then return end
        local stats = vim.uv.fs_stat(vim.fn.argv(0))
        if stats and stats.type == "directory" then
          require("neo-tree")
        end
      end,
    })
  end,
  opts = {
    sources = { "filesystem" },   -- filesystem only, no buffers/git_status tabs
    close_if_last_window = true,
    window = {
      position = "left",
      width    = 30,
    },
    filesystem = {
      follow_current_file = { enabled = true },
      use_libuv_file_watcher = true,
    },
    default_component_configs = {
      git_status = {
        symbols = {
          added     = "",
          modified  = "",
          deleted   = "✖",
          renamed   = "󰁕",
          untracked = "",
          ignored   = "",
          unstaged  = "󰄱",
          staged    = "",
          conflict  = "",
        },
      },
    },
  },
}
```

### Pattern 4: Removing Old Plugins

**What:** Old plugin files (fzf.vim equivalent, telescope, commander) are removed by deleting their files from `lua/plugins/`. lazy.nvim auto-scan means removing the file removes the plugin.

**When to use:** After confirming fzf-lua works for all required keybinds. Verification step: confirm `<leader>ff`, `<leader>fg`, `<leader>fb`, `<leader>fc` all work before deleting old files.

The current config has no telescope or fzf.vim files (only the 5 existing plugin files: colorscheme, completion, formatting, lsp, treesitter). There is nothing to remove — the old plugins mentioned in CONTEXT.md are not yet installed in this config. The `-` keybind for netrw (`vim.keymap.set("n", "-", ":Ex<CR>")`) in `keymaps.lua` should be removed once neo-tree is working.

### Anti-Patterns to Avoid

- **Loading gitsigns on VeryLazy:** VeryLazy fires after UI is ready; signs may not appear until after first buffer display flicker. BufReadPre is correct.
- **Not checking `vim.wo.diff` in hunk navigation:** Without the diff-mode check, `]h`/`[h` break in `:Gitsigns diffthis` view. Always check `vim.wo.diff` and fall back to `vim.cmd.normal`.
- **Setting neo-tree `lazy = false` without the init autocmd:** neo-tree says "lazy=false, neo-tree will lazily load itself" but this still adds the plugin to startup scan. Using `cmd` + `keys` + `init` autocmd is the correct zero-startup-cost pattern.
- **Using `FzfLua builtin` for the command palette:** `builtin` shows fzf-lua's own pickers, not Neovim keymaps. Use `FzfLua keymaps` for keymaps and `FzfLua commands` for Neovim commands.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| File fuzzy finding | Custom telescope wrapper | fzf-lua `files` picker | fzf binary is 10x faster; handles .gitignore natively via fd/rg |
| Live grep | Shell command wrapper | fzf-lua `live_grep` | Real-time rg integration; handles escaping, ignores, previews |
| Git diff signs | Custom sign column logic | gitsigns.nvim | Diff algorithm, sign placement, staged vs unstaged state are complex |
| Hunk navigation | Custom diff parsing | `gitsigns.nav_hunk()` | Handles folded lines, wrapping, diff view integration |
| File tree | Custom netrw wrapper | neo-tree.nvim | Icon rendering, git status decorators, async file watching are non-trivial |

**Key insight:** Each of these problems has solved edge cases (hidden files, binary files, large repos, sign column conflicts, async updates) that take months to get right. All three plugins are battle-tested across thousands of configurations.

## Common Pitfalls

### Pitfall 1: neo-tree Blank Buffer on First Open

**What goes wrong:** First time `<leader>e` is pressed or Neovim opens on a directory, the file buffer is blank.

**Why it happens:** neo-tree v3.30+ has its own internal lazy-loading autocmd. When user adds a `keys` trigger in lazy.nvim, both mechanisms fire and race. The internal one wins but leaves the buffer in a bad state.

**How to avoid:** Use the LazyVim pattern: add an `init` field with a `once = true` BufEnter autocmd that checks if the first arg is a directory and loads neo-tree. This handles the directory-open case without conflicts.

**Warning signs:** Opened `nvim /some/path/` and got a blank buffer; toggling neo-tree closed and reopening the file fixes it.

### Pitfall 2: gitsigns Not Showing in Non-Git Directories

**What goes wrong:** No errors but no signs appear in buffers outside git repos.

**Why it happens:** This is correct behavior. gitsigns silently no-ops outside git repos. Not a bug.

**How to avoid:** Test gitsigns in a directory that IS a git repo. The nvim config repo itself (`~/nix`) is a good test case.

**Warning signs:** No signs in any buffer — check with `:Gitsigns debug_messages` or `:checkhealth gitsigns`.

### Pitfall 3: fzf-lua Preview Layout Not Applying

**What goes wrong:** Preview appears below instead of right, or not at all.

**Why it happens:** `layout = "vertical"` means preview is below/above. For right-side preview, use `layout = "horizontal"` with `horizontal = "right:50%"`.

**How to avoid:** Use `layout = "horizontal"` (not "vertical") with `horizontal = "right:50%"` to get preview on the right side of a floating window.

**Warning signs:** Preview appears at bottom; check winopts in `:lua require('fzf-lua').setup` output.

### Pitfall 4: Keybind Conflict on `<leader>f` Prefix

**What goes wrong:** `<leader>ff` or `<leader>fg` conflicts with an existing keymap.

**Why it happens:** The existing `keymaps.lua` uses `<leader>h`, `<leader>w`, `<leader>q` but not `<leader>f`. LSP uses `<leader>l` prefix. No conflicts expected.

**How to avoid:** Audit `keymaps.lua` and `lsp.lua` before adding new binds. Current inventory: `<leader>w`, `<leader>q`, `<leader>h`, `<leader>l*`, `<C-hjkl>`. The `-` netrw bind should be removed once neo-tree is working.

**Warning signs:** Silent no-op when pressing `<leader>ff` — run `:verbose map <leader>ff` to check for conflicts.

### Pitfall 5: `nvim-web-devicons` Not Shared Between Plugins

**What goes wrong:** Both fzf-lua and neo-tree declare `nvim-web-devicons` as a dependency, causing lazy.nvim to install it twice or show a warning.

**Why it happens:** Each plugin spec independently lists it as a dependency.

**How to avoid:** This is harmless — lazy.nvim deduplicates dependencies by plugin name. Both can list it; only one copy is installed. No action needed.

## Code Examples

Verified patterns from official sources:

### fzf-lua: Keymaps Picker (Command Palette)

```lua
-- Source: https://github.com/ibhagwan/fzf-lua/blob/main/OPTIONS.md
-- FzfLua keymaps — shows all Neovim keymaps with descriptions, searchable
vim.keymap.set("n", "<leader>fc", "<cmd>FzfLua keymaps<CR>", { desc = "Keymaps (command palette)" })

-- FzfLua commands — shows all Neovim ex-commands
-- Optional second binding if user wants both:
vim.keymap.set("n", "<leader>f:", "<cmd>FzfLua commands<CR>", { desc = "Commands" })
```

### gitsigns.nvim: Hunk Navigation with Diff-Mode Guard

```lua
-- Source: https://github.com/lewis6991/gitsigns.nvim/blob/main/README.md
-- This pattern is from the official README — handles :Gitsigns diffthis correctly
map("n", "]h", function()
  if vim.wo.diff then vim.cmd.normal({ "]h", bang = true })
  else require("gitsigns").nav_hunk("next") end
end, "Next git hunk")

map("n", "[h", function()
  if vim.wo.diff then vim.cmd.normal({ "[h", bang = true })
  else require("gitsigns").nav_hunk("prev") end
end, "Prev git hunk")
```

### neo-tree.nvim: Toggle Command

```lua
-- Source: https://github.com/nvim-neo-tree/neo-tree.nvim/blob/main/README.md
-- :Neotree toggle — opens if closed, closes if open
vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<CR>", { desc = "Toggle file tree" })

-- Alternative using the Lua API (from LazyVim):
require("neo-tree.command").execute({ toggle = true, dir = vim.uv.cwd() })
```

### Removing the `-` Netrw Bind

```lua
-- In lua/config/keymaps.lua — REMOVE this line once neo-tree is working:
-- vim.keymap.set("n", "-", ":Ex<CR>", { desc = "File explorer (netrw)" })
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| fzf.vim (vimscript) | fzf-lua (Lua native) | 2021+ | Full Lua API, async, faster startup |
| telescope.nvim as default | fzf-lua as default (LazyVim 14+) | Late 2024 | Ecosystem shift; fzf-lua now mainstream |
| nvim-lspconfig (Phase 2 pattern) | vim.lsp.config (0.11 native) | Already applied | This pattern is already in use in this config |
| neo-tree v2 config API | neo-tree v3.x branch | 2023+ | v3 has different API; always use `branch = "v3.x"` |
| gitsigns `]c`/`[c` keybinds | `]h`/`[h` keybinds | User decision | User chose `]h`/`[h`; the diff-guard pattern applies to any key name |

**Deprecated/outdated:**
- `require('gitsigns.actions')`: old API — use `require('gitsigns').nav_hunk()` directly
- neo-tree `branch = "main"` or `branch = "v2.x"`: v3.x is current stable; v2 API differs
- fzf-lua `require('fzf-lua').files()` in keymap: use `<cmd>FzfLua files<CR>` (avoids loading at keymap registration time)

## Open Questions

1. **`<leader>fc` — keymaps only or keymaps + commands?**
   - What we know: user said "shows all available keymaps and commands in one searchable list"
   - What's unclear: `FzfLua keymaps` shows keymaps; `FzfLua commands` shows ex-commands; they are separate pickers
   - Recommendation: Map `<leader>fc` to `FzfLua keymaps` as primary (most useful for discovering leader binds). Optionally add `<leader>f:` for commands. Alternatively, fzf-lua has no single "everything" picker out of the box.

2. **modus vivendi color integration for fzf-lua**
   - What we know: current theme uses modus_vivendi via modus-themes.nvim; fzf-lua uses fzf's color system, not Neovim highlight groups by default
   - What's unclear: exact winopts/fzf_colors config needed to inherit modus colors
   - Recommendation: Leave as Claude's Discretion (per CONTEXT.md). Default fzf colors work fine; defer color tuning to after functional verification.

3. **neo-tree `close_if_last_window` behavior**
   - What we know: `close_if_last_window = true` closes neo-tree if it's the only window; user wants "closed by default"
   - What's unclear: whether this causes unexpected behavior in edge cases
   - Recommendation: Set to `true` — prevents being stuck with only the tree visible when closing all files.

## Sources

### Primary (HIGH confidence)
- https://github.com/ibhagwan/fzf-lua/blob/main/README.md — setup, winopts, lazy.nvim integration, picker names
- https://github.com/ibhagwan/fzf-lua/blob/main/OPTIONS.md — `keymaps` and `commands` picker names, layout options
- https://github.com/lewis6991/gitsigns.nvim/blob/main/README.md — on_attach pattern, sign config, nav_hunk API, BufReadPre event
- https://github.com/nvim-neo-tree/neo-tree.nvim/blob/main/README.md — v3.x branch, toggle command, window config, sources config
- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/editor/neo-tree.lua — canonical lazy load pattern with init BufEnter autocmd

### Secondary (MEDIUM confidence)
- https://github.com/nvim-neo-tree/neo-tree.nvim/issues/1699 — lazy load blank buffer bug, confirmed fixed with init autocmd pattern
- LazyVim fzf.lua spec (fetched) — winopts width/height/row/col for centered floating window

### Tertiary (LOW confidence)
- WebSearch results on startup cost comparison — not benchmarked; general community consensus that keys-trigger = zero startup cost

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — all three plugins verified via official GitHub README + actively maintained repos
- Architecture: HIGH — patterns sourced from official docs and LazyVim reference implementation
- Pitfalls: HIGH (neo-tree bug) / MEDIUM (others) — neo-tree bug confirmed via GitHub issue; other pitfalls from docs + community

**Research date:** 2026-02-26
**Valid until:** 2026-05-26 (stable plugins; 90 days reasonable)
