{
  description = "Seth's Zen Nix Flake - macOS and NixOS system configuration";

  inputs = {
    # Main package set — NixOS and Darwin share the same nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";

    # For NixOS, we may want the NixOS-specific branch
    nixpkgs-nixos.url = "github:NixOS/nixpkgs/nixos-25.11";

    # macOS system configuration framework
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # User-level dotfile and package management — shared by both platforms
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Home Manager for NixOS (follows NixOS nixpkgs)
    home-manager-nixos = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs-nixos";
    };

    # Declarative Homebrew management (macOS only)
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    # macOS app linking utility
    mac-app-util.url = "github:hraban/mac-app-util";

    # Homebrew tap repositories (non-flake inputs, macOS only)
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
    homebrew-skip = {
      url = "github:skiptools/homebrew-skip";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nixpkgs-nixos,
      home-manager,
      home-manager-nixos,
      nix-homebrew,
      mac-app-util,
      homebrew-bundle,
      homebrew-aerospace,
      homebrew-supabase,
      homebrew-skip,
    }:
    let
      # ─── macOS Darwin configuration factory ───
      mkDarwinConfig = hostPath: hostName:
        let
          hostConfig = import hostPath {
            inherit (nixpkgs) lib;
            pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          };
        in
        nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit inputs; };
          modules = [
            ./darwin
            mac-app-util.darwinModules.default
            nix-homebrew.darwinModules.nix-homebrew
            {
              nix-homebrew = {
                enable = true;
                enableRosetta = true;
                user = hostConfig.username;
                mutableTaps = true;
                autoMigrate = true;
                taps = {
                  "homebrew/homebrew-bundle" = homebrew-bundle;
                  "nikitabobko/tap" = homebrew-aerospace;
                  "supabase/tap" = homebrew-supabase;
                  "skiptools/skip" = homebrew-skip;
                };
              };
            }
            {
              _module.args.hostConfig = hostConfig;
              users.users.${hostConfig.username}.home = "/Users/${hostConfig.username}";
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                sharedModules = [
                  mac-app-util.homeManagerModules.default
                ];
                users.${hostConfig.username} =
                  { pkgs, ... }:
                  import ./home.nix {
                    inherit pkgs;
                    lib = nixpkgs.lib;
                    personal = hostConfig;
                    config = { };
                  };
                extraSpecialArgs = {
                  hostConfig = hostConfig;
                };
              };
            }
            home-manager.darwinModules.home-manager
          ];
        };

      # ─── NixOS configuration factory ───
      mkNixosConfig = hostPath: hostName:
        let
          hostConfig = import (hostPath + "/default.nix") {
            inherit (nixpkgs-nixos) lib;
            pkgs = nixpkgs-nixos.legacyPackages.x86_64-linux;
          };
        in
        nixpkgs-nixos.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            # Hardware configuration (machine-specific)
            (hostPath + "/hardware-configuration.nix")

            # NixOS system configuration (boot, networking, desktop, packages)
            ./nixos

            # Host config injection + Home Manager integration
            {
              _module.args.hostConfig = hostConfig;

              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                users.${hostConfig.username} =
                  { pkgs, ... }:
                  import ./home.nix {
                    inherit pkgs;
                    lib = nixpkgs-nixos.lib;
                    personal = hostConfig;
                    config = { };
                  };
                extraSpecialArgs = {
                  hostConfig = hostConfig;
                };
              };
            }

            # Home Manager NixOS module
            home-manager-nixos.nixosModules.home-manager
          ];
        };
    in
    {
      # ─── Darwin systems (macOS) ───
      darwinConfigurations = {
        "Seths-MacBook-Pro" = mkDarwinConfig ./hosts/work "Seths-MacBook-Pro";
        "sgoodluck-m1air" = mkDarwinConfig ./hosts/personal "sgoodluck-m1air";
      };

      # ─── NixOS systems ───
      nixosConfigurations = {
        "smartin-nano" = mkNixosConfig ./hosts/nixos-laptop "smartin-nano";
      };
    };
}
