# Common packages shared between work and personal configurations
{ pkgs, ... }:
{
  # NOTE: Docker Desktop was installed manually outside of Nix/Homebrew
  environment.systemPackages = with pkgs; [
    # Core development tools
    git               # Version control system
    lazygit           # because sometimes I'm lazy
    curl              # HTTP client for API requests and REST calls
    wget              # Simple file downloader for scripts and automation
    gnumake           # Build automation tool
    cmake             # Cross-platform build system generator
    ninja             # Small build system focused on speed
    neovim            # Modern Vim-based text editor
    nixfmt-rfc-style  # Nix code formatter
    gnupg             # GNU Privacy Guard for encryption
    pinentry_mac      # macOS GUI for GPG passphrase entry
    ncurses           # Terminal control library
    postman           # API testing area
    cocogitto         # conventional commits baby!
    
    # Modern CLI tools (Rust-based alternatives)
    ripgrep           # Fast text search tool (grep replacement)
    fd                # Fast and user-friendly find alternative
    eza               # Modern ls replacement with colors and icons
    bat               # Cat with syntax highlighting and Git integration
    fzf               # Fuzzy finder for interactive file/command selection
    zoxide            # Smart cd replacement that learns your habits
    dust              # Modern du disk usage analyzer with tree view
    procs             # Modern ps process viewer with colored output
    
    # Essential utilities
    jq                # JSON processor for parsing and manipulating JSON data
    yq                # YAML processor, pairs well with jq
    htop              # Interactive process viewer (better than top)
    direnv            # Automatic environment switching per directory
    just              # Modern alternative to make for running project commands
    
    # System utilities and development tools
    nmap              # Network discovery and security auditing tool
    ffmpeg            # Multimedia framework for audio/video processing
    aspell            # Spell checker for text processing
    hugo              # Static site generator for websites
    llvm              # Compiler infrastructure and toolchain
    bear              # Build tool for generating compilation databases
    ccls              # C/C++/Objective-C language server
    shellcheck        # Shell script static analysis tool
    clang-tools       # C/C++ development tools (includes clang-format)
    shfmt             # Shell script formatter
    gh                # GitHub CLI for repository management and workflows
    # Python development
    uv                # Extremely fast Python package installer and resolver
    poetry            # Python dependency management and packaging
    (python3.withPackages (
      ps: with ps; [
        black                # Python code formatter
        pyflakes             # Python syntax checker
        isort                # Python import sorter
        pytest               # Python testing framework
        debugpy              # Python debugger protocol implementation
        mypy                 # Static type checker for Python
        python-lsp-server    # Language server for Python
      ]
    ))
    
    # Node.js development
    nodejs                                     # Node.js JavaScript runtime
    nodePackages.typescript                    # TypeScript compiler
    nodePackages.typescript-language-server    # TypeScript language server
    nodePackages.prettier                      # Code formatter for JS/TS
    nodePackages.eslint                        # JavaScript/TypeScript linter
    vscode-js-debug                           # JavaScript debugger for editors (check if needed for Emacs DAP)
    pnpm                                      # Fast package manager for Node.js
    fnm                                       # Fast Node Manager - Rust-based nvm alternative
    
    # Go development
    go                # Go programming language
    delve             # Go debugger (dlv command)
    gopls             # Go language server
    golangci-lint     # Go linter aggregator
    go-tools          # Go development tools (goimports, gorename, etc.)

    # Rust development
    rustc             # Rust compiler
    cargo             # Rust package manager and build system
    
    # Terminal and shell tools
    zellij            # Terminal multiplexer (alternative to tmux)
    mkalias           # macOS alias creation tool
    oh-my-posh        # Cross-platform prompt theme engine
    
    # AI development tools
    claude-code       # Claude Code AI coding assistant
    
    # Kubernetes tools
    kubectl           # Kubernetes CLI for managing clusters
    kubectx           # Fast way to switch between clusters and namespaces
    stern             # Multi pod and container log tailing
    k9s               # Terminal-based UI to interact with Kubernetes clusters
  ];
  
  # Homebrew configuration
  homebrew = {
    enable = true;
    
    global = {
      autoUpdate = false;   # Disable automatic updates
      lockfiles = false;    # Don't create lockfiles
    };
    
    onActivation = {
      cleanup = "zap";      # Remove all formulae not listed
      autoUpdate = true;    # Update homebrew on activation
      upgrade = true;       # Upgrade existing packages
    };
    
    brews = [
      "mas"             # Mac App Store command line interface
      "git-graph"       # show off
      "nvm"             # Node Version Manager (better shell integration than fnm)
      "markdown"        # Markdown processor for documentation
      "moor"            # a modern pager
      "riff"            # a better diff
      "kube-ps1"        # Kubernetes prompt helper for showing current context/namespace
      "asciiquarium"    # for fun
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
      "alacritty"         # GPU-accelerated terminal emulator
      
      # Web browsers
      "firefox"           # Mozilla Firefox web browser
      "zen"               # Privacy-focused Firefox-based browser
      
      # Development tools
      "visual-studio-code" # Microsoft's code editor
 
      # Creative tools
      "gimp"              # GNU Image Manipulation Program
      
      # Window management & productivity
      "nikitabobko/tap/aerospace"  # i3-inspired tiling window manager for macOS
      "karabiner-elements"         # Keyboard customization tool (keep for custom key mappings)

      # Music Please
      "tidal"           # I love me some hifi
    ];
  };
}
