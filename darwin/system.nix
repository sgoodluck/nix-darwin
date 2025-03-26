# System-level settings and font configuration
{
  pkgs,
  config,
  lib,
  personal,
  ...
}:

{
  #
  # SYSTEM CONFIGURATION AND STATE
  #
  system.stateVersion = 5; # System state version
  nix.enable = false; # Rely on determinate systems to manage nix

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
          "/Applications/TIDAL.app/"
          "/Applications/Nix Apps/Alacritty.app"
        ];
      };

      finder = {
        FXPreferredViewStyle = "clmv"; # use column view as default finder view
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      screencapture = {
        location = "~/Pictures/screenshots";
      };

      NSGlobalDomain = {
        _HIHideMenuBar = true;
        AppleShowAllFiles = true; # show hidden files
        AppleShowAllExtensions = true; # show file extensions
        KeyRepeat = 2; # Faster key repeat rate
        InitialKeyRepeat = 15; # Reduce delay to keyrepeat start
        AppleMeasurementUnits = "Centimeters"; # Use cm measurements by default
        AppleMetricUnits = 1; # Enable Metric
        AppleTemperatureUnit = "Celsius"; # Use Celsius
        AppleICUForce24HourTime = true; # Use 24 hour time
        "com.apple.swipescrolldirection" = false; # Inverse scrolling
      };
    };
  };

  #
  # Launch at Login
  #
  launchd.user.agents = {
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

  #
  # NIXPKGS CONFIGURATION AND PLATFORM
  #
  nixpkgs = {
    config.allowUnfree = true; # Allow installation of non-free packages
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
