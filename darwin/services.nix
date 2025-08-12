# Service configurations and launch agents
{ config, pkgs, ... }:

{
  # Launch agents - Services that start at login
  launchd.user.agents = {
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
