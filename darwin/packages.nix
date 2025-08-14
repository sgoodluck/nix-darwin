# Package management configuration for macOS
# Combines common packages with host-specific additions
{ pkgs, lib, hostConfig, ... }:
{
  imports = [
    ../modules/common/packages.nix
  ];

  # Merge host-specific packages
  homebrew = {
    brews = hostConfig.extraBrews or [];
    casks = hostConfig.extraCasks or [];
  };
}
