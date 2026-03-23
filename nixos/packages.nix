# NixOS package management
# Imports shared common packages + adds host-specific and Linux-specific packages
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

  # Add host-specific Nix packages (from hosts/nixos-laptop/default.nix)
  environment.systemPackages =
    if (hostConfig ? extraPackages) then (hostConfig.extraPackages pkgs) else [ ];
}
