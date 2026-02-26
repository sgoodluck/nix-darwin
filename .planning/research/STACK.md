# Stack Research

**Domain:** Minimal Neovim development environment (Nix-managed)
**Researched:** 2026-02-26
**Confidence:** HIGH (core recommendations), MEDIUM (startup time figures)

## Recommended Stack

The goal: 8-10 total plugins, sub-100ms cold start, full IDE capability. Every plugin below replaces at least one currently installed plugin or fills a gap that nothing else covers.

### Core Technologies

| Technology | Version | Purpose | Why Recommended |
|------------|---------|---------|-----------------|
| lazy.nvim | stable | Plugin manager + lazy loading | Already bootstrapped. Bytecode compilation of Lua modules. Lazy-loading by event/keymap/cmd/filetype reduces startup to nearly zero for unused plugins. |
| nvim-lspconfig | latest | LSP server configurations | Neovim 0.11 added native `vim.lsp.config()` and `vim.lsp.enable()` APIs making plugins optional, but nvim-lspconfig still provides pre-built configs for all servers (gopls, pyright, ts_ls, lua_ls, ccls, nil_ls). Without it, you hand-write root_markers and filetypes for every server. DO NOT install mason — servers are Nix-managed. |
| blink.cmp | 0.x (stable) | Completion engine | Replaces nvim-cmp. Rust-based fuzzy matcher (frizbee) is ~6x faster than fzf. Ships LSP, buffer, path, cmdline, and snippet sources built-in — no extra plugins needed. Updates on every keystroke at 0.5-4ms async. Ships as the new default in kickstart.nvim (2025). nvim-cmp requires 4-6 additional source plugins; blink.cmp needs zero. |
| nvim-treesitter | latest | Syntax highlighting + code navigation | The 2025 standard. Native Neovim treesitter is available but requires manual grammar management. nvim-treesitter handles grammar installation and provides `highlight`, `indent`, and `incremental_selection` modules. Load on `BufReadPost` event to avoid startup impact. |
| fzf-lua | latest | Fuzzy finder + command palette + LSP picker | Replaces: fzf.vim, telescope.nvim, commander.nvim, plenary.nvim, telescope-fzf-native.nvim. fzf-lua has builtin pickers for: files, buffers, oldfiles, live_grep, git_status, git_commits, lsp_references, lsp_document_symbols, commands, keymaps, highlights. LazyVim v14 (2024) switched from telescope to fzf-lua as default. For large codebases, faster than telescope even with fzf-native extension. The `commands` and `keymaps` pickers cover the commander.nvim use case without a separate plugin. |
| gitsigns.nvim | latest | Git hunk signs + blame + staging | Lightweight, loads asynchronously. Provides: gutter signs (added/changed/removed), inline blame, hunk staging/resetting, hunk navigation. Fully sufficient without vim-fugitive for in-editor git workflow. Opens lazily when a git buffer is detected. |
| neo-tree.nvim | latest | Toggleable file tree sidebar | Supports sidebar, float, and split modes. Toggle with a keymap (closed by default). Lazy-loads on first toggle keypress. More actively maintained than nvim-tree in 2025. nvim-tree can be slow on large codebases (1-2 second delays reported). neo-tree handles the "closed by default, toggle to open" workflow natively. |
| miikanissi/modus-themes.nvim | latest | Colorscheme | WCAG AAA contrast, Neovim port of Emacs modus-themes (modus-vivendi, modus-operandi, modus-vivendi-tinted, modus-operandi-tinted). Directly matches user's existing hand-rolled Modus Vivendi Tinted colors. Full treesitter and LSP semantic token support. Replaces the hand-rolled colorscheme entirely with a maintained plugin. Last updated 2025-01-21. |

### Supporting Libraries

| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| nvim-web-devicons | latest | File icons | Required by neo-tree.nvim for icons in the file tree. Zero startup cost (lazy dep). |
| nui.nvim | latest | UI components | Required by neo-tree.nvim for UI rendering. Zero startup cost (lazy dep). |

**Note on plenary.nvim:** Currently installed as a telescope dependency. Removing telescope removes the need for plenary. fzf-lua has no dependency on plenary.

### Development Tools (Nix-Provided LSP Servers)

These are already in `modules/common/packages.nix` — no Mason needed:

| Tool | Language | Nix Package |
|------|----------|-------------|
| gopls | Go | `pkgs.gopls` |
| pyright or python-lsp-server | Python | `pkgs.python3.withPackages` (python-lsp-server included) |
| typescript-language-server | TypeScript/JS | `pkgs.nodePackages.typescript-language-server` |
| lua_ls | Lua | Add `pkgs.lua-language-server` to packages.nix |
| nil_ls or nixd | Nix | Add `pkgs.nil` or `pkgs.nixd` to packages.nix |
| ccls | C/C++ | `pkgs.ccls` |
| rust-analyzer | Rust | Add `pkgs.rust-analyzer` to packages.nix |

## Installation

No npm install — this is Nix + lazy.nvim. Lazy.nvim spec in init.lua:

```lua
require("lazy").setup({
  -- LSP
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function() ... end,
  },

  -- Completion (replaces nvim-cmp + all its sources)
  {
    "saghen/blink.cmp",
    event = "InsertEnter",
    version = "*",
    opts = { keymap = { preset = "default" } },
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "python", "go", "typescript", "nix", "rust", "c" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- Fuzzy finder (replaces fzf.vim + telescope + commander + plenary)
  {
    "ibhagwan/fzf-lua",
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Find text" },
      { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Find buffers" },
      { "<leader>fh", "<cmd>FzfLua oldfiles<cr>", desc = "Recent files" },
      { "<leader><space>", "<cmd>FzfLua commands<cr>", desc = "Command palette" },
      { "<leader>?", "<cmd>FzfLua keymaps<cr>", desc = "Show keymaps" },
    },
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
  },

  -- File tree (closed by default)
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "File tree" },
    },
    opts = { filesystem = { hijack_netrw_behavior = "disabled" } },
  },

  -- Colorscheme (replaces hand-rolled modus vivendi)
  {
    "miikanissi/modus-themes.nvim",
    priority = 1000,
    config = function()
      vim.cmd("colorscheme modus_vivendi_tinted")
    end,
  },
})
```

## Alternatives Considered

| Recommended | Alternative | When to Use Alternative |
|-------------|-------------|-------------------------|
| blink.cmp | nvim-cmp | Never for new configs. nvim-cmp requires 4-6 source plugins (nvim-cmp-lsp, nvim-cmp-buffer, nvim-cmp-path, nvim-cmp-snippets, cmp-cmdline). blink.cmp includes all of these. Only use nvim-cmp if blink.cmp has a breaking bug affecting your specific workflow. |
| fzf-lua | telescope.nvim | Use telescope only if you need a specific telescope extension with no fzf-lua equivalent. Note: this would require keeping plenary.nvim as a dep. |
| fzf-lua | fzf.vim (current) | Never. fzf.vim is Vimscript, fzf-lua is pure Lua with async. fzf-lua covers every fzf.vim feature plus LSP pickers. |
| fzf-lua (commands picker) | commander.nvim | Never. commander.nvim requires telescope as a hard dependency. fzf-lua's `commands` and `keymaps` pickers cover the same use case without telescope. |
| neo-tree.nvim | nvim-tree.lua | Use nvim-tree only if you hit neo-tree performance issues on huge repos. nvim-tree is simpler, fewer deps. |
| neo-tree.nvim | oil.nvim | Use oil.nvim if you prefer editing the filesystem as a buffer (vim-vinegar style) over a sidebar tree. oil.nvim is excellent but the UX model is different — it replaces the sidebar paradigm entirely. |
| neo-tree.nvim | netrw (builtin) | Use netrw for pure minimalism with zero plugin overhead. Already accessible via `-`. Lacks icons, git status, and toggle behavior. |
| modus-themes.nvim | hand-rolled colorscheme | Hand-rolled colorscheme is reasonable for total control but misses LSP semantic token highlights and treesitter-specific highlight groups. modus-themes.nvim handles all of these properly. |
| modus-themes.nvim | tokyonight.nvim | Use tokyonight if you prefer warmer blues. Both have full treesitter + LSP semantic token support. tokyonight also generates Alacritty terminal themes for consistency. |
| nvim-lspconfig | Native vim.lsp.config() (Neovim 0.11) | Use native APIs only if you want zero plugins for LSP config. You would need to manually write root_markers, filetypes, and cmd for each server. nvim-lspconfig has all of this pre-written. For a Nix config with 6+ language servers, nvim-lspconfig saves significant boilerplate. |
| gitsigns.nvim | vim-fugitive | Use fugitive if you want a full git TUI inside Neovim (staging, rebasing, branch management). gitsigns.nvim provides hunk-level operations and inline blame which covers 90% of in-editor git needs. lazygit (already installed as a system package) covers the remaining 10%. |
| gitsigns.nvim | neogit + diffview | Use this combo if you want a Magit-like experience in Neovim. Adds 2 plugins and is unnecessary when lazygit is already available externally. |

## What NOT to Use

| Avoid | Why | Use Instead |
|-------|-----|-------------|
| mason.nvim + mason-lspconfig | Installs LSP binaries into `~/.local/share/nvim/mason/` — directly conflicts with Nix-managed servers. Mason 2.0 (May 2025) had breaking changes. Fundamentally wrong tool for a Nix config. | Nix packages in `modules/common/packages.nix` |
| nvim-cmp | Requires 4-6 additional source plugins to match blink.cmp's out-of-the-box capability. Higher startup time, more config surface area. | blink.cmp |
| telescope.nvim (as primary finder) | Slower than fzf-lua on large codebases. Requires plenary.nvim as a heavy dep. LazyVim dropped it as default. | fzf-lua |
| commander.nvim | Hard dependency on telescope. Redundant when fzf-lua `commands` picker is available. Adds a plugin for functionality already covered. | fzf-lua `commands` / `keymaps` pickers |
| which-key.nvim | Adds ~15ms to startup even with lazy loading. For a Space-leader workflow, fzf-lua's keymaps picker (`<leader>?`) provides key discovery on demand without always-on popup overhead. | fzf-lua keymaps picker |
| lualine.nvim or similar statusline | Statusline plugins add startup cost and visual complexity. Neovim's built-in statusline is sufficient. If wanted later, mini.statusline is <1ms. | Neovim built-in statusline, or defer to later milestone |
| nvim-autopairs | Autopairing can be done with Neovim's built-in `vim.keymap` or a 5-line snippet. Adds a plugin for minimal benefit in a minimal config. | Manual mappings if needed |
| copilot, codeium, supermaven | Explicitly out of scope (PROJECT.md). Use Claude Code externally. | Claude Code (already installed) |

## Stack Patterns by Variant

**If you want zero sidebar (pure netrw workflow):**
- Drop neo-tree.nvim, nvim-web-devicons, nui.nvim
- Keep `-` mapped to `:Ex` (already in init.lua)
- Saves 3 plugins and their deps

**If you want vim-vinegar style file editing:**
- Replace neo-tree.nvim + deps with oil.nvim (single plugin, no deps)
- `require("oil").setup()` and map `<leader>e` to `:Oil<cr>`
- Saves 2 plugins total vs neo-tree approach

**If you want native LSP only (zero lspconfig):**
- Drop nvim-lspconfig
- Create `~/.config/nvim/after/lsp/gopls.lua` etc. for each server
- Use `vim.lsp.enable("gopls")` in init.lua
- Saves 1 plugin but adds ~20 lines of manual config per server

**Minimum absolute baseline (5 plugins):**
- nvim-lspconfig, blink.cmp, nvim-treesitter, fzf-lua, modus-themes.nvim
- Skip: neo-tree (use netrw), gitsigns (use lazygit externally)
- Estimated startup: 30-50ms

## Plugin Count Summary

| Category | Replacing | New Plugin Count |
|----------|-----------|-----------------|
| Fuzzy finder | fzf.vim + telescope + commander + plenary + fzf-native | 1 (fzf-lua) |
| Completion | nvim-cmp + 4 sources | 1 (blink.cmp) |
| LSP | nvim-lspconfig (keep) | 1 |
| Treesitter | (new) | 1 |
| Git | (new) | 1 (gitsigns) |
| File tree | netrw currently | 1 + 2 deps (neo-tree) |
| Colorscheme | hand-rolled (remove) | 1 (modus-themes) |
| **Total** | Was: 5 plugins + heavy deps | **7 plugins + 2 utility deps** |

## Version Compatibility

| Package | Compatible With | Notes |
|---------|-----------------|-------|
| blink.cmp `version = "*"` | Neovim 0.10+ | Requires stable release pin in lazy.nvim. Do not use `main` branch — it has breaking changes. |
| nvim-treesitter latest | Neovim 0.9+ | Grammar parsers compiled at `build = ":TSUpdate"` time. First install requires network access. |
| nvim-lspconfig latest | Neovim 0.11 native APIs | nvim-lspconfig 0.2.x+ is compatible with both old `lspconfig.server.setup{}` and new `vim.lsp.config` patterns. |
| neo-tree.nvim v3.x | Neovim 0.8+ | Requires `nui.nvim` and `nvim-web-devicons`. v3 is the current stable. |
| fzf-lua | Requires `fzf` binary on PATH | `fzf` is already in `modules/common/packages.nix` (`pkgs.fzf`). No additional install needed. |
| modus-themes.nvim latest | Neovim 0.8+ | `priority = 1000` required in lazy spec so colorscheme loads before other plugins. |

## Startup Time Impact

Estimates based on community benchmarks (MEDIUM confidence — no single authoritative source):

| Configuration | Estimated Cold Start |
|---------------|---------------------|
| Neovim bare (no config) | 10-20ms |
| Base init.lua + lazy.nvim bootstrap | 20-35ms |
| + colorscheme (priority load) | +2-5ms |
| + fzf-lua (key-lazy) | ~0ms added to startup |
| + blink.cmp (InsertEnter lazy) | ~0ms added to startup |
| + nvim-treesitter (BufReadPost lazy) | ~0ms added to startup |
| + nvim-lspconfig (BufReadPre lazy) | ~0ms added to startup |
| + gitsigns (BufReadPre lazy) | ~0ms added to startup |
| + neo-tree (key-lazy) | ~0ms added to startup |
| **Total estimated cold start** | **25-50ms** |

The key insight: with proper lazy loading, only the colorscheme loads at startup. Everything else defers to first use. The 100ms target is conservative for this plugin count.

## Sources

- [Neovim 0.11 LSP native APIs — Dave Lage](https://davelage.com/posts/neovim-lsp-0.11/) — Native LSP config without plugins verified
- [fzf-lua GitHub (ibhagwan/fzf-lua)](https://github.com/ibhagwan/fzf-lua) — Builtin pickers catalog confirmed
- [blink.cmp GitHub (saghen/blink.cmp)](https://github.com/saghen/blink.cmp) — Performance claims (0.5-4ms async) verified from README
- [LazyVim fzf-lua vs telescope discussion](https://github.com/LazyVim/LazyVim/discussions/3619) — Community performance comparison, LazyVim default switch
- [miikanissi/modus-themes.nvim](https://github.com/miikanissi/modus-themes.nvim) — Treesitter/LSP support, last updated 2025-01-21
- [dotfyle.com trending colorschemes 2025](https://dotfyle.com/neovim/colorscheme/trending) — Ecosystem popularity data
- [NixOS Discourse: LSP with Nix-managed binaries](https://discourse.nixos.org/t/i-need-help-setting-up-lsp-for-neovim-using-lspconfig-language-server-binaries/65455) — Nix+lspconfig integration confirmed
- [Neovim config for 2025 — Chris Arderne](https://rdrn.me/neovim-2025/) — Plugin selection rationale, blink.cmp recommendation
- [LazyVim 14 fzf-lua switch](https://www.lorenzobettini.it/2024/12/lazyvim-14-some-new-and-breaking-features/) — Confirmed telescope-to-fzf-lua migration

---
*Stack research for: Minimal Neovim development environment*
*Researched: 2026-02-26*
