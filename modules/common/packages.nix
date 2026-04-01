# Common packages shared between work, personal, and NixOS configurations
{ pkgs, lib, ... }:
let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;
in
{
  # NOTE: Docker Desktop was installed manually outside of Nix/Homebrew
  # NOTE: Tailscale was manually installed outside of Nix/Homebrew (macOS) or enabled as service (NixOS)
  environment.systemPackages = with pkgs; [
    # Core development tools
    git
    lazygit
    curl
    wget
    gnumake
    cmake
    ninja
    neovim
    nixfmt-rfc-style
    gnupg
    ncurses
    cocogitto

    # Modern CLI tools (Rust-based alternatives)
    ripgrep
    fd
    eza
    bat
    fzf
    zoxide
    dust
    procs

    # Essential utilities
    jq
    yq
    htop
    direnv
    just

    # System utilities and development tools
    nmap
    ffmpeg
    aspell
    hugo
    llvm
    bear
    ccls
    shellcheck
    clang-tools
    shfmt
    gh

    # Python development
    uv
    poetry
    (python3.withPackages (
      ps: with ps; [
        black
        pyflakes
        isort
        pytest
        debugpy
        mypy
        python-lsp-server
      ]
    ))
    pyright

    # Node.js development
    nodejs
    nodePackages.typescript
    nodePackages.typescript-language-server
    nodePackages.prettier
    nodePackages.eslint
    vscode-js-debug
    pnpm
    bun
    fnm

    # Go development
    go
    delve
    gopls
    golangci-lint
    go-tools

    # Rust development
    rustc
    cargo
    rust-analyzer
    rustfmt

    # Lua and Nix development
    lua-language-server
    nixd
    stylua

    # Terminal and shell tools
    zellij
    oh-my-posh

    # Database tools
    postgresql
    pgcli

    # Kubernetes tools
    kubectl
    kubectx
    stern
    k9s
  ]
  # macOS-only CLI packages
  ++ lib.optionals isDarwin [
    pinentry_mac    # macOS GUI for GPG passphrase entry
    mkalias         # macOS alias creation tool
    postman         # API testing (GUI — macOS via Nix, Linux via flatpak or skip)
    google-chrome   # Available as Nix package on macOS
  ]
  # Linux-only CLI packages
  ++ lib.optionals isLinux [
    pinentry-curses  # Terminal GPG passphrase entry
    xdg-utils        # xdg-open and friends
    file             # file type detection
    unzip
    zip
  ];
}
