{
  description = "Seth's Zen Nix Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    mac-app-util.url = "github:hraban/mac-app-util";
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
      system = "aarch64-darwin";
      machineName = "sgoodluck-m1air";

      # Import the personal configuration
      personalConfig = import ./personal.nix {
        inherit (nixpkgs) lib;
        pkgs = nixpkgs.legacyPackages.${system};
      };
    in
    {
      darwinConfigurations.${machineName} = nix-darwin.lib.darwinSystem {
        inherit system;
        modules = [
          ./darwin
          mac-app-util.darwinModules.default
          nix-homebrew.darwinModules.nix-homebrew
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

          {
            # Make personal config available to all modules
            _module.args.personal = personalConfig;

            users.users.${personalConfig.personal.username}.home = "/Users/${personalConfig.personal.username}";
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${personalConfig.personal.username} =
                { pkgs, ... }:
                import ./home.nix {
                  inherit pkgs;
                  lib = nixpkgs.lib;
                  personal = personalConfig;
                  config = { };
                };
              # Make personal config available to home-manager modules
              extraSpecialArgs = {
                personal = personalConfig;
              };
            };
          }

          home-manager.darwinModules.home-manager
        ];
      };
    };
}
