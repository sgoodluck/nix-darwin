{
  description = "Seth's Zen Nix Flake - macOS system configuration using Nix Darwin and Home Manager";

  inputs = {
    # Main package set - using nixpkgs-unstable for macOS compatibility
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    # macOS system configuration framework - using master branch
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # User-level dotfile and package management
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Declarative Homebrew management
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    
    # macOS app linking utility
    mac-app-util.url = "github:hraban/mac-app-util";
    # Homebrew tap repositories (non-flake inputs)
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-emacs-plus = {
      url = "github:d12frosted/homebrew-emacs-plus";
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
      # Import the personal configuration to get machine details
      personalConfig = import ./personal.nix {
        inherit (nixpkgs) lib;
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
      };
      
      # Extract values from personal config
      system = personalConfig.machine.system;
      machineName = personalConfig.machine.name;
    in
    {
      # Define Darwin system configuration for this specific machine
      # The machine name comes from personal.nix, making it easy to manage multiple systems
      darwinConfigurations.${machineName} = nix-darwin.lib.darwinSystem {
        inherit system;
        
        # Modules are evaluated in order and compose the final system configuration
        modules = [
          # Core Darwin system configuration (system settings, packages)
          ./darwin
          
          # Enable macOS app symlinking for GUI apps installed via Nix
          mac-app-util.darwinModules.default
          
          # Declarative Homebrew management module
          nix-homebrew.darwinModules.nix-homebrew
          
          # Configure nix-homebrew with our taps and settings
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = personalConfig.personal.username;
              mutableTaps = false;
              autoMigrate = true;
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-bundle" = homebrew-bundle;
                "homebrew/homebrew-cask" = homebrew-cask;
                "d12frosted/homebrew-emacs-plus" = homebrew-emacs-plus;
              };
            };
          }

          # Configuration module for system-level settings and home-manager integration
          {
            # Inject personal config into all Darwin and Home Manager modules
            # This makes personal settings available everywhere without explicit imports
            _module.args.personal = personalConfig;

            # Define user home directory (required for home-manager)
            users.users.${personalConfig.personal.username}.home = "/Users/${personalConfig.personal.username}";
            
            # Configure home-manager integration
            home-manager = {
              # Use system-level nixpkgs instead of separate instance (saves resources)
              useGlobalPkgs = true;
              # Install packages to user profile instead of system
              useUserPackages = true;
              # Define home configuration for our user
              users.${personalConfig.personal.username} =
                { pkgs, ... }:
                import ./home.nix {
                  inherit pkgs;
                  lib = nixpkgs.lib;
                  personal = personalConfig;
                  config = { };
                };
              
              # Pass personal config to all home-manager modules
              extraSpecialArgs = {
                personal = personalConfig;
              };
            };
          }

          # Load home-manager's Darwin integration module
          home-manager.darwinModules.home-manager
        ];
      };
    };
}
