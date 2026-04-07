# NixOS package management
# Imports shared common packages + adds host-specific and Linux-specific packages
{
  pkgs,
  lib,
  hostConfig,
  ...
}:
{
  imports = [
    ../modules/common/packages.nix
  ];

  # Override packages not yet updated in nixpkgs
  nixpkgs.overlays = [
    (final: prev: {
      supabase-cli = prev.stdenv.mkDerivation rec {
        pname = "supabase-cli";
        version = "2.84.2";

        src = prev.fetchzip {
          url = "https://github.com/supabase/cli/releases/download/v${version}/supabase_linux_amd64.tar.gz";
          sha256 = "sha256-4WUKpyMagNUQAjMe3dYSCcWEM+Q4jX4hLByYr/3nLvk=";
          stripRoot = false;
        };

        nativeBuildInputs = [ prev.installShellFiles ];

        installPhase = ''
          runHook preInstall
          install -Dm755 supabase -t $out/bin
          runHook postInstall
        '';

        postInstall = ''
          installShellCompletion --cmd supabase \
            --bash <($out/bin/supabase completion bash) \
            --zsh <($out/bin/supabase completion zsh) \
            --fish <($out/bin/supabase completion fish)
        '';

        meta = with prev.lib; {
          description = "Supabase CLI";
          homepage = "https://supabase.com";
          license = licenses.mit;
          platforms = [ "x86_64-linux" ];
        };
      };
    })
  ];

  # Add host-specific Nix packages (from hosts/nixos-laptop/default.nix)
  environment.systemPackages =
    if (hostConfig ? extraPackages) then (hostConfig.extraPackages pkgs) else [ ];
}
