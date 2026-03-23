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

  # Linux-specific Nix packages (GUI apps that are Homebrew casks on macOS)
  extraNixPackages = pkgs: with pkgs; [
    # Privacy & utilities
    protonvpn-gui
    proton-pass
    signal-desktop

    # Productivity
    obsidian

    # Creative tools
    orca-slicer

    # Browsers (on macOS these are Homebrew casks)
    firefox

    # Media
    vlc
    tidal-hifi

    # ESP32 development
    espup
    espflash
  ];

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
