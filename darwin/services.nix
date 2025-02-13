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

  # Karabiner Elements
  launchd.user.agents.karabiner = {
    serviceConfig = {
      Program = "${
        pkgs.karabiner-elements.overrideAttrs (old: {
          postInstall = ''
            xattr -d com.apple.quarantine $out/Applications/Karabiner-Elements.app || true
          '';
        })
      }/Applications/Karabiner-Elements.app/Contents/MacOS/Karabiner-Elements";
      RunAtLoad = true;
      KeepAlive = true;
    };
  };
}
