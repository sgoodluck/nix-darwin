# User-specific configurations (ZSH, Git, etc.)
{ config, pkgs, ... }:
{
  home = {
    username = "seth";
    homeDirectory = "/Users/seth";
    stateVersion = "24.11"; # Read the docs before changing
  };

  #
  # PROGRAM-SPECIFIC CONFIGURATIONS
  #
  programs = {
    home-manager.enable = true;

    #
    # GIT CONFIGURATION
    #
    git = {
      enable = true;
      userName = "Seth"; # Update with your name
      userEmail = "your.email@example.com"; # Update with your email
      extraConfig = {
        init.defaultBranch = "main"; # Default branch name
        pull.rebase = true; # Use rebase for pulls
        core.editor = "nvim"; # Default editor
      };
    };

    #
    # SHELL CONFIGURATION (ZSH)
    #
    zsh = {
      enable = true;
      enableCompletion = true; # Enable completion system
      enableAutosuggestions = true; # Enable autosuggestions feature

      # Shell initialization
      initExtra = ''
        eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/zen.toml)"
      '';

      # Environment variables
      sessionVariables = {
        XDG_CONFIG_HOME = "$HOME/.config";
        PATH = "$XDG_CONFIG_HOME/emacs/bin:$HOME/.emacs.d/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/opt/homebrew/opt/llvm/bin:$PATH";
      };

      # Shell aliases
      shellAliases = {
        nxr = "darwin-rebuild switch --flake ~/.config/nix#m1air"; # Rebuild system
      };
    };
  };

  #
  # DOTFILE MANAGEMENT
  #
  home.file = {
    # Example: ".config/ohmyposh/zen.toml".source = ./dotfiles/oh-my-posh/zen.toml;
  };
}
