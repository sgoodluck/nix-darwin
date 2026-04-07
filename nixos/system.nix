# NixOS system-level settings
# Parallel to darwin/system.nix — covers boot, networking, users, locale, security
{
  pkgs,
  config,
  lib,
  hostConfig,
  ...
}:

{
  # NixOS state version — do NOT change after initial install
  system.stateVersion = "25.11";

  # Nix settings
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Bootloader — systemd-boot (already working on this machine)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  # Networking
  networking = {
    hostName = hostConfig.machineName;
    networkmanager.enable = true;
    firewall.enable = true;
  };

  # Locale and timezone
  time.timeZone = "America/Los_Angeles";
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # User account
  users.users.${hostConfig.username} = {
    isNormalUser = true;
    description = hostConfig.fullName;
    extraGroups = [
      "wheel" # sudo
      "networkmanager" # network config
      "video" # backlight control
      "audio" # audio devices
      "docker" # docker access without sudo
    ];
    shell = pkgs.zsh;
  };

  # Docker
  virtualisation.docker.enable = true;

  # Enable zsh system-wide (required for it to be a valid login shell)
  programs.zsh.enable = true;

  # nix-ld for running unpatched dynamic binaries (AppImages, pre-compiled binaries, etc.)
  programs.nix-ld.enable = true;

  # Security
  security = {
    # Polkit for privilege escalation (needed by Hyprland, NetworkManager, etc.)
    polkit.enable = true;

    # Allow wheel group to use sudo
    sudo.wheelNeedsPassword = true;
  };

  # GPG agent (replaces pinentry_mac from macOS)
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-curses;
  };

  # SSH daemon
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Tailscale (you use this on macOS too)
  services.tailscale.enable = true;

  # Firmware updates
  services.fwupd.enable = true;

  # Laptop power management
  services.thermald.enable = true;
  services.auto-cpufreq = {
    enable = true;
    settings = {
      battery = {
        governor = "powersave";
        turbo = "never";
      };
      charger = {
        governor = "performance";
        turbo = "auto";
      };
    };
  };

  # Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  services.blueman.enable = true;
}
