# Personal machine configuration
{ pkgs, lib, ... }:

{
  # Personal identity
  username = "sgoodluck";
  fullName = "Seth";
  email = "sethgoodluck@pm.me";
  githubUsername = "Seth";
  
  # Machine details
  machineName = "sgoodluck-m1air";
  
  # Personal-specific packages
  extraBrews = [];
  
  extraCasks = [
    # Creative tools
    "orcaslicer"    # 3D printing slicer
    
    # Privacy & utilities
    "transmission"  # BitTorrent client
    "protonvpn"     # VPN service
    "proton-pass"   # Password manager
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