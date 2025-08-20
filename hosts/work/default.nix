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
    #Dev tools
    "cursor" # cursed
    "aws-vpn-client" # don't drop tables

    # Communication tools
    "zoom"          # Video conferencing
    "slack"         # Team communication
    
    # Google Stuff
    "google-drive"  # File sync
    "google-chrome" # meh
  ];
  
  # Work-specific shell aliases
  extraAliases = {
    # Privileges CLI shortcuts (for managing admin privileges)
    priv = "/Applications/Privileges.app/Contents/MacOS/PrivilegesCLI";
    priv-add = "/Applications/Privileges.app/Contents/MacOS/PrivilegesCLI --add";
    priv-remove = "/Applications/Privileges.app/Contents/MacOS/PrivilegesCLI --remove";
    priv-status = "/Applications/Privileges.app/Contents/MacOS/PrivilegesCLI --status";
  };
  
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
