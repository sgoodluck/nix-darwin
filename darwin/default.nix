# Darwin configuration entry point
# This module aggregates all macOS-specific system configuration
#
# Module structure:
# - system.nix: Core macOS settings, fonts, launch agents, dock configuration
# - packages.nix: Package management (Nix packages + Homebrew brews/casks)
{ config, pkgs, ... }:
{
  imports = [
    ./system.nix   # System settings, preferences, fonts, and services
    ./packages.nix # Package declarations and Homebrew configuration
  ];
}
