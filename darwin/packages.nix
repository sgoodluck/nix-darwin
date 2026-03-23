{ pkgs, lib, hostConfig, ... }:
{
  imports = [
    ../modules/common/packages.nix
  ];

  environment.systemPackages =
    if (hostConfig ? extraPackages) then (hostConfig.extraPackages pkgs) else [ ];

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
    ] ++ (hostConfig.extraBrews or [ ]);

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
    ] ++ (hostConfig.extraCasks or [ ]);
  };
}
