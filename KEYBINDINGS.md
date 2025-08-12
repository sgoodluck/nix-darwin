# Keybinding Reference Guide

A comprehensive guide to keyboard shortcuts across all applications in this Nix configuration.

## Table of Contents
- [Key Legend](#key-legend)
- [Aerospace (Window Manager)](#aerospace-window-manager)
- [Karabiner & Hyper Key](#karabiner--hyper-key)
- [Zen Browser](#zen-browser)
- [Alacritty (Terminal)](#alacritty-terminal)
- [Zellij (Terminal Multiplexer)](#zellij-terminal-multiplexer)
- [Doom Emacs](#doom-emacs)
- [macOS System](#macos-system)

## Key Legend

| Symbol | Key |
|--------|-----|
| ⌘ | Command |
| ⌥ | Option/Alt |
| ⌃ | Control |
| ⇧ | Shift |
| ⎵ | Space |
| ⇥ | Tab |
| ⏎ | Enter/Return |
| ⌫ | Backspace |
| ⌦ | Delete |
| **Hyper** | ⌃⌥⇧⌘ (Right Option remapped) |

---

## Aerospace (Window Manager)

**When to use**: Managing windows and workspaces across your desktop. Primary interface for organizing your workflow.

### Workspace Management (Hyper Key)
| Shortcut | Action | When to use |
|----------|--------|-------------|
| **Hyper + 1-5** | Switch to workspace 1-5 | Navigate between different project contexts |
| **Hyper + ⇧ + 1-5** | Move window to workspace 1-5 | Organize windows into appropriate workspaces |
| **Hyper + ⇥** | Switch to previous workspace | Quick toggle between two active workspaces |

### Window Navigation (Left Option)
| Shortcut | Action | When to use |
|----------|--------|-------------|
| **⌥ + H/J/K/L** | Focus left/down/up/right | Navigate between windows in current workspace |
| **⌥ + ⇧ + H/J/K/L** | Move window left/down/up/right | Rearrange window layout |
| **⌥ + ⏎** | Open new Alacritty terminal | Quick terminal access |

### Layout Management
| Shortcut | Action | When to use |
|----------|--------|-------------|
| **⌥ + /** | Toggle between horizontal/vertical tiles | Adjust layout orientation |
| **⌥ + ,** | Switch to accordion layout | Maximize one window, minimize others |
| **⌥ + ⇧ + -** | Decrease window size | Fine-tune window proportions |
| **⌥ + ⇧ + =** | Increase window size | Fine-tune window proportions |

### Service Mode
| Shortcut | Action | When to use |
|----------|--------|-------------|
| **⌥ + ⇧ + ;** | Enter service mode | Access advanced window operations |
| **⎋** (in service) | Exit service mode | Return to normal mode |
| **R** (in service) | Reset/flatten layout | Fix complex nested layouts |
| **F** (in service) | Toggle floating/tiling | Temporarily float a window |

---

## Karabiner & Hyper Key

**When to use**: System-level shortcuts and power user operations that don't conflict with applications.

### System Control
| Shortcut | Action | When to use |
|----------|--------|-------------|
| **⌘ + ⎋** | Lock screen | Quick privacy protection |
| **Hyper + L** | Logout | End user session |
| **Hyper + P** | Power down | Shutdown system |
| **Hyper + B** | Reboot | Restart system |
| **Hyper + S** | Sleep | Put system to sleep |

### Application Launchers
| Shortcut | Action | When to use |
|----------|--------|-------------|
| **⌘ + ⇧ + ⏎** | Launch Firefox | Quick browser access |
| **⌘ + ⌃ + ⏎** | Launch VS Code | Quick editor access |
| **Hyper + N** | Open Finder in current directory | File management |

### Utilities
| Shortcut | Action | When to use |
|----------|--------|-------------|
| **Hyper + C** | Open System Settings | Quick access to preferences |
| **Hyper + Y** | Restart Aerospace | Fix window manager issues |

---

## Zen Browser

**When to use**: Web browsing, research, documentation reading. Optimized for productivity and minimal distraction.

### Tab Management
| Shortcut | Action | When to use |
|----------|--------|-------------|
| **⌥ + 1-9** | Switch to tab 1-9 | Quick tab navigation |
| **⌃ + ⇥** | Next tab | Sequential tab browsing |
| **⌃ + ⇧ + ⇥** | Previous tab | Sequential tab browsing |

### Workspace Navigation
| Shortcut | Action | When to use |
|----------|--------|-------------|
| **⌥ + ⌃ + E** | Switch to next workspace | Organize different browsing contexts |

### View Modes
| Shortcut | Action | When to use |
|----------|--------|-------------|
| **⌘ + ⌥ + C** | Toggle Compact Mode | Maximize content area |
| **⌥ + B** | Toggle small sidebar | Show only favicons |

### Search & Navigation
| Shortcut | Action | When to use |
|----------|--------|-------------|
| **⌘ + L** | Focus address bar | Navigate to new URL |
| **⌘ + F** | Find on page | Locate content |

---

## Alacritty (Terminal)

**When to use**: Command-line operations, development tasks, system administration.

### Vi Mode Navigation
| Shortcut | Action | When to use |
|----------|--------|-------------|
| **⌃ + ⇧ + ⎵** | Enter Vi mode | Navigate terminal history |
| **V** (in Vi mode) | Start selection | Copy terminal output |
| **Y** (in Vi mode) | Copy selection | Save text to clipboard |
| **⌥ + V** (in Vi mode) | Semantic selection | Select words/paths |
| **⇧ + V** (in Vi mode) | Line selection | Select entire lines |

### Search
| Shortcut | Action | When to use |
|----------|--------|-------------|
| **⌘ + F** | Search forward | Find text in terminal |
| **⌘ + B** | Search backward | Find previous matches |

### System Integration
| Shortcut | Action | When to use |
|----------|--------|-------------|
| **⌥ + D** | Delete word forward | Fast text editing |
| **⌘ + C** | Copy | Standard copy operation |
| **⌘ + V** | Paste | Standard paste operation |

---

## Zellij (Terminal Multiplexer)

**When to use**: Managing multiple terminal sessions, persistent sessions, collaborative work.

### Mode Management
| Shortcut | Action | When to use |
|----------|--------|-------------|
| **⌃ + G** | Toggle Lock/Normal mode | Avoid conflicts with terminal apps |
| **⌃ + P** | Enter Pane mode | Manage terminal panes |
| **⌃ + O** | Enter Session mode | Session and configuration management |
| **⌃ + R** | Enter Resize mode | Adjust pane sizes |

### Pane Operations (after ⌃ + P)
| Shortcut | Action | When to use |
|----------|--------|-------------|
| **N** | New pane | Add terminal session |
| **X** | Close current pane | Remove unnecessary sessions |
| **H/J/K/L** | Focus pane | Navigate between terminals |

### Tab Management (after ⌃ + T)
| Shortcut | Action | When to use |
|----------|--------|-------------|
| **N** | New tab | Organize different projects |
| **X** | Close tab | Clean up workspace |
| **S** | Toggle sync mode | Send commands to all panes |

---

## Doom Emacs

**When to use**: Text editing, programming, note-taking, org-mode tasks, extensive document work.

### Leader Key Commands (⎵)
| Shortcut | Action | When to use |
|----------|--------|-------------|
| **⎵ ⇥** | Switch to last buffer | Toggle between two files |
| **⎵ O T** | Open terminal | Access shell from editor |
| **⎵ O N** | Open file tree | Navigate project structure |
| **⎵ H K** + key | Show key documentation | Learn keybindings |
| **⎵ H B B** | Search keybinds | Find available shortcuts |

### Alternative Access (when ⎵ unavailable)
| Shortcut | Action | When to use |
|----------|--------|-------------|
| **⌥ + ⎵** | Alternative leader | Non-evil or insert states |
| **⌥ + ⎵ + M** | Local leader | Mode-specific commands |

### System Integration
| Shortcut | Action | When to use |
|----------|--------|-------------|
| **⌘ + [various]** | macOS integration | File operations, system shortcuts |
| **⌥ + X** | Execute command | Run specific Emacs functions |

### Custom Shortcuts
| Shortcut | Action | When to use |
|----------|--------|-------------|
| **⌘ + ⇧ + T** | Toggle theme | Switch between light/dark |

---

## macOS System

**When to use**: System-level operations, application switching, universal shortcuts across all apps.

### Application Management
| Shortcut | Action | When to use |
|----------|--------|-------------|
| **⌘ + ⇥** | Application switcher | Switch between apps |
| **⌘ + ⎵** | Spotlight search | Find files, apps, information |
| **⌘ + W** | Close window | Close current window |
| **⌘ + Q** | Quit application | Exit current application |

### Mission Control & Spaces
| Shortcut | Action | When to use |
|----------|--------|-------------|
| **F3** | Mission Control | Overview all windows/spaces |
| **⌃ + ←/→** | Switch between Spaces | Navigate macOS virtual desktops |
| **⌃ + ↑** | Mission Control | Alternative access |

### Universal Text Operations
| Shortcut | Action | When to use |
|----------|--------|-------------|
| **⌘ + A** | Select all | Select all content |
| **⌘ + C/V/X** | Copy/Paste/Cut | Standard clipboard operations |
| **⌘ + Z** | Undo | Reverse last action |
| **⌘ + ⇧ + Z** | Redo | Restore undone action |

### File Operations
| Shortcut | Action | When to use |
|----------|--------|-------------|
| **⌘ + O** | Open | Open files/folders |
| **⌘ + S** | Save | Save current document |
| **⌘ + N** | New | Create new document/window |

---

## Workflow Tips

### Workspace Organization
1. **Workspace 1**: Terminal (Alacritty) - Development and system tasks
2. **Workspace 2**: Browsers (Zen) - Research and documentation  
3. **Workspace 3**: Editors (Emacs, VS Code) - Code and text editing
4. **Workspace 4**: Communication (Slack, Mail) - Messages and email
5. **Workspace 5**: Utilities - File managers, system tools

### Common Workflows
- **Development**: Hyper+1 (terminal) → Hyper+3 (editor) → Hyper+2 (docs)
- **Research**: Hyper+2 (browser) → ⌥+H/L (navigate windows) → Hyper+3 (notes)
- **Communication**: Hyper+4 (chat) → Hyper+Tab (previous workspace)
- **System Admin**: Hyper+1 (terminal) → ⌃+P N (new pane) → ⌃+G (lock for tools)

### Conflict Resolution
- **Zellij conflicts**: Use ⌃+G to lock interface when using terminal apps
- **Browser tab switching**: Use ⌥+1-9 (doesn't conflict with Aerospace)
- **Emacs in terminal**: Uses ⌥+⎵ as alternative leader when needed