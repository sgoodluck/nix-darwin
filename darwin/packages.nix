{ pkgs, ... }:
{
  #
  # SYSTEM PACKAGES
  #
  environment.systemPackages = with pkgs; [
    #
    # DEVELOPMENT TOOLS
    #
    karabiner-elements # hyperkey magic
    skhd # hotkeys for yabai
    yabai # i3wm like wm
    git # Version control system
    curl # Data transfer tool
    wget # File download utility
    coreutils # GNU file, shell and text utilities
    gnumake # Build automation tool
    cmake # Build system generator
    ninja # Fast build system
    neovim # Text editor
    nixfmt-rfc-style # Nix code formatter

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

    #
    # USER TOOLS
    #
    mkalias # Tool for creating macOS aliases
    oh-my-posh # Shell prompt customization
    obsidian # Note-taking application
  ];

  #
  # HOMEBREW CONFIGURATION AND PACKAGES
  #
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap"; # Remove anything not declared
      autoUpdate = true; # Update formulae on activation
      upgrade = true; # Upgrade packages on activation
    };

    taps = [
      "homebrew/homebrew-core" # Main package repository
      "homebrew/homebrew-cask" # GUI applications
      "homebrew/homebrew-bundle" # Brewfile support
      "d12frosted/homebrew-emacs-plus" # Enhanced Emacs
    ];

    brews = [
      "mas" # Mac App Store CLI
      "llvm" # Compiler infrastructure
      "bear" # Compilation database generator
      "ccls" # C/C++ language server
      "ripgrep" # Fast text search tool
      "fd" # Simple, fast file finder
      "markdown" # Text-to-HTML conversion
      "shellcheck" # Shell script static analyzer
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

    casks = [
      "the-unarchiver" # Archive extraction tool
      "zen-browser" # Web browser
      "protonvpn" # VPN client
      "proton-pass" # Password manager
      #"amethyst" # Tiling window manager
      "bambu-studio" # 3D printer software
      "tidal" # Music streaming service
    ];

    masApps = {
      Xcode = 497799835; # Apple's IDE for macOS/iOS development
    };
  };
}
