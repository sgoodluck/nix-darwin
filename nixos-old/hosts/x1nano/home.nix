{ config, pkgs, ... }:

{
  ## Configuration ##
  home.stateVersion = "24.05"; # Read instructions before changing.
  programs.home-manager.enable = true; # Let Home Manager self manage

  ## User Information ##
  home.username = "smartin";
  home.homeDirectory = "/home/smartin";
  
  nixpkgs.config.allowUnfree = true;
  
  ## User Packages ##
  home.packages = with pkgs; [
    gnome-disk-utility
    orca-slicer
    bambu-studio
    runelite
    proton-pass
    networkmanagerapplet
    signal-desktop
    docker
    pfetch
    obs-studio
    oh-my-posh
    zig
    vscode-fhs
    neovim
    kitty
    thunderbird
    firefox
    obsidian
    tidal-hifi
    protonmail-bridge-gui
    protonvpn-gui
    yubico-pam
    (writeShellScriptBin "nxr" ''
      echo "🔧 Initiating Nixos Rebuild 🔧" && echo &&
      sudo nixos-rebuild switch --flake ~/nixos#x1nano &&
      echo && echo "💛 Nixos Rebuild Complete 💛"
     '')
    (writeShellScriptBin "unxr" ''
       echo "🔧 Initiating Nix Flake Update & Nixos Rebuild 🔧" && echo &&
       sudo nix flake update --flake ~/nixos/ && echo &&
       sudo nixos-rebuild switch --flake ~/nixos#x1nano &&
       echo && echo "💛 Nix Flake Update & Nixos Rebuild Complete 💛"
    '')
  ];

  ## Dot Files ##
  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Session Variables ##
  home.sessionVariables = {
    EDITOR = "neovim";
  };

}

