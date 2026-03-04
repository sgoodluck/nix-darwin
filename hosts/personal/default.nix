# Personal machine configuration
{ pkgs, lib, ... }:

{
  # Personal identity
  username = "sgoodluck";
  fullName = "Seth";
  email = "sethgoodluck@pm.me";
  githubUsername = "Seth";
  gpgKey = "E322D2003CDAA1E0"; # Add your GPG key ID here if you have one

  # Git configuration
  gitConfig = {
    userName = "Seth";
    userEmail = "sethgoodluck@pm.me";
  };

  # Machine details
  machineName = "sgoodluck-m1air";

  # Dock configuration
  dockApps = [
    "/Applications/Alacritty.app"
    "/Applications/Zed.app"
    "/Applications/Zen.app"
    "/Applications/Tidal.app"
  ];

  # Personal-specific packages
  extraBrews = [
    "supabase"  # Supabase CLI from supabase/tap
  ];

  extraCasks = [
    "vlc"           # back to the pirate days I go
    "qflipper"      # yay dolphins
    # Creative tools
    "inkscape"      # Vector graphics editor
    "orcaslicer"    # 3D printing slicer
    "raspberry-pi-imager"  # Raspberry Pi OS imaging tool
    "balenaetcher"  # OS image flasher

    # Privacy & utilities
    "transmission"  # BitTorrent client
    "protonvpn"     # VPN service
    "proton-pass"   # Password manager
    "brave-browser" # Privacy-focused web browser

    # Productivity
    "obsidian"      # Knowledge management and note-taking

    # Sailing
    "opencpn"   # Chart plotter

    # Swift/Android development
    "skiptools/skip/skip"                          # Skip CLI
    "skiptools/skip/swift-android-toolchain@6.2"   # Swift Android cross-compilation toolchain
  ];

  # Universal preferences (inherited from common)
  preferences = {
    editor = {
      default = "nvim";
      terminal = "nvim";
      gui = "zed";  # Previously: emacs
    };
    shell = "zsh";
    terminalEmulator = "alacritty";
    promptTheme = "zen";
  };
}
