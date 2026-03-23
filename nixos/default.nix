# NixOS configuration entry point
# This module aggregates all NixOS-specific system configuration
#
# Module structure:
# - system.nix: Boot, networking, locale, users, security
# - packages.nix: Package management (Nix packages only — no Homebrew)
# - desktop.nix: Hyprland, audio, display manager, fonts
{ config, pkgs, inputs, hostConfig, ... }:
{
  imports = [
    ./system.nix
    ./packages.nix
    ./desktop.nix
  ];
}
