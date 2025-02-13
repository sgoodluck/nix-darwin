{
  pkgs,
  lib,
  config,
  ...
}:
let
  # Get the directory containing this file
  configDir = builtins.toString ./.;
in
{
  home.stateVersion = "24.11";

  #
  # SPECIFY DOT FILES
  #

  home.file = {
    ".config/ohmyposh/zen.toml".source = "${configDir}/dotfiles/zen.toml";
    ".config/karabiner/karabiner.json".source = "${configDir}/dotfiles/karabiner.json";
    ".config/amethyst/amethyst.yml".source = "${configDir}/dotfiles/amethyst.yml";
  };

  programs = {
    home-manager.enable = true;
    #
    # CONFIGURE GIT
    #
    git = {
      enable = true;
      userName = "Seth";
      userEmail = "sethgoodluck@pm.me";
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;
        core.editor = "nvim";
      };
    };

    #
    # CONFIGURE ZSH
    #
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;

      initExtra = ''
        eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/zen.toml)"
      '';

      sessionVariables = {
        XDG_CONFIG_HOME = "$HOME/.config";
        PATH = "$XDG_CONFIG_HOME/emacs/bin:$HOME/.emacs.d/bin:/opt/homebrew/bin:/opt/homebrew/sbin:/opt/homebrew/opt/llvm/bin:$PATH";
      };

      shellAliases = {
        nxr = "darwin-rebuild switch --flake ~/nix#m1air";
        ls = "ls --color=auto";
      };
    };
  };

}
