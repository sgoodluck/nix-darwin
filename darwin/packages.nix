{ pkgs, ... }:
{
  #
  # NOTES
  #

  # DOCKER DESKTOP was installed manually

  #
  # SYSTEM PACKAGES
  #
  environment.systemPackages = with pkgs; [
    #
    # DEVELOPMENT TOOLS
    #
    tree # for seeing files man
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
    vscode-js-debug
    pnpm

    #
    # GO DEVELOPMENT
    #
    go # Go compiler and toolchain
    delve # Debugger for Go (used with editors or CLI)
    gopls # Go language server (autocomplete, lint, hover, etc.)
    golangci-lint # Fast, configurable linter aggregator for Go
    go-tools # Collection of official Go dev tools (includes vet, etc.)
    goperf

    #
    # USER TOOLS
    #
    alacritty # I like it fast and simple
    zellij # Terminal multiplexer
    mkalias # Tool for creating macOS aliases
    oh-my-posh # Shell prompt customization
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
      "uv" # new python goat
      "nmap" # network mapping
      "ffmpeg" # audioo
      "poetry" # because python is
      "aspell" # i lke too spel rite
      "hugo" # blogging made easy
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

    casks = [
      "raspberry-pi-imager" # who loves pi?
      "appcleaner" # no
      "brave-browser" # when you need chrome...
      "balenaetcher" # live iso
      "transmission" # torrents babe
      "visual-studio-code" # wimp
      "gimp" # yay image editing
      "orcaslicer" # 3d printers rock dude
      "keycastr" # show keys
      "the-unarchiver" # Archive extraction tool
      "zen-browser" # Web browser
      "firefox" # for when I have to
      "protonvpn" # VPN client
      "proton-pass" # Password manager
      "amethyst" # Tiling window manager
      "karabiner-elements" # Hyperkey magic
      "tidal" # Music streaming service
      "obsidian" # Note taking for sharing
    ];

    #masApps = {
    # Xcode = 497799835; # Apple's IDE for macOS/iOS development
    #};
  };

}
