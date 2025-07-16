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
  # Darwin system state version (don't change after initial install)
  system.stateVersion = 5;
  
  # Primary user - used by various Darwin modules
  system.primaryUser = personal.personal.username;
  
  # Disable Nix daemon management (handled by Determinate Systems installer)
  nix.enable = false;

  # Create Application symlinks
  # This ensures Homebrew-installed Emacs appears in /Applications
  system.activationScripts.postActivation.text = ''
    # Ensure the Applications directory exists
    mkdir -p /Applications/Nix
    # Create symlink for Emacs (installed via Homebrew)
    ln -sf "/opt/homebrew/opt/emacs-plus/Emacs.app" /Applications/
  '';

  #
  # SECURITY AND AUTHENTICATION
  #
  security.pam.services.sudo_local.touchIdAuth = true; # Enable TouchID for sudo authentication

  #
  # HOME MANAGER SETTINGS
  #
  home-manager.backupFileExtension = "backup";

  #
  # MACOS SYSTEM PREFERENCES
  #
  system = {

    defaults = {

      dock = {
        autohide = true;           # Hide dock when not in use
        orientation = "right";     # Position on right side of screen
        show-recents = false;      # Don't show recent apps
        tilesize = 48;             # Icon size in pixels
        persistent-apps = [        # Pinned apps (in order)
          "/Applications/Emacs.app/"
          "/Applications/Zen.app/"
          "/Applications/TIDAL.app/"
          "/Applications/Nix Apps/Alacritty.app"
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
        _HIHideMenuBar = true; # Auto-hide menu bar
        AppleShowAllFiles = true; # Show hidden files in Finder
        AppleShowAllExtensions = true; # Always show file extensions
        KeyRepeat = 2; # Fast key repeat rate
        InitialKeyRepeat = 15; # Short delay before key repeat
        AppleMeasurementUnits = "Centimeters"; # Metric measurements
        AppleMetricUnits = 1; # Enable metric system
        AppleTemperatureUnit = "Celsius"; # Celsius for temperature
        AppleICUForce24HourTime = true; # 24-hour clock format
        "com.apple.swipescrolldirection" = false; # Natural scrolling off
      };
    };
  };

  #
  # LAUNCH AGENTS - Services that start at login
  #
  launchd.user.agents = {
    # Tiling window manager - starts automatically at login
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

    # Emacs daemon - provides fast client startup
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
    config.allowUnfree = true; # Required for some packages (VSCode, etc.)
  };

  #
  # FONT CONFIGURATION
  #
  fonts.packages = with pkgs; [
    nerd-fonts.anonymice # Primary font with nerd font patches
    nerd-fonts.symbols-only # Just the nerd font symbols
    nerd-fonts.fira-code # Popular programming font
    nerd-fonts.jetbrains-mono # JetBrains' coding font
    nerd-fonts.hack # Clean, readable coding font
  ];
}
