# Feature Research

**Domain:** Minimal Neovim IDE configuration for professional development
**Researched:** 2026-02-26
**Confidence:** HIGH (LSP/treesitter/git); MEDIUM (colorscheme, file tree options)

## Existing Foundation

The following features are already built and must be preserved:

- Space leader key, window navigation keymaps, visual indent keymaps
- fzf.vim for file (`<leader>ff`), text (`<leader>fg`), buffer (`<leader>fb`), history (`<leader>fh`) finding
- commander.nvim (via telescope) for command palette (`<leader><space>`)
- Hand-rolled modus vivendi tinted colorscheme (inline in init.lua)
- lazy.nvim plugin management with lazy-loading patterns established

---

## Feature Landscape

### Table Stakes (Users Expect These)

Features a developer expects from any serious editor configuration. Missing these makes Neovim feel like a toy.

| Feature | Why Expected | Complexity | Notes |
|---------|--------------|------------|-------|
| LSP go-to-definition (`gd`) | Every modern editor has jump-to-definition | LOW | Neovim 0.11 built-in; maps to `vim.lsp.buf.definition()` |
| LSP hover docs (`K`) | Documentation on demand is muscle memory | LOW | `vim.lsp.buf.hover()` — Neovim 0.11 adds treesitter-highlighted hover |
| LSP diagnostics in sign column | Errors/warnings visible at a glance | LOW | `signcolumn = "yes"` already set; just needs LSP attached |
| LSP diagnostic navigation (`[d` / `]d`) | Navigate errors without leaving keyboard | LOW | Neovim 0.11 sets these defaults automatically |
| LSP rename (`grn`) | Refactoring without find-replace | LOW | Neovim 0.11 default binding |
| LSP code actions (`gra`) | Fix imports, extract functions, etc. | LOW | Neovim 0.11 default binding |
| LSP references (`grr`) | Find all usages of a symbol | LOW | Neovim 0.11 default binding |
| Syntax highlighting beyond regex | Language-aware color, not dumb patterns | MEDIUM | Requires nvim-treesitter with parsers for each language |
| Autocompletion from LSP | Typing without memorizing every API | MEDIUM | Requires blink.cmp or nvim-cmp; blink.cmp preferred in 2025 |
| Completion triggered automatically | No manual `<C-x><C-o>` invocations | LOW | blink.cmp has auto-trigger built in |
| Tab to accept completion | Universal muscle memory from every editor | LOW | blink.cmp keymap preset configuration |
| Git change signs in gutter | Know what lines changed without leaving editor | LOW | gitsigns.nvim, minimal config, no dependencies |
| Hunk navigation (`]h` / `[h`) | Navigate changes within a file | LOW | gitsigns.nvim built-in |
| File tree toggle | Browse project structure when needed | MEDIUM | neo-tree.nvim; must be closed by default |

### Differentiators (This Project's Specific Value)

Features that distinguish this config from generic distributions (LazyVim, AstroNvim) and align with the project's "minimum viable set" philosophy.

| Feature | Value Proposition | Complexity | Notes |
|---------|-------------------|------------|-------|
| Nix-managed LSP servers, no Mason | Reproducible across machines; no runtime downloads; already solved | LOW | Point `cmd` to Nix-installed binaries; skip mason entirely |
| vim.lsp.enable() instead of lspconfig plugin | Removes one plugin dependency; native API is stable in 0.11 | LOW | Create `lsp/` dir with per-language configs; cleaner than plugin |
| Modus Vivendi colorscheme (matching terminal) | Visual consistency between terminal, Alacritty, and editor | MEDIUM | Switch from hand-rolled to miikanissi/modus-themes.nvim for treesitter/LSP highlight groups |
| Single init.lua (or thin module split) | Trivially auditable; every line earns its place | LOW | Keep complexity minimal; resist splitting into dozens of files |
| Space-leader command palette always discoverable | Spacemacs muscle memory; every binding documented in commander | LOW | Existing commander integration; expand to cover new LSP bindings |
| Inline git blame on current line | Blame without leaving the buffer | LOW | gitsigns `current_line_blame = true` option |
| Stage/unstage hunks from within editor | Git workflow without switching to terminal for small changes | LOW | gitsigns `:Gitsigns stage_hunk` / `:Gitsigns reset_hunk` |

### Anti-Features (Commonly Requested, Often Problematic)

Features that seem appealing but violate the "every plugin must justify itself" constraint or create more problems than they solve.

| Feature | Why Requested | Why Problematic | Alternative |
|---------|---------------|-----------------|-------------|
| Mason.nvim | Easy LSP server installation | Redundant when Nix manages servers; v2.0.0 broke mason-lspconfig in May 2025; adds eager startup overhead; downloads binaries outside Nix graph | Point `cmd` directly to Nix package paths; zero runtime download |
| nvim-lspconfig (as plugin) | Large community of default configs | Neovim 0.11 built-in `vim.lsp.config` / `vim.lsp.enable` does the same thing natively; the plugin is becoming a thin shim | Use native `vim.lsp.config` + `vim.lsp.enable` + `lsp/` directory |
| nvim-cmp | Most documented completion plugin | 5+ separate plugins required (nvim-cmp + sources + snippet engine + autopairs glue); blink.cmp ships lsp/buffer/path/snippets in one plugin | blink.cmp with built-in sources |
| Treesitter foldexpr | Code folding based on syntax | Known startup performance issue; slows initial open of large files | Use Neovim's built-in `foldmethod=indent` or skip folding |
| Treesitter textobjects plugin | `vaf` to select function, etc. | Disables lazy-loading for treesitter; adds startup cost; requires learning new motion system | Start without; add later only if missed in practice |
| Neogit or LazyGit integration | Full git TUI in the editor | Heavy; adds plenary dependency; overlaps with terminal workflow (Claude Code is already the external tool) | gitsigns.nvim for in-editor signs + blame; use terminal for commits |
| vim-fugitive | `:G` for git commands | Old vimscript; `<leader>fg` via fzf already covers text search; fugitive's main value is staging UI which gitsigns covers | gitsigns.nvim for hunks; use terminal for complex git operations |
| Custom statusline plugin (lualine, etc.) | Pretty status bars | Adds a plugin for aesthetic, not functionality; Neovim's built-in statusline is sufficient; PROJECT.md explicitly out-of-scope | `vim.opt.statusline` with minimal inline config if needed |
| Auto-install treesitter parsers on startup | "Just works" experience | Parsers download/compile at startup; breaks reproducibility; slow on first run | Pre-specify parsers in config; accept that first-run requires `:TSUpdate` |
| Oil.nvim | Edit filesystem like a buffer | Philosophically interesting but adds learning curve; project already has fzf for file navigation and `-` for netrw | Use neo-tree toggle for browsing; fzf for finding |
| nvim-autopairs | Auto-close brackets | Adds complexity for moderate value; fights with completion confirm key bindings; needs glue code | Configure blink.cmp's enter behavior; Neovim's `smartindent` handles most cases |
| Which-key.nvim | Show available keybindings | commander already shows all registered keybindings; which-key adds another floating UI | Use commander (`<leader><space>`) as the discovery mechanism |
| DAP/debugger | Breakpoints in editor | Explicitly out-of-scope in PROJECT.md; significant complexity | Use external debuggers and terminal |
| Snippet engine (LuaSnip, etc.) | Code template expansion | blink.cmp includes snippet support via built-in provider; separate engine only needed for custom snippet libraries | Use blink.cmp's built-in snippets source if needed |

---

## Feature Dependencies

```
nvim-treesitter (parsers)
    └──enables──> Treesitter syntax highlighting
    └──enables──> Treesitter-aware indent
    └──enables──> modus-themes.nvim treesitter highlight groups

vim.lsp.config + vim.lsp.enable (native, no plugin)
    └──requires──> LSP server binaries (Nix packages: gopls, pyright, etc.)
    └──enables──> blink.cmp LSP source (via get_lsp_capabilities())
    └──enables──> Diagnostics in sign column
    └──enables──> Hover, go-to-definition, code actions

blink.cmp
    └──requires──> LSP attached (for lsp source)
    └──enhances──> LSP (communicates expanded capabilities via get_lsp_capabilities())

modus-themes.nvim
    └──enhances──> nvim-treesitter (treesitter highlight groups)
    └──enhances──> vim.lsp (LSP semantic token highlight groups)
    └──replaces──> hand-rolled colorscheme in init.lua

neo-tree.nvim
    └──requires──> nvim-web-devicons (optional, for icons)
    └──conflicts with──> netrw (disable netrw or use neo-tree's hijack)

gitsigns.nvim
    └──requires──> git repo (gracefully no-ops outside repos)
    └──independent of──> all other plugins above

commander.nvim (existing)
    └──should register──> LSP keybindings for discoverability
    └──should register──> neo-tree toggle
    └──should register──> gitsigns hunk operations
```

### Dependency Notes

- **vim.lsp requires Nix LSP binaries:** The `cmd` field in each `lsp/*.lua` file must point to the Nix-installed binary path. These are already in PATH via Nix: `gopls`, `pyright`, `typescript-language-server`, `nil` (Nix LSP), `rust-analyzer`, `clangd`.
- **blink.cmp enhances LSP:** Call `require('blink.cmp').get_lsp_capabilities()` and pass result as `capabilities` when enabling each LSP server. This ensures LSP knows about completion features.
- **modus-themes.nvim replaces hand-rolled colorscheme:** The existing inline `hi clear` + `nvim_set_hl` blocks should be replaced. The plugin's `modus_vivendi_tinted` variant matches the existing color philosophy.
- **neo-tree conflicts with netrw:** Set `vim.g.loaded_netrw = 1` and `vim.g.loaded_netrwPlugin = 1` before neo-tree loads. The existing `"-"` netrw binding should be reassigned to neo-tree toggle.

---

## MVP Definition

### Launch With (v1 — this milestone)

- [ ] **LSP via native vim.lsp** — Go-to-definition, hover, diagnostics, code actions, rename, references for: Go, Python, TypeScript/JavaScript, Nix, Rust, C/C++
- [ ] **blink.cmp** — LSP + buffer + path completion with tab-to-accept; replaces Neovim's default `<C-x><C-o>`
- [ ] **nvim-treesitter** — Syntax highlighting for all target languages; explicit parser list, no auto-install
- [ ] **gitsigns.nvim** — Gutter signs for added/changed/removed lines; hunk navigation; inline blame
- [ ] **neo-tree.nvim** — Toggleable sidebar (`<leader>e` or similar), closed by default, follows current file
- [ ] **modus-themes.nvim** — Replace hand-rolled colorscheme; use `modus_vivendi_tinted` variant for LSP/treesitter highlight group support
- [ ] **commander registration** — All new LSP bindings, neo-tree toggle, and gitsigns operations registered in commander for discoverability

### Add After Validation (v1.x)

- [ ] **Hunk staging from editor** — gitsigns stage/reset hunk keybindings if found useful in practice (already available, just needs keymaps)
- [ ] **Treesitter textobjects** — Only if `va`/`vi` motions feel missing; adds plugin dependency so defer until pain is real
- [ ] **Additional LSP capabilities** — Formatting via LSP or conform.nvim if auto-format-on-save is desired

### Future Consideration (v2+)

- [ ] **Conform.nvim for formatting** — Many formatters aren't LSP-based (prettier, black, gofmt); add if LSP formatting proves insufficient
- [ ] **Custom snippet library** — blink.cmp handles built-in snippets; only add if custom project templates needed
- [ ] **Diffview.nvim** — Full diff UI for reviewing changes; only if git workflow demands more than gitsigns provides

---

## Feature Prioritization Matrix

| Feature | User Value | Implementation Cost | Priority |
|---------|------------|---------------------|----------|
| LSP (all 6 languages) | HIGH | LOW (Nix handles binaries, native API) | P1 |
| blink.cmp completion | HIGH | LOW (single plugin, built-in sources) | P1 |
| nvim-treesitter highlighting | HIGH | LOW (explicit parser list, lazy build) | P1 |
| gitsigns.nvim | HIGH | LOW (zero dependencies, just works) | P1 |
| neo-tree (toggleable) | MEDIUM | MEDIUM (netrw conflict, icon setup) | P1 |
| modus-themes.nvim | MEDIUM | LOW (replaces existing hand-rolled code) | P1 |
| Commander registration for new bindings | MEDIUM | LOW (already have commander) | P1 |
| Hunk staging keymaps | MEDIUM | LOW | P2 |
| Treesitter textobjects | LOW | MEDIUM (no lazy-loading allowed) | P3 |
| Conform.nvim | MEDIUM | LOW | P2 |

**Priority key:**
- P1: Must have for milestone launch
- P2: Should have, add when core is working
- P3: Nice to have, defer

---

## Expected UX Behaviors by Category

### LSP

- `gd` — Go to definition (jumps to declaration in same or new buffer)
- `K` — Hover documentation (floating window with type info and docs)
- `[d` / `]d` — Previous/next diagnostic
- `grn` — Rename symbol under cursor
- `grr` — Show all references (opens location list or quickfix)
- `gri` — Go to implementation
- `gra` — Code action menu (floating list of fixes/refactors)
- `gO` — Document symbols (outline of current file)
- Diagnostics appear in sign column inline with line numbers; virtual text optional
- Hover window has rounded border (consistent with existing lazy.nvim UI config)
- LSP attaches automatically on file open — no manual invocation

### Completion (blink.cmp)

- Completion menu appears automatically after ~1-2 characters of typing
- `<Tab>` — Accept selected completion or select next item
- `<S-Tab>` — Select previous item
- `<CR>` — Confirm selected item (or do nothing if menu closed)
- `<C-e>` — Dismiss completion menu
- Sources: LSP (highest priority), buffer words, file paths
- Ghost text optional but desirable — shows completion inline without blocking
- Signature help shows function parameter hints when inside a function call

### Treesitter

- Syntax highlighting enabled for: go, python, typescript, javascript, tsx, nix, rust, c, lua, bash, json, yaml, toml, markdown
- Treesitter-based indentation enabled (more accurate than regex indent)
- Parsers explicitly listed — no auto-install; build happens via lazy.nvim's `build = ":TSUpdate"`
- Does NOT use treesitter for folding (known performance issue)
- Does NOT install textobjects plugin for v1

### Git Signs (gitsigns.nvim)

- Added lines: green `+` in sign column
- Modified lines: orange `~` in sign column
- Deleted lines: red `_` at boundary in sign column
- Staged hunks shown with separate highlight
- `]h` / `[h` — Navigate between hunks
- Current line blame shown as virtual text at end of line (subtle, muted color)
- `<leader>hp` — Preview hunk in floating window
- `<leader>hs` — Stage hunk
- `<leader>hr` — Reset hunk
- All above registered in commander

### File Tree (neo-tree.nvim)

- Closed by default — does NOT open on startup
- Toggle with `<leader>e` (or configured key)
- Sidebar width: 30 columns
- Closes when it becomes the last window (`close_if_last_window = true`)
- Follows current file when opened (`reveal` behavior)
- Shows hidden files toggled with `.` or `H`
- `<CR>` or `l` — Open file/expand node
- `h` — Collapse node
- `a` — Create new file/directory
- `d` — Delete
- `r` — Rename
- `<leader>e` registered in commander
- Icons: nvim-web-devicons if available, graceful fallback without

### Colorscheme (modus-themes.nvim)

- Use `modus_vivendi_tinted` variant — matches existing `bg = "#1d2235"` color philosophy
- Replace existing hand-rolled highlight groups in init.lua
- Must define highlight groups for: LSP diagnostics, semantic tokens, treesitter captures, gitsigns signs, neo-tree UI
- Background: dark, consistent with Alacritty terminal theme

---

## Reference Configurations Analyzed

- [Minimal Neovim config v0.12 — vieitesss](https://vieitesss.github.io/posts/Neovim-new-config/) — demonstrates vim.lsp.enable, blink.cmp without nvim-lspconfig plugin
- [Neovim config for 2025 — Chris Arderne](https://rdrn.me/neovim-2025/) — recommends blink.cmp over nvim-cmp, nvim-tree for file browser
- [My Minimal Neovim Configuration (6 plugins) — Damascenov](https://vdamasceno.eu/blog/2025/02/my_neovim_conf) — demonstrates mini.nvim consolidation approach
- [What's New in Neovim 0.11 — g.p. anders](https://gpanders.com/blog/whats-new-in-neovim-0-11/) — authoritative source for native LSP API changes
- [Switching from lspconfig to vim.lsp.config — xnacly](https://xnacly.me/posts/2025/neovim-lsp-changes/) — practical migration guide, confirms native approach better for Nix users
- [blink.cmp GitHub](https://github.com/saghen/blink.cmp) — official docs for capabilities API and source configuration
- [gitsigns.nvim GitHub](https://github.com/lewis6991/gitsigns.nvim) — feature list and setup API
- [modus-themes.nvim GitHub](https://github.com/miikanissi/modus-themes.nvim) — v1.4.2 (Oct 2025), active maintenance, treesitter + LSP semantic token support confirmed
- [Debloating Neovim — rootknecht.net](https://rootknecht.net/blog/debloating-neovim-config/) — anti-patterns and startup time optimization
- [Mason.nvim v2.0.0 break issue](https://github.com/mason-org/mason-lspconfig.nvim/issues/544) — confirms mason is unstable and redundant for Nix users

---

*Feature research for: Minimal Neovim IDE configuration*
*Researched: 2026-02-26*
