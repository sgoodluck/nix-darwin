# Package management configuration for macOS
# Combines Nix packages with declarative Homebrew management
{ pkgs, ... }:
{
  # NOTE: Docker Desktop was installed manually outside of Nix/Homebrew
  environment.systemPackages = with pkgs; [
    # Core development tools
    tree
    git
    curl
    wget
    coreutils
    gnumake
    cmake
    ninja
    neovim
    nixfmt-rfc-style
    gnupg
    pinentry_mac
    ncurses

    # Python development
    (python3.withPackages (
      ps: with ps; [
        black
        pyflakes
        isort
        pytest
        debugpy
        mypy
        python-lsp-server
        rope
      ]
    ))

    # Node.js development
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.prettier
    nodePackages.eslint
    vscode-js-debug
    pnpm

    # Go development
    go
    delve
    gopls
    golangci-lint
    go-tools
    goperf

    # Terminal and shell tools
    zellij
    mkalias
    oh-my-posh
    
    # Claude Code from overlay
    claude-code
  ];

  # Homebrew configuration
  homebrew = {
    enable = true;
    
    global = {
      autoUpdate = false;
      lockfiles = false;
    };
    
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };

    brews = [
      "uv"
      "nmap"
      "ffmpeg"
      "poetry"
      "aspell"
      "hugo"
      "mas"
      "llvm"
      "bear"
      "ccls"
      "ripgrep"
      "fd"
      "markdown"
      "shellcheck"
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
          "with-modern-black-variant-icon"
        ];
      }
    ];

    casks = [
      # Utilities
      "raspberry-pi-imager"
      "appcleaner"
      "balenaetcher"
      "the-unarchiver"
      "keycastr"
      "ghostty"
      
      # Web browsers
      "brave-browser"
      "firefox"
      "zen"
      
      # Development tools
      "visual-studio-code"
      
      # Creative tools
      "gimp"
      "orcaslicer"
      "transmission"
      
      # Privacy & security
      "protonvpn"
      "proton-pass"
      
      # Window management & productivity
      "amethyst"
      "karabiner-elements"
      "obsidian"
    ];

    # Mac App Store apps (uncomment to enable)
    #masApps = {
    #  Xcode = 497799835; # Apple's IDE for macOS/iOS development
    #};
  };

}
