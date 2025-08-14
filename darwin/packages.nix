# Package management configuration for macOS
# Combines common packages with host-specific additions
{ pkgs, lib, hostConfig, ... }:
{
  imports = [
    ../modules/common/packages.nix
  ];
}
