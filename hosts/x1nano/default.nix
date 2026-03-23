# NixOS machine configuration - Lenovo ThinkPad X1 Nano
{ pkgs, lib, ... }:

{
  # Personal identity (same as macOS)
  username = "sgoodluck";
  fullName = "Seth";
  email = "sethgoodluck@pm.me";
  githubUsername = "Seth";
  gpgKey = "E322D2003CDAA1E0";

  # Git configuration
  gitConfig = {
    userName = "Seth";
    userEmail = "sethgoodluck@pm.me";
  };

  # Machine details
  machineName = "x1nano";

  # NixOS: no dock (macOS concept)
  dockApps = [ ];

  # Linux-specific Nix packages (GUI apps that are Homebrew casks on macOS)
  extraPackages = pkgs: with pkgs; [
    # Terminal
    ghostty

    # Browsers
    firefox
    brave

    # Privacy & utilities
    protonvpn-gui
    proton-pass
    signal-desktop
    transmission_4-gtk

    # Productivity
    obsidian

    # Creative tools
    orca-slicer
    inkscape

    # Media
    vlc
    tidal-hifi

    # ESP32 development
    espup
    espflash

    # Wayland utilities
    wl-clipboard
    brightnessctl
    playerctl
    networkmanagerapplet
    grim
    slurp
    hyprshot
  ];

  # No Homebrew on NixOS
  extraBrews = [ ];
  extraCasks = [ ];

  # Extra aliases for NixOS
  extraAliases = {
    pbcopy = "wl-copy";
    pbpaste = "wl-paste";
  };

  # NixOS-specific shell init
  extraShellInit = ''
    export MOZ_ENABLE_WAYLAND=1
    export NIXOS_OZONE_WL=1
  '';

  # Universal preferences (same as macOS personal)
  preferences = {
    editor = {
      default = "nvim";
      terminal = "nvim";
      gui = "zed";
    };
    shell = "zsh";
    terminalEmulator = "ghostty";
    promptTheme = "zen";
  };
}
