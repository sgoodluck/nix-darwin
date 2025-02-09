{
  description = "Seth's Zen Nix Flake";

  #
  # INPUTS AND PACKAGE SOURCES
  #
  inputs = {
    #
    # CORE NIX PACKAGES AND DARWIN SYSTEM
    #
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin"; # Main package repository for Darwin
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11"; # Darwin-specific system configuration
      inputs.nixpkgs.follows = "nixpkgs"; # Ensure consistent package versions
    };

    #
    # HOME MANAGER FOR USER ENVIRONMENT
    #
    home-manager = {
      url = "github:nix-community/home-manager"; # User environment management
      inputs.nixpkgs.follows = "nixpkgs"; # Use same nixpkgs as system
    };

    #
    # MACOS-SPECIFIC TOOLS
    #
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew"; # Homebrew integration for Nix
    mac-app-util.url = "github:hraban/mac-app-util"; # Nix utilities for macOS application management

    #
    # HOMEBREW PACKAGE SOURCES
    #
    homebrew-core = {
      url = "github:homebrew/homebrew-core"; # Main Homebrew package repository
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask"; # GUI application repository for Homebrew
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle"; # Bundler for Homebrew packages
      flake = false;
    };
    homebrew-emacs-plus = {
      url = "github:d12frosted/homebrew-emacs-plus"; # Enhanced Emacs distribution
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      nix-homebrew,
      mac-app-util,
      homebrew-core,
      homebrew-cask,
      homebrew-bundle,
      homebrew-emacs-plus,
    }:
    let
      # Global variables
      username = "seth"; # Username for system configuration
      system = "aarch64-darwin"; # Platform specification for Apple Silicon
    in
    {
      #
      # CONFIGURE DARWIN SYSTEM
      #
      darwinConfigurations."m1air" = nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          #
          # CONFIGURE MACOSX UTILITIES
          #
          mac-app-util.darwinModules.default
          nix-homebrew.darwinModules.nix-homebrew

          #
          # CONFIGURE HOME MANAGER
          #
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true; # Use system nixpkgs
            home-manager.useUserPackages = true; # Install to /etc/profiles
            home-manager.users.${username} = import ./home.nix; # User-specific config
          }

          #
          # LOAD SYSTEM CONFIGURATIONS
          #
          ./darwin # System-level settings

          #
          # CONFIGURE HOMEBREW
          #
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true; # Enable x86_64 app support
              user = username; # Homebrew installation user
              mutableTaps = false; # Manage taps through Nix
              autoMigrate = true; # Auto-migrate Homebrew installation
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-bundle" = homebrew-bundle;
                "homebrew/homebrew-cask" = homebrew-cask;
                "d12frosted/homebrew-emacs-plus" = homebrew-emacs-plus;
              };
            };
          }
        ];
      };
    };
}
