# Neovim Configuration

## What This Is

A blazingly fast, minimal Neovim configuration managed through the Nix dotfiles repository. Replaces the current bare-bones setup with a full development environment supporting all installed languages, while keeping the plugin count low and startup time fast.

## Core Value

Fast, capable editing across all development languages with the fewest plugins possible — every plugin must earn its place.

## Requirements

### Validated

<!-- Shipped and confirmed valuable. -->

(None yet — ship to validate)

### Active

<!-- Current scope. Building toward these. -->

- [ ] LSP support for all installed languages (Nix, Python, TS, Go, Rust, C/C++)
- [ ] Autocompletion with LSP integration
- [ ] Treesitter for syntax highlighting and code navigation
- [ ] Fast fuzzy finder (files, text, buffers)
- [ ] Git integration (signs, blame, status)
- [ ] Toggleable file tree sidebar (closed by default)
- [ ] Toggleable command palette (closed by default)
- [ ] Well-maintained colorscheme with LSP/treesitter support
- [ ] Fast startup time (< 100ms target)

### Out of Scope

<!-- Explicit boundaries. Includes reasoning to prevent re-adding. -->

- DAP/Debugger integration — use external tools, adds complexity
- Note-taking/org-mode plugins — use Emacs for that
- AI/copilot plugins — use Claude Code externally
- Custom statusline plugin — keep it simple or use a minimal one
- Session management — not needed for a fast editor workflow

## Context

- Neovim installed via Nix (`modules/common/packages.nix`)
- Config lives in `dotfiles/nvim/`, symlinked to `~/.config/nvim` via Home Manager
- Current setup: lazy.nvim bootstrapped, fzf.vim, telescope (for commander), hand-rolled modus vivendi colorscheme
- All LSP servers already available as Nix packages (gopls, pyright, typescript-language-server, etc.)
- User prefers Spacemacs-like leader key workflows (space as leader)
- File tree and command palette should be toggleable, closed most of the time

## Constraints

- **Plugin count**: Minimum viable set — every plugin must justify its inclusion
- **Startup time**: Must feel instant (< 100ms cold start target)
- **Package manager**: lazy.nvim (already bootstrapped)
- **Config structure**: Single `init.lua` or minimal file structure in `dotfiles/nvim/`
- **Nix integration**: LSP servers installed via Nix, not Mason

## Key Decisions

<!-- Decisions that constrain future work. Add throughout project lifecycle. -->

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| lazy.nvim for plugin management | Already bootstrapped, best lazy-loading support | — Pending |
| Nix-managed LSP servers | Reproducible, already in packages.nix | — Pending |
| Space as leader key | User preference, Spacemacs muscle memory | — Pending |

---
*Last updated: 2026-02-26 after milestone v1.0 initialization*
