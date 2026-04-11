# Home Manager configuration for user-level settings
# Manages dotfiles, shell configuration, and user programs
#
# Platform-aware: works on both macOS (nix-darwin) and NixOS
# macOS-specific items are gated behind `isDarwin` checks
{
  pkgs,
  lib,
  config,
  personal,
  ...
}:
let
  # Get the directory containing this file
  configDir = builtins.toString ./.;

  # Extract values from personal config for convenience
  machineName = personal.machineName;
  promptTheme = personal.preferences.promptTheme;
  username = personal.username;

  # Platform detection
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in
{
  # Home Manager state version - matches the 25.05 release
  home.stateVersion = "25.05";

  #
  # DOTFILE MANAGEMENT
  # Symlinks configuration files from dotfiles/ to user's home directory
  #

  home.file = {
    # Shell prompt theme configuration
    ".config/ohmyposh/${promptTheme}.toml".source = "${configDir}/dotfiles/zen.toml";

    # Status scripts for oh-my-posh prompt
    ".config/dotfiles/vpn-status.sh".source = "${configDir}/scripts/prompt/vpn-status.sh";
    ".config/dotfiles/venv-status.sh".source = "${configDir}/scripts/prompt/venv-status.sh";
    ".config/dotfiles/aws-profile-status.sh".source = "${configDir}/scripts/prompt/aws-profile-status.sh";
    ".config/dotfiles/kube-status.sh".source = "${configDir}/scripts/prompt/kube-status.sh";

    # Nvim config (cross-platform)
    ".config/nvim".source = "${configDir}/dotfiles/nvim";

    # Terminal multiplexer (cross-platform)
    ".config/zellij/config.kdl".text = ''
      // Zellij configuration
      // https://zellij.dev/documentation/configuration.html

      // Theme
      themes {
          modus-vivendi-tinted {
              bg "#1d2235"
              fg "#ffffff"
              black "#1d2235"
              red "#ff5f59"
              green "#00d3d0"
              yellow "#d0bc00"
              blue "#2fafff"
              magenta "#feacd0"
              cyan "#00d3d0"
              white "#989898"
              orange "#ef8b50"
              gray "#4f5666"
              silver "#a8a8a8"
              pink "#feacd0"
              brown "#b06240"
          }
      }

      theme "modus-vivendi-tinted"

      // Keybindings
      keybinds {
          normal {
              bind "Alt h" { MoveFocus "Left"; }
              bind "Alt l" { MoveFocus "Right"; }
              bind "Alt j" { MoveFocus "Down"; }
              bind "Alt k" { MoveFocus "Up"; }
              bind "Alt n" { NewPane; }
              bind "Alt x" { CloseFocus; }
              bind "Alt f" { ToggleFocusFullscreen; }
              bind "Alt s" { NewPane "Down"; }
              bind "Alt v" { NewPane "Right"; }
              bind "Alt t" { NewTab; }
              bind "Alt 1" { GoToTab 1; }
              bind "Alt 2" { GoToTab 2; }
              bind "Alt 3" { GoToTab 3; }
              bind "Alt 4" { GoToTab 4; }
              bind "Alt 5" { GoToTab 5; }
              bind "Alt 6" { GoToTab 6; }
              bind "Alt 7" { GoToTab 7; }
              bind "Alt 8" { GoToTab 8; }
              bind "Alt 9" { GoToTab 9; }
              bind "Ctrl o" { SwitchToMode "Session"; }
          }
      }

      // UI Configuration
      pane_frames true
      default_layout "compact"

      // Copy command (platform-specific)
      copy_command "${if isDarwin then "pbcopy" else "wl-copy"}"

      // Scrollback
      scroll_buffer_size 10000

      // Mouse mode
      mouse_mode true

      // Simplified UI
      simplified_ui false

      // Hide session name
      hide_session_name false
    '';
    ".config/zellij/layouts/minimal.kdl".source = "${configDir}/dotfiles/zellij/layouts/minimal.kdl";

    # Terminal emulator (cross-platform — Ghostty runs on Linux and macOS)
    ".config/ghostty/config".source = "${configDir}/dotfiles/ghostty/config";

    # System info (cross-platform)
    ".config/fastfetch/config.jsonc".source = "${configDir}/dotfiles/fastfetch/config.jsonc";

    # Git UI (cross-platform)
    ".config/lazygit/config.yml".source = "${configDir}/dotfiles/lazygit.yml";

    # File manager (cross-platform)
    ".config/yazi/keymap.toml".source = "${configDir}/dotfiles/yazi/keymap.toml";

    # Zed editor (cross-platform)
    ".config/zed/settings.json".source = "${configDir}/dotfiles/zed/settings.json";

    # Claude Code configuration and commands (cross-platform)
    ".claude/CLAUDE.md".source = "${configDir}/dotfiles/claude/CLAUDE.md";
    ".claude/commands/screenshot.md".source = "${configDir}/dotfiles/claude/commands/screenshot.md";
    ".claude/commands/pr-review.md".source = "${configDir}/dotfiles/claude/commands/pr-review.md";
    ".claude/commands/fdse/start.md".source = "${configDir}/dotfiles/claude/commands/fdse/start.md";
    ".claude/commands/fdse/stop.md".source = "${configDir}/dotfiles/claude/commands/fdse/stop.md";
    ".claude/commands/fdse/switch.md".source = "${configDir}/dotfiles/claude/commands/fdse/switch.md";
    ".claude/commands/fdse/status.md".source = "${configDir}/dotfiles/claude/commands/fdse/status.md";
    ".claude/commands/fdse/log.md".source = "${configDir}/dotfiles/claude/commands/fdse/log.md";
    ".claude/commands/fdse/report.md".source = "${configDir}/dotfiles/claude/commands/fdse/report.md";
    ".claude/commands/fdse/update-joby.md".source = "${configDir}/dotfiles/claude/commands/fdse/update-joby.md";
    ".claude/commands/fdse/create.md".source = "${configDir}/dotfiles/claude/commands/fdse/create.md";
    ".claude/statusline.sh" = {
      source = "${configDir}/dotfiles/claude/statusline.sh";
      executable = true;
    };

    # Claude helper scripts in PATH (cross-platform)
    ".local/bin/screenshot-capture".source = "${configDir}/scripts/claude/screenshot-capture.sh";
    ".local/bin/pr-review".source = "${configDir}/scripts/claude/pr-review.sh";

    # PostgreSQL client configs (cross-platform)
    ".psqlrc".source = "${configDir}/dotfiles/psqlrc";
    ".config/pgcli/config".source = "${configDir}/dotfiles/pgcli/config";

    # Kubernetes helper scripts (cross-platform)
    ".local/bin/k8s-db-password".source = "${configDir}/dotfiles/scripts/k8s-db-password";
  }
  # macOS-only dotfile symlinks
  // lib.optionalAttrs isDarwin {
    ".config/aerospace/aerospace.toml".source = "${configDir}/dotfiles/aerospace/aerospace.toml";
    ".config/karabiner/karabiner.json".source = "${configDir}/dotfiles/karabiner.json";
    ".config/amethyst/amethyst.yml".source = "${configDir}/dotfiles/amethyst.yml";
    # VS Code on macOS uses Application Support
    "Library/Application Support/Code/User/settings.json".source = "${configDir}/dotfiles/vscode/settings.json";
  }
  # Linux-only dotfile symlinks
  // lib.optionalAttrs isLinux {
    # Hyprland config
    ".config/hypr/hyprland.conf".source = "${configDir}/dotfiles/hypr/hyprland.conf";
    ".config/hypr/hypridle.conf".source = "${configDir}/dotfiles/hypr/hypridle.conf";
    ".config/hypr/hyprlock.conf".source = "${configDir}/dotfiles/hypr/hyprlock.conf";
    ".config/hypr/hyprpaper.conf".source = "${configDir}/dotfiles/hypr/hyprpaper.conf";
    # Waybar status bar
    ".config/waybar/config.jsonc".source = "${configDir}/dotfiles/waybar/config.jsonc";
    ".config/waybar/style.css".source = "${configDir}/dotfiles/waybar/style.css";
    # Wofi app launcher
    ".config/wofi/style.css".source = "${configDir}/dotfiles/wofi/style.css";
    # VS Code on Linux uses XDG
    ".config/Code/User/settings.json".source = "${configDir}/dotfiles/vscode/settings.json";
  };

  # Program-specific configurations
  programs = {
    # Enable Home Manager command
    home-manager.enable = true;

    #
    # GIT CONFIGURATION
    #
    git = {
      enable = true;
      signing = lib.mkIf (personal.gpgKey != null) {
        key = personal.gpgKey;
        signByDefault = true;
      };
      settings = {
        user.name = personal.gitConfig.userName;
        user.email = personal.gitConfig.userEmail;
        init.defaultBranch = "main";
        pull.rebase = true;
        push.default = "simple";
        core.editor = personal.preferences.editor.default;
      };
    };

    #
    # SSH CONFIGURATION
    #
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          extraOptions = lib.mkMerge [
            { AddKeysToAgent = "yes"; }
            (lib.mkIf isDarwin { UseKeychain = "yes"; })
          ];
        };
        "github.com" = {
          hostname = "github.com";
          user = "git";
          identityFile = "~/.ssh/id_ed25519";
        };
        "home" = {
          hostname = "100.89.94.46";
          user = "sgoodluck";
          localForwards = [
            { bind.port = 54321; host.address = "localhost"; host.port = 54321; }
            { bind.port = 54322; host.address = "localhost"; host.port = 54322; }
            { bind.port = 54323; host.address = "localhost"; host.port = 54323; }
            { bind.port = 54324; host.address = "localhost"; host.port = 54324; }
            { bind.port = 54325; host.address = "localhost"; host.port = 54325; }
            { bind.port = 54326; host.address = "localhost"; host.port = 54326; }
            { bind.port = 54327; host.address = "localhost"; host.port = 54327; }
            { bind.port = 54328; host.address = "localhost"; host.port = 54328; }
            { bind.port = 54329; host.address = "localhost"; host.port = 54329; }
          ];
        };
      };
    };

    #
    # ZSH SHELL CONFIGURATION
    #
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;

      initContent = ''
        eval "$(oh-my-posh init ${personal.preferences.shell} --config ~/.config/ohmyposh/${promptTheme}.toml)"
        eval "$(zoxide init zsh)"

        # GPG configuration for commit signing
        export GPG_TTY=$(tty)

        # Add blank line before command output (except for clear)
        preexec() {
          if [[ "$1" != "clear" ]]; then
            echo
          fi
        }

        # Add blank line after command output before next prompt
        add_newline() {
          if [ -z "$NEW_LINE_BEFORE_PROMPT" ]; then
            NEW_LINE_BEFORE_PROMPT=1
          elif [ "$NEW_LINE_BEFORE_PROMPT" = 1 ]; then
            local last_cmd=$(fc -ln -1 | sed 's/^[[:space:]]*//')
            if [[ "$last_cmd" != "clear" ]]; then
              echo
            fi
          fi
        }
        precmd_functions+=(add_newline)

        # Cursor CLI path
        export PATH="$HOME/.local/bin:$PATH"

        # NVM initialization (macOS only — installed via Homebrew)
        ${if isDarwin then ''
        export NVM_DIR="$HOME/.nvm"
        [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
        [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
        '' else ""}

        # Source local environment variables (secrets, tokens, etc.)
        [[ -f ~/.env.local ]] && source ~/.env.local

        # Host-specific shell initialization
        ${personal.extraShellInit or ""}

        # System info on new terminal
        fastfetch
      '';

      sessionVariables = {
        # XDG base directory specification
        XDG_CONFIG_HOME = "$HOME/.config";

        # Pager configuration
        PAGER = "moor";
        MANPAGER = "moor";
      } // lib.optionalAttrs isDarwin {
        # Homebrew configuration (macOS only)
        HOMEBREW_NO_AUTO_UPDATE = "1";
        HOMEBREW_NO_ENV_HINTS = "1";
      };

      # PATH configuration — platform-aware
      envExtra = if isDarwin then ''
        # macOS: Homebrew and related paths
        CUSTOM_PATHS=(
          "/opt/homebrew/bin"
          "/opt/homebrew/sbin"
          "/opt/homebrew/opt/llvm/bin"
          "/opt/homebrew/opt/postgresql@16/bin"
        )
        export PATH="$(IFS=:; echo "''${CUSTOM_PATHS[*]}"):$PATH"
      '' else ''
        # Linux: Nix manages PATH — just ensure local bin is included
        export PATH="$HOME/.local/bin:$PATH"
      '';

      shellAliases = {
        # Modern CLI replacements (cross-platform)
        cat = "bat --style=plain";
        ls = "eza --icons";
        ll = "eza -la --icons --git";
        tree = "eza --tree --icons";
        du = "dust";
        ps = "procs";
        top = "htop";
        find = "fd";
        grep = "rg";
        cd = "z";
        lg = "lazygit";
        diff = "riff";

        # Claude Code helpers
        screenshot = "screenshot-capture";
        pr-data = "pr-review";

        # NPM authentication
        npm-auth = "export GH_NPM_TOKEN=\"$(pbpaste)\" && echo \"✓ NPM token set\"";

        # Kubernetes helpers
        kube-reset = "kubectl config unset current-context && echo \"✓ Cleared current context\"";
        kube-clear = "kubectl config unset current-context && echo \"✓ Cleared current context\"";
      }
      # Platform-specific rebuild aliases
      // (if isDarwin then {
        nxr = "sudo darwin-rebuild switch --flake ~/nix#${machineName}";
        nxr-work = "sudo darwin-rebuild switch --flake ~/nix#Seths-MacBook-Pro";
        nxr-personal = "sudo darwin-rebuild switch --flake ~/nix#sgoodluck-m1air";
      } else {
        nxr = "sudo nixos-rebuild switch --flake ~/nix#${machineName}";
      })
      // (personal.extraAliases or {});
    };
  };

}
