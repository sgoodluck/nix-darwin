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

  # Machine name - still hardcoded here since it's Mac-specific
  machineName = "sgoodluck-m1air";

  # Theme name - still hardcoded here since it's Mac-specific
  promptTheme = "zen";
in
{
  home.stateVersion = "24.11";

  #
  # SPECIFY DOT FILES
  #

  home.file = {
    ".config/ohmyposh/${promptTheme}.toml".source = "${configDir}/dotfiles/zen.toml";
    ".config/karabiner/karabiner.json".source = "${configDir}/dotfiles/karabiner.json";
    ".config/amethyst/amethyst.yml".source = "${configDir}/dotfiles/amethyst.yml";
    ".config/doom/init.el".source = "${configDir}/dotfiles/doom/init.el";
    ".config/doom/config.el".source = "${configDir}/dotfiles/doom/config.el";
    ".config/doom/packages.el".source = "${configDir}/dotfiles/doom/packages.el";
    ".config/nvim/init.lua".source = "${configDir}/dotfiles/nvim/init.lua";
  };

  programs = {

    home-manager.enable = true;
    #
    # CONFIGURE GIT
    #
    git = {
      enable = true;
      userName = personal.personal.fullName;
      userEmail = personal.personal.email;
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;
        core.editor = personal.preferences.editor.default;
      };
    };

    #
    # CONFIGURE ALACRITTY
    #
    alacritty = {
      enable = true;
      settings = {
        window = {
          decorations = "none";
          padding = {
            x = 5;
            y = 5;
          };
          opacity = .95;
        };
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
        eval "$(oh-my-posh init ${personal.preferences.shell} --config ~/.config/ohmyposh/${promptTheme}.toml)"
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
        nxr = "darwin-rebuild switch --flake ~/nix#${machineName}";
        ls = "ls --color=auto";
      };
    };
  };

}
