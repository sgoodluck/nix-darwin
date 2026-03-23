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

  # Homebrew configuration
  homebrew = {
    enable = true;

    global = {
      autoUpdate = false;
      lockfiles = false;
    };

    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };

    brews = [
      "mas"
      "git-graph"
      "nvm"
      "markdown"
      "moor"
      "riff"
      "kube-ps1"
      "asciiquarium"
      "cmatrix"
    ] ++ (hostConfig.extraBrews or []);

    casks = [
      "markedit"
      "appcleaner"
      "the-unarchiver"
      "keycastr"
      "ghostty"
      "firefox"
      "zen"
      "zed"
      "gimp"
      "nikitabobko/tap/aerospace"
      "karabiner-elements"
      "tidal"
      "notunes"
    ] ++ (hostConfig.extraCasks or []);
  };
}
