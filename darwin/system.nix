# System-level settings and font configuration
{
  pkgs,
  config,
  lib,
  ...
}:
{
  #
  # SYSTEM CONFIGURATION AND STATE
  #
  system.stateVersion = 5; # System state version
  nix.enable = false; # Rely on determinate systems to manae nix

  # Symlink emacs
  system.activationScripts.postActivation.text = ''
    # Ensure the Applications directory exists
    mkdir -p /Applications/Nix
    # Create symlink for Emacs
    ln -sf "$(brew --prefix)/opt/emacs-plus/Emacs.app" /Applications/
  '';

  #
  # SECURITY AND AUTHENTICATION
  #
  security.pam.enableSudoTouchIdAuth = true; # Enable TouchID for sudo authentication

  #
  #HOME MANAGER SETTINGS
  # .
  home-manager.backupFileExtension = "backup";

  #
  # Mac System Settings
  #
  system.defaults = {

    dock = {
      dock.autohide = true;
      dock.orientation = "right";
      show-recents = false;
      tilesize = 48;
    };

    finder = {
      FXPreferredViewStyle = "clmv"; # use column view as default finder view
      ShowPathbar = true;
      ShowStatusbar = true;
    };

    screencapture = {
      location = "~/Pictures/screenshots";
    };

    NSGlobalDomain = {
      AppleShowAllFiles = true; # show hidden files
      AppleShowAllExtensions = true; # show file extensions
      KeyRepeat = 2; # Faster key repeat rate
      InitialKeyRepeat = 15; # Reduce delay to keyrepeat start
      AppleMeasurementUnits = "Centimeters"; # Use cm measurements by default
      AppleMetricUnits = 1; # Enable Metric
      AppleTemperatureUnit = "Celsius"; # Use Celsius
    };

  };
  #
  # NIXPKGS CONFIGURATION AND PLATFORM
  #
  nixpkgs = {
    config.allowUnfree = true; # Allow installation of non-free packages
    hostPlatform = "aarch64-darwin"; # Set for Apple Silicon Macs
  };

  #
  # FONT CONFIGURATION
  #
  fonts.packages = with pkgs; [
    (nerdfonts.override {
      fonts = [
        "AnonymousPro" # Clean monospace font for coding
        "NerdFontsSymbolsOnly" # Adds icons and symbols
        "FiraCode" # Programming font with ligatures
        "JetBrainsMono" # Another excellent coding font
        "Hack" # Alternative coding font
      ];
    })
  ];
}
