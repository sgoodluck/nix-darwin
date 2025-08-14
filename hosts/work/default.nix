# Work machine configuration
{ pkgs, lib, ... }:

{
  # Work identity
  username = "seth.martin@firstresonance.io";
  fullName = "Seth";
  email = "seth.martin@firstresonance.io";
  githubUsername = "smartin-firstresonance";
  gpgKey = "0727CB23E7713CFB";
  
  # Machine details
  machineName = "Seths-MacBook-Pro";
  
  # Work-specific packages
  extraBrews = [
    "postgresql@16"  # PostgreSQL version 16 for specific project requirements
  ];
  
  extraCasks = [
    # Communication tools
    "zoom"          # Video conferencing
    "slack"         # Team communication
    
    # Google Workspace
    "google-drive"  # File sync
    "cursor" # cursed
    "google-chrome" # meh
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
