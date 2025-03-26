# personal.nix - User-specific personal preferences
{ pkgs, lib, ... }:

{
  # Personal identity information
  personal = {
    username = "sgoodluck";
    fullName = "Seth";
    email = "sethgoodluck@pm.me";
    githubUsername = "Seth";
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
  };
}
