# personal.nix - User-specific personal preferences
{ pkgs, lib, ... }:

{
  # Personal identity information
  personal = {
    username = "sgoodluck";
    fullName = "Seth";
    email = "sethgoodluck@pm.me";
    githubUsername = "Seth";
  };

  # Machine-specific settings
  machine = {
    name = "sgoodluck-m1air";
    hostName = "sgoodluck-m1air";
    isWork = false;
  };

  # Personal preferences
  preferences = {
    # Editor preferences
    editor = {
      default = "nvim";
      terminal = "nvim";
      gui = "emacs";
    };

    # Terminal preferences
    terminal = {
      app = "alacritty";
      shell = "zsh";
      promptTheme = "zen"; # Used by oh-my-posh
    };

    # UI preferences
    ui = {
      theme = "spacemacs-light"; # Base theme
      font = "AnonymicePro Nerd Font";
      fontSize = 12;
    };

    # Web browser
    browser = "Zen";
  };

  # Your favorite applications
  favoriteApps = [
    "/Applications/Emacs.app/"
    "/Applications/Zen.app/"
    "/Applications/TIDAL.app/"
    "/Applications/Nix Apps/Alacritty.app"
  ];
}
