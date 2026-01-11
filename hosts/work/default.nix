# Work machine configuration
{ pkgs, lib, ... }:

{
  # Work identity
  username = "seth.martin@firstresonance.io";
  fullName = "Seth";
  email = "seth.martin@firstresonance.io";
  githubUsername = "smartin-fr";
  gpgKey = "79F5B64411A630A8";

  # Git configuration
  gitConfig = {
    userName = "Seth Martin";
    userEmail = "seth.martin@firstresonance.io";
  };

  # Machine details
  machineName = "Seths-MacBook-Pro";

  # Dock configuration
  dockApps = [
    "/Applications/Alacritty.app"
    "/Applications/Zed.app"
    "/Applications/Zen.app"
    "/Applications/Linear.app"
    "/Applications/Superhuman.app"
    "/Applications/Slack.app"
  ];

  # Work-specific packages
  extraPackages = pkgs: [
    pkgs.awscli2  # AWS Command Line Interface version 2
    # Prismatic CLI - Integration platform CLI tool
    # Using stdenv.mkDerivation since the package lacks package-lock.json
    (pkgs.stdenv.mkDerivation {
      pname = "prism";
      version = "7.10.0";

      src = pkgs.fetchurl {
        url = "https://registry.npmjs.org/@prismatic-io/prism/-/prism-7.10.0.tgz";
        hash = "sha256-pKeG8GUMjTzXMcm0HFJ6GRPdUocPC83iUDBBeRT9y1I=";
      };

      buildInputs = [ pkgs.nodejs pkgs.makeWrapper ];

      unpackPhase = ''
        tar -xzf $src
      '';

      installPhase = ''
        mkdir -p $out/lib/node_modules/@prismatic-io/prism
        cp -r package/* $out/lib/node_modules/@prismatic-io/prism/

        mkdir -p $out/bin
        makeWrapper ${pkgs.nodejs}/bin/node $out/bin/prism \
          --add-flags "$out/lib/node_modules/@prismatic-io/prism/dist/index.js" \
          --prefix NODE_PATH : "$out/lib/node_modules"
      '';

      meta = {
        description = "Build, deploy, and support integrations in Prismatic";
        homepage = "https://prismatic.io/docs/cli/";
        mainProgram = "prism";
      };
    })
  ];

  extraBrews = [
    "postgresql@16"  # PostgreSQL version 16 for specific project requirements
  ];

  extraCasks = [
    #Dev tools
    "cursor" # cursed
    "aws-vpn-client" # don't drop tables
    "pgadmin4" # PostgreSQL admin GUI
    "linear-linear" # because tooling is cool
    "dbeaver-community"

    # Communication tools
    "zoom"          # Video conferencing
    "slack"         # Team communication

    # Google Stuff
    "google-drive"  # File sync

    # Productivity Stuff
    "notion"
    "clockify"
    "superhuman"
    "bitwarden"
  ];

  # Work-specific shell aliases
  extraAliases = {
    # Privileges CLI shortcuts (for managing admin privileges)
    priv = "/Applications/Privileges.app/Contents/MacOS/PrivilegesCLI";
    priv-add = "/Applications/Privileges.app/Contents/MacOS/PrivilegesCLI --add";
    priv-remove = "/Applications/Privileges.app/Contents/MacOS/PrivilegesCLI --remove";
    priv-status = "/Applications/Privileges.app/Contents/MacOS/PrivilegesCLI --status";

    # PostgreSQL aliases
    psql = "/opt/homebrew/opt/postgresql@16/bin/psql";
    pg_dump = "/opt/homebrew/opt/postgresql@16/bin/pg_dump";
    pg_restore = "/opt/homebrew/opt/postgresql@16/bin/pg_restore";
    createdb = "/opt/homebrew/opt/postgresql@16/bin/createdb";
    dropdb = "/opt/homebrew/opt/postgresql@16/bin/dropdb";
    pg_config = "/opt/homebrew/opt/postgresql@16/bin/pg_config";
  };

  # Work-specific shell initialization
  extraShellInit = ''
    # Remote PostgreSQL connection helper
    function rpsql() {
      pgoptions=$PGOPTIONS  # capture original value
      NAMESPACE="ion"  # default if none is provided
      OPTIND=1         # Reset in case getopts has been used previously in the shell.
      while getopts "s:n:" opt; do
        case $opt in
          n) NAMESPACE=''${OPTARG}
          ;;
          s) PGOPTIONS=--search_path=''${OPTARG}
          ;;
          \?) echo "unknown arg -$OPTARG"
          ;;
        esac
      done
      shift $((OPTIND-1))
      if [[ -z $1 ]]; then
        echo "Must provide context as first argument"
        return
      fi
      kubectx $1 && kubens $NAMESPACE && PGOPTIONS=$PGOPTIONS psql $(kubectl exec deploy/notifications -- bash -c "[[ -z \$SQLALCHEMY_DATABASE_URI ]] && cat /tmp/env | grep SQLALCHEMY_DATABASE_URI | cut -d\\\" -f2 || echo \$SQLALCHEMY_DATABASE_URI" 2> /dev/null)
      PGOPTIONS=$pgoptions  # restore original value
    }
  '';

  # Universal preferences (inherited from common)
  preferences = {
    editor = {
      default = "nvim";
      terminal = "nvim";
      gui = "zed";  # Previously: emacs
    };
    shell = "zsh";
    terminalEmulator = "alacritty";
    promptTheme = "zen";
  };
}
