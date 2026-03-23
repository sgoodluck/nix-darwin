# NixOS laptop configuration — ThinkPad X1 Nano Gen 3
{ pkgs, lib, ... }:

{
  # Personal identity (same as macOS personal machine)
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
  machineName = "smartin-nano";

  # NixOS-specific: no dockApps (that's a macOS concept)
  # Provide empty defaults so shared code doesn't break
  dockApps = [ ];

  # Linux-specific extra packages (GUI apps that were Homebrew casks on macOS)
  extraPackages = pkgs: with pkgs; [
    # Browsers
    firefox
    zen-browser

    # Privacy & utilities
    transmission_4-gtk
    protonvpn-gui

    # Creative tools
    inkscape
    obsidian

    # Terminal
    ghostty

    # Wayland utilities
    wl-clipboard       # clipboard for Wayland (replaces pbcopy/pbpaste)
    brightnessctl      # backlight control
    playerctl          # media key control
    networkmanagerapplet # nm-applet for systray

    # Screenshot
    grim               # screenshot tool for Wayland
    slurp              # region selection for grim
    hyprshot           # Hyprland screenshot wrapper
  ];

  # No Homebrew on NixOS
  extraBrews = [ ];
  extraCasks = [ ];

  # Extra aliases for NixOS
  extraAliases = {
    # NixOS rebuild (parallel to nxr on macOS)
    nxr = "sudo nixos-rebuild switch --flake ~/nix#smartin-nano";

    # Clipboard (match macOS muscle memory)
    pbcopy = "wl-copy";
    pbpaste = "wl-paste";
  };

  # NixOS-specific shell init
  extraShellInit = ''
    # Wayland environment
    export MOZ_ENABLE_WAYLAND=1
    export NIXOS_OZONE_WL=1
  '';

  # Universal preferences (same as personal macOS)
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
