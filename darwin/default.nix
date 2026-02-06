# Darwin configuration entry point
# This module aggregates all macOS-specific system configuration
#
# Module structure:
# - system.nix: Core macOS settings, preferences, and fonts
# - packages.nix: Package management (Nix packages + Homebrew)
# - services.nix: Launch agents and service configurations
{ config, pkgs, inputs, hostConfig, ... }:
{
  imports = [
    ./system.nix   # System settings, preferences, and fonts
    ./packages.nix # Package declarations and Homebrew configuration
    ./services.nix # Launch agents and services
  ];
}
