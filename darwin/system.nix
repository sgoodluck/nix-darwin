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
  #
  home-manager.backupFileExtension = "backup";

  #
  # NIXPKGS CONFIGURATION AND PLATFORM
  #
  nixpkgs = {
    config.allowUnfree = true; # Allow installation of non-free packages
    hostPlatform = "aarch64-darwin"; # Set for Apple Silicon Macs
  };

  #
  # NIX CONFIGURATION
  #
  nix = {
    settings = {
      experimental-features = "nix-command flakes"; # Enable flakes and new CLI
      max-jobs = "auto"; # Parallel build jobs
    };
    optimise.automatic = true; # Safely optimize store
    gc = {
      automatic = true; # Enable automatic garbage collection
      interval = {
        Hour = 0;
      }; # Run GC daily at midnight
      options = "--delete-older-than 30d"; # Remove packages older than 30 days
    };
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
