# Package management configuration for macOS
# Combines Nix packages with declarative Homebrew management
# 
# Organization:
# - Nix packages: Development tools, compilers, language servers
# - Homebrew brews: CLI tools not available in Nix
# - Homebrew casks: GUI applications
{ pkgs, ... }:
{
  # NOTE: Docker Desktop was installed manually outside of Nix/Homebrew

  #
  # SYSTEM PACKAGES
  #
  environment.systemPackages = with pkgs; [
    #
    # CORE DEVELOPMENT TOOLS
    #
    tree # Directory tree visualization
    git # Version control (configured in home.nix)
    curl # HTTP/HTTPS client
    wget # Non-interactive network downloader
    coreutils # Essential GNU utilities (ls, cat, etc.)
    gnumake # Standard build tool
    cmake # Cross-platform build system
    ninja # High-performance build system
    neovim # Modal text editor (vim successor)
    nixfmt-rfc-style # Official Nix formatter

    #
    # PYTHON DEVELOPMENT ENVIRONMENT
    #
    (python3.withPackages (
      ps: with ps; [
        black # Code formatter
        pyflakes # Static code analyzer
        isort # Import sorter
        pytest # Testing framework
        debugpy # Debugging tool
        mypy # Static type checker
        python-lsp-server # Language server for Python
        rope # Refactoring library
      ]
    ))

    #
    # NODE.JS DEVELOPMENT
    #
    nodePackages.typescript # TypeScript language support
    nodePackages.typescript-language-server # Language server
    nodePackages.prettier # Code formatter
    nodePackages.eslint # JavaScript/TypeScript linter
    vscode-js-debug # DAP-compliant debugger for JavaScript
    pnpm # Fast, disk space efficient package manager

    #
    # GO DEVELOPMENT
    #
    go # Go compiler and toolchain
    delve # Debugger for Go (used with editors or CLI)
    gopls # Go language server (autocomplete, lint, hover, etc.)
    golangci-lint # Fast, configurable linter aggregator for Go
    go-tools # Collection of official Go dev tools (includes vet, etc.)
    goperf # Go performance analysis tool

    #
    # TERMINAL AND SHELL TOOLS
    #
    alacritty # GPU-accelerated terminal emulator
    zellij # Modern terminal multiplexer (tmux alternative)
    mkalias # macOS app alias creator for Nix apps
    oh-my-posh # Cross-shell prompt theme engine
  ];

  #
  # HOMEBREW CONFIGURATION AND PACKAGES
  #
  homebrew = {
    enable = true;
    
    # Activation behavior - runs during darwin-rebuild
    onActivation = {
      cleanup = "zap"; # Remove anything not declared here
      autoUpdate = true; # Update formulae definitions
      upgrade = true; # Upgrade installed packages
    };

    # Note: Homebrew taps are declared in flake.nix via nix-homebrew

    # Command-line tools installed via Homebrew
    brews = [
      "uv" # Ultra-fast Python package manager
      "nmap" # Network exploration and security auditing
      "ffmpeg" # Audio/video processing Swiss army knife
      "poetry" # Python dependency management
      "aspell" # Spell checker (used by Emacs)
      "hugo" # Static site generator
      "mas" # Mac App Store CLI
      "llvm" # Compiler infrastructure
      "bear" # Compilation database generator
      "ccls" # C/C++ language server
      "ripgrep" # Blazing fast grep alternative (rg)
      "fd" # User-friendly find alternative
      "markdown" # Markdown to HTML converter
      "shellcheck" # Bash/shell script linter
      "node" # JavaScript runtime (for npm packages)
      "clang-format" # LLVM's code formatter
      "pipenv" # Python virtual environment manager
      "shfmt" # Go-based shell formatter
      {
        name = "emacs-plus"; # The only editor you'll ever need
        args = [
          "with-ctags"
          "with-mailutils"
          "with-xwidgets"
          "with-imagemagick"
          "with-modern-black-variant-icon"
        ];
      }
    ];

    # GUI applications installed via Homebrew Cask
    casks = [
      # Utilities
      "raspberry-pi-imager" # SD card writer for Raspberry Pi
      "appcleaner" # Thorough app uninstaller
      "balenaetcher" # USB/SD card image writer
      "the-unarchiver" # Archive extraction tool
      "keycastr" # Keystroke visualizer for screencasts
      
      # Web browsers
      "brave-browser" # Privacy-focused Chromium browser
      "firefox" # Mozilla's web browser
      "zen" # Web browser
      
      # Development tools
      "visual-studio-code" # Microsoft's code editor
      
      # Creative tools
      "gimp" # GNU Image Manipulation Program
      "orcaslicer" # Advanced 3D printing slicer
      "transmission" # BitTorrent client
      
      # Privacy & security
      "protonvpn" # Privacy-focused VPN service
      "proton-pass" # Encrypted password manager
      
      # Window management & productivity
      "amethyst" # Automatic tiling window manager
      "karabiner-elements" # Keyboard customizer
      "obsidian" # Markdown-based knowledge base
      
      # Entertainment
      "tidal" # Hi-fi music streaming
    ];

    # Mac App Store apps (uncomment to enable)
    #masApps = {
    #  Xcode = 497799835; # Apple's IDE for macOS/iOS development
    #};
  };

}
