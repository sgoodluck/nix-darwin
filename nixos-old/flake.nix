{
  description = "Nixos config flake";

  # defines sources that the flake needs to fetch
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser.url = "github:youwen5/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
    hyprland-qtutils.url = "github:hyprwm/hyprland-qtutils";
  };
  
  # nix code that can be evaluated after fetching inputs
  outputs = { self, nixpkgs, hyprland-qtutils, ... }@inputs: {

    nixosConfigurations = { 

      x1nano = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs;};
        modules = [
          ./hosts/x1nano/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
    };
  };
}
