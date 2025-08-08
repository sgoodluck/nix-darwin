# Common packages shared between work and personal configurations
{ pkgs, ... }:
{
  # NOTE: Docker Desktop was installed manually outside of Nix/Homebrew
  environment.systemPackages = with pkgs; [
    # Core development tools
    tree              # Directory tree visualization
    git               # Version control system
    curl              # HTTP client for API requests and downloads
    wget              # File downloader
    coreutils         # GNU core utilities (ls, cp, mv, etc.)
    gnumake           # Build automation tool
    cmake             # Cross-platform build system generator
    ninja             # Small build system focused on speed
    neovim            # Modern Vim-based text editor
    nixfmt-rfc-style  # Nix code formatter
    gnupg             # GNU Privacy Guard for encryption
    pinentry_mac      # macOS GUI for GPG passphrase entry
    ncurses           # Terminal control library
    
    # Python development
    (python3.withPackages (
      ps: with ps; [
        black                # Python code formatter
        pyflakes             # Python syntax checker
        isort                # Python import sorter
        pytest               # Python testing framework
        debugpy              # Python debugger protocol implementation
        mypy                 # Static type checker for Python
        python-lsp-server    # Language server for Python
        rope                 # Python refactoring library
      ]
    ))
    
    # Node.js development
    nodePackages.typescript                    # TypeScript compiler
    nodePackages.typescript-language-server    # TypeScript language server
    nodePackages.prettier                      # Code formatter for JS/TS
    nodePackages.eslint                        # JavaScript/TypeScript linter
    vscode-js-debug                           # JavaScript debugger
    pnpm                                      # Fast package manager for Node.js
    fnm                                       # Fast Node Manager - Rust-based nvm alternative
    
    # Go development
    go                # Go programming language
    delve             # Go debugger
    gopls             # Go language server
    golangci-lint     # Go linter aggregator
    go-tools          # Go development tools (goimports, gorename, etc.)
    goperf            # Go performance analysis tools
    
    # Terminal and shell tools
    zellij            # Terminal multiplexer (alternative to tmux)
    mkalias           # macOS alias creation tool
    oh-my-posh        # Cross-platform prompt theme engine
    
    # AI development tools
    claude-code       # Claude Code from overlay - AI coding assistant
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
      "uv"              # Fast Python package installer and resolver
      "nmap"            # Network discovery and security auditing tool
      "ffmpeg"          # Multimedia framework for audio/video processing
      "poetry"          # Python dependency management and packaging
      "aspell"          # Spell checker
      "hugo"            # Static site generator
      "mas"             # Mac App Store command line interface
      "llvm"            # Compiler infrastructure and toolchain
      "bear"            # Build tool for generating compilation databases
      "ccls"            # C/C++/Objective-C language server
      "ripgrep"         # Fast text search tool (grep alternative)
      "fd"              # Fast and user-friendly find alternative
      "markdown"        # Markdown processor
      "shellcheck"      # Shell script static analysis tool
      "node"            # Node.js JavaScript runtime
      "nvm"             # Node Version Manager
      "clang-format"    # C/C++/Java/JavaScript code formatter
      "pipenv"          # Python virtual environment and dependency manager
      "shfmt"           # Shell script formatter
      {
        name = "emacs-plus";  # Enhanced Emacs build with additional features
        args = [
          "with-ctags"                      # Include ctags support
          "with-mailutils"                  # Email handling capabilities
          "with-xwidgets"                   # Web widget support
          "with-imagemagick"                # Image processing support
          "with-modern-black-variant-icon"  # Modern black app icon
        ];
      }
    ];
    
    casks = [
      # Utilities
      "appcleaner"        # Application uninstaller and cleanup tool
      "the-unarchiver"    # Archive extraction utility
      "keycastr"          # Keystroke visualizer for presentations
      "ghostty"           # Modern terminal emulator
      
      # Web browsers
      "firefox"           # Mozilla Firefox web browser
      "zen"               # Privacy-focused Firefox-based browser
      "google-chrome"     # Google Chrome web browser
      
      # Development tools
      "visual-studio-code" # Microsoft's code editor
      "cursor"            # AI-powered code editor
 
      # Creative tools
      "gimp"              # GNU Image Manipulation Program
      
      # Window management & productivity
      "nikitabobko/tap/aerospace"  # i3-inspired tiling window manager for macOS
      "karabiner-elements"         # Keyboard customization tool (keep for custom key mappings)
    ];
  };
}