{ config, pkgs, inputs, ... }:
let
  backgroundImage = pkgs.stdenvNoCC.mkDerivation {
    name = "background-image";
    src = ./.;  # Assuming the image is in the same directory as your configuration.nix
    dontUnpack = true;
    installPhase = ''
      mkdir -p $out
      cp ./shaded.png $out/
    '';
  };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./main-user.nix
      inputs.home-manager.nixosModules.default
    ];
  
  ## User Settings ##
  main-user.enable = true;
  main-user.userName = "smartin";
  main-user.description = "Seth Martin";
  main-user.extraGroups = [ "networkmanager" "wheel" "docker" "video" ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.hostName = "smartin-nano"; 
  networking.networkmanager = {
    enable = true;
  };

  networking.wireguard.enable = true;
  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
    allowedUDPPortRanges = [
      { from = 1194; to = 1194; }
      { from = 4569; to = 4569; }
    ];
  };

  virtualisation.docker.enable = true;

  # Enable Flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set your time zone.
  time.timeZone = "America/Los_Angeles";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
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

  # Enable Logitech Receiver
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true;
  
  # Enable plain old i3
  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;
  services.displayManager.defaultSession = "none+i3";


  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true; 
    openFirewall = true;
  };
  
  # Enable bluetooth.
  hardware.bluetooth = {
    enable = true; 
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  home-manager = { 
    extraSpecialArgs = { inherit inputs; };
    users = {
      "smartin" = import ./home.nix;
    };
  };

  # Enable hyprland
  services.displayManager.sddm = {
    enable = true;
    theme = "catppuccin-frappe";
    package = pkgs.kdePackages.sddm;
    #wayland.enable = true;
  };

  programs.hyprland = {
    enable = true;
  };

  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Enable ZSH 
  programs.zsh = {
    enable = true; 
    ohMyZsh = {
      enable = true;
      plugins = [ "git" "sudo" ];
    };
  };
  users.defaultUserShell = pkgs.zsh;
  
  # System Packages
  environment.systemPackages = with pkgs; [
    brightnessctl
    light
    zsh
     kdePackages.sddm
     (catppuccin-sddm.override {
      flavor = "frappe";
      font = "_0xproto";
      fontSize = "9";
      background = "${./shaded.png}";
      loginBackground = true;
    })
     vim
     wget
     wofi
     hyprpaper
     networkmanager
     plasma-nm
     waybar
     hyprshot
     hyprlock
     hypridle
     swaynotificationcenter
     libnotify
     ranger
     (xfce.thunar.override { thunarPlugins = [pkgs.xfce.thunar-archive-plugin]; })
     xarchiver
     xfce.tumbler
     unzip
     ripgrep
     git
     tree-sitter
     nodejs
     lazygit
     wl-clipboard
     inputs.zen-browser.packages.${pkgs.system}.default
     inputs.hyprland-qtutils.packages."${pkgs.system}".default
     overskride
     networkmanagerapplet
     wireguard-tools
     protonvpn-cli_2
     dotnet-sdk
  ];
  
  fonts.packages = with pkgs; [
   font-awesome
   nerd-fonts._0xproto
  ];

  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
