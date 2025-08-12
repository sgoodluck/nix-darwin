# System-level settings and font configuration
{
  pkgs,
  config,
  lib,
  hostConfig,
  ...
}:

{
  # System configuration
  system.stateVersion = 5; # Don't change after initial install
  system.primaryUser = hostConfig.username;
  nix.enable = false; # Handled by Determinate Systems installer

  # Ensure Homebrew-installed Emacs appears in /Applications
  system.activationScripts.postActivation.text = ''
    mkdir -p /Applications/Nix
    ln -sf "/opt/homebrew/opt/emacs-plus/Emacs.app" /Applications/
    
    # Reload Aerospace config if it's running
    if pgrep -x "AeroSpace" > /dev/null; then
      /opt/homebrew/bin/aerospace reload-config
    fi
  '';

  # Security
  security.pam.services.sudo_local.touchIdAuth = true;

  # macOS preferences
  system = {

    defaults = {

      dock = {
        autohide = true;
        orientation = "right";
        show-recents = false;
        tilesize = 48;
        persistent-apps = [
          "/Applications/Alacritty.app"
          "/Applications/Zen.app/"
          "/Applications/Emacs.app/"
        ];
      };

      finder = {
        FXPreferredViewStyle = "clmv"; # Column view as default
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      screencapture = {
        location = "~/Pictures/screenshots";
      };

      NSGlobalDomain = {
        _HIHideMenuBar = true;
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
        KeyRepeat = 2;
        InitialKeyRepeat = 15;
        AppleMeasurementUnits = "Centimeters";
        AppleMetricUnits = 1;
        AppleTemperatureUnit = "Celsius";
        AppleICUForce24HourTime = true;
        "com.apple.swipescrolldirection" = false;
      };
    };
  };

  # Nixpkgs configuration
  nixpkgs.config.allowUnfree = true;

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.anonymice
    nerd-fonts.symbols-only
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.hack
  ];
}
