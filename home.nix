# Home Manager configuration for user-level settings
# Manages dotfiles, shell configuration, and user programs
#
# Structure:
# - Dotfile symlinks: Links config files from dotfiles/ to ~/.config/
# - Program configurations: Git, Alacritty, Zsh with custom settings
# - Shell environment: PATH, aliases, and environment variables
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
    ".config/aerospace/aerospace.toml".source = "${configDir}/dotfiles/aerospace/aerospace.toml";
    ".config/ohmyposh/${promptTheme}.toml".source = "${configDir}/dotfiles/zen.toml";
    # Status scripts for oh-my-posh prompt
    ".config/dotfiles/vpn-status.sh".source = "${configDir}/scripts/prompt/vpn-status.sh";
    ".config/dotfiles/venv-status.sh".source = "${configDir}/scripts/prompt/venv-status.sh";
    ".config/dotfiles/aws-profile-status.sh".source = "${configDir}/scripts/prompt/aws-profile-status.sh";
    ".config/dotfiles/kube-status.sh".source = "${configDir}/scripts/prompt/kube-status.sh";
    ".config/karabiner/karabiner.json".source = "${configDir}/dotfiles/karabiner.json";
    ".config/amethyst/amethyst.yml".source = "${configDir}/dotfiles/amethyst.yml";
    # Nvim config now managed via Nix
    ".config/nvim".source = "${configDir}/dotfiles/nvim";
    ".config/zellij/config.kdl".source = "${configDir}/dotfiles/zellij/config.kdl";
    ".config/zellij/layouts/minimal.kdl".source = "${configDir}/dotfiles/zellij/layouts/minimal.kdl";
    ".config/alacritty/alacritty.toml".source = "${configDir}/dotfiles/alacritty.toml";
    ".config/lazygit/config.yml".source = "${configDir}/dotfiles/lazygit.yml";
    ".config/zed/settings.json".source = "${configDir}/dotfiles/zed/settings.json";

    # Claude Code configuration and commands
    ".claude/CLAUDE.md".source = "${configDir}/dotfiles/claude/CLAUDE.md";
    ".claude/commands/screenshot.md".source = "${configDir}/dotfiles/claude/commands/screenshot.md";
    ".claude/commands/pr-review.md".source = "${configDir}/dotfiles/claude/commands/pr-review.md";
    ".claude/statusline.sh" = {
      source = "${configDir}/dotfiles/claude/statusline.sh";
      executable = true;
    };
    # Claude helper scripts in PATH
    ".local/bin/screenshot-capture".source = "${configDir}/scripts/claude/screenshot-capture.sh";
    ".local/bin/pr-review".source = "${configDir}/scripts/claude/pr-review.sh";

    # Kubernetes helper scripts (work machine)
    ".local/bin/k8s-db-password".source = "${configDir}/dotfiles/scripts/k8s-db-password";
    # VS Code settings - symlinked to Application Support
    "Library/Application Support/Code/User/settings.json".source = "${configDir}/dotfiles/vscode/settings.json";
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
      userName = personal.gitConfig.userName;
      userEmail = personal.gitConfig.userEmail;
      signing = {
        key = personal.gpgKey;
        signByDefault = true;
      };
      extraConfig = {
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
      addKeysToAgent = "yes";
      extraConfig = ''
        UseKeychain yes
        AddKeysToAgent yes
      '';
      matchBlocks = {
        "github.com" = {
          hostname = "github.com";
          user = "git";
          identityFile = "~/.ssh/id_ed25519";
        };
        "home" = {
          hostname = "100.89.94.46";
          user = "sgoodluck";
          localForwards = [
            { bind.port = 54321; host.address = "localhost"; host.port = 54321; } # Studio
            { bind.port = 54322; host.address = "localhost"; host.port = 54322; } # PostgreSQL
            { bind.port = 54323; host.address = "localhost"; host.port = 54323; } # REST API
            { bind.port = 54324; host.address = "localhost"; host.port = 54324; } # Realtime
            { bind.port = 54325; host.address = "localhost"; host.port = 54325; } # Storage
            { bind.port = 54326; host.address = "localhost"; host.port = 54326; } # Auth
            { bind.port = 54327; host.address = "localhost"; host.port = 54327; } # Edge Functions
            { bind.port = 54328; host.address = "localhost"; host.port = 54328; } # Analytics
            { bind.port = 54329; host.address = "localhost"; host.port = 54329; } # S3 Storage
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
        # Skip blank lines after 'clear' command
        add_newline() {
          if [ -z "$NEW_LINE_BEFORE_PROMPT" ]; then
            NEW_LINE_BEFORE_PROMPT=1
          elif [ "$NEW_LINE_BEFORE_PROMPT" = 1 ]; then
            # Check if last command was 'clear'
            local last_cmd=$(fc -ln -1 | sed 's/^[[:space:]]*//')
            if [[ "$last_cmd" != "clear" ]]; then
              echo
            fi
          fi
        }
        precmd_functions+=(add_newline)
        
        # Cursor CLI path (install manually with: curl https://cursor.com/install | bash)
        export PATH="$HOME/.local/bin:$PATH"
        
        # Host-specific shell initialization
        ${personal.extraShellInit or ""}
      '';


      sessionVariables = {
        # XDG base directory specification
        XDG_CONFIG_HOME = "$HOME/.config";

        # Homebrew configuration
        HOMEBREW_NO_AUTO_UPDATE = "1"; # Prevent auto-updates during installs
        HOMEBREW_NO_ENV_HINTS = "1"; # Suppress environment hints

        # Pager configuration
        PAGER = "moor";
        MANPAGER = "moor";

        # API Keys - set your key here or use .authinfo.gpg instead
        # ANTHROPIC_API_KEY = "your-api-key-here";
      };

      # PATH configuration - prepend custom directories
      envExtra = ''
        # Build PATH from list of directories
        CUSTOM_PATHS=(
          "/opt/homebrew/bin"            # Homebrew binaries
          "/opt/homebrew/sbin"           # Homebrew system binaries
          "/opt/homebrew/opt/llvm/bin"  # LLVM tools from Homebrew
          "/opt/homebrew/opt/postgresql@16/bin"  # PostgreSQL tools
        )

        # Join paths with : and prepend to PATH
        export PATH="$(IFS=:; echo "''${CUSTOM_PATHS[*]}"):$PATH"
      '';

      shellAliases = {
        # Nix rebuild commands
        nxr = "sudo darwin-rebuild switch --flake ~/nix#${machineName}";
        nxr-work = "sudo darwin-rebuild switch --flake ~/nix#Seths-MacBook-Pro";
        nxr-personal = "sudo darwin-rebuild switch --flake ~/nix#sgoodluck-m1air";
        
        # Modern CLI replacements
        cat = "bat";
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
        
        # NPM authentication - set token from clipboard
        npm-auth = "export GH_NPM_TOKEN=\"$(pbpaste)\" && echo \"✓ NPM token set\"";
        
        # Kubernetes helpers
        kube-reset = "kubectl config unset current-context && echo \"✓ Cleared current context\"";
        kube-clear = "kubectl config unset current-context && echo \"✓ Cleared current context\"";
      } // (personal.extraAliases or {});
    };
  };

}
