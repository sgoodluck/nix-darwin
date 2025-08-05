# Package management configuration for macOS
# Combines common packages with host-specific additions
{ pkgs, lib, hostConfig, ... }:
{
  imports = [
    ../modules/common/packages.nix
  ];
  
  # Add host-specific brews if defined
  homebrew.brews = lib.mkAfter (hostConfig.extraBrews or []);
  
  # Add host-specific casks if defined
  homebrew.casks = lib.mkAfter (hostConfig.extraCasks or []);
}
