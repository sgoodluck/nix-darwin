# System-level settings and font configuration
{
  pkgs,
  config,
  lib,
  hostConfig,
  ...
}:

{
  # System configuration
  system.stateVersion = 5; # Don't change after initial install
  system.primaryUser = hostConfig.username;
  nix.enable = false; # Handled by Determinate Systems installer

  # Ensure Homebrew-installed Emacs appears in /Applications
  # Configure Claude Code statusline in user settings (merges, doesn't overwrite)
  system.activationScripts.postActivation.text = ''
    mkdir -p /Applications/Nix
    ln -sf "/opt/homebrew/opt/emacs-plus/Emacs.app" /Applications/

    CLAUDE_SETTINGS="$HOME/.claude/settings.json"
    if [ -f "$CLAUDE_SETTINGS" ]; then
      if ! ${pkgs.jq}/bin/jq -e '.statusLine' "$CLAUDE_SETTINGS" > /dev/null 2>&1; then
        ${pkgs.jq}/bin/jq '. + {"statusLine": {"type": "command", "command": ($ENV.HOME + "/.claude/statusline.sh")}}' \
          "$CLAUDE_SETTINGS" > "$CLAUDE_SETTINGS.tmp" && mv "$CLAUDE_SETTINGS.tmp" "$CLAUDE_SETTINGS"
      fi
    else
      mkdir -p "$HOME/.claude"
      echo '{"statusLine":{"type":"command","command":"'"$HOME"'/.claude/statusline.sh"}}' \
        | ${pkgs.jq}/bin/jq . > "$CLAUDE_SETTINGS"
    fi
  '';

  # Security
  security.pam.services.sudo_local.touchIdAuth = true;

  # macOS preferences
  system = {

    defaults = {

      dock = {
        autohide = true;
        orientation = "right";
        show-recents = false;
        tilesize = 48;
        persistent-apps = hostConfig.dockApps or [];
      };

      finder = {
        FXPreferredViewStyle = "clmv"; # Column view as default
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      screencapture = {
        location = "~/Pictures/screenshots";
      };

      NSGlobalDomain = {
        _HIHideMenuBar = true;
        AppleShowAllFiles = true;
        AppleShowAllExtensions = true;
        KeyRepeat = 2;
        InitialKeyRepeat = 15;
        AppleMeasurementUnits = "Centimeters";
        AppleMetricUnits = 1;
        AppleTemperatureUnit = "Celsius";
        AppleICUForce24HourTime = true;
        "com.apple.swipescrolldirection" = false;
      };
    };
  };

  # Nixpkgs configuration
  nixpkgs.config.allowUnfree = true;

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.anonymice
    nerd-fonts.symbols-only
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.hack
    nerd-fonts.caskaydia-cove
  ];
}
