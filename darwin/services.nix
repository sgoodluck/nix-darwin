# Service configurations and launch agents
{ config, pkgs, ... }:

{
  # Launch agents - Services that start at login
  launchd.user.agents = {
    # Tiling window manager
    amethyst = {
      serviceConfig = {
        ProgramArguments = [
          "/Applications/Amethyst.app/Contents/MacOS/Amethyst"
        ];
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "/tmp/amethyst.log";
        StandardErrorPath = "/tmp/amethyst.error.log";
      };
    };

    # Emacs daemon for fast client startup
    emacs = {
      serviceConfig = {
        ProgramArguments = [
          "/Applications/Emacs.app/Contents/MacOS/Emacs"
          "--daemon"
        ];
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "/tmp/emacs.log";
        StandardErrorPath = "/tmp/emacs.error.log";
      };
    };
  };
}