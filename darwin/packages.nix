# Package management configuration for macOS
# Combines common packages with host-specific additions
{
  pkgs,
  lib,
  hostConfig,
  ...
}:
{
  imports = [
    ../modules/common/packages.nix
  ];
  # Add host-specific Nix packages
  environment.systemPackages =
    if (hostConfig ? extraPackages) then (hostConfig.extraPackages pkgs) else [ ];

  # Merge host-specific Homebrew packages
  homebrew = {
    brews = hostConfig.extraBrews or [ ];
    casks = hostConfig.extraCasks or [ ];
  };
}
