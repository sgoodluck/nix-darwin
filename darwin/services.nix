# services.nix
{ config, pkgs, ... }:
{
  services = {
    # Yabai config
    yabai = {
      enable = true;
      enableScriptingAddition = false;
      package = pkgs.yabai;
    };

    # skhd config
    skhd = {
      enable = true;
      package = pkgs.skhd;
    };
  };

}
