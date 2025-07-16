# personal.nix - User-specific personal preferences and machine configuration
{ pkgs, lib, ... }:

{
  # Personal identity information
  personal = {
    username = "sgoodluck";
    fullName = "Seth";
    email = "sethgoodluck@pm.me";
    githubUsername = "Seth";
  };

  # Machine-specific configuration
  machine = {
    # Name used for darwin-rebuild switch command
    name = "sgoodluck-m1air";
    # System architecture
    system = "aarch64-darwin";
  };

  # Universal preferences that would apply across systems
  preferences = {
    # Editor preferences
    editor = {
      default = "nvim";
      terminal = "nvim";
      gui = "emacs";
    };

    # Terminal shell preference
    shell = "zsh";
    
    # Theme configuration
    promptTheme = "zen";
  };
}
