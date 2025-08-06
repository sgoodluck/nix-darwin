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
    ".config/karabiner/karabiner.json".source = "${configDir}/dotfiles/karabiner.json";
    ".config/amethyst/amethyst.yml".source = "${configDir}/dotfiles/amethyst.yml";
    ".config/doom/init.el".source = "${configDir}/dotfiles/doom/init.el";
    ".config/doom/config.el".source = "${configDir}/dotfiles/doom/config.el";
    ".config/doom/packages.el".source = "${configDir}/dotfiles/doom/packages.el";
    ".config/doom/README.md".source = "${configDir}/dotfiles/doom/README.md";
    ".config/doom/.gitignore".source = "${configDir}/dotfiles/doom/.gitignore";
    ".local/bin/doom-git-init".source = "${configDir}/scripts/doom-git-init.sh";
    ".config/nvim".source = "${configDir}/dotfiles/nvim";
    ".config/zellij/config.kdl".source = "${configDir}/dotfiles/zellij/config.kdl";
    ".config/ghostty/config".source = "${configDir}/dotfiles/ghostty/config";
    ".claude/CLAUDE.md".source = "${configDir}/dotfiles/claude/CLAUDE.md";
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
      userName = personal.fullName;
      userEmail = personal.email;
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;
        core.editor = personal.preferences.editor.default;
      };
    };

    #
    # SSH CONFIGURATION
    #
    ssh = {
      enable = true;
      matchBlocks = {
        "github.com" = {
          hostname = "github.com";
          user = "git";
          identityFile = "~/.ssh/id_ed25519";
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
      '';

      sessionVariables = {
        # XDG base directory specification
        XDG_CONFIG_HOME = "$HOME/.config";

        # Doom Emacs configuration directory
        DOOMDIR = "$HOME/.config/doom";

        # Homebrew configuration
        HOMEBREW_NO_AUTO_UPDATE = "1"; # Prevent auto-updates during installs
        HOMEBREW_NO_ENV_HINTS = "1"; # Suppress environment hints

        # API Keys - set your key here or use .authinfo.gpg instead
        # ANTHROPIC_API_KEY = "your-api-key-here";
      };

      # PATH configuration - prepend custom directories
      envExtra = ''
        # Build PATH from list of directories
        CUSTOM_PATHS=(
          "$HOME/.config/emacs/bin"     # Doom Emacs scripts
          "/opt/homebrew/bin"            # Homebrew binaries
          "/opt/homebrew/sbin"           # Homebrew system binaries
          "/opt/homebrew/opt/llvm/bin"  # LLVM tools from Homebrew
        )

        # Join paths with : and prepend to PATH
        export PATH="$(IFS=:; echo "''${CUSTOM_PATHS[*]}"):$PATH"
      '';

      shellAliases = {
        nxr = "sudo darwin-rebuild switch --flake ~/nix#${machineName}";
        nxr-work = "sudo darwin-rebuild switch --flake ~/nix#Seths-MacBook-Pro";
        nxr-personal = "sudo darwin-rebuild switch --flake ~/nix#sgoodluck-m1air";
        ls = "ls --color=auto";
        # Doom config git management
        doom-commit = "cd ~/.config/doom && git add -A && git commit -m";
        doom-push = "cd ~/.config/doom && git push";
        doom-status = "cd ~/.config/doom && git status";
      };
    };
  };

}
