# Phase 1: Foundation - Context

**Gathered:** 2026-02-26
**Status:** Ready for planning

<domain>
## Phase Boundary

Restructure the monolithic init.lua into a modular lua/ directory structure, replace the hand-rolled colorscheme with modus-themes.nvim, install treesitter with parsers for all target languages, verify Nix PATH resolves LSP servers from inside Neovim, and confirm sub-100ms cold start. No LSP configuration, no completion, no plugins beyond colorscheme and treesitter.

</domain>

<decisions>
## Implementation Decisions

### Config structure
- Modular `lua/plugins/` directory with lazy.nvim auto-scanning via `require("lazy").setup("plugins")`
- Core config in `lua/config/`: `options.lua`, `keymaps.lua`, `autocmds.lua`
- `init.lua` becomes a thin bootstrap: load config modules, bootstrap lazy.nvim, call lazy setup
- One plugin spec file per concern (e.g., `lua/plugins/colorscheme.lua`, `lua/plugins/treesitter.lua`)
- Lockfile stays at `vim.fn.stdpath("data")` to avoid read-only Nix store issues

### Colorscheme
- Use `miikanissi/modus-themes.nvim` with `modus_vivendi_tinted` variant
- Remove the entire hand-rolled colorscheme block from current init.lua
- Eager-load (no lazy trigger) — colorscheme must be first visual thing applied
- Accept default highlight groups — modus-themes provides full treesitter + LSP coverage
- If `modus_vivendi_tinted` background doesn't match the current `#1d2235`, use the plugin's override mechanism to set it

### Keybind philosophy
- Keep space as leader, preserve existing muscle memory binds (`<leader>w`, `<leader>q`, `<leader>h`)
- Keep window navigation (`C-hjkl`) and visual indenting (`</>gv`)
- Remove fzf.vim, telescope, commander, and plenary — they'll be replaced by fzf-lua in Phase 3
- The `-` binding for netrw/Ex stays temporarily until neo-tree replaces it in Phase 3
- Group future keybinds by prefix: `<leader>f` = find, `<leader>g` = git, `<leader>l` = LSP

### Treesitter scope
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

</decisions>

<specifics>
## Specific Ideas

- The existing modus vivendi tinted colors use bg `#1d2235` — check if the plugin's tinted variant matches or needs an override
- Keep the config feeling minimal — no unnecessary abstractions or helper functions
- The Nix PATH verification (exepath check for gopls, pyright, etc.) should be a concrete diagnostic, not just an assumption
- Primeagen / minimal-style philosophy: Neovim is NOT an IDE replacement. It should be fast and lightweight by default, but capable when you reach for features. Extras load on demand, core stays lean.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 01-foundation*
*Context gathered: 2026-02-26*
