{
  description = "Seth's Zen Nix Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-24.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
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
      nix-homebrew,
      mac-app-util,
      homebrew-core,
      homebrew-cask,
      homebrew-bundle,
      homebrew-emacs-plus,
    }:
    let
      configuration =
        {
          pkgs,
          config,
          lib,
          ...
        }:
        {
          nixpkgs.config.allowUnfree = true;

          security.pam.enableSudoTouchIdAuth = true;

          homebrew = {
            enable = true;
            onActivation = {
              cleanup = "zap";
              autoUpdate = true;
              upgrade = true;
            };
            taps = [
              "homebrew/homebrew-core"
              "homebrew/homebrew-cask"
              "homebrew/homebrew-bundle"
              "d12frosted/homebrew-emacs-plus"
            ];
            brews = [
              "mas"
              "llvm"
              "bear" # For generating compilation databases
              "ccls"
              "git"
              "ripgrep"
              "coreutils"
              "fd"
              "markdown"
              "shellcheck"
              "cmake"
              "node"
              "clang-format"
              "pipenv"
              "shfmt"
              {
                name = "emacs-plus";
                args = [
                  "with-ctags"
                  "with-mailutils"
                  "with-xwidgets"
                  "with-imagemagick"
                  "with-native-comp"
                ];
              }
            ];
            casks = [
              "the-unarchiver"
              "zen-browser"
              "protonvpn"
              "proton-pass"
              "amethyst"
              "bambu-studio"
              "tidal"
            ];
            masApps = {
              Xcode = 497799835;
            };
          };

          programs.zsh = {
            enable = true;
            interactiveShellInit = ''
              eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/zen.toml)"
            '';
            shellInit = ''
              export XDG_CONFIG_HOME="$HOME/.config"
              export PATH="$XDG_CONFIG_HOME/emacs/bin:$PATH"
              export PATH="$HOME/.emacs.d/bin:$PATH"
              export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
              export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
            '';
          };

          environment.systemPackages = with pkgs; [
            cmake
            gnumake
            nixfmt-rfc-style
            neovim
            mkalias
            oh-my-posh
            obsidian
            (python3.withPackages (
              ps: with ps; [
                black
                pyflakes
                isort
                pipenv
                pytest
                debugpy
              ]
            ))
          ];

          fonts.packages = with pkgs; [
            (nerdfonts.override {
              fonts = [
                "AnonymousPro"
                "NerdFontsSymbolsOnly"
              ];
            })
          ];

          system.defaults = {
            dock.autohide = true;
          };

          nix = {
            settings = {
              experimental-features = "nix-command flakes";
            };
            extraOptions = ''
              extra-platforms = x86_64-darwin aarch64-darwin
            '';
          };

          system.configurationRevision = self.rev or self.dirtyRev or null;

          system.stateVersion = lib.mkForce 5;

          nixpkgs.hostPlatform = "aarch64-darwin";
        };
    in
    {
      darwinConfigurations."m1air" = nix-darwin.lib.darwinSystem {
        modules = [
          mac-app-util.darwinModules.default
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = "seth";
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
        ];
      };
    };
}
