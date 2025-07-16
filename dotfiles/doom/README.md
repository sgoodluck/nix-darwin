# Doom Emacs Configuration

A minimal, elegant Doom Emacs configuration featuring modus-vivendi-tinted theme, modern Org mode, and AI integration.

![Doom Emacs](https://raw.githubusercontent.com/doomemacs/doomemacs/screenshots/main.png)

## Features

- 🎨 **Modus Vivendi Tinted theme** with 95% opacity for a modern look
- 📝 **Modern Org mode** setup with streamlined capture templates
- 🤖 **AI Integration** with Claude via gptel
- 🐛 **DAP debugging** support for multiple languages
- 🖥️ **Eat terminal** emulator integration
- ✨ **Minimal UI** with undecorated frames and clean modeline

## Prerequisites

- Emacs 29.1 or higher
- Git
- [Doom Emacs](https://github.com/doomemacs/doomemacs)
- Required system dependencies:
  - `aspell` (spell checking)
  - `ripgrep` (for project search)
  - AnonymicePro Nerd Font

## Installation

### Quick Install

```bash
# Clone this configuration
git clone https://github.com/YOUR_USERNAME/doom-config ~/.config/doom

# Install Doom Emacs if you haven't already
git clone --depth 1 https://github.com/doomemacs/doomemacs ~/.config/emacs
~/.config/emacs/bin/doom install

# Sync Doom with this configuration
~/.config/emacs/bin/doom sync
```

### For Nix Users

If you're using this as part of a Nix configuration:

```bash
# After running nxr, initialize git repository
doom-git-init

# Add your remote
cd ~/.config/doom
git remote add origin https://github.com/YOUR_USERNAME/doom-config.git
git push -u origin main

# Use provided aliases
doom-status              # Check git status
doom-commit "message"    # Commit changes
doom-push               # Push to remote
```

### Manual Installation

1. Back up your existing Doom configuration:
   ```bash
   mv ~/.config/doom ~/.config/doom.backup
   ```

2. Clone this configuration:
   ```bash
   git clone https://github.com/YOUR_USERNAME/doom-config ~/.config/doom
   ```

3. Sync Doom:
   ```bash
   ~/.config/emacs/bin/doom sync
   ```

## Configuration Overview

### File Structure

```
~/.config/doom/
├── config.el    # Main configuration file
├── init.el      # Module declarations
├── packages.el  # Package management
└── README.md    # This file
```

### Key Bindings

| Keybinding | Description |
|------------|-------------|
| `SPC t t` | Toggle between dark/light theme |
| `SPC c c` | Start Claude Code |
| `SPC d d` | Start debugger |
| `SPC e e` | Open eat terminal |
| `SPC P b` | Publish blog post |

### Enabled Modules

**Completion**: corfu, vertico  
**UI**: doom, doom-dashboard, emoji, hl-todo, modeline, treemacs, zen  
**Editor**: evil, file-templates, fold, format, snippets  
**Tools**: eval, lookup, lsp, magit  
**Languages**: C/C++, Go, JavaScript, Python, Rust, Nix, Org, Markdown

## Customization

### Environment Variables

Set your Anthropic API key for AI features:
```bash
export ANTHROPIC_API_KEY="your-api-key-here"
```

Alternatively, add to `~/.authinfo.gpg`:
```
machine api.anthropic.com login claude password your-api-key-here
```

### Personal Settings

Update paths in `config.el`:
- `org-directory`: Your documents folder
- `my/hugo-base-dir`: Your Hugo blog directory

### Theme

The configuration uses modus-vivendi-tinted by default. Toggle between dark and light variants with `SPC t t`.

To change the default theme, modify in `config.el`:
```elisp
(setq doom-theme 'your-preferred-theme)
```

### Fonts

Default font is AnonymicePro Nerd Font size 12. To change:
```elisp
(setq doom-font (font-spec :family "Your Font" :size 14))
```

## Org Mode Setup

### Directory Structure

The configuration expects:
```
~/Documents/
└── Areas/           # Main org files location
    ├── Todo.org     # Tasks
    ├── Inbox.org    # Quick notes
    ├── Journal.org  # Daily journal
    └── Blog/        # Blog posts
        └── posts/
```

### Capture Templates

- `t t` - Personal todo
- `t n` - Personal note  
- `t j` - Journal entry
- `p t` - Project todo
- `p n` - Project note
- `p c` - Project changelog
- `b` - Blog post

## Troubleshooting

### Common Issues

1. **Fonts not displaying correctly**
   - Install AnonymicePro Nerd Font: `brew install --cask font-anonymice-nerd-font`

2. **Spell checker not working**
   - Install aspell: `brew install aspell`

3. **AI features not working**
   - Ensure `ANTHROPIC_API_KEY` is set in your environment

4. **Performance issues**
   - Run `~/.config/emacs/bin/doom doctor` to diagnose
   - Try `~/.config/emacs/bin/doom gc` to garbage collect

### Getting Help

- Doom Emacs Discord: https://discord.gg/qvGgnVx
- Doom Emacs Documentation: https://docs.doomemacs.org
- Issue Tracker: https://github.com/YOUR_USERNAME/doom-config/issues

## Contributing

Feel free to fork and customize! Pull requests are welcome for improvements that maintain the minimalist philosophy.

## License

This configuration is provided as-is for anyone to use and modify freely.