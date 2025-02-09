{
  pkgs,
  lib,
  config,
  ...
}:
{
  home.stateVersion = "24.11";

  programs = {
    home-manager.enable = true;

    git = {
      enable = true;
      userName = "Seth";
      userEmail = "your.email@example.com";
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;
        core.editor = "nvim";
      };
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      enableAutosuggestions = true;

      initExtra = ''
        eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/zen.toml)"
      '';

      sessionVariables = {
        XDG_CONFIG_HOME = "$HOME/.config";
        PATH = "$XDG_CONFIG_HOME/emacs/bin:$HOME/.emacs.d/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/opt/homebrew/opt/llvm/bin:$PATH";
      };

      shellAliases = {
        nixr = "darwin-rebuild switch --flake ~/.config/nix#m1air";
      };
    };
  };
}
