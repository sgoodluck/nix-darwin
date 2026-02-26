# Phase 3: Editor Experience - Context

**Gathered:** 2026-02-26
**Status:** Ready for planning

<domain>
## Phase Boundary

Fuzzy finding (files, text, buffers), git gutter signs with hunk navigation, and a toggleable file tree. All lazy-loaded at zero startup cost. Replaces existing fzf.vim and telescope (commander) plugins.

</domain>

<decisions>
## Implementation Decisions

### Fuzzy finder (fzf-lua)
- fzf-lua for all finding — replaces fzf.vim and telescope
- Centered floating window with preview pane on the right
- File picker shows devicons and respects .gitignore
- `<leader>ff` files, `<leader>fg` live grep, `<leader>fb` buffers
- Live grep uses ripgrep (already on PATH)
- Remove fzf.vim and telescope after fzf-lua is working

### Command palette
- `<leader>fc` opens fzf-lua's builtin keymaps/commands picker
- Shows all available keymaps and commands in one searchable list
- No separate commander plugin needed — fzf-lua covers this

### Git gutter (gitsigns.nvim)
- Signs only: `+` added, `~` modified, `-` deleted in the gutter
- No inline blame by default (too noisy for fast editing)
- Hunk navigation: `]h` next hunk, `[h` previous hunk
- Stage/unstage hunks available under `<leader>g` prefix but not primary workflow
- Load on BufReadPre for git repos only

### File tree (neo-tree.nvim)
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

</decisions>

<specifics>
## Specific Ideas

- Primeagen-style: fast, keyboard-driven, minimal visual clutter
- All three plugins must lazy-load — zero startup cost contribution
- Existing telescope/fzf.vim/commander should be removed once fzf-lua is confirmed working
- `<leader>f` is the "find" prefix, `<leader>g` is the "git" prefix, `<leader>e` is tree toggle

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 03-editor-experience*
*Context gathered: 2026-02-26*
