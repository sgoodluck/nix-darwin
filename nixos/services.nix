# NixOS service configurations
{ config, pkgs, lib, ... }:
{
  # Docker
  virtualisation.docker.enable = true;

  # Printing (CUPS)
  services.printing.enable = true;

  # Avahi - mDNS/DNS-SD for network printer discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
}
