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
    ".config/doom/init.el".source = "${configDir}/dotfiles/doom/init.el";
    ".config/doom/config.el".source = "${configDir}/dotfiles/doom/config.el";
    ".config/doom/packages.el".source = "${configDir}/dotfiles/doom/packages.el";
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
        DOOMDIR = "$HOME/.config/doom";

        # Individual PATH components
        EMACS_BIN = "$HOME/.config/emacs/bin";
        HOMEBREW_BIN = "/opt/homebrew/bin";
        HOMEBREW_SBIN = "/opt/homebrew/sbin";
        LLVM_BIN = "/opt/homebrew/opt/llvm/bin";

        # Assembled PATH with all components
        PATH = "$EMACS_BIN:$HOMEBREW_BIN:$HOMEBREW_SBIN:$LLVM_BIN:$PATH";
      };

      shellAliases = {
        nxr = "darwin-rebuild switch --flake ~/nix#m1air";
        ls = "ls --color=auto";
      };
    };
  };

}
