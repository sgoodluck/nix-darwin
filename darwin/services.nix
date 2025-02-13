# services.nix
{ config, pkgs, ... }:

{
  services = {
    # Your existing services here...

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

  # Karabiner Elements
  launchd.user.agents.karabiner = {
    serviceConfig = {
      Program = "${pkgs.karabiner-elements}/Applications/Karabiner-Elements.app/Contents/MacOS/Karabiner-Elements";
      RunAtLoad = true;
      KeepAlive = true;
    };
  };
}
