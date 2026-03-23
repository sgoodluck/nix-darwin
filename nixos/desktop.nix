# NixOS desktop environment — Hyprland + Wayland + Pipewire
# This is the Linux equivalent of macOS's Aerospace + system audio + login window
{
  pkgs,
  config,
  lib,
  hostConfig,
  ...
}:

{
  # Hyprland — declarative Wayland compositor
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Login manager — greetd with tuigreet (lightweight, terminal-based)
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  # XDG portal for Hyprland (screen sharing, file picker dialogs)
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # Audio — Pipewire (replaces PulseAudio)
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };
  # Explicitly disable PulseAudio (conflicts with Pipewire)
  services.pulseaudio.enable = false;

  # Fonts — same nerd fonts as macOS config
  fonts = {
    packages = with pkgs; [
      nerd-fonts.anonymice
      nerd-fonts.symbols-only
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.hack
      nerd-fonts.caskaydia-cove
      nerd-fonts.sauce-code-pro
      # Extra fonts for Linux desktop
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      liberation_ttf
    ];
    fontconfig = {
      defaultFonts = {
        serif = [ "Liberation Serif" "Noto Serif" ];
        sansSerif = [ "Noto Sans" "Liberation Sans" ];
        monospace = [ "SauceCodePro Nerd Font" "Noto Sans Mono" ];
      };
    };
  };

  # Hyprland ecosystem packages (installed system-wide)
  environment.systemPackages = with pkgs; [
    # Status bar
    waybar

    # Wallpaper
    hyprpaper

    # App launcher
    wofi

    # Notification daemon
    swaynotificationcenter

    # Screen locker
    hyprlock
    hypridle

    # Screenshot
    hyprshot
    grim
    slurp

    # Clipboard
    wl-clipboard
    cliphist

    # Brightness
    brightnessctl

    # Audio control (GUI)
    pavucontrol

    # Cursor theme
    adwaita-icon-theme
  ];

  # Environment variables for Wayland session
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    GDK_BACKEND = "wayland,x11";
    QT_QPA_PLATFORM = "wayland;xcb";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };
}
