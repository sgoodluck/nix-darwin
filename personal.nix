# personal.nix - User-specific personal preferences and machine configuration
{ pkgs, lib, ... }:

{
  # Personal identity information
  personal = {
    username = "seth.martin@firstresonance.io";
    fullName = "Seth";
    email = "seth.martin@firstresonance.io";
    githubUsername = "smartin-firstresonance";
  };

  # Machine-specific configuration
  machine = {
    # Name used for darwin-rebuild switch command
    name = "Seths-MacBook-Pro";
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
    
    # Terminal emulator preference
    terminalEmulator = "ghostty";
    
    # Theme configuration
    promptTheme = "zen";
  };
}
