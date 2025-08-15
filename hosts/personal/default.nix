# Personal machine configuration
{ pkgs, lib, ... }:

{
  # Personal identity
  username = "sgoodluck";
  fullName = "Seth";
  email = "sethgoodluck@pm.me";
  githubUsername = "Seth";
  gpgKey = "E322D2003CDAA1E0"; # Add your GPG key ID here if you have one
  
  # Machine details
  machineName = "sgoodluck-m1air";
  
  # Personal-specific packages
  extraBrews = [];
  
  extraCasks = [
    # Creative tools
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
  ];
  
  # Universal preferences (inherited from common)
  preferences = {
    editor = {
      default = "nvim";
      terminal = "nvim";
      gui = "emacs";
    };
    shell = "zsh";
    terminalEmulator = "alacritty";
    promptTheme = "zen";
  };
}
