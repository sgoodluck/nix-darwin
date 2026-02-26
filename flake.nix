{
  description = "Seth's Zen Nix Flake - macOS system configuration using Nix Darwin and Home Manager";

  inputs = {
    # Main package set - using nixpkgs 25.05 Darwin branch for macOS
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";

    # macOS system configuration framework - using corresponding nix-darwin branch
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # User-level dotfile and package management - using release branch
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Declarative Homebrew management
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    # macOS app linking utility
    mac-app-util.url = "github:hraban/mac-app-util";
    # Homebrew tap repositories (non-flake inputs)
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-aerospace = {
      url = "github:nikitabobko/homebrew-aerospace";
      flake = false;
    };
    homebrew-supabase = {
      url = "github:supabase/homebrew-tap";
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
      homebrew-bundle,
      homebrew-aerospace,
      homebrew-supabase,
    }:
    let
      # Helper function to create a Darwin configuration
      mkDarwinConfig = hostPath: hostName: 
        let
          # Import the host-specific configuration
          hostConfig = import hostPath {
            inherit (nixpkgs) lib;
            pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          };
        in
        nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs; };

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
                user = hostConfig.username;
                mutableTaps = true;
                autoMigrate = true;
                taps = {
                  # Only manage non-core taps
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                  "nikitabobko/tap" = homebrew-aerospace;
                  "supabase/tap" = homebrew-supabase;
                };
              };
            }

            # Configuration module for system-level settings and home-manager integration
            {
              # Inject host config into all Darwin and Home Manager modules
              # This makes host settings available everywhere without explicit imports
              _module.args.hostConfig = hostConfig;

              # Define user home directory (required for home-manager)
              users.users.${hostConfig.username}.home = "/Users/${hostConfig.username}";

              # Configure home-manager integration
              home-manager = {
                # Use system-level nixpkgs instead of separate instance (saves resources)
                useGlobalPkgs = true;
                # Install packages to user profile instead of system
                useUserPackages = true;
                # Automatically backup conflicting files with .backup extension
                backupFileExtension = "backup";
                # Enable mac-app-util to create .app bundles for Nix GUI apps
                sharedModules = [
                  mac-app-util.homeManagerModules.default
                ];
                # Define home configuration for our user
                users.${hostConfig.username} =
                  { pkgs, ... }:
                  import ./home.nix {
                    inherit pkgs;
                    lib = nixpkgs.lib;
                    personal = hostConfig;
                    config = { };
                  };

                # Pass host config to all home-manager modules
                extraSpecialArgs = {
                  hostConfig = hostConfig;
                };
              };
            }

            # Load home-manager's Darwin integration module
            home-manager.darwinModules.home-manager
          ];
        };
    in
    {
      # Define Darwin system configurations for both machines
      darwinConfigurations = {
        "Seths-MacBook-Pro" = mkDarwinConfig ./hosts/work "Seths-MacBook-Pro";
        "sgoodluck-m1air" = mkDarwinConfig ./hosts/personal "sgoodluck-m1air";
      };
    };
}
