# System-level settings and font configuration
{
  pkgs,
  config,
  lib,
  personal,
  ...
}:

{
  # System configuration
  system.stateVersion = 5; # Don't change after initial install
  system.primaryUser = personal.personal.username;
  nix.enable = false; # Handled by Determinate Systems installer

  # Ensure Homebrew-installed Emacs appears in /Applications
  system.activationScripts.postActivation.text = ''
    mkdir -p /Applications/Nix
    ln -sf "/opt/homebrew/opt/emacs-plus/Emacs.app" /Applications/
  '';

  # Security
  security.pam.services.sudo_local.touchIdAuth = true;

  # Home Manager
  home-manager.backupFileExtension = "backup";

  # macOS preferences
  system = {

    defaults = {

      dock = {
        autohide = true;
        orientation = "right";
        show-recents = false;
        tilesize = 48;
        persistent-apps = [
          "/Applications/Emacs.app/"
          "/Applications/Zen.app/"
          "/Applications/Ghostty.app"
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
