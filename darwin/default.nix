# Main entry point for Darwin configuration - imports all other modules
{ config, pkgs, ... }:
{
  imports = [
    ./system.nix # System settings and fonts
    ./packages.nix # All packages and Homebrew config
  ];
}
