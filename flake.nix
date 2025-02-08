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
        let

          #
          # PYTHON DEVELOPMENT PACKAGES
          #
          pythonPackages = with pkgs.python3Packages; [
            black # Code formatter
            pyflakes # Static code analyzer
            isort # Import sorter
            pytest # Testing framework
            debugpy # Debugging tool
            mypy # Static type checker
            python-lsp-server # Language server for Python
            rope # Refactoring library
          ];

          #
          # NODE.JS DEVELOPMENT PACKAGES
          #
          nodePackages = with pkgs.nodePackages; [
            typescript # TypeScript language support
            typescript-language-server # Language server for TypeScript
            prettier # Code formatter
            eslint # JavaScript/TypeScript linter
          ];

          #
          # DEVELOPMENT TOOLS AND UTILITIES
          #
          devTools = with pkgs; [
            cmake # Build system generator
            gnumake # Build automation tool
            ninja # Fast build system
            nixfmt-rfc-style # Nix code formatter
            neovim # Text editor
            git # Version control
          ];

          #
          # GENERAL UTILITY PACKAGES
          #
          utilityPackages = with pkgs; [
            mkalias # Tool for creating macOS aliases
            oh-my-posh # Shell prompt customization
            obsidian # Note-taking application
          ];
        in
        {

          #
          # NIXPKGS CONFIGURATION AND PLATFORM
          #
          nixpkgs = {
            config.allowUnfree = true; # Allow installation of non-free packages
            hostPlatform = "aarch64-darwin"; # Set for Apple Silicon Macs
          };

          #
          # SYSTEM CONFIGURATION AND STATE
          #
          system = {
            stateVersion = 5;  # System state version
          };

          #
          # SECURITY AND AUTHENTICATION
          #
          security.pam.enableSudoTouchIdAuth = true; # Enable TouchID for sudo authentication

          #
          # PACKAGE MANAGEMENT AND NIX SETTINGS
          #
          nix = {
            settings = {
              experimental-features = "nix-command flakes"; # Enable flakes and new CLI
              max-jobs = "auto"; # Parallel build jobs
            };
            optimise.automatic = true;  # Safely optimize store
            gc = {
              automatic = true; # Enable automatic garbage collection
              interval = {
                Hour = 0;
              }; # Run GC daily
              options = "--delete-older-than 30d"; # Remove packages older than 30 days
            };
          };

          #
          # SYSTEM PACKAGES AND ENVIRONMENT
          #
          environment.systemPackages =
            with pkgs;
            [
              (python3.withPackages (ps: pythonPackages)) # Python with selected packages
            ]
            ++ devTools
            ++ nodePackages
            ++ utilityPackages;

          #
          # FONT CONFIGURATION AND THEMING
          #
          fonts.packages = with pkgs; [
            (nerdfonts.override {
              fonts = [
                "AnonymousPro" # Monospace font for coding
                "NerdFontsSymbolsOnly" # Icons and symbols
                "FiraCode" # Font with programming ligatures
                "JetBrainsMono" # Clear monospace font
                "Hack" # Clean monospace font
              ];
            })
          ];

          #
          # HOMEBREW CONFIGURATION AND PACKAGES
          #
          homebrew = {
            enable = true;
            onActivation = {
              cleanup = "zap"; # Remove anything not declared here
              autoUpdate = true; # Update formulae on activation
              upgrade = true; # Upgrade packages on activation
            };

            # Package sources
            taps = [
              "homebrew/homebrew-core" # Main package repository
              "homebrew/homebrew-cask" # GUI applications
              "homebrew/homebrew-bundle" # Brewfile support
              "d12frosted/homebrew-emacs-plus" # Enhanced Emacs
            ];

            # CLI packages
            brews = [
              "mas" # Mac App Store CLI
              "llvm" # Compiler infrastructure
              "bear" # Compilation database generator
              "ccls" # C/C++ language server
              "git" # Version control system
              "ripgrep" # Fast text search tool
              "coreutils" # GNU file, shell, and text utilities
              "fd" # Simple, fast file finder
              "markdown" # Text-to-HTML conversion tool
              "shellcheck" # Shell script static analyzer
              "cmake" # Build system generator
              "node" # JavaScript runtime
              "clang-format" # C/C++ code formatter
              "pipenv" # Python dependency manager
              "shfmt" # Shell script formatter
              {
                name = "emacs-plus"; # Enhanced Emacs distribution
                args = [
                  "with-ctags" # For code navigation
                  "with-mailutils" # For email support
                  "with-xwidgets" # For web browser support
                  "with-imagemagick" # For image processing
                  "with-native-comp" # For native compilation
                  "with-modern-icon" # Modern styling
                ];
              }
            ];

            # GUI applications
            casks = [
              "the-unarchiver" # Archive extraction tool
              "zen-browser" # Web browser
              "protonvpn" # VPN client
              "proton-pass" # Password manager
              "amethyst" # Tiling window manager
              "bambu-studio" # 3D printer software
              "tidal" # Music streaming service
            ];

            # Mac App Store applications
            masApps = {
              Xcode = 497799835; # Apple's IDE for macOS/iOS development
            };
          };

          #
          # SHELL AND PROGRAM CONFIGURATION
          #
          programs = {
            # ZSH settings
            zsh = {
              enable = true;
              enableCompletion = true; # Enable completion system
              enableBashCompletion = true; # Enable bash compatibility
              promptInit = ""; # Disable default prompt
              # Use ohmyposh
              interactiveShellInit = ''
                eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/zen.toml)" 
              '';
              # Set up environment paths
              shellInit = ''
                export XDG_CONFIG_HOME="$HOME/.config"
                export PATH="$XDG_CONFIG_HOME/emacs/bin:$PATH"
                export PATH="$HOME/.emacs.d/bin:$PATH"
                export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
                export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

                # Nix Rebuild Alias
                alias nixr="darwin-rebuild switch --flake ~/.config/nix#m1air"
              '';
            };
          };
        };
    in
    {

      #
      # DARWIN SYSTEM CONFIGURATION
      #
      darwinConfigurations."m1air" = nix-darwin.lib.darwinSystem {
        modules = [
          mac-app-util.darwinModules.default
          configuration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true; # Enable x86_64 app support
              user = "seth"; # Username
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
